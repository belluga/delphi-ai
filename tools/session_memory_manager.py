#!/usr/bin/env python3
"""PACED Session Memory Manager: Enforces Identity and TODO-linkage.

This tool ensures that session-memory is never anonymous and always
subservient to an active TODO.
"""

import argparse
import sys
from pathlib import Path
from datetime import datetime

def create_memory(session_id: str, todo_id: str, repo_root: Path):
    memory_dir = repo_root / "foundation_documentation" / "sessions"
    memory_dir.mkdir(parents=True, exist_ok=True)
    
    memory_file = memory_dir / f"session_{session_id}_memory.md"
    
    if memory_file.exists():
        print(f"Memory for session '{session_id}' already exists.")
        return 0

    content = f"""# Session Memory: {session_id}
- **Linked TODO:** {todo_id}
- **Started At:** {datetime.now().isoformat()}
- **Status:** ACTIVE

## 🧠 Contextual Stream
<!-- Use this section for raw thoughts, temporary decisions, and command logs -->

## 🛠️ Pending Transpositions
<!-- List items that MUST be moved to the TODO or Rulebook before closing this session -->

---
**Authority:** PACED Deterministic Session Management
"""
    memory_file.write_text(content)
    print(f"Created session memory: {memory_file}")
    return 0

def close_memory(session_id: str, repo_root: Path):
    memory_file = repo_root / "foundation_documentation" / "sessions" / f"session_{session_id}_memory.md"
    if not memory_file.exists():
        print(f"Error: Session memory '{session_id}' not found.")
        return 1
    
    # Check for pending transpositions (FAIL-CLOSED: blocks if transpositions remain)
    content = memory_file.read_text()
    transposition_marker = "## 🛠️ Pending Transpositions"
    if transposition_marker in content:
        section_content = content.split(transposition_marker)[1]
        # Stop at the next section or end of file
        if "## " in section_content[1:]:
            section_content = section_content[:section_content.index("## ", 1)]
        # Remove HTML comments and blank lines
        meaningful_lines = [
            line.strip() for line in section_content.strip().splitlines()
            if line.strip()
            and not line.strip().startswith("<!--")
            and not line.strip().startswith("---")
            and not line.strip().startswith("**Authority")
        ]
        if meaningful_lines:
            print(
                f"TEACH runtime response\n"
                f"status: blocked\n"
                f"enforcement: stop_before_close\n"
                f"rule_id: paced.session.pending-transpositions\n"
                f"violation:\n"
                f"  - [TRANSPOSITION-PENDING] Session '{session_id}' has {len(meaningful_lines)} "
                f"pending transposition(s) that MUST be moved to the TODO or Rulebook before closing.\n"
                f"hint: Clear the '## 🛠️ Pending Transpositions' section by moving each item "
                f"to the linked TODO, project_memory.md, or a rule file. Then retry close."
            )
            return 2
    
    archive_dir = repo_root / "foundation_documentation" / "sessions" / "archive"
    archive_dir.mkdir(parents=True, exist_ok=True)
    
    # Run Reconciler before archiving
    import subprocess
    print(f"Running reconciler for session '{session_id}'...")
    subprocess.run([sys.executable, str(Path(__file__).parent / "reconcile_session.py"), 
                    "--session-id", session_id, "--repo-root", str(repo_root)], check=False)

    target = archive_dir / f"session_{session_id}_memory.md"
    memory_file.rename(target)
    print(f"Archived session memory to: {target}")
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command")
    
    init = subparsers.add_parser("init")
    init.add_argument("--session-id", required=True)
    init.add_argument("--todo-id", required=True)
    init.add_argument("--repo-root", required=True)
    
    close = subparsers.add_parser("close")
    close.add_argument("--session-id", required=True)
    close.add_argument("--repo-root", required=True)
    
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    
    if args.command == "init":
        sys.exit(create_memory(args.session_id, args.todo_id, root))
    elif args.command == "close":
        sys.exit(close_memory(args.session_id, root))
