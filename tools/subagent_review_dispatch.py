#!/usr/bin/env python3
"""Build a derived no-context subagent dispatch packet for PACED review gates."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator


REPO_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_dispatch.schema.json"

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
    if payload.get("goal"):
        lines.extend(["", "## Goal", payload["goal"]])
    if payload.get("todo_path"):
        lines.extend(["", "## Related TODO", f"`{payload['todo_path']}`"])
    lines.extend(
        [
            "",
            "## Result Contract",
            "Each reviewer should answer in JSON compatible with `schemas/subagent_review_result.schema.json`.",
            "",
        ]
    )
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
    if args.goal:
        payload["goal"] = args.goal

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
