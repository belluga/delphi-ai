#!/usr/bin/env python3
"""Aggregate PACED rule/gate metrics and derive project clean rates."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from gate_finding_resolution_extract import build_resolution_packet
from paced_metrics_core import load_jsonl, normalize_repo_relative, utc_now, validate_schema, write_json
from todo_validation_bundle_export import build_bundle


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Aggregate PACED metrics into a derived summary.")
    parser.add_argument("--repo", default=".", help="Project repository root.")
    parser.add_argument(
        "--events-jsonl",
        default="foundation_documentation/artifacts/metrics/events/rule-events.jsonl",
        help="Path to the rule events JSONL ledger, relative to --repo unless absolute.",
    )
    parser.add_argument("--summary-json", required=True, help="Output path for the JSON summary.")
    parser.add_argument("--summary-markdown", help="Optional output path for the markdown summary.")
    return parser.parse_args()


def discover_closed_todos(repo_root: Path) -> list[Path]:
    todos_root = repo_root / "foundation_documentation" / "todos"
    if not todos_root.exists():
        return []

    discovered: list[Path] = []
    for path in todos_root.rglob("*.md"):
        normalized = str(path).replace("\\", "/")
        if "/ephemeral/" in normalized:
            continue
        try:
            bundle = build_bundle(path)
        except Exception:
            continue
        if bundle.get("artifact_type") != "tactical_execution_contract":
            continue
        delivery = bundle.get("delivery_status", {})
        if bundle.get("artifact_state") == "completed" or delivery.get("stage") == "Production-Ready":
            discovered.append(path)
    return sorted(discovered)


def load_rule_events(events_path: Path) -> tuple[dict[str, dict], int, dict[str, int]]:
    if not events_path.exists():
        return {}, 0, {"true_positive": 0, "false_positive": 0}

    events = load_jsonl(events_path)
    episodes: dict[str, dict] = {}
    recalibrations = 0
    resolution_counts = {"true_positive": 0, "false_positive": 0}
    for event in events:
        kind = event["event_kind"]
        if kind == "rule_state_changed" and event.get("from_state") == "ready" and event.get("to_state") == "adjusting":
            recalibrations += 1
            continue
        episode_id = event.get("episode_id")
        if not episode_id:
            continue
        record = episodes.setdefault(
            episode_id,
            {
                "todo_path": event.get("todo_path", ""),
                "observed": False,
                "resolution": None,
                "escape": False,
            },
        )
        if event.get("todo_path"):
            record["todo_path"] = event["todo_path"]
        if kind == "rule_block_observed":
            record["observed"] = True
            record["resolution"] = None
        elif kind == "rule_episode_resolved":
            record["resolution"] = event.get("outcome", "unknown")
            if event.get("outcome") in resolution_counts:
                resolution_counts[event["outcome"]] += 1
        elif kind == "rule_escape_recorded":
            record["escape"] = True
    return episodes, recalibrations, resolution_counts


def safe_rate(numerator: int, denominator: int) -> float:
    if denominator <= 0:
        return 0.0
    return round(numerator / denominator, 4)


def render_markdown(payload: dict) -> str:
    lines = [
        "# PACED Metrics Summary",
        "",
        f"- **Generated at:** `{payload['generated_at']}`",
        f"- **Closed TODO count:** `{payload['closed_todo_count']}`",
        "",
        "## Clean Rates",
        f"- **Deterministic clean rate:** `{payload['clean_rates']['deterministic_clean_rate']}`",
        f"- **Gate clean rate:** `{payload['clean_rates']['gate_clean_rate']}`",
        f"- **Work clean rate:** `{payload['clean_rates']['work_clean_rate']}`",
        "",
        "## Rule Metrics",
        f"- **Block episodes:** `{payload['rule_metrics']['block_episodes']}`",
        f"- **True positives:** `{payload['rule_metrics']['true_positives']}`",
        f"- **False positives:** `{payload['rule_metrics']['false_positives']}`",
        f"- **Escapes:** `{payload['rule_metrics']['escapes']}`",
        f"- **Recalibrations:** `{payload['rule_metrics']['recalibrations']}`",
        "",
        "## Gate Metrics",
        f"- **Executed gates:** `{payload['gate_metrics']['executed_gate_count']}`",
        f"- **Clean gates:** `{payload['gate_metrics']['clean_gate_count']}`",
        f"- **Useful findings:** `{payload['gate_metrics']['useful_findings']}`",
        f"- **Discarded findings:** `{payload['gate_metrics']['discarded_findings']}`",
        f"- **Mixed findings:** `{payload['gate_metrics']['mixed_findings']}`",
        f"- **Formalizable yes:** `{payload['gate_metrics']['formalizable_yes']}`",
        f"- **Formalizable partial:** `{payload['gate_metrics']['formalizable_partial']}`",
    ]
    if payload.get("todo_summaries"):
        lines.extend(["", "## TODO Summaries"])
        for todo in payload["todo_summaries"]:
            lines.append(
                f"- `{todo['todo_path']}` -> rule_blocked=`{str(todo['rule_blocked']).lower()}`, useful_gate_findings=`{todo['useful_gate_findings']}`, clean_work=`{str(todo['clean_work']).lower()}`"
            )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo).resolve()
    events_path = Path(args.events_jsonl)
    if not events_path.is_absolute():
        events_path = (repo_root / events_path).resolve()

    episodes, recalibrations, resolution_counts = load_rule_events(events_path)
    closed_todos = discover_closed_todos(repo_root)
    closed_todo_paths = {normalize_repo_relative(path, repo_root) for path in closed_todos}

    block_episodes = {episode_id: record for episode_id, record in episodes.items() if record["todo_path"] in closed_todo_paths and record["observed"]}
    escape_episodes = {episode_id: record for episode_id, record in episodes.items() if record["todo_path"] in closed_todo_paths and record["escape"]}
    true_positives = resolution_counts["true_positive"]
    false_positives = resolution_counts["false_positive"]
    escapes = len(escape_episodes)

    executed_gate_count = 0
    clean_gate_count = 0
    useful_findings = 0
    discarded_findings = 0
    mixed_findings = 0
    formalizable_yes = 0
    formalizable_partial = 0
    clean_todos = 0
    todo_summaries: list[dict] = []

    for todo_path in closed_todos:
        bundle = build_bundle(todo_path)
        relative_todo = normalize_repo_relative(todo_path, repo_root)
        todo_has_rule_block = any(record["todo_path"] == relative_todo and record["observed"] for record in episodes.values())
        todo_has_escape = any(record["todo_path"] == relative_todo and record["escape"] for record in episodes.values())
        todo_useful_findings = 0
        todo_all_gates_clean = True

        # Iterate over all gates present in the bundle dynamically
        # instead of hardcoded REVIEW_KINDS — respects namespace-specific gates
        bundle_gates = bundle.get("gates", {})
        for gate_id, gate in bundle_gates.items():
            if gate.get("decision") == "not_needed":
                continue
            executed_gate_count += 1

            if gate.get("status") == "no_material_findings":
                clean_gate_count += 1
                continue

            if gate.get("status") != "findings_integrated":
                todo_all_gates_clean = False
                continue

            try:
                packet = build_resolution_packet(todo_path, gate_id, repo_root)
            except (SystemExit, Exception):
                todo_all_gates_clean = False
                continue
            gate_useful = 0
            for finding in packet.get("findings", []):
                usefulness = finding.get("usefulness", "unknown")
                if usefulness == "useful":
                    useful_findings += 1
                    gate_useful += 1
                elif usefulness == "noise":
                    discarded_findings += 1
                elif usefulness == "mixed":
                    mixed_findings += 1
                    gate_useful += 1

                if usefulness in {"useful", "mixed"}:
                    if finding.get("formalizable") == "yes":
                        formalizable_yes += 1
                    elif finding.get("formalizable") == "partial":
                        formalizable_partial += 1

            todo_useful_findings += gate_useful
            if gate_useful == 0:
                clean_gate_count += 1
            else:
                todo_all_gates_clean = False

        clean_work = not todo_has_rule_block and not todo_has_escape and todo_useful_findings == 0 and todo_all_gates_clean
        if clean_work:
            clean_todos += 1

        todo_summaries.append(
            {
                "todo_path": relative_todo,
                "rule_blocked": todo_has_rule_block,
                "useful_gate_findings": todo_useful_findings,
                "clean_work": clean_work,
            }
        )

    payload = {
        "schema_version": "paced-metrics-summary-v1",
        "artifact_kind": "paced_metrics_summary",
        "generated_at": utc_now(),
        "closed_todo_count": len(closed_todos),
        "rule_metrics": {
            "block_episodes": len(block_episodes),
            "true_positives": true_positives,
            "false_positives": false_positives,
            "escapes": escapes,
            "recalibrations": recalibrations,
        },
        "gate_metrics": {
            "executed_gate_count": executed_gate_count,
            "clean_gate_count": clean_gate_count,
            "useful_findings": useful_findings,
            "discarded_findings": discarded_findings,
            "mixed_findings": mixed_findings,
            "formalizable_yes": formalizable_yes,
            "formalizable_partial": formalizable_partial,
        },
        "clean_rates": {
            "deterministic_clean_rate": safe_rate(
                len(closed_todos) - len({record["todo_path"] for record in block_episodes.values()} | {record["todo_path"] for record in escape_episodes.values()}),
                len(closed_todos),
            ),
            "gate_clean_rate": safe_rate(clean_gate_count, executed_gate_count),
            "work_clean_rate": safe_rate(clean_todos, len(closed_todos)),
        },
        "todo_summaries": todo_summaries,
    }
    validate_schema(payload, "paced_metrics_summary.schema.json", "paced metrics summary")

    write_json(Path(args.summary_json).resolve(), payload)
    if args.summary_markdown:
        output_path = Path(args.summary_markdown).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(render_markdown(payload), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
