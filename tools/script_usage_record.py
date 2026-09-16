#!/usr/bin/env python3
"""Record deterministic script-usage events for Delphi-local telemetry."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys

from paced_metrics_core import (
    append_jsonl,
    build_rule_event_id,
    normalize_repo_relative,
    short_hash,
    utc_now,
    validate_schema,
)


DEFAULT_EVENTS_PATH = "artifacts/local/metrics/events/script-usage.jsonl"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Append a script-usage event to the local Delphi metrics ledger.")
    parser.add_argument("--repo-root", default=".", help="Delphi repository root.")
    parser.add_argument("--events-jsonl", default=DEFAULT_EVENTS_PATH, help="Ledger path, relative to --repo-root unless absolute.")
    parser.add_argument("--script-id", required=True, help="Stable script identifier.")
    parser.add_argument("--script-path", required=True, help="Repo-relative script path.")
    parser.add_argument("--surface", required=True, choices=["delphi-tool", "root-tool", "root-script"])
    parser.add_argument("--scenario", default="default", help="Safe scenario label for this invocation.")
    parser.add_argument("--exit-code", required=True, type=int)
    parser.add_argument("--duration-ms", required=True, type=int)
    parser.add_argument("--cwd", default=".", help="Invocation cwd.")
    parser.add_argument("--metadata", action="append", default=[], help="Optional KEY=VALUE metadata pair. Repeat as needed.")
    parser.add_argument("--quiet", action="store_true", help="Suppress noop messages.")
    return parser.parse_args()


def resolve_path(repo_root: Path, raw_path: str) -> Path:
    candidate = Path(raw_path)
    if candidate.is_absolute():
      return candidate
    return (repo_root / candidate).resolve()


def determine_status(exit_code: int) -> str:
    if exit_code == 0:
        return "passed"
    if exit_code in {64, 65}:
        return "usage_error"
    if exit_code in {130, 137, 143}:
        return "interrupted"
    return "failed"


def parse_metadata(raw_items: list[str]) -> dict[str, str]:
    metadata: dict[str, str] = {}
    for raw in raw_items:
        if "=" not in raw:
            raise SystemExit(f"invalid --metadata value (expected KEY=VALUE): {raw}")
        key, value = raw.split("=", 1)
        key = key.strip()
        if not key:
            raise SystemExit(f"invalid --metadata key in: {raw}")
        metadata[key] = value.strip()
    return metadata


def git_value(repo_root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo_root), *args],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return "unknown"
    value = result.stdout.strip()
    return value or "unknown"


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    if not (repo_root / "tools" / "script_usage_record.py").exists():
        if not args.quiet:
            print("script usage metrics skipped: no Delphi repository root found", file=sys.stderr)
        return 0

    events_path = resolve_path(repo_root, args.events_jsonl)
    cwd_path = Path(args.cwd).resolve()
    branch = git_value(repo_root, "branch", "--show-current")
    head_sha = git_value(repo_root, "rev-parse", "HEAD")
    metadata = parse_metadata(args.metadata)
    timestamp = utc_now()
    fingerprint = short_hash(
        args.script_id,
        args.script_path,
        args.scenario,
        branch,
        head_sha,
        timestamp,
        length=16,
    )
    payload = {
        "schema_version": "script-usage-event-v1",
        "artifact_kind": "script_usage_event",
        "event_id": build_rule_event_id(
            "script_usage_event",
            args.script_id,
            args.script_path,
            fingerprint,
            timestamp,
        ),
        "timestamp": timestamp,
        "script_id": args.script_id,
        "script_path": args.script_path,
        "surface": args.surface,
        "scenario": args.scenario,
        "status": determine_status(args.exit_code),
        "exit_code": args.exit_code,
        "duration_ms": args.duration_ms,
        "repo_root": str(repo_root),
        "repo_name": repo_root.name,
        "branch": branch,
        "head_sha": head_sha,
        "cwd": normalize_repo_relative(cwd_path, repo_root),
        "metadata": metadata,
    }
    validate_schema(payload, "script_usage_event.schema.json", "script usage event")
    append_jsonl(events_path, payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
