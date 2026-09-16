#!/usr/bin/env python3
"""Compare a tactical TODO diff contract with the real repository changes.

The contract deliberately separates expected paths from paths that are never
expected.  A path that is not classified by either table is a deviation too:
the delivery lane must stop and the user must validate the new scope before
the TODO or implementation is changed.  A no-go is a decision gate for
analysis, not an automatic rollback: the agent may defend a necessary change
with evidence, while an unnecessary deviation must be reverted and noise
must be cleaned or otherwise explained.

Exit codes:
  0  GO: every observed change matches the approved contract.
  2  NO-GO: the contract is incomplete or a diff deviation was found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


RULE_ID = "paced.todo.diff-expectation"
SECTION_NAME = "Diff Expectation Contract"
BASELINES_SUBSECTION = "Repository Baselines"
EXPECTED_SUBSECTION = "Expected Changed Paths"
FORBIDDEN_SUBSECTION = "Not Expected Changed Paths"
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FIELD_RE_TEMPLATE = r"^\s*-\s+\*\*%s:\*\*\s*(.+?)\s*$"
TABLE_ROW_RE = re.compile(r"^\s*\|(.+)\|\s*$")
PLACEHOLDER_RE = re.compile(r"<[^>]+>")
ALLOWED_CHANGE_TYPES = {"A", "M", "D", "R", "T", "U", "X", "B", "??", "ANY"}
DEVIATION_TEACH = (
    "TEACH: analyze each reported item before changing files. Classify it as "
    "(a) an actual scope deviation, (b) a necessary/justifiable need, or "
    "(c) noise. This no-go is not an automatic rollback: the agent may defend "
    "retaining a necessary change with concrete evidence. Clean/remove noise; "
    "revert an unnecessary deviation; for a necessary scope expansion, obtain "
    "user validation, update the TODO contract, renew approval, and rerun the guard."
)
NO_GO_TEACH = (
    "TEACH: a no-go is a delivery stop for analysis, not an automatic rollback. "
    "For path/type findings, classify each item as scope deviation, "
    "necessary/justifiable need, or noise; defend necessary changes with "
    "evidence, clean noise, revert unnecessary deviations, and obtain user "
    "validation plus renewed approval for necessary scope expansion. For "
    "contract or baseline findings, repair the contract/environment and rerun the guard."
)


def strip_markup(value: str) -> str:
    value = value.strip()
    if value.startswith("`") and value.endswith("`") and len(value) >= 2:
        return value[1:-1].strip()
    return value


def normalize(value: str) -> str:
    value = strip_markup(value)
    value = re.sub(r"`([^`]+)`", r"\1", value)
    value = re.sub(r"[*_#>|]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip().lower()


def is_placeholder(value: str) -> bool:
    value = strip_markup(value)
    lowered = normalize(value)
    return not value or bool(PLACEHOLDER_RE.search(value)) or lowered in {
        "todo",
        "tbd",
        "unknown",
        "pending",
        "planned",
        "fixme",
    }


def extract_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines:
        match = HEADING_RE.match(line)
        if match and len(match.group(1)) == 2:
            current = match.group(2).strip()
            sections.setdefault(current, [])
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def find_section(sections: dict[str, list[str]], wanted: str) -> list[str]:
    target = normalize(wanted)
    for title, lines in sections.items():
        if normalize(title) == target:
            return lines
    return []


def find_subsection(lines: list[str], wanted: str) -> list[str]:
    target = normalize(wanted)
    start: int | None = None
    level = 0
    for index, line in enumerate(lines):
        match = HEADING_RE.match(line)
        if not match or len(match.group(1)) < 3:
            continue
        title = normalize(match.group(2))
        if start is None:
            if title == target:
                start = index + 1
                level = len(match.group(1))
            continue
        if len(match.group(1)) <= level:
            return lines[start:index]
    return lines[start:] if start is not None else []


def extract_field(lines: list[str], label: str) -> str | None:
    pattern = re.compile(FIELD_RE_TEMPLATE % re.escape(label))
    for line in lines:
        match = pattern.match(line)
        if match:
            return strip_markup(match.group(1))
    return None


def table_rows(lines: list[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in lines:
        match = TABLE_ROW_RE.match(line)
        if not match:
            continue
        cells = [strip_markup(cell) for cell in match.group(1).split("|")]
        if not any(cell.strip() for cell in cells):
            continue
        if set("".join(cells).replace(" ", "")) <= {"-", ":"}:
            continue
        rows.append(cells)
    return rows[1:] if len(rows) > 1 else []


def violation(code: str, message: str, resolution: str, section: str) -> dict[str, str]:
    return {
        "code": code,
        "message": message,
        "resolution": resolution,
        "section": section,
    }


def run_git(repo: Path, args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repo), *args],
        check=check,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )


def resolve_git_root(path: Path) -> Path:
    result = run_git(path, ["rev-parse", "--show-toplevel"])
    return Path(result.stdout.strip()).resolve()


def resolve_baseline(repo: Path, raw_ref: str) -> str:
    candidate = strip_markup(raw_ref)
    match = re.search(r"@([0-9a-fA-F]{7,64})$", candidate)
    if match:
        candidate = match.group(1)
    result = run_git(repo, ["rev-parse", "--verify", f"{candidate}^{{commit}}"])
    return result.stdout.strip()


def change_types(raw: str) -> set[str]:
    values = {item.strip().upper() for item in re.split(r"[,/\s]+", raw) if item.strip()}
    if not values:
        return set()
    if "ANY" in values:
        return {"ANY"}
    return values


def parse_contract(todo_path: Path, repo_root: Path) -> tuple[dict[str, Any], list[dict[str, str]]]:
    lines = todo_path.read_text(encoding="utf-8").splitlines()
    sections = extract_sections(lines)
    contract_lines = find_section(sections, SECTION_NAME)
    if not contract_lines:
        return {}, [
            violation(
                "DIFF-CONTRACT-MISSING",
                "The TODO has no `Diff Expectation Contract`.",
                "Add the contract before delivery: repository baselines, expected changed paths, and paths that are not expected. Any deviation must be validated with the user before the TODO or implementation changes.",
                SECTION_NAME,
            )
        ]

    violations: list[dict[str, str]] = []
    status = normalize(extract_field(contract_lines, "Contract status") or "")
    policy = normalize(extract_field(contract_lines, "Policy") or "")
    user_validation = normalize(extract_field(contract_lines, "User validation") or "")
    comparison_mode = normalize(extract_field(contract_lines, "Comparison mode") or "")

    if status != "required":
        violations.append(
            violation(
                "DIFF-CONTRACT-STATUS-INVALID",
                f"Diff Expectation Contract status is `{status or 'missing'}`, not `required`.",
                "Set `Contract status` to `required`; a delivery claim cannot bypass diff classification with an implicit or not-applicable contract.",
                SECTION_NAME,
            )
        )
    if "strict" not in policy:
        violations.append(
            violation(
                "DIFF-CONTRACT-POLICY-NOT-STRICT",
                "Diff Expectation Contract does not declare a strict policy.",
                "Declare `Policy: strict` and state that an unclassified or forbidden path blocks delivery.",
                SECTION_NAME,
            )
        )
    if "required" not in user_validation or "deviation" not in user_validation:
        violations.append(
            violation(
                "DIFF-CONTRACT-USER-VALIDATION-MISSING",
                "The contract does not require user validation for deviations.",
                "Declare `User validation: required on deviation` so delivery cannot silently absorb scope drift.",
                SECTION_NAME,
            )
        )
    if comparison_mode not in {"working_tree", "working tree"}:
        violations.append(
            violation(
                "DIFF-CONTRACT-COMPARISON-MODE-INVALID",
                f"Unsupported diff comparison mode: `{comparison_mode or 'missing'}`.",
                "Use `Comparison mode: working_tree` so tracked and non-ignored untracked changes are inspected.",
                SECTION_NAME,
            )
        )

    baselines = table_rows(find_subsection(contract_lines, BASELINES_SUBSECTION))
    expected_rows = table_rows(find_subsection(contract_lines, EXPECTED_SUBSECTION))
    forbidden_rows = table_rows(find_subsection(contract_lines, FORBIDDEN_SUBSECTION))

    if not baselines:
        violations.append(
            violation(
                "DIFF-BASELINES-MISSING",
                "No repository baseline rows were declared.",
                "Add one baseline row per repository whose diff is in scope, with a resolvable commit/ref.",
                f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
            )
        )
    if not expected_rows:
        violations.append(
            violation(
                "DIFF-EXPECTED-PATHS-MISSING",
                "No expected changed-path rows were declared.",
                "List the file/folder globs that implementation is allowed to change and why each is in scope.",
                f"{SECTION_NAME} / {EXPECTED_SUBSECTION}",
            )
        )
    if not forbidden_rows:
        violations.append(
            violation(
                "DIFF-FORBIDDEN-PATHS-MISSING",
                "No `Not Expected Changed Paths` rows were declared.",
                "List the file/folder/type patterns that must not appear in the implementation diff, including the reason they are prohibited.",
                f"{SECTION_NAME} / {FORBIDDEN_SUBSECTION}",
            )
        )

    repositories: dict[str, dict[str, Any]] = {}
    for row in baselines:
        if len(row) < 4 or any(is_placeholder(cell) for cell in row[:4]):
            violations.append(
                violation(
                    "DIFF-BASELINE-ROW-INCOMPLETE",
                    f"Repository baseline row is incomplete: {' | '.join(row)}",
                    "Use columns `Repository | Path | Baseline ref | Comparison mode` with concrete values.",
                    f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
                )
            )
            continue
        label, raw_path, raw_ref, raw_mode = row[:4]
        label = strip_markup(label)
        repo_path = (repo_root / strip_markup(raw_path)).resolve()
        mode = normalize(raw_mode)
        if mode not in {"working_tree", "working tree"}:
            violations.append(
                violation(
                    "DIFF-BASELINE-MODE-INVALID",
                    f"Repository `{label}` uses unsupported comparison mode `{raw_mode}`.",
                    "Use `working_tree` for every repository baseline.",
                    f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
                )
            )
        if not repo_path.is_dir():
            violations.append(
                violation(
                    "DIFF-REPOSITORY-MISSING",
                    f"Repository path for `{label}` does not exist: {repo_path}",
                    "Correct the repository path in the TODO or resolve the environment blocker before delivery.",
                    f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
                )
            )
            continue
        try:
            git_root = resolve_git_root(repo_path)
            baseline = resolve_baseline(git_root, raw_ref)
        except (OSError, subprocess.CalledProcessError) as exc:
            violations.append(
                violation(
                    "DIFF-BASELINE-UNRESOLVABLE",
                    f"Repository `{label}` baseline cannot be resolved: {exc}",
                    "Record the exact pre-implementation branch/commit baseline and ensure the repository is available.",
                    f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
                )
            )
            continue
        if label in repositories:
            violations.append(
                violation(
                    "DIFF-BASELINE-DUPLICATE-REPOSITORY",
                    f"Repository baseline `{label}` is declared more than once.",
                    "Keep one baseline row per repository label so the diff contract has one unambiguous comparison authority.",
                    f"{SECTION_NAME} / {BASELINES_SUBSECTION}",
                )
            )
            continue
        repositories[label] = {
            "label": label,
            "path": str(repo_path),
            "git_root": str(git_root),
            "baseline_ref": strip_markup(raw_ref),
            "baseline_commit": baseline,
            "comparison_mode": mode,
        }

    def parse_path_rows(rows: list[list[str]], section: str) -> list[dict[str, Any]]:
        parsed: list[dict[str, Any]] = []
        for row in rows:
            if len(row) < 4 or any(is_placeholder(cell) for cell in row[:4]):
                violations.append(
                    violation(
                        "DIFF-PATH-ROW-INCOMPLETE",
                        f"Diff path row is incomplete: {' | '.join(row)}",
                        "Use columns `Repository | Path glob | Change types | Reason` with concrete values.",
                        f"{SECTION_NAME} / {section}",
                    )
                )
                continue
            repository, pattern, raw_types, reason = [strip_markup(cell) for cell in row[:4]]
            types = change_types(raw_types)
            if repository not in repositories:
                violations.append(
                    violation(
                        "DIFF-PATH-UNKNOWN-REPOSITORY",
                        f"Diff path row references undeclared repository `{repository}`.",
                        "Add the repository to `Repository Baselines` or correct the row label.",
                        f"{SECTION_NAME} / {section}",
                    )
                )
            if not types or not types <= ALLOWED_CHANGE_TYPES:
                violations.append(
                    violation(
                        "DIFF-CHANGE-TYPE-INVALID",
                        f"Diff path row uses invalid change types `{raw_types}`.",
                        "Use a comma-separated subset of `A, M, D, R, T, U, X, B, ??, any`.",
                        f"{SECTION_NAME} / {section}",
                    )
                )
            parsed.append(
                {
                    "repository": repository,
                    "pattern": pattern.replace("\\", "/"),
                    "types": types,
                    "reason": reason,
                }
            )
        return parsed

    expected = parse_path_rows(expected_rows, EXPECTED_SUBSECTION)
    forbidden = parse_path_rows(forbidden_rows, FORBIDDEN_SUBSECTION)
    if violations:
        return {
            "repositories": repositories,
            "expected": expected,
            "forbidden": forbidden,
        }, violations
    return {"repositories": repositories, "expected": expected, "forbidden": forbidden}, []


def diff_entries(repository: dict[str, Any]) -> list[dict[str, str]]:
    repo = Path(repository["git_root"])
    baseline = repository["baseline_commit"]
    result = run_git(repo, ["diff", "--name-status", "--find-renames", "--no-ext-diff", "-z", baseline, "--"])
    tokens = result.stdout.split("\0")
    entries: list[dict[str, str]] = []
    index = 0
    while index < len(tokens) and tokens[index]:
        status = tokens[index]
        index += 1
        if status.startswith("R") or status.startswith("C"):
            if index + 1 >= len(tokens):
                break
            old_path, new_path = tokens[index], tokens[index + 1]
            index += 2
            for role, path in (("source", old_path), ("destination", new_path)):
                entries.append({"repository": repository["label"], "path": path, "status": "R", "role": role})
        else:
            if index >= len(tokens):
                break
            path = tokens[index]
            index += 1
            entries.append({"repository": repository["label"], "path": path, "status": status[:1], "role": "path"})

    untracked = run_git(repo, ["ls-files", "--others", "--exclude-standard", "-z"]).stdout.split("\0")
    for path in untracked:
        if path:
            entries.append({"repository": repository["label"], "path": path, "status": "??", "role": "untracked"})
    return entries


def row_matches(row: dict[str, Any], entry: dict[str, str]) -> bool:
    if row["repository"] != entry["repository"]:
        return False
    pattern = row["pattern"]
    path = entry["path"].replace("\\", "/").lstrip("./")
    pattern = pattern.lstrip("./")
    return fnmatch.fnmatchcase(path, pattern) or path == pattern


def validate_diff(contract: dict[str, Any]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    violations: list[dict[str, str]] = []
    context: dict[str, Any] = {
        "repositories": {},
        "actual_change_count": 0,
        "expected_change_count": 0,
        "forbidden_change_count": 0,
        "unclassified_change_count": 0,
    }
    all_entries: list[dict[str, str]] = []
    for label, repository in contract["repositories"].items():
        entries = diff_entries(repository)
        context["repositories"][label] = {
            "path": repository["git_root"],
            "baseline_commit": repository["baseline_commit"],
            "actual_change_count": len(entries),
        }
        all_entries.extend(entries)

    context["actual_change_count"] = len(all_entries)
    if not all_entries:
        violations.append(
            violation(
                "DIFF-EMPTY",
                "The declared delivery baseline has no tracked or non-ignored untracked changes.",
                "Confirm the implementation was made from the recorded baseline, or do not claim delivery until the approved change exists.",
                SECTION_NAME,
            )
        )

    for entry in all_entries:
        forbidden = [row for row in contract["forbidden"] if row_matches(row, entry)]
        if forbidden:
            context["forbidden_change_count"] += 1
            reasons = "; ".join(row["reason"] for row in forbidden)
            violations.append(
                violation(
                    "DIFF-FORBIDDEN-PATH",
                    f"Actual {entry['status']} change is explicitly not expected: {entry['repository']}:{entry['path']} ({entry['role']}). Reason: {reasons}",
                    DEVIATION_TEACH,
                    f"{SECTION_NAME} / {FORBIDDEN_SUBSECTION}",
                )
            )
            continue

        expected = [row for row in contract["expected"] if row_matches(row, entry)]
        if not expected:
            context["unclassified_change_count"] += 1
            violations.append(
                violation(
                    "DIFF-UNCLASSIFIED-PATH",
                    f"Actual {entry['status']} change is outside the expected diff contract: {entry['repository']}:{entry['path']} ({entry['role']}).",
                    DEVIATION_TEACH,
                    f"{SECTION_NAME} / {EXPECTED_SUBSECTION}",
                )
            )
            continue

        if not any("ANY" in row["types"] or entry["status"] in row["types"] for row in expected):
            context["unclassified_change_count"] += 1
            allowed = ", ".join(sorted({value for row in expected for value in row["types"]}))
            violations.append(
                violation(
                    "DIFF-CHANGE-TYPE-UNEXPECTED",
                    f"Actual change type `{entry['status']}` is not allowed for {entry['repository']}:{entry['path']}; contract allows `{allowed}`.",
                    DEVIATION_TEACH,
                    f"{SECTION_NAME} / {EXPECTED_SUBSECTION}",
                )
            )
            continue
        context["expected_change_count"] += 1

    return violations, context


def validate_todo(todo_path: Path, repo_root: Path) -> dict[str, Any]:
    result: dict[str, Any] = {
        "blocked": False,
        "violations": [],
        "context": {"todo_path": str(todo_path), "repo_root": str(repo_root)},
    }
    if not todo_path.is_file():
        result["blocked"] = True
        result["violations"] = [
            violation(
                "TODO-NOT-FOUND",
                f"TODO file does not exist: {todo_path}",
                "Pass an existing tactical TODO path.",
                "TODO File",
            )
        ]
        return result

    contract, contract_violations = parse_contract(todo_path, repo_root)
    result["violations"].extend(contract_violations)
    result["context"]["contract_repository_count"] = len(contract.get("repositories", {}))
    if contract_violations:
        result["blocked"] = True
        return result

    diff_violations, diff_context = validate_diff(contract)
    result["violations"].extend(diff_violations)
    result["context"].update(diff_context)
    result["blocked"] = bool(result["violations"])
    return result


def format_response(result: dict[str, Any]) -> str:
    lines = [
        "TODO Diff Expectation Guard",
        f"Rule: {RULE_ID}",
        f"Overall outcome: {'no-go' if result['blocked'] else 'go'}",
        "",
        "Context:",
    ]
    for key in sorted(result["context"]):
        value = result["context"][key]
        if isinstance(value, dict):
            lines.append(f"  - {key}:")
            for inner_key in sorted(value):
                lines.append(f"    - {inner_key}: {value[inner_key]}")
        else:
            lines.append(f"  - {key}: {value}")
    lines.append("")
    if result["blocked"]:
        lines.extend(["TEACH:", f"  - {NO_GO_TEACH}", ""])
    lines.append("Violations:")
    if result["violations"]:
        for item in result["violations"]:
            lines.append(f"  - [{item['code']}] {item['message']}")
            lines.append(f"    section: {item['section']}")
            lines.append(f"    resolution: {item['resolution']}")
    else:
        lines.append("  - none")
    return "\n".join(lines)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("todo_path", help="Path to the tactical TODO markdown file.")
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Checkout root used to resolve repository paths in the TODO contract (default: current directory).",
    )
    parser.add_argument("--json-output", help="Optional path for machine-readable JSON output.")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    result = validate_todo(Path(args.todo_path).resolve(), Path(args.repo_root).resolve())
    if args.json_output:
        output = Path(args.json_output).resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(format_response(result))
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except BrokenPipeError:
        raise SystemExit(1)
