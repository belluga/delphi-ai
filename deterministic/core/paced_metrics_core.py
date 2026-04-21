#!/usr/bin/env python3
"""Reusable PACED metrics helpers for CLI tools and future MCP exposure."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

from jsonschema import Draft202012Validator


REPO_ROOT = Path(__file__).resolve().parents[2]
SCHEMA_DIR = REPO_ROOT / "schemas"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def short_hash(*parts: str, length: int = 12) -> str:
    payload = "||".join(part.strip() for part in parts if part is not None)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()[:length]


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    rows: list[dict] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        stripped = raw.strip()
        if not stripped:
            continue
        rows.append(json.loads(stripped))
    return rows


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def append_jsonl(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload) + "\n")


def validate_schema(payload: dict, schema_name: str, label: str) -> None:
    schema_path = SCHEMA_DIR / schema_name
    validator = Draft202012Validator(load_json(schema_path))
    errors = sorted(validator.iter_errors(payload), key=lambda item: list(item.absolute_path))
    if not errors:
        return

    rendered = []
    for error in errors:
        field = " -> ".join(str(part) for part in error.absolute_path) or label
        rendered.append(f"{field}: {error.message}")
    raise SystemExit(f"{label} failed schema validation:\n" + "\n".join(rendered))


def normalize_repo_relative(path: Path, repo_root: Path) -> str:
    try:
        return str(path.resolve().relative_to(repo_root.resolve()))
    except ValueError:
        return str(path.resolve())


def canonical_todo_path(raw: str, repo_root: Path | None = None) -> str:
    repo_root = (repo_root or Path.cwd()).resolve()
    candidate = Path(raw)
    if candidate.is_absolute():
        try:
            return str(candidate.resolve().relative_to(repo_root))
        except ValueError:
            normalized = str(candidate.resolve()).replace("\\", "/")
            marker = "/foundation_documentation/"
            if marker in normalized:
                return "foundation_documentation/" + normalized.split(marker, 1)[1]
            return str(candidate.resolve())
    normalized = raw.replace("\\", "/")
    marker = "foundation_documentation/"
    if marker in normalized:
        return normalized[normalized.index(marker) :]
    return normalized


def build_rule_episode_key(rule_id: str, todo_path: str, fingerprint: str) -> str:
    return short_hash(rule_id, todo_path, fingerprint, length=16)


def build_rule_episode_id(rule_id: str, todo_path: str, fingerprint: str, occurrence: int = 1) -> str:
    base = f"ep-{build_rule_episode_key(rule_id, todo_path, fingerprint)}"
    if occurrence <= 1:
        return base
    return f"{base}-{occurrence}"


def parse_rule_episode_occurrence(episode_id: str, rule_id: str, todo_path: str, fingerprint: str) -> int:
    base = build_rule_episode_id(rule_id, todo_path, fingerprint)
    if episode_id == base:
        return 1
    prefix = f"{base}-"
    if episode_id.startswith(prefix):
        suffix = episode_id[len(prefix) :]
        if suffix.isdigit():
            return int(suffix)
    return 1


def next_rule_episode_id(events: list[dict], rule_id: str, todo_path: str, fingerprint: str) -> str:
    related = [
        event
        for event in events
        if event.get("rule_id") == rule_id
        and event.get("todo_path") == todo_path
        and event.get("fingerprint") == fingerprint
        and event.get("episode_id")
    ]
    if related and related[-1].get("event_kind") == "rule_block_observed":
        return related[-1]["episode_id"]
    next_occurrence = 1
    if related:
        next_occurrence = max(
            parse_rule_episode_occurrence(event["episode_id"], rule_id, todo_path, fingerprint)
            for event in related
        ) + 1
    return build_rule_episode_id(rule_id, todo_path, fingerprint, next_occurrence)


def build_rule_event_id(event_kind: str, rule_id: str, todo_path: str, fingerprint: str, timestamp: str | None = None) -> str:
    stamp = timestamp or utc_now()
    return f"evt-{short_hash(event_kind, rule_id, todo_path, fingerprint, stamp, length=16)}"


def build_rule_fingerprint(parts: Iterable[str]) -> str:
    normalized = [part.strip().lower() for part in parts if part and part.strip()]
    return short_hash(*normalized, length=16)


def normalize_text(value: str) -> str:
    return " ".join(value.lower().split())


def combine_formalizable_hints(values: list[str]) -> str:
    normalized = {value for value in values if value}
    if "yes" in normalized:
        return "yes"
    if "partial" in normalized:
        return "partial"
    if normalized == {"no"}:
        return "no"
    if not normalized:
        return "unknown"
    return "unknown"


def combine_candidate_rule_levels(values: list[str]) -> str:
    normalized = {value for value in values if value and value != "unknown"}
    if len(normalized) == 1:
        return next(iter(normalized))
    if not normalized:
        return "unknown"
    return "unknown"
