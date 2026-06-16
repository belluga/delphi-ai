#!/usr/bin/env python3
"""Deterministic post-reconcile replay guard for orchestration promotion handoff.

This guard validates that an accepted reconcile state was replayed back onto the
canonical return branch before promotion or non-orchestration closeout resumes.
It consumes the orchestration execution plan plus a real authoritative source
checkout so the replay claim is backed by both plan evidence and local git
topology.

Exit codes:
  0  GO: replay evidence is complete and promotion may resume from the canonical branch.
  2  NO-GO: deterministic blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path
from typing import Any

from orchestration_delivery_guard import validate_delivery
from orchestration_plan_completion_guard import (
    build_violation,
    extract_field,
    extract_sections,
    is_placeholder,
    normalize_text,
    references_reconcile_branch,
    section_has_content,
)


RULE_ID = "paced.orchestration.reconcile-replay"
REPLAY_STATUS_ALLOWED = {"passed", "blocked", "pending", "waived", "n/a"}
REPLAY_MODE_ALLOWED = {"fast-forward", "merge-commit", "curated-replay", "same-commit-alias"}
POST_REPLAY_CI_ALLOWED = {"passed", "not-needed", "waived", "blocked", "pending"}
COMMIT_RE = re.compile(r"\b[0-9a-fA-F]{7,40}\b")


def git(repo_path: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repo_path), *args],
        check=False,
        capture_output=True,
        text=True,
    )


def repo_is_git_root(repo_path: Path) -> bool:
    result = git(repo_path, "rev-parse", "--show-toplevel")
    return result.returncode == 0


def resolve_commit(repo_path: Path, rev: str) -> str | None:
    result = git(repo_path, "rev-parse", "--verify", f"{rev}^{{commit}}")
    if result.returncode != 0:
        return None
    return result.stdout.strip() or None


def branch_head(repo_path: Path, branch: str) -> str | None:
    return resolve_commit(repo_path, branch)


def is_ancestor(repo_path: Path, ancestor: str, descendant: str) -> bool:
    result = git(repo_path, "merge-base", "--is-ancestor", ancestor, descendant)
    return result.returncode == 0


def parse_commit_list(value: str) -> list[str]:
    return COMMIT_RE.findall(value)


def has_approval_text(value: str) -> bool:
    lowered = normalize_text(value)
    return "approval" in lowered or "aprovado" in lowered


def validate_replay(
    plan_path: Path,
    repo_path: Path,
    allow_waivers: bool,
) -> dict[str, Any]:
    context: dict[str, Any] = {
        "plan_path": str(plan_path),
        "repo_path": str(repo_path),
        "replay_status": "unknown",
        "replay_mode": "unknown",
        "authoritative_return_branch": "unknown",
        "promotion_source_branch": "unknown",
        "post_replay_ci_status": "unknown",
    }
    violations: list[dict[str, str]] = []

    delivery_result = validate_delivery(plan_path, require_approved=True, allow_waivers=allow_waivers)
    if delivery_result["blocked"]:
        for violation in delivery_result["violations"]:
            violations.append(
                build_violation(
                    f"DELIVERY-{violation['code']}",
                    violation["message"],
                    violation["resolution"],
                    violation["section"],
                )
            )

    if not plan_path.is_file():
        return {
            "blocked": True,
            "violations": violations
            or [
                build_violation(
                    "PLAN-NOT-FOUND",
                    f"Plan file does not exist: {plan_path}",
                    "Create or restore the orchestration execution plan before claiming reconcile replay is complete.",
                    "Plan File",
                )
            ],
            "context": context,
        }

    lines = plan_path.read_text(encoding="utf-8").splitlines()
    sections = extract_sections(lines)
    topology_lines = sections.get("Orchestration Topology", [])
    replay_lines = sections.get("Post-Reconcile Replay Evidence", [])

    topology_return_branch = extract_field(topology_lines, "Authoritative return branch after reconcile")
    topology_promotion_source = extract_field(topology_lines, "Promotion source after reconcile")

    if not replay_lines:
        violations.append(
            build_violation(
                "REPLAY-SECTION-MISSING",
                "The plan does not include `## Post-Reconcile Replay Evidence`.",
                "Add `## Post-Reconcile Replay Evidence` to the orchestration execution plan and record the concrete replay proof before promotion or closeout resumes.",
                "Post-Reconcile Replay Evidence",
            )
        )
        return {"blocked": True, "violations": violations, "context": context}

    if not section_has_content(replay_lines):
        violations.append(
            build_violation(
                "REPLAY-SECTION-EMPTY",
                "The post-reconcile replay section has no concrete content.",
                "Fill `## Post-Reconcile Replay Evidence` with concrete replay fields and passed evidence before promotion resumes.",
                "Post-Reconcile Replay Evidence",
            )
        )
        return {"blocked": True, "violations": violations, "context": context}

    replay_required = extract_field(replay_lines, "Replay required?")
    replay_status = extract_field(replay_lines, "Replay status")
    accepted_reconcile_branch = extract_field(replay_lines, "Accepted reconcile branch")
    accepted_reconcile_commit = extract_field(replay_lines, "Accepted reconcile commit")
    replay_mode = extract_field(replay_lines, "Replay mode")
    authoritative_return_branch_verified = extract_field(replay_lines, "Authoritative return branch verified")
    authoritative_return_head = extract_field(replay_lines, "Authoritative return branch head after replay")
    promotion_source_branch_verified = extract_field(replay_lines, "Promotion source branch verified")
    replay_commits = extract_field(replay_lines, "Replay commit(s) on authoritative branch")
    replay_proof_summary = extract_field(replay_lines, "Replay proof summary")
    post_replay_ci_status = extract_field(replay_lines, "Post-replay authoritative CI-equivalent status")

    context["replay_status"] = replay_status or "missing"
    context["replay_mode"] = replay_mode or "missing"
    context["authoritative_return_branch"] = authoritative_return_branch_verified or topology_return_branch or "missing"
    context["promotion_source_branch"] = promotion_source_branch_verified or topology_promotion_source or "missing"
    context["post_replay_ci_status"] = post_replay_ci_status or "missing"

    if replay_required is None or is_placeholder(replay_required):
        violations.append(
            build_violation(
                "REPLAY-REQUIRED-MISSING",
                "The plan does not declare whether replay back onto the canonical branch is required.",
                "Record `- **Replay required?:** yes` once the package was first integrated on `reconcile/*`, then fill the remaining replay evidence fields before promotion resumes.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_required) != "yes":
        violations.append(
            build_violation(
                "REPLAY-REQUIRED-NOT-CONFIRMED",
                f"Replay required is `{replay_required}`, but this guard only clears reconcile-origin packages after replay reaches the canonical branch.",
                "If the package was first integrated on `reconcile/*`, record `Replay required?: yes`, replay the accepted net effect onto the canonical return branch, and rerun this guard. If no reconcile-origin handoff exists, do not use this guard for the package.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if replay_status is None or is_placeholder(replay_status):
        violations.append(
            build_violation(
                "REPLAY-STATUS-MISSING",
                "The plan does not record the replay status.",
                "Set `Replay status` to `passed` only after the canonical branch has received the accepted reconcile net effect and the remaining replay evidence fields are complete.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_status) not in REPLAY_STATUS_ALLOWED:
        violations.append(
            build_violation(
                "REPLAY-STATUS-INVALID",
                f"Replay status is `{replay_status}`, expected one of {sorted(REPLAY_STATUS_ALLOWED)}.",
                "Use `passed` after the canonical branch replay is complete. Use `blocked|pending` while the replay is still open.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_status) == "waived":
        if not allow_waivers or not has_approval_text(replay_proof_summary or ""):
            violations.append(
                build_violation(
                    "REPLAY-WAIVER-APPROVAL-MISSING",
                    "Replay status is `waived` without explicit approval evidence.",
                    "Either complete the canonical replay and mark the status `passed`, or rerun with `--allow-waivers` only after recording explicit approval evidence in `Replay proof summary`.",
                    "Post-Reconcile Replay Evidence",
                )
            )
    elif normalize_text(replay_status) != "passed":
        violations.append(
            build_violation(
                "REPLAY-NOT-PASSED",
                f"Replay status is `{replay_status}`.",
                "Do not resume promotion or non-orchestration closeout until the accepted reconcile state has been replayed onto the canonical branch and `Replay status` is `passed`.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if accepted_reconcile_branch is None or is_placeholder(accepted_reconcile_branch):
        violations.append(
            build_violation(
                "ACCEPTED-RECONCILE-BRANCH-MISSING",
                "The plan does not record which reconciliation branch produced the accepted state.",
                "Record the accepted `reconcile/*` branch in `Accepted reconcile branch` so the replay source is explicit.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif not references_reconcile_branch(accepted_reconcile_branch):
        violations.append(
            build_violation(
                "ACCEPTED-RECONCILE-BRANCH-INVALID",
                f"Accepted reconcile branch does not point to `reconcile/*`: {accepted_reconcile_branch}",
                "Record the actual orchestration reconciliation branch that produced the accepted integrated state.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if accepted_reconcile_commit is None or is_placeholder(accepted_reconcile_commit):
        violations.append(
            build_violation(
                "ACCEPTED-RECONCILE-COMMIT-MISSING",
                "The plan does not record the accepted reconcile commit.",
                "Record the accepted reconcile commit SHA so the canonical replay can be verified deterministically.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif not COMMIT_RE.fullmatch(accepted_reconcile_commit.strip()):
        violations.append(
            build_violation(
                "ACCEPTED-RECONCILE-COMMIT-INVALID",
                f"Accepted reconcile commit is not a git SHA: {accepted_reconcile_commit}",
                "Record a concrete git commit SHA for the accepted reconcile state.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if replay_mode is None or is_placeholder(replay_mode):
        violations.append(
            build_violation(
                "REPLAY-MODE-MISSING",
                "The plan does not record how the replay reached the canonical branch.",
                "Record `Replay mode` as `fast-forward`, `merge-commit`, `same-commit-alias`, or `curated-replay`.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_mode) not in REPLAY_MODE_ALLOWED:
        violations.append(
            build_violation(
                "REPLAY-MODE-INVALID",
                f"Replay mode is `{replay_mode}`, expected one of {sorted(REPLAY_MODE_ALLOWED)}.",
                "Use one of the canonical replay modes so the remaining evidence can be interpreted deterministically.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if authoritative_return_branch_verified is None or is_placeholder(authoritative_return_branch_verified):
        violations.append(
            build_violation(
                "RETURN-BRANCH-VERIFIED-MISSING",
                "The plan does not record which canonical branch received the accepted replay.",
                "Record `Authoritative return branch verified` with the canonical version/source branch that now contains the accepted reconcile net effect.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif topology_return_branch and authoritative_return_branch_verified != topology_return_branch:
        violations.append(
            build_violation(
                "RETURN-BRANCH-VERIFIED-MISMATCH",
                f"Replay evidence names `{authoritative_return_branch_verified}` but the topology recorded `{topology_return_branch}`.",
                "Replay evidence must point back to the same canonical return branch declared under `## Orchestration Topology`.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if promotion_source_branch_verified is None or is_placeholder(promotion_source_branch_verified):
        violations.append(
            build_violation(
                "PROMOTION-SOURCE-VERIFIED-MISSING",
                "The plan does not record which branch promotion will actually use after replay.",
                "Record `Promotion source branch verified` with the canonical branch that promotion will use after replay.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif topology_promotion_source and promotion_source_branch_verified != topology_promotion_source:
        violations.append(
            build_violation(
                "PROMOTION-SOURCE-VERIFIED-MISMATCH",
                f"Replay evidence names `{promotion_source_branch_verified}` but the topology recorded `{topology_promotion_source}`.",
                "Promotion replay evidence must point to the same promotion-source branch declared under `## Orchestration Topology`.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif references_reconcile_branch(promotion_source_branch_verified):
        violations.append(
            build_violation(
                "PROMOTION-SOURCE-VERIFIED-INVALID",
                f"Promotion source branch verified still points to `reconcile/*`: {promotion_source_branch_verified}",
                "Replay onto the canonical version/source branch first. Promotion may not resume from `reconcile/*`.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if (
        authoritative_return_branch_verified
        and promotion_source_branch_verified
        and authoritative_return_branch_verified != promotion_source_branch_verified
    ):
        violations.append(
            build_violation(
                "RETURN-AND-PROMOTION-SOURCE-MISMATCH",
                f"Replay evidence records different canonical branches for return and promotion: `{authoritative_return_branch_verified}` vs `{promotion_source_branch_verified}`.",
                "For reconcile-origin promotion, the promotion source must be the same canonical branch that received the accepted replay.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if authoritative_return_head is None or is_placeholder(authoritative_return_head):
        violations.append(
            build_violation(
                "RETURN-HEAD-MISSING",
                "The plan does not record the canonical branch head after replay.",
                "Record `Authoritative return branch head after replay` with the exact git SHA that promotion will advance from.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif not COMMIT_RE.fullmatch(authoritative_return_head.strip()):
        violations.append(
            build_violation(
                "RETURN-HEAD-INVALID",
                f"Authoritative return branch head after replay is not a git SHA: {authoritative_return_head}",
                "Record the exact git SHA currently at the canonical return branch head after replay.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if replay_proof_summary is None or is_placeholder(replay_proof_summary):
        violations.append(
            build_violation(
                "REPLAY-PROOF-MISSING",
                "The plan does not explain how the accepted reconcile state was replayed onto the canonical branch.",
                "Record a concise replay proof summary naming the merge/cherry-pick/fast-forward path and the exact evidence used to confirm the handoff.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if replay_commits is None or is_placeholder(replay_commits):
        violations.append(
            build_violation(
                "REPLAY-COMMIT-LIST-MISSING",
                "The plan does not record which commit(s) on the canonical branch prove the replay.",
                "Record `Replay commit(s) on authoritative branch` as `same-as-reconcile` or list the replay commit SHA(s) on the canonical branch.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_mode or "") == "curated-replay" and normalize_text(replay_commits) == "same-as-reconcile":
        violations.append(
            build_violation(
                "CURATED-REPLAY-COMMIT-LIST-INVALID",
                "Curated replay cannot use `same-as-reconcile` as the canonical replay commit proof.",
                "List the actual canonical-branch replay commit SHA(s) created during the curated replay.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if post_replay_ci_status is None or is_placeholder(post_replay_ci_status):
        violations.append(
            build_violation(
                "POST-REPLAY-CI-STATUS-MISSING",
                "The plan does not record the post-replay CI-equivalent outcome on the canonical branch.",
                "Record `Post-replay authoritative CI-equivalent status` as `passed` or `not-needed` according to the replay policy before promotion resumes.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(post_replay_ci_status) not in POST_REPLAY_CI_ALLOWED:
        violations.append(
            build_violation(
                "POST-REPLAY-CI-STATUS-INVALID",
                f"Post-replay CI-equivalent status is `{post_replay_ci_status}`, expected one of {sorted(POST_REPLAY_CI_ALLOWED)}.",
                "Use `passed` when the canonical branch required a rerun, or `not-needed` only when the replay policy genuinely allowed a bounded sanity check instead of a full rerun.",
                "Post-Reconcile Replay Evidence",
            )
        )
    elif normalize_text(replay_mode or "") == "curated-replay" and normalize_text(post_replay_ci_status) != "passed":
        violations.append(
            build_violation(
                "POST-REPLAY-CI-RERUN-MISSING",
                f"Replay mode `{replay_mode}` requires a full canonical-branch CI-equivalent rerun, but the recorded status is `{post_replay_ci_status}`.",
                "Run the in-scope CI-equivalent matrix on the canonical branch after the curated replay and record the status as `passed` before promotion resumes.",
                "Post-Reconcile Replay Evidence",
            )
        )

    if repo_is_git_root(repo_path):
        source_branch = promotion_source_branch_verified or topology_promotion_source
        return_branch = authoritative_return_branch_verified or topology_return_branch
        source_head = branch_head(repo_path, source_branch) if source_branch and not is_placeholder(source_branch) else None
        return_head = branch_head(repo_path, return_branch) if return_branch and not is_placeholder(return_branch) else None
        reconcile_commit = resolve_commit(repo_path, accepted_reconcile_commit) if accepted_reconcile_commit else None

        if source_branch and source_head is None:
            violations.append(
                build_violation(
                    "PROMOTION-SOURCE-BRANCH-NOT-FOUND",
                    f"Promotion source branch cannot be resolved in the authoritative repo: {source_branch}",
                    "Check out or fetch the canonical promotion-source branch locally before claiming replay handoff is complete.",
                    "Post-Reconcile Replay Evidence",
                )
            )

        if return_branch and return_head is None:
            violations.append(
                build_violation(
                    "RETURN-BRANCH-NOT-FOUND",
                    f"Authoritative return branch cannot be resolved in the authoritative repo: {return_branch}",
                    "Check out or fetch the canonical return branch locally before claiming replay handoff is complete.",
                    "Post-Reconcile Replay Evidence",
                )
            )

        if authoritative_return_head and return_head and authoritative_return_head != return_head:
            violations.append(
                build_violation(
                    "RETURN-HEAD-MISMATCH",
                    f"Recorded canonical head `{authoritative_return_head}` does not match the local branch head `{return_head}`.",
                    "Refresh the replay evidence after the canonical branch reaches the final replay SHA, then rerun this guard.",
                    "Post-Reconcile Replay Evidence",
                )
            )

        if accepted_reconcile_commit and reconcile_commit is None:
            violations.append(
                build_violation(
                    "RECONCILE-COMMIT-NOT-FOUND",
                    f"Accepted reconcile commit cannot be resolved locally: {accepted_reconcile_commit}",
                    "Fetch or restore the accepted reconcile commit locally so the canonical replay can be verified against a real git anchor.",
                    "Post-Reconcile Replay Evidence",
                )
            )

        normalized_mode = normalize_text(replay_mode or "")
        normalized_replay_commits = normalize_text(replay_commits or "")
        if source_head and reconcile_commit and normalized_mode in {"fast-forward", "merge-commit", "same-commit-alias"}:
            if not is_ancestor(repo_path, reconcile_commit, source_head):
                violations.append(
                    build_violation(
                        "REPLAY-ANCESTRY-NOT-PROVEN",
                        f"Canonical promotion source `{source_branch}` does not contain the accepted reconcile commit `{reconcile_commit}` for replay mode `{replay_mode}`.",
                        "Replay the accepted reconcile state onto the canonical branch, verify the branch now contains that commit, update the replay evidence, and rerun this guard.",
                        "Post-Reconcile Replay Evidence",
                    )
                )

        if source_head and normalized_mode == "curated-replay":
            commit_list = parse_commit_list(replay_commits or "")
            if not commit_list:
                violations.append(
                    build_violation(
                        "CURATED-REPLAY-COMMIT-LIST-MISSING",
                        "Curated replay mode does not list the canonical replay commit SHA(s).",
                        "Record the curated replay commit SHA(s) created on the canonical branch and rerun this guard.",
                        "Post-Reconcile Replay Evidence",
                    )
                )
            else:
                for commit_id in commit_list:
                    resolved_replay_commit = resolve_commit(repo_path, commit_id)
                    if resolved_replay_commit is None:
                        violations.append(
                            build_violation(
                                "CURATED-REPLAY-COMMIT-NOT-FOUND",
                                f"Curated replay commit cannot be resolved locally: {commit_id}",
                                "Fetch or restore the canonical replay commit locally so the replay handoff can be verified.",
                                "Post-Reconcile Replay Evidence",
                            )
                        )
                        continue
                    if not is_ancestor(repo_path, resolved_replay_commit, source_head):
                        violations.append(
                            build_violation(
                                "CURATED-REPLAY-COMMIT-NOT-ON-SOURCE",
                                f"Curated replay commit `{resolved_replay_commit}` is not contained in the canonical promotion source `{source_branch}`.",
                                "Replay the accepted net effect onto the canonical branch, ensure the listed replay commits are present there, update the evidence, and rerun this guard.",
                                "Post-Reconcile Replay Evidence",
                            )
                        )
    else:
        violations.append(
            build_violation(
                "REPO-NOT-GIT",
                f"Authoritative repo path is not a git checkout: {repo_path}",
                "Run this guard from, or point `--repo` at, the real authoritative source checkout that will feed promotion after replay.",
                "Authoritative Repo",
            )
        )

    return {
        "blocked": bool(violations),
        "violations": violations,
        "context": context,
    }


def render_text(result: dict[str, Any]) -> str:
    blocked = bool(result["blocked"])
    context = result["context"]
    violations = result["violations"]
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append(f"status: {'blocked' if blocked else 'ready'}")
    lines.append(
        "enforcement: "
        + ("stop_before_promotion_or_non_orchestration_closeout" if blocked else "allow_promotion_or_non_orchestration_closeout")
    )
    lines.append(f"rule_id: {RULE_ID}")
    lines.append("violation:")
    if not violations:
        lines.append("  - none")
    else:
        for violation in violations:
            lines.append(f"  - [{violation['code']}] {violation['section']}: {violation['message']}")
    lines.append("resolution_prompt:")
    if not violations:
        lines.append("  - The accepted reconcile state is proven on the canonical return branch and promotion may resume from that branch.")
        lines.append("  - Continue with the promotion lane only from the recorded canonical source branch, and rerun this guard if replay evidence, branch heads, or post-replay CI-equivalent status changes.")
    else:
        seen: set[str] = set()
        for violation in violations:
            resolution = violation["resolution"]
            if resolution in seen:
                continue
            seen.add(resolution)
            lines.append(f"  - {resolution}")
    lines.append("context:")
    for key in (
        "plan_path",
        "repo_path",
        "replay_status",
        "replay_mode",
        "authoritative_return_branch",
        "promotion_source_branch",
        "post_replay_ci_status",
    ):
        lines.append(f"  {key}: {context.get(key)}")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines) + "\n"


def render_json(result: dict[str, Any]) -> str:
    payload = {
        "schema_version": "orchestration-reconcile-replay-guard-v1",
        "rule_id": RULE_ID,
        "status": "blocked" if result["blocked"] else "ready",
        "overall_outcome": "no-go" if result["blocked"] else "go",
        **result,
    }
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate that accepted reconcile state was replayed back onto the canonical branch before promotion resumes."
    )
    parser.add_argument("--plan", required=True, help="Path to the orchestration execution plan markdown file.")
    parser.add_argument(
        "--repo",
        default=".",
        help="Authoritative source checkout that will feed promotion after replay. Defaults to the current directory.",
    )
    parser.add_argument(
        "--allow-waivers",
        action="store_true",
        help="Allow approved waiver states where the replay/CI policy explicitly authorized one.",
    )
    parser.add_argument("--json-output", help="Optional path to write a JSON result artifact.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    plan_path = Path(args.plan).resolve()
    repo_path = Path(args.repo).resolve()
    result = validate_replay(plan_path, repo_path, allow_waivers=args.allow_waivers)
    text = render_text(result)
    print(text, end="")
    if args.json_output:
        Path(args.json_output).write_text(render_json(result), encoding="utf-8")
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
