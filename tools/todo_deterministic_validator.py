#!/usr/bin/env python3
"""Run deterministic structural validation for a tactical TODO."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator

import todo_validation_bundle_export as exporter


SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}
ALLOWED_GATE_DECISIONS = {"required", "recommended", "not_needed"}
ALLOWED_GATE_STATUSES = {"not_run", "running", "no_material_findings", "findings_integrated", "blocked", "waived"}
ALLOWED_DELIVERY_STAGES = {"Pending", "Local-Implemented", "Lane-Promoted", "Production-Ready"}
SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schemas" / "todo_validation_bundle.schema.json"


def is_missing(value: str) -> bool:
    return exporter.is_placeholder(value)


def add_issue(issues: list[dict], severity: str, code: str, message: str, field: str) -> None:
    issues.append(
        {
            "severity": severity,
            "code": code,
            "field": field,
            "message": message,
        }
    )


def schema_issues(bundle: dict) -> list[dict]:
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    validator = Draft202012Validator(schema)
    issues: list[dict] = []
    for error in validator.iter_errors(bundle):
        field = " -> ".join(str(part) for part in error.absolute_path) or "bundle"
        add_issue(issues, "error", "TODO-BUNDLE-SCHEMA", error.message, field)
    return issues


def validate_bundle(bundle: dict) -> list[dict]:
    issues: list[dict] = schema_issues(bundle)
    if bundle["artifact_type"] != "tactical_execution_contract":
        return issues

    delivery = bundle["delivery_status"]
    blocker = bundle["blocker_record"]
    provisional = bundle["provisional_record"]
    artifact_state = bundle["artifact_state"]

    if delivery["stage"] not in ALLOWED_DELIVERY_STAGES:
        add_issue(issues, "error", "TODO-STAGE-MISSING", "Delivery stage is missing or invalid.", "## Delivery Status Canon -> Current delivery stage")

    if delivery["invalid_qualifiers"]:
        bad = ", ".join(delivery["invalid_qualifiers"])
        add_issue(
            issues,
            "error",
            "TODO-QUALIFIERS-INVALID",
            f"Qualifiers must use canonical forms (`none`, `Provisional`, `Blocked`, `Provisional+Blocked`). Bad value(s): {bad}.",
            "## Delivery Status Canon -> Qualifiers",
        )

    if is_missing(delivery["next_exact_step"]):
        add_issue(issues, "error", "TODO-NEXT-STEP-MISSING", "Next exact step is required.", "## Delivery Status Canon -> Next exact step")

    if blocker["required"]:
        if not blocker["present"]:
            add_issue(issues, "error", "TODO-BLOCKER-RECORD-MISSING", "TODO is Blocked but Blocker Notes are missing.", "## Blocker Notes")
        label_map = {
            "blocker": "## Blocker Notes -> Blocker",
            "why_blocked_now": "## Blocker Notes -> Why blocked now",
            "what_unblocks_it": "## Blocker Notes -> What unblocks it",
            "owner_source": "## Blocker Notes -> Owner / source",
            "last_confirmed_truth": "## Blocker Notes -> Last confirmed truth"
        }
        for key in ["blocker", "why_blocked_now", "what_unblocks_it", "owner_source", "last_confirmed_truth"]:
            if is_missing(blocker[key]):
                add_issue(
                    issues,
                    "error",
                    f"TODO-BLOCKER-{key.upper()}-MISSING",
                    f"Blocked TODO is missing `{key}`.",
                    label_map[key],
                )

    if "Blocked" in delivery["qualifiers"] and (delivery["stage"] == "Production-Ready" or artifact_state == "completed"):
        add_issue(
            issues,
            "error",
            "TODO-BLOCKED-CLOSURE-INVALID",
            "`Blocked` cannot remain present when the TODO is `Production-Ready` or already in `completed/`.",
            "## Delivery Status Canon -> Qualifiers",
        )

    if provisional["required"]:
        if not provisional["present"]:
            add_issue(issues, "error", "TODO-PROVISIONAL-RECORD-MISSING", "TODO is Provisional but Provisional Notes are missing.", "## Provisional Notes")
        provisional_label_map = {
            "missing_for_production_ready": "## Provisional Notes -> Missing for production-ready",
            "revisit_criteria": "## Provisional Notes -> Revisit criteria",
            "dependencies_unblocked": "## Provisional Notes -> Dependencies unblocked",
        }
        for key in ["missing_for_production_ready", "revisit_criteria", "dependencies_unblocked"]:
            if is_missing(provisional[key]):
                add_issue(
                    issues,
                    "error",
                    f"TODO-PROVISIONAL-{key.upper()}-MISSING",
                    f"Provisional TODO is missing `{key}`.",
                    provisional_label_map[key],
                )

    for gate_id, gate in bundle["gates"].items():
        if not gate["section_present"]:
            add_issue(issues, "error", f"GATE-{gate_id.upper()}-SECTION-MISSING", f"{gate_id} section is missing.", f"gates.{gate_id}")
            continue

        if gate["decision"] not in ALLOWED_GATE_DECISIONS:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-DECISION-MISSING",
                f"{gate_id} decision is missing or invalid.",
                f"{gate_id} gate -> decision field",
            )

        if gate["status"] not in ALLOWED_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-STATUS-MISSING",
                f"{gate_id} status is missing or invalid.",
                f"{gate_id} gate -> status field",
            )
            continue

        if gate["status"] in {"blocked", "waived", "no_material_findings", "findings_integrated"} and not gate["evidence_present"]:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-EVIDENCE-MISSING",
                f"{gate_id} status `{gate['status']}` requires evidence/reference.",
                f"{gate_id} gate -> Evidence / reference",
            )

        if gate["status"] == "waived" and not gate["waiver_present"]:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-WAIVER-MISSING",
                f"{gate_id} status `waived` requires waiver authority/reference.",
                f"{gate_id} gate -> Waiver authority / reference",
            )

        if artifact_state == "completed" and gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-UNRESOLVED-FOR-CLOSURE",
                f"Completed TODO cannot leave required {gate_id} gate at `{gate['status']}`.",
                f"{gate_id} gate -> status field",
            )

        if delivery["stage"] == "Production-Ready" and gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"GATE-{gate_id.upper()}-UNRESOLVED-FOR-PRODUCTION",
                f"`Production-Ready` TODO cannot leave required {gate_id} gate at `{gate['status']}`.",
                f"{gate_id} gate -> status field",
            )

    return issues


def render_text(todo_path: Path, issues: list[dict]) -> str:
    lines = [f"Deterministic TODO validation for `{todo_path}`"]
    if not issues:
        lines.append("Result: PASS")
        return "\n".join(lines) + "\n"

    lines.append("Result: FAIL")
    for issue in issues:
        lines.append(f"- [{issue['severity']}] {issue['code']}: {issue['message']} ({issue['field']})")
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate structural TODO obligations with deterministic diagnostics.")
    parser.add_argument("--todo", required=True, help="Path to the TODO markdown file.")
    parser.add_argument("--bundle-output", help="Optional path to write the exported validation bundle.")
    parser.add_argument("--report-json", help="Optional path to write the diagnostic report as JSON.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    bundle = exporter.build_bundle(todo_path)
    issues = validate_bundle(bundle)

    if args.bundle_output:
        bundle_path = Path(args.bundle_output)
        bundle_path.parent.mkdir(parents=True, exist_ok=True)
        bundle_path.write_text(json.dumps(bundle, indent=2) + "\n", encoding="utf-8")

    if args.report_json:
        report_path = Path(args.report_json)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps({"todo_path": str(todo_path), "issues": issues}, indent=2) + "\n", encoding="utf-8")

    print(render_text(todo_path, issues), end="")
    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
