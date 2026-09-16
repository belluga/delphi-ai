#!/usr/bin/env python3
"""Normalize documented review-kind-specific aliases before canonical validation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from jsonschema import Draft202012Validator

REPO_ROOT = Path(__file__).resolve().parent.parent
RESULT_SCHEMA_PATH = REPO_ROOT / "schemas" / "subagent_review_result.schema.json"
ALIAS_MAP_VERSION = "v1"

# These aliases are historical provider vocabulary, not an alternate result
# contract. Keep them narrowly scoped to the review kinds where they occurred.
CATEGORY_ALIASES_BY_REVIEW_KIND = {
    "architecture_opinion": {
        "correctness": "architecture",
        "scope_boundary": "adherence",
    },
    "architecture_adherence": {
        "scope_boundary": "adherence",
    },
    "test_quality_audit": {
        "test_effectiveness": "tests",
    },
}


def reject_duplicate_keys(pairs: list[tuple[str, object]]) -> dict[str, object]:
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    try:
        payload = json.loads(
            Path(args.input).read_text(encoding="utf-8"),
            object_pairs_hook=reject_duplicate_keys,
        )
    except (json.JSONDecodeError, ValueError) as error:
        raise SystemExit(f"invalid reviewer result JSON: {error}") from error

    if not isinstance(payload, dict):
        raise SystemExit("invalid reviewer result JSON: top level must be an object")

    aliases = CATEGORY_ALIASES_BY_REVIEW_KIND.get(payload.get("review_kind"), {})
    normalized_count = 0
    for finding in payload.get("findings", []):
        if not isinstance(finding, dict):
            continue
        category = finding.get("category")
        if category in aliases:
            finding["category"] = aliases[category]
            normalized_count += 1

    errors = sorted(Draft202012Validator(json.loads(RESULT_SCHEMA_PATH.read_text())).iter_errors(payload), key=lambda item: list(item.absolute_path))
    if errors:
        rendered = "\n".join(f"{' -> '.join(map(str, error.absolute_path)) or 'result'}: {error.message}" for error in errors)
        raise SystemExit(f"normalized subagent review result failed schema validation:\n{rendered}")

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"normalized review alias map {ALIAS_MAP_VERSION}: {normalized_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
