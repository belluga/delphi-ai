#!/usr/bin/env python3
"""Deterministic authority/process guard for tactical TODO execution.

This companion guard validates evidence that should already exist in a tactical
TODO after approval and before implementation/delivery claims:

  - explicit approval evidence and approved scope;
  - touched-surface rule/workflow ingestion;
  - delivery-gate rows when a delivery claim is being made;
  - promotion finding routing when promotion blockers are recorded.

It intentionally does not scrape chat history and does not replace
todo_completion_guard.py. It emits a TEACH runtime response and exits with:

  0  GO: no authority/process blocker was found.
  2  NO-GO: deterministic authority/process blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from orchestration_plan_completion_guard import (
    build_violation,
    extract_field,
    is_placeholder,
    row_text,
    strip_markup,
    table_rows,
)


RULE_ID = "paced.todo.authority-process"
DELIVERY_STAGE_MARKERS = (
    "Local-Implemented",
    "Local-Validated",
    "Local-Complete",
    "Lane-Promoted",
    "Production-Ready",
    "Completed",
    "Complete",
)
APPROVAL_TOKENS = ("aprovado", "approved")
APPROVAL_SECTION_NAMES = ("Approval", "Approval Evidence")
RULES_SECTION = "Rules Acknowledgement / Ingestion"
CI_EQ_SECTION = "Local CI-Equivalent Suite Matrix"
PIPELINE_PREFLIGHT_SECTION = "Pipeline/Copilot P1/P2 Preflight"
RULE_SPIRIT_HUNT_SECTION = "Rule-Spirit Anti-Pattern Hunt"
PROMOTION_ROUTING_SECTION = "Promotion Finding Routing Ledger"
DELIVERY_GATE_SECTIONS = (
    (CI_EQ_SECTION, 4),
    (PIPELINE_PREFLIGHT_SECTION, 2),
    (RULE_SPIRIT_HUNT_SECTION, 2),
)
PASSING_STATUSES = {"passed", "waived", "n/a"}
PROMOTION_BLOCKING_STATUSES = {"open", "pending", "planned", "blocked", "unresolved", "failing"}
PROMOTION_SCOPE_CHANGE_TOKENS = (
    "split",
    "renewed",
    "renew approval",
    "renovar",
    "scope-change",
    "scope change",
    "mudanca de escopo",
    "mudança de escopo",
    "waiver",
    "exception",
    "excecao",
    "exceção",
)
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
P1_P2_RE = re.compile(r"\bP[12]\b", re.IGNORECASE)
UNRESOLVED_RE = re.compile(
    r"\b("
    r"unresolved|unresolved:|open|pending|blocked|blocker|failing|still open|"
    r"nao resolvido|não resolvido|sem resolucao|sem resolução|em aberto"
    r")\b",
    re.IGNORECASE,
)


def normalize(value: str) -> str:
    value = strip_markup(value)
    value = re.sub(r"`([^`]+)`", r"\1", value)
    value = re.sub(r"[*_#>|]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip().lower()


def extract_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines:
        match = HEADING_RE.match(line)
        if match:
            current = match.group(2).strip()
            sections.setdefault(current, [])
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def find_section(sections: dict[str, list[str]], section_name: str) -> list[str]:
    wanted = normalize(section_name)
    for title, lines in sections.items():
        normalized = normalize(title)
        if normalized == wanted or normalized.startswith(wanted):
            return lines
    return []


def first_field(lines: list[str], labels: tuple[str, ...]) -> str | None:
    for label in labels:
        value = extract_field(lines, label)
        if value is not None:
            return value
    return None


def value_is_missing(value: str | None, *, allow_na: bool = False) -> bool:
    if value is None:
        return True
    stripped = strip_markup(value)
    lowered = normalize(stripped)
    if allow_na and lowered in {"n/a", "na", "none", "not applicable", "nao aplicavel", "não aplicável"}:
        return False
    return is_placeholder(stripped) or lowered in {"n/a", "na", "none", "not applicable", "nao aplicavel", "não aplicável"}


def has_approval_token(lines: list[str]) -> bool:
    lowered = normalize("\n".join(lines))
    return any(token in lowered for token in APPROVAL_TOKENS)


def is_delivery_claim(todo_path: Path, stage: str | None, require_delivery_gates: bool) -> bool:
    if require_delivery_gates:
        return True
    normalized_stage = stage or ""
    if any(marker in normalized_stage for marker in DELIVERY_STAGE_MARKERS):
        return True
    normalized_path = todo_path.as_posix()
    return "/foundation_documentation/todos/completed/" in normalized_path or "/foundation_documentation/todos/promotion_lane/" in normalized_path


def row_has_unresolved_p1_p2(row: list[str]) -> bool:
    text = row_text(row)
    lowered = normalize(text)
    if "no p1" in lowered or "no p1 or p2" in lowered or "no p1/p2" in lowered or "sem p1" in lowered:
        return False
    return bool(P1_P2_RE.search(text) and UNRESOLVED_RE.search(text))


def row_has_approved_waiver(row: list[str]) -> bool:
    lowered = normalize(row_text(row))
    return "waived" in lowered and any(token in lowered for token in APPROVAL_TOKENS)


def validate_approval(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {
        "approval_section_present": False,
        "approval_scope_present": False,
    }
    violations: list[dict[str, str]] = []
    approval_lines: list[str] = []
    for name in APPROVAL_SECTION_NAMES:
        approval_lines = find_section(sections, name)
        if approval_lines:
            break

    if not approval_lines:
        violations.append(
            build_violation(
                "APPROVAL-SECTION-MISSING",
                "No Approval section was found for the tactical TODO.",
                "Add `## Approval` with approved-by evidence and exact approval scope before implementation.",
                "Approval",
            )
        )
        return violations, context

    context["approval_section_present"] = True
    approved_by = first_field(approval_lines, ("Approved by", "Approval evidence", "Approval reference"))
    approval_scope = first_field(approval_lines, ("Approval scope", "Execution authorized by approval", "Authorized scope"))

    if value_is_missing(approved_by):
        violations.append(
            build_violation(
                "APPROVAL-EVIDENCE-MISSING",
                "Approval evidence is missing or still placeholder.",
                "Record who approved the TODO, when, and the approval phrase/reference.",
                "Approval",
            )
        )
    if not has_approval_token(approval_lines):
        violations.append(
            build_violation(
                "APPROVAL-TOKEN-MISSING",
                "The Approval section does not contain an explicit approval token/evidence.",
                "Record the user's `APROVADO`/approved approval phrase in the TODO before implementation.",
                "Approval",
            )
        )
    if value_is_missing(approval_scope):
        violations.append(
            build_violation(
                "APPROVAL-SCOPE-MISSING",
                "Approval scope is missing or still placeholder.",
                "Record the exact implementation boundary authorized by approval.",
                "Approval",
            )
        )
    else:
        context["approval_scope_present"] = True

    return violations, context


def validate_rules_ingestion(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {"rules_ingestion_rows": 0}
    violations: list[dict[str, str]] = []
    lines = find_section(sections, RULES_SECTION)
    rows = table_rows(lines)
    context["rules_ingestion_rows"] = len(rows)

    if not rows:
        violations.append(
            build_violation(
                "RULE-INGESTION-MISSING",
                "No Rules Acknowledgement / Ingestion rows were found.",
                "After approval and before implementation, add rows for every governing touched-surface rule/workflow.",
                RULES_SECTION,
            )
        )
        return violations, context

    for row in rows:
        if len(row) < 5:
            violations.append(
                build_violation(
                    "RULE-INGESTION-ROW-INCOMPLETE",
                    f"Rule-ingestion row has fewer than five cells: {row_text(row)}",
                    "Use columns: Source, Why It Applies Now, Must Preserve, Must Avoid, Execution Impact.",
                    RULES_SECTION,
                )
            )
            continue
        if any(value_is_missing(cell) for cell in row[:5]):
            violations.append(
                build_violation(
                    "RULE-INGESTION-ROW-PLACEHOLDER",
                    f"Rule-ingestion row has missing or placeholder cells: {row_text(row)}",
                    "Replace placeholders with concrete rule/workflow source and execution impact.",
                    RULES_SECTION,
                )
            )
        source = normalize(row[0])
        if not any(token in source for token in ("rules/", "workflows/", "skills/", ".md", "skill.md")):
            violations.append(
                build_violation(
                    "RULE-INGESTION-SOURCE-WEAK",
                    f"Rule-ingestion source is not a concrete rule/workflow path: {row[0]}",
                    "Name the actual rule, workflow, or skill source that was loaded.",
                    RULES_SECTION,
                )
            )

    return violations, context


def validate_delivery_gates(
    sections: dict[str, list[str]],
    delivery_claim: bool,
    allow_waivers: bool,
) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {"delivery_gate_rows": {}}
    violations: list[dict[str, str]] = []
    if not delivery_claim:
        return violations, context

    for section_name, status_index in DELIVERY_GATE_SECTIONS:
        lines = find_section(sections, section_name)
        rows = table_rows(lines)
        context["delivery_gate_rows"][section_name] = len(rows)
        if not rows:
            violations.append(
                build_violation(
                    "DELIVERY-GATE-MISSING",
                    f"No {section_name} rows were found under a delivery claim.",
                    f"Add {section_name} rows with concrete execution evidence, or an explicit n/a row with rationale where truly not applicable.",
                    section_name,
                )
            )
            continue
        for row in rows:
            if len(row) <= status_index:
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-ROW-INCOMPLETE",
                        f"{section_name} row is missing the status cell: {row_text(row)}",
                        f"Use the canonical {section_name} table shape from the TODO template.",
                        section_name,
                    )
                )
                continue
            if any(value_is_missing(cell, allow_na=True) for cell in row):
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-ROW-PLACEHOLDER",
                        f"{section_name} row contains missing or placeholder cells: {row_text(row)}",
                        "Replace placeholders with concrete command/artifact evidence and rationale.",
                        section_name,
                    )
                )
            status = normalize(row[status_index])
            if status not in PASSING_STATUSES:
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-STATUS-NOT-PASSING",
                        f"{section_name} row status `{row[status_index]}` does not satisfy delivery: {row_text(row)}",
                        "Run the gate, fix the blocker, or record an approved waiver/n/a rationale before claiming delivery.",
                        section_name,
                    )
                )
            if status == "waived" and not allow_waivers and not row_has_approved_waiver(row):
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-WAIVER-UNAPPROVED",
                        f"{section_name} row is waived without explicit approval evidence: {row_text(row)}",
                        "Record human approval evidence for the waiver, or rerun with --allow-waivers only after external approval policy permits it.",
                        section_name,
                    )
                )
            if row_has_unresolved_p1_p2(row):
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-UNRESOLVED-P1-P2",
                        f"{section_name} row records an unresolved P1/P2 finding: {row_text(row)}",
                        "Fix or explicitly adjudicate the P1/P2 finding before delivery or promotion readiness claims.",
                        section_name,
                    )
                )

    return violations, context


def validate_promotion_routing(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {"promotion_routing_rows": 0}
    violations: list[dict[str, str]] = []
    lines = find_section(sections, PROMOTION_ROUTING_SECTION)
    rows = table_rows(lines)
    context["promotion_routing_rows"] = len(rows)
    if not rows:
        return violations, context

    for row in rows:
        if len(row) < 7:
            violations.append(
                build_violation(
                    "PROMOTION-ROUTING-ROW-INCOMPLETE",
                    f"Promotion routing row has fewer than seven cells: {row_text(row)}",
                    "Use columns: Finding ID, Severity, Classification, Routing Decision, Same TODO / Split Rationale, Status, Approval / Follow-up Reference.",
                    PROMOTION_ROUTING_SECTION,
                )
            )
            continue
        severity = normalize(row[1])
        routing = normalize(row[3])
        rationale = row[4]
        status = normalize(row[5])
        reference = row[6]

        if severity in {"n/a", "na", "none"}:
            continue
        if any(value_is_missing(cell) for cell in row[:6]):
            violations.append(
                build_violation(
                    "PROMOTION-ROUTING-ROW-PLACEHOLDER",
                    f"Promotion routing row has missing or placeholder cells: {row_text(row)}",
                    "Record concrete finding severity, classification, routing, rationale, and status.",
                    PROMOTION_ROUTING_SECTION,
                )
            )
        if P1_P2_RE.search(row[1]) and status in PROMOTION_BLOCKING_STATUSES:
            violations.append(
                build_violation(
                    "PROMOTION-P1-P2-UNRESOLVED",
                    f"Promotion routing row leaves a P1/P2 finding unresolved: {row_text(row)}",
                    "Keep the promotion blocked, fix/adjudicate the finding, then rerun affected promotion evidence before claiming completion.",
                    PROMOTION_ROUTING_SECTION,
                )
            )
        if P1_P2_RE.search(row[1]) and status == "deferred" and value_is_missing(reference):
            violations.append(
                build_violation(
                    "PROMOTION-P1-P2-DEFERRED-WITHOUT-AUTHORITY",
                    f"Promotion routing row defers a P1/P2 finding without approval/follow-up reference: {row_text(row)}",
                    "A P1/P2 can only be deferred through explicit human waiver/exception evidence with owner and follow-up.",
                    PROMOTION_ROUTING_SECTION,
                )
            )
        if any(token in routing for token in PROMOTION_SCOPE_CHANGE_TOKENS) and value_is_missing(reference):
            violations.append(
                build_violation(
                    "PROMOTION-SCOPE-CHANGE-MISSING-REFERENCE",
                    f"Promotion routing row requires split/renewed approval/exception but has no reference: {row_text(row)}",
                    "Record the renewed approval, split TODO, waiver, or follow-up reference before continuing promotion.",
                    PROMOTION_ROUTING_SECTION,
                )
            )
        if "same-todo" in routing and value_is_missing(rationale):
            violations.append(
                build_violation(
                    "PROMOTION-SAME-TODO-RATIONALE-MISSING",
                    f"Same-TODO promotion routing lacks rationale: {row_text(row)}",
                    "Explain why the remediation stays within the same approved objective, scenario, and risk conversation.",
                    PROMOTION_ROUTING_SECTION,
                )
            )

    return violations, context


def validate_todo(
    todo_path: Path,
    require_delivery_gates: bool,
    allow_waivers: bool,
) -> dict[str, Any]:
    context: dict[str, Any] = {
        "todo_path": str(todo_path),
        "current_delivery_stage": "missing",
        "delivery_claim": False,
        "require_delivery_gates": require_delivery_gates,
    }
    violations: list[dict[str, str]] = []

    if not todo_path.is_file():
        return {
            "blocked": True,
            "violations": [
                build_violation(
                    "TODO-NOT-FOUND",
                    f"TODO file does not exist: {todo_path}",
                    "Pass an existing tactical TODO path.",
                    "TODO File",
                )
            ],
            "context": context,
        }

    lines = todo_path.read_text(encoding="utf-8").splitlines()
    sections = extract_sections(lines)
    delivery_status_lines = find_section(sections, "Delivery Status Canon")
    stage = extract_field(delivery_status_lines, "Current delivery stage")
    context["current_delivery_stage"] = stage or "missing"
    delivery_claim = is_delivery_claim(todo_path, stage, require_delivery_gates)
    context["delivery_claim"] = delivery_claim

    for validator in (validate_approval, validate_rules_ingestion, validate_promotion_routing):
        section_violations, section_context = validator(sections)
        violations.extend(section_violations)
        context.update(section_context)

    delivery_violations, delivery_context = validate_delivery_gates(
        sections,
        delivery_claim=delivery_claim,
        allow_waivers=allow_waivers,
    )
    violations.extend(delivery_violations)
    context.update(delivery_context)

    return {
        "blocked": bool(violations),
        "violations": violations,
        "context": context,
    }


def format_response(result: dict[str, Any]) -> str:
    lines = [
        "TODO Authority Guard",
        f"Rule: {RULE_ID}",
        f"Overall outcome: {'no-go' if result['blocked'] else 'go'}",
        "",
        "Context:",
    ]
    for key in sorted(result["context"]):
        value = result["context"][key]
        if isinstance(value, dict):
            lines.append(f"  - {key}:")
            for inner_key in sorted(value):
                lines.append(f"    - {inner_key}: {value[inner_key]}")
        else:
            lines.append(f"  - {key}: {value}")

    lines.append("")
    lines.append("Violations:")
    if result["violations"]:
        for violation in result["violations"]:
            lines.append(f"  - [{violation['code']}] {violation['message']}")
            lines.append(f"    section: {violation['section']}")
            lines.append(f"    resolution: {violation['resolution']}")
    else:
        lines.append("  - none")

    return "\n".join(lines)


def write_json(path: Path, result: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("todo_path", help="Path to the tactical TODO markdown file.")
    parser.add_argument(
        "--require-delivery-gates",
        action="store_true",
        help="Require delivery-gate evidence even when the TODO does not yet claim a delivery stage.",
    )
    parser.add_argument(
        "--allow-waivers",
        action="store_true",
        help="Allow waived delivery rows without requiring inline approval evidence in the row.",
    )
    parser.add_argument("--json-output", help="Optional path for machine-readable JSON output.")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    result = validate_todo(
        Path(args.todo_path),
        require_delivery_gates=args.require_delivery_gates,
        allow_waivers=args.allow_waivers,
    )
    if args.json_output:
        write_json(Path(args.json_output), result)
    print(format_response(result))
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except BrokenPipeError:
        raise SystemExit(1)
