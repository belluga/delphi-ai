#!/usr/bin/env python3
"""Extract Claude's terminal print result from a stream-json transcript."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from jsonschema import Draft202012Validator


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract the terminal successful result from Claude stream-json output."
    )
    parser.add_argument("--stream", required=True, help="Claude stream-json transcript path")
    parser.add_argument("--output", required=True, help="Destination for the terminal result text")
    parser.add_argument(
        "--json-schema",
        help="Optional JSON schema that makes the terminal result a validated JSON object",
    )
    return parser.parse_args()


def parse_json_object(result: str) -> dict:
    try:
        payload = json.loads(result)
    except json.JSONDecodeError:
        fenced = re.findall(r"```(?:json)?\s*(\{.*?\})\s*```", result, flags=re.DOTALL | re.IGNORECASE)
        if len(fenced) != 1:
            raise SystemExit(
                "Claude terminal result is not one JSON object or one fenced JSON object."
            )
        try:
            payload = json.loads(fenced[0])
        except json.JSONDecodeError as error:
            raise SystemExit(f"Claude fenced JSON is invalid: {error}") from error

    if not isinstance(payload, dict):
        raise SystemExit("Claude terminal JSON result must be an object.")

    return payload


def main() -> int:
    args = parse_args()
    terminal_event: dict[str, object] | None = None

    for line in Path(args.stream).read_text(encoding="utf-8").splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if event.get("type") != "result":
            continue

        terminal_event = event

    if terminal_event is None:
        raise SystemExit("Claude stream contained no terminal successful result.")

    if terminal_event.get("subtype") != "success":
        failure = str(
            terminal_event.get("result")
            or terminal_event.get("error")
            or "unknown Claude failure"
        )
        raise SystemExit(f"Claude stream ended unsuccessfully: {failure}")

    result = terminal_event.get("result")
    if not isinstance(result, str) or not result.strip():
        raise SystemExit("Claude stream terminal successful result was empty.")

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if args.json_schema:
        schema_path = Path(args.json_schema)
        try:
            schema = json.loads(schema_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise SystemExit(f"Unable to load Claude JSON schema: {error}") from error

        payload = parse_json_object(result)
        errors = sorted(
            Draft202012Validator(schema).iter_errors(payload),
            key=lambda error: list(error.absolute_path),
        )
        if errors:
            details = "; ".join(
                f"{' -> '.join(str(part) for part in error.absolute_path) or 'result'}: {error.message}"
                for error in errors
            )
            raise SystemExit(f"Claude terminal JSON failed schema validation: {details}")

        output_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    else:
        output_path.write_text(result.rstrip() + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
