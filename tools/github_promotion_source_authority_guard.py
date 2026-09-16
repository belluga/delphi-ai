#!/usr/bin/env python3
"""Deterministically validate promotion source authority against a governing TODO."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


RULE_ID = "paced.github-promotion.source-authority"
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
TOP_LEVEL_BULLET_RE = re.compile(r"^- (.+?):\s*(.*)$")
INDENTED_BULLET_RE = re.compile(r"^\s+-\s+(.*)$")
DELIVERY_STAGE_PREFIX = "- **Current delivery stage:**"
PROMOTABLE_CHILD_STAGES = {
    "Local-Implemented",
    "Local-Validated",
    "Local-Complete",
    "Lane-Promoted",
    "Production-Ready",
    "Completed",
    "Complete",
}
REPO_KEY_ALIASES = {
    "root": "root",
    "belluga_now_docker": "root",
    "flutter-app": "flutter-app",
    "laravel-app": "laravel-app",
    "web-app": "web-app",
    "foundation_documentation": "foundation_documentation",
}
BRANCH_AUTHORITY_LABELS = {
    "root": "Root canonical branch",
    "flutter-app": "flutter-app canonical branch",
    "laravel-app": "laravel-app canonical branch",
    "web-app": "web-app generated bundle branch",
    "foundation_documentation": "foundation_documentation authority branch",
}
BASELINES_PARENT_LABEL = "Canonical post-replay source baselines currently under promotion consideration"
CHILD_OWNER_SECTION = "Current Diff Child Owners"
BRANCH_AUTHORITY_SECTION = "Current Branch Authority"
DELIVERY_STATUS_SECTION = "Delivery Status Canon"


def clean_value(raw: str) -> str:
    value = raw.strip()
    while len(value) >= 2 and value[0] == value[-1] and value[0] in {"`", '"', "'"}:
        value = value[1:-1].strip()
    return value


def normalize(text: str) -> str:
    text = text.replace("`", " ")
    text = text.replace("*", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip().lower()


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def extract_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines:
        match = HEADING_RE.match(line)
        if match:
            current = match.group(2).strip()
            sections.setdefault(current, [])
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def find_section(sections: dict[str, list[str]], section_name: str) -> list[str]:
    wanted = normalize(section_name)
    for title, lines in sections.items():
        title_normalized = normalize(title)
        if title_normalized == wanted or title_normalized.startswith(wanted):
            return lines
    return []


def extract_delivery_stage(lines: list[str]) -> str | None:
    for line in lines:
        stripped = line.strip()
        if stripped.startswith(DELIVERY_STAGE_PREFIX):
            return clean_value(stripped[len(DELIVERY_STAGE_PREFIX) :])
    return None


def extract_top_level_bullet_field(lines: list[str], label: str) -> str | None:
    wanted = normalize(label)
    for line in lines:
        stripped = line.strip()
        match = TOP_LEVEL_BULLET_RE.match(stripped)
        if not match:
            continue
        if normalize(match.group(1)) == wanted:
            return clean_value(match.group(2))
    return None


def parse_baselines(lines: list[str]) -> tuple[dict[str, tuple[str, str]], list[str]]:
    baselines: dict[str, tuple[str, str]] = {}
    issues: list[str] = []
    start = None

    for index, line in enumerate(lines):
        stripped = line.strip()
        match = TOP_LEVEL_BULLET_RE.match(stripped)
        if not match:
            continue
        if normalize(match.group(1)) == normalize(BASELINES_PARENT_LABEL):
            start = index + 1
            break

    if start is None:
        issues.append(
            f"The governing TODO does not declare `{BASELINES_PARENT_LABEL}` in `{BRANCH_AUTHORITY_SECTION}`."
        )
        return baselines, issues

    for line in lines[start:]:
        if not line.strip():
            continue
        if line.startswith("- "):
            break
        match = INDENTED_BULLET_RE.match(line)
        if not match:
            continue
        entry = match.group(1).strip()
        entry_match = re.match(r"(.+?)\s+`([^`]+)`\s*$", entry)
        if not entry_match:
            issues.append(f"Unable to parse baseline entry: `{entry}`.")
            continue
        raw_key = clean_value(entry_match.group(1))
        baseline_value = clean_value(entry_match.group(2))
        if "@" not in baseline_value:
            issues.append(
                f"Baseline entry for `{raw_key}` must use the form `branch@sha`, but found `{baseline_value}`."
            )
            continue
        branch_name, sha = baseline_value.rsplit("@", 1)
        baselines[normalize(raw_key)] = (clean_value(branch_name), clean_value(sha))

    return baselines, issues


def parse_child_owner_paths(lines: list[str]) -> list[str]:
    owners: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped.startswith("- "):
            continue
        value = clean_value(stripped[2:])
        if value.endswith(".md"):
            owners.append(value)
    return owners


def normalize_repo_key(raw_key: str) -> str:
    canonical = REPO_KEY_ALIASES.get(raw_key)
    if canonical is None:
        raise KeyError(raw_key)
    return canonical


def normalize_ref_name(ref_name: str) -> str:
    normalized = ref_name.strip()
    for prefix in ("refs/heads/", "refs/remotes/origin/", "origin/"):
        if normalized.startswith(prefix):
            normalized = normalized[len(prefix) :]
    return normalized


def git(repo_root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo_root), *args],
        check=True,
        text=True,
        capture_output=True,
    )
    return result.stdout.strip()


def resolve_repo_root(repo_input: str) -> Path:
    output = subprocess.run(
        ["git", "-C", repo_input, "rev-parse", "--show-toplevel"],
        check=True,
        text=True,
        capture_output=True,
    )
    return Path(output.stdout.strip())


def resolve_foundation_root(todo_path: Path) -> Path | None:
    current = todo_path.resolve()
    for parent in (current.parent, *current.parents):
        if parent.name == "foundation_documentation":
            return parent
    return None


def render_response(
    *,
    repo_root: Path,
    source_ref: str,
    source_sha: str,
    actual_branch: str,
    repo_key: str,
    governing_todo: Path,
    package_stage: str,
    expected_branch: str | None,
    expected_sha: str | None,
    child_statuses: list[str],
    violations: list[str],
    resolutions: list[str],
) -> str:
    blocked = bool(violations)
    lines = [
        "GitHub Promotion Source Authority Guard",
        f"Repository root: {repo_root}",
        f"Governing TODO: {governing_todo}",
        f"Repository key: {repo_key}",
        f"Source ref: {source_ref}",
        f"Resolved source branch: {actual_branch or 'DETACHED'}",
        f"Resolved source sha: {source_sha}",
        "",
        "Authority summary",
        f"  - package delivery stage: {package_stage or 'missing'}",
        f"  - expected source branch: {expected_branch or 'missing'}",
        f"  - expected source sha: {expected_sha or 'missing'}",
        f"  - child owners checked: {len(child_statuses)}",
        "",
        "TEACH runtime response",
        f"status: {'blocked' if blocked else 'ready'}",
        f"enforcement: {'stop_before_source_preflight' if blocked else 'allow_source_preflight'}",
        f"rule_id: {RULE_ID}",
        "violation:",
    ]

    if violations:
        for violation in violations:
            lines.append(f"  - {violation}")
    else:
        lines.append("  - none")

    lines.append("resolution_prompt:")
    if resolutions:
        for resolution in resolutions:
            lines.append(f"  - {resolution}")
    else:
        lines.append("  - none")

    lines.extend(
        [
            "context:",
            f"  governing_todo: {governing_todo}",
            f"  repo_key: {repo_key}",
            f"  package_delivery_stage: {package_stage or 'missing'}",
            f"  expected_source_branch: {expected_branch or 'missing'}",
            f"  expected_source_sha: {expected_sha or 'missing'}",
            f"  actual_source_branch: {actual_branch or 'DETACHED'}",
            f"  actual_source_sha: {source_sha}",
            "  child_owner_statuses:",
        ]
    )

    if child_statuses:
        for status in child_statuses:
            lines.append(f"    - {status}")
    else:
        lines.append("    - none")

    lines.append("")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate that the promotion source ref matches the authoritative branch "
            "and exact validated SHA recorded in the governing package TODO."
        )
    )
    parser.add_argument("--repo", default=".", help="Repository to inspect. Defaults to current directory.")
    parser.add_argument("--source-ref", required=True, help="Source ref/branch intended for promotion.")
    parser.add_argument(
        "--governing-todo",
        required=True,
        help="Path to the governing package/release TODO with Current Branch Authority.",
    )
    parser.add_argument(
        "--repo-key",
        required=True,
        choices=sorted(REPO_KEY_ALIASES),
        help="Authority key for the repo under promotion: root, flutter-app, laravel-app, web-app, or foundation_documentation.",
    )
    args = parser.parse_args()

    governing_todo = Path(args.governing_todo).resolve()
    if not governing_todo.is_file():
        print(f"Error: governing TODO not found: {governing_todo}", file=sys.stderr)
        return 1

    try:
        repo_key = normalize_repo_key(args.repo_key)
    except KeyError:
        print(f"Error: unsupported repo key: {args.repo_key}", file=sys.stderr)
        return 1

    try:
        repo_root = resolve_repo_root(args.repo)
        source_sha = git(repo_root, "rev-parse", "--verify", f"{args.source_ref}^{{commit}}")
        source_branch = normalize_ref_name(git(repo_root, "rev-parse", "--abbrev-ref", args.source_ref))
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip() if exc.stderr else str(exc)
        print(f"Error: {stderr}", file=sys.stderr)
        return 1

    package_lines = read_lines(governing_todo)
    package_sections = extract_sections(package_lines)
    delivery_lines = find_section(package_sections, DELIVERY_STATUS_SECTION)
    authority_lines = find_section(package_sections, BRANCH_AUTHORITY_SECTION)
    child_owner_lines = find_section(package_sections, CHILD_OWNER_SECTION)

    package_stage = extract_delivery_stage(delivery_lines) or extract_delivery_stage(package_lines) or ""
    expected_branch: str | None = None
    expected_sha: str | None = None
    child_statuses: list[str] = []
    violations: list[str] = []
    resolutions: list[str] = []

    if not package_stage:
        violations.append(
            "The governing TODO does not declare `Current delivery stage`, so promotion authority is not measurable."
        )
        resolutions.append(
            "Add the package `Current delivery stage` and keep it at least `Local-Implemented` before promotion preflight."
        )
    elif package_stage not in PROMOTABLE_CHILD_STAGES:
        violations.append(
            f"The governing TODO delivery stage `{package_stage}` is below the minimum promotable threshold."
        )
        resolutions.append(
            "Complete the package until its delivery stage is `Local-Implemented` or beyond before starting promotion."
        )

    if not authority_lines:
        violations.append(
            f"The governing TODO does not contain a `{BRANCH_AUTHORITY_SECTION}` section."
        )
        resolutions.append(
            "Record the canonical branch and exact validated baseline SHA in `Current Branch Authority` before promotion."
        )
    else:
        branch_label = BRANCH_AUTHORITY_LABELS[repo_key]
        expected_branch = extract_top_level_bullet_field(authority_lines, branch_label)
        if not expected_branch:
            violations.append(
                f"`{BRANCH_AUTHORITY_SECTION}` does not declare `{branch_label}` for repo key `{repo_key}`."
            )
            resolutions.append(
                f"Add `{branch_label}: <branch>` to the governing TODO before promotion."
            )

        baselines, baseline_issues = parse_baselines(authority_lines)
        violations.extend(baseline_issues)
        if baseline_issues:
            resolutions.append(
                f"Repair the `{BASELINES_PARENT_LABEL}` entries so each repo records `branch@sha` deterministically."
            )

        baseline_key = normalize(repo_key)
        if baseline_key in baselines:
            baseline_branch, baseline_sha = baselines[baseline_key]
            expected_sha = baseline_sha
            if expected_branch and normalize_ref_name(baseline_branch) != normalize_ref_name(expected_branch):
                violations.append(
                    f"The governing TODO records branch authority `{expected_branch}` but the baseline entry uses `{baseline_branch}` for repo `{repo_key}`."
                )
                resolutions.append(
                    "Keep the branch-authority bullet and the baseline `branch@sha` entry synchronized before promotion."
                )
        else:
            violations.append(
                f"`{BASELINES_PARENT_LABEL}` does not include an entry for repo `{repo_key}`."
            )
            resolutions.append(
                f"Add a `{repo_key}` baseline entry using `branch@sha` to the governing TODO before promotion."
            )

    if expected_branch and normalize_ref_name(source_branch) != normalize_ref_name(expected_branch):
        violations.append(
            f"Source ref `{args.source_ref}` resolves to branch `{source_branch}`, but the governing TODO records `{expected_branch}` as the authoritative promotion branch for repo `{repo_key}`."
        )
        resolutions.append(
            f"Promote from `{expected_branch}` or update the governing TODO after rerunning package proof on the real latest source branch."
        )

    if expected_sha and source_sha != expected_sha:
        violations.append(
            f"Source ref `{args.source_ref}` resolves to `{source_sha}`, which does not match the authoritative baseline SHA `{expected_sha}` recorded for repo `{repo_key}`."
        )
        resolutions.append(
            "If the branch advanced, rerun the authoritative CI-equivalent/package proof on that exact branch and refresh the governing TODO baseline SHA before promotion."
        )

    child_owner_paths = parse_child_owner_paths(child_owner_lines)
    if not child_owner_paths:
        violations.append(
            f"The governing TODO does not list any child owners in `{CHILD_OWNER_SECTION}`."
        )
        resolutions.append(
            f"List the exact child TODO owners that compose this promotion package under `{CHILD_OWNER_SECTION}`."
        )
    else:
        foundation_root = resolve_foundation_root(governing_todo)
        if foundation_root is None:
            violations.append(
                "Could not resolve the `foundation_documentation` root from the governing TODO path."
            )
            resolutions.append(
                "Pass a governing TODO that lives under the canonical `foundation_documentation` tree."
            )
        else:
            for relative_path in child_owner_paths:
                child_path = (foundation_root / relative_path).resolve()
                if not child_path.is_file():
                    child_statuses.append(f"{relative_path} => missing")
                    violations.append(f"Child owner `{relative_path}` is missing from `foundation_documentation`.")
                    continue

                child_lines = read_lines(child_path)
                child_stage = extract_delivery_stage(child_lines)
                child_statuses.append(f"{relative_path} => {child_stage or 'missing'}")

                if not child_stage:
                    violations.append(
                        f"Child owner `{relative_path}` does not declare `Current delivery stage`."
                    )
                    continue
                if child_stage not in PROMOTABLE_CHILD_STAGES:
                    violations.append(
                        f"Child owner `{relative_path}` is still at delivery stage `{child_stage}`, below the minimum promotable threshold."
                    )

            if any(
                "Child owner" in violation and "minimum promotable threshold" in violation
                for violation in violations
            ):
                resolutions.append(
                    "Finish or remove child TODOs that are still below `Local-Implemented` before promoting this package."
                )
            if any(
                "Child owner" in violation and "missing from `foundation_documentation`" in violation
                for violation in violations
            ):
                resolutions.append(
                    "Repair the package owner list so every listed child TODO exists in `foundation_documentation`."
                )

    if not violations:
        resolutions.append(
            "Authority matches the governing package TODO. Continue with stage-promotion source preflight next."
        )
    else:
        resolutions.append(
            "Rerun github_promotion_source_authority_guard.py and require `Overall outcome: go` before opening the first promotion PR."
        )

    print(
        render_response(
            repo_root=repo_root,
            source_ref=args.source_ref,
            source_sha=source_sha,
            actual_branch=source_branch,
            repo_key=repo_key,
            governing_todo=governing_todo,
            package_stage=package_stage,
            expected_branch=expected_branch,
            expected_sha=expected_sha,
            child_statuses=child_statuses,
            violations=violations,
            resolutions=resolutions,
        )
    )
    return 2 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
