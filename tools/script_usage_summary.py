#!/usr/bin/env python3
"""Aggregate deterministic script-usage telemetry into derived local Delphi summaries."""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from pathlib import Path

from paced_metrics_core import load_jsonl, utc_now, validate_schema, write_json


DEFAULT_EVENTS_PATH = "artifacts/local/metrics/events/script-usage.jsonl"
DEFAULT_SUMMARY_JSON = "artifacts/local/metrics/script-usage-summary.json"
DEFAULT_SUMMARY_MARKDOWN = "artifacts/local/metrics/script-usage-summary.md"
STATUS_KEYS = ("passed", "failed", "usage_error", "interrupted")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Aggregate script-usage telemetry into a derived summary.")
    parser.add_argument("--repo", default=".", help="Delphi repository root.")
    parser.add_argument("--events-jsonl", default=DEFAULT_EVENTS_PATH, help="Ledger path, relative to --repo unless absolute.")
    parser.add_argument("--summary-json", default=DEFAULT_SUMMARY_JSON, help="Output path for the JSON summary.")
    parser.add_argument("--summary-markdown", default=DEFAULT_SUMMARY_MARKDOWN, help="Optional output path for the markdown summary.")
    return parser.parse_args()


def resolve_path(repo_root: Path, raw_path: str) -> Path:
    candidate = Path(raw_path)
    if candidate.is_absolute():
        return candidate
    return (repo_root / candidate).resolve()


def empty_status_counts() -> dict[str, int]:
    return {key: 0 for key in STATUS_KEYS}


def render_markdown(payload: dict) -> str:
    lines = [
        "# Script Usage Summary",
        "",
        f"- **Generated at:** `{payload['generated_at']}`",
        f"- **Event count:** `{payload['event_count']}`",
        f"- **Script count:** `{payload['script_count']}`",
        "",
        "## Global Status Counts",
    ]
    for key in STATUS_KEYS:
        lines.append(f"- **{key}:** `{payload['status_counts'][key]}`")
    lines.extend(["", "## Scripts", "", "| Script ID | Surface | Runs | Passed | Failed | Usage Error | Interrupted | Avg Duration (ms) | Last Run | Scenarios |", "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"])
    for item in payload["scripts"]:
        scenario_render = ", ".join(f"{key}:{value}" for key, value in sorted(item["scenarios"].items())) or "none"
        lines.append(
            "| `{script_id}` | `{surface}` | `{total_runs}` | `{passed}` | `{failed}` | `{usage_error}` | `{interrupted}` | `{avg}` | `{last_run}` | `{scenarios}` |".format(
                script_id=item["script_id"],
                surface=item["surface"],
                total_runs=item["total_runs"],
                passed=item["status_counts"]["passed"],
                failed=item["status_counts"]["failed"],
                usage_error=item["status_counts"]["usage_error"],
                interrupted=item["status_counts"]["interrupted"],
                avg=item["average_duration_ms"],
                last_run=item["last_run_at"],
                scenarios=scenario_render,
            )
        )
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo).resolve()
    if not (repo_root / "tools" / "script_usage_summary.py").exists():
        raise SystemExit("script usage summary requires a Delphi repository root")
    events_path = resolve_path(repo_root, args.events_jsonl)
    events = load_jsonl(events_path)

    global_status_counts = Counter()
    per_script: dict[str, dict] = {}
    scenario_counts: dict[str, Counter] = defaultdict(Counter)
    duration_totals: Counter = Counter()

    for event in events:
        script_id = event["script_id"]
        entry = per_script.setdefault(
            script_id,
            {
                "script_id": script_id,
                "script_path": event["script_path"],
                "surface": event["surface"],
                "total_runs": 0,
                "status_counts": empty_status_counts(),
                "last_run_at": event["timestamp"],
                "average_duration_ms": 0,
                "scenarios": {},
            },
        )
        entry["total_runs"] += 1
        status = event["status"]
        entry["status_counts"][status] += 1
        global_status_counts[status] += 1
        duration_totals[script_id] += int(event["duration_ms"])
        scenario_counts[script_id][event["scenario"]] += 1
        if event["timestamp"] > entry["last_run_at"]:
            entry["last_run_at"] = event["timestamp"]

    scripts = []
    for script_id in sorted(per_script):
        entry = per_script[script_id]
        total_runs = entry["total_runs"]
        entry["average_duration_ms"] = 0 if total_runs == 0 else round(duration_totals[script_id] / total_runs)
        entry["scenarios"] = dict(sorted(scenario_counts[script_id].items()))
        scripts.append(entry)

    payload = {
        "schema_version": "script-usage-summary-v1",
        "artifact_kind": "script_usage_summary",
        "generated_at": utc_now(),
        "event_count": len(events),
        "script_count": len(scripts),
        "status_counts": {key: int(global_status_counts.get(key, 0)) for key in STATUS_KEYS},
        "scripts": scripts,
    }
    validate_schema(payload, "script_usage_summary.schema.json", "script usage summary")
    write_json(resolve_path(repo_root, args.summary_json), payload)
    if args.summary_markdown:
        markdown_path = resolve_path(repo_root, args.summary_markdown)
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(render_markdown(payload), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
