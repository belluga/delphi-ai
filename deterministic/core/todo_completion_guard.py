#!/usr/bin/env python3
"""Deterministic completion guard for tactical TODOs (Level 0 Scrutiny Edition).

Supports two modes:
  --todo <path>         Validate a single TODO file.
  --all-completed       Scan ``todos/active/`` and validate every TODO.
                        Exits 0 only if ALL active TODOs pass.
"""

from __future__ import annotations
import argparse
import json
import re
import sys
import traceback
from pathlib import Path

# Shared infrastructure
sys.path.insert(0, str(Path(__file__).resolve().parent))

try:
    from pattern_resolver import validate_refs as _validate_pattern_refs, _find_delphi_root
    _PATTERN_RESOLVER_AVAILABLE = True
except ImportError:
    _PATTERN_RESOLVER_AVAILABLE = False

# Constants
RULE_ID = "paced.todo.completion-guard"
SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}


def _load_namespace_gates() -> dict:
    """Load mandatory gates from external JSON config (Single Source of Truth)."""
    config_path = Path(__file__).resolve().parent / "namespace_gates.json"
    if config_path.exists():
        data = json.loads(config_path.read_text(encoding="utf-8"))
        return {k: v for k, v in data.items() if not k.startswith("_")}
    # Fallback if config file is missing (fail-safe)
    return {"core": ["logic", "critique"]}


NAMESPACE_MANDATORY_GATES = _load_namespace_gates()

CHECKBOX_RE = re.compile(r"^\s*-\s+\[([ xX])\]\s+(.+)$")


def parse_checkboxes(lines: list[str], section_heading: str) -> list[dict]:
    in_section = False
    items: list[dict] = []
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if stripped.startswith("## ") or stripped.startswith("# "):
            if stripped.startswith(section_heading):
                in_section = True
                continue
            elif in_section:
                break
        if not in_section:
            continue
        match = CHECKBOX_RE.match(line)
        if match:
            marker = match.group(1)
            text = match.group(2).strip()
            items.append({"text": text, "checked": marker.lower() == "x", "line_number": idx})
    return items


def find_waiver_section(lines: list[str]) -> list[str]:
    in_section = False
    content: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("## ") or stripped.startswith("# "):
            if "waiver" in stripped.lower():
                in_section = True
                continue
            elif in_section:
                break
        if in_section and stripped:
            content.append(stripped)
    return content


