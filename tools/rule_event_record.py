#!/usr/bin/env python3
"""Record PACED rule events manually when automatic inference is insufficient."""

from __future__ import annotations

import argparse
from pathlib import Path

from paced_metrics_core import (
    append_jsonl,
    build_rule_event_id,
    canonical_todo_path,
    load_jsonl,
    next_rule_episode_id,
    utc_now,
    validate_schema,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Append PACED rule events to a JSONL ledger.")
    parser.add_argument("--events-jsonl", required=True, help="Path to rule-events.jsonl")
    subparsers = parser.add_subparsers(dest="command", required=True)

    resolve = subparsers.add_parser("resolve", help="Record a resolution for an existing episode.")
    resolve.add_argument("--episode-id", required=True)
    resolve.add_argument("--outcome", required=True, choices=["true_positive", "false_positive", "waived", "unknown"])
    resolve.add_argument("--reason", required=True)

    escape = subparsers.add_parser("escape", help="Record an escape for a rule episode.")
    escape.add_argument("--rule-id", required=True)
    escape.add_argument("--rule-level", required=True, choices=["paced", "project"])
    escape.add_argument("--todo-path", required=True)
    escape.add_argument("--fingerprint", required=True, help="Stable fingerprint for the escaped condition.")
    escape.add_argument("--reason", required=True)
    escape.add_argument("--source-kind", default="manual", choices=["ci", "lint", "analyzer", "validator", "hybrid", "manual"])
    escape.add_argument("--source-ref", default="manual")

    state = subparsers.add_parser("state-change", help="Record a lifecycle change for a rule.")
    state.add_argument("--rule-id", required=True)
    state.add_argument("--rule-level", required=True, choices=["paced", "project"])
    state.add_argument("--from-state", required=True, choices=["created", "adjusting", "ready", "operating"])
    state.add_argument("--to-state", required=True, choices=["created", "adjusting", "ready", "operating"])
    state.add_argument("--reason", required=True)
    state.add_argument("--source-kind", default="manual", choices=["ci", "lint", "analyzer", "validator", "hybrid", "manual"])
    state.add_argument("--source-ref", default="manual")
    return parser


def last_event_for_episode(path: Path, episode_id: str) -> dict:
    events = load_jsonl(path)
    for event in reversed(events):
        if event.get("episode_id") == episode_id:
            return event
    raise SystemExit(f"episode_id not found in rule events: {episode_id}")


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    events_path = Path(args.events_jsonl).resolve()
    timestamp = utc_now()

    if args.command == "resolve":
        previous = last_event_for_episode(events_path, args.episode_id)
        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": build_rule_event_id(
                "rule_episode_resolved",
                previous["rule_id"],
                previous.get("todo_path", ""),
                previous.get("fingerprint", args.episode_id),
                timestamp,
            ),
            "event_kind": "rule_episode_resolved",
            "timestamp": timestamp,
            "rule_id": previous["rule_id"],
            "rule_level": previous["rule_level"],
            "todo_path": previous.get("todo_path", ""),
            "episode_id": args.episode_id,
            "fingerprint": previous.get("fingerprint", ""),
            "source_kind": "manual",
            "source_ref": "delphi-ai/tools/rule_event_record.py",
            "outcome": args.outcome,
            "reason": args.reason,
        }
    elif args.command == "escape":
        todo_path = canonical_todo_path(args.todo_path, Path.cwd())
        prior_events = load_jsonl(events_path)
        episode_id = next_rule_episode_id(prior_events, args.rule_id, todo_path, args.fingerprint)
        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": build_rule_event_id("rule_escape_recorded", args.rule_id, todo_path, args.fingerprint, timestamp),
            "event_kind": "rule_escape_recorded",
            "timestamp": timestamp,
            "rule_id": args.rule_id,
            "rule_level": args.rule_level,
            "todo_path": todo_path,
            "episode_id": episode_id,
            "fingerprint": args.fingerprint,
            "source_kind": args.source_kind,
            "source_ref": args.source_ref,
            "reason": args.reason,
        }
    else:
        payload = {
            "schema_version": "rule-event-v1",
            "artifact_kind": "rule_event",
            "event_id": build_rule_event_id("rule_state_changed", args.rule_id, "", args.rule_id, timestamp),
            "event_kind": "rule_state_changed",
            "timestamp": timestamp,
            "rule_id": args.rule_id,
            "rule_level": args.rule_level,
            "source_kind": args.source_kind,
            "source_ref": args.source_ref,
            "from_state": args.from_state,
            "to_state": args.to_state,
            "reason": args.reason,
        }

    validate_schema(payload, "rule_event.schema.json", "rule event")
    append_jsonl(events_path, payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
