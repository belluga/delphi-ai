#!/usr/bin/env python3
"""Deterministic completion guard for tactical TODOs.

This is the T.E.A.C.H.-compliant gate that must return GO before a TODO
can be moved from ``todos/active/`` to ``todos/completed/``.

T.E.A.C.H. compliance:
  Triggered  – called explicitly when the agent attempts to finalize a TODO
  Enforced   – exit code 2 = NO-GO, exit code 0 = GO
  Automated  – Python script, no manual intervention
  Contextual – emits per-section evidence (checkboxes, gates, blockers)
  Hinting    – resolution_prompt gives exact next steps to resolve blockers

Usage:
  python3 todo_completion_guard.py --todo <path-to-TODO.md> [--events-jsonl <path>]

Exit codes:
  0  GO: the TODO is ready to be moved to completed/
  2  NO-GO: deterministic TEACH blocker found; follow resolution_prompt
  1  Operational error (file not found, parse failure, etc.)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Import shared infrastructure from the existing codebase
# ---------------------------------------------------------------------------
sys.path.insert(0, str(Path(__file__).resolve().parent))

import todo_validation_bundle_export as exporter
from todo_validation_bundle_export import is_placeholder

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

RULE_ID = "paced.todo.completion-guard"
SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}

CHECKBOX_RE = re.compile(r"^\s*-\s+\[([ xX])\]\s+(.+)$")


# ---------------------------------------------------------------------------
# Checkbox parsing
# ---------------------------------------------------------------------------

def parse_checkboxes(lines: list[str], section_heading: str) -> list[dict]:
    """Extract checkbox items from a named section.

    Returns a list of dicts with keys: text, checked, line_number.
    """
    in_section = False
    items: list[dict] = []
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if stripped.startswith("## ") or stripped.startswith("# "):
            if stripped.startswith(section_heading):
                in_section = True
                continue
            elif in_section:
                break  # left the section
        if not in_section:
            continue
        match = CHECKBOX_RE.match(line)
        if match:
            marker = match.group(1)
            text = match.group(2).strip()
            items.append({
                "text": text,
                "checked": marker.lower() == "x",
                "line_number": idx,
            })
    return items


def find_waiver_section(lines: list[str]) -> list[str]:
    """Extract content from a ## Waivers or ## Completion Waivers section."""
    in_section = False
    content: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("## ") or stripped.startswith("# "):
            if "waiver" in stripped.lower():
                in_section = True
                continue
            elif in_section:
                break
        if in_section and stripped:
            content.append(stripped)
    return content


# ---------------------------------------------------------------------------
# Validation logic
# ---------------------------------------------------------------------------

