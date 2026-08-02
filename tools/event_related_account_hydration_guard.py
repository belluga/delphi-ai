#!/usr/bin/env python3
"""Block premature nested-account row hydration in detail payload assembly.

This deterministic guard enforces the shared detail hydration boundary:

- initial Event detail hydration is metadata-only for the related-profile surface;
- initial Account Detail hydration is metadata-only for nested groups;
- nested-account rows hydrate only after the user opens a tab/group;
- tab/group-open row hydration must come from paginated canonical `accounts_nested` reads.

It emits a TEACH runtime response and exits with:

  0  GO: no forbidden hydration shape was found.
  2  NO-GO: one or more forbidden hydration shapes were found.
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


RULE_ID = "paced.nested-account-detail-hydration-boundary"
DEFAULT_SCAN_PATHS = (
    "laravel-app/packages/belluga/belluga_events/src/Application/Events/EventQueryService.php",
    "laravel-app/app/Application/AccountProfiles/AccountProfileFormatterService.php",
    "laravel-app/app/Application/AccountProfiles/AccountProfileNestedPublicMembersProjectionService.php",
    "laravel-app/app/Application/AccountProfiles/AccountProfileNestedGroupService.php",
)
METHOD_RE = re.compile(r"function\s+([A-Za-z0-9_]+)\s*\(")
COMMENT_ONLY_RE = re.compile(r"^\s*(//|/\*|\*|#)")


@dataclass(frozen=True)
class SourcePattern:
    source_kind: str
    pattern: re.Pattern[str]
    message: str
    resolution: str


EVENT_SOURCE_PATTERNS = (
    SourcePattern(
        source_kind="linked-profile-resolver",
        pattern=re.compile(r"\bresolveLinkedAccountProfiles\s*\("),
        message="Initial Event detail hydration resolves linked-profile rows.",
        resolution=(
            "Do not resolve related-profile rows during initial detail hydration. Return tab metadata only, "
            "and move row hydration to tab-open paginated nested-account reads."
        ),
    ),
    SourcePattern(
        source_kind="detail-linked-profile-resolver",
        pattern=re.compile(r"\bresolveDetailLinkedAccountProfiles\s*\("),
        message="Initial Event detail hydration aggregates linked-profile rows from occurrences/programming items.",
        resolution=(
            "Do not aggregate related-profile rows into the initial detail payload. Row hydration belongs to tab-open "
            "paged reads over occurrence-owned canonical nested-account rows."
        ),
    ),
    SourcePattern(
        source_kind="linked-profiles-payload-key",
        pattern=re.compile(r"""(?:\$payload\[['"]linked_account_profiles['"]\]\s*=|['"]linked_account_profiles['"]\s*=>)"""),
        message="Initial Event detail hydration embeds `linked_account_profiles` rows in the payload.",
        resolution=(
            "Remove related-profile row embedding from initial detail hydration. The related-profile surface hydrates "
            "rows only when a tab is opened."
        ),
    ),
    SourcePattern(
        source_kind="groups-from-linked-profiles",
        pattern=re.compile(r"\bhydratePublicProfileGroupsFromLinkedProfiles\s*\("),
        message="Initial Event detail hydration reconstructs groups from linked-profile rows.",
        resolution=(
            "Do not hydrate groups from related-profile rows during initial detail payload assembly. The initial payload "
            "may expose merged tab metadata only; group/member rows hydrate on tab open."
        ),
    ),
)

ACCOUNT_FORMATTER_SOURCE_PATTERNS = (
    SourcePattern(
        source_kind="public-detail-groups",
        pattern=re.compile(r"\bpublicDetailGroups\s*\("),
        message="Initial Account Detail hydration resolves nested public member rows.",
        resolution=(
            "Do not resolve nested member rows during initial Account Detail hydration. Return group metadata only, "
            "and hydrate member rows only after the user opens a tab/group through the paginated canonical members path."
        ),
    ),
    SourcePattern(
        source_kind="group-member-ids",
        pattern=re.compile(r"\bgroupMemberIds\s*\("),
        message="Initial Account Detail hydration resolves nested member ids for immediate payload embedding.",
        resolution=(
            "Do not resolve member ids during initial Account Detail payload assembly. The initial payload may carry "
            "group metadata only; member rows hydrate only on tab/group open through paginated canonical reads."
        ),
    ),
    SourcePattern(
        source_kind="selected-summaries-by-ids",
        pattern=re.compile(r"\bselectedSummariesByIds\s*\("),
        message="Initial Account Detail hydration resolves nested member summaries for immediate payload embedding.",
        resolution=(
            "Do not resolve nested member summaries during initial Account Detail payload assembly. Member rows belong "
            "to the tab/group-open paginated canonical read path."
        ),
    ),
    SourcePattern(
        source_kind="with-selected-summaries",
        pattern=re.compile(r"\bwithSelectedSummaries\s*\("),
        message="Initial Account Detail hydration injects nested member summaries into the initial payload.",
        resolution=(
            "Do not inject nested member summaries during initial Account Detail hydration. Keep the initial payload "
            "metadata-only and hydrate rows only after the user opens a nested-members tab/group."
        ),
    ),
)

ACCOUNT_PUBLIC_PROJECTION_SOURCE_PATTERNS = (
    SourcePattern(
        source_kind="group-profiles",
        pattern=re.compile(r"\bgroupProfiles\s*\("),
        message="Account nested public detail projection resolves nested member rows while building initial detail groups.",
        resolution=(
            "Do not resolve nested member rows while building initial Account Detail groups. Group/member rows belong "
            "to the paginated canonical members path after the tab/group is opened."
        ),
    ),
    SourcePattern(
        source_kind="profiles-payload-key",
        pattern=re.compile(r"""['"]profiles['"]\s*=>"""),
        message="Account nested public detail projection embeds nested member rows in the initial detail payload.",
        resolution=(
            "Remove eager `profiles` row embedding from the initial Account Detail payload. The initial payload may "
            "return group metadata only, with member rows deferred to tab/group-open paginated reads."
        ),
    ),
)

ACCOUNT_GROUP_SERVICE_SOURCE_PATTERNS = (
    SourcePattern(
        source_kind="format-linked-profile",
        pattern=re.compile(r"\bformatLinkedProfile\s*\("),
        message="Account nested group public detail formatting resolves member cards during initial detail hydration.",
        resolution=(
            "Do not format member cards during initial Account Detail hydration. Hydrate member rows only after the "
            "user opens a nested-members tab/group through the paginated canonical path."
        ),
    ),
    SourcePattern(
        source_kind="profiles-variable-payload-key",
        pattern=re.compile(r"""['"]profiles['"]\s*=>\s*\$profiles\b"""),
        message="Account nested group public detail formatting embeds member rows in the initial detail payload.",
        resolution=(
            "Remove eager member-row embedding from initial Account Detail formatting. The initial payload is "
            "metadata-only; rows hydrate after tab/group open through paginated canonical reads."
        ),
    ),
)


@dataclass(frozen=True)
class ScanTarget:
    relative_path: str
    method_pattern: re.Pattern[str]
    finding_code: str
    source_patterns: tuple[SourcePattern, ...]


SCAN_TARGETS = (
    ScanTarget(
        relative_path="laravel-app/packages/belluga/belluga_events/src/Application/Events/EventQueryService.php",
        method_pattern=re.compile(r"^(formatEventDetail|formatPublicDetailPayload)$"),
        finding_code="EVENT-DETAIL-HYDRATION-ROWS",
        source_patterns=EVENT_SOURCE_PATTERNS,
    ),
    ScanTarget(
        relative_path="laravel-app/app/Application/AccountProfiles/AccountProfileFormatterService.php",
        method_pattern=re.compile(r"^format$"),
        finding_code="ACCOUNT-DETAIL-HYDRATION-ROWS",
        source_patterns=ACCOUNT_FORMATTER_SOURCE_PATTERNS,
    ),
    ScanTarget(
        relative_path="laravel-app/app/Application/AccountProfiles/AccountProfileNestedPublicMembersProjectionService.php",
        method_pattern=re.compile(r"^publicDetailGroups$"),
        finding_code="ACCOUNT-DETAIL-HYDRATION-ROWS",
        source_patterns=ACCOUNT_PUBLIC_PROJECTION_SOURCE_PATTERNS,
    ),
    ScanTarget(
        relative_path="laravel-app/app/Application/AccountProfiles/AccountProfileNestedGroupService.php",
        method_pattern=re.compile(r"^formatForPublicDetail$"),
        finding_code="ACCOUNT-DETAIL-HYDRATION-ROWS",
        source_patterns=ACCOUNT_GROUP_SERVICE_SOURCE_PATTERNS,
    ),
)


@dataclass(frozen=True)
class Finding:
    code: str
    path: str
    line: int
    method: str
    source_kind: str
    message: str
    resolution: str


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="Repository root that contains laravel-app/ and delphi-ai/.")
    parser.add_argument(
        "--path",
        action="append",
        default=[],
        help="Optional relative scan path override. When provided, replaces the default scan path set.",
    )
    parser.add_argument("--json-output", help="Optional file path for machine-readable JSON output.")
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
        return []

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


