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
import datetime
import ipaddress
import json
import re
import sys
import urllib.parse
from pathlib import Path
from typing import Any

from agent_role_routing_guard import DEFAULT_CONTRACT_PATH, evaluate_routing, load_contract
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
ROUTING_SECTION = "Agent Routing Preflight"
MODULE_DECISION_BASELINE_SECTION = "Module Decision Baseline Snapshot"
ARCHITECTURE_GOVERNANCE_SECTION = "Architecture Change Governance"
PATTERNS_TO_ENFORCE_SECTION = "Patterns To Enforce"
PROHIBITED_ANTI_PATTERNS_SECTION = "Prohibited Anti-Patterns"
ARCHITECTURE_PROTECTION_HARNESS_SECTION = "Architecture Protection Harness"
ARCHITECTURE_REVIEW_GATES_SECTION = "Architecture Review Gates"
IMPLEMENTATION_HORIZON_SECTION = "Implementation Horizon & Extensibility Intent"
CI_EQ_SECTION = "Local CI-Equivalent Suite Matrix"
PIPELINE_PREFLIGHT_SECTION = "Pipeline/Copilot P1/P2 Preflight"
RULE_SPIRIT_HUNT_SECTION = "Rule-Spirit Anti-Pattern Hunt"
PROMOTION_ROUTING_SECTION = "Promotion Finding Routing Ledger"
DELIVERY_GATE_SECTIONS = (
    (CI_EQ_SECTION, 6),
    (PIPELINE_PREFLIGHT_SECTION, 2),
    (RULE_SPIRIT_HUNT_SECTION, 2),
)
PASSING_STATUSES = {"passed", "waived", "n/a"}
ARCHITECTURE_REVIEW_SUCCESS_STATUSES = {"no material findings", "findings integrated"}
ROUTING_ALLOWED_OUTCOMES = {
    "go",
    "delegate-required",
    "review-required",
    "waiver-required",
    "blocked",
}
ROUTING_REQUIRED_SOURCE_TOKENS = (
    "effort-selection-method",
    "agent_role_routing_guard.py",
)
ARCHITECTURE_GOVERNANCE_APPLICABILITY = {"required", "not needed"}
ARCHITECTURE_HARNESS_TIMINGS = {
    "already-enforced",
    "implement-in-this-todo",
    "follow-up-approved",
    "manual-only-with-rationale",
}
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
PROMOTION_FOLLOWUP_CLASSIFICATION_TOKENS = (
    "follow-up",
    "follow up",
    "fast-follow",
    "fast follow",
    "hardening",
)
# CommonMark ATX headings permit at most three leading spaces; four spaces are
# an indented code block and must never establish TODO authority.
HEADING_RE = re.compile(r"^ {0,3}(#{1,6})\s+(.+?)\s*$")
P1_P2_RE = re.compile(r"\bP[12]\b", re.IGNORECASE)
P1_P2_CLEAN_NEGATIVE_RE = re.compile(
    r"^\s*(?:\bno\s+unresolved\s+p1\s*(?:/|\band\b|\bor\b)\s*p2(?:\s+findings?)?"
    r"|\bno\s+p1\s+(?:and|or)\s+(?:no\s+)?p2\s+(?:anti-pattern\s+)?findings?"
    r"|\bno\s+p1\s*/\s*p2\s+findings?"
    r"|\bno\s+p[12]\s+findings?)\s*$",
    re.IGNORECASE,
)
P1_P2_GROUP = r"p[12](?:\s*(?:/|and|or)\s*p[12])*"
P1_P2_CLEAN_DISPOSITION = r"(?:fixed|resolved|integrated|clean)"
P1_P2_CLEAN_CLAUSE_RE = re.compile(
    rf"^(?:{P1_P2_GROUP}\s*(?::|-)?\s*(?:(?:is|was|has\s+been|are|were|have\s+been)\s+)?{P1_P2_CLEAN_DISPOSITION}"
    rf"|{P1_P2_CLEAN_DISPOSITION}\s+{P1_P2_GROUP})$",
    re.IGNORECASE,
)
P1_P2_SAFE_CONTINUATION_RE = re.compile(
    r"^(?:fixed|resolved|integrated|clean|resolution|complete|"
    r"p(?:[3-9]|\d{2,})\s+remains?\s+open|"
    r"(?:regression\s+)?tests?\s+did\s+not\s+fail|"
    r"final\s+review\s+remains?\s+required)$",
    re.IGNORECASE,
)
WAIVER_PLACEHOLDER_RE = re.compile(r"\b(?:n/?a|none|tbd|pending|required|placeholder)\b", re.IGNORECASE)
WAIVER_APPROVAL_ANCHOR = (
    r"(?:\d{4}-\d{2}-\d{2}|[0-9a-f]{7,}|https?://\S+|"
    r"(?:issue|reference|ref)\s*(?:#|:)?\s*\d+)"
)
WAIVER_AFFIRMATIVE_APPROVAL_RE = re.compile(
    rf"^(?:(?:aprovado|approved)|(?:approval\s+(?:approved|confirmed|granted)|"
    rf"aprova[cç][aã]o\s+(?:confirmada|concedida)))\s+{WAIVER_APPROVAL_ANCHOR}$",
    re.IGNORECASE,
)
WAIVER_APPROVAL_DENIAL_RE = re.compile(
    r"\b(?:not\s+approved|not\s+(?:an?\s+)?approval|n[aã]o\s+aprovad[oa]|unapproved|disapproved|"
    r"approval\s+(?:not\s+(?:approved|granted)|denied|refused|rejected|revoked)|"
    r"(?:denied|refused|rejected|revoked)\s+(?:the\s+)?approval|"
    r"aprova[cç][aã]o\s+(?:negada|recusada|rejeitada|revogada)|"
    r"denied|refused|rejected|revoked|revocation|withdrawn|expired|"
    r"no\s+longer\s+valid|does\s+not\s+constitute\s+approval|rejection\s+of\s+approval)\b",
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
            title = match.group(2).strip()
            current = title
            occurrence = 2
            while current in sections:
                current = f"{title} (duplicate occurrence {occurrence})"
                occurrence += 1
            sections[current] = []
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def find_section(sections: dict[str, list[str]], section_name: str) -> list[str]:
    matches = find_matching_sections(sections, section_name)
    return matches[0][1] if matches else []


def find_matching_sections(
    sections: dict[str, list[str]], section_name: str
) -> list[tuple[str, list[str]]]:
    wanted = normalize(section_name)
    return [
        (title, lines)
        for title, lines in sections.items()
        if (normalized := normalize(title)) == wanted or normalized.startswith(f"{wanted} ")
    ]


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
    """Fail closed for P1/P2 evidence in canonical Findings and Resolution cells."""
    if len(row) < 6:
        return False
    cell_states: list[dict[str, set[str]]] = []
    active_severities: set[str] = set()
    for cell in row[4:6]:
        states = {"p1": set(), "p2": set()}
        for raw_clause in re.split(r"[;.,|\n]+", cell):
            clause = normalize(raw_clause)
            if not clause:
                continue
            severities = {value.lower() for value in P1_P2_RE.findall(clause)}
            if severities:
                active_severities = severities
                clean_clause = bool(
                    P1_P2_CLEAN_NEGATIVE_RE.fullmatch(clause)
                    or P1_P2_CLEAN_CLAUSE_RE.fullmatch(clause)
                )
                for severity in severities:
                    states[severity].add("clean" if clean_clause else "ambiguous")
            elif active_severities and not P1_P2_SAFE_CONTINUATION_RE.fullmatch(clause):
                for severity in active_severities:
                    states[severity].add("ambiguous")
        cell_states.append(states)

    findings, resolution = cell_states
    for severity in ("p1", "p2"):
        resolution_states = resolution[severity]
        if resolution_states:
            if resolution_states != {"clean"}:
                return True
            continue
        if findings[severity] and findings[severity] != {"clean"}:
            return True
    return False


def field_values(lines: list[str], label: str) -> list[str]:
    pattern = re.compile(rf"^\s*-\s+\*\*{re.escape(label)}:\*\*\s*(.*?)\s*$")
    return [strip_markup(match.group(1)) for line in lines if (match := pattern.match(line))]


def has_concrete_approver_identifier(value: str, field_label: str) -> bool:
    candidate = strip_markup(value).strip().lower()
    normalized = normalize(candidate)
    generic = {
        "actual approver", "anonymous", "approver", "approver name", "developer", "human",
        "human approver", "owner", "platform owner", "release manager", "reviewer", "user",
        "user approver", normalize(field_label),
    }
    if normalized in generic or WAIVER_PLACEHOLDER_RE.search(candidate):
        return False
    return bool(re.fullmatch(r"user-(?:[a-z][a-z0-9]*-)+0*[1-9]\d*", candidate))


def fully_decode_approval_reference(value: str) -> str | None:
    decoded = value
    for _ in range(3):
        next_value = urllib.parse.unquote(decoded)
        if next_value == decoded:
            return decoded
        decoded = next_value
    return decoded if urllib.parse.unquote(decoded) == decoded else None


def has_affirmative_approval(reference: str) -> bool:
    decoded = fully_decode_approval_reference(reference)
    if decoded is None:
        return False
    denial_search_text = re.sub(r"[_\W]+", " ", decoded)
    return bool(
        WAIVER_AFFIRMATIVE_APPROVAL_RE.search(reference)
        and not WAIVER_APPROVAL_DENIAL_RE.search(denial_search_text)
    )


def valid_approval_url(value: str) -> bool:
    try:
        decoded = fully_decode_approval_reference(value)
        if decoded is None:
            return False
        parsed = urllib.parse.urlsplit(decoded)
        hostname = parsed.hostname
        if parsed.scheme.lower() not in {"http", "https"} or not parsed.netloc or not hostname:
            return False
        parsed.port
        try:
            ipaddress.ip_address(hostname)
            return True
        except ValueError:
            labels = hostname.rstrip(".").split(".")
            return all(re.fullmatch(r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?", label, re.IGNORECASE) for label in labels)
    except ValueError:
        return False


def has_concrete_approval_anchor(reference: str) -> bool:
    if any(valid_approval_url(value) for value in re.findall(r"https?://\S+", reference, re.IGNORECASE)):
        return True
    if re.search(r"\b[0-9a-f]{7,}\b", reference, re.IGNORECASE):
        return True
    for value in re.findall(r"\b\d{4}-\d{2}-\d{2}\b", reference):
        try:
            datetime.date.fromisoformat(value)
            return True
        except ValueError:
            pass
    return any(
        int(value) > 0
        for value in re.findall(r"\b(?:issue|reference|ref)\s*(?:#|:)?\s*(\d+)\b", reference, re.IGNORECASE)
    )


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


def routing_preflight_required(sections: dict[str, list[str]]) -> bool:
    for row in table_rows(find_section(sections, RULES_SECTION)):
        if not row:
            continue
        source = normalize(row[0])
        if any(token in source for token in ROUTING_REQUIRED_SOURCE_TOKENS):
            return True
    return False


def validate_agent_routing_preflight(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    required = routing_preflight_required(sections)
    lines = find_section(sections, ROUTING_SECTION)
    context: dict[str, Any] = {
        "routing_preflight_required": required,
        "routing_preflight_section_present": bool(lines),
        "routing_preflight_outcome": "missing",
    }
    violations: list[dict[str, str]] = []

    if not required and not lines:
        return violations, context

    if not lines:
        violations.append(
            build_violation(
                "ROUTING-PREFLIGHT-MISSING",
                "No `Agent Routing Preflight` section was found even though the touched rules/workflows require routing resolution.",
                "Add the canonical routing preflight section and record the selected client, governed action, role, model, proof mode, and guard outcome before execution.",
                ROUTING_SECTION,
            )
        )
        return violations, context

    client = extract_field(lines, "Client surface")
    surface = extract_field(lines, "Current governed action")
    role = extract_field(lines, "Selected role")
    model = extract_field(lines, "Selected model")
    effort = extract_field(lines, "Selected effort")
    proof_mode = extract_field(lines, "Proof mode")
    exception_reason = extract_field(lines, "Exception reason")
    guard_outcome = extract_field(lines, "Guard outcome")
    waiver_reference = extract_field(lines, "Waiver / exception reference")
    execution_topology = extract_field(lines, "Execution topology")
    worktree_authorization = extract_field(lines, "Worktree authorization")
    worktree_authorization_reference = extract_field(lines, "Worktree authorization reference")

    required_fields = (
        ("Client surface", client),
        ("Current governed action", surface),
        ("Selected role", role),
        ("Proof mode", proof_mode),
        ("Guard outcome", guard_outcome),
    )
    for label, value in required_fields:
        if value_is_missing(value):
            violations.append(
                build_violation(
                    "ROUTING-PREFLIGHT-FIELD-MISSING",
                    f"`Agent Routing Preflight` is missing `{label}`.",
                    f"Fill `{label}` with the concrete routing declaration before execution.",
                    ROUTING_SECTION,
                )
            )

    normalized_outcome = normalize(guard_outcome or "")
    context["routing_preflight_outcome"] = normalized_outcome or "missing"
    if normalized_outcome and normalized_outcome not in ROUTING_ALLOWED_OUTCOMES:
        violations.append(
            build_violation(
                "ROUTING-PREFLIGHT-OUTCOME-INVALID",
                f"`Agent Routing Preflight` uses invalid guard outcome `{guard_outcome}`.",
                "Use one of: go, delegate-required, review-required, waiver-required, blocked.",
                ROUTING_SECTION,
            )
        )

    if violations:
        return violations, context

    try:
        contract = load_contract(DEFAULT_CONTRACT_PATH)
    except Exception as exc:  # pragma: no cover - defensive
        violations.append(
            build_violation(
                "ROUTING-CONTRACT-LOAD-FAILED",
                f"Unable to load the canonical routing contract: {exc}",
                "Repair config/agent_role_routing.json before trusting routing preflight evidence.",
                ROUTING_SECTION,
            )
        )
        return violations, context

    routing_result = evaluate_routing(
        contract=contract,
        client=strip_markup(client or ""),
        surface=strip_markup(surface or ""),
        role=strip_markup(role or ""),
        model=strip_markup(model or "") or None,
        review_kind=None,
        effort=strip_markup(effort or "") or None,
        proof_mode=strip_markup(proof_mode or ""),
        exception_reason=strip_markup(exception_reason or "") or None,
        waiver_reference=strip_markup(waiver_reference or "") or None,
        execution_topology=strip_markup(execution_topology or "") or None,
        worktree_authorization=strip_markup(worktree_authorization or "") or None,
        worktree_authorization_reference=strip_markup(worktree_authorization_reference or "") or None,
    )
    context["routing_preflight_outcome"] = routing_result["outcome"]

    if normalized_outcome != routing_result["outcome"]:
        violations.append(
            build_violation(
                "ROUTING-PREFLIGHT-OUTCOME-MISMATCH",
                f"`Agent Routing Preflight` records outcome `{guard_outcome}`, but the canonical guard evaluates to `{routing_result['outcome']}`.",
                "Refresh the preflight section so the recorded outcome matches the canonical routing guard result.",
                ROUTING_SECTION,
            )
        )

    if routing_result["outcome"] != "go":
        for violation in routing_result["violations"]:
            violations.append(
                build_violation(
                    f"ROUTING-{violation['code']}",
                    f"Agent routing preflight did not resolve to go: {violation['message']}",
                    violation["resolution"],
                    ROUTING_SECTION,
                )
            )

    return violations, context


def architecture_supersede_trigger(sections: dict[str, list[str]]) -> bool:
    rows = table_rows(find_section(sections, MODULE_DECISION_BASELINE_SECTION))
    for row in rows:
        if len(row) >= 3 and "supersede" in normalize(row[2]):
            return True
    return False


def validate_architecture_governance(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {
        "architecture_governance_section_present": False,
        "architecture_governance_required": False,
        "architecture_supersede_trigger": False,
    }
    violations: list[dict[str, str]] = []
    supersede_trigger = architecture_supersede_trigger(sections)
    context["architecture_supersede_trigger"] = supersede_trigger

    section_lines = find_section(sections, ARCHITECTURE_GOVERNANCE_SECTION)
    if not section_lines:
        if supersede_trigger:
            violations.append(
                build_violation(
                    "ARCHITECTURE-GOVERNANCE-MISSING",
                    "TODO intentionally supersedes module decisions but is missing `Architecture Change Governance`.",
                    "Add the architecture governance contract covering the retired deviation, target steady-state, required patterns, prohibited anti-patterns, and protection harness.",
                    ARCHITECTURE_GOVERNANCE_SECTION,
                )
            )
        return violations, context

    context["architecture_governance_section_present"] = True
    applicability = first_field(section_lines, ("Applicability (`required|not_needed`)", "Applicability"))
    normalized_applicability = normalize(applicability or "")

    if normalized_applicability not in ARCHITECTURE_GOVERNANCE_APPLICABILITY:
        violations.append(
            build_violation(
                "ARCHITECTURE-GOVERNANCE-APPLICABILITY-INVALID",
                "Architecture Change Governance applicability is missing or invalid.",
                "Set `Applicability` to `required` or `not_needed`.",
                ARCHITECTURE_GOVERNANCE_SECTION,
            )
        )
        return violations, context

    required = normalized_applicability == "required" or supersede_trigger
    context["architecture_governance_required"] = required

    if normalized_applicability == "not needed" and supersede_trigger:
        violations.append(
            build_violation(
                "ARCHITECTURE-GOVERNANCE-CONTRADICTION",
                "Architecture Change Governance says `not_needed` while the module baseline records an intentional supersede.",
                "Mark the section `required` and document the architecture correction package.",
                ARCHITECTURE_GOVERNANCE_SECTION,
            )
        )
        return violations, context

    if not required:
        return violations, context

    required_fields = (
        "Why this applies",
        "Deviation / debt being retired",
        "Target steady-state after closeout",
        "Temporary exceptions allowed",
        "Cutover / removal condition",
    )
    for label in required_fields:
        allow_na = label == "Temporary exceptions allowed"
        value = extract_field(section_lines, label)
        if value_is_missing(value, allow_na=allow_na):
            violations.append(
                build_violation(
                    "ARCHITECTURE-GOVERNANCE-FIELD-MISSING",
                    f"Architecture Change Governance field `{label}` is missing or still placeholder.",
                    f"Fill `{label}` with the concrete architecture-correction contract detail.",
                    ARCHITECTURE_GOVERNANCE_SECTION,
                )
            )

    pattern_rows = table_rows(find_section(sections, PATTERNS_TO_ENFORCE_SECTION))
    if not pattern_rows:
        violations.append(
            build_violation(
                "ARCHITECTURE-PATTERNS-MISSING",
                "Required architecture-correction TODO is missing `Patterns To Enforce` rows.",
                "Add at least one concrete pattern/decision row that must remain true after cutover.",
                PATTERNS_TO_ENFORCE_SECTION,
            )
        )
    for row in pattern_rows:
        if len(row) < 4:
            violations.append(
                build_violation(
                    "ARCHITECTURE-PATTERN-ROW-INCOMPLETE",
                    f"Patterns To Enforce row has fewer than four cells: {row_text(row)}",
                    "Use columns: Pattern / Decision, Source / ID, Scope, Why It Must Hold After Cutover.",
                    PATTERNS_TO_ENFORCE_SECTION,
                )
            )
            continue
        row_missing = [
            value_is_missing(row[0]),
            value_is_missing(row[1], allow_na=True),
            value_is_missing(row[2]),
            value_is_missing(row[3]),
        ]
        if any(row_missing):
            violations.append(
                build_violation(
                    "ARCHITECTURE-PATTERN-ROW-PLACEHOLDER",
                    f"Patterns To Enforce row contains missing or placeholder cells: {row_text(row)}",
                    "Replace placeholders with the concrete pattern, source, scope, and rationale.",
                    PATTERNS_TO_ENFORCE_SECTION,
                )
            )

    anti_pattern_rows = table_rows(find_section(sections, PROHIBITED_ANTI_PATTERNS_SECTION))
    if not anti_pattern_rows:
        violations.append(
            build_violation(
                "ARCHITECTURE-ANTI-PATTERNS-MISSING",
                "Required architecture-correction TODO is missing `Prohibited Anti-Patterns` rows.",
                "Add at least one concrete wrong-path row that becomes forbidden after cutover.",
                PROHIBITED_ANTI_PATTERNS_SECTION,
            )
        )
    for row in anti_pattern_rows:
        if len(row) < 4:
            violations.append(
                build_violation(
                    "ARCHITECTURE-ANTI-PATTERN-ROW-INCOMPLETE",
                    f"Prohibited Anti-Patterns row has fewer than four cells: {row_text(row)}",
                    "Use columns: Anti-Pattern / Wrong Path, Detection Signal, Why It Is Forbidden After Cutover, Exception Policy.",
                    PROHIBITED_ANTI_PATTERNS_SECTION,
                )
            )
            continue
        row_missing = [
            value_is_missing(row[0]),
            value_is_missing(row[1]),
            value_is_missing(row[2]),
            value_is_missing(row[3], allow_na=True),
        ]
        if any(row_missing):
            violations.append(
                build_violation(
                    "ARCHITECTURE-ANTI-PATTERN-ROW-PLACEHOLDER",
                    f"Prohibited Anti-Patterns row contains missing or placeholder cells: {row_text(row)}",
                    "Replace placeholders with the retired wrong path, detection signal, rationale, and exception policy.",
                    PROHIBITED_ANTI_PATTERNS_SECTION,
                )
            )

    harness_rows = table_rows(find_section(sections, ARCHITECTURE_PROTECTION_HARNESS_SECTION))
    if not harness_rows:
        violations.append(
            build_violation(
                "ARCHITECTURE-HARNESS-MISSING",
                "Required architecture-correction TODO is missing `Architecture Protection Harness` rows.",
                "Add the concrete lasting protection rows that will defend the corrected architecture from regression.",
                ARCHITECTURE_PROTECTION_HARNESS_SECTION,
            )
        )
    for row in harness_rows:
        if len(row) < 6:
            violations.append(
                build_violation(
                    "ARCHITECTURE-HARNESS-ROW-INCOMPLETE",
                    f"Architecture Protection Harness row has fewer than six cells: {row_text(row)}",
                    "Use columns: Harness Type, Surface, Command / Rule / Artifact, Regression It Must Catch, Adoption Timing, Evidence Plan / Follow-up.",
                    ARCHITECTURE_PROTECTION_HARNESS_SECTION,
                )
            )
            continue
        if any(value_is_missing(cell) for cell in row[:6]):
            violations.append(
                build_violation(
                    "ARCHITECTURE-HARNESS-ROW-PLACEHOLDER",
                    f"Architecture Protection Harness row contains missing or placeholder cells: {row_text(row)}",
                    "Replace placeholders with the real harness surface, command/rule, regression target, timing, and evidence/follow-up plan.",
                    ARCHITECTURE_PROTECTION_HARNESS_SECTION,
                )
            )
            continue
        timing = normalize(row[4])
        if timing not in ARCHITECTURE_HARNESS_TIMINGS:
            violations.append(
                build_violation(
                    "ARCHITECTURE-HARNESS-TIMING-INVALID",
                    f"Architecture Protection Harness row uses invalid adoption timing `{row[4]}`: {row_text(row)}",
                    "Use one of: already-enforced, implement-in-this-todo, follow-up-approved, manual-only-with-rationale.",
                    ARCHITECTURE_PROTECTION_HARNESS_SECTION,
                )
            )

    return violations, context


def validate_implementation_horizon(sections: dict[str, list[str]]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    """Validate the literal horizon truth table only when a TODO adopts it."""
    matches = find_matching_sections(sections, IMPLEMENTATION_HORIZON_SECTION)
    context: dict[str, Any] = {
        "implementation_horizon_present": bool(matches),
        "implementation_horizon_section_count": len(matches),
    }
    section_present = context["implementation_horizon_present"]
    if not section_present:
        return [], context  # Legacy approved TODOs retain their frozen authority.

    violations: list[dict[str, str]] = []
    if len(matches) > 1:
        violations.append(
            build_violation(
                "HORIZON-SECTION-DUPLICATE",
                "Implementation Horizon & Extensibility Intent appears more than once after normalized heading matching.",
                "Keep exactly one canonical Implementation Horizon section; remove normalized or suffixed duplicates.",
                IMPLEMENTATION_HORIZON_SECTION,
            )
        )
        return violations, context

    lines = matches[0][1]
    fields = {label: extract_field(lines, label) for label in (
        "Mode", "Current delivery", "Explicit future cases informing the design",
        "Anticipatory implementation authorized now", "Not authorized now", "Rationale",
    )}
    mode = strip_markup(fields["Mode"] or "").strip()
    if mode not in {"current-scope-only", "bounded-anticipatory-extensibility"}:
        violations.append(build_violation("HORIZON-MODE-INVALID", "Implementation Horizon `Mode` must be `current-scope-only` or `bounded-anticipatory-extensibility`.", "Use one literal mode from the TODO truth table.", IMPLEMENTATION_HORIZON_SECTION))
        return violations, context
    for label in ("Current delivery", "Not authorized now", "Rationale"):
        if value_is_missing(fields[label]):
            violations.append(build_violation("HORIZON-FIELD-MISSING", f"Implementation Horizon `{label}` is missing or placeholder.", "Fill every required literal truth-table field.", IMPLEMENTATION_HORIZON_SECTION))
    future_cases_raw = strip_markup(fields["Explicit future cases informing the design"] or "").strip()
    anticipatory_raw = strip_markup(fields["Anticipatory implementation authorized now"] or "").strip()
    future_cases = normalize(future_cases_raw)
    anticipatory = normalize(anticipatory_raw)
    if mode == "current-scope-only":
        if future_cases_raw != "none" and value_is_missing(fields["Explicit future cases informing the design"]):
            violations.append(build_violation("HORIZON-FUTURE-CASES-MISSING", "Current-scope-only horizon needs concrete future cases or literal `none`.", "Record a concrete informational list or `none`.", IMPLEMENTATION_HORIZON_SECTION))
        if anticipatory_raw != "none":
            violations.append(build_violation("HORIZON-ANTICIPATORY-MUST-BE-NONE", "Current-scope-only horizon requires `Anticipatory implementation authorized now: none`.", "Use literal `none`; present-contract abstractions remain allowed.", IMPLEMENTATION_HORIZON_SECTION))
    else:
        if value_is_missing(fields["Explicit future cases informing the design"]) or future_cases == "none":
            violations.append(build_violation("HORIZON-FUTURE-CASES-MISSING", "Bounded anticipatory horizon requires concrete future cases.", "Name the bounded future cases informing the authorized seam.", IMPLEMENTATION_HORIZON_SECTION))
        if value_is_missing(fields["Anticipatory implementation authorized now"]) or anticipatory == "none":
            violations.append(build_violation("HORIZON-ANTICIPATORY-SEAM-MISSING", "Bounded anticipatory horizon requires a concrete authorized seam.", "Name the bounded anticipatory implementation authorized now.", IMPLEMENTATION_HORIZON_SECTION))
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
            if section_name in {PIPELINE_PREFLIGHT_SECTION, RULE_SPIRIT_HUNT_SECTION} and len(row) != 6:
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-ROW-INCOMPLETE",
                        f"{section_name} row must use the canonical 6-cell shape: {row_text(row)}",
                        f"Use the canonical {section_name} table shape from the TODO template and escape literal pipes inside cells.",
                        section_name,
                    )
                )
                continue
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
            if section_name in {PIPELINE_PREFLIGHT_SECTION, RULE_SPIRIT_HUNT_SECTION} and row_has_unresolved_p1_p2(row):
                violations.append(
                    build_violation(
                        "DELIVERY-GATE-UNRESOLVED-P1-P2",
                        f"{section_name} row records an unresolved P1/P2 finding: {row_text(row)}",
                        "Fix or explicitly adjudicate the P1/P2 finding before delivery or promotion readiness claims.",
                        section_name,
                    )
                )

    return violations, context


def validate_architecture_review_gates(
    sections: dict[str, list[str]], *, architecture_required: bool, delivery_claim: bool, allow_waivers: bool
) -> tuple[list[dict[str, str]], dict[str, Any]]:
    context: dict[str, Any] = {"architecture_review_gates_required": architecture_required}
    violations: list[dict[str, str]] = []
    if not architecture_required:
        return violations, context

    lines = find_section(sections, ARCHITECTURE_REVIEW_GATES_SECTION)
    if not lines:
        return [build_violation("ARCHITECTURE-REVIEW-GATES-MISSING", "Required architecture TODO is missing Architecture Review Gates.", "Add the canonical Architecture Review Gates section and record both derived reviews.", ARCHITECTURE_REVIEW_GATES_SECTION)], context

    checks = [
        (
            "Architecture decision review",
            "Decision review status",
            "Decision review waiver approver",
            "Decision review waiver approval reference",
        )
    ]
    if delivery_claim:
        checks.append(
            (
                "Architecture adherence review",
                "Adherence review status",
                "Adherence review waiver approver",
                "Adherence review waiver approval reference",
            )
        )
    for decision_label, status_label, approver_label, reference_label in checks:
        decision = normalize(first_field(lines, (decision_label,)) or "")
        status = normalize(first_field(lines, (status_label,)) or "")
        if decision != "required":
            violations.append(build_violation("ARCHITECTURE-REVIEW-DECISION-MISMATCH", f"{decision_label} must be `required` when Architecture Change Governance is required.", "Record the guard-derived required decision in Architecture Review Gates.", ARCHITECTURE_REVIEW_GATES_SECTION))
        if status not in ARCHITECTURE_REVIEW_SUCCESS_STATUSES and status != "waived":
            violations.append(build_violation("ARCHITECTURE-REVIEW-STATUS-NOT-PASSING", f"{status_label} `{status or 'missing'}` does not satisfy the required architecture review.", "Run the review, resolve findings, or record an explicit human-approved waiver.", ARCHITECTURE_REVIEW_GATES_SECTION))
        if status == "waived":
            approvers = field_values(lines, approver_label)
            references = field_values(lines, reference_label)
            approver = approvers[0] if len(approvers) == 1 else ""
            reference = references[0] if len(references) == 1 else ""
            if (
                len(approvers) != 1
                or len(references) != 1
                or value_is_missing(approver)
                or not has_concrete_approver_identifier(approver, approver_label)
                or value_is_missing(reference)
                or WAIVER_PLACEHOLDER_RE.search(reference) is not None
                or not has_affirmative_approval(reference)
                or not has_concrete_approval_anchor(reference)
            ):
                violations.append(build_violation("ARCHITECTURE-REVIEW-WAIVER-UNAPPROVED", f"{status_label} is waived without dedicated concrete approver and approval-reference fields.", f"Record `{approver_label}` with a concrete approver and `{reference_label}` with approval language plus a date, SHA, URL, or issue/reference number.", ARCHITECTURE_REVIEW_GATES_SECTION))
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
        classification = normalize(row[2])
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
        if any(token in classification for token in PROMOTION_FOLLOWUP_CLASSIFICATION_TOKENS) and value_is_missing(reference):
            violations.append(
                build_violation(
                    "PROMOTION-FOLLOWUP-MISSING-REFERENCE",
                    f"Promotion routing row classifies a finding as follow-up/hardening but has no explicit follow-up reference: {row_text(row)}",
                    "Open or cite the explicit fast-follow/hardening TODO before claiming the finding is non-blocking for the current release.",
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

    for validator in (
        validate_approval,
        validate_rules_ingestion,
        validate_agent_routing_preflight,
        validate_architecture_governance,
        validate_implementation_horizon,
        validate_promotion_routing,
    ):
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
    architecture_review_violations, architecture_review_context = validate_architecture_review_gates(
        sections,
        architecture_required=bool(context.get("architecture_governance_required")),
        delivery_claim=delivery_claim,
        allow_waivers=allow_waivers,
    )
    violations.extend(architecture_review_violations)
    context.update(architecture_review_context)

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
