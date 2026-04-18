#!/usr/bin/env python3
"""PACED Session Reconciler: Distills session memory into project-level intelligence.

This tool processes a finished session memory and:
1. Extracts [LEARNING] and [PATTERN] entries into project_memory.md.
2. Detects recurring anti-patterns and suggests promotion to stack/core.
3. Generates pattern candidate files for human review.
"""

import argparse
import json
import sys
import re
from pathlib import Path
from datetime import datetime

# ---------------------------------------------------------------------------
# Regex for extraction
# ---------------------------------------------------------------------------

_LEARNING_RE = re.compile(r"^\s*\[LEARNING\][:\s]*(.+)$", re.IGNORECASE)
_PATTERN_RE = re.compile(r"^\s*\[PATTERN\][:\s]*(.+)$", re.IGNORECASE)
_ANTI_PATTERN_RE = re.compile(r"^\s*\[ANTI[_-]?PATTERN\][:\s]*(.+)$", re.IGNORECASE)

# Threshold: if an anti-pattern appears this many times across sessions, suggest promotion
_PROMOTION_THRESHOLD = 2


# ---------------------------------------------------------------------------
# Deduplication
# ---------------------------------------------------------------------------

def _load_existing_entries(project_memory_file: Path) -> set[str]:
    """Load existing entries from project_memory.md for deduplication."""
    if not project_memory_file.exists():
        return set()
    existing = set()
    for line in project_memory_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            existing.add(stripped[2:].strip().lower())
    return existing


# ---------------------------------------------------------------------------
# Anti-pattern frequency tracking
# ---------------------------------------------------------------------------

def _load_anti_pattern_ledger(ledger_path: Path) -> dict:
    """Load the anti-pattern frequency ledger (JSON)."""
    if not ledger_path.exists():
        return {"version": "anti-pattern-ledger-v1", "entries": {}}
    try:
        return json.loads(ledger_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, KeyError):
        return {"version": "anti-pattern-ledger-v1", "entries": {}}


def _save_anti_pattern_ledger(ledger_path: Path, ledger: dict) -> None:
    """Save the anti-pattern frequency ledger."""
    ledger_path.parent.mkdir(parents=True, exist_ok=True)
    ledger_path.write_text(json.dumps(ledger, indent=2, ensure_ascii=False), encoding="utf-8")


def _normalize_anti_pattern_key(text: str) -> str:
    """Normalize anti-pattern text to a stable key for frequency tracking."""
    return re.sub(r"\s+", " ", text.strip().lower())


def _generate_candidate_file(
    anti_pattern_text: str,
    count: int,
    sessions: list[str],
    candidates_dir: Path,
) -> Path:
    """Generate a pattern candidate markdown file for human review."""
    candidates_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"CANDIDATE_{timestamp}.md"
    filepath = candidates_dir / filename

    content = f"""---
status: "pending_review"
type: "anti-pattern"
scope: "local"
title: "{anti_pattern_text[:80]}"
category: "convention"
severity: "should"
occurrences: {count}
sessions: {json.dumps(sessions)}
created: "{datetime.now().strftime('%Y-%m-%d')}"
---

## Promotion Candidate

This anti-pattern has been detected **{count} time(s)** across {len(sessions)} session(s),
exceeding the promotion threshold of {_PROMOTION_THRESHOLD}.

### Original Anti-Pattern

> {anti_pattern_text}

### Observed In Sessions

{chr(10).join(f"- `{s}`" for s in sessions)}

### Recommended Action

1. **Review** this candidate for accuracy and relevance.
2. **Decide scope**: Should this become a `local`, `stack:<namespace>`, or `core` anti-pattern?
3. **Create formal anti-pattern** using the `anti_pattern_template.md` template.
4. **Register** in the appropriate `_index.json`.
5. **Delete** this candidate file after promotion.
"""
    filepath.write_text(content, encoding="utf-8")
    return filepath


# ---------------------------------------------------------------------------
# Main reconciliation
# ---------------------------------------------------------------------------

