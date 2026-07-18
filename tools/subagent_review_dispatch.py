#!/usr/bin/env python3
"""Build a derived no-context subagent dispatch packet for PACED review gates."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator

from finding_carry_forward_extract import build_carry_forward_packet


REPO_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_dispatch.schema.json"
RESULT_SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_result.schema.json"

CONFIG = {
    "architecture_opinion": {
        "axes": ["correctness", "performance", "elegance", "structural_soundness", "operational_fit"],
        "focus": [
            "Compare only viable architectural paths inside the bounded package.",
            "Name the recommended path and the main tradeoff behind that choice.",
            "State whether the path improves or regresses performance, elegance, and structural soundness.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]"
        ],
    },
    "architecture_adherence": {
        "axes": ["adherence", "structural_soundness", "operational_fit", "performance", "elegance"],
        "focus": [
            "Compare the delivered bounded package against the frozen Architecture Change Governance contract and Decision Baseline.",
            "Identify any implementation path, temporary exception, or missing protection harness that diverges from the approved target steady-state.",
            "Do not redesign the approved architecture unless the delivered evidence exposes a material defect or an approval-breaking divergence.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]",
        ],
    },
    "critique": {
        "axes": ["adherence", "performance", "elegance", "structural_soundness", "operational_fit"],
        "focus": [
            "Challenge the bounded plan or implementation for regressions, hidden scope, and weak adherence.",
            "Explicitly assess performance, elegance, structural soundness, and operational fit.",
            "Do not reopen unrelated architecture outside the bounded package.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]"
        ],
    },
    "test_quality_audit": {
        "axes": ["test_effectiveness", "test_efficiency", "performance", "structural_soundness", "operational_fit"],
        "focus": [
            "Verify whether changed tests reflect real behavior/contract change or only pass-the-test repair.",
            "Assess whether assertions are effective and efficient.",
            "State whether the audit sees brittle test-only shortcuts or weak coverage.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]"
        ],
    },
    "final_review": {
        "axes": ["adherence", "residual_risk", "performance", "elegance", "structural_soundness"],
        "focus": [
            "Review the delivered bounded package for regressions, adherence gaps, residual risk, and waiver quality.",
            "Explicitly call out any performance regressions, elegance regressions, or brittle structural shortcuts.",
            "Stay inside the bounded package and treat the review as closure-focused.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]"
        ],
    },
    "cutover_integrity_audit": {
        "axes": ["adherence", "structural_soundness", "operational_fit", "performance", "elegance"],
        "focus": [
            "Determine whether the chosen path is truly canonical or just a disguised workaround/bridge.",
            "Cross-check the governing TODO when provided: if it explicitly authorizes a compatibility shim, fallback bridge, or temporary dual-path, do not block the existence alone; instead assess whether the scope, rationale, and removal/closeout condition are explicit and coherent.",
            "Escalate as blocking when pseudo-canonical fields, silent fallback mirrors, dual-read/dual-write bridges, or query-time stitching are left as the effective final architecture without explicit bounded authorization.",
            "Treat style disagreement as non-blocking. The target is workaround architecture disguised as completion, not naming or formatting polish.",
            "For each material finding, add category and formalizable-hint when you can judge them honestly.",
        ],
        "result_fields": [
            "overall_assessment",
            "recommended_path",
            "performance_position",
            "elegance_position",
            "structural_soundness_position",
            "operational_fit_position",
            "findings[].finding_id (optional)",
            "findings[].category (optional)",
            "findings[].formalizable_hint (optional)",
            "findings[].candidate_rule_level (optional)",
            "findings[]"
        ],
    },
}


def validate_schema(payload: dict) -> None:
    validator = Draft202012Validator(json.loads(SCHEMA_PATH.read_text(encoding="utf-8")))
    errors = sorted(validator.iter_errors(payload), key=lambda item: list(item.absolute_path))
    if not errors:
        return

    rendered = []
    for error in errors:
        field = " -> ".join(str(part) for part in error.absolute_path) or "dispatch"
        rendered.append(f"{field}: {error.message}")
    raise SystemExit("subagent review dispatch failed schema validation:\n" + "\n".join(rendered))


def result_contract_lines(payload: dict) -> list[str]:
    """Render the canonical reviewer contract from the merge-validator schema."""
    schema = json.loads(RESULT_SCHEMA_PATH.read_text(encoding="utf-8"))
    properties = schema["properties"]
    finding = schema["$defs"]["finding"]
    finding_properties = finding["properties"]

    lines = [
        "## Result Contract",
        "Return exactly one JSON object and no Markdown fence or prose.",
        "Do not emit `null`; omit optional fields that do not apply.",
        "No top-level fields other than the following are allowed:",
    ]
    for field in schema["required"]:
        field_schema = properties[field]
        if "const" in field_schema:
            lines.append(f"- `{field}`: `{field_schema['const']}`")
        elif field == "dispatch_path":
            lines.append(f"- `{field}`: the exact binding shown above")
        elif field == "review_kind":
            lines.append(f"- `{field}`: `{payload['review_kind']}`")
        else:
            lines.append(f"- `{field}`")

    position_values = ", ".join(f"`{value}`" for value in schema["$defs"]["position"]["enum"])
    category_values = ", ".join(f"`{value}`" for value in finding_properties["category"]["enum"])
    severity_values = ", ".join(f"`{value}`" for value in finding_properties["severity"]["enum"])
    formalizable_values = ", ".join(
        f"`{value}`" for value in finding_properties["formalizable_hint"]["enum"]
    )
    candidate_rule_level_values = ", ".join(
        f"`{value}`" for value in finding_properties["candidate_rule_level"]["enum"]
    )
    optional_finding_fields = ", ".join(
        f"`{field}`" for field in finding_properties if field not in finding["required"]
    )
    lines.extend(
        [
            "",
            f"Every `*_position` value must be one of: {position_values}.",
            "Each finding may contain only these fields:",
            f"- required: {', '.join(f'`{field}`' for field in finding['required'])}",
            f"- optional: {optional_finding_fields}",
            f"- `severity` values: {severity_values}",
            f"- `category` values: {category_values}",
            f"- `formalizable_hint` values: {formalizable_values}",
            f"- `candidate_rule_level` values: {candidate_rule_level_values}",
        ]
    )
    return lines


def render_markdown(payload: dict) -> str:
    lines = [
        f"# PACED Subagent Dispatch: {payload['review_kind']}",
        "",
        "## Dispatch Identity",
        "- **Artifact kind:** `subagent_review_dispatch`",
        "- **Authoritative:** `false`",
        "- **Edit policy:** `derived_dispatch_packet`",
        f"- **Review kind:** `{payload['review_kind']}`",
        f"- **Bounded package:** `{payload['bounded_package_path']}`",
        f"- **Reviewer count:** `{payload['reviewer_count']}`",
        "- **No-context required:** `true`",
        "",
        "## Required Axes",
    ]
    for axis in payload["required_axes"]:
        lines.append(f"- `{axis}`")
    lines.extend(["", "## Focus Points"])
    for item in payload["focus_points"]:
        lines.append(f"- {item}")
    lines.extend(["", "## Required Result Fields"])
    for field in payload["result_contract_fields"]:
        lines.append(f"- `{field}`")
    result_dispatch_path = payload.get("review_result_dispatch_path")
    if result_dispatch_path:
        lines.extend(
            [
                "",
                "## Required Result Binding",
                "The reviewer result's `dispatch_path` must equal this exact dispatch JSON path:",
                f"`{result_dispatch_path}`",
                "Do not substitute the bounded package path, governing TODO path, or reviewer output path.",
            ]
        )
    if payload.get("goal"):
        lines.extend(["", "## Goal", payload["goal"]])
    if payload.get("todo_path"):
        lines.extend(
            [
                "",
                "## Related TODO",
                f"`{payload['todo_path']}`",
                "",
                "Reviewers must cross-check findings against the governing TODO's explicit decisions, approved exceptions, compatibility mandates, and non-goals before classifying something as blocking drift.",
            ]
        )
    if payload.get("historical_disposition_policy"):
        lines.extend(["", "## Historical Finding Carry-Forward", "Previously adjudicated findings are historical context, not automatic reopening triggers."])
        for policy_line in payload["historical_disposition_policy"]:
            lines.append(f"- {policy_line}")
    if payload.get("historical_dispositions"):
        lines.extend(["", "### Recorded Dispositions"])
        for entry in payload["historical_dispositions"]:
            lines.extend(
                [
                    f"- `{entry['source_kind']} / {entry['finding_id']}` -> `{entry['carry_forward_class']}`",
                    f"  - Disposition: {entry['source_disposition']}",
                    f"  - Summary: {entry['summary']}",
                    f"  - Reference: {entry['reference']}",
                ]
            )
    lines.extend(["", *result_contract_lines(payload), ""])
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a derived no-context subagent dispatch packet.")
    parser.add_argument("--review-kind", required=True, choices=sorted(CONFIG.keys()))
    parser.add_argument("--package", required=True, help="Bounded package path to hand to the reviewer.")
    parser.add_argument("--reviewer-count", type=int, default=1, help="Expected reviewer/subagent count.")
    parser.add_argument("--todo-path", help="Optional related TODO path.")
    parser.add_argument("--goal", help="Optional succinct review goal.")
    parser.add_argument("--json-output", help="Write the dispatch packet JSON to this path.")
    parser.add_argument("--markdown-output", help="Write the dispatch packet markdown to this path.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    config = CONFIG[args.review_kind]
    payload = {
        "schema_version": "subagent-review-dispatch-v1",
        "artifact_kind": "subagent_review_dispatch",
        "authoritative": False,
        "edit_policy": "derived_dispatch_packet",
        "review_kind": args.review_kind,
        "bounded_package_path": str(Path(args.package)),
        "reviewer_count": args.reviewer_count,
        "no_context_required": True,
        "required_axes": config["axes"],
        "focus_points": config["focus"],
        "result_contract_fields": config["result_fields"],
    }
    if args.todo_path:
        payload["todo_path"] = args.todo_path
        historical = build_carry_forward_packet(Path(args.todo_path).resolve(), Path.cwd())
        payload["historical_disposition_policy"] = historical["policy_lines"]
        payload["historical_dispositions"] = historical["entries"]
    if args.goal:
        payload["goal"] = args.goal
    if args.json_output:
        payload["review_result_dispatch_path"] = str(Path(args.json_output).resolve())

    validate_schema(payload)
    rendered_json = json.dumps(payload, indent=2) + "\n"
    rendered_markdown = render_markdown(payload) + "\n"

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
