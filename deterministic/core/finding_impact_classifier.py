#!/usr/bin/env python3
"""Deterministic impact classifier for code-change findings.

Classifies the impact of a proposed code change (from Copilot review,
Triple Audit, or any other finding source) before it is applied.

The goal is to prevent silent logic changes: findings that look cosmetic
but actually alter conditional flows, business decisions, or architecture.

T.E.A.C.H. compliance:
  Triggered  – called when processing a finding that proposes code changes
  Enforced   – exit code 2 = BLOCKED (logic-change or architecture-change)
               exit code 0 = ALLOWED (cosmetic or refactor)
  Automated  – Python script analyzing git diff or patch content
  Contextual – emits affected files, change categories, decision-file matches
  Hinting    – resolution_prompt explains why the change is blocked and what
               the operator must do (verify Constitution, get human approval)

Usage:
  python3 finding_impact_classifier.py --diff <path-to-diff-or-patch>
      [--constitution <path-to-constitution-dir>]
      [--finding-id <id>]
      [--finding-text <description>]

  Or pipe a diff:
  git diff HEAD~1 | python3 finding_impact_classifier.py --diff -

Exit codes:
  0  ALLOWED: cosmetic or refactor — safe to apply without escalation
  2  BLOCKED: logic-change or architecture-change — requires human review
  1  Operational error
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

RULE_ID = "paced.finding.impact-classifier"

# Patterns that indicate conditional/logic changes
LOGIC_CHANGE_PATTERNS = [
    # Conditional flow
    re.compile(r"^[+-]\s*(if|else\s*if|elif|else|switch|case|default)\b", re.MULTILINE),
    re.compile(r"^[+-].*\?\s*.*:", re.MULTILINE),  # ternary
    # Exception/error handling flow
    re.compile(r"^[+-]\s*(try|catch|except|finally|throw|raise|rethrow)\b", re.MULTILINE),
    # Loop control flow
    re.compile(r"^[+-]\s*(break|continue|return)\b", re.MULTILINE),
    # Guard clauses
    re.compile(r"^[+-].*guard\s+", re.MULTILINE),  # Swift/Dart guard
    # Null/optional handling
    re.compile(r"^[+-].*\?\?", re.MULTILINE),  # null coalescing
    re.compile(r"^[+-].*\?\.", re.MULTILINE),   # optional chaining (added/removed)
    # Assertion/validation
    re.compile(r"^[+-]\s*(assert|require|ensure)\b", re.MULTILINE),
]

# Patterns that indicate architecture-level changes
ARCHITECTURE_PATTERNS = [
    # Class/interface/trait structure
    re.compile(r"^[+-]\s*(class|interface|trait|abstract|extends|implements|mixin|with)\b", re.MULTILINE),
    # Module/import restructuring (new dependencies)
    re.compile(r"^[+]\s*(import|require|use|from\s+\S+\s+import)\b", re.MULTILINE),
    # Route/endpoint definitions
    re.compile(r"^[+-]\s*(Route::|@(Get|Post|Put|Delete|Patch|Route))\b", re.MULTILINE),
    # Database/migration
    re.compile(r"^[+-].*(Schema::|Migration|migrate|CreateTable|AlterTable)", re.MULTILINE),
    # Dependency injection / service registration
    re.compile(r"^[+-].*(bind|singleton|register|provide|inject)\s*\(", re.MULTILINE),
]

# File path patterns that indicate business-decision-sensitive files
DECISION_FILE_PATTERNS = [
    re.compile(r"constitution", re.IGNORECASE),
    re.compile(r"module.*\.md$", re.IGNORECASE),
    re.compile(r"decision", re.IGNORECASE),
    re.compile(r"policy", re.IGNORECASE),
    re.compile(r"contract", re.IGNORECASE),
    re.compile(r"guard", re.IGNORECASE),
    re.compile(r"middleware", re.IGNORECASE),
    re.compile(r"auth", re.IGNORECASE),
    re.compile(r"tenant.*access", re.IGNORECASE),
    re.compile(r"permission", re.IGNORECASE),
]


# ---------------------------------------------------------------------------
# Diff parsing
# ---------------------------------------------------------------------------

def parse_diff_files(diff_text: str) -> list[dict]:
    """Parse a unified diff into per-file change records."""
    file_pattern = re.compile(r"^diff --git a/(.+?) b/(.+?)$", re.MULTILINE)
    files: list[dict] = []

    splits = file_pattern.split(diff_text)
    # splits[0] is before first match, then groups of (a_path, b_path, content)
    i = 1
    while i < len(splits) - 2:
        a_path = splits[i]
        b_path = splits[i + 1]
        content = splits[i + 2] if i + 2 < len(splits) else ""
        i += 3

        # Extract only added/removed lines
        added_lines = []
        removed_lines = []
        for line in content.splitlines():
            if line.startswith("+") and not line.startswith("+++"):
                added_lines.append(line)
            elif line.startswith("-") and not line.startswith("---"):
                removed_lines.append(line)

        files.append({
            "path": b_path,
            "added_count": len(added_lines),
            "removed_count": len(removed_lines),
            "added_lines": added_lines,
            "removed_lines": removed_lines,
            "full_diff": content,
        })

    return files


# ---------------------------------------------------------------------------
# Classification logic
# ---------------------------------------------------------------------------

def classify_file_changes(file_record: dict) -> dict:
    """Classify the impact of changes to a single file."""
    path = file_record["path"]
    diff_content = file_record["full_diff"]
    change_lines = "\n".join(file_record["added_lines"] + file_record["removed_lines"])

    categories: list[str] = []
    evidence: list[str] = []

    # Check for logic changes
    logic_hits = []
    for pattern in LOGIC_CHANGE_PATTERNS:
        matches = pattern.findall(change_lines)
        if matches:
            logic_hits.extend(matches[:3])  # cap evidence per pattern
    if logic_hits:
        categories.append("logic-change")
        evidence.append(f"Conditional/flow changes detected: {', '.join(repr(h) for h in logic_hits[:5])}")

    # Check for architecture changes
    arch_hits = []
    for pattern in ARCHITECTURE_PATTERNS:
        matches = pattern.findall(change_lines)
        if matches:
            arch_hits.extend(matches[:3])
    if arch_hits:
        categories.append("architecture-change")
        evidence.append(f"Structural changes detected: {', '.join(repr(h) for h in arch_hits[:5])}")

    # Check if file is a decision-sensitive file
    is_decision_file = False
    for pattern in DECISION_FILE_PATTERNS:
        if pattern.search(path):
            is_decision_file = True
            evidence.append(f"File matches decision-sensitive pattern: {path}")
            break

    # If no logic or architecture patterns, classify as cosmetic or refactor
    if not categories:
        if file_record["added_count"] + file_record["removed_count"] > 50:
            categories.append("refactor")
            evidence.append(f"Large change ({file_record['added_count']}+ / {file_record['removed_count']}-) without logic patterns — classified as refactor")
        else:
            categories.append("cosmetic")
            evidence.append("No conditional/structural patterns detected — classified as cosmetic")

    return {
        "path": path,
        "categories": categories,
        "is_decision_file": is_decision_file,
        "evidence": evidence,
        "added_count": file_record["added_count"],
        "removed_count": file_record["removed_count"],
    }


def classify_finding(diff_text: str, constitution_dir: Path | None = None) -> dict:
    """Classify the overall impact of a finding's diff."""
    files = parse_diff_files(diff_text)
    if not files:
        return {
            "classification": "cosmetic",
            "blocked": False,
            "files": [],
            "summary": "No file changes detected in diff.",
            "violations": [],
        }

    file_results = [classify_file_changes(f) for f in files]

    # Aggregate categories across all files
    all_categories: set[str] = set()
    decision_files: list[str] = []
    violations: list[dict] = []

    for fr in file_results:
        all_categories.update(fr["categories"])
        if fr["is_decision_file"]:
            decision_files.append(fr["path"])

    # Check constitution directory for documented decisions
    constitution_matches: list[str] = []
    if constitution_dir and constitution_dir.exists():
        touched_paths = {fr["path"] for fr in file_results}
        for md_file in constitution_dir.glob("**/*.md"):
            try:
                content = md_file.read_text(encoding="utf-8", errors="replace")
                for tp in touched_paths:
                    # Check if the constitution references the touched file
                    basename = Path(tp).name
                    if basename in content:
                        constitution_matches.append(
                            f"{md_file.name} references {tp}"
                        )
            except Exception:
                pass

    # Determine overall classification (worst wins)
    if "architecture-change" in all_categories:
        classification = "architecture-change"
    elif "logic-change" in all_categories:
        classification = "logic-change"
    elif "refactor" in all_categories:
        classification = "refactor"
    else:
        classification = "cosmetic"

    blocked = classification in ("logic-change", "architecture-change")

    # Build violations for blocked changes
    if blocked:
        logic_files = [fr["path"] for fr in file_results if "logic-change" in fr["categories"]]
        arch_files = [fr["path"] for fr in file_results if "architecture-change" in fr["categories"]]

        if logic_files:
            violations.append({
                "code": "FINDING-LOGIC-CHANGE",
                "message": (
                    f"Finding alters conditional/flow logic in: "
                    f"{', '.join(logic_files[:5])}"
                ),
                "resolution": (
                    "This finding changes conditional logic (if/else/switch/guard/return). "
                    "Before applying: (1) verify the change against the Constitution and "
                    "frozen decisions in the TODO, (2) classify as 'confirmed defect' or "
                    "'by-design intent', (3) if ambiguous, run wf-docker-independent-critique-method "
                    "with a bounded package. Do not apply blindly."
                ),
            })

        if arch_files:
            violations.append({
                "code": "FINDING-ARCHITECTURE-CHANGE",
                "message": (
                    f"Finding alters structural/architectural elements in: "
                    f"{', '.join(arch_files[:5])}"
                ),
                "resolution": (
                    "This finding changes class/interface/route/migration structure. "
                    "Before applying: (1) verify against module decisions and Constitution, "
                    "(2) run wf-docker-independent-critique-method with a bounded package, "
                    "(3) require explicit human approval. Architecture changes from findings "
                    "must never be applied automatically."
                ),
            })

        if decision_files:
            violations.append({
                "code": "FINDING-DECISION-FILE-TOUCHED",
                "message": (
                    f"Finding touches decision-sensitive file(s): "
                    f"{', '.join(decision_files[:5])}"
                ),
                "resolution": (
                    "This finding modifies files that contain or enforce business decisions. "
                    "Cross-reference with the Constitution and module decision baselines "
                    "before applying."
                ),
            })

        if constitution_matches:
            violations.append({
                "code": "FINDING-CONSTITUTION-REFERENCE",
                "message": (
                    f"Touched files are referenced in Constitution documents: "
                    f"{'; '.join(constitution_matches[:5])}"
                ),
                "resolution": (
                    "The Constitution explicitly documents decisions about these files. "
                    "Verify that the finding does not contradict documented decisions."
                ),
            })

    return {
        "classification": classification,
        "blocked": blocked,
        "files": file_results,
        "decision_files": decision_files,
        "constitution_matches": constitution_matches,
        "summary": (
            f"{len(files)} file(s) analyzed. "
            f"Classification: {classification}. "
            f"{'BLOCKED — requires human review.' if blocked else 'ALLOWED — safe to apply.'}"
        ),
        "violations": violations,
    }


