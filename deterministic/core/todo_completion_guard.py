#!/usr/bin/env python3
"""Deterministic completion guard for tactical TODOs."""

from __future__ import annotations
import argparse
import json
import re
import sys
from pathlib import Path

# Shared infrastructure
sys.path.insert(0, str(Path(__file__).resolve().parent))
import todo_validation_bundle_export as exporter

# Constants
RULE_ID = "paced.todo.completion-guard"
SATISFYING_GATE_STATUSES = {"no_material_findings", "findings_integrated", "waived"}

NAMESPACE_MANDATORY_GATES = {
    "laravel": ["logic", "architecture", "security"],
    "flutter": ["logic", "ui_fidelity", "performance"],
    "core": ["logic", "critique"]
}

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
    lines = todo_path.read_text(encoding="utf-8").splitlines()
    bundle = exporter.build_bundle(todo_path)
    violations: list[dict] = []
    context: dict = {}

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
                "resolution": "Mark as done or add a ## Waivers section."
            })

    # 2. Validation Steps
    vs_items = parse_checkboxes(lines, "## Validation Steps")
    unchecked_vs = [i for i in vs_items if not i["checked"]]
    if unchecked_vs:
        violations.append({
            "section": "Validation Steps",
            "code": "VS-INCOMPLETE",
            "message": f"{len(unchecked_vs)} unchecked validation step(s).",
            "resolution": "Run the steps or document why they are not applicable."
        })

    # 3. Delivery Stage
    stage = bundle["delivery_status"]["stage"]
    if stage != "Production-Ready":
        violations.append({
            "section": "Delivery Status",
            "code": "STAGE-NOT-READY",
            "message": f"Stage is '{stage}', expected 'Production-Ready'.",
            "resolution": "Update stage after verification."
        })

    # 4. Mandatory Gates per Namespace
    namespace = bundle.get("namespace", "core")
    mandatory = NAMESPACE_MANDATORY_GATES.get(namespace, NAMESPACE_MANDATORY_GATES["core"])
    for g_id in mandatory:
        if g_id not in bundle["gates"]:
            violations.append({
                "section": f"Gate: {g_id}",
                "code": f"GATE-{g_id.upper()}-MISSING",
                "message": f"Mandatory gate '{g_id}' for namespace '{namespace}' is missing.",
                "resolution": f"Add ## Gate: {g_id.capitalize()} to the TODO."
            })

    # 5. Gate Statuses
    for g_id, gate in bundle["gates"].items():
        if gate["decision"] == "required" and gate["status"] not in SATISFYING_GATE_STATUSES:
            violations.append({
                "section": f"Gate: {g_id}",
                "code": f"GATE-{g_id.upper()}-UNRESOLVED",
                "message": f"Gate '{g_id}' status is '{gate['status']}'.",
                "resolution": "Resolve gate or record a waiver."
            })

    return {"status": "go" if not violations else "blocked", "violations": violations}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--todo", required=True, help="Path to TODO file")
    args = parser.parse_args()
    
    result = validate_completion(Path(args.todo))
    if result["status"] == "blocked":
        print(json.dumps(result, indent=2))
        sys.exit(2)
    print("GO: TODO is valid.")
    sys.exit(0)
