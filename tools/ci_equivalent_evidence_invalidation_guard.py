#!/usr/bin/env python3
"""Decide whether a passed CI-equivalent artifact can be reused on the current heads."""

from __future__ import annotations

import argparse
import fnmatch
import json
import subprocess
import sys
from pathlib import Path

from github_promotion_source_authority_guard import (
    BRANCH_AUTHORITY_SECTION,
    extract_sections,
    find_section,
    normalize_ref_name,
    parse_baselines,
    read_lines,
)


REPO_ROOT = Path(__file__).resolve().parents[2]
RULE_ID = "paced.ci-equivalent.evidence-invalidation"
EXIT_REUSABLE = 0
EXIT_RERUN_REQUIRED = 10
EXIT_MANUAL_ADMISSION_REQUIRED = 11
EXIT_INVALID = 2


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Determine whether a passed CI-equivalent artifact is still reusable on the current heads."
    )
    parser.add_argument("--governing-todo", required=True, help="TODO that records the authoritative branch baselines.")
    parser.add_argument("--policy", required=True, help="Project-owned evidence reuse/invalidation policy JSON.")
    parser.add_argument("--report", required=True, help="Passed CI-equivalent report artifact to evaluate for reuse.")
    parser.add_argument("--json-output", help="Optional path for a machine-readable decision payload.")
    return parser.parse_args()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_path(raw_path: str) -> Path:
    path = Path(raw_path)
    if path.is_absolute():
        return path
    return (Path.cwd() / path).resolve()


def git(repo_root: Path, *args: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(repo_root), *args],
        check=True,
        text=True,
        capture_output=True,
    )
    return completed.stdout.strip()


def git_optional(repo_root: Path, *args: str) -> str | None:
    completed = subprocess.run(
        ["git", "-C", str(repo_root), *args],
        check=False,
        text=True,
        capture_output=True,
    )
    if completed.returncode != 0:
        return None
    return completed.stdout.strip()


def normalize_globs(globs: list[str] | None) -> list[str]:
    return [entry.strip() for entry in (globs or []) if entry and entry.strip()]


def matches_any(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, pattern) for pattern in patterns)


def parse_todo_baselines(todo_path: Path) -> dict[str, tuple[str, str]]:
    sections = extract_sections(read_lines(todo_path))
    baselines_section = find_section(sections, BRANCH_AUTHORITY_SECTION)
    baselines, issues = parse_baselines(baselines_section)
    if issues:
        raise ValueError(" ".join(issues))
    return baselines


def classify_paths(
    changed_paths: list[str],
    *,
    safe_reuse_globs: list[str],
    invalidating_globs: list[str],
) -> tuple[list[str], list[str]]:
    safe_paths: list[str] = []
    invalidating_paths: list[str] = []
    for changed_path in changed_paths:
        normalized = changed_path.strip()
        if not normalized:
            continue
        if matches_any(normalized, invalidating_globs):
            invalidating_paths.append(normalized)
            continue
        if matches_any(normalized, safe_reuse_globs):
            safe_paths.append(normalized)
            continue
        invalidating_paths.append(normalized)
    return safe_paths, invalidating_paths


