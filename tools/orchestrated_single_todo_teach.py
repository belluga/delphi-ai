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
    opt_out = args.metrics_opt_out_reference
    opt_out_section = "## User Metrics Opt-Out" in todo_text
    valid_opt_out = bool(
        opt_out
        and opt_out_section
        and opt_out.startswith("user-approved:")
        and opt_out in todo_text
        and re.search(r"\*\*Status:\*\*\s*approved", todo_text)
    )
    if opt_out and not valid_opt_out:
        failures.append({"code": "PRIMARY-GOAL-OPTOUT", "reason": "metrics opt-out must be an explicit user-approved reference recorded in the exact TODO"})
    if args.primary_goal_state != "active" and not valid_opt_out:
        failures.append({"code": "PRIMARY-GOAL", "reason": "primary orchestrator must hold and report an active Goal before execution, or provide a valid exact-TODO user metrics opt-out"})
    if not args.primary_goal_report or args.primary_goal_report == "n/a":
        failures.append({"code": "PRIMARY-GOAL-REPORT", "reason": "primary orchestrator must report its Goal state"})
    elif args.primary_goal_state == "active" and not args.primary_goal_report.startswith("active:"):
        failures.append({"code": "PRIMARY-GOAL-REPORT", "reason": "active primary Goal report must identify the active state"})
    elif args.primary_goal_state == "absent" and valid_opt_out and not args.primary_goal_report.startswith("metrics-opt-out:"):
        failures.append({"code": "PRIMARY-GOAL-REPORT", "reason": "opt-out primary report must identify the metrics opt-out state"})
    if args.writer_role != "routine-executor":
        failures.append({"code": "WRITER-ROLE", "reason": "routine-executor is the sole normal material writer"})
    if "/artifacts/tmp/todo-execution/" not in Path(args.raw_artifact_root).as_posix():
        failures.append({"code": "RAW-ARTIFACT-ROOT", "reason": "raw payloads must remain under the ignored TODO execution artifact root"})
    if args.token_total != "unavailable" and (not args.token_total.isdigit() or int(args.token_total) < 0):
        failures.append({"code": "TOKEN-TOTAL", "reason": "token totals must be provider-reported digits or unavailable"})
    telemetry = {
        "telemetry_kind": "goal_runtime",
        "model_family": args.model_family,
        "execution_kind": args.execution_kind,
        "goal_created": bool(args.goal_created),
        "goal_completed": bool(args.goal_completed),
        "tokensUsed": args.goal_tokens_used,
        "tokenBudget": args.goal_token_budget,
        "timeUsedSeconds": args.goal_time_used_seconds,
        "provider_receipt": False,
        "estimated": False,
        "session_total": False,
    }
    if args.execution_kind == "llm-subagent":
        if not args.model_family or args.model_family == "n/a":
            failures.append({"code": "GOAL-MODEL-FAMILY", "reason": "LLM subagent Goal telemetry requires the JSON-resolved model family"})
        if not args.goal_created or not args.goal_completed:
            failures.append({"code": "GOAL-LIFECYCLE", "reason": "LLM subagent must create a Goal and call update_goal complete"})
        if not args.goal_tokens_used.isdigit() or int(args.goal_tokens_used) < 0:
            failures.append({"code": "GOAL-TOKENS", "reason": "LLM subagent Goal tokensUsed must be a non-negative integer"})
        if args.goal_token_budget != "unbudgeted" and (not args.goal_token_budget.isdigit() or int(args.goal_token_budget) < 0):
            failures.append({"code": "GOAL-BUDGET", "reason": "LLM subagent Goal tokenBudget must be a non-negative integer or unbudgeted"})
        try:
            if float(args.goal_time_used_seconds) < 0:
                raise ValueError
        except ValueError:
            failures.append({"code": "GOAL-TIME", "reason": "LLM subagent Goal timeUsedSeconds must be a non-negative number"})
    else:
        if args.model_family != "n/a" or any(value != "n/a" for value in (args.goal_tokens_used, args.goal_token_budget, args.goal_time_used_seconds)):
            failures.append({"code": "DETERMINISTIC-TELEMETRY", "reason": "deterministic-only work must explicitly report n/a Goal telemetry"})
        if args.goal_created or args.goal_completed:
            failures.append({"code": "DETERMINISTIC-GOAL", "reason": "deterministic-only work must not claim an LLM Goal lifecycle"})
    return {
        "artifact_kind": "orchestrated_single_todo_teach",
        "overall_outcome": "go" if not failures else "blocked",
        "todo": str(todo),
        "changed_paths": args.changed_path,
        "goal_runtime_telemetry": telemetry,
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
    parser.add_argument("--primary-goal-state", required=True, choices=("active", "absent"))
    parser.add_argument("--primary-goal-report", required=True)
    parser.add_argument("--metrics-opt-out-reference")
    parser.add_argument("--writer-role", required=True)
    parser.add_argument("--raw-artifact-root", required=True)
    parser.add_argument("--token-total", required=True)
    parser.add_argument("--execution-kind", required=True, choices=("llm-subagent", "deterministic-only"))
    parser.add_argument("--model-family", required=True)
    parser.add_argument("--goal-created", action="store_true")
    parser.add_argument("--goal-completed", action="store_true")
    parser.add_argument("--goal-tokens-used", required=True)
    parser.add_argument("--goal-token-budget", required=True)
    parser.add_argument("--goal-time-used-seconds", required=True)
    args = parser.parse_args()
    result = assess(args)
    print("TEACH single-TODO assessment")
    print(f"Overall outcome: {result['overall_outcome']}")
    print(json.dumps(result["goal_runtime_telemetry"], sort_keys=True))
    for failure in result["failures"]:
        print(f"- [{failure['code']}] {failure['reason']}")
    return 0 if result["overall_outcome"] == "go" else 2


if __name__ == "__main__":
    raise SystemExit(main())