# ---------------------------------------------------------------------------
# Output rendering
# ---------------------------------------------------------------------------

def render_text(result: dict, finding_id: str | None, finding_text: str | None) -> str:
    """Render the T.E.A.C.H. runtime response as human-readable text."""
    lines: list[str] = []
    lines.append("Finding Impact Classifier")
    if finding_id:
        lines.append(f"Finding ID: {finding_id}")
    if finding_text:
        lines.append(f"Finding: {finding_text[:120]}")
    lines.append("")

    lines.append("Classification summary")
    lines.append(f"  - Overall: {result['classification']}")
    lines.append(f"  - Files analyzed: {len(result['files'])}")
    for fr in result["files"]:
        cats = ", ".join(fr["categories"])
        dec = " [DECISION-FILE]" if fr["is_decision_file"] else ""
        lines.append(f"  - {fr['path']}: {cats}{dec} (+{fr['added_count']}/-{fr['removed_count']})")
    if result.get("decision_files"):
        lines.append(f"  - Decision-sensitive files: {', '.join(result['decision_files'])}")
    if result.get("constitution_matches"):
        lines.append(f"  - Constitution references: {'; '.join(result['constitution_matches'][:3])}")
    lines.append("")

    status = "blocked" if result["blocked"] else "ready"
    enforcement = "stop_before_apply" if result["blocked"] else "allow_apply"

    lines.append("TEACH runtime response")
    lines.append(f"status: {status}")
    lines.append(f"enforcement: {enforcement}")
    lines.append(f"rule_id: {RULE_ID}")

    lines.append("violation:")
    if not result["violations"]:
        lines.append("  - none")
    else:
        for v in result["violations"]:
            lines.append(f"  - [{v['code']}] {v['message']}")

    lines.append("resolution_prompt:")
    if not result["violations"]:
        lines.append(f"  - Finding classified as '{result['classification']}' — safe to apply.")
        lines.append("  - Proceed with the standard finding scrutiny gate in the promotion skill.")
    else:
        for v in result["violations"]:
            lines.append(f"  - {v['resolution']}")

    lines.append("context:")
    lines.append(f"  classification: {result['classification']}")
    lines.append(f"  blocked: {result['blocked']}")
    lines.append(f"  files_analyzed: {len(result['files'])}")
    for fr in result["files"]:
        lines.append(f"  file_{fr['path']}:")
        lines.append(f"    categories: {fr['categories']}")
        for ev in fr["evidence"][:3]:
            lines.append(f"    evidence: {ev}")

    outcome = "no-go" if result["blocked"] else "go"
    lines.append("")
    lines.append(f"Overall outcome: {outcome}")
    return "\n".join(lines) + "\n"