def reconcile(session_id: str, repo_root: Path) -> int:
    session_dir = repo_root / "foundation_documentation" / "sessions"
    session_file = session_dir / f"session_{session_id}_memory.md"
    project_memory_file = repo_root / "foundation_documentation" / "project_memory.md"
    ledger_path = repo_root / "foundation_documentation" / "anti_pattern_ledger.json"
    candidates_dir = repo_root / "foundation_documentation" / "patterns" / "candidates"

    if not session_file.exists():
        print(f"Error: Session memory '{session_id}' not found.")
        return 1

    content = session_file.read_text(encoding="utf-8")

    # Extract learnings, patterns, and anti-patterns
    learnings: list[str] = []
    patterns: list[str] = []
    anti_patterns: list[str] = []

    for line in content.splitlines():
        m_learn = _LEARNING_RE.match(line)
        if m_learn:
            value = m_learn.group(1).strip()
            if value:
                learnings.append(value)
            continue
        m_anti = _ANTI_PATTERN_RE.match(line)
        if m_anti:
            value = m_anti.group(1).strip()
            if value:
                anti_patterns.append(value)
            continue
        m_pattern = _PATTERN_RE.match(line)
        if m_pattern:
            value = m_pattern.group(1).strip()
            if value:
                patterns.append(value)

    if not learnings and not patterns and not anti_patterns:
        print(f"No explicit learnings, patterns, or anti-patterns found in session '{session_id}'.")
        return 0

    # --- Phase 1: Distill into project_memory.md ---

    if not project_memory_file.exists():
        project_memory_file.parent.mkdir(parents=True, exist_ok=True)
        project_memory_file.write_text(
            "# Project Long-Term Memory\n\n## Accumulated Intelligence\n\n",
            encoding="utf-8",
        )

    existing_entries = _load_existing_entries(project_memory_file)
    new_learnings = [l for l in learnings if l.strip().lower() not in existing_entries]
    new_patterns = [p for p in patterns if p.strip().lower() not in existing_entries]
    new_anti_patterns = [a for a in anti_patterns if a.strip().lower() not in existing_entries]

    skipped = (
        (len(learnings) - len(new_learnings))
        + (len(patterns) - len(new_patterns))
        + (len(anti_patterns) - len(new_anti_patterns))
    )
    if skipped > 0:
        print(f"Deduplication: skipped {skipped} already-known entries.")

    if new_learnings or new_patterns or new_anti_patterns:
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

        if new_anti_patterns:
            new_entries += "#### Anti-Patterns Detected\n"
            for entry in new_anti_patterns:
                new_entries += f"- {entry}\n"

        project_memory_file.write_text(
            current_project_memory + new_entries, encoding="utf-8"
        )
        print(
            f"Reconciled session '{session_id}': "
            f"{len(new_learnings)} learnings, {len(new_patterns)} patterns, "
            f"{len(new_anti_patterns)} anti-patterns."
        )
    else:
        print(f"All entries from session '{session_id}' already exist in project_memory.md.")

    # --- Phase 2: Anti-pattern frequency tracking & promotion ---

    if anti_patterns:
        ledger = _load_anti_pattern_ledger(ledger_path)
        entries = ledger.get("entries", {})
        promoted_candidates: list[str] = []

        for ap_text in anti_patterns:
            key = _normalize_anti_pattern_key(ap_text)
            if key not in entries:
                entries[key] = {"text": ap_text, "count": 0, "sessions": [], "promoted": False}

            entry = entries[key]
            if session_id not in entry["sessions"]:
                entry["count"] += 1
                entry["sessions"].append(session_id)

            # Check promotion threshold
            if entry["count"] >= _PROMOTION_THRESHOLD and not entry["promoted"]:
                candidate_path = _generate_candidate_file(
                    ap_text, entry["count"], entry["sessions"], candidates_dir
                )
                entry["promoted"] = True
                promoted_candidates.append(f"  - '{ap_text[:60]}...' -> {candidate_path.name}")
                print(
                    f"PROMOTION: Anti-pattern detected {entry['count']}x, "
                    f"candidate generated: {candidate_path.name}"
                )

        ledger["entries"] = entries
        _save_anti_pattern_ledger(ledger_path, ledger)

        if promoted_candidates:
            print(f"\n--- PROMOTION CANDIDATES ({len(promoted_candidates)}) ---")
            for c in promoted_candidates:
                print(c)
            print("Review candidates in: foundation_documentation/patterns/candidates/")

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="PACED Session Reconciler: Distill session intelligence."
    )
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--repo-root", required=True)

    args = parser.parse_args()
    sys.exit(reconcile(args.session_id, Path(args.repo_root).resolve()))
