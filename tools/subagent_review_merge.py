#!/usr/bin/env python3
"""Merge PACED no-context subagent review results into a derived summary packet."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator

from paced_metrics_core import combine_candidate_rule_levels, combine_formalizable_hints, normalize_text, short_hash


REPO_ROOT = Path(__file__).resolve().parent.parent
DISPATCH_SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_dispatch.schema.json"
RESULT_SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_result.schema.json"
MERGE_SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_merge.schema.json"
SEVERITY_ORDER = {"none": 0, "low": 1, "medium": 2, "high": 3}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def validate(payload: dict, schema_path: Path, label: str) -> None:
    validator = Draft202012Validator(load_json(schema_path))
    errors = sorted(validator.iter_errors(payload), key=lambda item: list(item.absolute_path))
    if not errors:
        return

    rendered = []
    for error in errors:
        field = " -> ".join(str(part) for part in error.absolute_path) or label
        rendered.append(f"{field}: {error.message}")
    raise SystemExit(f"{label} failed schema validation:\n" + "\n".join(rendered))


def summarize_axis(values: list[str]) -> str:
    unique = sorted(set(values))
    if len(unique) == 1:
        return unique[0]
    return "mixed: " + ", ".join(unique)


def highest_finding_severity(results: list[dict]) -> str:
    level = 0
    for result in results:
        for finding in result["findings"]:
            level = max(level, SEVERITY_ORDER[finding["severity"]])
    for severity, score in SEVERITY_ORDER.items():
        if score == level:
            return severity
    return "none"


def finding_fingerprint(review_kind: str, finding: dict) -> str:
    category = finding.get("category", "other")
    return short_hash(
        review_kind,
        category,
        normalize_text(finding["title"]),
        normalize_text(finding["rationale"]),
        normalize_text(finding["suggested_action"]),
        length=16,
    )


def merged_findings(results: list[dict], review_kind: str) -> list[dict]:
    merged: dict[str, dict] = {}
    for result in results:
        for index, finding in enumerate(result["findings"], start=1):
            fingerprint = finding_fingerprint(review_kind, finding)
            source_finding_id = finding.get("finding_id") or f"{result['reviewer_label']}-{index}"
            record = merged.setdefault(
                fingerprint,
                {
                    "finding_id": f"F-{fingerprint[:8].upper()}",
                    "severity": finding["severity"],
                    "title": finding["title"],
                    "rationale": finding["rationale"],
                    "suggested_action": finding["suggested_action"],
                    "reviewer_labels": [],
                    "source_finding_ids": [],
                    "category": finding.get("category", "other"),
                    "formalizable_hints": [],
                    "candidate_rule_levels": [],
                    "candidate_rule_ids": [],
                },
            )
            if SEVERITY_ORDER[finding["severity"]] > SEVERITY_ORDER[record["severity"]]:
                record["severity"] = finding["severity"]
            if result["reviewer_label"] not in record["reviewer_labels"]:
                record["reviewer_labels"].append(result["reviewer_label"])
            if source_finding_id not in record["source_finding_ids"]:
                record["source_finding_ids"].append(source_finding_id)
            record["formalizable_hints"].append(finding.get("formalizable_hint", "unknown"))
            record["candidate_rule_levels"].append(finding.get("candidate_rule_level", "unknown"))
            candidate_rule_id = finding.get("candidate_rule_id", "")
            if candidate_rule_id:
                record["candidate_rule_ids"].append(candidate_rule_id)

    normalized: list[dict] = []
    for fingerprint, finding in sorted(merged.items(), key=lambda item: (SEVERITY_ORDER[item[1]["severity"]], item[1]["title"]), reverse=True):
        candidate_rule_ids = sorted({item for item in finding["candidate_rule_ids"] if item})
        normalized_record = {
            "finding_id": finding["finding_id"],
            "severity": finding["severity"],
            "title": finding["title"],
            "rationale": finding["rationale"],
            "suggested_action": finding["suggested_action"],
            "reviewer_labels": finding["reviewer_labels"],
            "source_finding_ids": finding["source_finding_ids"],
            "category": finding["category"],
            "formalizable_hint": combine_formalizable_hints(finding["formalizable_hints"]),
            "candidate_rule_level": combine_candidate_rule_levels(finding["candidate_rule_levels"]),
            "candidate_rule_id": "n/a",
        }
        if len(candidate_rule_ids) == 1:
            normalized_record["candidate_rule_id"] = candidate_rule_ids[0]
        elif len(candidate_rule_ids) > 1:
            normalized_record["candidate_rule_id"] = "multiple"
            normalized_record["candidate_rule_id_options"] = candidate_rule_ids
        normalized.append(normalized_record)
    return normalized


def render_markdown(payload: dict, results: list[dict]) -> str:
    lines = [
        f"# PACED Subagent Review Merge: {payload['review_kind']}",
        "",
        "## Merge Identity",
        "- **Artifact kind:** `subagent_review_merge`",
        "- **Authoritative:** `false`",
        "- **Edit policy:** `derived_merge_packet`",
        f"- **Dispatch path:** `{payload['dispatch_path']}`",
        f"- **Review count:** `{payload['review_count']}`",
        f"- **Highest finding severity:** `{payload['highest_finding_severity']}`",
        "",
        "## Axis Summary",
        f"- **Performance:** `{payload['axis_summary']['performance']}`",
        f"- **Elegance:** `{payload['axis_summary']['elegance']}`",
        f"- **Structural soundness:** `{payload['axis_summary']['structural_soundness']}`",
        f"- **Operational fit:** `{payload['axis_summary']['operational_fit']}`",
        "",
        "## Recommended Paths",
    ]
    for item in payload["recommended_paths"]:
        lines.append(f"- `{item}`")
    lines.extend(["", "## Merged Findings"])
    if payload["findings"]:
        for finding in payload["findings"]:
                lines.extend(
                [
                    f"### {finding['finding_id']} [{finding['severity']}] {finding['title']}",
                    f"- **Reviewers:** {', '.join(finding['reviewer_labels'])}",
                    f"- **Category:** `{finding['category']}`",
                    f"- **Formalizable hint:** `{finding['formalizable_hint']}`",
                    f"- **Candidate rule level:** `{finding['candidate_rule_level']}`",
                    f"- **Candidate rule id:** `{finding['candidate_rule_id']}`",
                    *(
                        [f"- **Candidate rule id options:** `{', '.join(finding['candidate_rule_id_options'])}`"]
                        if finding.get("candidate_rule_id_options")
                        else []
                    ),
                    f"- **Suggested action:** {finding['suggested_action']}",
                    f"- **Rationale:** {finding['rationale']}",
                    "",
                ]
            )
    else:
        lines.append("- `none`")
        lines.append("")

    lines.extend(["## Reviewer Summaries"])
    for result in results:
        lines.extend(
            [
                f"### {result['reviewer_label']}",
                f"- **Assessment:** {result['overall_assessment']}",
                f"- **Recommended path:** `{result['recommended_path']}`",
                f"- **Performance:** `{result['performance_position']}`",
                f"- **Elegance:** `{result['elegance_position']}`",
                f"- **Structural soundness:** `{result['structural_soundness_position']}`",
                f"- **Operational fit:** `{result['operational_fit_position']}`",
            ]
        )
        if result["findings"]:
            lines.append("- **Findings:**")
            for finding in result["findings"]:
                rendered_id = finding.get("finding_id") or "derived-at-merge"
                lines.append(f"  - [{finding['severity']}] {rendered_id} {finding['title']}: {finding['rationale']}")
        lines.append("")

    lines.extend(["## Exact Next Step", payload["exact_next_step"], ""])
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Merge PACED subagent review results into a derived summary packet.")
    parser.add_argument("--dispatch", required=True, help="Dispatch packet JSON path.")
    parser.add_argument("--review", required=True, action="append", help="Review result JSON path. Repeat for multiple reviewers.")
    parser.add_argument("--json-output", help="Write the merged review packet JSON to this path.")
    parser.add_argument("--markdown-output", help="Write the merged review packet markdown to this path.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    dispatch_path = Path(args.dispatch).resolve()
    dispatch = load_json(dispatch_path)
    validate(dispatch, DISPATCH_SCHEMA_PATH, "subagent dispatch")

    results = [load_json(Path(item).resolve()) for item in args.review]
    for result in results:
        validate(result, RESULT_SCHEMA_PATH, "subagent review result")
        if result["review_kind"] != dispatch["review_kind"]:
            raise SystemExit("subagent review result kind does not match dispatch kind")
        if Path(result["dispatch_path"]).resolve() != dispatch_path:
            raise SystemExit("subagent review result dispatch_path does not match the merge dispatch")

    reviewer_labels = [item["reviewer_label"] for item in results]
    recommended_paths = sorted({item["recommended_path"] for item in results})
    highest_severity = highest_finding_severity(results)
    findings = merged_findings(results, dispatch["review_kind"])

    payload = {
        "schema_version": "subagent-review-merge-v2",
        "artifact_kind": "subagent_review_merge",
        "authoritative": False,
        "edit_policy": "derived_merge_packet",
        "dispatch_path": str(dispatch_path),
        "review_kind": dispatch["review_kind"],
        "review_count": len(results),
        "reviewer_labels": reviewer_labels,
        "highest_finding_severity": highest_severity,
        "axis_summary": {
            "performance": summarize_axis([item["performance_position"] for item in results]),
            "elegance": summarize_axis([item["elegance_position"] for item in results]),
            "structural_soundness": summarize_axis([item["structural_soundness_position"] for item in results]),
            "operational_fit": summarize_axis([item["operational_fit_position"] for item in results]),
        },
        "recommended_paths": recommended_paths,
        "exact_next_step": (
            "Record reviewer resolutions in the governing TODO using the machine-checkable resolution table or equivalent gate ledger, "
            "then extract the derived resolution packet and decide whether another bounded review pass is still required."
        ),
        "findings": findings,
    }
    validate(payload, MERGE_SCHEMA_PATH, "subagent review merge")

    rendered_json = json.dumps(payload, indent=2) + "\n"
    rendered_markdown = render_markdown(payload, results) + "\n"

    if args.json_output:
        json_path = Path(args.json_output)
        json_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(rendered_json, encoding="utf-8")
    else:
        print(rendered_json, end="")

    if args.markdown_output:
        markdown_path = Path(args.markdown_output)
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(rendered_markdown, encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
