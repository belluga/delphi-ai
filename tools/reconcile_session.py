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

def reconcile(session_id: str, repo_root: Path):
    session_dir = repo_root / "foundation_documentation" / "sessions"
    session_file = session_dir / f"session_{session_id}_memory.md"
    project_memory_file = repo_root / "foundation_documentation" / "project_memory.md"
    
    if not session_file.exists():
        print(f"Error: Session memory '{session_id}' not found.")
        return 1

    content = session_file.read_text()
    
    # Extract "Lessons Learned" or "Patterns" - looking for specific markers
    # Users/Agents should mark these with [LEARNING] or [PATTERN] or inside a specific section
    learnings = []
    patterns = []
    
    # Simple extraction logic: look for lines starting with [LEARNING] or [PATTERN]
    for line in content.splitlines():
        if line.strip().upper().startswith("[LEARNING]"):
            learnings.append(line.strip()[10:].strip())
        elif line.strip().upper().startswith("[PATTERN]"):
            patterns.append(line.strip()[9:].strip())

    if not learnings and not patterns:
        print(f"No explicit learnings or patterns found in session '{session_id}'.")
        return 0

    # Ensure project memory exists
    if not project_memory_file.exists():
        project_memory_file.write_text("# Project Long-Term Memory\n\n## 🧠 Accumulated Intelligence\n\n")

    current_project_memory = project_memory_file.read_text()
    new_entries = f"\n### 📝 From Session {session_id} ({datetime.now().strftime('%Y-%m-%d')})\n"
    
    if learnings:
        new_entries += "#### Lessons Learned\n"
        for l in learnings:
            new_entries += f"- {l}\n"
            
    if patterns:
        new_entries += "#### New Patterns\n"
        for p in patterns:
            new_entries += f"- {p}\n"

    project_memory_file.write_text(current_project_memory + new_entries)
    print(f"Successfully reconciled session '{session_id}' into project_memory.md")
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--repo-root", required=True)
    
    args = parser.parse_args()
    sys.exit(reconcile(args.session_id, Path(args.repo_root).resolve()))
