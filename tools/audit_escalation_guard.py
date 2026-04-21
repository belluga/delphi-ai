#!/usr/bin/env python3
"""Deterministically derive the minimum PACED audit floor from a tactical TODO."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

RULE_ID = "paced.audit-escalation.requirements"

REQUIRED_TRIGGERS = {
    "complexity": {"small", "medium", "big"},
    "blast_radius": {"local", "cross-module", "cross-stack"},
    "behavioral_change_or_bugfix": {"yes", "no"},
    "changes_public_contract": {"yes", "no"},
    "touches_auth_or_tenant": {"yes", "no"},
    "touches_runtime_or_infra": {"yes", "no"},
    "touches_tests": {"yes", "no"},
    "critical_user_journey": {"yes", "no"},
    "release_or_promotion_critical": {"yes", "no"},
    "high_severity_plan_review_issue": {"yes", "no"},
    "explicit_three_lane_request": {"yes", "no"},
}

TRIGGER_ORDER = list(REQUIRED_TRIGGERS.keys())
AUDIT_TRIGGER_HEADING = "## Audit Trigger Matrix"


def extract_heading_section(text: str, heading: str) -> str | None:
    pattern = re.compile(
        rf"^{re.escape(heading)}\s*$\n(?P<body>.*?)(?=^##\s|\Z)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    if not match:
        return None
    return match.group("body")


def parse_two_column_table(section: str) -> tuple[dict[str, str], list[str], list[str]]:
    rows: dict[str, str] = {}
    duplicates: list[str] = []
    unknown: list[str] = []

    def normalize_cell(value: str) -> str:
        value = value.strip().lower()
        if value.startswith("`") and value.endswith("`") and len(value) >= 2:
            value = value[1:-1].strip()
        return value

    for raw_line in section.splitlines():
        line = raw_line.strip()
        if not line.startswith("|") or line.count("|") < 3:
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 2:
            continue

        first = normalize_cell(cells[0])
        second = normalize_cell(cells[1])
        if first == "trigger" and second == "value":
            continue
        if set(first) == {"-"}:
            continue

        key = first
        value = second
        if key in rows:
            duplicates.append(key)
            continue
        rows[key] = value
        if key not in REQUIRED_TRIGGERS:
            unknown.append(key)

    return rows, duplicates, unknown


def extract_complexity_from_todo(text: str) -> str | None:
    section = extract_heading_section(text, "## Complexity")
    if not section:
        return None
    match = re.search(
        r"Level.*?:\s*`?<?(small|medium|big)>?`?",
        section,
        re.IGNORECASE,
    )
    if not match:
        return None
    return match.group(1).lower()


def detect_high_severity_issue(text: str) -> bool:
    return bool(
        re.search(
            r"Severity:\s*<?high>?|\*\*Severity:\*\*\s*<?high>?",
            text,
            re.IGNORECASE,
        )
    )


def yes(data: dict[str, str], key: str) -> bool:
    return data[key] == "yes"


def any_high_risk_signal(data: dict[str, str]) -> bool:
    return any(
        (
            data["complexity"] == "big",
            data["blast_radius"] != "local",
            yes(data, "behavioral_change_or_bugfix"),
            yes(data, "changes_public_contract"),
            yes(data, "touches_auth_or_tenant"),
            yes(data, "touches_runtime_or_infra"),
            yes(data, "critical_user_journey"),
            yes(data, "release_or_promotion_critical"),
            yes(data, "high_severity_plan_review_issue"),
        )
    )


def derive_decisions(data: dict[str, str]) -> dict[str, dict[str, object]]:
    high_risk = any_high_risk_signal(data)
    release_sensitive = yes(data, "release_or_promotion_critical")
    critical_journey = yes(data, "critical_user_journey")
    runtime_sensitive = yes(data, "touches_runtime_or_infra")
    auth_sensitive = yes(data, "touches_auth_or_tenant")
    public_contract = yes(data, "changes_public_contract")
    tests_touched = yes(data, "touches_tests")
    behavior_changed = yes(data, "behavioral_change_or_bugfix")
    high_issue = yes(data, "high_severity_plan_review_issue")
    explicit_three_lane = yes(data, "explicit_three_lane_request")
    cross_stack = data["blast_radius"] == "cross-stack"
    cross_module = data["blast_radius"] == "cross-module"

    critique_reason_codes = ["CRITIQUE-BASELINE-ALWAYS"]
    if high_risk:
        critique_reason_codes.append("CRITIQUE-EXPANDED-RISK-SIGNALS")

    test_quality_reason_codes: list[str] = []
    if tests_touched:
        test_quality_reason_codes.append("TQA-TESTS-TOUCHED")
    if behavior_changed:
        test_quality_reason_codes.append("TQA-BEHAVIOR-OR-BUGFIX")
    if public_contract:
        test_quality_reason_codes.append("TQA-PUBLIC-CONTRACT")
    if critical_journey:
        test_quality_reason_codes.append("TQA-CRITICAL-JOURNEY")
    if release_sensitive:
        test_quality_reason_codes.append("TQA-RELEASE-CRITICAL")

    final_review_reason_codes = ["FINAL-BASELINE-ALWAYS"]
    if high_risk:
        final_review_reason_codes.append("FINAL-EXPANDED-RISK-SIGNALS")

    triple_required = explicit_three_lane or (
        release_sensitive
        and any(
            (
                data["complexity"] == "big",
                cross_stack,
                critical_journey,
                runtime_sensitive,
                auth_sensitive,
                high_issue,
            )
        )
    )
    triple_recommended = (
        not triple_required
        and (
            (data["complexity"] == "big" and any((public_contract, critical_journey, runtime_sensitive, auth_sensitive)))
            or (release_sensitive and cross_module)
        )
    )
    if triple_required:
        triple_decision = "required"
        triple_reason_codes = ["TRIPLE-EXPLICIT" if explicit_three_lane else "TRIPLE-HIGH-CRITICALITY"]
    elif triple_recommended:
        triple_decision = "recommended"
        triple_reason_codes = ["TRIPLE-EXPANDED-CHALLENGE-RECOMMENDED"]
    else:
        triple_decision = "not_needed"
        triple_reason_codes = ["TRIPLE-NOT-TRIGGERED"]

    if test_quality_reason_codes:
        test_quality_decision = "required"
    elif data["complexity"] in {"medium", "big"}:
        test_quality_decision = "recommended"
        test_quality_reason_codes = ["TQA-MEDIUM-OR-BIG-DEFAULT"]
    else:
        test_quality_decision = "not_needed"
        test_quality_reason_codes = ["TQA-NOT-TRIGGERED"]

    if auth_sensitive:
        security_decision = "required"
        security_reason_codes = ["SEC-AUTH-OR-TENANT"]
    elif public_contract and critical_journey:
        security_decision = "recommended"
        security_reason_codes = ["SEC-PUBLIC-CONTRACT-CRITICAL-JOURNEY"]
    else:
        security_decision = "not_needed"
        security_reason_codes = ["SEC-NOT-TRIGGERED"]

    if runtime_sensitive:
        pcv_decision = "required"
        pcv_reason_codes = ["PCV-RUNTIME-OR-INFRA"]
    elif release_sensitive and any((critical_journey, cross_module, cross_stack, data["complexity"] == "big")):
        pcv_decision = "recommended"
        pcv_reason_codes = ["PCV-RELEASE-SENSITIVE"]
    else:
        pcv_decision = "not_needed"
        pcv_reason_codes = ["PCV-NOT-TRIGGERED"]

    if data["complexity"] in {"medium", "big"} or release_sensitive:
        verification_debt_decision = "required"
        verification_debt_reason_codes = ["VDA-MEDIUM-BIG-OR-RELEASE"]
    elif public_contract or tests_touched:
        verification_debt_decision = "recommended"
        verification_debt_reason_codes = ["VDA-CONTRACT-OR-TESTS"]
    else:
        verification_debt_decision = "not_needed"
        verification_debt_reason_codes = ["VDA-NOT-TRIGGERED"]

    return {
        "critique": {
            "decision": "required",
            "lifecycle_gate": "before_aprovado",
            "workflow": "wf-docker-independent-critique-method",
            "depth": "expanded" if high_risk else "baseline",
            "reason_codes": critique_reason_codes,
        },
        "test_quality_audit": {
            "decision": test_quality_decision,
            "lifecycle_gate": "before_completed",
            "workflow": "wf-docker-independent-test-quality-audit-method",
            "depth": "full" if any((tests_touched, public_contract, critical_journey, release_sensitive, high_issue)) else "focused",
            "reason_codes": test_quality_reason_codes,
        },
        "final_review": {
            "decision": "required",
            "lifecycle_gate": "before_completed",
            "workflow": "wf-docker-independent-final-review-method",
            "depth": "expanded" if high_risk else "baseline",
            "reason_codes": final_review_reason_codes,
        },
        "triple_review": {
            "decision": triple_decision,
            "lifecycle_gate": "before_completed",
            "workflow": "audit-protocol-triple-review",
            "replacement_policy": "additive_only",
            "reason_codes": triple_reason_codes,
        },
        "security_review": {
            "decision": security_decision,
            "lifecycle_gate": "before_completed",
            "workflow": "security-adversarial-review",
            "reason_codes": security_reason_codes,
        },
        "performance_concurrency": {
            "decision": pcv_decision,
            "lifecycle_gate": "per_pcv1_gate_deadlines",
            "workflow": "wf-docker-performance-concurrency-validation-method",
            "reason_codes": pcv_reason_codes,
        },
        "verification_debt": {
            "decision": verification_debt_decision,
            "lifecycle_gate": "before_completed",
            "workflow": "verification-debt-audit",
            "reason_codes": verification_debt_reason_codes,
        },
    }


def build_result(todo_path: Path, text: str) -> dict[str, object]:
    violations: list[dict[str, str]] = []
    section = extract_heading_section(text, AUDIT_TRIGGER_HEADING)
    if section is None:
        return {
            "blocked": True,
            "violations": [
                {
                    "code": "AUDIT-MATRIX-MISSING",
                    "message": "The TODO does not contain the required 'Audit Trigger Matrix' section.",
                    "resolution": "Add the 'Audit Trigger Matrix' section from `delphi-ai/templates/todo_template.md`, fill every required trigger with an exact enum value, then rerun the guard.",
                }
            ],
            "trigger_matrix": {},
            "decisions": {},
            "fingerprint": None,
        }

    matrix, duplicates, unknown = parse_two_column_table(section)

    for key in duplicates:
        violations.append(
            {
                "code": "AUDIT-MATRIX-DUPLICATE-ROW",
                "message": f"Trigger '{key}' appears more than once in the Audit Trigger Matrix.",
                "resolution": f"Keep exactly one row for '{key}' in the Audit Trigger Matrix and rerun the guard.",
            }
        )

    for key in unknown:
        violations.append(
            {
                "code": "AUDIT-MATRIX-UNKNOWN-TRIGGER",
                "message": f"Trigger '{key}' is not part of the canonical Audit Trigger Matrix.",
                "resolution": "Use only the canonical trigger names from `delphi-ai/templates/todo_template.md` or update the canonical template/rule/tooling together in the same Delphi change.",
            }
        )

    for key, allowed in REQUIRED_TRIGGERS.items():
        if key not in matrix:
            violations.append(
                {
                    "code": "AUDIT-MATRIX-MISSING-TRIGGER",
                    "message": f"Trigger '{key}' is missing from the Audit Trigger Matrix.",
                    "resolution": f"Add the '{key}' row with one of: {', '.join(sorted(allowed))}.",
                }
            )
            continue
        if matrix[key] not in allowed:
            violations.append(
                {
                    "code": "AUDIT-MATRIX-INVALID-VALUE",
                    "message": f"Trigger '{key}' has invalid value '{matrix[key]}'.",
                    "resolution": f"Change '{key}' to one of: {', '.join(sorted(allowed))}.",
                }
            )

    complexity_from_todo = extract_complexity_from_todo(text)
    if (
        complexity_from_todo
        and "complexity" in matrix
        and matrix["complexity"] in REQUIRED_TRIGGERS["complexity"]
        and matrix["complexity"] != complexity_from_todo
    ):
        violations.append(
            {
                "code": "AUDIT-MATRIX-COMPLEXITY-MISMATCH",
                "message": (
                    "Audit Trigger Matrix complexity does not match the TODO Complexity section "
                    f"('{matrix['complexity']}' vs '{complexity_from_todo}')."
                ),
                "resolution": "Make the Complexity section and Audit Trigger Matrix use the same `small|medium|big` value, then rerun the guard.",
            }
        )

    if detect_high_severity_issue(text) and matrix.get("high_severity_plan_review_issue") == "no":
        violations.append(
            {
                "code": "AUDIT-MATRIX-HIGH-SEVERITY-MISMATCH",
                "message": "The Plan Review Gate contains a high-severity issue, but `high_severity_plan_review_issue` is `no`.",
                "resolution": "Set `high_severity_plan_review_issue` to `yes` or remove/correct the high-severity issue card before rerunning the guard.",
            }
        )

    if violations:
        return {
            "blocked": True,
            "violations": violations,
            "trigger_matrix": matrix,
            "decisions": {},
            "fingerprint": None,
        }

    fingerprint = hashlib.sha256(
        json.dumps(matrix, sort_keys=True).encode("utf-8")
    ).hexdigest()[:12]
    decisions = derive_decisions(matrix)
    return {
        "blocked": False,
        "violations": [],
        "trigger_matrix": matrix,
        "decisions": decisions,
        "fingerprint": fingerprint,
        "todo_path": str(todo_path),
    }


def render_text(result: dict[str, object]) -> str:
    blocked = bool(result["blocked"])
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append(f"status: {'blocked' if blocked else 'ready'}")
    lines.append(
        "enforcement: "
        + ("stop_before_audit_decisions" if blocked else "audit_floor_declared")
    )
    lines.append(f"rule_id: {RULE_ID}")

    lines.append("violation:")
    violations: list[dict[str, str]] = result["violations"]  # type: ignore[assignment]
    if not violations:
        lines.append("  - none")
    else:
        for violation in violations:
            lines.append(f"  - [{violation['code']}] {violation['message']}")

    lines.append("resolution_prompt:")
    if blocked:
        for violation in violations:
            lines.append(f"  - {violation['resolution']}")
    else:
        lines.append("  - Record the derived decisions into the TODO sections for critique, security, performance/concurrency, verification debt, test-quality audit, and final review.")
        lines.append("  - Run the critique gate before `APROVADO`; do not treat the triple review as a replacement for critique.")
        lines.append("  - Do not downgrade any derived `required` decision. Manual escalation may be stricter, never looser, than this deterministic floor.")
        lines.append("  - Rerun this guard whenever trigger fields change after implementation, especially for tests, auth/tenant scope, runtime/infra scope, or release-critical scope.")

    lines.append("context:")
    trigger_matrix: dict[str, str] = result["trigger_matrix"]  # type: ignore[assignment]
    if not trigger_matrix:
        lines.append("  trigger_matrix: missing")
    else:
        if result.get("todo_path"):
            lines.append(f"  todo_path: {result['todo_path']}")
        if result.get("fingerprint"):
            lines.append(f"  trigger_matrix_fingerprint: {result['fingerprint']}")
        for key in TRIGGER_ORDER:
            if key in trigger_matrix:
                lines.append(f"  trigger.{key}: {trigger_matrix[key]}")

    decisions: dict[str, dict[str, object]] = result["decisions"]  # type: ignore[assignment]
    for key, decision in decisions.items():
        decision_bits = [
            f"decision={decision['decision']}",
            f"gate={decision['lifecycle_gate']}",
            f"workflow={decision['workflow']}",
        ]
        if "depth" in decision:
            decision_bits.append(f"depth={decision['depth']}")
        if "replacement_policy" in decision:
            decision_bits.append(f"replacement_policy={decision['replacement_policy']}")
        lines.append(f"  audit.{key}: {'; '.join(decision_bits)}")
        reason_codes = ", ".join(decision["reason_codes"])  # type: ignore[index]
        lines.append(f"  audit.{key}.reason_codes: {reason_codes}")

    lines.append("")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines) + "\n"


def render_json(result: dict[str, object]) -> str:
    payload = {
        "schema_version": "audit-escalation-guard-v1",
        "artifact_kind": "audit_escalation_decision",
        "rule_id": RULE_ID,
        "outcome": "no-go" if result["blocked"] else "go",
        "blocked": result["blocked"],
        "todo_path": result.get("todo_path"),
        "trigger_matrix_fingerprint": result.get("fingerprint"),
        "trigger_matrix": result["trigger_matrix"],
        "decisions": result["decisions"],
        "violations": result["violations"],
    }
    return json.dumps(payload, indent=2) + "\n"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Deterministically derive the minimum PACED audit floor from a tactical TODO."
    )
    parser.add_argument("--todo", required=True, help="Path to the tactical TODO markdown file.")
    parser.add_argument(
        "--json-output",
        help="Optional path for a structured JSON copy of the derived audit decision.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    todo_path = Path(args.todo).resolve()
    if not todo_path.is_file():
        print(f"Error: TODO file not found: {todo_path}", file=sys.stderr)
        return 1

    text = todo_path.read_text(encoding="utf-8")
    result = build_result(todo_path, text)
    print(render_text(result), end="")

    if args.json_output:
        output_path = Path(args.json_output).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(render_json(result), encoding="utf-8")

    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
