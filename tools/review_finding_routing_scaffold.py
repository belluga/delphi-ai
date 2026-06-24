#!/usr/bin/env python3
"""Render a guard-compatible Promotion Finding Routing Ledger scaffold from operator-supplied findings."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


CLASSIFICATIONS = {
    "release-blocker",
    "follow-up-fast-follow",
    "follow-up-hardening",
    "by-design/no-action",
}
STATUSES = {"open", "fixed", "routed", "accepted", "blocked"}
DEFAULT_ROUTING_PLACEHOLDER = (
    "<same-todo-remediation|same-todo-evidence-refresh|split-fast-follow|"
    "split-hardening|renewed-approval-required|no-action>"
)
DEFAULT_CLASSIFICATION_PLACEHOLDER = (
    "<release-blocker|follow-up-fast-follow|follow-up-hardening|by-design/no-action>"
)
DEFAULT_STATUS_PLACEHOLDER = "<open|fixed|routed|accepted|blocked>"
HEADER = (
    "| Finding ID | Severity | Classification | Routing Decision | "
    "Same TODO / Split Rationale | Status | Approval / Follow-up Reference |"
)
SEPARATOR = "| --- | --- | --- | --- | --- | --- | --- |"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Render Promotion Finding Routing Ledger rows from operator-supplied findings. "
            "This helper scaffolds the ledger only; it does not choose the classification."
        )
    )
    parser.add_argument(
        "--input",
        required=True,
        help="Path to a JSON file containing either an array of findings or an object with a `findings` array.",
    )
    parser.add_argument("--output", help="Optional markdown output path.")
    parser.add_argument(
        "--section",
        action="store_true",
        help="Render the full `## Promotion Finding Routing Ledger` section instead of only the table.",
    )
    return parser.parse_args()


def load_findings(path: Path) -> list[dict]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(payload, list):
        findings = payload
    elif isinstance(payload, dict) and isinstance(payload.get("findings"), list):
        findings = payload["findings"]
    else:
        raise ValueError("input JSON must be an array or an object with a `findings` array")
    if not all(isinstance(item, dict) for item in findings):
        raise ValueError("every finding entry must be a JSON object")
    return findings


def placeholder_for_reference(classification: str | None) -> str:
    if classification == "release-blocker":
        return "<same TODO evidence|renewed approval reference>"
    if classification == "follow-up-fast-follow":
        return "<exact fast-follow TODO path>"
    if classification == "follow-up-hardening":
        return "<exact hardening TODO path>"
    if classification == "by-design/no-action":
        return "<approved rationale or prior authority>"
    return "<same TODO evidence|follow-up TODO path|approval rationale>"


def normalize_field(value: object) -> str:
    if value is None:
        return ""
    if not isinstance(value, str):
        raise ValueError("string fields must be strings when provided")
    return value.strip()


def render_row(finding: dict) -> str:
    finding_id = normalize_field(finding.get("finding_id"))
    severity = normalize_field(finding.get("severity"))
    if not finding_id:
        raise ValueError("finding_id is required")
    if not severity:
        raise ValueError(f"severity is required for finding `{finding_id}`")

    classification = normalize_field(finding.get("classification"))
    if classification and classification not in CLASSIFICATIONS:
        raise ValueError(
            f"invalid classification `{classification}` for finding `{finding_id}`; "
            f"expected one of {sorted(CLASSIFICATIONS)}"
        )

    status = normalize_field(finding.get("status"))
    if status and status not in STATUSES:
        raise ValueError(
            f"invalid status `{status}` for finding `{finding_id}`; expected one of {sorted(STATUSES)}"
        )

    routing = normalize_field(finding.get("routing_decision")) or DEFAULT_ROUTING_PLACEHOLDER
    rationale = normalize_field(finding.get("rationale")) or "<why this classification stays in-scope or routes out>"
    reference = normalize_field(finding.get("reference")) or placeholder_for_reference(classification or None)

    rendered_classification = classification or DEFAULT_CLASSIFICATION_PLACEHOLDER
    rendered_status = status or DEFAULT_STATUS_PLACEHOLDER

    return (
        f"| `{finding_id}` | `{severity}` | `{rendered_classification}` | `{routing}` | "
        f"{rationale} | `{rendered_status}` | {reference} |"
    )


def render_markdown(findings: list[dict], include_section: bool) -> str:
    lines: list[str] = []
    if include_section:
        lines.extend(
            [
                "## Promotion Finding Routing Ledger",
                "Use after review/audit/promotion findings are collected and deduplicated.",
                "Only `release-blocker` rows may block the current delivery/promotion claim.",
                "",
            ]
        )
    lines.extend([HEADER, SEPARATOR])
    for finding in findings:
        lines.append(render_row(finding))
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    try:
        findings = load_findings(Path(args.input).resolve())
        rendered = render_markdown(findings, args.section)
    except Exception as exc:  # noqa: BLE001 - deterministic CLI error path
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    if args.output:
        output_path = Path(args.output).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
