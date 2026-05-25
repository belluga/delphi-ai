#!/usr/bin/env python3
"""Compatibility bridge for the canonical TODO completion guard.

The authoritative guard lives at ``tools/todo_completion_guard.py``. This path is
kept so older deterministic-surface links keep working while callers migrate.
"""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


def translated_args(argv: list[str]) -> list[str]:
    translated: list[str] = []
    idx = 0
    while idx < len(argv):
        arg = argv[idx]
        if arg == "--todo":
            if idx + 1 >= len(argv):
                raise SystemExit("--todo requires a path")
            translated.append(argv[idx + 1])
            idx += 2
            continue
        translated.append(arg)
        idx += 1
    return translated


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    canonical = repo_root / "tools" / "todo_completion_guard.py"
    if not canonical.is_file():
        raise SystemExit(f"canonical TODO completion guard not found: {canonical}")
    sys.path.insert(0, str(canonical.parent))
    sys.argv = [str(canonical), *translated_args(sys.argv[1:])]
    runpy.run_path(str(canonical), run_name="__main__")


if __name__ == "__main__":
    main()
