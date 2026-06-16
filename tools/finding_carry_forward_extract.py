#!/usr/bin/env python3
"""Extract historical finding dispositions from a tactical TODO for no-context review loops."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from orchestration_plan_completion_guard import canonical_heading, extract_sections, row_text, table_rows

REPO_ROOT = Path(__file__).resolve().parent.parent
DETERMINISTIC_CORE_ROOT = REPO_ROOT / "deterministic" / "core"
if str(DETERMINISTIC_CORE_ROOT) not in sys.path:
    sys.path.insert(0, str(DETERMINISTIC_CORE_ROOT))

from gate_finding_resolution_extract import REVIEW_CONFIG, build_resolution_packet  # type: ignore
from paced_metrics_core import normalize_repo_relative, validate_schema, write_json  # type: ignore
from todo_validation_bundle_export import extract_field_in_section, section_present  # type: ignore


PROMOTION_ROUTING_SECTION = "Promotion Finding Routing Ledger"
PROMOTION_UNRESOLVED_STATUSES = {"open", "pending", "planned", "blocked", "unresolved", "failing"}
BY_DESIGN_CLASSIFICATIONS = {"by-design intent", "by design intent", "non-actionable"}
DEFERRED_CLASSIFICATIONS = {"upstream-lane drift"}
DEFERRED_CLASSIFICATION_TOKENS = (
    "follow-up",
    "follow up",
    "fast-follow",
    "fast follow",
    "hardening",
)
POLICY_LINES = [
    "Resolved findings are historical context only. Do not reopen them unless the current bounded package materially changes the same locus/behavior or fresh evidence shows regression.",
    "Challenged findings stay closed unless the current bounded package materially changes the same locus/behavior or the prior rationale is objectively insufficient.",
    "Deferred findings must cite the recorded follow-up/waiver path first. Re-raise them only when the current bounded package changes the same locus or closure now depends on that deferred risk.",
    "Unresolved findings remain valid to re-raise until they are fixed, challenged, or formally deferred with authority.",
]


def normalize(value: str) -> str:
    return canonical_heading(value)


def find_section(lines: list[str], section_name: str) -> list[str]:
    sections = extract_sections(lines)
    wanted = normalize(section_name)
    for title, section_lines in sections.items():
        normalized = normalize(title)
        if normalized == wanted or normalized.startswith(wanted):
            return section_lines
    return []


def classify_promotion_row(classification: str, routing: str, status: str) -> str:
    normalized_status = normalize(status)
    normalized_classification = normalize(classification)
    normalized_routing = normalize(routing)
    if normalized_status in PROMOTION_UNRESOLVED_STATUSES:
        return "unresolved"
    if normalized_classification in BY_DESIGN_CLASSIFICATIONS:
        return "challenged"
    if (
        normalized_classification in DEFERRED_CLASSIFICATIONS
        or any(token in normalized_classification for token in DEFERRED_CLASSIFICATION_TOKENS)
        or "defer" in normalized_routing
        or "followup" in normalized_routing
        or "follow-up" in normalized_routing
        or "hardening" in normalized_routing
    ):
        return "deferred"
    if normalized_status == "deferred":
        return "deferred"
    return "resolved"


def extract_promotion_entries(todo_path: Path, repo_root: Path) -> list[dict[str, str]]:
    lines = todo_path.read_text(encoding="utf-8").splitlines()
    rows = table_rows(find_section(lines, PROMOTION_ROUTING_SECTION))
    entries: list[dict[str, str]] = []
    for row in rows:
        if len(row) < 7:
            continue
        severity = normalize(row[1])
        if severity in {"n/a", "na", "none"}:
            continue
        classification = row[2]
        routing = row[3]
        rationale = row[4]
        status = row[5]
        reference = row[6]
        entries.append(
            {
                "source_kind": "promotion_routing",
                "finding_id": row[0],
                "carry_forward_class": classify_promotion_row(classification, routing, status),
                "source_disposition": f"classification={classification}; routing={routing}; status={status}",
                "summary": rationale or row_text(row),
                "reference": reference or "n/a",
            }
        )
    return entries


def extract_gate_entries(todo_path: Path, repo_root: Path) -> list[dict[str, str]]:
    lines = todo_path.read_text(encoding="utf-8").splitlines()
    entries: list[dict[str, str]] = []
    for review_kind in REVIEW_CONFIG:
        config = REVIEW_CONFIG[review_kind]
        if not section_present(lines, config["heading"]):
            continue
        gate_status = extract_field_in_section(lines, config["heading"], config["status_label"])
        if gate_status in {"missing", "not_run", "running"}:
            continue
        packet = build_resolution_packet(todo_path, review_kind, repo_root)
        for finding in packet.get("findings", []):
            resolution = finding["resolution"]
            if resolution == "Integrated":
                carry_forward_class = "resolved"
            elif resolution == "Challenged":
                carry_forward_class = "challenged"
            else:
                carry_forward_class = "deferred"
            entries.append(
                {
                    "source_kind": review_kind,
                    "finding_id": finding["finding_id"],
                    "carry_forward_class": carry_forward_class,
                    "source_disposition": (
                        f"resolution={finding['resolution']}; usefulness={finding['usefulness']}; "
                        f"formalizable={finding['formalizable']}"
                    ),
                    "summary": finding["rationale"],
                    "reference": f"{review_kind}:{packet['gate_status']}",
                }
            )
    return entries


def build_carry_forward_packet(todo_path: Path, repo_root: Path | None = None) -> dict:
    normalized_root = repo_root or Path.cwd()
    entries = extract_promotion_entries(todo_path, normalized_root)
    entries.extend(extract_gate_entries(todo_path, normalized_root))
    payload = {
        "schema_version": "finding-carry-forward-v1",
        "artifact_kind": "finding_carry_forward",
        "authoritative": False,
        "edit_policy": "derived_from_todo",
        "todo_path": normalize_repo_relative(todo_path, normalized_root),
        "policy_lines": POLICY_LINES,
        "entries": entries,
    }
    validate_schema(payload, "finding_carry_forward.schema.json", "finding carry-forward")
    return payload


def render_markdown(payload: dict) -> str:
    lines = [
        "## Historical Finding Dispositions",
        "",
        "Derived from the authoritative TODO. These items are carry-forward context for no-context reviewers and promotion loops.",
        "",
        "### Reopen Policy",
    ]
    for line in payload["policy_lines"]:
        lines.append(f"- {line}")
    lines.extend(["", "### Recorded Dispositions"])
    if not payload["entries"]:
        lines.append("- none recorded in the authoritative TODO")
        return "\n".join(lines) + "\n"

    for entry in payload["entries"]:
        lines.extend(
            [
                f"- `{entry['source_kind']} / {entry['finding_id']}` -> `{entry['carry_forward_class']}`",
                f"  - Disposition: {entry['source_disposition']}",
                f"  - Summary: {entry['summary']}",
                f"  - Reference: {entry['reference']}",
            ]
        )
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract historical finding dispositions from a tactical TODO.")
    parser.add_argument("--todo", required=True, help="Path to the tactical TODO markdown file.")
    parser.add_argument("--json-output", help="Optional output path for the JSON packet.")
    parser.add_argument("--markdown-output", help="Optional output path for the markdown summary.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    payload = build_carry_forward_packet(todo_path, Path.cwd())
    rendered_json = json.dumps(payload, indent=2) + "\n"
    rendered_markdown = render_markdown(payload)

    if args.json_output:
        write_json(Path(args.json_output).resolve(), payload)
    else:
        print(rendered_json, end="")

    if args.markdown_output:
        markdown_path = Path(args.markdown_output).resolve()
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(rendered_markdown, encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
