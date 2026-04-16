#!/usr/bin/env python3
"""Metrics consolidation trigger for TODO completion.

Extracts formalizable findings from gate finding resolutions (Triple Audits)
associated with a TODO and appends them as rule events to rule-events.jsonl.

This is the bridge between organic review work and the Phase 0 metrics
pipeline. It runs as part of the TODO completion workflow, after the
completion guard passes but before the TODO is moved to completed/.

T.E.A.C.H. compliance:
  Triggered  – called during TODO completion, after completion guard GO
  Enforced   – exit code 0 = success, exit code 1 = error
  Automated  – Python script extracting from gate finding resolution tables
  Contextual – reports which findings were extracted and their rule candidates
  Hinting    – suggests next steps for rule formalization

Usage:
  python3 metrics_consolidation_trigger.py \\
      --todo <path-to-TODO.md> \\
      --events-jsonl <path-to-rule-events.jsonl> \\
      [--review-kinds critique,test_quality_audit,final_review] \\
      [--report-json <path>]

Exit codes:
  0  Success (findings extracted and appended, or no findings to extract)
  1  Operational error
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Import shared infrastructure
# ---------------------------------------------------------------------------
sys.path.insert(0, str(Path(__file__).resolve().parent))

from paced_metrics_core import (
    append_jsonl,
    build_rule_event_id,
    build_rule_fingerprint,
    canonical_todo_path,
    load_jsonl,
    next_rule_episode_id,
    utc_now,
    validate_schema,
)
import gate_finding_resolution_extract as gfr_extract


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

RULE_ID_PREFIX = "paced.finding.formalizable"
SOURCE_KIND = "validator"
SOURCE_REF = "delphi-ai/tools/metrics_consolidation_trigger.py"

ALL_REVIEW_KINDS = ["critique", "test_quality_audit", "final_review"]


# ---------------------------------------------------------------------------
# Extraction logic
# ---------------------------------------------------------------------------

def extract_formalizable_findings(
    todo_path: Path,
    review_kinds: list[str],
) -> list[dict]:
    """Extract findings with formalizable_hint=yes|partial from a TODO's gate tables."""
    all_findings: list[dict] = []

    for review_kind in review_kinds:
        try:
            packet = gfr_extract.build_resolution_packet(todo_path, review_kind)
        except SystemExit:
            # Gate not present or no findings — skip silently
            continue

        for finding in packet.get("findings", []):
            formalizable = finding.get("formalizable", "unknown")
            if formalizable not in ("yes", "partial"):
                continue

            all_findings.append({
                "review_kind": review_kind,
                "finding_id": finding.get("finding_id", "unknown"),
                "resolution": finding.get("resolution", "unknown"),
                "usefulness": finding.get("usefulness", "unknown"),
                "formalizable": formalizable,
                "candidate_rule_level": finding.get("candidate_rule_level", "unknown"),
                "candidate_rule_id": finding.get("candidate_rule_id", "n/a"),
                "rationale": finding.get("rationale", ""),
            })

    return all_findings


def emit_rule_events(
    events_path: Path,
    todo_path_str: str,
    findings: list[dict],
) -> list[dict]:
    """Emit rule events for each formalizable finding."""
    prior_events = load_jsonl(events_path)
    timestamp = utc_now()
    emitted: list[dict] = []

    for finding in findings:
        # Build a unique rule_id for this candidate
        candidate_id = finding["candidate_rule_id"]
        if candidate_id in ("n/a", "unknown", ""):
            rule_id = f"{RULE_ID_PREFIX}.{finding['review_kind']}.{finding['finding_id']}"
        else:
            rule_id = candidate_id

        fingerprint = build_rule_fingerprint([
            finding["review_kind"],
            finding["finding_id"],
            finding["candidate_rule_id"],
        ])

        episode_id = next_rule_episode_id(
            prior_events, rule_id, todo_path_str, fingerprint,
        )

        event_id = build_rule_event_id(
            "rule_block_observed", rule_id,
            todo_path_str, fingerprint, timestamp,
        )

        # Determine rule_level
        level = finding["candidate_rule_level"]
        if level not in ("paced", "project"):
            level = "paced"  # default for formalizable findings

        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": event_id,
            "event_kind": "rule_block_observed",
            "timestamp": timestamp,
            "rule_id": rule_id,
            "rule_level": level,
            "todo_path": todo_path_str,
            "episode_id": episode_id,
            "fingerprint": fingerprint,
            "source_kind": SOURCE_KIND,
            "source_ref": SOURCE_REF,
            "issue_code": f"FORMALIZABLE-{finding['finding_id']}",
            "field": f"gate.{finding['review_kind']}",
            "severity": "info",
            "message": (
                f"Formalizable finding from {finding['review_kind']}: "
                f"{finding['finding_id']} ({finding['formalizable']}). "
                f"Candidate rule: {finding['candidate_rule_id']}. "
                f"Rationale: {finding['rationale'][:200]}"
            ),
            "resolution_instruction": (
                f"Review this finding for rule formalization. "
                f"Candidate rule ID: {finding['candidate_rule_id']}. "
                f"Level: {finding['candidate_rule_level']}. "
                f"If confirmed, add to the rule catalog via seed_rule_catalog.py."
            ),
        }

        validate_schema(payload, "rule_event.schema.json", "metrics consolidation rule event")
        append_jsonl(events_path, payload)
        prior_events.append(payload)
        emitted.append(payload)

    return emitted


