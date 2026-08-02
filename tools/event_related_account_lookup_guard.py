#!/usr/bin/env python3
"""Block Event-target related-account lookups and nested-account parent_type=event.

This deterministic guard enforces the Event related-profile cutover boundary:

- lookups may start from Event context;
- Event documents are not canonical generic related-account lookup targets;
- nested-account rows for this surface may use only parent_type=event_occurrence;
- parent_type=event is forbidden for both reads and writes.

It emits a TEACH runtime response and exits with:

  0  GO: no forbidden lookup-target shape was found.
  2  NO-GO: one or more forbidden lookup-target shapes were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


RULE_ID = "paced.event-related-account-lookup-boundary"
DEFAULT_EVENT_TARGET_SCAN_PATHS = (
    "laravel-app/packages/belluga/belluga_events/src/Application/Events",
    "laravel-app/packages/belluga/belluga_events/src/Http/Api/v1",
    "laravel-app/packages/belluga/belluga_events/src/Support",
)
DEFAULT_PARENT_TYPE_SCAN_PATHS = (
    "laravel-app/app",
    "laravel-app/packages",
)

METHOD_RE = re.compile(r"function\s+([A-Za-z0-9_]+)\s*\(")
COMMENT_ONLY_RE = re.compile(r"^\s*(//|/\*|\*|#)")
EVENT_PREFIXED_SELECTOR_RE = re.compile(
    r"""['"]event\.(event_parties|linked_account_profiles|own_linked_account_profiles)(?:\.[^'"]+)?['"]"""
)
UNPREFIXED_SELECTOR_RE = re.compile(
    r"""['"](event_parties|linked_account_profiles|own_linked_account_profiles)(?:\.[^'"]+)?['"]"""
)
QUERY_CONTEXT_RE = re.compile(
    r"""(->where(?:Raw|In)?\s*\(|->orWhere(?:Raw|In)?\s*\(|->whereHas\s*\(|->orWhereHas\s*\(|\$match\b|\$elemMatch\b|\$lookup\b|\$and\b|\$or\b|aggregate\s*\()"""
)
PARENT_TYPE_EVENT_PATTERNS = (
    re.compile(r"""['"]parent_type['"]\s*=>\s*['"]event['"]"""),
    re.compile(r"""where(?:Raw)?\(\s*['"]parent_type['"]\s*,\s*['"]event['"]"""),
    re.compile(r"""['"]parent_type['"]\s*=>\s*[A-Za-z0-9_\\:]*EVENT\b"""),
)


@dataclass(frozen=True)
class Finding:
    code: str
    path: str
    line: int
    method: str
    message: str
    resolution: str


def clean_value(value: str) -> str:
    stripped = value.strip()
    while len(stripped) >= 2 and stripped[0] == stripped[-1] and stripped[0] in {"`", "'", '"'}:
        stripped = stripped[1:-1].strip()
    return stripped


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo",
        default=".",
        help="Repository root that contains laravel-app/ and delphi-ai/.",
    )
    parser.add_argument(
        "--path",
        action="append",
        default=[],
        help="Optional relative scan path override. When provided, replaces the default path sets.",
    )
    parser.add_argument(
        "--json-output",
        help="Optional file path to write the machine-readable guard result JSON.",
    )
    return parser.parse_args(argv)


def iter_php_files(repo_root: Path, scan_paths: tuple[str, ...] | list[str]) -> list[Path]:
    files: list[Path] = []
    seen: set[Path] = set()
    for raw_path in scan_paths:
        candidate = (repo_root / raw_path).resolve()
        if candidate.is_file():
            if candidate.suffix.lower() == ".php" and candidate not in seen:
                seen.add(candidate)
                files.append(candidate)
            continue
        if not candidate.is_dir():
            continue
        for path in sorted(candidate.rglob("*.php")):
            resolved = path.resolve()
            if resolved not in seen:
                seen.add(resolved)
                files.append(resolved)
    return files


def relative_path(path: Path, repo_root: Path) -> str:
    return path.resolve().relative_to(repo_root.resolve()).as_posix()


def extract_method_ranges(lines: list[str]) -> list[tuple[str, int, int]]:
    starts: list[tuple[str, int]] = []
    for index, line in enumerate(lines):
        match = METHOD_RE.search(line)
        if match:
            starts.append((match.group(1), index))
    if not starts:
        return [("[file-scope]", 0, len(lines))]

    ranges: list[tuple[str, int, int]] = []
    for offset, (method, start) in enumerate(starts):
        end = starts[offset + 1][1] if offset + 1 < len(starts) else len(lines)
        ranges.append((method, start, end))
    return ranges


def non_comment_lines(lines: list[str], start: int, end: int) -> list[tuple[int, str]]:
    result: list[tuple[int, str]] = []
    for index in range(start, end):
        line = lines[index]
        if COMMENT_ONLY_RE.match(line):
            continue
        result.append((index, line))
    return result


def is_event_primary_file(path: str) -> bool:
    name = Path(path).name
    return "Event" in name and "Occurrence" not in name


def first_matching_line(
    method_lines: list[tuple[int, str]],
    patterns: tuple[re.Pattern[str], ...] | list[re.Pattern[str]],
) -> tuple[int, str] | None:
    for index, line in method_lines:
        for pattern in patterns:
            if pattern.search(line):
                return index + 1, clean_value(line)
    return None


def line_window_text(method_lines: list[tuple[int, str]], ordinal: int, radius: int = 4) -> str:
    start = max(0, ordinal - radius)
    end = min(len(method_lines), ordinal + radius + 1)
    return "".join(line for _, line in method_lines[start:end])


def first_query_target_match(
    method_lines: list[tuple[int, str]],
    patterns: tuple[re.Pattern[str], ...] | list[re.Pattern[str]],
) -> tuple[int, str] | None:
    for ordinal, (index, line) in enumerate(method_lines):
        for pattern in patterns:
            if not pattern.search(line):
                continue
            local_window = line_window_text(method_lines, ordinal)
            if QUERY_CONTEXT_RE.search(local_window):
                return index + 1, clean_value(line)
    return None


def detect_event_target_lookup(
    *,
    repo_relative_path: str,
    method: str,
    method_lines: list[tuple[int, str]],
) -> Finding | None:
    block = "".join(line for _, line in method_lines)
    prefixed_match = first_query_target_match(method_lines, [EVENT_PREFIXED_SELECTOR_RE])
    if prefixed_match is not None:
        line_number, line_text = prefixed_match
        return Finding(
            code="EVENT-TARGET-RELATED-LOOKUP",
            path=repo_relative_path,
            line=line_number,
            method=method,
            message=(
                "Event-scoped related-account lookup targets the Event aggregate itself "
                f"via selector `{line_text}`."
            ),
            resolution=(
                "Keep Event as origin context only. Resolve occurrence ids and/or occurrence-backed "
                "group metadata first, then query occurrence-owned canonical rows."
            ),
        )

    if not is_event_primary_file(repo_relative_path):
        return None

    if not QUERY_CONTEXT_RE.search(block):
        return None

    unprefixed_match = first_query_target_match(method_lines, [UNPREFIXED_SELECTOR_RE])
    if unprefixed_match is None:
        return None

    line_number, line_text = unprefixed_match
    return Finding(
        code="EVENT-TARGET-RELATED-LOOKUP",
        path=repo_relative_path,
        line=line_number,
        method=method,
        message=(
            "Event-primary query code targets Event relation ownership for related-account lookup "
            f"via selector `{line_text}`."
        ),
        resolution=(
            "Do not target the Event document for generic related-account lookup. Use Event context "
            "only to resolve occurrence-backed lookup inputs, then continue on occurrence-owned data."
        ),
    )


def detect_parent_type_event(
    *,
    repo_relative_path: str,
    method: str,
    method_lines: list[tuple[int, str]],
) -> Finding | None:
    match = first_matching_line(method_lines, list(PARENT_TYPE_EVENT_PATTERNS))
    if match is None:
        return None

    line_number, line_text = match
    return Finding(
        code="NESTED-PARENT-TYPE-EVENT",
        path=repo_relative_path,
        line=line_number,
        method=method,
        message=(
            "Nested-account lookup/write shape uses forbidden `parent_type=event` "
            f"via `{line_text}`."
        ),
        resolution=(
            "For this surface, nested-account rows may use only `parent_type=event_occurrence`. "
            "Rewrite the lookup/write to stay occurrence-owned."
        ),
    )


def evaluate(repo_root: Path, scan_override: list[str]) -> dict[str, Any]:
    event_scan_paths = tuple(scan_override) if scan_override else DEFAULT_EVENT_TARGET_SCAN_PATHS
    parent_scan_paths = tuple(scan_override) if scan_override else DEFAULT_PARENT_TYPE_SCAN_PATHS

    findings: list[Finding] = []
    scanned_files: set[str] = set()

    for path in iter_php_files(repo_root, event_scan_paths):
        relative = relative_path(path, repo_root)
        scanned_files.add(relative)
        lines = path.read_text(encoding="utf-8").splitlines()
        for method, start, end in extract_method_ranges(lines):
            method_lines = non_comment_lines(lines, start, end)
            finding = detect_event_target_lookup(
                repo_relative_path=relative,
                method=method,
                method_lines=method_lines,
            )
            if finding is not None:
                findings.append(finding)

    for path in iter_php_files(repo_root, parent_scan_paths):
        relative = relative_path(path, repo_root)
        scanned_files.add(relative)
        lines = path.read_text(encoding="utf-8").splitlines()
        for method, start, end in extract_method_ranges(lines):
            method_lines = non_comment_lines(lines, start, end)
            finding = detect_parent_type_event(
                repo_relative_path=relative,
                method=method,
                method_lines=method_lines,
            )
            if finding is not None:
                findings.append(finding)

    findings.sort(key=lambda item: (item.path, item.line, item.code, item.method))

    return {
        "blocked": findings != [],
        "repo_root": repo_root.resolve().as_posix(),
        "event_target_scan_paths": list(event_scan_paths),
        "parent_type_scan_paths": list(parent_scan_paths),
        "scanned_files": sorted(scanned_files),
        "decision": (
            "Event context may originate related-account lookup, but Event cannot be the canonical "
            "generic relation target and nested-account parent_type=event is forbidden."
        ),
        "violations": [
            {
                "code": finding.code,
                "path": finding.path,
                "line": finding.line,
                "method": finding.method,
                "message": finding.message,
                "resolution": finding.resolution,
            }
            for finding in findings
        ],
    }


def format_teach(result: dict[str, Any]) -> str:
    lines = [
        "TEACH runtime response",
        f"status: {'blocked' if result['blocked'] else 'ready'}",
        "enforcement: hard",
        f"rule_id: {RULE_ID}",
        "violation:",
    ]
    violations = result["violations"]
    if violations:
        for violation in violations:
            lines.append(
                "  - "
                f"[{violation['code']}] {violation['path']}:{violation['line']} "
                f"({violation['method']}) {violation['message']}"
            )
    else:
        lines.append("  - none")

    lines.append("resolution_prompt:")
    if violations:
        lines.append(
            "  - Keep Event as origin context only. Resolve occurrences first, then continue on occurrence-owned canonical relation state."
        )
        lines.append(
            "  - Do not query generic related-account ownership from Event projection fields such as `event_parties` or `linked_account_profiles`."
        )
        lines.append(
            "  - Do not write or read nested-account rows for this surface with `parent_type=event`; use `parent_type=event_occurrence` only."
        )
        lines.append(
            "  - Rerun `python3 delphi-ai/tools/event_related_account_lookup_guard.py --repo <repo-root>` and require `Overall outcome: go` before treating the Event related-profile boundary as converged."
        )
    else:
        lines.append("  - none")

    lines.append("context:")
    lines.append(f"  - repo_root: {result['repo_root']}")
    lines.append(f"  - decision: {result['decision']}")
    lines.append(
        "  - event_target_scan_paths: "
        + ", ".join(result["event_target_scan_paths"])
    )
    lines.append(
        "  - parent_type_scan_paths: "
        + ", ".join(result["parent_type_scan_paths"])
    )
    lines.append(f"  - scanned_files: {len(result['scanned_files'])}")
    lines.append(f"  - violation_count: {len(violations)}")
    lines.append("")
    lines.append(f"Overall outcome: {'no-go' if result['blocked'] else 'go'}")
    return "\n".join(lines)


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    repo_root = Path(args.repo).resolve()
    if not repo_root.exists():
        print("TEACH runtime response")
        print("status: blocked")
        print("enforcement: hard")
        print(f"rule_id: {RULE_ID}")
        print("violation:")
        print(f"  - [REPO-NOT-FOUND] Repository root `{repo_root.as_posix()}` does not exist.")
        print("resolution_prompt:")
        print("  - Pass --repo with an existing repository root and rerun the guard.")
        print("context:")
        print("  - violation_count: 1")
        print("")
        print("Overall outcome: no-go")
        return 1

    result = evaluate(repo_root, args.path)
    if args.json_output:
        write_json(Path(args.json_output), result)
    print(format_teach(result))
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
