#!/usr/bin/env python3
"""Validate phase-split skill surfaces that must stay in sync."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class PhaseGroup:
    name: str
    umbrella_skill: str
    phases: tuple[str, ...]
    workflows: tuple[str, ...] = ()
    clinerules: tuple[str, ...] = ()
    require_register: bool = True


SCHEMA_VERSION = "1"
LIST_FIELDS = {"phases", "workflows", "clinerules"}
SCALAR_FIELDS = {"name", "umbrella_skill", "require_register"}


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError:
        return ""


def same_file(a: Path, b: Path) -> bool:
    return a.is_file() and b.is_file() and read(a) == read(b)


def strip_comment(line: str) -> str:
    quote: str | None = None
    for idx, char in enumerate(line):
        if char in {"'", '"'}:
            quote = None if quote == char else char
        elif char == "#" and quote is None:
            return line[:idx]
    return line


def strip_scalar(value: str) -> str:
    value = value.strip()
    if value.startswith(("'", '"')) and value.endswith(("'", '"')) and len(value) >= 2:
        return value[1:-1].strip()
    return value


def parse_bool(value: str, default: bool) -> bool:
    if not value:
        return default
    normalized = strip_scalar(value).lower()
    if normalized in {"true", "yes", "1"}:
        return True
    if normalized in {"false", "no", "0"}:
        return False
    return default


def parse_config(path: Path) -> tuple[list[PhaseGroup], list[str]]:
    errors: list[str] = []
    groups: list[dict[str, object]] = []
    schema_version: str | None = None
    in_phase_groups = False
    current: dict[str, object] | None = None
    current_list: str | None = None

    if not path.is_file():
        return [], [f"phase surface config file not found: {path}"]

    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if "\t" in raw_line:
            errors.append(f"line {line_number}: tabs are not allowed in the phase surface config")
        line = strip_comment(raw_line).rstrip()
        if not line.strip():
            continue

        top = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if top:
            key, value = top.groups()
            current = None
            current_list = None
            in_phase_groups = key == "phase_groups"
            if key == "schema_version":
                schema_version = strip_scalar(value)
            elif key != "phase_groups":
                errors.append(f"line {line_number}: unsupported top-level key `{key}`")
            continue

        if not in_phase_groups:
            errors.append(f"line {line_number}: content must be under phase_groups")
            continue

        group_start = re.match(r"^  - name:\s*(.+?)\s*$", line)
        if group_start:
            current = {
                "name": strip_scalar(group_start.group(1)),
                "phases": [],
                "workflows": [],
                "clinerules": [],
                "require_register": True,
            }
            groups.append(current)
            current_list = None
            continue

        if current is None:
            errors.append(f"line {line_number}: phase group entry must start with `- name:`")
            continue

        scalar = re.match(r"^    ([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if scalar:
            key, value = scalar.groups()
            if key in LIST_FIELDS:
                current_list = key
                value = value.strip()
                if value == "[]":
                    current[key] = []
                elif value:
                    errors.append(f"line {line_number}: list field `{key}` must use `[]` or indented `-` items")
                continue
            current_list = None
            if key not in SCALAR_FIELDS:
                errors.append(f"line {line_number}: unsupported phase group key `{key}`")
                continue
            if key == "require_register":
                current[key] = parse_bool(value, default=True)
            else:
                current[key] = strip_scalar(value)
            continue

        item = re.match(r"^      -\s*(.+?)\s*$", line)
        if item and current_list:
            current.setdefault(current_list, [])
            list_value = current[current_list]
            if isinstance(list_value, list):
                list_value.append(strip_scalar(item.group(1)))
            else:
                errors.append(f"line {line_number}: `{current_list}` is not a list")
            continue

        errors.append(f"line {line_number}: unsupported config shape")

    if schema_version != SCHEMA_VERSION:
        errors.append(f"schema_version must be `{SCHEMA_VERSION}`, found `{schema_version or 'missing'}`")
    if not groups:
        errors.append("phase_groups must include at least one group")

    phase_groups: list[PhaseGroup] = []
    for index, raw_group in enumerate(groups, start=1):
        name = str(raw_group.get("name", "")).strip()
        umbrella = str(raw_group.get("umbrella_skill", "")).strip()
        phases = tuple(str(item).strip() for item in raw_group.get("phases", []) if str(item).strip())
        workflows = tuple(str(item).strip() for item in raw_group.get("workflows", []) if str(item).strip())
        clinerules = tuple(str(item).strip() for item in raw_group.get("clinerules", []) if str(item).strip())
        require_register = bool(raw_group.get("require_register", True))

        if not name:
            errors.append(f"group {index}: missing name")
        if not umbrella:
            errors.append(f"{name or f'group {index}'}: missing umbrella_skill")
        if not phases:
            errors.append(f"{name or f'group {index}'}: phases must include at least one phase skill")
        if name and umbrella and phases:
            phase_groups.append(
                PhaseGroup(
                    name=name,
                    umbrella_skill=umbrella,
                    phases=phases,
                    workflows=workflows,
                    clinerules=clinerules,
                    require_register=require_register,
                )
            )

    return phase_groups, errors


def validate(root: Path, config_path: Path) -> list[str]:
    errors: list[str] = []
    phase_groups, config_errors = parse_config(config_path)
    errors.extend(config_errors)
    if config_errors:
        return errors

    register = root / "skills" / "deterministic-tooling-register.md"
    register_text = read(register)

    for group in phase_groups:
        umbrella = root / "skills" / group.umbrella_skill / "SKILL.md"
        umbrella_text = read(umbrella)
        if not umbrella.is_file():
            errors.append(f"{group.name}: missing umbrella skill {umbrella.relative_to(root)}")
            continue

        for phase in group.phases:
            canonical = root / "skills" / phase / "SKILL.md"
            cline = root / ".cline" / "skills" / phase / "SKILL.md"
            claude = root / ".claude" / "skills" / phase / "SKILL.md"
            if not canonical.is_file():
                errors.append(f"{group.name}: missing phase skill {canonical.relative_to(root)}")
                continue
            if phase not in umbrella_text:
                errors.append(f"{group.name}: umbrella skill does not reference phase {phase}")
            if not same_file(canonical, cline):
                errors.append(f"{group.name}: .cline mirror missing or stale for {phase}")
            if not same_file(canonical, claude):
                errors.append(f"{group.name}: .claude mirror missing or stale for {phase}")
            if group.require_register and phase not in register_text:
                errors.append(f"{group.name}: deterministic tooling register missing {phase}")

        for workflow in group.workflows:
            if not (root / workflow).is_file():
                errors.append(f"{group.name}: missing phase workflow {workflow}")

        for clinerule in group.clinerules:
            if not (root / clinerule).is_file():
                errors.append(f"{group.name}: missing .clinerules phase workflow {clinerule}")

    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate phase-split skill surfaces.")
    parser.add_argument(
        "--config",
        default="config/phase_surfaces.yaml",
        help="Phase surface registry path. Defaults to config/phase_surfaces.yaml.",
    )
    parser.add_argument(
        "--root",
        default=None,
        help="Repository root. Defaults to the parent of tools/.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parents[1]
    config_path = Path(args.config)
    if not config_path.is_absolute():
        config_path = root / config_path
    errors = validate(root, config_path)
    if errors:
        print("validate_phase_surfaces: FAIL", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("validate_phase_surfaces: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