def validate_completion(todo_path: Path) -> dict:
    try:
        import todo_validation_bundle_export as exporter
    except ImportError as e:
        return {
            "status": "blocked",
            "violations": [{
                "section": "System Integrity",
                "code": "DEPENDENCY-FAILURE",
                "message": f"Critical dependency failure: {str(e)}",
                "resolution_instruction": "Check if PACED infrastructure is properly linked via verify_context.sh."
            }]
        }

    try:
        lines = todo_path.read_text(encoding="utf-8").splitlines()
        bundle = exporter.build_bundle(todo_path)
        violations: list[dict] = []

        # 1. DoD
        dod_items = parse_checkboxes(lines, "## Definition of Done")
        unchecked_dod = [i for i in dod_items if not i["checked"]]
        if unchecked_dod:
            waiver_lines = find_waiver_section(lines)
            unwaived = [i for i in unchecked_dod if not any(i["text"][:40].lower() in w.lower() for w in waiver_lines)]
            if unwaived:
                violations.append({
                    "section": "Definition of Done",
                    "code": "DOD-INCOMPLETE",
                    "message": f"{len(unwaived)} unchecked item(s) without waiver.",
                    "resolution_instruction": "Mark as done or add a ## Waivers section."
                })

        # 2. Validation Steps
        vs_items = parse_checkboxes(lines, "## Validation Steps")
        unchecked_vs = [i for i in vs_items if not i["checked"]]
        if unchecked_vs:
            violations.append({
                "section": "Validation Steps",
                "code": "VS-INCOMPLETE",
                "message": f"{len(unchecked_vs)} unchecked validation step(s).",
                "resolution_instruction": "Run the steps or document why they are not applicable."
            })

        # 3. Delivery Stage
        stage = bundle["delivery_status"]["stage"]
        if stage != "Production-Ready":
            violations.append({
                "section": "Delivery Status",
                "code": "STAGE-NOT-READY",
                "message": f"Stage is '{stage}', expected 'Production-Ready'.",
                "resolution_instruction": "Update stage after verification."
            })

        # 4. Mandatory Gates per Namespace
        namespace = bundle.get("namespace", "core")
        mandatory = NAMESPACE_MANDATORY_GATES.get(namespace, NAMESPACE_MANDATORY_GATES.get("core", []))
        for g_id in mandatory:
            if g_id not in bundle["gates"]:
                violations.append({
                    "section": f"Gate: {g_id}",
                    "code": f"GATE-{g_id.upper()}-MISSING",
                    "message": f"Mandatory gate '{g_id}' for namespace '{namespace}' is missing.",
                    "resolution_instruction": f"Add ## Gate: {g_id.capitalize()} to the TODO."
                })

        # 5. Ecosystem Reuse Analysis (Mandatory for Features)
        if bundle.get("artifact_type") == "tactical_execution_contract" or "feature" in todo_path.name.lower():
            todo_content = todo_path.read_text(encoding="utf-8").lower()
            if "ecosystem impact" not in todo_content and "reuse analysis" not in todo_content:
                violations.append({
                    "section": "Ecosystem Alignment",
                    "code": "REUSE-ANALYSIS-MISSING",
                    "message": "Meaningful features must include an 'Ecosystem Impact' or 'Reuse Analysis' section.",
                    "resolution_instruction": "Add a section to the TODO discussing if this should be a package or remain local."
                })

        # 6. Gate Statuses
        for g_id, gate in bundle["gates"].items():
            if gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
                violations.append({
                    "section": f"Gate: {g_id}",
                    "code": f"GATE-{g_id.upper()}-UNRESOLVED",
                    "message": f"Gate '{g_id}' status is '{gate['status']}'.",
                    "resolution_instruction": "Resolve gate or record a waiver."
                })

        # 7. Pattern Reference Validation
        if _PATTERN_RESOLVER_AVAILABLE:
            delphi_root = _find_delphi_root(todo_path.parent)
            if delphi_root:
                # Resolve project root (parent of delphi-ai)
                project_root = delphi_root.parent if delphi_root.name == "delphi-ai" else None
                pat_violations = _validate_pattern_refs(
                    todo_path, delphi_root, namespace, project_root
                )
                for pv in pat_violations:
                    violations.append({
                        "section": "Pattern References",
                        "code": f"PATTERN-{pv['type'].upper().replace('_', '-')}",
                        "message": pv["message"],
                        "resolution_instruction": pv["resolution_instruction"],
                    })

        return {"status": "go" if not violations else "blocked", "violations": violations}
    except Exception as e:
        return {
            "status": "blocked",
            "violations": [{
                "section": "Parser Integrity",
                "code": "PARSER-CRASH",
                "message": f"Parser crashed: {str(e)}",
                "resolution_instruction": "Fix the malformed TODO or the parser script. Traceback: " + traceback.format_exc()
            }]
        }


def discover_active_todos(start_path: Path) -> list[Path]:
    """Walk upward from start_path to find the project root (contains foundation_documentation/)
    and return all .md files under todos/active/."""
    search = start_path.resolve()
    for _ in range(10):
        candidate = search / "foundation_documentation" / "todos" / "active"
        if candidate.is_dir():
            return sorted(candidate.rglob("*.md"))
        if search.parent == search:
            break
        search = search.parent
    # Also try relative to CWD
    cwd_candidate = Path.cwd() / "foundation_documentation" / "todos" / "active"
    if cwd_candidate.is_dir():
        return sorted(cwd_candidate.rglob("*.md"))
    return []


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="PACED Deterministic Guard: Validate tactical TODO completion."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--todo", help="Path to a single TODO file to validate.")
    group.add_argument(
        "--all-completed",
        action="store_true",
        help="Scan todos/active/ and validate all TODOs. Exit 0 only if ALL pass.",
    )
    args = parser.parse_args()

    if args.todo:
        todo_path = Path(args.todo).resolve()
        result = validate_completion(todo_path)
        if result["status"] == "blocked":
            print(json.dumps(result, indent=2))
            sys.exit(2)
        print(f"GO: {todo_path.name} is valid.")
        sys.exit(0)

    # --all-completed mode
    script_dir = Path(__file__).resolve().parent
    todos = discover_active_todos(script_dir)
    if not todos:
        print("PACED Guard: No active TODOs found. Nothing to validate.")
        sys.exit(0)

    all_passed = True
    summary: list[dict] = []
    for todo_path in todos:
        result = validate_completion(todo_path)
        entry = {"todo": str(todo_path.name), "status": result["status"]}
        if result["status"] == "blocked":
            all_passed = False
            entry["violations"] = result["violations"]
        summary.append(entry)

    if all_passed:
        print(f"GO: All {len(todos)} active TODO(s) passed validation.")
        sys.exit(0)
    else:
        failed = [s for s in summary if s["status"] == "blocked"]
        print(json.dumps({"guard": RULE_ID, "total": len(todos), "failed": len(failed), "details": summary}, indent=2))
        sys.exit(2)
