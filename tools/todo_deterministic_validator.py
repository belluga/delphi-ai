#!/usr/bin/env python3
"""Run deterministic structural validation for a tactical TODO."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator

import todo_validation_bundle_export as exporter
from paced_metrics_core import (
    build_rule_episode_id,
    build_rule_event_id,
    build_rule_fingerprint,
    canonical_todo_path as canonicalize_todo_path,
    load_jsonl,
    next_rule_episode_id,
    utc_now,
    validate_schema,
    write_json,
    append_jsonl,
)
from todo_validation_rules import metadata_for_issue


SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}
ALLOWED_GATE_DECISIONS = {"required", "recommended", "not_needed"}
ALLOWED_GATE_STATUSES = {"not_run", "running", "no_material_findings", "findings_integrated", "blocked", "waived"}
ALLOWED_DELIVERY_STAGES = {"Pending", "Local-Implemented", "Lane-Promoted", "Production-Ready"}
SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schemas" / "todo_validation_bundle.schema.json"


def is_missing(value: str) -> bool:
    return exporter.is_placeholder(value)


def build_issue(severity: str, code: str, message: str, field: str, todo_path: str) -> dict:
    metadata = metadata_for_issue(code)
    fingerprint = build_rule_fingerprint([code, field])
    return {
        "severity": severity,
        "code": code,
        "field": field,
        "message": message,
        "rule_id": metadata["rule_id"],
        "rule_level": metadata["rule_level"],
        "source_kind": metadata["source_kind"],
        "source_ref": metadata["source_ref"],
        "resolution_instruction": metadata["resolution_contract"],
        "fingerprint": fingerprint,
        "episode_id": build_rule_episode_id(metadata["rule_id"], todo_path, fingerprint),
    }


def add_issue(issues: list[dict], severity: str, code: str, message: str, field: str, todo_path: str) -> None:
    issues.append(build_issue(severity, code, message, field, todo_path))


def schema_issues(bundle: dict) -> list[dict]:
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    validator = Draft202012Validator(schema)
    issues: list[dict] = []
    todo_path = canonicalize_todo_path(str(Path(bundle["todo_path"]).resolve()), Path.cwd())
    for error in validator.iter_errors(bundle):
        field = " -> ".join(str(part) for part in error.absolute_path) or "bundle"
        add_issue(issues, "error", "TODO-BUNDLE-SCHEMA", error.message, field, todo_path)
    return issues


def validate_bundle(bundle: dict) -> list[dict]:
    issues: list[dict] = schema_issues(bundle)
    if bundle["artifact_type"] != "tactical_execution_contract":
        return issues

    todo_path = canonicalize_todo_path(str(Path(bundle["todo_path"]).resolve()), Path.cwd())
    delivery = bundle["delivery_status"]
    blocker = bundle["blocker_record"]
    provisional = bundle["provisional_record"]
    artifact_state = bundle["artifact_state"]

    if delivery["stage"] not in ALLOWED_DELIVERY_STAGES:
        add_issue(issues, "error", "TODO-STAGE-MISSING", "Delivery stage is missing or invalid.", "## Delivery Status Canon -> Current delivery stage", todo_path)

    if delivery["invalid_qualifiers"]:
        bad = ", ".join(delivery["invalid_qualifiers"])
        add_issue(
            issues,
            "error",
            "TODO-QUALIFIERS-INVALID",
            f"Qualifiers must use canonical forms (`none`, `Provisional`, `Blocked`, `Provisional+Blocked`). Bad value(s): {bad}.",
            "## Delivery Status Canon -> Qualifiers",
            todo_path,
        )

    if is_missing(delivery["next_exact_step"]):
        add_issue(issues, "error", "TODO-NEXT-STEP-MISSING", "Next exact step is required.", "## Delivery Status Canon -> Next exact step", todo_path)

    if blocker["required"]:
        if not blocker["present"]:
            add_issue(issues, "error", "TODO-BLOCKER-RECORD-MISSING", "TODO is Blocked but Blocker Notes are missing.", "## Blocker Notes", todo_path)
        label_map = {
            "blocker": "## Blocker Notes -> Blocker",
            "why_blocked_now": "## Blocker Notes -> Why blocked now",
            "what_unblocks_it": "## Blocker Notes -> What unblocks it",
            "owner_source": "## Blocker Notes -> Owner / source",
            "last_confirmed_truth": "## Blocker Notes -> Last confirmed truth",
        }
        for key in ["blocker", "why_blocked_now", "what_unblocks_it", "owner_source", "last_confirmed_truth"]:
            if is_missing(blocker[key]):
                add_issue(
                    issues,
                    "error",
                    "TODO-BLOCKER-RECORD-MISSING",
                    f"Blocked TODO is missing `{key}`.",
                    label_map[key],
                    todo_path,
                )

    if "Blocked" in delivery["qualifiers"] and (delivery["stage"] == "Production-Ready" or artifact_state == "completed"):
        add_issue(
            issues,
            "error",
            "TODO-BLOCKED-CLOSURE-INVALID",
            "`Blocked` cannot remain present when the TODO is `Production-Ready` or already in `completed/`.",
            "## Delivery Status Canon -> Qualifiers",
            todo_path,
        )

    if provisional["required"]:
        if not provisional["present"]:
            add_issue(issues, "error", "TODO-PROVISIONAL-RECORD-MISSING", "TODO is Provisional but Provisional Notes are missing.", "## Provisional Notes", todo_path)
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
                    "TODO-PROVISIONAL-RECORD-MISSING",
                    f"Provisional TODO is missing `{key}`.",
                    provisional_label_map[key],
                    todo_path,
                )

    for gate_id, gate in bundle["gates"].items():
        gate_prefix = f"GATE-{gate_id.upper()}"
        if not gate["section_present"]:
            add_issue(issues, "error", f"{gate_prefix}-SECTION-MISSING", f"{gate_id} section is missing.", f"gates.{gate_id}", todo_path)
            continue

        if gate["decision"] not in ALLOWED_GATE_DECISIONS:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-DECISION-MISSING",
                f"{gate_id} decision is missing or invalid.",
                f"{gate_id} gate -> decision field",
                todo_path,
            )

        if gate["status"] not in ALLOWED_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-STATUS-MISSING",
                f"{gate_id} status is missing or invalid.",
                f"{gate_id} gate -> status field",
                todo_path,
            )
            continue

        if gate["status"] in {"blocked", "waived", "no_material_findings", "findings_integrated"} and not gate["evidence_present"]:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-EVIDENCE-MISSING",
                f"{gate_id} status `{gate['status']}` requires evidence/reference.",
                f"{gate_id} gate -> Evidence / reference",
                todo_path,
            )

        if gate["status"] == "waived" and not gate["waiver_present"]:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-WAIVER-MISSING",
                f"{gate_id} status `waived` requires waiver authority/reference.",
                f"{gate_id} gate -> Waiver authority / reference",
                todo_path,
            )

        if artifact_state == "completed" and gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-UNRESOLVED-FOR-CLOSURE",
                f"Completed TODO cannot leave required {gate_id} gate at `{gate['status']}`.",
                f"{gate_id} gate -> status field",
                todo_path,
            )

        if delivery["stage"] == "Production-Ready" and gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            add_issue(
                issues,
                "error",
                f"{gate_prefix}-UNRESOLVED-FOR-PRODUCTION",
                f"`Production-Ready` TODO cannot leave required {gate_id} gate at `{gate['status']}`.",
                f"{gate_id} gate -> status field",
                todo_path,
            )

    return issues


def render_text(todo_path: Path, issues: list[dict]) -> str:
    lines = [f"Deterministic TODO validation for `{todo_path}`"]
    if not issues:
        lines.append("Result: PASS")
        return "\n".join(lines) + "\n"

    lines.append("Result: FAIL")
    for issue in issues:
        lines.append(
            f"- [{issue['severity']}] {issue['code']}: {issue['message']} ({issue['field']}) -> {issue['resolution_instruction']}"
        )
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate structural TODO obligations with deterministic diagnostics.")
    parser.add_argument("--todo", required=True, help="Path to the TODO markdown file.")
    parser.add_argument("--bundle-output", help="Optional path to write the exported validation bundle.")
    parser.add_argument("--report-json", help="Optional path to write the diagnostic report as JSON.")
    parser.add_argument("--events-jsonl", help="Optional path to append rule events as JSONL.")
    return parser.parse_args()


def emit_rule_events(events_path: Path, todo_path: str, issues: list[dict]) -> None:
    prior_events = load_jsonl(events_path)
    prior_open_episodes: dict[str, dict] = {}
    for event in prior_events:
        if event.get("todo_path") != todo_path:
            continue
        episode_id = event.get("episode_id")
        if not episode_id:
            continue
        if event["event_kind"] == "rule_block_observed":
            prior_open_episodes[episode_id] = event
        elif event["event_kind"] == "rule_episode_resolved":
            prior_open_episodes.pop(episode_id, None)
    current_issues: dict[str, dict] = {}
    timestamp = utc_now()

    for issue in issues:
        issue["episode_id"] = next_rule_episode_id(
            prior_events,
            issue["rule_id"],
            todo_path,
            issue["fingerprint"],
        )
        current_issues[issue["episode_id"]] = issue
        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": build_rule_event_id(
                "rule_block_observed",
                issue["rule_id"],
                todo_path,
                issue["fingerprint"],
                timestamp,
            ),
            "event_kind": "rule_block_observed",
            "timestamp": timestamp,
            "rule_id": issue["rule_id"],
            "rule_level": issue["rule_level"],
            "todo_path": todo_path,
            "episode_id": issue["episode_id"],
            "fingerprint": issue["fingerprint"],
            "source_kind": issue["source_kind"],
            "source_ref": issue["source_ref"],
            "issue_code": issue["code"],
            "field": issue["field"],
            "severity": issue["severity"],
            "message": issue["message"],
            "resolution_instruction": issue["resolution_instruction"],
        }
        validate_schema(payload, "rule_event.schema.json", "rule event")
        append_jsonl(events_path, payload)
        prior_events.append(payload)

    for episode_id, previous in prior_open_episodes.items():
        if episode_id in current_issues:
            continue
        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": build_rule_event_id(
                "rule_episode_resolved",
                previous["rule_id"],
                todo_path,
                previous["fingerprint"],
                timestamp,
            ),
            "event_kind": "rule_episode_resolved",
            "timestamp": timestamp,
            "rule_id": previous["rule_id"],
            "rule_level": previous["rule_level"],
            "todo_path": todo_path,
            "episode_id": episode_id,
            "fingerprint": previous["fingerprint"],
            "source_kind": previous.get("source_kind", "validator"),
            "source_ref": previous.get("source_ref", "delphi-ai/tools/todo_deterministic_validator.py"),
            "issue_code": previous.get("issue_code", ""),
            "field": previous.get("field", ""),
            "severity": previous.get("severity", "error"),
            "message": previous.get("message", ""),
            "resolution_instruction": previous.get("resolution_instruction", ""),
            "outcome": "true_positive",
            "reason": "Issue no longer present in deterministic TODO validator output.",
        }
        validate_schema(payload, "rule_event.schema.json", "rule event")
        append_jsonl(events_path, payload)
        prior_events.append(payload)


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    bundle = exporter.build_bundle(todo_path)
    issues = validate_bundle(bundle)

    report_path = Path(args.report_json).resolve() if args.report_json else None
    if args.bundle_output:
        write_json(Path(args.bundle_output).resolve(), bundle)

    report_payload = {
        "schema_version": "todo-validation-report-v1",
        "artifact_kind": "todo_validation_report",
        "todo_path": canonicalize_todo_path(str(todo_path.resolve()), Path.cwd()),
        "result": "FAIL" if issues else "PASS",
        "issues": [
            {
                "severity": issue["severity"],
                "code": issue["code"],
                "field": issue["field"],
                "message": issue["message"],
                "rule_id": issue["rule_id"],
                "rule_level": issue["rule_level"],
                "source_kind": issue["source_kind"],
                "source_ref": issue["source_ref"],
                "episode_id": issue["episode_id"],
                "fingerprint": issue["fingerprint"],
                "resolution_instruction": issue["resolution_instruction"],
            }
            for issue in issues
        ],
    }
    validate_schema(report_payload, "todo_validation_report.schema.json", "todo validation report")

    if args.events_jsonl:
        emit_rule_events(Path(args.events_jsonl).resolve(), report_payload["todo_path"], issues)
        report_payload["issues"] = [
            {
                **item,
                "episode_id": next(
                    issue["episode_id"]
                    for issue in issues
                    if issue["fingerprint"] == item["fingerprint"] and issue["rule_id"] == item["rule_id"]
                ),
            }
            for item in report_payload["issues"]
        ]

    if report_path:
        write_json(report_path, report_payload)

    print(render_text(todo_path, issues), end="")
    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
