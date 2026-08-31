#!/usr/bin/env python3
"""Detect material scope drift between a current TODO and its pushed pre-review baseline."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
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
BASELINE_GATE_HEADING = "## Gate: Review Baseline Freeze"
SCOPE_DRIFT_GATE_HEADING = "## Gate: Review Scope Drift"
MATERIAL_HEADINGS = (
    "## Context",
    "## Framing Source & Story Slice",
    "## Contract Boundary",
    "## Scope",
    "## Out of Scope",
    "## Bounded But Elastic Guardrails",
    "## Definition of Done",
    "## Validation Steps",
    "## Execution Lane Tracking",
    "## Complexity",
    "## Canonical Module Anchors",
    "## Decisions (Resolved Before Freeze)",
    "## Module Decision Baseline Snapshot",
    "## Decision Baseline (Frozen Before Implementation)",
    "## Architecture Change Governance",
    "## Questions To Close",
    "## Assumptions Preview",
    "## Execution Plan",
    "## Flow Evidence Planning Matrix",
    "## Runtime / Rollout Notes",
    "## Security Risk Assessment",
    "## Performance & Concurrency Risk Assessment",
)
H2_RE = re.compile(r"^##\s+.+$")


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


def section_present(lines: list[str], heading_prefix: str) -> bool:
    return find_section_bounds(lines, heading_prefix) is not None


def normalize_section(lines: list[str]) -> list[str]:
    normalized = [line.rstrip() for line in lines]
    while normalized and normalized[0] == "":
        normalized.pop(0)
    while normalized and normalized[-1] == "":
        normalized.pop()
    collapsed: list[str] = []
    blank_streak = False
    for line in normalized:
        if line == "":
            if blank_streak:
                continue
            blank_streak = True
        else:
            blank_streak = False
        collapsed.append(line)
    return collapsed


def section_body(lines: list[str], heading_prefix: str) -> list[str] | None:
    bounds = find_section_bounds(lines, heading_prefix)
    if bounds is None:
        return None
    start, end = bounds
    return normalize_section(lines[start:end])


def run_git(repo_root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repo_root), *args],
        capture_output=True,
        text=True,
        check=False,
    )


def infer_repo_root(todo_path: Path) -> Path:
    result = run_git(todo_path.resolve().parent, "rev-parse", "--show-toplevel")
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "Unable to infer git repo root for TODO.")
    return Path(result.stdout.strip()).resolve()


def load_git_file(repo_root: Path, commit: str, relative_path: str) -> list[str] | None:
    result = run_git(repo_root, "show", f"{commit}:{relative_path}")
    if result.returncode != 0:
        return None
    return result.stdout.splitlines()


def commit_reaches_ref(repo_root: Path, commit: str, ref: str) -> bool:
    ref_check = run_git(repo_root, "rev-parse", "--verify", ref)
    if ref_check.returncode != 0:
        return False
    ancestor_check = run_git(repo_root, "merge-base", "--is-ancestor", commit, ref)
    return ancestor_check.returncode == 0


def material_changes(baseline_lines: list[str], current_lines: list[str]) -> list[str]:
    changed: list[str] = []
    for heading in MATERIAL_HEADINGS:
        baseline_body = section_body(baseline_lines, heading)
        current_body = section_body(current_lines, heading)
        if baseline_body is None and current_body is None:
            continue
        if baseline_body != current_body:
            changed.append(heading.replace("## ", "", 1))
    return changed


def build_issue(code: str, message: str, severity: str = "error") -> dict:
    return {
        "severity": severity,
        "code": code,
        "message": message,
    }


def evaluate(todo_path: Path) -> dict:
    current_lines = read_lines(todo_path)
    issues: list[dict] = []

    baseline_gate = {
        "section_present": section_present(current_lines, BASELINE_GATE_HEADING),
        "decision": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Gate decision"),
        "status": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Gate status"),
        "branch": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Baseline branch"),
        "commit": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Baseline commit"),
        "push_reference": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Baseline push reference"),
        "evidence_reference": extract_field_in_section(current_lines, BASELINE_GATE_HEADING, "Evidence / reference"),
        "waiver_reference": extract_field_in_section(
            current_lines,
            BASELINE_GATE_HEADING,
            "Waiver authority / reference (required if waived)",
        ),
    }
    scope_gate = {
        "section_present": section_present(current_lines, SCOPE_DRIFT_GATE_HEADING),
        "decision": extract_field_in_section(current_lines, SCOPE_DRIFT_GATE_HEADING, "Gate decision"),
        "status": extract_field_in_section(current_lines, SCOPE_DRIFT_GATE_HEADING, "Gate status"),
        "evidence_reference": extract_field_in_section(current_lines, SCOPE_DRIFT_GATE_HEADING, "Evidence / reference"),
        "waiver_reference": extract_field_in_section(
            current_lines,
            SCOPE_DRIFT_GATE_HEADING,
            "Waiver authority / reference (required if waived)",
        ),
    }

    if not baseline_gate["section_present"]:
        issues.append(build_issue("REVIEW-BASELINE-GATE-MISSING", "TODO is missing `Gate: Review Baseline Freeze`."))
    if baseline_gate["decision"] not in ALLOWED_GATE_DECISIONS:
        issues.append(build_issue("REVIEW-BASELINE-DECISION-INVALID", "Review baseline freeze gate decision is missing or invalid."))
    if baseline_gate["status"] not in ALLOWED_GATE_STATUSES:
        issues.append(build_issue("REVIEW-BASELINE-STATUS-INVALID", "Review baseline freeze gate status is missing or invalid."))
    if baseline_gate["decision"] == "required" and baseline_gate["status"] not in SATISFYING_GATE_STATUSES:
        issues.append(build_issue("REVIEW-BASELINE-UNRESOLVED", "Required review baseline freeze gate is not yet in a satisfying state."))
    if baseline_gate["status"] in SATISFYING_GATE_STATUSES and is_placeholder(baseline_gate["evidence_reference"]):
        issues.append(build_issue("REVIEW-BASELINE-EVIDENCE-MISSING", "A satisfying review baseline freeze gate requires evidence/reference."))
    if baseline_gate["status"] == "waived" and is_placeholder(baseline_gate["waiver_reference"]):
        issues.append(build_issue("REVIEW-BASELINE-WAIVER-MISSING", "Waived review baseline freeze gate requires waiver authority/reference."))
    if is_placeholder(baseline_gate["branch"]):
        issues.append(build_issue("REVIEW-BASELINE-BRANCH-MISSING", "Review baseline freeze is missing the baseline branch."))
    if is_placeholder(baseline_gate["commit"]):
        issues.append(build_issue("REVIEW-BASELINE-COMMIT-MISSING", "Review baseline freeze is missing the baseline commit."))
    if is_placeholder(baseline_gate["push_reference"]):
        issues.append(build_issue("REVIEW-BASELINE-PUSH-REF-MISSING", "Review baseline freeze is missing the baseline push reference."))

    if not scope_gate["section_present"]:
        issues.append(build_issue("REVIEW-SCOPE-DRIFT-GATE-MISSING", "TODO is missing `Gate: Review Scope Drift`."))
    if scope_gate["decision"] not in ALLOWED_GATE_DECISIONS:
        issues.append(build_issue("REVIEW-SCOPE-DRIFT-DECISION-INVALID", "Review scope drift gate decision is missing or invalid."))
    if scope_gate["status"] not in ALLOWED_GATE_STATUSES:
        issues.append(build_issue("REVIEW-SCOPE-DRIFT-STATUS-INVALID", "Review scope drift gate status is missing or invalid."))

    repo_root: Path | None = None
    baseline_lines: list[str] | None = None
    todo_relative_path = "missing"

    if not issues or any(issue["code"].startswith("REVIEW-SCOPE-DRIFT") for issue in issues):
        try:
            repo_root = infer_repo_root(todo_path)
            try:
                todo_relative_path = str(todo_path.resolve().relative_to(repo_root))
            except ValueError:
                todo_relative_path = str(Path(todo_path.resolve()).relative_to(repo_root.resolve()))
        except Exception as exc:  # pragma: no cover - defensive
            issues.append(build_issue("REVIEW-SCOPE-DRIFT-REPO-ROOT-FAILED", str(exc)))

    if repo_root is not None and not is_placeholder(baseline_gate["commit"]):
        commit_check = run_git(repo_root, "cat-file", "-e", f"{baseline_gate['commit']}^{{commit}}")
        if commit_check.returncode != 0:
            issues.append(build_issue("REVIEW-BASELINE-COMMIT-NOT-FOUND", "Baseline commit does not resolve in the TODO repository."))
        else:
            baseline_lines = load_git_file(repo_root, baseline_gate["commit"], todo_relative_path)
            if baseline_lines is None:
                issues.append(build_issue("REVIEW-BASELINE-FILE-MISSING", "TODO file does not exist at the recorded baseline commit."))

        if not is_placeholder(baseline_gate["push_reference"]) and not commit_reaches_ref(
            repo_root, baseline_gate["commit"], baseline_gate["push_reference"]
        ):
            issues.append(
                build_issue(
                    "REVIEW-BASELINE-PUSH-REF-MISMATCH",
                    "Recorded baseline commit is not reachable from the recorded pushed reference.",
                )
            )

    changed_sections: list[str] = []
    if baseline_lines is not None:
        changed_sections = material_changes(baseline_lines, current_lines)
        if changed_sections:
            issues.append(
                build_issue(
                    "REVIEW-SCOPE-DRIFT-MATERIAL-CHANGE",
                    "Material scope-governing sections changed after the pushed review baseline: "
                    + ", ".join(changed_sections)
                    + ". Renewed user scope validation is required before approval resumes. Return the TODO to the review loop, refresh the pushed baseline when needed, and rerun the affected review/guard lanes. This is not a hard rejection.",
                )
            )

    return {
        "artifact_kind": "review_scope_drift_guard",
        "todo_path": str(todo_path),
        "repo_root": str(repo_root) if repo_root is not None else "missing",
        "todo_relative_path": todo_relative_path,
        "overall_outcome": "go" if not issues else "no-go",
        "baseline_gate": baseline_gate,
        "scope_drift_gate": scope_gate,
        "changed_sections": changed_sections,
        "material_headings": list(MATERIAL_HEADINGS),
        "issues": issues,
    }


def render_text(report: dict) -> str:
    baseline = report["baseline_gate"]
    lines = [
        f"Review scope drift guard for `{report['todo_path']}`",
        f"Overall outcome: {report['overall_outcome']}",
        f"Baseline branch/commit: {baseline['branch']} / {baseline['commit']}",
        f"Baseline push reference: {baseline['push_reference']}",
        f"Material sections compared: {len(report['material_headings'])}",
        f"Changed material sections: {len(report['changed_sections'])}",
    ]
    if report["changed_sections"]:
        lines.append("Changed sections:")
        for heading in report["changed_sections"]:
            lines.append(f"- {heading}")
    if report["issues"]:
        lines.append("Issues:")
        for issue in report["issues"]:
            lines.append(f"- [{issue['severity']}] {issue['code']}: {issue['message']}")
    if any(issue["code"] == "REVIEW-SCOPE-DRIFT-MATERIAL-CHANGE" for issue in report["issues"]):
        lines.append("Interpretation:")
        lines.append("- scope-drift `no-go` is a revalidation checkpoint, not a hard rejection.")
        lines.append(
            "- return the TODO to the review loop, revalidate the evolved scope with the user, refresh the pushed baseline when needed, and rerun the affected review/guard lanes."
        )
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Detect material scope-governing drift between a current TODO and its pushed review baseline."
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
