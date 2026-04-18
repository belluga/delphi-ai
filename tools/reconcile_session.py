#!/usr/bin/env python3
"""PACED Session Reconciler: Distills session memory into project-level intelligence.

This tool processes a finished session memory and identifies patterns, lessons,
or architectural changes that should be elevated to the project's long-term memory.
"""

import argparse
import sys
import re
from pathlib import Path
from datetime import datetime

# Robust regex: matches [LEARNING] or [PATTERN] with optional colon/spaces after the tag
_LEARNING_RE = re.compile(r"^\s*\[LEARNING\][:\s]*(.+)$", re.IGNORECASE)
_PATTERN_RE = re.compile(r"^\s*\[PATTERN\][:\s]*(.+)$", re.IGNORECASE)


def _load_existing_entries(project_memory_file: Path) -> set[str]:
    """Load existing entries from project_memory.md for deduplication."""
    if not project_memory_file.exists():
        return set()
    existing = set()
    for line in project_memory_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            # Normalize: lowercase, strip whitespace for comparison
            existing.add(stripped[2:].strip().lower())
    return existing


def reconcile(session_id: str, repo_root: Path) -> int:
    session_dir = repo_root / "foundation_documentation" / "sessions"
    session_file = session_dir / f"session_{session_id}_memory.md"
    project_memory_file = repo_root / "foundation_documentation" / "project_memory.md"

    if not session_file.exists():
        print(f"Error: Session memory '{session_id}' not found.")
        return 1

    content = session_file.read_text(encoding="utf-8")

    # Extract learnings and patterns using robust regex
    learnings: list[str] = []
    patterns: list[str] = []

    for line in content.splitlines():
        m_learn = _LEARNING_RE.match(line)
        if m_learn:
            value = m_learn.group(1).strip()
            if value:
                learnings.append(value)
            continue
        m_pattern = _PATTERN_RE.match(line)
        if m_pattern:
            value = m_pattern.group(1).strip()
            if value:
                patterns.append(value)

    if not learnings and not patterns:
        print(f"No explicit learnings or patterns found in session '{session_id}'.")
        return 0

    # Ensure project memory exists
    if not project_memory_file.exists():
        project_memory_file.parent.mkdir(parents=True, exist_ok=True)
        project_memory_file.write_text(
            "# Project Long-Term Memory\n\n## Accumulated Intelligence\n\n",
            encoding="utf-8",
        )

    # Deduplication: load existing entries and filter out duplicates
    existing_entries = _load_existing_entries(project_memory_file)
    new_learnings = [l for l in learnings if l.strip().lower() not in existing_entries]
    new_patterns = [p for p in patterns if p.strip().lower() not in existing_entries]

    skipped = (len(learnings) - len(new_learnings)) + (len(patterns) - len(new_patterns))
    if skipped > 0:
        print(f"Deduplication: skipped {skipped} already-known entries.")

    if not new_learnings and not new_patterns:
        print(f"All entries from session '{session_id}' already exist in project_memory.md.")
        return 0

    current_project_memory = project_memory_file.read_text(encoding="utf-8")
    new_entries = f"\n### From Session {session_id} ({datetime.now().strftime('%Y-%m-%d')})\n"

    if new_learnings:
        new_entries += "#### Lessons Learned\n"
        for entry in new_learnings:
            new_entries += f"- {entry}\n"

    if new_patterns:
        new_entries += "#### New Patterns\n"
        for entry in new_patterns:
            new_entries += f"- {entry}\n"

    project_memory_file.write_text(
        current_project_memory + new_entries, encoding="utf-8"
    )
    print(
        f"Successfully reconciled session '{session_id}' into project_memory.md "
        f"({len(new_learnings)} learnings, {len(new_patterns)} patterns)."
    )
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--repo-root", required=True)

    args = parser.parse_args()
    sys.exit(reconcile(args.session_id, Path(args.repo_root).resolve()))
