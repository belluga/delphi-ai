#!/usr/bin/env python3
"""Render a markdown resolution table scaffold from a merged subagent review packet."""

from __future__ import annotations

import argparse
from pathlib import Path

from paced_metrics_core import load_json, validate_schema


HEADER = "| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |"
SEPARATOR = "| --- | --- | --- | --- | --- | --- | --- |"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a TODO-ready finding-resolution table scaffold from a subagent review merge packet.")
    parser.add_argument("--merge", required=True, help="Path to subagent review merge JSON.")
    parser.add_argument("--output", help="Optional markdown output path.")
    return parser.parse_args()


def render_markdown(merge_payload: dict) -> str:
    lines = [
        "<!-- Paste this table below the gate's `Resolution ledger` line and then replace the placeholders. -->",
        HEADER,
        SEPARATOR,
    ]
    for finding in merge_payload.get("findings", []):
        default_rule_level = finding.get("candidate_rule_level", "unknown")
        candidate_rule_id = finding.get("candidate_rule_id", "n/a") or "n/a"
        candidate_rule_id_options = finding.get("candidate_rule_id_options", [])
        rationale = f"{finding['title']} ({', '.join(finding.get('reviewer_labels', []))})"
        rule_level_hint = default_rule_level if default_rule_level in {"paced", "project", "none", "unknown"} else "unknown"
        if candidate_rule_id_options:
            rule_id_hint = "<" + "|".join(candidate_rule_id_options + ["n/a"]) + ">"
        else:
            rule_id_hint = "<n/a>" if candidate_rule_id == "n/a" else f"<{candidate_rule_id}|n/a>"
        lines.append(
            f"| `{finding['finding_id']}` | `<Integrated|Challenged|Deferred>` | `<useful|noise|mixed|unknown>` | `<yes|partial|no|unknown>` | `<{rule_level_hint}>` | {rule_id_hint} | {rationale} |"
        )
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    merge_path = Path(args.merge).resolve()
    payload = load_json(merge_path)
    validate_schema(payload, "subagent_review_merge.schema.json", "subagent review merge")
    rendered = render_markdown(payload)
    if args.output:
        output_path = Path(args.output).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
