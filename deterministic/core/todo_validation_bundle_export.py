#!/usr/bin/env python3
"""Export deterministic validation records from a tactical TODO markdown file."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


QUALIFIER_SPLIT_RE = re.compile(r"[+,/|]")


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def clean_value(raw: str) -> str:
    value = raw.strip()
    while len(value) >= 2 and value[0] == value[-1] and value[0] in {"`", '"', "'"}:
        value = value[1:-1].strip()
    return value or "missing"


def is_placeholder(value: str) -> bool:
    stripped = value.strip()
    return stripped in {"missing", "n/a", ""} or (stripped.startswith("<") and stripped.endswith(">"))


def find_section_start(lines: list[str], heading_prefix: str) -> int | None:
    for index, line in enumerate(lines):
        if line.strip().startswith(heading_prefix):
            return index + 1
    return None


def extract_field(lines: list[str], label: str) -> str:
    prefix = f"- **{label}:**"
    for line in lines:
        if line.startswith(prefix):
            return clean_value(line[len(prefix) :])
    return "missing"


def extract_field_in_section(lines: list[str], heading_prefix: str, label: str) -> str:
    start = find_section_start(lines, heading_prefix)
    if start is None:
        return "missing"

    prefix = f"- **{label}:**"
    for line in lines[start:]:
        stripped = line.strip()
        if stripped.startswith("## ") and not stripped.startswith(heading_prefix):
            break
        if stripped.startswith(prefix):
            return clean_value(stripped[len(prefix) :])
    return "missing"


def section_present(lines: list[str], heading_prefix: str) -> bool:
    return find_section_start(lines, heading_prefix) is not None


def parse_qualifiers(raw: str) -> tuple[list[str], list[str]]:
    canonical_forms = {"none", "Provisional", "Blocked", "Provisional+Blocked"}
    if is_placeholder(raw):
        return [], []
    if raw in canonical_forms:
        if raw == "none":
            return [], []
        return [part for part in QUALIFIER_SPLIT_RE.split(raw) if part], []

    values = []
    invalid = []
    for part in QUALIFIER_SPLIT_RE.split(raw):
        cleaned = clean_value(part)
        if cleaned in {"Provisional", "Blocked"} and cleaned not in values:
            values.append(cleaned)
        else:
            invalid.append(cleaned)
    if raw not in canonical_forms and raw not in invalid:
        invalid.append(raw)
    return values, invalid


def classify_artifact_state(todo_path: Path) -> str:
    normalized = str(todo_path).replace("\\", "/")
    if "/todos/active/" in normalized:
        return "active"
    if "/todos/completed/" in normalized:
        return "completed"
    if "/todos/ephemeral/" in normalized:
        return "ephemeral"
    return "unknown"


def infer_artifact_type(lines: list[str]) -> str:
    explicit = extract_field(lines, "Artifact type")
    if explicit in {"tactical_execution_contract", "capped_no_code_ledger"}:
        return explicit

    code_touch_boundary = extract_field(lines, "Code-touch boundary")
    if code_touch_boundary == "no code":
        return "capped_no_code_ledger"

    if section_present(lines, "## Contract Boundary"):
        return "tactical_execution_contract"

    return "unknown"


def export_gate(lines: list[str], gate_id: str, heading_prefix: str, decision_label: str, status_label: str) -> dict:
    evidence = extract_field_in_section(lines, heading_prefix, "Evidence / reference")
    waiver = extract_field_in_section(lines, heading_prefix, "Waiver authority / reference (required if waived)")
    decision = extract_field_in_section(lines, heading_prefix, decision_label)
    status = extract_field_in_section(lines, heading_prefix, status_label)
    return {
        "gate_id": gate_id,
        "section_present": section_present(lines, heading_prefix),
        "decision": decision,
        "status": status,
        "evidence_reference": evidence,
        "waiver_reference": waiver,
        "decision_present": not is_placeholder(decision),
        "status_present": not is_placeholder(status),
        "evidence_present": not is_placeholder(evidence),
        "waiver_present": not is_placeholder(waiver)
    }


def build_bundle(todo_path: Path) -> dict:
    lines = read_lines(todo_path)
    raw_qualifiers = extract_field(lines, "Qualifiers")
    qualifiers, invalid_qualifiers = parse_qualifiers(raw_qualifiers)

    blocker = extract_field_in_section(lines, "## Blocker Notes", "Blocker")
    why_blocked_now = extract_field_in_section(lines, "## Blocker Notes", "Why blocked now")
    what_unblocks_it = extract_field_in_section(lines, "## Blocker Notes", "What unblocks it")
    owner_source = extract_field_in_section(lines, "## Blocker Notes", "Owner / source")
    last_confirmed_truth = extract_field_in_section(lines, "## Blocker Notes", "Last confirmed truth")
    blocker_present = not all(
        is_placeholder(value)
        for value in [blocker, why_blocked_now, what_unblocks_it, owner_source, last_confirmed_truth]
    )

    missing_for_production_ready = extract_field_in_section(lines, "## Provisional Notes", "Missing for production-ready")
    revisit_criteria = extract_field_in_section(lines, "## Provisional Notes", "Revisit criteria")
    dependencies_unblocked = extract_field_in_section(lines, "## Provisional Notes", "Dependencies unblocked")
    provisional_present = not all(
        is_placeholder(value)
        for value in [missing_for_production_ready, revisit_criteria, dependencies_unblocked]
    )

    return {
        "schema_version": "todo-validation-bundle-v1",
        "todo_path": str(todo_path),
        "artifact_type": infer_artifact_type(lines),
        "artifact_state": classify_artifact_state(todo_path),
        "delivery_status": {
            "stage": extract_field(lines, "Current delivery stage"),
            "raw_qualifiers": raw_qualifiers,
            "qualifiers": qualifiers,
            "invalid_qualifiers": invalid_qualifiers,
            "next_exact_step": extract_field(lines, "Next exact step")
        },
        "blocker_record": {
            "required": "Blocked" in qualifiers,
            "present": blocker_present,
            "blocker": blocker,
            "why_blocked_now": why_blocked_now,
            "what_unblocks_it": what_unblocks_it,
            "owner_source": owner_source,
            "last_confirmed_truth": last_confirmed_truth
        },
        "provisional_record": {
            "required": "Provisional" in qualifiers,
            "present": provisional_present,
            "missing_for_production_ready": missing_for_production_ready,
            "revisit_criteria": revisit_criteria,
            "dependencies_unblocked": dependencies_unblocked
        },
        "gates": {
            "critique": export_gate(
                lines,
                "critique",
                "## Independent No-Context Critique Gate",
                "Critique decision",
                "Critique status"
            ),
            "test_quality_audit": export_gate(
                lines,
                "test_quality_audit",
                "## Independent Test Quality Audit Gate",
                "Audit decision",
                "Audit status"
            ),
            "final_review": export_gate(
                lines,
                "final_review",
                "## Independent No-Context Final Review Gate",
                "Final review decision",
                "Final review status"
            )
        }
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export a machine-checkable validation bundle from a tactical TODO.")
    parser.add_argument("--todo", required=True, help="Path to the TODO markdown file.")
    parser.add_argument("--output", help="Write JSON bundle to this path. Defaults to stdout.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    bundle = build_bundle(Path(args.todo).resolve())
    rendered = json.dumps(bundle, indent=2) + "\n"
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
