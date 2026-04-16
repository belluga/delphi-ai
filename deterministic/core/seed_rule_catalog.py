#!/usr/bin/env python3
"""Seed a project-local PACED rule catalog with canonical TODO-validator rules."""

from __future__ import annotations

import argparse
from pathlib import Path

from paced_metrics_core import load_json, utc_now, validate_schema, write_json
from todo_validation_rules import all_catalog_entries


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed a PACED rule catalog JSON file.")
    parser.add_argument("--output", required=True, help="Path to write rule-catalog.json")
    return parser.parse_args()


PRESERVED_FIELDS = ("created_at", "last_recalibrated_at", "notes", "superseded_by", "lifecycle_state", "owner")


def merge_seeded_entry(existing: dict | None, seeded: dict, timestamp: str) -> dict:
    merged = dict(seeded)
    merged["created_at"] = timestamp
    if not existing:
        return merged

    for field in PRESERVED_FIELDS:
        value = existing.get(field)
        if value not in (None, ""):
            merged[field] = value
    if existing.get("created_at"):
        merged["created_at"] = existing["created_at"]
    return merged


def main() -> int:
    args = parse_args()
    output_path = Path(args.output).resolve()
    timestamp = utc_now()
    existing_rules_by_id: dict[str, dict] = {}

    if output_path.exists():
        existing_payload = load_json(output_path)
        validate_schema(existing_payload, "rule_catalog.schema.json", "existing rule catalog")
        existing_rules_by_id = {entry["rule_id"]: entry for entry in existing_payload["rules"]}

    merged_rules = dict(existing_rules_by_id)
    for entry in all_catalog_entries():
        merged_rules[entry["rule_id"]] = merge_seeded_entry(existing_rules_by_id.get(entry["rule_id"]), entry, timestamp)

    payload = {
        "schema_version": "rule-catalog-v1",
        "artifact_kind": "rule_catalog",
        "rules": sorted(merged_rules.values(), key=lambda item: item["rule_id"]),
    }
    validate_schema(payload, "rule_catalog.schema.json", "rule catalog")
    write_json(output_path, payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
