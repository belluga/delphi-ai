#!/usr/bin/env python3
"""Canonical PACED rule metadata for the deterministic TODO validator."""

from __future__ import annotations

from typing import Iterable


DEFAULT_OWNER = "paced"
DEFAULT_SOURCE_KIND = "validator"
DEFAULT_SOURCE_REF = "delphi-ai/tools/todo_deterministic_validator.py"
DEFAULT_LIFECYCLE_STATE = "adjusting"

GATE_IDS = ("critique", "test_quality_audit", "final_review")

EXACT_RULES = {
    "TODO-BUNDLE-SCHEMA": {
        "rule_id": "paced.todo.bundle.schema",
        "title": "Tactical TODO validation bundle must match schema",
        "resolution_contract": "Fix the markdown TODO or exporter assumptions so the derived bundle satisfies the canonical schema.",
    },
    "TODO-STAGE-MISSING": {
        "rule_id": "paced.todo.delivery-stage.present",
        "title": "Tactical TODO must declare a canonical delivery stage",
        "resolution_contract": "Set `Current delivery stage` to one canonical value: `Pending`, `Local-Implemented`, `Lane-Promoted`, or `Production-Ready`.",
    },
    "TODO-QUALIFIERS-INVALID": {
        "rule_id": "paced.todo.qualifiers.canonical",
        "title": "Tactical TODO qualifiers must use canonical values",
        "resolution_contract": "Set `Qualifiers` to `none`, `Provisional`, `Blocked`, or `Provisional+Blocked`.",
    },
    "TODO-NEXT-STEP-MISSING": {
        "rule_id": "paced.todo.next-exact-step.present",
        "title": "Tactical TODO must state the next exact step",
        "resolution_contract": "Fill `Next exact step` with one concrete immediate action.",
    },
    "TODO-BLOCKER-RECORD-MISSING": {
        "rule_id": "paced.todo.blocker-record.present",
        "title": "Blocked tactical TODOs must include blocker notes",
        "resolution_contract": "Add the full `Blocker Notes` block before claiming the TODO is `Blocked`.",
    },
    "TODO-BLOCKED-CLOSURE-INVALID": {
        "rule_id": "paced.todo.blocked-not-closed",
        "title": "Blocked tactical TODOs cannot be closed or production-ready",
        "resolution_contract": "Remove the `Blocked` qualifier only after the blocker is resolved, or reopen the delivery stage instead of claiming closure.",
    },
    "TODO-PROVISIONAL-RECORD-MISSING": {
        "rule_id": "paced.todo.provisional-record.present",
        "title": "Provisional tactical TODOs must explain the provisional state",
        "resolution_contract": "Add the full `Provisional Notes` block before claiming the TODO is `Provisional`.",
    },
}

GATE_RULE_PATTERNS = {
    "SECTION-MISSING": {
        "suffix": "section-present",
        "title": "Gate section must be present in the tactical TODO",
        "resolution_contract": "Add the full gate section to the TODO before using or validating that gate.",
    },
    "DECISION-MISSING": {
        "suffix": "decision-present",
        "title": "Gate decision must be present and canonical",
        "resolution_contract": "Fill the gate decision field with `required`, `recommended`, or `not_needed`.",
    },
    "STATUS-MISSING": {
        "suffix": "status-present",
        "title": "Gate status must be present and canonical",
        "resolution_contract": "Fill the gate status field with one canonical status value before claiming progress.",
    },
    "EVIDENCE-MISSING": {
        "suffix": "evidence-present",
        "title": "Gate evidence must be present when the gate status claims a resolved outcome",
        "resolution_contract": "Add the gate evidence/reference for the resolved outcome before claiming the gate is satisfied or waived.",
    },
    "WAIVER-MISSING": {
        "suffix": "waiver-present",
        "title": "Waived gates must include waiver authority/reference",
        "resolution_contract": "Fill the waiver authority/reference field before claiming the gate was waived.",
    },
    "UNRESOLVED-FOR-CLOSURE": {
        "suffix": "resolved-for-closure",
        "title": "Required gates must be resolved before TODO closure",
        "resolution_contract": "Move the gate to a satisfying status or record an explicit human waiver before marking the TODO completed.",
    },
    "UNRESOLVED-FOR-PRODUCTION": {
        "suffix": "resolved-for-production",
        "title": "Required gates must be resolved before production-ready status",
        "resolution_contract": "Move the gate to a satisfying status or record an explicit human waiver before marking the TODO production-ready.",
    },
}


def _gate_title_prefix(gate_id: str) -> str:
    return gate_id.replace("_", " ")


def metadata_for_issue(issue_code: str) -> dict:
    if issue_code in EXACT_RULES:
        rule = EXACT_RULES[issue_code]
        return {
            "rule_id": rule["rule_id"],
            "rule_level": "paced",
            "source_kind": DEFAULT_SOURCE_KIND,
            "source_ref": DEFAULT_SOURCE_REF,
            "title": rule["title"],
            "resolution_contract": rule["resolution_contract"],
            "owner": DEFAULT_OWNER,
            "lifecycle_state": DEFAULT_LIFECYCLE_STATE,
        }

    if issue_code.startswith("GATE-"):
        parts = issue_code.split("-")
        gate_id = parts[1].lower()
        kind = "-".join(parts[2:])
        if kind not in GATE_RULE_PATTERNS:
            raise KeyError(f"unknown gate rule kind for issue code: {issue_code}")
        pattern = GATE_RULE_PATTERNS[kind]
        gate_prefix = _gate_title_prefix(gate_id)
        return {
            "rule_id": f"paced.todo.gate.{gate_id}.{pattern['suffix']}",
            "rule_level": "paced",
            "source_kind": DEFAULT_SOURCE_KIND,
            "source_ref": DEFAULT_SOURCE_REF,
            "title": f"{gate_prefix} gate: {pattern['title']}",
            "resolution_contract": pattern["resolution_contract"],
            "owner": DEFAULT_OWNER,
            "lifecycle_state": DEFAULT_LIFECYCLE_STATE,
        }

    raise KeyError(f"unknown issue code: {issue_code}")


def all_catalog_entries() -> list[dict]:
    entries: list[dict] = []
    for code in EXACT_RULES:
        metadata = metadata_for_issue(code)
        entries.append(
            {
                "rule_id": metadata["rule_id"],
                "rule_level": metadata["rule_level"],
                "source_kind": metadata["source_kind"],
                "source_ref": metadata["source_ref"],
                "title": metadata["title"],
                "resolution_contract": metadata["resolution_contract"],
                "lifecycle_state": metadata["lifecycle_state"],
                "owner": metadata["owner"],
            }
        )
    for gate_id in GATE_IDS:
        for kind in GATE_RULE_PATTERNS:
            code = f"GATE-{gate_id.upper()}-{kind}"
            metadata = metadata_for_issue(code)
            entries.append(
                {
                    "rule_id": metadata["rule_id"],
                    "rule_level": metadata["rule_level"],
                    "source_kind": metadata["source_kind"],
                    "source_ref": metadata["source_ref"],
                    "title": metadata["title"],
                    "resolution_contract": metadata["resolution_contract"],
                    "lifecycle_state": metadata["lifecycle_state"],
                    "owner": metadata["owner"],
                }
            )
    return sorted(entries, key=lambda item: item["rule_id"])


def known_issue_codes() -> Iterable[str]:
    for code in EXACT_RULES:
        yield code
    for gate_id in GATE_IDS:
        for kind in GATE_RULE_PATTERNS:
            yield f"GATE-{gate_id.upper()}-{kind}"