def validate_completion(todo_path: Path) -> dict:
    """Run all completion checks and return a structured result."""
    lines = todo_path.read_text(encoding="utf-8").splitlines()
    bundle = exporter.build_bundle(todo_path)

    violations: list[dict] = []
    context: dict = {}

    # ── 1. Definition of Done checkboxes ─────────────────────────────────
    dod_items = parse_checkboxes(lines, "## Definition of Done")
    context["definition_of_done"] = {
        "total": len(dod_items),
        "checked": sum(1 for i in dod_items if i["checked"]),
        "unchecked": sum(1 for i in dod_items if not i["checked"]),
    }

    unchecked_dod = [i for i in dod_items if not i["checked"]]
    if unchecked_dod:
        waiver_lines = find_waiver_section(lines)
        waived_items = []
        unwaived_items = []
        for item in unchecked_dod:
            # Check if any waiver line references this item (fuzzy match on first 40 chars)
            item_key = item["text"][:40].lower()
            has_waiver = any(item_key in w.lower() for w in waiver_lines)
            if has_waiver:
                waived_items.append(item)
            else:
                unwaived_items.append(item)

        context["definition_of_done"]["waived"] = len(waived_items)
        context["definition_of_done"]["unwaived"] = len(unwaived_items)

        if unwaived_items:
            item_list = "; ".join(
                f"L{i['line_number']}: {i['text'][:80]}" for i in unwaived_items
            )
            violations.append({
                "section": "Definition of Done",
                "code": "DOD-INCOMPLETE",
                "message": f"{len(unwaived_items)} unchecked item(s) without waiver: {item_list}",
                "resolution": (
                    f"BEFORE accepting this blocker: verify in the actual codebase "
                    f"whether the {len(unwaived_items)} unchecked item(s) were already "
                    f"implemented but not marked. If the code/tests confirm the item "
                    f"is done, mark the checkbox and rerun the guard. "
                    f"If genuinely incomplete, either complete the item(s) or add a "
                    f"'## Waivers' section documenting why each pending item "
                    f"is acceptable for closure."
                ),
            })

    # ── 2. Validation Steps checkboxes ───────────────────────────────────
    vs_items = parse_checkboxes(lines, "## Validation Steps")
    context["validation_steps"] = {
        "total": len(vs_items),
        "checked": sum(1 for i in vs_items if i["checked"]),
        "unchecked": sum(1 for i in vs_items if not i["checked"]),
    }

    unchecked_vs = [i for i in vs_items if not i["checked"]]
    if unchecked_vs:
        item_list = "; ".join(
            f"L{i['line_number']}: {i['text'][:80]}" for i in unchecked_vs
        )
        violations.append({
            "section": "Validation Steps",
            "code": "VS-INCOMPLETE",
            "message": f"{len(unchecked_vs)} unchecked validation step(s): {item_list}",
            "resolution": (
                f"BEFORE accepting this blocker: cross-check each unchecked step "
                f"against the actual code, tests, and CI results — the step may "
                f"have been completed without the checkbox being marked. "
                f"If evidence confirms the step passes, mark it and rerun. "
                f"Otherwise, run the {len(unchecked_vs)} remaining validation step(s), "
                f"or document why they are not applicable for this delivery."
            ),
        })

    # ── 3. Delivery stage must be Production-Ready ───────────────────────
    delivery_stage = bundle["delivery_status"]["stage"]
    context["delivery_stage"] = delivery_stage

    if delivery_stage != "Production-Ready":
        violations.append({
            "section": "Delivery Status",
            "code": "STAGE-NOT-READY",
            "message": f"Delivery stage is '{delivery_stage}', expected 'Production-Ready'.",
            "resolution": (
                "Update 'Current delivery stage' to 'Production-Ready' only after "
                "all deliverables are verified. If the TODO is Provisional, resolve "
                "the provisional state first."
            ),
        })

    # ── 4. Qualifiers must not include Blocked ───────────────────────────
    qualifiers = bundle["delivery_status"]["qualifiers"]
    context["qualifiers"] = qualifiers

    if "Blocked" in qualifiers:
        violations.append({
            "section": "Delivery Status",
            "code": "BLOCKED-CLOSURE",
            "message": "Cannot close a TODO that is still Blocked.",
            "resolution": (
                "Resolve the blocker and remove the 'Blocked' qualifier, "
                "or split the blocked portion into a new TODO."
            ),
        })

    if "Provisional" in qualifiers:
        violations.append({
            "section": "Delivery Status",
            "code": "PROVISIONAL-CLOSURE",
            "message": "Cannot close a TODO that is still Provisional without explicit waiver.",
            "resolution": (
                "Either resolve the provisional state (fill all missing items), "
                "or add a '## Waivers' section with explicit human approval "
                "to close as-is and create a follow-up TODO for the remainder."
            ),
        })

    # ── 5. Required gates must be in satisfying status ───────────────────
    gate_summary: dict = {}
    for gate_id, gate in bundle["gates"].items():
        gate_summary[gate_id] = {
            "decision": gate["decision"],
            "status": gate["status"],
            "section_present": gate["section_present"],
        }

        if not gate["section_present"]:
            violations.append({
                "section": f"Gate: {gate_id}",
                "code": f"GATE-{gate_id.upper()}-MISSING",
                "message": f"Gate section '{gate_id}' is missing from the TODO.",
                "resolution": (
                    f"Add the '{gate_id}' gate section to the TODO. "
                    "If the gate is not needed, declare decision='not_needed' with rationale."
                ),
            })
            continue

        if gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            violations.append({
                "section": f"Gate: {gate_id}",
                "code": f"GATE-{gate_id.upper()}-UNRESOLVED",
                "message": (
                    f"Required gate '{gate_id}' has status '{gate['status']}' "
                    f"(needs one of: {', '.join(sorted(SATISFYING_GATE_STATUSES))})."
                ),
                "resolution": (
                    f"Complete the '{gate_id}' gate to a satisfying status, "
                    "or record an explicit human waiver with authority reference."
                ),
            })

    context["gates"] = gate_summary

    # ── 6. Artifact state consistency ────────────────────────────────────
    artifact_state = bundle["artifact_state"]
    context["artifact_state"] = artifact_state

    # If already in completed/ but has violations, that's a retroactive catch
    if artifact_state == "completed" and violations:
        context["retroactive_check"] = True

    # ── Build result ─────────────────────────────────────────────────────
    if not violations:
        outcome = "go"
        status = "ready"
        enforcement = "allow_completion"
    else:
        outcome = "no-go"
        status = "blocked"
        enforcement = "stop_before_completion"

    return {
        "outcome": outcome,
        "status": status,
        "enforcement": enforcement,
        "violations": violations,
        "context": context,
        "todo_path": str(todo_path),
    }


# ---------------------------------------------------------------------------
# Output rendering
# ---------------------------------------------------------------------------