def clean_line(line: str) -> str:
    stripped = line.strip()
    while len(stripped) >= 2 and stripped[0] == stripped[-1] and stripped[0] in {"`", "'", '"'}:
        stripped = stripped[1:-1].strip()
    return stripped


def detect_findings(repo_relative_path: str, method: str, method_lines: list[tuple[int, str]]) -> list[Finding]:
    scan_target = next(
        (
            candidate
            for candidate in SCAN_TARGETS
            if candidate.relative_path == repo_relative_path and candidate.method_pattern.search(method) is not None
        ),
        None,
    )
    if scan_target is None:
        return []

    findings: list[Finding] = []
    for index, line in method_lines:
        for source_pattern in scan_target.source_patterns:
            if source_pattern.pattern.search(line):
                findings.append(
                    Finding(
                        code=scan_target.finding_code,
                        path=repo_relative_path,
                        line=index + 1,
                        method=method,
                        source_kind=source_pattern.source_kind,
                        message=source_pattern.message,
                        resolution=source_pattern.resolution,
                    )
                )
    return findings


def evaluate(repo_root: Path, scan_override: list[str]) -> dict[str, Any]:
    scan_paths = tuple(scan_override) if scan_override else DEFAULT_SCAN_PATHS
    findings: list[Finding] = []
    scanned_files: set[str] = set()

    for path in iter_php_files(repo_root, scan_paths):
        relative = relative_path(path, repo_root)
        scanned_files.add(relative)
        lines = path.read_text(encoding="utf-8").splitlines()
        for method, start, end in extract_method_ranges(lines):
            method_lines = non_comment_lines(lines, start, end)
            findings.extend(detect_findings(relative, method, method_lines))

    findings.sort(key=lambda item: (item.path, item.line, item.method, item.source_kind))
    return {
        "blocked": findings != [],
        "repo_root": repo_root.resolve().as_posix(),
        "scan_paths": list(scan_paths),
        "scanned_files": sorted(scanned_files),
        "decision": (
            "Initial Event detail and Account Detail hydration are metadata-only for nested-account surfaces. "
            "Nested-account rows hydrate only when a tab/group is opened through paginated canonical `accounts_nested` reads."
        ),
        "violations": [
            {
                "code": finding.code,
                "path": finding.path,
                "line": finding.line,
                "method": finding.method,
                "source_kind": finding.source_kind,
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
                f"({violation['method']}/{violation['source_kind']}) {violation['message']}"
            )
    else:
        lines.append("  - none")

    lines.append("resolution_prompt:")
    if violations:
        lines.append(
            "  - Treat `hydration` here as the initial Event detail or Account Detail payload before any related-profile or nested-members tab/group is opened."
        )
        lines.append("  - Keep that initial hydration metadata-only for nested-account surfaces.")
        lines.append("  - Hydrate nested-account rows only after the user opens a tab/group.")
        lines.append(
            "  - The allowed row-hydration path is tab/group open -> paginated canonical `accounts_nested` read -> row payload."
        )
        lines.append(
            "  - Rerun `python3 delphi-ai/tools/event_related_account_hydration_guard.py --repo <repo-root>` "
            "and require `Overall outcome: go` before treating the shared detail hydration boundary as converged."
        )
    else:
        lines.append("  - none")

    lines.append("context:")
    lines.append(f"  - repo_root: {result['repo_root']}")
    lines.append(f"  - decision: {result['decision']}")
    lines.append("  - scan_paths: " + ", ".join(result["scan_paths"]))
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
