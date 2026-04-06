#!/usr/bin/env python3
"""Generate a derived runtime/session continuity index from active TODOs."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path


FIELD_RE = re.compile(r"^- \*\*(.+?):\*\*\s*(.*)$")


@dataclass
class HandoffEntry:
    from_profile: str
    to_profile: str
    why: str
    touched_surfaces: str
    status: str


@dataclass
class TodoRecord:
    path: str
    title: str
    delivery_stage: str
    qualifiers: str
    next_exact_step: str
    primary_module: str
    primary_profile: str
    technical_scope: str
    feature_brief: str
    blocker: str
    blocker_reason: str
    unblocker: str
    blocker_owner: str
    last_confirmed_truth: str
    open_handoffs: list[HandoffEntry]

    @property
    def is_blocked(self) -> bool:
        lowered = self.qualifiers.lower().strip()
        if lowered in {"n/a", ""} or (lowered.startswith("<") and lowered.endswith(">")):
            return False
        parts = {part.strip() for part in re.split(r"[+,/|]", lowered)}
        return "blocked" in parts


@dataclass
class SessionMemory:
    path: str
    last_updated: str
    current_active_todo: str
    current_active_front: str
    last_confirmed_truth: str
    next_likely_step: str


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def clean_value(raw: str) -> str:
    value = raw.strip()
    while len(value) >= 2 and value[0] == value[-1] and value[0] in {"`", '"', "'"}:
        value = value[1:-1].strip()
    return value or "n/a"


def extract_field(lines: list[str], label: str) -> str:
    prefix = f"- **{label}:**"
    for line in lines:
        if line.startswith(prefix):
            return clean_value(line[len(prefix) :])
    return "n/a"


def extract_block_field(lines: list[str], section_heading: str, label: str) -> str:
    start = None
    for index, line in enumerate(lines):
        if line.strip() == section_heading:
            start = index + 1
            break
    if start is None:
        return "n/a"

    prefix = f"- **{label}:**"
    for line in lines[start:]:
        stripped = line.strip()
        if stripped.startswith("## ") and stripped != section_heading:
            break
        if stripped.startswith(prefix):
            return clean_value(stripped[len(prefix) :])
    return "n/a"


def extract_heading_value(lines: list[str], heading: str) -> str:
    for index, line in enumerate(lines):
        if line.strip() == heading:
            for candidate in lines[index + 1 :]:
                stripped = candidate.strip()
                if not stripped:
                    continue
                if stripped.startswith("#"):
                    break
                return clean_value(stripped)
            break
    return "n/a"


def normalize_cell(cell: str) -> str:
    return cell.strip().strip("`")


def parse_table(lines: list[str], heading: str) -> list[list[str]]:
    start = None
    for index, line in enumerate(lines):
        if line.strip() == heading:
            start = index + 1
            break
    if start is None:
        return []

    rows: list[list[str]] = []
    for line in lines[start:]:
        stripped = line.strip()
        if not stripped:
            if rows:
                break
            continue
        if stripped.startswith("#"):
            break
        if not stripped.startswith("|"):
            if rows:
                break
            continue
        cells = [normalize_cell(cell) for cell in stripped.strip("|").split("|")]
        if not cells or all(not cell for cell in cells):
            continue
        if all(set(cell) <= {"-"} for cell in cells):
            continue
        if cells[0].lower() == "from profile":
            continue
        rows.append(cells)
    return rows


def parse_handoffs(lines: list[str]) -> list[HandoffEntry]:
    rows = parse_table(lines, "### Handoff Log (Update when execution crosses profile boundaries)")
    entries: list[HandoffEntry] = []
    for row in rows:
        if len(row) < 5:
            continue
        if row[0].startswith("<") or row[4].startswith("<"):
            continue
        status = row[4]
        if status.lower() in {"completed", "none", "n/a"}:
            continue
        entries.append(
            HandoffEntry(
                from_profile=row[0],
                to_profile=row[1],
                why=row[2],
                touched_surfaces=row[3],
                status=status,
            )
        )
    return entries


def parse_todo(path: Path, repo_root: Path) -> TodoRecord:
    lines = read_lines(path)
    return TodoRecord(
        path=str(path.relative_to(repo_root)),
        title=extract_heading_value(lines, "## Title"),
        delivery_stage=extract_field(lines, "Current delivery stage"),
        qualifiers=extract_field(lines, "Qualifiers"),
        next_exact_step=extract_field(lines, "Next exact step"),
        primary_module=extract_field(lines, "Primary module doc"),
        primary_profile=extract_field(lines, "Primary execution profile"),
        technical_scope=extract_field(lines, "Active technical scope"),
        feature_brief=extract_field(lines, "Feature brief"),
        blocker=extract_block_field(lines, "## Blocker Notes (Required if `Qualifiers` includes `Blocked`)", "Blocker"),
        blocker_reason=extract_block_field(
            lines,
            "## Blocker Notes (Required if `Qualifiers` includes `Blocked`)",
            "Why blocked now",
        ),
        unblocker=extract_block_field(
            lines,
            "## Blocker Notes (Required if `Qualifiers` includes `Blocked`)",
            "What unblocks it",
        ),
        blocker_owner=extract_block_field(
            lines,
            "## Blocker Notes (Required if `Qualifiers` includes `Blocked`)",
            "Owner / source",
        ),
        last_confirmed_truth=extract_block_field(
            lines,
            "## Blocker Notes (Required if `Qualifiers` includes `Blocked`)",
            "Last confirmed truth",
        ),
        open_handoffs=parse_handoffs(lines),
    )


def parse_session_memory(path: Path, repo_root: Path) -> SessionMemory:
    lines = read_lines(path)
    return SessionMemory(
        path=str(path.relative_to(repo_root)),
        last_updated=extract_field(lines, "Last updated"),
        current_active_todo=extract_field(lines, "Current active TODO"),
        current_active_front=extract_field(lines, "Current active front"),
        last_confirmed_truth=extract_field(lines, "Last confirmed truth"),
        next_likely_step=extract_field(lines, "Next likely step"),
    )


def match_session_hint(session_memory: SessionMemory | None, todos: list[TodoRecord]) -> TodoRecord | None:
    if not session_memory:
        return None

    explicit_todo = session_memory.current_active_todo
    if explicit_todo not in {"n/a", "<foundation_documentation/todos/active/<lane>/<slug>.md|n/a>"}:
        normalized = explicit_todo.strip()
        exact = [todo for todo in todos if todo.path == normalized]
        if len(exact) == 1:
            return exact[0]
        by_name = [todo for todo in todos if Path(todo.path).name == Path(normalized).name]
        if len(by_name) == 1:
            return by_name[0]

    hint = session_memory.current_active_front.lower()
    if hint in {"n/a", "<what the next session should understand first>"}:
        return None

    matches = []
    for todo in todos:
        haystack = " ".join([todo.path, todo.title]).lower()
        if hint in haystack or todo.path.lower() in hint or todo.title.lower() in hint:
            matches.append(todo)
    return matches[0] if len(matches) == 1 else None


def choose_resume_target(todos: list[TodoRecord], session_memory: SessionMemory | None) -> TodoRecord | None:
    if not todos:
        return None

    hinted = match_session_hint(session_memory, todos)
    if hinted:
        return hinted

    unblocked = [todo for todo in todos if not todo.is_blocked]
    if len(unblocked) == 1:
        return unblocked[0]

    blocked = [todo for todo in todos if todo.is_blocked]
    if blocked:
        if len(blocked) == 1:
            return blocked[0]

    if len(todos) == 1:
        return todos[0]

    return None


def render_markdown(
    repo_root: Path,
    todos: list[TodoRecord],
    session_memory: SessionMemory | None,
) -> str:
    generated_at = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")
    resume_target = choose_resume_target(todos, session_memory)
    blocked = [todo for todo in todos if todo.is_blocked]
    handoffs = [(todo, entry) for todo in todos for entry in todo.open_handoffs]

    lines = [
        "# Runtime Index (Derived)",
        "",
        f"- **Generated at:** {generated_at}",
        f"- **Repository root:** `{repo_root}`",
        f"- **Active tactical TODOs:** `{len(todos)}`",
        f"- **Blocked fronts:** `{len(blocked)}`",
        f"- **Open handoffs:** `{len(handoffs)}`",
        "- **Authority reminder:** This file is derived navigation aid only. Canonical authority remains in `project_constitution.md`, `system_roadmap.md`, canonical module docs, active TODOs, and explicit handoff logs.",
        "- **Editing rule:** Do not hand-edit this file to create truth. Regenerate it from the canonical sources instead.",
        "",
        "## Resume Heuristic",
    ]

    if resume_target:
        lines.extend(
            [
                f"- **Suggested first TODO to open:** `{resume_target.path}`",
                f"- **Why this one:** `{resume_target.title}` | stage `{resume_target.delivery_stage}` | qualifiers `{resume_target.qualifiers}`",
                f"- **Next exact step:** {resume_target.next_exact_step}",
            ]
        )
    else:
        if todos:
            lines.append("- No single confident resume target could be derived. Review the summary tables below, especially blocked fronts and open handoffs.")
            candidate_paths = ", ".join(f"`{todo.path}`" for todo in sorted(todos, key=lambda item: item.path)[:3])
            lines.append(f"- **Most relevant candidate fronts:** {candidate_paths}")
        else:
            lines.append("- No active tactical TODOs found.")

    if session_memory:
        lines.extend(
            [
                "",
                "## Session Memory Carry-Over",
                f"- **Source:** `{session_memory.path}`",
                f"- **Last updated:** {session_memory.last_updated}",
                f"- **Current active TODO:** {session_memory.current_active_todo}",
                f"- **Current active front:** {session_memory.current_active_front}",
                f"- **Last confirmed truth:** {session_memory.last_confirmed_truth}",
                f"- **Next likely step:** {session_memory.next_likely_step}",
            ]
        )

    lines.extend(
        [
            "",
            "## Active TODO Summary",
            "| TODO | Title | Stage | Qualifiers | Next exact step | Primary module | Profile / Scope |",
            "| --- | --- | --- | --- | --- | --- | --- |",
        ]
    )

    if todos:
        for todo in sorted(todos, key=lambda item: item.path):
            lines.append(
                f"| `{todo.path}` | {todo.title} | `{todo.delivery_stage}` | `{todo.qualifiers}` | {todo.next_exact_step} | `{todo.primary_module}` | `{todo.primary_profile}` / `{todo.technical_scope}` |"
            )
    else:
        lines.append("| `none` | No active TODOs found | `n/a` | `n/a` | n/a | `n/a` | `n/a` |")

    lines.extend(["", "## Blocked Fronts"])
    if blocked:
        for todo in sorted(blocked, key=lambda item: item.path):
            lines.extend(
                [
                    f"### `{todo.path}`",
                    f"- **Title:** {todo.title}",
                    f"- **Blocker:** {todo.blocker}",
                    f"- **Why blocked now:** {todo.blocker_reason}",
                    f"- **What unblocks it:** {todo.unblocker}",
                    f"- **Owner / source:** {todo.blocker_owner}",
                    f"- **Last confirmed truth:** {todo.last_confirmed_truth}",
                    f"- **Next exact step:** {todo.next_exact_step}",
                ]
            )
    else:
        lines.append("- No blocked TODOs detected.")

    lines.extend(
        [
            "",
            "## Open Handoffs",
            "| TODO | From | To | Status | Touched Surfaces | Why |",
            "| --- | --- | --- | --- | --- | --- |",
        ]
    )
    if handoffs:
        for todo, entry in sorted(handoffs, key=lambda item: (item[0].path, item[1].from_profile, item[1].to_profile)):
            lines.append(
                f"| `{todo.path}` | `{entry.from_profile}` | `{entry.to_profile}` | `{entry.status}` | {entry.touched_surfaces} | {entry.why} |"
            )
    else:
        lines.append("| `none` | `n/a` | `n/a` | `n/a` | n/a | No open handoffs detected. |")

    return "\n".join(lines) + "\n"


def build_payload(repo_root: Path, todos: list[TodoRecord], session_memory: SessionMemory | None) -> dict:
    resume_target = choose_resume_target(todos, session_memory)
    return {
        "artifact_kind": "runtime_index",
        "authoritative": False,
        "edit_policy": "derived_regenerate_do_not_hand_edit",
        "provenance": {
            "active_todo_glob": "foundation_documentation/todos/active/**/*.md",
            "session_memory_path": session_memory.path if session_memory else None,
        },
        "generated_at": datetime.now().astimezone().isoformat(),
        "repo_root": str(repo_root),
        "active_todos": [asdict(todo) for todo in todos],
        "session_memory": asdict(session_memory) if session_memory else None,
        "resume_target": resume_target.path if resume_target else None,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a derived runtime/session continuity index from active TODOs and session memory."
    )
    parser.add_argument("--repo", default=".", help="Repository root containing foundation_documentation/.")
    parser.add_argument("--output", help="Write markdown output to this path. Defaults to stdout.")
    parser.add_argument("--json-output", help="Optional JSON sidecar output path.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo).resolve()
    foundation_root = repo_root / "foundation_documentation"
    todos_root = foundation_root / "todos" / "active"
    session_memory_path = foundation_root / "artifacts" / "session-memory.md"

    if not foundation_root.exists():
        print(
            f"foundation_documentation/ not found under {repo_root}. This index applies to downstream tactical continuity, not Delphi self-maintenance.",
            file=sys.stderr,
        )
        return 1

    todo_paths = sorted(path for path in todos_root.rglob("*.md")) if todos_root.exists() else []
    todos = [parse_todo(path, repo_root) for path in todo_paths]
    session_memory = parse_session_memory(session_memory_path, repo_root) if session_memory_path.exists() else None

    markdown = render_markdown(repo_root, todos, session_memory)
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(markdown, encoding="utf-8")
    else:
        sys.stdout.write(markdown)

    if args.json_output:
        json_path = Path(args.json_output)
        json_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(json.dumps(build_payload(repo_root, todos, session_memory), indent=2), encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
