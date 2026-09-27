#!/usr/bin/env python3
"""Assess the fixed boundaries of an explicitly authorized single-TODO implementation."""

from __future__ import annotations

import argparse
import json
import fnmatch
import re
from pathlib import Path


def assess(args: argparse.Namespace) -> dict[str, object]:
    failures: list[dict[str, str]] = []
    todo = Path(args.todo).resolve()
    todo_text = todo.read_text(encoding="utf-8") if todo.is_file() else ""
    if not todo.is_file() or "foundation_documentation/todos/active/" not in todo.as_posix():
        failures.append({"code": "TODO-SCOPE", "reason": "canonical TODO must be an existing active Foundation TODO"})
    if "## Diff Expectation Contract" not in todo_text:
        failures.append({"code": "TODO-CONTRACT", "reason": "canonical TODO must declare its strict Diff Expectation Contract"})
    if not args.changed_path or not args.expected_path:
        failures.append({"code": "BOUNDED-DIFF", "reason": "implementation must declare changed paths and bounded expected paths"})
    if len(args.changed_path) > 32 or len(args.expected_path) > 64:
        failures.append({"code": "BOUNDED-DIFF", "reason": "changed and expected paths exceed the bounded intake limits"})
    for expected in args.expected_path:
        if expected not in todo_text:
            failures.append({"code": "TODO-AUTHORIZATION", "reason": f"expected path `{expected}` is not authorized by the exact TODO"})
    for changed in args.changed_path:
        if not any(fnmatch.fnmatch(changed, expected) for expected in args.expected_path):
            failures.append({"code": "PATH-SCOPE", "reason": f"changed path `{changed}` is outside the TODO's expected paths"})
    if not re.fullmatch(r"[^\s@]+@[0-9a-fA-F]{7,64}", args.baseline):
        failures.append({"code": "BASELINE", "reason": "a frozen baseline must use ref@commit form"})
    if args.approval_gate != "approved":
        failures.append({"code": "APPROVAL-GATE", "reason": "an approved tactical TODO is required before implementation"})
    if args.authority_gate != "canonical":
        failures.append({"code": "AUTHORITY-GATE", "reason": "the canonical routing/TODO authority gate must pass"})
    if args.writer_role != "routine-executor":
        failures.append({"code": "WRITER-ROLE", "reason": "routine-executor is the sole normal material writer"})
    if "/artifacts/tmp/todo-execution/" not in Path(args.raw_artifact_root).as_posix():
        failures.append({"code": "RAW-ARTIFACT-ROOT", "reason": "raw payloads must remain under the ignored TODO execution artifact root"})
    if args.token_total != "unavailable" and (not args.token_total.isdigit() or int(args.token_total) < 0):
        failures.append({"code": "TOKEN-TOTAL", "reason": "token totals must be provider-reported digits or unavailable"})
    return {
        "artifact_kind": "orchestrated_single_todo_teach",
        "overall_outcome": "go" if not failures else "blocked",
        "todo": str(todo),
        "changed_paths": args.changed_path,
        "failures": failures,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--todo", required=True)
    parser.add_argument("--changed-path", action="append", default=[])
    parser.add_argument("--expected-path", action="append", default=[])
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--approval-gate", required=True)
    parser.add_argument("--authority-gate", required=True)
    parser.add_argument("--writer-role", required=True)
    parser.add_argument("--raw-artifact-root", required=True)
    parser.add_argument("--token-total", required=True)
    args = parser.parse_args()
    result = assess(args)
    print("TEACH single-TODO assessment")
    print(f"Overall outcome: {result['overall_outcome']}")
    for failure in result["failures"]:
        print(f"- [{failure['code']}] {failure['reason']}")
    return 0 if result["overall_outcome"] == "go" else 2


if __name__ == "__main__":
    raise SystemExit(main())
