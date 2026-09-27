#!/usr/bin/env python3
"""Assess the fixed boundaries of an explicitly authorized micro-adjustment."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def assess(args: argparse.Namespace) -> dict[str, object]:
    failures: list[dict[str, str]] = []
    todo = Path(args.todo).resolve()
    if not todo.is_file() or "foundation_documentation/todos/active/" not in todo.as_posix():
        failures.append({"code": "TODO-SCOPE", "reason": "exact TODO must be an existing active Foundation TODO"})
    if not args.changed_path or len(args.changed_path) > 5:
        failures.append({"code": "BOUNDED-DIFF", "reason": "micro-adjustment must declare between 1 and 5 changed paths"})
    if args.writer_role != "routine-executor":
        failures.append({"code": "WRITER-ROLE", "reason": "routine-executor is the sole normal material writer"})
    for flag, code, reason in (
        (args.provider_fallback, "PROVIDER-FALLBACK", "automatic provider fallback is prohibited"),
        (args.runtime_introspection, "RUNTIME-INTROSPECTION", "runtime model introspection is out of scope"),
        (args.schema_migration, "SCHEMA-MIGRATION", "routing-schema migration is out of scope"),
    ):
        if flag != "prohibited":
            failures.append({"code": code, "reason": reason})
    if "/artifacts/tmp/todo-execution/" not in Path(args.raw_artifact_root).as_posix():
        failures.append({"code": "RAW-ARTIFACT-ROOT", "reason": "raw payloads must remain under the ignored TODO execution artifact root"})
    if args.token_total != "unavailable" and (not args.token_total.isdigit() or int(args.token_total) < 0):
        failures.append({"code": "TOKEN-TOTAL", "reason": "token totals must be provider-reported digits or unavailable"})
    return {
        "artifact_kind": "codex_micro_adjustment_teach",
        "overall_outcome": "go" if not failures else "blocked",
        "todo": str(todo),
        "changed_paths": args.changed_path,
        "failures": failures,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--todo", required=True)
    parser.add_argument("--changed-path", action="append", default=[])
    parser.add_argument("--writer-role", required=True)
    parser.add_argument("--provider-fallback", required=True, choices=("prohibited", "allowed"))
    parser.add_argument("--runtime-introspection", required=True, choices=("prohibited", "allowed"))
    parser.add_argument("--schema-migration", required=True, choices=("prohibited", "allowed"))
    parser.add_argument("--raw-artifact-root", required=True)
    parser.add_argument("--token-total", required=True)
    args = parser.parse_args()
    result = assess(args)
    print("TEACH micro-adjustment assessment")
    print(f"Overall outcome: {result['overall_outcome']}")
    for failure in result["failures"]:
        print(f"- [{failure['code']}] {failure['reason']}")
    return 0 if result["overall_outcome"] == "go" else 2


if __name__ == "__main__":
    raise SystemExit(main())
