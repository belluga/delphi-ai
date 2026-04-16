#!/usr/bin/env python3
"""Extract machine-checkable gate finding resolutions from a tactical TODO."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from paced_metrics_core import normalize_repo_relative, validate_schema, write_json
import todo_validation_bundle_export as exporter


REVIEW_CONFIG = {
    "critique": {
        "heading": "## Independent No-Context Critique Gate",
        "status_label": "Critique status",
    },
    "test_quality_audit": {
        "heading": "## Independent Test Quality Audit Gate",
        "status_label": "Audit status",
    },
    "final_review": {
        "heading": "## Independent No-Context Final Review Gate",
        "status_label": "Final review status",
    },
}

ALLOWED_RESOLUTIONS = {"Integrated", "Challenged", "Deferred"}
ALLOWED_USEFULNESS = {"useful", "noise", "mixed", "unknown"}
ALLOWED_FORMALIZABLE = {"yes", "partial", "no", "unknown"}
ALLOWED_RULE_LEVELS = {"paced", "project", "none", "unknown"}


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def find_section_start(lines: list[str], heading_prefix: str) -> int | None:
    for index, line in enumerate(lines):
        if line.strip().startswith(heading_prefix):
            return index + 1
    return None


def parse_resolution_rows(lines: list[str], heading_prefix: str) -> list[dict]:
    start = find_section_start(lines, heading_prefix)
    if start is None:
        return []

    rows: list[list[str]] = []
    found_header = False
    for line in lines[start:]:
        stripped = line.strip()
        if stripped.startswith("## ") and not stripped.startswith(heading_prefix):
            break
        # Accept both '| ...' and '- | ...' (bullet-list-wrapped tables)
        table_line = stripped
        if table_line.startswith("- "):
            table_line = table_line[2:].strip()
        if not table_line.startswith("|"):
            continue
        cells = [cell.strip().strip("`") for cell in table_line.strip("|").split("|")]
        if not found_header:
            if cells and cells[0] == "Finding ID":
                found_header = True
            continue
        if all(set(cell) <= {"-"} for cell in cells):
            continue
        if len(cells) < 7 or cells[0].startswith("<"):
            continue
        rows.append(cells[:7])

    findings: list[dict] = []
    for row in rows:
        finding = {
            "finding_id": row[0],
            "resolution": row[1],
            "usefulness": row[2],
            "formalizable": row[3],
            "candidate_rule_level": row[4],
            "candidate_rule_id": row[5],
            "rationale": row[6],
        }
        findings.append(finding)
    return findings


def validate_findings(findings: list[dict]) -> None:
    for finding in findings:
        if finding["resolution"] not in ALLOWED_RESOLUTIONS:
            raise SystemExit(f"invalid resolution for {finding['finding_id']}: {finding['resolution']}")
        if finding["usefulness"] not in ALLOWED_USEFULNESS:
            raise SystemExit(f"invalid usefulness for {finding['finding_id']}: {finding['usefulness']}")
        if finding["formalizable"] not in ALLOWED_FORMALIZABLE:
            raise SystemExit(f"invalid formalizable value for {finding['finding_id']}: {finding['formalizable']}")
        if finding["candidate_rule_level"] not in ALLOWED_RULE_LEVELS:
            raise SystemExit(f"invalid candidate rule level for {finding['finding_id']}: {finding['candidate_rule_level']}")
        if not finding["candidate_rule_id"]:
            raise SystemExit(f"candidate_rule_id must be present for {finding['finding_id']} (use `n/a` when none)")
        if not finding["rationale"]:
            raise SystemExit(f"rationale must be present for {finding['finding_id']}")


def build_resolution_packet(todo_path: Path, review_kind: str, repo_root: Path | None = None) -> dict:
    if review_kind not in REVIEW_CONFIG:
        raise SystemExit(f"unsupported review_kind: {review_kind}")

    config = REVIEW_CONFIG[review_kind]
    lines = read_lines(todo_path)
    findings = parse_resolution_rows(lines, config["heading"])
    validate_findings(findings)
    gate_status = exporter.extract_field_in_section(lines, config["heading"], config["status_label"])
    if gate_status == "findings_integrated" and not findings:
        raise SystemExit(
            f"{review_kind} gate is `findings_integrated` but no machine-checkable finding rows were found in {todo_path}."
        )
    payload = {
        "schema_version": "gate-finding-resolution-v1",
        "artifact_kind": "gate_finding_resolution",
        "authoritative": False,
        "edit_policy": "derived_from_todo",
        "todo_path": normalize_repo_relative(todo_path, repo_root or Path.cwd()),
        "review_kind": review_kind,
        "gate_status": gate_status,
        "findings": findings,
    }
    validate_schema(payload, "gate_finding_resolution.schema.json", "gate finding resolution")
    return payload


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract gate finding resolution data from a tactical TODO.")
    parser.add_argument("--todo", required=True, help="Path to the tactical TODO markdown file.")
    parser.add_argument("--review-kind", required=True, choices=sorted(REVIEW_CONFIG.keys()))
    parser.add_argument("--output", help="Optional output path for the derived JSON packet.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    payload = build_resolution_packet(todo_path, args.review_kind, Path.cwd())
    if args.output:
        write_json(Path(args.output).resolve(), payload)
    else:
        print(json.dumps(payload, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
