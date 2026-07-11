#!/usr/bin/env python3
"""Deterministically validate whether a direct git commit/push is allowed.

This guard is intentionally narrow: it validates whether the current repo/branch
shape is a permitted direct-write surface for the requested action. It does not
replace lane-specific guards, approval gates, or validation requirements.

Exit codes:
- 0: allowed (`Overall outcome: go`)
- 2: blocked by deterministic policy (`Overall outcome: no-go`)
- 1: usage/runtime error
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


RULE_ID = "paced.git-write-authority"
DEFAULT_PROTECTED_BRANCHES = ("dev", "stage", "main")


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


def detect_branch(repo_root: Path) -> str:
    return git(repo_root, "rev-parse", "--abbrev-ref", "HEAD")


def infer_surface(repo_root: Path, requested: str) -> str:
    if requested != "auto":
        return requested
    name = repo_root.name
    if name == "foundation_documentation":
        return "foundation_documentation"
    if name == "delphi-ai":
        return "delphi_self"
    return "project_code"


def render_response(
    *,
    repo_root: Path,
    action: str,
    branch: str,
    surface: str,
    protected_branches: list[str],
    classification: str,
    allowed: bool,
    violations: list[str],
    resolutions: list[str],
) -> str:
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append("status: ready")
    lines.append("enforcement: git_write_authority")
    lines.append(f"rule_id: {RULE_ID}")
    lines.append("violation:")
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
    lines.append("context:")
    lines.append(f"  repo_root: {repo_root}")
    lines.append(f"  repo_name: {repo_root.name}")
    lines.append(f"  action: {action}")
    lines.append(f"  branch: {branch}")
    lines.append(f"  authority_surface: {surface}")
    lines.append(f"  classification: {classification}")
    lines.append(f"  protected_branches: {','.join(protected_branches)}")
    lines.append(f"  direct_write_allowed: {'yes' if allowed else 'no'}")
    lines.append("")
    lines.append(f"Overall outcome: {'go' if allowed else 'no-go'}")
    return "\n".join(lines)


def evaluate(
    *,
    repo_root: Path,
    action: str,
    branch: str,
    surface: str,
    protected_branches: list[str],
) -> tuple[bool, str, list[str], list[str]]:
    violations: list[str] = []
    resolutions: list[str] = []

    if branch == "HEAD":
        violations.append(
            f"The repo is in detached HEAD state, so `{action}` cannot be classified as a governed direct-write scenario."
        )
        resolutions.append(
            "Checkout or create a named branch that matches the intended work lane, then rerun git_write_authority_guard.py."
        )
        return False, "detached_head_blocked", violations, resolutions

    if surface == "foundation_documentation":
        if branch != "main":
            violations.append(
                f"`foundation_documentation` must stay on `main`, but the current branch is `{branch}`."
            )
            resolutions.append(
                "Return the canonical foundation_documentation checkout to `main` before attempting direct commit/push."
            )
            return False, "foundation_branch_mismatch", violations, resolutions
        resolutions.append(
            f"`{action}` is allowed because `foundation_documentation:main` is an authoritative documentation write surface."
        )
        return True, "foundation_main_allowed", violations, resolutions

    if surface == "project_code" and branch in protected_branches:
        violations.append(
            f"Direct `{action}` to protected promotion branch `{branch}` is forbidden."
        )
        resolutions.append(
            f"Move the work onto a non-protected work branch and advance `{branch}` only through the promotion-lane PR flow."
        )
        return False, "protected_promotion_branch_blocked", violations, resolutions

    if surface == "project_code":
        resolutions.append(
            f"`{branch}` is treated as a direct-write work branch for `{action}` because it is not one of the protected promotion branches."
        )
        return True, "project_work_branch_allowed", violations, resolutions

    if surface == "delphi_self":
        resolutions.append(
            f"`{action}` is allowed on Delphi self-maintenance surface `{branch}`; validate the self-improvement/session rules separately."
        )
        return True, "delphi_self_allowed", violations, resolutions

    violations.append(
        f"Unsupported authority surface `{surface}`."
    )
    resolutions.append(
        "Pass --authority-surface auto|foundation_documentation|project_code|delphi_self with a valid repo."
    )
    return False, "unsupported_surface", violations, resolutions


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate whether a direct git commit/push is allowed for the current repo/branch scenario."
    )
    parser.add_argument("--repo", default=".", help="Git repository path (defaults to current directory).")
    parser.add_argument(
        "--action",
        required=True,
        choices=("git-commit", "git-push"),
        help="The direct git write operation being evaluated.",
    )
    parser.add_argument(
        "--branch",
        help="Branch/ref name to evaluate. Defaults to the current checked out branch.",
    )
    parser.add_argument(
        "--authority-surface",
        default="auto",
        choices=("auto", "foundation_documentation", "project_code", "delphi_self"),
        help="Override repo-surface classification. Defaults to auto-detect by repo name.",
    )
    parser.add_argument(
        "--protected-branch",
        action="append",
        dest="protected_branches",
        help="Exact protected promotion branch name. Repeat as needed. Defaults to dev, stage, main.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    repo_root = resolve_repo_root(args.repo)
    branch = args.branch or detect_branch(repo_root)
    protected_branches = args.protected_branches or list(DEFAULT_PROTECTED_BRANCHES)
    surface = infer_surface(repo_root, args.authority_surface)

    allowed, classification, violations, resolutions = evaluate(
        repo_root=repo_root,
        action=args.action,
        branch=branch,
        surface=surface,
        protected_branches=protected_branches,
    )

    print(
        render_response(
            repo_root=repo_root,
            action=args.action,
            branch=branch,
            surface=surface,
            protected_branches=protected_branches,
            classification=classification,
            allowed=allowed,
            violations=violations,
            resolutions=resolutions,
        )
    )
    return 0 if allowed else 2


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except subprocess.CalledProcessError as exc:
        print(f"fatal: {exc}", file=sys.stderr)
        raise SystemExit(1)
