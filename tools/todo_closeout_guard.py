#!/usr/bin/env python3
"""Deterministic closeout guard for tactical TODOs.

The guard validates both nested ``foundation_documentation/todos`` and
standalone ``todos`` authorities. It fails closed for unsupported authorities,
invalid inputs, lifecycle aliases, and containment escapes. It does not move
files automatically. It emits a TEACH runtime-style response and exits with:

  0  GO: no closeout-disposition blocker was found.
  2  NO-GO: closeout blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import UTC, datetime
from dataclasses import dataclass
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
DISPOSITION_SECTION = "TODO Closeout Disposition"
ACTIVE_WORK_STATE_SECTION = "Active Work State"
VALID_DISPOSITIONS = {
    "keep-active",
    "move-promotion-lane",
    "move-completed",
    "blocked",
}
VALID_ACTIVE_WORK_STATES = {"implementation", "review", "blocked"}
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
LIFECYCLES = ("active", "promotion_lane", "completed")


@dataclass(frozen=True)
class TodoAuthority:
    root: Path
    aliases: tuple[Path, ...]


@dataclass(frozen=True)
class TodoSelection:
    load_path: Path
    report_path: Path
    discovered: bool


def contains_path(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def boundary_violation(code: str, message: str, resolution: str, todo_path: str | None) -> dict[str, Any]:
    return {**build_violation(code, message, resolution, "Authority resolution"), "todo_path": todo_path}


def resolve_authority(repo: Path) -> tuple[TodoAuthority | None, list[dict[str, Any]]]:
    lexical_repo = repo.absolute()
    try:
        repo_root = repo.resolve()
    except (OSError, RuntimeError):
        return None, [
            boundary_violation(
                "CLOSEOUT-REPOSITORY-UNRESOLVABLE",
                "Selected repository path cannot be resolved.",
                "Replace the cyclic or inaccessible --repo path with a resolvable repository directory.",
                str(lexical_repo),
            )
        ]
    candidates = (
        lexical_repo / "foundation_documentation" / "todos",
        lexical_repo / "todos",
    )
    canonical_candidates = (
        repo_root / "foundation_documentation" / "todos",
        repo_root / "todos",
    )
    for candidate in candidates:
        if candidate.is_symlink() and not candidate.exists():
            try:
                target = candidate.resolve()
            except RuntimeError:
                target = candidate
            if not contains_path(target, repo_root):
                return None, [
                    boundary_violation(
                        "CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY",
                        "A broken TODO authority-root symlink resolves outside the selected repository.",
                        "Replace the external authority-root symlink with a contained real authority root.",
                        str(candidate),
                    )
                ]
    # A dangling authority-root symlink is still an explicit authority candidate;
    # it is incomplete rather than indistinguishable from a completely missing root.
    existing = [candidate for candidate in candidates if candidate.exists() or candidate.is_symlink()]
    external = [candidate for candidate in candidates if candidate.exists() and not contains_path(candidate.resolve(), repo_root)]
    if external:
        return None, [
            boundary_violation(
                "CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY",
                "A TODO authority root resolves outside the selected repository.",
                "Replace the external authority-root symlink with a contained real authority root.",
                str(external[0]),
            )
        ]
    grouped: dict[Path, list[Path]] = {}
    for candidate in (*candidates, *canonical_candidates):
        active = candidate / "active"
        if active.is_dir():
            aliases = grouped.setdefault(candidate.resolve(), [])
            if candidate not in aliases:
                aliases.append(candidate)
    if not grouped:
        code = "CLOSEOUT-AUTHORITY-INCOMPLETE" if existing else "CLOSEOUT-AUTHORITY-MISSING"
        return None, [boundary_violation(code, "No supported TODO authority root was found.", "Provide exactly one todos/ root with a real active/ directory.", None)]
    if len(grouped) != 1:
        return None, [boundary_violation("CLOSEOUT-AUTHORITY-AMBIGUOUS", "Multiple distinct supported TODO authority roots were found.", "Keep exactly one supported authority root.", None)]
    root, aliases = next(iter(grouped.items()))
    return TodoAuthority(root=root, aliases=tuple(aliases)), []


def lifecycle_root(authority: TodoAuthority, lifecycle: str, alias: Path) -> tuple[Path | None, list[dict[str, Any]]]:
    lexical = alias / lifecycle
    if lexical.is_symlink():
        try:
            resolved = lexical.resolve()
        except RuntimeError:
            return None, [boundary_violation("CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK", "Lifecycle directory symlink cannot be resolved.", "Replace the cyclic lifecycle symlink with a real contained directory.", str(lexical))]
        code = "CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE" if not contains_path(resolved, authority.root) else "CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK"
        return None, [boundary_violation(code, "Lifecycle directory is a symlink.", "Use a real lifecycle directory contained by the authority.", str(lexical))]
    if not lexical.is_dir() or not contains_path(lexical.resolve(), authority.root):
        return None, [boundary_violation("CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE", "Lifecycle directory escapes the authority.", "Restore a contained lifecycle directory.", str(lexical))]
    return lexical.resolve(), []


def select_explicit_todo(value: str, authority: TodoAuthority) -> tuple[Path | None, str | None, list[dict[str, Any]]]:
    lexical = Path(value).absolute()
    alias = next((item for item in authority.aliases if contains_path(lexical, item)), None)
    lifecycle = ""
    if alias is not None:
        relative = lexical.relative_to(alias)
        lifecycle = relative.parts[0] if relative.parts else ""
        if lifecycle in LIFECYCLES and ((alias / lifecycle).exists() or (alias / lifecycle).is_symlink()):
            _root, lifecycle_violations = lifecycle_root(authority, lifecycle, alias)
            if lifecycle_violations:
                return None, None, lifecycle_violations
    try:
        resolved = lexical.resolve()
    except RuntimeError:
        return None, None, [boundary_violation("CLOSEOUT-TODO-MISSING", "Explicit TODO symlink cannot be resolved.", "Replace the cyclic TODO symlink with an existing Markdown file.", value)]
    if not lexical.exists():
        if lexical.is_symlink() and not contains_path(resolved, authority.root):
            return None, None, [boundary_violation("CLOSEOUT-TODO-OUTSIDE-AUTHORITY", "Explicit TODO symlink escapes the authority.", "Replace the escaping TODO symlink with a contained Markdown file.", value)]
        return None, None, [boundary_violation("CLOSEOUT-TODO-MISSING", "Explicit TODO path does not exist.", "Pass an existing Markdown TODO file.", value)]
    if not lexical.is_file():
        return None, None, [boundary_violation("CLOSEOUT-TODO-NOT-FILE", "Explicit TODO path is not a regular file.", "Pass an existing regular Markdown TODO file.", value)]
    if lexical.suffix != ".md":
        return None, None, [boundary_violation("CLOSEOUT-TODO-NOT-MARKDOWN", "Explicit TODO path is not a .md file.", "Pass a Markdown TODO file with the exact .md suffix.", value)]
    if alias is None:
        return None, None, [boundary_violation("CLOSEOUT-TODO-OUTSIDE-AUTHORITY", "Explicit TODO is outside the selected authority.", "Pass a TODO contained by the authority.", value)]
    if not contains_path(resolved, authority.root):
        return None, None, [boundary_violation("CLOSEOUT-TODO-OUTSIDE-AUTHORITY", "Explicit TODO is outside the selected authority.", "Pass a TODO contained by the authority.", value)]
    if lifecycle not in LIFECYCLES:
        return None, None, [boundary_violation("CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED", "TODO lifecycle is not recognized.", "Use active/, promotion_lane/, or completed/.", value)]
    root, violations = lifecycle_root(authority, lifecycle, alias)
    if not contains_path(resolved, root):
        return None, None, [boundary_violation("CLOSEOUT-TODO-LIFECYCLE-ESCAPE", "TODO alias crosses its lexical lifecycle boundary.", "Keep aliases within their lexical lifecycle.", value)]
    return resolved, lifecycle, []


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


def canonical_work_state(value: str | None) -> str:
    normalized = normalize(value).replace("_", "-")
    if normalized in {"n/a once moved out of active", "n/a-once-moved-out-of-active"}:
        return "n/a-once-moved-out-of-active"
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


def path_state(path: Path, authority: TodoAuthority) -> str:
    resolved = path.resolve()
    if contains_path(resolved, authority.root):
        relative = resolved.relative_to(authority.root)
        return relative.parts[0] if relative.parts and relative.parts[0] in LIFECYCLES else "other"
    return "other"


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


def load_todo(todo_path: Path, authority: TodoAuthority) -> dict[str, Any]:
    text = todo_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    sections = extract_sections(lines)
    status_lines = find_section(sections, "Delivery Status Canon")
    closeout_lines = find_section(sections, DISPOSITION_SECTION)
    active_work_lines = find_section(sections, ACTIVE_WORK_STATE_SECTION)
    stage = first_field(status_lines, ("Current delivery stage",))
    qualifiers = first_field(status_lines, ("Qualifiers",))
    next_step = first_field(status_lines, ("Next exact step",))
    work_state = canonical_work_state(first_field(active_work_lines, ("Work state",)))
    work_state_reason = first_field(active_work_lines, ("Why this state now",))
    work_state_exit_condition = first_field(active_work_lines, ("Exit condition",))
    disposition = canonical_disposition(first_field(closeout_lines, ("Disposition", "Closeout disposition")))
    reason = first_field(closeout_lines, ("Disposition reason", "Reason"))
    post_commit_status = first_field(closeout_lines, ("Post-commit/push status", "Post commit/push status"))
    next_path_action = first_field(closeout_lines, ("Next path/status action", "Path/status action"))
    return {
        "path": todo_path,
        "sections": sections,
        "path_state": path_state(todo_path, authority),
        "stage": stage,
        "qualifiers": qualifiers,
        "next_step": next_step,
        "active_work_state_section_present": bool(active_work_lines),
        "work_state": work_state,
        "work_state_reason": work_state_reason,
        "work_state_exit_condition": work_state_exit_condition,
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
        "work_state": todo["work_state"] or None,
        "delivery_claim": todo["delivery_claim"],
        "closeout_section_present": todo["closeout_section_present"],
        "disposition": todo["disposition"] or None,
        "post_commit_push_status": todo["post_commit_status"],
    }

    if todo["path_state"] != "active" or not todo["delivery_claim"]:
        return violations, context
    qualifiers = normalize(todo["qualifiers"])

    if not todo["active_work_state_section_present"]:
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-MISSING",
                "Delivered active TODO is missing the `Active Work State` section.",
                "Add `## Active Work State` with work state, why this state now, and exit condition while the TODO remains in active/.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )
        return violations, context

    if todo["work_state"] not in VALID_ACTIVE_WORK_STATES:
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-INVALID",
                f"Active work state is missing or invalid: {todo['work_state'] or 'missing'}.",
                "Use one of: implementation, review, blocked.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )
    if is_missing(todo["work_state_reason"]):
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-REASON-MISSING",
                "Active work state is missing `Why this state now`.",
                "Explain why the TODO still belongs in active/.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )
    if is_missing(todo["work_state_exit_condition"]):
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-EXIT-MISSING",
                "Active work state is missing `Exit condition`.",
                "Record the exact event that moves the TODO to the next state or lane.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )
    if todo["work_state"] == "blocked" and "blocked" not in qualifiers:
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-BLOCKED-QUALIFIER-MISMATCH",
                "Work state is blocked but Delivery Status Canon qualifiers do not include Blocked.",
                "If work state is blocked, include `Blocked` in `Qualifiers` and keep blocker notes current.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )
    if "blocked" in qualifiers and todo["work_state"] != "blocked":
        violations.append(
            build_violation(
                "ACTIVE-WORK-STATE-BLOCKED-STATE-MISMATCH",
                "Delivery Status Canon qualifiers include Blocked but work state is not blocked.",
                "Set `Work state` to `blocked` whenever the TODO is blocked in active/.",
                ACTIVE_WORK_STATE_SECTION,
            )
        )

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
        if todo["work_state"] != "blocked":
            violations.append(
                build_violation(
                    "ACTIVE-WORK-STATE-BLOCKED-DISPOSITION-MISMATCH",
                    "Disposition is blocked but work state is not blocked.",
                    "Set `Work state` to `blocked` when closeout disposition is blocked.",
                    ACTIVE_WORK_STATE_SECTION,
                )
            )
    elif disposition in {"move-completed", "move-promotion-lane"}:
        if todo["work_state"] != "review":
            violations.append(
                build_violation(
                    "ACTIVE-WORK-STATE-REVIEW-REQUIRED",
                    f"Disposition {disposition} requires active work state `review` while the TODO remains in active/.",
                    "Set `Work state` to `review` once local implementation is complete and only review/promotion follow-through remains.",
                    ACTIVE_WORK_STATE_SECTION,
                )
            )
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


def discover_active_todos(authority: TodoAuthority) -> tuple[list[TodoSelection], list[dict[str, Any]]]:
    active_root, violations = lifecycle_root(authority, "active", authority.aliases[0])
    if violations:
        return [], violations
    discovered: list[TodoSelection] = []
    seen: set[Path] = set()
    lexical_active = authority.aliases[0] / "active"
    candidates: list[Path] = []

    def record_walk_error(error: OSError) -> None:
        failed_path = str(error.filename) if error.filename else str(lexical_active)
        violations.append(
            boundary_violation(
                "CLOSEOUT-DISCOVERY-UNREADABLE",
                "Active TODO discovery could not read a filesystem entry or subtree.",
                "Restore read access to the active TODO tree and rerun the guard.",
                failed_path,
            )
        )

    for directory, dirnames, filenames in os.walk(lexical_active, topdown=True, onerror=record_walk_error, followlinks=False):
        base = Path(directory)
        markdown_directories = [name for name in dirnames if name.endswith(".md")]
        dirnames[:] = [name for name in dirnames if name not in markdown_directories]
        candidates.extend(base / name for name in markdown_directories)
        candidates.extend(base / name for name in filenames if name.endswith(".md"))

    for path in sorted(candidates):
        if path.is_dir() and not path.is_symlink():
            violations.append(boundary_violation("CLOSEOUT-TODO-NOT-FILE", "Discovered TODO is not a regular file.", "Use a regular Markdown TODO file.", str(path)))
            continue
        try:
            resolved = path.resolve()
        except RuntimeError:
            violations.append(boundary_violation("CLOSEOUT-TODO-MISSING", "Discovered TODO symlink cannot be resolved.", "Replace the cyclic TODO symlink with an existing Markdown file.", str(path)))
            continue
        if path.is_symlink() and not path.exists():
            code = "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" if not contains_path(resolved, authority.root) else "CLOSEOUT-TODO-MISSING"
            message = "Discovered TODO escapes the authority." if code == "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" else "Discovered TODO symlink target is missing."
            resolution = "Remove the escaping alias." if code == "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" else "Replace the broken TODO symlink with an existing Markdown file."
            violations.append(boundary_violation(code, message, resolution, str(path)))
            continue
        if not path.is_file():
            violations.append(boundary_violation("CLOSEOUT-TODO-NOT-FILE", "Discovered TODO is not a regular file.", "Use a regular Markdown TODO file.", str(path)))
            continue
        if not contains_path(resolved, authority.root):
            violations.append(boundary_violation("CLOSEOUT-TODO-OUTSIDE-AUTHORITY", "Discovered TODO escapes the authority.", "Remove the escaping alias.", str(path)))
        elif not contains_path(resolved, active_root):
            violations.append(boundary_violation("CLOSEOUT-TODO-LIFECYCLE-ESCAPE", "Discovered TODO crosses the active lifecycle boundary.", "Keep aliases inside active/.", str(path)))
        elif resolved not in seen:
            seen.add(resolved)
            discovered.append(TodoSelection(load_path=resolved, report_path=path, discovered=True))
    return sorted(discovered, key=lambda item: str(item.load_path)), violations


def result_for(todo_selections: list[TodoSelection], repo: Path | None, authority: TodoAuthority | None, boundary_violations: list[dict[str, Any]]) -> dict[str, Any]:
    git = git_context(repo)
    todo_results = []
    all_violations: list[dict[str, Any]] = list(boundary_violations)
    for selection in todo_selections:
        assert authority is not None
        try:
            todo = load_todo(selection.load_path, authority)
        except OSError:
            if not selection.discovered:
                raise
            all_violations.append(
                boundary_violation(
                    "CLOSEOUT-DISCOVERY-UNREADABLE",
                    "Discovered Markdown TODO could not be read.",
                    "Restore read access to the TODO file and rerun the guard.",
                    str(selection.report_path),
                )
            )
            continue
        violations, context = validate_todo(todo, git)
        all_violations.extend({**violation, "todo_path": str(selection.load_path)} for violation in violations)
        todo_results.append({"context": context, "violations": violations})
    return {
        "rule_id": RULE_ID,
        "generated_at_utc": datetime.now(UTC).isoformat().replace("+00:00", "Z"),
        "todo_count": len(todo_results),
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
        print(f"    todo_path: {violation['todo_path'] or 'n/a'}")
        print(f"    section: {violation['section']}")
        print(f"    resolution: {violation['resolution']}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate closeout disposition in nested foundation_documentation/todos or standalone todos authorities.")
    parser.add_argument("todo", nargs="?", help="TODO markdown path to validate.")
    parser.add_argument("--repo", default=".", help="Repository/container for authority resolution, Git context, and discovery.")
    parser.add_argument("--all-active", action="store_true", help="Scan the selected authority active/**/*.md files.")
    parser.add_argument("--json-output", help="Write machine-readable guard result to this path.")
    parser.add_argument("--advisory", action="store_true", help="Always exit 0 after printing findings.")
    args = parser.parse_args(argv)
    if bool(args.todo) == bool(args.all_active):
        parser.error("Pass either a TODO path or --all-active.")
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    repo = Path(args.repo)
    authority, boundary_violations = resolve_authority(repo)
    todo_selections: list[TodoSelection] = []
    if authority is not None:
        if args.all_active:
            todo_selections, discovered_violations = discover_active_todos(authority)
            boundary_violations.extend(discovered_violations)
        else:
            todo_path, _lifecycle, explicit_violations = select_explicit_todo(args.todo, authority)
            boundary_violations.extend(explicit_violations)
            if todo_path is not None:
                todo_selections = [TodoSelection(load_path=todo_path, report_path=todo_path, discovered=False)]
    result = result_for(todo_selections, repo, authority, boundary_violations)
    print_result(result)
    if args.json_output:
        try:
            Path(args.json_output).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        except OSError as error:
            print(f"TODO Closeout Guard runtime error: unable to write JSON output: {error}", file=sys.stderr)
            return 1
    if args.advisory:
        return 0
    return 0 if result["overall_outcome"] == "go" else 2


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        raise SystemExit(130)
