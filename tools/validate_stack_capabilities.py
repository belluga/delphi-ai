#!/usr/bin/env python3
"""Validate Delphi's stack capability registry without external YAML dependencies."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_TOP_LEVEL = {"schema_version", "ecosystem", "activation_contract", "capabilities"}
REQUIRED_CAPABILITIES = {"docker", "flutter", "laravel", "go"}
REQUIRED_CAPABILITY_FIELDS = {
    "lifecycle",
    "purpose",
    "activation_markers",
    "detection_markers",
    "execution_policy",
}
ALLOWED_LIFECYCLES = {"available", "future", "deprecated", "experimental"}
FORBIDDEN_ACTIVATION_RE = re.compile(
    r"^\s*(active|enabled|activated|project_active|is_active)\s*:\s*(true|yes|1)\s*(#.*)?$",
    re.I,
)


def strip_comment(line: str) -> str:
    quote: str | None = None
    for idx, char in enumerate(line):
        if char in {"'", '"'}:
            quote = None if quote == char else char
        elif char == "#" and quote is None:
            return line[:idx]
    return line


def parse_registry(path: Path) -> tuple[set[str], dict[str, dict[str, str]], list[str]]:
    top_level: set[str] = set()
    capabilities: dict[str, dict[str, str]] = {}
    errors: list[str] = []
    section: str | None = None
    current_capability: str | None = None

    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if "\t" in raw_line:
            errors.append(f"line {line_number}: tabs are not allowed in the registry")
        if FORBIDDEN_ACTIVATION_RE.match(raw_line):
            errors.append(
                f"line {line_number}: forbidden project activation flag; stack activation belongs in project-owned contracts"
            )

        line = strip_comment(raw_line).rstrip()
        if not line.strip():
            continue

        top = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if top:
            key, value = top.groups()
            top_level.add(key)
            section = key
            current_capability = None
            if key == "schema_version" and not value.strip():
                errors.append(f"line {line_number}: schema_version must have a scalar value")
            if key == "ecosystem" and not value.strip():
                errors.append(f"line {line_number}: ecosystem must have a scalar value")
            continue

        if section == "capabilities":
            cap = re.match(r"^  ([A-Za-z0-9_-]+):\s*$", line)
            if cap:
                current_capability = cap.group(1)
                capabilities.setdefault(current_capability, {})
                continue

            field = re.match(r"^    ([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
            if field and current_capability:
                key, value = field.groups()
                capabilities.setdefault(current_capability, {})[key] = value.strip()
                continue

    return top_level, capabilities, errors


def validate(path: Path) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"registry file not found: {path}"]

    top_level, capabilities, parse_errors = parse_registry(path)
    errors.extend(parse_errors)

    missing_top = sorted(REQUIRED_TOP_LEVEL - top_level)
    if missing_top:
        errors.append(f"missing top-level key(s): {', '.join(missing_top)}")

    missing_caps = sorted(REQUIRED_CAPABILITIES - set(capabilities))
    if missing_caps:
        errors.append(f"missing capability block(s): {', '.join(missing_caps)}")

    for capability in sorted(REQUIRED_CAPABILITIES & set(capabilities)):
        fields = capabilities[capability]
        missing_fields = sorted(REQUIRED_CAPABILITY_FIELDS - set(fields))
        if missing_fields:
            errors.append(f"{capability}: missing required field(s): {', '.join(missing_fields)}")
        lifecycle = fields.get("lifecycle", "").strip("'\"")
        if lifecycle and lifecycle not in ALLOWED_LIFECYCLES:
            errors.append(
                f"{capability}: invalid lifecycle `{lifecycle}`; expected one of {', '.join(sorted(ALLOWED_LIFECYCLES))}"
            )

    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate config/stack_capabilities.yaml.")
    parser.add_argument(
        "config",
        nargs="?",
        default="config/stack_capabilities.yaml",
        help="Registry path. Defaults to config/stack_capabilities.yaml.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    path = Path(args.config)
    errors = validate(path)
    if errors:
        print("validate_stack_capabilities: FAIL", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"validate_stack_capabilities: OK ({path})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