def render_json(result: dict, finding_id: str | None, finding_text: str | None) -> str:
    """Render the result as structured JSON."""
    payload = {
        "schema_version": "finding-impact-classifier-v1",
        "artifact_kind": "finding_impact_classification",
        "rule_id": RULE_ID,
        "finding_id": finding_id,
        "finding_text": finding_text,
        "classification": result["classification"],
        "blocked": result["blocked"],
        "outcome": "no-go" if result["blocked"] else "go",
        "files": [
            {
                "path": fr["path"],
                "categories": fr["categories"],
                "is_decision_file": fr["is_decision_file"],
                "added_count": fr["added_count"],
                "removed_count": fr["removed_count"],
                "evidence": fr["evidence"],
            }
            for fr in result["files"]
        ],
        "decision_files": result.get("decision_files", []),
        "constitution_matches": result.get("constitution_matches", []),
        "violations": result["violations"],
        "summary": result["summary"],
    }
    return json.dumps(payload, indent=2) + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Classify the impact of a code-change finding before applying it. "
            "Returns ALLOWED (exit 0) or BLOCKED (exit 2) with T.E.A.C.H. diagnostics."
        )
    )
    parser.add_argument(
        "--diff", required=True,
        help="Path to a unified diff/patch file, or '-' to read from stdin.",
    )
    parser.add_argument(
        "--constitution",
        help="Optional path to the Constitution directory for cross-referencing.",
    )
    parser.add_argument(
        "--finding-id",
        help="Optional finding identifier for traceability.",
    )
    parser.add_argument(
        "--finding-text",
        help="Optional finding description text.",
    )
    parser.add_argument(
        "--report-json",
        help="Optional path to write the classification result as JSON.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    # Read diff
    if args.diff == "-":
        diff_text = sys.stdin.read()
    else:
        diff_path = Path(args.diff).resolve()
        if not diff_path.exists():
            print(f"Error: diff file not found: {diff_path}", file=sys.stderr)
            return 1
        diff_text = diff_path.read_text(encoding="utf-8", errors="replace")

    constitution_dir = Path(args.constitution).resolve() if args.constitution else None

    result = classify_finding(diff_text, constitution_dir)

    # Text output to stdout
    print(render_text(result, args.finding_id, args.finding_text), end="")

    # Optional JSON report
    if args.report_json:
        report_path = Path(args.report_json).resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(
            render_json(result, args.finding_id, args.finding_text),
            encoding="utf-8",
        )

    # Exit code: 0 = ALLOWED, 2 = BLOCKED
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
