#!/usr/bin/env python3
"""
PACED Pattern Resolver — Cascading Authority Resolution for Patterns & Anti-Patterns.

Resolves pattern IDs through the hierarchy: Local > Stack > Core.
A local pattern with `supersedes` explicitly overrides a higher-level pattern.

Usage:
    python3 pattern_resolver.py --id PAT-CORE-001-v1 [--namespace laravel] [--project-root /path]
    python3 pattern_resolver.py --validate-refs --todo /path/to/todo.md [--namespace laravel] [--project-root /path]
    python3 pattern_resolver.py --list [--namespace laravel] [--project-root /path]
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Index loading
# ---------------------------------------------------------------------------

def _find_delphi_root(start: Path) -> Optional[Path]:
    """Walk up from *start* looking for the delphi-ai directory."""
    current = start.resolve()
    for _ in range(10):
        candidate = current / "delphi-ai"
        if candidate.is_dir() and (candidate / "patterns").is_dir():
            return candidate
        if (current / "patterns").is_dir() and (current / "deterministic").is_dir():
            return current
        parent = current.parent
        if parent == current:
            break
        current = parent
    return None


def _load_index(path: Path) -> list[dict]:
    """Load a _index.json and return its patterns list."""
    if not path.exists():
        return []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return data.get("patterns", [])
    except (json.JSONDecodeError, KeyError):
        print(f"WARNING: malformed index at {path}", file=sys.stderr)
        return []


def load_all_patterns(
    delphi_root: Path,
    namespace: Optional[str] = None,
    project_root: Optional[Path] = None,
) -> dict[str, dict]:
    """
    Build a merged pattern dict respecting cascading precedence.
    Later entries override earlier ones (Core < Stack < Local).
    Returns {pattern_id: entry_dict}.
    """
    merged: dict[str, dict] = {}

    # 1. Core patterns (lowest precedence)
    core_index = delphi_root / "patterns" / "core" / "_index.json"
    for entry in _load_index(core_index):
        entry["_resolved_from"] = "core"
        entry["_file_path"] = str(delphi_root / "patterns" / "core" / entry.get("file", ""))
        merged[entry["id"]] = entry

    # 2. Stack patterns (middle precedence)
    if namespace:
        stack_index = delphi_root / "patterns" / "stacks" / namespace / "_index.json"
        for entry in _load_index(stack_index):
            entry["_resolved_from"] = f"stack:{namespace}"
            entry["_file_path"] = str(
                delphi_root / "patterns" / "stacks" / namespace / entry.get("file", "")
            )
            merged[entry["id"]] = entry
            # Handle supersedes: if this pattern supersedes a core one, mark it
            sup = entry.get("supersedes")
            if sup and sup in merged:
                merged[sup]["_overridden_by"] = entry["id"]

    # 3. Local patterns (highest precedence)
    if project_root:
        local_index = project_root / "foundation_documentation" / "patterns" / "local" / "_index.json"
        for entry in _load_index(local_index):
            entry["_resolved_from"] = "local"
            entry["_file_path"] = str(
                project_root / "foundation_documentation" / "patterns" / "local" / entry.get("file", "")
            )
            merged[entry["id"]] = entry
            sup = entry.get("supersedes")
            if sup and sup in merged:
                merged[sup]["_overridden_by"] = entry["id"]

    return merged


# ---------------------------------------------------------------------------
# Resolution
# ---------------------------------------------------------------------------

def resolve(
    pattern_id: str,
    delphi_root: Path,
    namespace: Optional[str] = None,
    project_root: Optional[Path] = None,
) -> Optional[dict]:
    """Resolve a single pattern ID through the cascade."""
    all_patterns = load_all_patterns(delphi_root, namespace, project_root)

    # Strip version suffix for flexible lookup: PAT-CORE-001 matches PAT-CORE-001-v1
    if pattern_id in all_patterns:
        entry = all_patterns[pattern_id]
        if entry.get("deprecated", False):
            dep_by = entry.get("deprecated_by", "unknown")
            print(
                f"WARNING: {pattern_id} is deprecated (replaced by {dep_by})",
                file=sys.stderr,
            )
        return entry

    # Try prefix match (without version)
    for pid, entry in all_patterns.items():
        if pid.rsplit("-v", 1)[0] == pattern_id.rsplit("-v", 1)[0]:
            if entry.get("deprecated", False):
                dep_by = entry.get("deprecated_by", "unknown")
                print(
                    f"WARNING: {pid} is deprecated (replaced by {dep_by})",
                    file=sys.stderr,
                )
            return entry

    return None


# ---------------------------------------------------------------------------
# TODO reference validation
# ---------------------------------------------------------------------------

_PATTERN_REF_RE = re.compile(r"\[PATTERN:\s*([\w-]+(?:-v\d+)?)\s*\]", re.IGNORECASE)


def extract_pattern_refs(todo_path: Path) -> list[str]:
    """Extract all [PATTERN: id] references from a TODO markdown file."""
    if not todo_path.exists():
        return []
    content = todo_path.read_text(encoding="utf-8")
    return _PATTERN_REF_RE.findall(content)


def validate_refs(
    todo_path: Path,
    delphi_root: Path,
    namespace: Optional[str] = None,
    project_root: Optional[Path] = None,
) -> list[dict]:
    """
    Validate all pattern references in a TODO file.
    Returns a list of violations (empty = all valid).
    """
    refs = extract_pattern_refs(todo_path)
    violations = []

    for ref_id in refs:
        result = resolve(ref_id, delphi_root, namespace, project_root)
        if result is None:
            violations.append({
                "type": "phantom_reference",
                "pattern_id": ref_id,
                "todo_path": str(todo_path),
                "message": f"Pattern '{ref_id}' referenced in TODO but not found in any authority level (local/stack/core).",
                "resolution_instruction": f"Either create the pattern or remove the reference from {todo_path.name}.",
            })
        elif result.get("deprecated", False):
            violations.append({
                "type": "deprecated_reference",
                "pattern_id": ref_id,
                "todo_path": str(todo_path),
                "message": f"Pattern '{ref_id}' is deprecated. Replaced by: {result.get('deprecated_by', 'unknown')}.",
                "resolution_instruction": f"Update reference in {todo_path.name} to use the replacement pattern.",
            })
        elif result.get("_overridden_by"):
            violations.append({
                "type": "overridden_reference",
                "pattern_id": ref_id,
                "todo_path": str(todo_path),
                "message": f"Pattern '{ref_id}' has been overridden by '{result['_overridden_by']}' at a higher-precedence level.",
                "resolution_instruction": f"Consider updating reference in {todo_path.name} to '{result['_overridden_by']}'.",
            })

    return violations


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="PACED Pattern Resolver")
    parser.add_argument("--id", help="Resolve a single pattern by ID")
    parser.add_argument("--validate-refs", action="store_true", help="Validate pattern refs in a TODO")
    parser.add_argument("--todo", help="Path to TODO file (for --validate-refs)")
    parser.add_argument("--list", action="store_true", help="List all resolved patterns")
    parser.add_argument("--namespace", help="Stack namespace (e.g., laravel, flutter)")
    parser.add_argument("--project-root", help="Project root for local patterns")
    parser.add_argument("--delphi-root", help="Path to delphi-ai root (auto-detected if omitted)")
    args = parser.parse_args()

    # Resolve delphi root
    if args.delphi_root:
        delphi_root = Path(args.delphi_root)
    else:
        delphi_root = _find_delphi_root(Path.cwd())
        if not delphi_root:
            delphi_root = _find_delphi_root(Path(__file__).parent)
    if not delphi_root or not delphi_root.exists():
        print("ERROR: Cannot find delphi-ai root. Use --delphi-root.", file=sys.stderr)
        sys.exit(2)

    project_root = Path(args.project_root) if args.project_root else None

    if args.id:
        result = resolve(args.id, delphi_root, args.namespace, project_root)
        if result:
            print(json.dumps(result, indent=2))
        else:
            print(f"ERROR: Pattern '{args.id}' not found in any authority level.", file=sys.stderr)
            sys.exit(1)

    elif args.validate_refs:
        if not args.todo:
            print("ERROR: --todo is required with --validate-refs", file=sys.stderr)
            sys.exit(2)
        violations = validate_refs(Path(args.todo), delphi_root, args.namespace, project_root)
        if violations:
            print(json.dumps(violations, indent=2))
            sys.exit(1)
        else:
            print("OK: All pattern references are valid.")

    elif args.list:
        all_patterns = load_all_patterns(delphi_root, args.namespace, project_root)
        for pid, entry in sorted(all_patterns.items()):
            status = ""
            if entry.get("deprecated"):
                status = " [DEPRECATED]"
            elif entry.get("_overridden_by"):
                status = f" [OVERRIDDEN by {entry['_overridden_by']}]"
            print(f"  {pid}: {entry.get('title', '?')} ({entry.get('_resolved_from', '?')}){status}")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
