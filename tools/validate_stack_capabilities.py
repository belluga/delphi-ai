#!/usr/bin/env python3
"""Validate Delphi's stack capability registry without external YAML dependencies."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from lib.stack_capability_registry import RegistryValidationError, load_registry


def validate(path: Path) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"registry file not found: {path}"]

    try:
        load_registry(path)
    except RegistryValidationError as error:
        errors.append(str(error))
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
