#!/usr/bin/env python3
"""Deterministic closeout guard for tactical TODOs.

The guard catches the process gap where a TODO already has delivery evidence
but remains in `foundation_documentation/todos/active/` with no explicit
closeout disposition. It does not move files automatically. It emits a TEACH
runtime-style response and exits with:

  0  GO: no closeout-disposition blocker was found.
  2  NO-GO: closeout blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from orchestration_plan_completion_guard import (
    build_violation,
    extract_field,
    is_placeholder,
    strip_markup,
)


RULE_ID = "paced.todo.closeout-disposition"
DELIVERY_STAGE_MARKERS = (
    "Local-Implemented",
    "Local-Validated",
    "Local-Complete",
    "Lane-Promoted",
    "Production-Ready",
    "Completed",
    "Complete",
)
ACTIVE_PARTS = ("foundation_documentation", "todos", "active")
PROMOTION_PARTS = ("foundation_documentation", "todos", "promotion_lane")
COMPLETED_PARTS = ("foundation_documentation", "todos", "completed")
DISPOSITION_SECTION = "TODO Closeout Disposition"
VALID_DISPOSITIONS = {
    "keep-active",
    "move-promotion-lane",
    "move-completed",
    "blocked",
}
POST_COMMIT_COMPLETE = {
    "complete",
    "completed",
    "done",
    "pushed",
    "synced",
    "clean",
}
POST_COMMIT_PENDING = {
    "pending",
    "not-yet",
    "not yet",
    "not_applicable",
    "not applicable",
    "n/a",
    "na",
}
STALE_NEXT_STEP_RE = re.compile(
    r"\b("
    r"present the next|presentar o proximo|apresentar o proximo|"
    r"tell the user|diga ao usuario|"
    r"commit and push|fazer commit|faca commit|"
    r"already satisfied|ja satisfeito"
    r")\b",
    re.IGNORECASE,
)
ACTIONABLE_KEEP_ACTIVE_RE = re.compile(
    r"\b("
    r"promotion|promote|stage|main|blocked|blocker|await|waiting|"
    r"approval|approve|validat|canonical|follow-through|lane|"
    r"promocao|bloque|aguard|validar|validacao"
    r")\b",
    re.IGNORECASE,
)
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")


def normalize(value: str | None) -> str:
    if value is None:
        return ""
    value = strip_markup(value)
    value = re.sub(r"`([^`]+)`", r"\1", value)
    value = re.sub(r"[*_#>|]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip().lower()


def canonical_disposition(value: str | None) -> str:
    normalized = normalize(value).replace("_", "-").replace(" ", "-")
    if normalized == "promotion-lane":
        return "move-promotion-lane"
    if normalized == "completed":
        return "move-completed"
    return normalized


def is_missing(value: str | None, *, allow_na: bool = False) -> bool:
    if value is None:
        return True
    stripped = strip_markup(value)
    lowered = normalize(stripped)
    if allow_na and lowered in {"n/a", "na", "none", "not applicable", "not-applicable"}:
        return False
    return is_placeholder(stripped) or lowered in {
        "n/a",
        "na",
        "none",
        "not applicable",
        "not-applicable",
        "unknown",
        "pending",
    }


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
        normalized = normalize(title)
        if normalized == wanted or normalized.startswith(wanted):
            return lines
    return []


def first_field(lines: list[str], labels: tuple[str, ...]) -> str | None:
    for label in labels:
        value = extract_field(lines, label)
        if value is not None:
            return value
    return None


def path_state(path: Path) -> str:
    parts = path.as_posix().split("/")
    if contains_parts(parts, ACTIVE_PARTS):
        return "active"
    if contains_parts(parts, PROMOTION_PARTS):
        return "promotion_lane"
    if contains_parts(parts, COMPLETED_PARTS):
        return "completed"
    return "other"


def contains_parts(parts: list[str], sequence: tuple[str, ...]) -> bool:
    size = len(sequence)
    return any(tuple(parts[index : index + size]) == sequence for index in range(len(parts) - size + 1))


def is_delivery_stage(stage: str | None) -> bool:
    return any(marker in (stage or "") for marker in DELIVERY_STAGE_MARKERS)


def git_context(repo: Path | None) -> dict[str, Any]:
    context: dict[str, Any] = {
        "available": False,
        "clean": None,
        "upstream": None,
        "ahead": None,
        "behind": None,
        "synced": None,
    }
    if repo is None:
        return context
    try:
        root = subprocess.run(
            ["git", "-C", str(repo), "rev-parse", "--show-toplevel"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        ).stdout.strip()
        status = subprocess.run(
            ["git", "-C", root, "status", "--porcelain"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        ).stdout
        upstream = subprocess.run(
            ["git", "-C", root, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        ).stdout.strip()
        context.update({"available": True, "root": root, "clean": status.strip() == "", "upstream": upstream or None})
        if upstream:
            counts = subprocess.run(
                ["git", "-C", root, "rev-list", "--left-right", "--count", f"HEAD...{upstream}"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
            ).stdout.strip()
            ahead_text, behind_text = counts.split()
            ahead = int(ahead_text)
            behind = int(behind_text)
            context.update({"ahead": ahead, "behind": behind, "synced": context["clean"] and ahead == 0 and behind == 0})
    except (OSError, subprocess.CalledProcessError, ValueError):
        return context
    return context


def post_commit_is_complete(value: str | None, git: dict[str, Any]) -> bool:
    if git.get("synced"):
        return True
    normalized = normalize(value).replace("_", "-")
    if normalized in POST_COMMIT_COMPLETE:
        return True
    if normalized in POST_COMMIT_PENDING:
        return False
    return bool(git.get("synced"))


def next_step_is_stale(next_step: str | None) -> bool:
    if is_missing(next_step):
        return False
    return bool(STALE_NEXT_STEP_RE.search(next_step or ""))


def next_step_is_actionable(next_step: str | None) -> bool:
    if is_missing(next_step):
        return False
    if next_step_is_stale(next_step):
        return False
    return bool(ACTIONABLE_KEEP_ACTIVE_RE.search(next_step or ""))


def load_todo(todo_path: Path) -> dict[str, Any]:
    text = todo_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    sections = extract_sections(lines)
    status_lines = find_section(sections, "Delivery Status Canon")
    closeout_lines = find_section(sections, DISPOSITION_SECTION)
    stage = first_field(status_lines, ("Current delivery stage",))
    qualifiers = first_field(status_lines, ("Qualifiers",))
    next_step = first_field(status_lines, ("Next exact step",))
    disposition = canonical_disposition(first_field(closeout_lines, ("Disposition", "Closeout disposition")))
    reason = first_field(closeout_lines, ("Disposition reason", "Reason"))
    post_commit_status = first_field(closeout_lines, ("Post-commit/push status", "Post commit/push status"))
    next_path_action = first_field(closeout_lines, ("Next path/status action", "Path/status action"))
    return {
        "path": todo_path,
        "sections": sections,
        "path_state": path_state(todo_path.resolve()),
        "stage": stage,
        "qualifiers": qualifiers,
        "next_step": next_step,
        "closeout_section_present": bool(closeout_lines),
        "disposition": disposition,
        "disposition_reason": reason,
        "post_commit_status": post_commit_status,
        "next_path_action": next_path_action,
        "delivery_claim": is_delivery_stage(stage),
    }


def validate_todo(todo: dict[str, Any], git: dict[str, Any]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    violations: list[dict[str, str]] = []
    context = {
        "todo_path": str(todo["path"]),
        "path_state": todo["path_state"],
        "current_delivery_stage": todo["stage"],
        "qualifiers": todo["qualifiers"],
        "next_exact_step": todo["next_step"],
        "delivery_claim": todo["delivery_claim"],
        "closeout_section_present": todo["closeout_section_present"],
        "disposition": todo["disposition"] or None,
        "post_commit_push_status": todo["post_commit_status"],
    }

    if todo["path_state"] != "active" or not todo["delivery_claim"]:
        return violations, context

    qualifiers = normalize(todo["qualifiers"])
    if "blocked" in qualifiers and not is_missing(todo["next_step"]):
        return violations, context

    if not todo["closeout_section_present"]:
        violations.append(
            build_violation(
                "CLOSEOUT-DISPOSITION-MISSING",
                "Delivered TODO remains in active/ without a TODO Closeout Disposition section.",
                "Add `## TODO Closeout Disposition` with disposition keep-active, move-promotion-lane, move-completed, or blocked.",
                DISPOSITION_SECTION,
            )
        )
        return violations, context

    disposition = todo["disposition"]
    if disposition not in VALID_DISPOSITIONS:
        violations.append(
            build_violation(
                "CLOSEOUT-DISPOSITION-INVALID",
                f"Closeout disposition is missing or invalid: {disposition or 'missing'}.",
                "Use one of: keep-active, move-promotion-lane, move-completed, blocked.",
                DISPOSITION_SECTION,
            )
        )
        return violations, context

    if is_missing(todo["disposition_reason"]):
        violations.append(
            build_violation(
                "CLOSEOUT-DISPOSITION-REASON-MISSING",
                "Closeout disposition reason is missing or placeholder.",
                "Record why the TODO is being kept active, moved, or blocked.",
                DISPOSITION_SECTION,
            )
        )

    stale_next_step_allowed_pre_push = disposition in {"move-completed", "move-promotion-lane"} and not post_commit_is_complete(
        todo["post_commit_status"], git
    )
    if next_step_is_stale(todo["next_step"]) and not stale_next_step_allowed_pre_push:
        violations.append(
            build_violation(
                "CLOSEOUT-NEXT-STEP-STALE",
                f"Next exact step looks already satisfied or non-actionable: {todo['next_step']}",
                "Replace it with an actionable remaining step, or move the TODO to promotion_lane/ or completed/.",
                "Delivery Status Canon",
            )
        )

    if disposition == "keep-active":
        if not next_step_is_actionable(todo["next_step"]):
            violations.append(
                build_violation(
                    "CLOSEOUT-KEEP-ACTIVE-NON-ACTIONABLE",
                    "Disposition is keep-active but Next exact step is missing, stale, or not actionable.",
                    "Keep the TODO active only with a real remaining blocker, promotion action, validation step, or approval wait.",
                    DISPOSITION_SECTION,
                )
            )
    elif disposition == "blocked":
        if "blocked" not in qualifiers:
            violations.append(
                build_violation(
                    "CLOSEOUT-BLOCKED-QUALIFIER-MISSING",
                    "Disposition is blocked but Delivery Status Canon qualifiers do not include Blocked.",
                    "Set `Qualifiers` to include `Blocked` and record blocker notes plus an actionable next step.",
                    "Delivery Status Canon",
                )
            )
    elif disposition in {"move-completed", "move-promotion-lane"}:
        if is_missing(todo["next_path_action"]):
            violations.append(
                build_violation(
                    "CLOSEOUT-PATH-ACTION-MISSING",
                    "Move disposition is set but Next path/status action is missing or placeholder.",
                    "Record the exact file move or status action that must happen after validation and commit/push.",
                    DISPOSITION_SECTION,
                )
            )
        if post_commit_is_complete(todo["post_commit_status"], git):
            target = "completed/" if disposition == "move-completed" else "promotion_lane/"
            violations.append(
                build_violation(
                    "CLOSEOUT-MOVE-PENDING-AFTER-PUSH",
                    f"TODO disposition is {disposition}, commit/push is complete or git is synced, but the TODO is still in active/.",
                    f"Move the TODO to {target} or change the disposition with a real remaining active reason.",
                    DISPOSITION_SECTION,
                )
            )

    return violations, context


def discover_active_todos(repo: Path) -> list[Path]:
    root = repo.resolve()
    active_root = root / "foundation_documentation" / "todos" / "active"
    if not active_root.is_dir():
        return []
    return sorted(path for path in active_root.rglob("*.md") if path.is_file())


def result_for(todo_paths: list[Path], repo: Path | None) -> dict[str, Any]:
    git = git_context(repo)
    todo_results = []
    all_violations: list[dict[str, str]] = []
    for todo_path in todo_paths:
        todo = load_todo(todo_path)
        violations, context = validate_todo(todo, git)
        all_violations.extend({**violation, "todo_path": str(todo_path)} for violation in violations)
        todo_results.append({"context": context, "violations": violations})
    return {
        "rule_id": RULE_ID,
        "generated_at_utc": datetime.now(UTC).isoformat().replace("+00:00", "Z"),
        "todo_count": len(todo_paths),
        "git": git,
        "todo_results": todo_results,
        "violations": all_violations,
        "overall_outcome": "go" if not all_violations else "no-go",
    }


def print_result(result: dict[str, Any]) -> None:
    print("TODO Closeout Guard")
    print(f"Rule: {RULE_ID}")
    print(f"Overall outcome: {result['overall_outcome']}")
    print("")
    print("Context:")
    print(f"  - todo_count: {result['todo_count']}")
    git = result["git"]
    print(f"  - git_available: {git.get('available')}")
    print(f"  - git_clean: {git.get('clean')}")
    print(f"  - git_upstream: {git.get('upstream')}")
    print(f"  - git_ahead: {git.get('ahead')}")
    print(f"  - git_behind: {git.get('behind')}")
    print(f"  - git_synced: {git.get('synced')}")
    for item in result["todo_results"]:
        context = item["context"]
        print(f"  - todo: {context['todo_path']}")
        print(f"    path_state: {context['path_state']}")
        print(f"    current_delivery_stage: {context['current_delivery_stage']}")
        print(f"    disposition: {context['disposition']}")
        print(f"    violations: {len(item['violations'])}")
    print("")
    print("Violations:")
    if not result["violations"]:
        print("  - none")
        return
    for violation in result["violations"]:
        print(f"  - [{violation['code']}] {violation['message']}")
        print(f"    todo_path: {violation['todo_path']}")
        print(f"    section: {violation['section']}")
        print(f"    resolution: {violation['resolution']}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate tactical TODO closeout disposition.")
    parser.add_argument("todo", nargs="?", help="TODO markdown path to validate.")
    parser.add_argument("--repo", default=".", help="Repository root for git context and --all-active discovery.")
    parser.add_argument("--all-active", action="store_true", help="Scan foundation_documentation/todos/active/**/*.md.")
    parser.add_argument("--json-output", help="Write machine-readable guard result to this path.")
    parser.add_argument("--advisory", action="store_true", help="Always exit 0 after printing findings.")
    args = parser.parse_args(argv)
    if bool(args.todo) == bool(args.all_active):
        parser.error("Pass either a TODO path or --all-active.")
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    repo = Path(args.repo)
    if args.all_active:
        todo_paths = discover_active_todos(repo)
    else:
        todo_paths = [Path(args.todo)]
    result = result_for(todo_paths, repo)
    print_result(result)
    if args.json_output:
        Path(args.json_output).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    if args.advisory:
        return 0
    return 0 if result["overall_outcome"] == "go" else 2


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        raise SystemExit(130)