def render_text(result: dict) -> str:
    """Render the T.E.A.C.H. runtime response as human-readable text."""
    lines: list[str] = []
    lines.append("TODO Completion Guard")
    lines.append(f"TODO: {result['todo_path']}")
    lines.append("")

    ctx = result["context"]
    lines.append("Preflight summary")
    dod = ctx.get("definition_of_done", {})
    lines.append(f"  - Definition of Done: {dod.get('checked', 0)}/{dod.get('total', 0)} checked")
    if dod.get("unwaived"):
        lines.append(f"    ({dod['unwaived']} unwaived pending)")
    vs = ctx.get("validation_steps", {})
    lines.append(f"  - Validation Steps: {vs.get('checked', 0)}/{vs.get('total', 0)} checked")
    lines.append(f"  - Delivery stage: {ctx.get('delivery_stage', 'unknown')}")
    lines.append(f"  - Qualifiers: {ctx.get('qualifiers', [])}")
    for gid, gs in ctx.get("gates", {}).items():
        lines.append(f"  - Gate {gid}: decision={gs['decision']}, status={gs['status']}")
    lines.append("")

    lines.append("TEACH runtime response")
    lines.append(f"status: {result['status']}")
    lines.append(f"enforcement: {result['enforcement']}")
    lines.append(f"rule_id: {RULE_ID}")

    lines.append("violation:")
    if not result["violations"]:
        lines.append("  - none")
    else:
        for v in result["violations"]:
            lines.append(f"  - [{v['code']}] {v['message']}")

    lines.append("resolution_prompt:")
    if not result["violations"]:
        lines.append("  - TODO is ready to be moved to completed/.")
        lines.append("  - Record completion evidence and update the Promotion Evidence table.")
    else:
        for v in result["violations"]:
            lines.append(f"  - {v['resolution']}")
        lines.append(
            f"  - Rerun the completion guard after fixes: "
            f"python3 delphi-ai/tools/todo_completion_guard.py --todo {result['todo_path']}"
        )

    lines.append("context:")
    for key, value in ctx.items():
        if isinstance(value, dict):
            lines.append(f"  {key}:")
            for k2, v2 in value.items():
                lines.append(f"    {k2}: {v2}")
        else:
            lines.append(f"  {key}: {value}")

    lines.append("")
    lines.append(f"Overall outcome: {result['outcome']}")
    return "\n".join(lines) + "\n"


def render_json(result: dict) -> str:
    """Render the result as structured JSON."""
    payload = {
        "schema_version": "todo-completion-guard-v1",
        "artifact_kind": "todo_completion_guard_result",
        "rule_id": RULE_ID,
        "todo_path": result["todo_path"],
        "outcome": result["outcome"],
        "status": result["status"],
        "enforcement": result["enforcement"],
        "violations": result["violations"],
        "context": result["context"],
    }
    return json.dumps(payload, indent=2) + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Deterministic completion guard for tactical TODOs. "
            "Returns GO (exit 0) or NO-GO (exit 2) with T.E.A.C.H. diagnostics."
        )
    )
    parser.add_argument(
        "--todo", required=True,
        help="Path to the TODO markdown file.",
    )
    parser.add_argument(
        "--report-json",
        help="Optional path to write the guard result as JSON.",
    )
    parser.add_argument(
        "--events-jsonl",
        help="Optional path to append rule events as JSONL (reuses existing metrics infrastructure).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()

    if not todo_path.exists():
        print(f"Error: TODO file not found: {todo_path}", file=sys.stderr)
        return 1

    result = validate_completion(todo_path)

    # Text output to stdout
    print(render_text(result), end="")

    # Optional JSON report
    if args.report_json:
        report_path = Path(args.report_json).resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(render_json(result), encoding="utf-8")

    # Optional rule events emission (reuses paced_metrics_core infrastructure)
    if args.events_jsonl:
        try:
            from paced_metrics_core import (
                append_jsonl,
                build_rule_event_id,
                build_rule_fingerprint,
                next_rule_episode_id,
                load_jsonl,
                utc_now,
                validate_schema,
            )

            events_path = Path(args.events_jsonl).resolve()
            prior_events = load_jsonl(events_path)
            timestamp = utc_now()

            for v in result["violations"]:
                fingerprint = build_rule_fingerprint([v["code"], v["section"]])
                episode_id = next_rule_episode_id(
                    prior_events, RULE_ID, result["todo_path"], fingerprint,
                )
                event_id = build_rule_event_id(
                    "rule_block_observed", RULE_ID,
                    result["todo_path"], fingerprint, timestamp,
                )
                payload = {
                    "schema_version": "rule-event-v1",
                    "artifact_kind": "rule_event",
                    "event_id": event_id,
                    "event_kind": "rule_block_observed",
                    "timestamp": timestamp,
                    "rule_id": RULE_ID,
                    "rule_level": "paced",
                    "todo_path": result["todo_path"],
                    "episode_id": episode_id,
                    "fingerprint": fingerprint,
                    "source_kind": "completion_guard",
                    "source_ref": "delphi-ai/tools/todo_completion_guard.py",
                    "issue_code": v["code"],
                    "field": v["section"],
                    "severity": "error",
                    "message": v["message"],
                    "resolution_instruction": v["resolution"],
                }
                validate_schema(payload, "rule_event.schema.json", "completion guard rule event")
                append_jsonl(events_path, payload)
                prior_events.append(payload)

        except ImportError:
            print(
                "Warning: paced_metrics_core not available, skipping events emission.",
                file=sys.stderr,
            )

    # Exit code: 0 = GO, 2 = NO-GO
    if result["outcome"] == "go":
        return 0
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
