#!/usr/bin/env python3
"""Turn a PACED project setup report into a non-authoritative normalization packet."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator


REPO_ROOT = Path(__file__).resolve().parent.parent
REPORT_SCHEMA_PATH = REPO_ROOT / "schemas" / "project_setup_report.schema.json"
PACKET_SCHEMA_PATH = REPO_ROOT / "schemas" / "project_normalization_packet.schema.json"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def validate_schema(payload: dict, schema_path: Path, label: str) -> None:
    validator = Draft202012Validator(load_json(schema_path))
    errors = sorted(validator.iter_errors(payload), key=lambda item: list(item.absolute_path))
    if not errors:
        return

    rendered = []
    for error in errors:
        field = " -> ".join(str(part) for part in error.absolute_path) or label
        rendered.append(f"{field}: {error.message}")
    joined = "\n".join(rendered)
    raise SystemExit(f"{label} failed schema validation:\n{joined}")


def track(
    track_id: str,
    action_type: str,
    reason: str,
    scope_boundary: str,
    suggested_owner: str,
    blocking_buckets: list[str],
    issue_count: int,
    suggested_todo_slug: str,
    requires_aprovado: bool,
    notes: list[str],
) -> dict:
    return {
        "track_id": track_id,
        "action_type": action_type,
        "reason": reason,
        "scope_boundary": scope_boundary,
        "suggested_owner": suggested_owner,
        "blocking_buckets": blocking_buckets,
        "issue_count": issue_count,
        "suggested_todo_slug": suggested_todo_slug,
        "requires_aprovado": requires_aprovado,
        "notes": notes,
    }


def derive_packet(report: dict) -> dict:
    issues = report["issues"]
    derived_tracks: list[dict] = []

    if report["overall_status"] == "bootstrap-preflight-ready":
        bootstrap_notes = (
            issues["documentation"]
            + issues["canonical_coverage"]
            + issues["governance"]
            + ["Bootstrap may still need canonical project docs instantiated before normal feature work."]
        )
        return {
            "schema_version": "project-normalization-packet-v1",
            "artifact_kind": "project_normalization_packet",
            "authoritative": False,
            "edit_policy": "derived_assistive_packet",
            "source_report_path": report["source_report_path"],
            "repo_root": report["repo_root"],
            "lane_effective": report["lane_effective"],
            "overall_status": report["overall_status"],
            "recommended_next_step": report["recommended_next_step"],
            "manual_remediation_required": False,
            "normalization_todo_required": False,
            "tracks": [
                track(
                    track_id="continue-bootstrap",
                    action_type="observe_only",
                    reason="Bootstrap preflight passed. Missing canonical project surfaces are expected bootstrap outputs, not brownfield normalization debt.",
                    scope_boundary="Continue Genesis/installation/bootstrap work until the first canonical package exists.",
                    suggested_owner="Genesis / Product-Bootstrap",
                    blocking_buckets=[],
                    issue_count=len(bootstrap_notes),
                    suggested_todo_slug="",
                    requires_aprovado=False,
                    notes=bootstrap_notes,
                )
            ],
            "exact_next_step": "Continue bootstrap/Genesis installation work before normal feature execution.",
        }

    structural_issues = issues["structural"]
    if structural_issues:
        derived_tracks.append(
            track(
                track_id="delphi-surface-repair",
                action_type="manual_remediation",
                reason="Delphi-managed readiness or surface drift must be cleared before feature work or normalization TODO execution can be trusted.",
                scope_boundary="Delphi-managed installation surfaces, readiness blockers, linked bootloaders, and local workspace wiring.",
                suggested_owner="Operational/DevOps",
                blocking_buckets=["structural"],
                issue_count=len(structural_issues),
                suggested_todo_slug="",
                requires_aprovado=False,
                notes=structural_issues,
            )
        )

    authority_issues = issues["documentation"] + issues["governance"]
    authority_buckets = []
    if issues["documentation"]:
        authority_buckets.append("documentation")
    if issues["governance"]:
        authority_buckets.append("governance")
    if authority_issues:
        derived_tracks.append(
            track(
                track_id="project-authority-normalization",
                action_type="normalization_todo",
                reason="Project-owned authority surfaces are incomplete or drifted and need an explicit normalization packet before ordinary feature work resumes.",
                scope_boundary="project_mandate, domain_entities, project_constitution, scope/subscope governance, and directly related governance handoffs.",
                suggested_owner="Strategic or Operational with Strategic review",
                blocking_buckets=authority_buckets,
                issue_count=len(authority_issues),
                suggested_todo_slug="normalize-project-authority",
                requires_aprovado=True,
                notes=authority_issues,
            )
        )

    coverage_issues = issues["canonical_coverage"]
    if coverage_issues:
        derived_tracks.append(
            track(
                track_id="canonical-coverage-normalization",
                action_type="normalization_todo",
                reason="Module and roadmap coverage drift should be normalized into canonical project surfaces instead of carried as session knowledge.",
                scope_boundary="system_roadmap and module coverage only; keep unrelated product change out of this packet.",
                suggested_owner="Operational with Strategic confirmation",
                blocking_buckets=["canonical_coverage"],
                issue_count=len(coverage_issues),
                suggested_todo_slug="normalize-canonical-coverage",
                requires_aprovado=True,
                notes=coverage_issues,
            )
        )

    if not derived_tracks:
        derived_tracks.append(
            track(
                track_id="no-normalization-needed",
                action_type="observe_only",
                reason="The setup report does not currently indicate any normalization or manual remediation track.",
                scope_boundary="No normalization packet should be opened from this report.",
                suggested_owner="Current operator",
                blocking_buckets=[],
                issue_count=0,
                suggested_todo_slug="",
                requires_aprovado=False,
                notes=["Proceed with normal work unless a newer report changes the status."],
            )
        )

    if report["overall_status"] == "manual-remediation-required":
        exact_next_step = (
            "Clear the manual remediation track(s), rerun `delphi_project_setup_report.sh`, "
            "and regenerate this packet before opening any normalization TODO."
        )
    elif report["overall_status"] == "needs-normalization":
        exact_next_step = (
            "Open or update the recommended normalization TODO track(s), request `APROVADO`, "
            "and execute them through the TODO-driven method."
        )
    elif report["overall_status"] == "bootstrap-preflight-ready":
        exact_next_step = "Continue bootstrap/Genesis installation work before normal feature execution."
    else:
        exact_next_step = "Proceed with normal work; this packet is informational only."

    normalization_required = report["overall_status"] == "needs-normalization" or any(
        item["action_type"] == "normalization_todo" for item in derived_tracks
    )

    packet = {
        "schema_version": "project-normalization-packet-v1",
        "artifact_kind": "project_normalization_packet",
        "authoritative": False,
        "edit_policy": "derived_assistive_packet",
        "source_report_path": report["source_report_path"],
        "repo_root": report["repo_root"],
        "lane_effective": report["lane_effective"],
        "overall_status": report["overall_status"],
        "recommended_next_step": report["recommended_next_step"],
        "manual_remediation_required": report["overall_status"] == "manual-remediation-required",
        "normalization_todo_required": normalization_required,
        "tracks": derived_tracks,
        "exact_next_step": exact_next_step,
    }
    return packet


def render_markdown(packet: dict) -> str:
    lines = [
        "# PACED Brownfield Normalization Packet",
        "",
        "## Packet Identity",
        "- **Artifact kind:** `project_normalization_packet`",
        "- **Authoritative:** `false`",
        "- **Edit policy:** `derived_assistive_packet`",
        f"- **Source report:** `{packet['source_report_path']}`",
        f"- **Lane:** `{packet['lane_effective']}`",
        f"- **Overall status:** `{packet['overall_status']}`",
        f"- **Recommended next step from report:** `{packet['recommended_next_step']}`",
        "",
        "## Recommended Tracks",
    ]

    for index, item in enumerate(packet["tracks"], start=1):
        lines.extend(
            [
                f"### {index}. {item['track_id']}",
                f"- **Action type:** `{item['action_type']}`",
                f"- **Reason:** {item['reason']}",
                f"- **Scope boundary:** {item['scope_boundary']}",
                f"- **Suggested owner:** `{item['suggested_owner']}`",
                f"- **Blocking buckets:** `{', '.join(item['blocking_buckets']) if item['blocking_buckets'] else 'none'}`",
                f"- **Issue count:** `{item['issue_count']}`",
                f"- **Suggested TODO slug:** `{item['suggested_todo_slug'] or 'n/a'}`",
                f"- **Requires APROVADO:** `{str(item['requires_aprovado']).lower()}`",
            ]
        )
        if item["notes"]:
            lines.append("- **Notes:**")
            for note in item["notes"]:
                lines.append(f"  - {note}")
        lines.append("")

    lines.extend(
        [
            "## Exact Next Step",
            packet["exact_next_step"],
            "",
            "## Usage Boundary",
            "This packet is assistive only. Do not treat it as canonical project authority or as a substitute for the downstream tactical TODO(s).",
            "",
        ]
    )
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Derive a non-authoritative brownfield normalization packet from a PACED project setup report."
    )
    parser.add_argument("--report", required=True, help="Path to the project setup report JSON.")
    parser.add_argument("--json-output", help="Write the derived normalization packet JSON to this path.")
    parser.add_argument("--markdown-output", help="Write the derived normalization packet markdown to this path.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    report_path = Path(args.report).resolve()
    report = load_json(report_path)
    validate_schema(report, REPORT_SCHEMA_PATH, "project setup report")
    report = {**report, "source_report_path": str(report_path)}

    packet = derive_packet(report)
    validate_schema(packet, PACKET_SCHEMA_PATH, "project normalization packet")

    rendered_json = json.dumps(packet, indent=2) + "\n"
    rendered_markdown = render_markdown(packet)
    if not rendered_markdown.endswith("\n"):
        rendered_markdown += "\n"

    if args.json_output:
        json_output_path = Path(args.json_output)
        json_output_path.parent.mkdir(parents=True, exist_ok=True)
        json_output_path.write_text(rendered_json, encoding="utf-8")

    if args.markdown_output:
        markdown_output_path = Path(args.markdown_output)
        markdown_output_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_output_path.write_text(rendered_markdown, encoding="utf-8")
    else:
        print(rendered_markdown, end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
