#!/usr/bin/env python3
import argparse
import fnmatch
import json
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RULES_FILE = REPO_ROOT / "profiles" / "profile_scope_rules.json"


def load_rules():
    data = json.loads(RULES_FILE.read_text())
    return data["profiles"]


def git_paths(staged: bool, base: str | None, head: str | None) -> list[str]:
    if base and head:
        cmd = ["git", "diff", "--name-only", f"{base}..{head}"]
    elif staged:
        cmd = ["git", "diff", "--name-only", "--cached"]
    else:
        cmd = ["git", "diff", "--name-only", "HEAD"]
    proc = subprocess.run(cmd, cwd=REPO_ROOT, check=True, capture_output=True, text=True)
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def matches(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, pattern) for pattern in patterns)


def classify(paths: list[str], rule: dict) -> dict[str, list[str]]:
    result = {"allowed": [], "review_required": [], "forbidden": [], "unknown": []}
    for path in paths:
        if matches(path, rule.get("forbidden", [])):
            result["forbidden"].append(path)
        elif matches(path, rule.get("review_required", [])):
            result["review_required"].append(path)
        elif matches(path, rule.get("allowed", [])):
            result["allowed"].append(path)
        else:
            result["unknown"].append(path)
    return result


def print_section(title: str, items: list[str]) -> None:
    if not items:
        return
    print(f"{title}:")
    for item in items:
        print(f"- {item}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate changed paths against Delphi profile scope rules."
    )
    parser.add_argument("--profile", required=True, help="Profile id from profiles/profile_scope_rules.json")
    parser.add_argument("--staged", action="store_true", help="Inspect staged changes instead of git diff HEAD")
    parser.add_argument("--base", help="Base ref for git diff")
    parser.add_argument("--head", help="Head ref for git diff")
    parser.add_argument("paths", nargs="*", help="Explicit paths to classify instead of reading git diff")
    args = parser.parse_args()

    rules = load_rules()
    if args.profile not in rules:
        print(f"Unknown profile: {args.profile}", file=sys.stderr)
        print("Available profiles:", file=sys.stderr)
        for profile_id in sorted(rules):
            print(f"- {profile_id}", file=sys.stderr)
        return 1

    if (args.base and not args.head) or (args.head and not args.base):
        print("--base and --head must be provided together", file=sys.stderr)
        return 1

    paths = args.paths or git_paths(args.staged, args.base, args.head)
    if not paths:
        print(f"Profile: {args.profile}")
        print("Result: no changed paths detected")
        print(
            "Note: this tool validates touched surfaces only. It does not infer authorship or handoff."
        )
        return 0

    rule = rules[args.profile]
    classified = classify(paths, rule)

    print(f"Profile: {args.profile}")
    print(f"Description: {rule.get('description', '')}")
    print(f"Changed paths: {len(paths)}")
    print_section("Allowed", classified["allowed"])
    print_section("Review required", classified["review_required"])
    print_section("Forbidden", classified["forbidden"])
    print_section("Unknown", classified["unknown"])
    print(
        "Reminder: this tool validates surfaces only. It does not infer whether mixed changes came from a valid handoff."
    )
    print(
        "Compare any non-allowed paths with the TODO `Profile Scope & Handoffs` section before treating them as violations."
    )

    if classified["forbidden"] or classified["review_required"] or classified["unknown"]:
        print("Result: review required")
        return 2

    print("Result: in scope")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
