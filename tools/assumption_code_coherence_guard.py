#!/usr/bin/env python3
"""Check whether live TODO assumptions are concretely anchored in current code/test files."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ALLOWED_GATE_DECISIONS = {"required", "recommended", "not_needed"}
ALLOWED_GATE_STATUSES = {
    "not_run",
    "running",
    "no_material_findings",
    "findings_integrated",
    "blocked",
    "waived",
}
SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}
LIVE_ASSUMPTION_HANDLINGS = {"Keep as Assumption", "Block"}
CODE_EXTENSIONS = {
    ".c",
    ".cc",
    ".cpp",
    ".cs",
    ".dart",
    ".go",
    ".h",
    ".hpp",
    ".java",
    ".js",
    ".jsx",
    ".kt",
    ".m",
    ".mm",
    ".php",
    ".py",
    ".rb",
    ".rs",
    ".sh",
    ".sql",
    ".swift",
    ".ts",
    ".tsx",
}
DOC_ONLY_EXTENSIONS = {".json", ".md", ".txt", ".yaml", ".yml"}
PATH_RE = re.compile(
    r"(?P<path>(?:/)?[A-Za-z0-9_.\-/]+\.(?:yaml|yml|json|dart|swift|tsx|ts|jsx|js|java|php|py|rb|rs|sql|hpp|cpp|cc|cs|txt|md|mm|kt|go|sh|c|h|m))(?::\d+)?"
)


def clean_value(raw: str) -> str:
    value = raw.strip()
    while len(value) >= 2 and value[0] == value[-1] and value[0] in {"`", '"', "'"}:
        value = value[1:-1].strip()
    return value


def is_placeholder(value: str) -> bool:
    stripped = clean_value(value)
    return stripped in {"", "missing", "n/a", "none"} or (
        stripped.startswith("<") and stripped.endswith(">")
    )


def read_lines(path: Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def find_section_bounds(lines: list[str], heading_prefix: str) -> tuple[int, int] | None:
    start = None
    for index, line in enumerate(lines):
        if line.strip().startswith(heading_prefix):
            start = index + 1
            break
    if start is None:
        return None
    end = len(lines)
    for index in range(start, len(lines)):
        if lines[index].strip().startswith("## "):
            end = index
            break
    return start, end


def extract_field_in_section(lines: list[str], heading_prefix: str, label: str) -> str:
    bounds = find_section_bounds(lines, heading_prefix)
    if bounds is None:
        return "missing"
    start, end = bounds
    prefix = f"- **{label}:**"
    for line in lines[start:end]:
        stripped = line.strip()
        if stripped.startswith(prefix):
            value = clean_value(stripped[len(prefix):])
            return value or "missing"
    return "missing"


def parse_markdown_table(lines: list[str], heading_prefix: str) -> list[list[str]]:
    bounds = find_section_bounds(lines, heading_prefix)
    if bounds is None:
        return []
    start, end = bounds
    table_lines = [line.strip() for line in lines[start:end] if line.strip().startswith("|")]
    if len(table_lines) < 3:
        return []
    rows: list[list[str]] = []
    for row_line in table_lines[2:]:
        cells = [clean_value(cell) for cell in row_line.strip().strip("|").split("|")]
        rows.append(cells)
    return rows


def infer_repo_root(todo_path: Path) -> Path:
    current = todo_path.resolve().parent
    first_git_root: Path | None = None
    for candidate in [current, *current.parents]:
        if (candidate / "foundation_documentation").is_dir():
            return candidate
        if first_git_root is None and (candidate / ".git").exists():
            first_git_root = candidate
    return first_git_root or todo_path.resolve().parent


def resolve_path(token: str, todo_path: Path, repo_root: Path) -> Path | None:
    cleaned = clean_value(token)
    if not cleaned:
        return None
    base_token = cleaned.split(":", 1)[0]
    candidate = Path(base_token)
    if candidate.is_absolute():
        return candidate if candidate.exists() else None
    for root in (repo_root, todo_path.parent):
        resolved = (root / candidate).resolve()
        if resolved.exists():
            return resolved
    return None


def extract_paths(evidence: str) -> list[str]:
    return [match.group("path") for match in PATH_RE.finditer(evidence)]


def is_code_like(path: Path) -> bool:
    suffix = path.suffix.lower()
    return suffix in CODE_EXTENSIONS or "/test/" in path.as_posix() or path.as_posix().endswith("_test.dart")


def build_issue(code: str, message: str, assumption_id: str | None = None, severity: str = "error") -> dict:
    payload = {
        "severity": severity,
        "code": code,
        "message": message,
    }
    if assumption_id is not None:
        payload["assumption_id"] = assumption_id
    return payload


def evaluate(todo_path: Path) -> dict:
    lines = read_lines(todo_path)
    repo_root = infer_repo_root(todo_path)
    issues: list[dict] = []

    assumption_rows = parse_markdown_table(lines, "## Assumptions Preview")
    assumptions: list[dict] = []
    if not assumption_rows:
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-ASSUMPTIONS-MISSING",
                "Assumptions Preview is missing or does not contain a parseable assumptions table.",
            )
        )

    for row in assumption_rows:
        if len(row) < 6:
            continue
        assumption_id = row[0]
        if is_placeholder(assumption_id):
            continue
        evidence = row[2]
        handling = row[5]
        tokens = extract_paths(evidence)
        resolved_paths = [resolved for token in tokens if (resolved := resolve_path(token, todo_path, repo_root)) is not None]
        code_paths = [path for path in resolved_paths if is_code_like(path)]
        assumptions.append(
            {
                "assumption_id": assumption_id,
                "handling": handling,
                "evidence": evidence,
                "path_tokens": tokens,
                "resolved_paths": [path.as_posix() for path in resolved_paths],
                "resolved_code_paths": [path.as_posix() for path in code_paths],
            }
        )

        if handling in LIVE_ASSUMPTION_HANDLINGS:
            if not tokens:
                issues.append(
                    build_issue(
                        "ASSUMPTION-CODE-NO-PATH-EVIDENCE",
                        "Live assumption evidence must cite concrete file paths, not only prose.",
                        assumption_id=assumption_id,
                    )
                )
            elif not resolved_paths:
                issues.append(
                    build_issue(
                        "ASSUMPTION-CODE-PATH-NOT-FOUND",
                        "Live assumption cites paths, but none resolve in the current checkout.",
                        assumption_id=assumption_id,
                    )
                )
            elif not code_paths:
                issues.append(
                    build_issue(
                        "ASSUMPTION-CODE-NO-CODE-ANCHOR",
                        "Live assumption evidence resolves only to doc-only artifacts; at least one code/test path is required.",
                        assumption_id=assumption_id,
                    )
                )

    live_assumption_ids = [
        entry["assumption_id"]
        for entry in assumptions
        if entry["handling"] in LIVE_ASSUMPTION_HANDLINGS
    ]

    gate_heading = "## Gate: Assumption Code Coherence"
    gate_section_present = find_section_bounds(lines, gate_heading) is not None
    gate_decision = extract_field_in_section(lines, gate_heading, "Gate decision")
    gate_status = extract_field_in_section(lines, gate_heading, "Gate status")
    gate_evidence = extract_field_in_section(lines, gate_heading, "Evidence / reference")
    gate_waiver = extract_field_in_section(
        lines,
        gate_heading,
        "Waiver authority / reference (required if waived)",
    )

    if not gate_section_present:
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-MISSING",
                "TODO is missing the `Gate: Assumption Code Coherence` section.",
            )
        )
    if gate_decision not in ALLOWED_GATE_DECISIONS:
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-DECISION-INVALID",
                "Gate decision is missing or invalid.",
            )
        )
    if gate_status not in ALLOWED_GATE_STATUSES:
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-STATUS-INVALID",
                "Gate status is missing or invalid.",
            )
        )
    if live_assumption_ids and gate_decision == "not_needed":
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-DECISION-TOO-WEAK",
                "Gate decision cannot be `not_needed` while live assumptions still exist.",
            )
        )
    if gate_status in SATISFYING_GATE_STATUSES and is_placeholder(gate_evidence):
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-EVIDENCE-MISSING",
                "A satisfying guard status requires evidence/reference.",
            )
        )
    if gate_status == "waived" and is_placeholder(gate_waiver):
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-WAIVER-MISSING",
                "Waived assumption-vs-code guard requires waiver authority/reference.",
            )
        )
    if gate_decision == "required" and gate_status not in SATISFYING_GATE_STATUSES:
        issues.append(
            build_issue(
                "ASSUMPTION-CODE-GATE-UNRESOLVED",
                "Required assumption-vs-code guard is not yet in a satisfying state.",
            )
        )

    return {
        "artifact_kind": "assumption_code_coherence_guard",
        "todo_path": str(todo_path),
        "repo_root": str(repo_root),
        "overall_outcome": "go" if not issues else "no-go",
        "live_assumption_ids": live_assumption_ids,
        "gate": {
            "section_present": gate_section_present,
            "decision": gate_decision,
            "status": gate_status,
            "evidence_reference": gate_evidence,
            "waiver_reference": gate_waiver,
        },
        "assumptions": assumptions,
        "issues": issues,
    }


def render_text(report: dict) -> str:
    lines = [
        f"Assumption-vs-code coherence guard for `{report['todo_path']}`",
        f"Overall outcome: {report['overall_outcome']}",
        f"Live assumptions checked: {len(report['live_assumption_ids'])}",
        f"Gate decision/status: {report['gate']['decision']} / {report['gate']['status']}",
    ]
    if report["issues"]:
        lines.append("Issues:")
        for issue in report["issues"]:
            prefix = f"[{issue['severity']}] {issue['code']}"
            if "assumption_id" in issue:
                prefix = f"{prefix} ({issue['assumption_id']})"
            lines.append(f"- {prefix}: {issue['message']}")
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate that live TODO assumptions are concretely anchored in current code/test files."
    )
    parser.add_argument("--todo", required=True, help="Path to the tactical TODO markdown file.")
    parser.add_argument("--json-output", help="Optional path to write the JSON report.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    report = evaluate(todo_path)
    if args.json_output:
        output_path = Path(args.json_output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(report, indent=2, ensure_ascii=True) + "\n", encoding="utf-8")
    print(render_text(report), end="")
    return 0 if report["overall_outcome"] == "go" else 1


if __name__ == "__main__":
    raise SystemExit(main())
