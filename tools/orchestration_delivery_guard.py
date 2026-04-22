#!/usr/bin/env python3
"""Deterministic delivery guard for approved orchestration execution plans.

This guard validates execution evidence, not just plan shape. It is intended to
run before claiming local implementation or delivery completion for a
subagent/worktree orchestration wave.

Exit codes:
  0  GO: delivery evidence satisfies the approved plan.
  2  NO-GO: deterministic blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from orchestration_plan_completion_guard import (
    SPEC_MARKERS,
    TRACEABILITY_COLUMNS,
    build_violation,
    extract_sections,
    is_placeholder,
    marker_present,
    owner_names_orchestrator,
    row_has_runtime_ui_signal,
    row_text,
    section_has_content,
    table_rows,
    validate_plan,
)


RULE_ID = "paced.orchestration.delivery"
PASSED_STATUS = "passed"
WAIVED_STATUS = "waived"
RUNTIME_TERMS = (
    "web",
    "browser",
    "navegador",
    "device",
    "dispositivo",
    "runtime",
    "navigation",
    "navegacao",
    "navegação",
    "build",
    "playwright",
    "emulator",
    "simulator",
    "tunnel",
    "domain",
    "dominio",
    "domínio",
)
TRACEABILITY_RUNTIME_NA = {"n/a", "na", "none", "not applicable", "não aplicável", "nao aplicavel"}
DIVERGENT_PLATFORM_TERMS = ("divergent-android-web", "android/web divergent", "android and web differ", "android e web diferem")
ANDROID_RUNTIME_TERMS = ("android", "adb", "device", "dispositivo", "emulator", "simulator")
WEB_RUNTIME_TERMS = ("web", "browser", "navegador", "playwright", "run_web_navigation_smoke")


def normalize_area(value: str) -> str:
    return " ".join(value.strip().lower().split())


def contains_runtime_requirement(rows: list[list[str]]) -> bool:
    for row in rows:
        lowered = row_text(row).lower()
        if any(term in lowered for term in RUNTIME_TERMS):
            return True
    return False


def runtime_evidence_required_for_traceability(row: list[str]) -> bool:
    if row_has_runtime_ui_signal(row):
        return True
    lowered = row_text(row).lower()
    return any(term in lowered for term in RUNTIME_TERMS)


def evidence_mentions_marker(evidence: str, aliases: tuple[str, ...]) -> bool:
    return marker_present(evidence, aliases)


def approved_deviation_mentions_marker(spec_rows: list[list[str]], aliases: tuple[str, ...]) -> bool:
    for row in spec_rows:
        if len(row) < 5:
            continue
        status = row[4].strip().lower()
        if status != "approved":
            continue
        if marker_present(row_text(row), aliases):
            return True
    return False


def is_runtime_na(value: str) -> bool:
    return value.strip().lower() in TRACEABILITY_RUNTIME_NA


def runtime_freshness_sufficient(lines: list[str]) -> bool:
    lowered = "\n".join(lines).lower()
    required_groups = (
        ("branch", "commit"),
        ("build", "artifact", "artefact", "artefato"),
        ("served", "runtime", "url", "device", "domain", "tunnel", "servido"),
        ("fresh", "matches", "correspond", "proven", "proof", "frescor", "comprova"),
    )
    return all(any(term in lowered for term in group) for group in required_groups)


def row_requires_both_android_and_web(row: list[str]) -> bool:
    lowered = row_text(row).lower()
    return any(term in lowered for term in DIVERGENT_PLATFORM_TERMS)


def runtime_mentions_android_and_web(runtime_evidence: str) -> bool:
    lowered = runtime_evidence.lower()
    has_android = any(term in lowered for term in ANDROID_RUNTIME_TERMS)
    has_web = any(term in lowered for term in WEB_RUNTIME_TERMS)
    return has_android and has_web


def validate_delivery(
    plan_path: Path,
    require_approved: bool,
    allow_waivers: bool,
) -> dict[str, Any]:
    context: dict[str, Any] = {
        "plan_path": str(plan_path),
        "require_approved": require_approved,
        "allow_waivers": allow_waivers,
        "validation_row_count": 0,
        "delivery_evidence_row_count": 0,
        "traceability_row_count": 0,
        "runtime_freshness_required": False,
        "missing_delivery_areas": [],
    }
    violations: list[dict[str, str]] = []

    plan_result = validate_plan(plan_path, require_approved=require_approved)
    if plan_result["blocked"]:
        for violation in plan_result["violations"]:
            violations.append(
                build_violation(
                    f"PLAN-{violation['code']}",
                    violation["message"],
                    violation["resolution"],
                    violation["section"],
                )
            )

    if not plan_path.is_file():
        return {
            "blocked": True,
            "violations": violations
            or [
                build_violation(
                    "PLAN-NOT-FOUND",
                    f"Plan file does not exist: {plan_path}",
                    "Create the orchestration execution plan before running the delivery guard.",
                    "Plan File",
                )
            ],
            "context": context,
        }

    lines = plan_path.read_text(encoding="utf-8").splitlines()
    sections = extract_sections(lines)

    traceability_rows = table_rows(sections.get("Acceptance Traceability Matrix", []))
    spec_rows = table_rows(sections.get("Spec Deviation Ledger", []))
    context["traceability_row_count"] = len(traceability_rows)
    if not traceability_rows:
        violations.append(
            build_violation(
                "TRACEABILITY-EVIDENCE-MISSING",
                "No Acceptance Traceability Matrix rows were found for delivery validation.",
                "Add traceability rows for every governing TODO criterion and update them with passed implementation/test/runtime evidence before claiming delivery.",
                "Acceptance Traceability Matrix",
            )
        )
    for row in traceability_rows:
        if len(row) < TRACEABILITY_COLUMNS:
            violations.append(
                build_violation(
                    "TRACEABILITY-ROW-INCOMPLETE",
                    f"Traceability row has fewer than {TRACEABILITY_COLUMNS} cells: {row_text(row)}",
                    "Use columns: Requirement ID, Source TODO / Criterion, Implementation Owner, Required Artifact / UI Marker, Implementation Evidence, Test Evidence, Runtime / Web Evidence, Status.",
                    "Acceptance Traceability Matrix",
                )
            )
            continue
        requirement_id = row[0]
        owner = row[2]
        marker = row[3]
        implementation_evidence = row[4]
        test_evidence = row[5]
        runtime_evidence = row[6]
        status = row[7].strip().lower()
        if owner_names_orchestrator(owner):
            violations.append(
                build_violation(
                    "TRACEABILITY-ORCHESTRATOR-OWNER",
                    f"Traceability implementation owner is orchestrator for requirement `{requirement_id}`.",
                    "Assign implementation evidence to the responsible worker/subagent. The orchestrator may only reconcile and validate.",
                    "Acceptance Traceability Matrix",
                )
            )
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "TRACEABILITY-EVIDENCE-PLACEHOLDER",
                    f"Traceability row contains placeholder content: {row_text(row)}",
                    "Replace placeholders with concrete passed implementation, test, and runtime evidence.",
                    "Acceptance Traceability Matrix",
                )
            )
        if status == WAIVED_STATUS and allow_waivers:
            continue
        if status != PASSED_STATUS:
            violations.append(
                build_violation(
                    "TRACEABILITY-NOT-PASSED",
                    f"Traceability status is `{row[7]}` for requirement `{requirement_id}`.",
                    "Every traceability row must be `passed` before delivery, unless an explicit approved waiver is recorded and `--allow-waivers` is used.",
                    "Acceptance Traceability Matrix",
                )
            )
        if is_placeholder(implementation_evidence) or is_placeholder(test_evidence):
            violations.append(
                build_violation(
                    "TRACEABILITY-EVIDENCE-INCOMPLETE",
                    f"Implementation or test evidence is incomplete for requirement `{requirement_id}`.",
                    "Record concrete implementation evidence and concrete test command/artifact evidence for this requirement.",
                    "Acceptance Traceability Matrix",
                )
            )
        runtime_required_for_row = runtime_evidence_required_for_traceability(row)
        if runtime_required_for_row and (is_placeholder(runtime_evidence) or is_runtime_na(runtime_evidence)):
            violations.append(
                build_violation(
                    "TRACEABILITY-RUNTIME-EVIDENCE-MISSING",
                    f"UI/runtime requirement `{requirement_id}` lacks concrete runtime/web/device/navigation evidence.",
                    "Run the required real browser/device/navigation validation against the reconciliation branch runtime and record the evidence in the traceability row.",
                    "Acceptance Traceability Matrix",
                )
            )
        if row_requires_both_android_and_web(row) and not runtime_mentions_android_and_web(runtime_evidence):
            violations.append(
                build_violation(
                    "TRACEABILITY-DIVERGENT-PLATFORM-EVIDENCE-MISSING",
                    f"Requirement `{requirement_id}` is marked as divergent Android/Web behavior but does not prove both runtime lanes.",
                    "Record both ADB/device integration evidence and Playwright/browser navigation evidence for divergent Android/Web behavior. If the behavior is shared, change the row to shared-android-web and record the single accepted runtime lane.",
                    "Acceptance Traceability Matrix",
                )
            )
        strict_marker_text = " ".join((marker, row[1]))
        for marker_label, aliases, _ in SPEC_MARKERS:
            if not marker_present(strict_marker_text, aliases):
                continue
            if approved_deviation_mentions_marker(spec_rows, aliases):
                continue
            combined_evidence = " ".join((implementation_evidence, test_evidence, runtime_evidence))
            if not evidence_mentions_marker(combined_evidence, aliases):
                violations.append(
                    build_violation(
                        "TRACEABILITY-MARKER-EVIDENCE-MISMATCH",
                        f"Requirement `{requirement_id}` requires `{marker_label}`, but delivery evidence does not prove that exact marker.",
                        "Update the implementation/test/runtime evidence to prove the named artifact or record an approved Spec Deviation Ledger row. Substituting a different control or behavior is not delivery.",
                        "Acceptance Traceability Matrix",
                    )
                )

    validation_rows = table_rows(sections.get("Consolidated Validation Matrix", []))
    delivery_rows = table_rows(sections.get("Consolidated Delivery Evidence", []))
    context["validation_row_count"] = len(validation_rows)
    context["delivery_evidence_row_count"] = len(delivery_rows)

    if not delivery_rows:
        violations.append(
            build_violation(
                "DELIVERY-EVIDENCE-MISSING",
                "No consolidated delivery evidence rows were found.",
                "Add `## Consolidated Delivery Evidence` rows for every validation matrix area before claiming local implementation or delivery completion.",
                "Consolidated Delivery Evidence",
            )
        )

    required_areas = {
        normalize_area(row[0])
        for row in validation_rows
        if row and not is_placeholder(row[0])
    }
    delivered_areas = {
        normalize_area(row[0])
        for row in delivery_rows
        if row and not is_placeholder(row[0])
    }
    missing_areas = sorted(area for area in required_areas if area not in delivered_areas)
    context["missing_delivery_areas"] = missing_areas
    for area in missing_areas:
        violations.append(
            build_violation(
                "VALIDATION-AREA-NOT-DELIVERED",
                f"Validation matrix area has no matching delivery evidence: {area}",
                "Add a delivery evidence row with the same area name and a concrete passed evidence artifact.",
                "Consolidated Delivery Evidence",
            )
        )

    for row in delivery_rows:
        if len(row) < 5:
            violations.append(
                build_violation(
                    "DELIVERY-EVIDENCE-ROW-INCOMPLETE",
                    f"Delivery evidence row has fewer than 5 cells: {row_text(row)}",
                    "Use columns: Area, Required Evidence, Status, Evidence Artifact / Command, Owner.",
                    "Consolidated Delivery Evidence",
                )
            )
            continue
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "DELIVERY-EVIDENCE-PLACEHOLDER",
                    f"Delivery evidence row contains placeholder content: {row_text(row)}",
                    "Replace placeholder delivery evidence with real command output, artifact paths, check URLs, or blocker notes.",
                    "Consolidated Delivery Evidence",
                )
            )
        status = row[2].strip().lower()
        if status == WAIVED_STATUS and allow_waivers:
            continue
        if status != PASSED_STATUS:
            violations.append(
                build_violation(
                    "DELIVERY-EVIDENCE-NOT-PASSED",
                    f"Delivery evidence status is `{row[2]}` for area `{row[0]}`.",
                    "Run the required validation and record `passed`, or rerun with `--allow-waivers` only after an explicit user-approved waiver is recorded.",
                    "Consolidated Delivery Evidence",
                )
            )

    runtime_required = (
        contains_runtime_requirement(validation_rows)
        or contains_runtime_requirement(delivery_rows)
        or any(runtime_evidence_required_for_traceability(row) for row in traceability_rows if len(row) >= TRACEABILITY_COLUMNS)
    )
    context["runtime_freshness_required"] = runtime_required
    runtime_lines = sections.get("Runtime Freshness Evidence", [])
    if runtime_required:
        if not runtime_lines or not section_has_content(runtime_lines):
            violations.append(
                build_violation(
                    "RUNTIME-FRESHNESS-MISSING",
                    "Runtime/browser/device/build validation is in scope but no runtime freshness evidence was found.",
                    "Add branch, commit, build artifact, served runtime target, and proof that the runtime resolves to the reconciliation branch build.",
                    "Runtime Freshness Evidence",
                )
            )
        elif any(is_placeholder(line) for line in runtime_lines if line.strip()):
            violations.append(
                build_violation(
                    "RUNTIME-FRESHNESS-PLACEHOLDER",
                    "Runtime freshness evidence still contains placeholder content.",
                    "Replace placeholders with real branch/commit/build/served-runtime proof.",
                    "Runtime Freshness Evidence",
                )
            )
        elif not runtime_freshness_sufficient(runtime_lines):
            violations.append(
                build_violation(
                    "RUNTIME-FRESHNESS-INCOMPLETE",
                    "Runtime freshness evidence does not prove branch/commit, build artifact, served target, and freshness/provenance.",
                    "Record the reconciliation branch/commit, build command or artifact id, served URL/device/tunnel, and the proof that the served runtime matches that build.",
                    "Runtime Freshness Evidence",
                )
            )

    return {
        "blocked": bool(violations),
        "violations": violations,
        "context": context,
    }


def render_text(result: dict[str, Any]) -> str:
    blocked = bool(result["blocked"])
    context = result["context"]
    violations = result["violations"]
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append(f"status: {'blocked' if blocked else 'ready'}")
    lines.append(
        "enforcement: "
        + ("stop_before_orchestration_delivery_claim" if blocked else "allow_orchestration_delivery_claim")
    )
    lines.append(f"rule_id: {RULE_ID}")
    lines.append("violation:")
    if not violations:
        lines.append("  - none")
    else:
        for violation in violations:
            lines.append(f"  - [{violation['code']}] {violation['section']}: {violation['message']}")
    lines.append("resolution_prompt:")
    if not violations:
        lines.append("  - The approved orchestration plan has concrete passed delivery evidence for every validation area.")
        lines.append("  - Continue only within the governing TODO set and rerun this guard if ownership, validation scope, runtime target, or evidence changes.")
    else:
        seen: set[str] = set()
        for violation in violations:
            resolution = violation["resolution"]
            if resolution in seen:
                continue
            seen.add(resolution)
            lines.append(f"  - {resolution}")
    lines.append("context:")
    for key in (
        "plan_path",
        "require_approved",
        "allow_waivers",
        "validation_row_count",
        "delivery_evidence_row_count",
        "traceability_row_count",
        "runtime_freshness_required",
        "missing_delivery_areas",
    ):
        lines.append(f"  {key}: {context.get(key)}")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines) + "\n"


def render_json(result: dict[str, Any]) -> str:
    payload = {
        "schema_version": "orchestration-delivery-guard-v1",
        "rule_id": RULE_ID,
        "status": "blocked" if result["blocked"] else "ready",
        "overall_outcome": "no-go" if result["blocked"] else "go",
        **result,
    }
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate orchestration delivery evidence with TEACH output.")
    parser.add_argument("--plan", required=True, help="Path to the orchestration execution plan markdown file.")
    parser.add_argument(
        "--require-approved",
        action="store_true",
        help="Require the plan completion guard to see Artifact Identity status `Approved`.",
    )
    parser.add_argument(
        "--allow-waivers",
        action="store_true",
        help="Allow delivery rows with status `waived`; use only after explicit user-approved waiver evidence is recorded.",
    )
    parser.add_argument("--json-output", help="Optional path to write a JSON result artifact.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    plan_path = Path(args.plan).resolve()
    result = validate_delivery(plan_path, require_approved=args.require_approved, allow_waivers=args.allow_waivers)
    text = render_text(result)
    print(text, end="")
    if args.json_output:
        Path(args.json_output).write_text(render_json(result), encoding="utf-8")
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        raise SystemExit(1)