# ---------------------------------------------------------------------------
# Output rendering
# ---------------------------------------------------------------------------

def render_text(
    todo_path: str,
    findings: list[dict],
    emitted_count: int,
) -> str:
    """Render the consolidation result as human-readable text."""
    lines: list[str] = []
    lines.append("Metrics Consolidation Trigger")
    lines.append(f"TODO: {todo_path}")
    lines.append("")

    lines.append(f"Formalizable findings found: {len(findings)}")
    lines.append(f"Rule events emitted: {emitted_count}")
    lines.append("")

    if findings:
        lines.append("Extracted findings:")
        for f in findings:
            lines.append(
                f"  - [{f['review_kind']}] {f['finding_id']}: "
                f"formalizable={f['formalizable']}, "
                f"candidate={f['candidate_rule_id']}, "
                f"level={f['candidate_rule_level']}"
            )
        lines.append("")
        lines.append("TEACH hint:")
        lines.append("  - These findings are now in rule-events.jsonl as 'rule_block_observed' events.")
        lines.append("  - Review each candidate_rule_id for formalization into the rule catalog.")
        lines.append("  - Use seed_rule_catalog.py to add confirmed rules.")
    else:
        lines.append("No formalizable findings found in gate resolution tables.")
        lines.append("This is normal for TODOs without Triple Audit gates or with all findings marked as 'no'.")

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Extract formalizable findings from gate resolutions and emit "
            "them as rule events for the Phase 0 metrics pipeline."
        )
    )
    parser.add_argument(
        "--todo", required=True,
        help="Path to the TODO markdown file.",
    )
    parser.add_argument(
        "--events-jsonl", required=True,
        help="Path to the rule-events.jsonl file to append to.",
    )
    parser.add_argument(
        "--review-kinds",
        default=",".join(ALL_REVIEW_KINDS),
        help=f"Comma-separated list of review kinds to scan (default: {','.join(ALL_REVIEW_KINDS)}).",
    )
    parser.add_argument(
        "--report-json",
        help="Optional path to write the consolidation report as JSON.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()

    if not todo_path.exists():
        print(f"Error: TODO file not found: {todo_path}", file=sys.stderr)
        return 1

    review_kinds = [k.strip() for k in args.review_kinds.split(",") if k.strip()]
    events_path = Path(args.events_jsonl).resolve()

    # Normalize todo path for events
    todo_path_str = canonical_todo_path(str(todo_path))

    # Extract formalizable findings
    findings = extract_formalizable_findings(todo_path, review_kinds)

    # Emit rule events
    emitted: list[dict] = []
    if findings:
        emitted = emit_rule_events(events_path, todo_path_str, findings)

    # Text output
    print(render_text(todo_path_str, findings, len(emitted)), end="")

    # Optional JSON report
    if args.report_json:
        report = {
            "schema_version": "metrics-consolidation-v1",
            "artifact_kind": "metrics_consolidation_report",
            "todo_path": todo_path_str,
            "review_kinds_scanned": review_kinds,
            "findings_extracted": len(findings),
            "events_emitted": len(emitted),
            "findings": findings,
        }
        report_path = Path(args.report_json).resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