def render_output(payload: dict) -> str:
    lines = [
        "CI Equivalent Evidence Invalidation Guard",
        f"Project root: {payload['project_root']}",
        f"Governing TODO: {payload['governing_todo']}",
        f"Policy: {payload['policy_path']}",
        f"Report: {payload['report_path']}",
        f"Contract ID: {payload['contract_id']}",
        f"Report baseline source: {payload['report_baseline_source']}",
        "",
        "Per-repo decisions",
    ]
    for repo in payload["repos"]:
        lines.extend(
            [
                f"- {repo['repo_key']}: {repo['decision']}",
                f"  repo_path: {repo['repo_path']}",
                f"  baseline_branch: {repo['baseline_branch']}",
                f"  baseline_sha: {repo['baseline_sha']}",
                f"  current_branch: {repo['current_branch']}",
                f"  current_sha: {repo['current_sha']}",
            ]
        )
        if repo["changed_paths"]:
            lines.append(f"  changed_paths: {', '.join(repo['changed_paths'])}")
        if repo["safe_paths"]:
            lines.append(f"  safe_paths: {', '.join(repo['safe_paths'])}")
        if repo["invalidating_paths"]:
            lines.append(f"  invalidating_paths: {', '.join(repo['invalidating_paths'])}")
        if repo["notes"]:
            lines.append(f"  notes: {' | '.join(repo['notes'])}")

    lines.extend(
        [
            "",
            "TEACH runtime response",
            f"status: {payload['status']}",
            f"enforcement: {payload['enforcement']}",
            f"rule_id: {RULE_ID}",
            "resolution_prompt:",
        ]
    )
    for resolution in payload["resolutions"]:
        lines.append(f"  - {resolution}")
    lines.extend(["", f"Overall outcome: {payload['overall_outcome']}"])
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()

    try:
        todo_path = resolve_path(args.governing_todo)
        policy_path = resolve_path(args.policy)
        report_path = resolve_path(args.report)

        policy = load_json(policy_path)
        if policy.get("schema_version") != "ci-evidence-reuse-policy-v1":
            raise ValueError(f"{policy_path} must declare schema_version=ci-evidence-reuse-policy-v1")

        report = load_json(report_path)
        if report.get("artifact_kind") != "ci_contract_run":
            raise ValueError(f"{report_path} must be a ci_contract_run artifact")
        if report.get("overall_status") != "passed":
            raise ValueError(f"{report_path} is not reusable because overall_status is not `passed`")

        todo_baselines = parse_todo_baselines(todo_path)
        report_repo_states = report.get("repo_states") or {}
        report_baseline_source = "report-repo-states" if report_repo_states else "governing-todo-baselines"

        repos_payload: list[dict] = []
        overall_decision = "reusable"
        resolutions: list[str] = []

        for repo_policy in policy.get("repos", []):
            repo_key = repo_policy["repo_key"]
            repo_path = resolve_path(repo_policy["repo_path"])
            safe_reuse_globs = normalize_globs(repo_policy.get("safe_reuse_globs"))
            invalidating_globs = normalize_globs(repo_policy.get("invalidating_globs"))
            baseline_branch = None
            baseline_sha = None
            notes: list[str] = []

            report_state = report_repo_states.get(repo_key)
            if report_state:
                baseline_branch = normalize_ref_name(report_state.get("branch", "")) or None
                baseline_sha = report_state.get("head_sha") or None
                notes.append("baseline comes from the report artifact repo_states block")
            if not baseline_sha:
                todo_entry = todo_baselines.get(repo_key)
                if not todo_entry:
                    raise ValueError(
                        f"Governing TODO {todo_path} does not declare a baseline for repo `{repo_key}`."
                    )
                baseline_branch = baseline_branch or normalize_ref_name(todo_entry[0])
                baseline_sha = todo_entry[1]
                notes.append("report had no repo_states for this repo; fell back to governing TODO branch@sha")

            current_branch = normalize_ref_name(git(repo_path, "branch", "--show-current"))
            current_sha = git(repo_path, "rev-parse", "HEAD")
            dirty_status = git(repo_path, "status", "--short")

            repo_result = {
                "repo_key": repo_key,
                "repo_path": str(repo_path),
                "baseline_branch": baseline_branch or "unknown",
                "baseline_sha": baseline_sha,
                "current_branch": current_branch or "DETACHED",
                "current_sha": current_sha,
                "changed_paths": [],
                "safe_paths": [],
                "invalidating_paths": [],
                "decision": "reusable",
                "notes": notes,
            }

            if dirty_status:
                repo_result["decision"] = "manual-admission-required"
                repo_result["notes"].append("worktree is dirty; clean authoritative state is required")
                overall_decision = "manual-admission-required"
                repos_payload.append(repo_result)
                continue

            if baseline_branch and current_branch and current_branch != baseline_branch:
                repo_result["decision"] = "manual-admission-required"
                repo_result["notes"].append(
                    "current branch diverges from the baseline branch; refresh authority or switch back before reuse"
                )
                overall_decision = "manual-admission-required"
                repos_payload.append(repo_result)
                continue

            if current_sha == baseline_sha:
                repos_payload.append(repo_result)
                continue

            merge_base = git_optional(repo_path, "merge-base", baseline_sha, current_sha)
            if merge_base != baseline_sha:
                repo_result["decision"] = "manual-admission-required"
                repo_result["notes"].append(
                    "current head is not a descendant of the baseline head; deterministic file-level reuse is unsafe"
                )
                overall_decision = "manual-admission-required"
                repos_payload.append(repo_result)
                continue

            changed_paths = [
                line.strip()
                for line in git(repo_path, "diff", "--name-only", f"{baseline_sha}..{current_sha}").splitlines()
                if line.strip()
            ]
            repo_result["changed_paths"] = changed_paths
            safe_paths, invalidating_paths = classify_paths(
                changed_paths,
                safe_reuse_globs=safe_reuse_globs,
                invalidating_globs=invalidating_globs,
            )
            repo_result["safe_paths"] = safe_paths
            repo_result["invalidating_paths"] = invalidating_paths

            if invalidating_paths:
                repo_result["decision"] = "rerun-required"
                repo_result["notes"].append(
                    "at least one changed path is outside the safe-reuse allowlist or matches an explicit invalidating glob"
                )
                if overall_decision == "reusable":
                    overall_decision = "rerun-required"
            else:
                repo_result["notes"].append("all changed paths are explicitly marked safe for evidence reuse")

            repos_payload.append(repo_result)

        if overall_decision == "reusable":
            resolutions.append("reuse the passed CI-equivalent artifact; do not rerun the broad stage-full gate.")
            status = "ready"
            enforcement = "allow_existing_ci_equivalent"
            exit_code = EXIT_REUSABLE
        elif overall_decision == "rerun-required":
            resolutions.append(
                "rerun the broad CI-equivalent/stage-full gate on the current authoritative heads before claiming readiness."
            )
            resolutions.append(
                "after the rerun passes, refresh the governing TODO/report references to the new passed artifact."
            )
            status = "blocked"
            enforcement = "rerun_ci_equivalent_before_promotion"
            exit_code = EXIT_RERUN_REQUIRED
        else:
            resolutions.append(
                "refresh the authoritative branch/todo/report state first; deterministic evidence reuse is unsafe on the current topology."
            )
            resolutions.append(
                "when the branch authority and baseline artifact are coherent again, rerun this guard before deciding on stage-full reuse."
            )
            status = "blocked"
            enforcement = "manual_authority_refresh_required"
            exit_code = EXIT_MANUAL_ADMISSION_REQUIRED

        output_payload = {
            "artifact_kind": "ci_equivalent_evidence_invalidation_decision",
            "schema_version": "ci-equivalent-evidence-invalidation-v1",
            "contract_id": report.get("contract_id") or policy.get("contract_id") or "unknown",
            "project_root": str(REPO_ROOT),
            "governing_todo": str(todo_path),
            "policy_path": str(policy_path),
            "report_path": str(report_path),
            "report_baseline_source": report_baseline_source,
            "status": status,
            "enforcement": enforcement,
            "overall_outcome": overall_decision,
            "repos": repos_payload,
            "resolutions": resolutions,
        }
        print(render_output(output_payload), end="")
        if args.json_output:
            output_path = resolve_path(args.json_output)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(json.dumps(output_payload, indent=2) + "\n", encoding="utf-8")
        return exit_code
    except Exception as exc:  # noqa: BLE001 - deterministic CLI error path
        print(f"ERROR: {exc}", file=sys.stderr)
        return EXIT_INVALID


if __name__ == "__main__":
    raise SystemExit(main())
