#!/usr/bin/env python3
"""Deterministic completion guard for orchestration execution plans.

This guard validates that a derived orchestration plan is structurally complete
enough to be presented for approval or used for execution. It does not validate
post-execution delivery evidence; use orchestration_delivery_guard.py for that.
It emits a TEACH runtime response and exits with:

  0  GO: the plan is complete for the selected mode.
  2  NO-GO: deterministic blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


RULE_ID = "paced.orchestration-plan.completion"
ALLOWED_STATUSES = {"Draft", "Pending Approval", "Approved", "Superseded", "Canceled"}
READY_STATUSES = {"Pending Approval", "Approved"}
REQUIRED_SECTIONS = (
    "Artifact Identity",
    "Authority Boundary",
    "Governing TODO Set",
    "Acceptance Traceability Matrix",
    "Spec Deviation Ledger",
    "Dependency Graph",
    "Orchestration Topology",
    "Workstreams",
    "Execution Ownership Ledger",
    "Execution Waves",
    "Consolidated Validation Matrix",
    "Risk / Conflict Controls",
    "Approval Request",
)

TRACEABILITY_COLUMNS = 8
TRACEABILITY_ALLOWED_STATUSES = {"planned", "passed", "blocked", "waived"}
SPEC_DEVIATION_ALLOWED_STATUSES = {"approved", "n/a"}
TODO_REQUIREMENT_SECTIONS = ("Definition of Done", "Validation Steps")
DECISION_SECTIONS = ("Decisions", "Decision Baseline")
UI_RUNTIME_MARKER_TERMS = (
    "fab",
    "floatingactionbutton",
    "tab",
    "tabs",
    "datas",
    "programacao",
    "programação",
    "sobre",
    "route",
    "rota",
    "navigation",
    "navegacao",
    "navegação",
    "web",
    "browser",
    "navegador",
    "device",
    "dispositivo",
    "map",
    "mapa",
    "admin",
    "public",
    "screen",
    "tela",
    "detail",
    "detalhe",
    "list",
    "lista",
    "card",
    "highlight",
    "highlighted",
    "destacado",
    "selected",
    "selecionado",
    "sticky",
    "scroll",
    "click",
    "tap",
    "loading",
    "carregamento",
    "empty",
    "vazio",
    "error",
    "erro",
)

SPEC_MARKERS = (
    ("FAB", ("fab", "floatingactionbutton"), True),
    ("FloatingActionButton", ("floatingactionbutton",), True),
    ("web/browser", ("web", "browser", "navegador"), True),
    ("navigation", ("navigation", "navegacao", "navegação", "route", "rota"), True),
    ("tab", ("tab", "tabs"), True),
    ("Datas", ("datas",), True),
    ("Programacao", ("programacao", "programação"), True),
    ("highlight", ("highlight", "highlighted", "destacado"), True),
    ("map", ("map", "mapa"), True),
    ("loading", ("loading", "carregamento"), True),
    ("empty", ("empty", "vazio"), True),
    ("error", ("error", "erro"), True),
    ("endpoint", ("endpoint", "endpoints"), False),
    ("schema", ("schema", "schemas"), False),
    ("migration", ("migration", "migracao", "migração"), False),
)

HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FIELD_RE_TEMPLATE = r"^\s*-\s+\*\*%s:\*\*\s*(.+?)\s*$"
TABLE_ROW_RE = re.compile(r"^\s*\|(.+)\|\s*$")
PLACEHOLDER_RE = re.compile(r"<[^>]+>")


def strip_markup(value: str) -> str:
    value = value.strip()
    if value.startswith("`") and value.endswith("`") and len(value) >= 2:
        value = value[1:-1]
    return value.strip()


def is_placeholder(value: str) -> bool:
    stripped = strip_markup(value)
    lowered = stripped.lower()
    return (
        not stripped
        or bool(PLACEHOLDER_RE.search(stripped))
        or lowered in {"todo", "tbd", "unknown", "pending", "fixme"}
    )


def extract_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines:
        match = HEADING_RE.match(line)
        if match and match.group(1) == "##":
            current = match.group(2).strip()
            sections.setdefault(current, [])
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def extract_field(lines: list[str], label: str) -> str | None:
    pattern = re.compile(FIELD_RE_TEMPLATE % re.escape(label))
    for line in lines:
        match = pattern.match(line)
        if match:
            return strip_markup(match.group(1))
    return None


def section_has_content(lines: list[str]) -> bool:
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("| ---"):
            continue
        if stripped.startswith("<!--"):
            continue
        if not is_placeholder(stripped):
            return True
    return False


def table_rows(lines: list[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in lines:
        match = TABLE_ROW_RE.match(line)
        if not match:
            continue
        cells = [strip_markup(cell) for cell in match.group(1).split("|")]
        if not cells:
            continue
        joined = " ".join(cells).strip()
        if not joined:
            continue
        if set(joined.replace(" ", "")) <= {"-", ":"}:
            continue
        rows.append(cells)
    if len(rows) <= 1:
        return []
    return rows[1:]


def row_text(row: list[str]) -> str:
    return " | ".join(row)


def normalize_text(value: str) -> str:
    value = re.sub(r"`([^`]+)`", r"\1", value)
    value = re.sub(r"\[[ xX]\]", "", value)
    value = re.sub(r"[*_#>|]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip().lower()


def canonical_heading(value: str) -> str:
    return normalize_text(value).rstrip(":")


def marker_present(text: str, aliases: tuple[str, ...]) -> bool:
    lowered = normalize_text(text)
    for alias in aliases:
        normalized_alias = normalize_text(alias)
        if not normalized_alias:
            continue
        if re.search(rf"(?<![a-z0-9]){re.escape(normalized_alias)}(?![a-z0-9])", lowered):
            return True
    return False


def owner_names_orchestrator(owner: str) -> bool:
    lowered = owner.lower()
    return "orchestrator" in lowered or "orquestrador" in lowered


def orchestrator_scope_allowed(scope: str) -> bool:
    lowered = scope.lower()
    if any(
        token in lowered
        for token in (
            "feature",
            "todo implementation",
            "implementacao",
            "implementação",
            "business",
            "domain",
            "backend",
            "primary",
            "slice implementation",
            "local implementation",
        )
    ):
        return False
    return any(
        token in lowered
        for token in (
            "none",
            "n/a",
            "merge-conflict",
            "merge conflict",
            "reconciliation",
            "reconcile",
            "integration glue",
            "minimal integration",
        )
    )


def build_violation(code: str, message: str, resolution: str, section: str) -> dict[str, str]:
    return {
        "code": code,
        "message": message,
        "resolution": resolution,
        "section": section,
    }


def find_project_root(plan_path: Path) -> Path | None:
    current = plan_path.resolve()
    for parent in [current.parent, *current.parents]:
        if parent.name == "foundation_documentation":
            return parent.parent
        if (parent / "foundation_documentation").is_dir():
            return parent
    return None


def resolve_todo_path(plan_path: Path, raw_value: str) -> Path | None:
    value = strip_markup(raw_value)
    match = re.search(r"(foundation_documentation/[^\s`|]+\.md)", value)
    if not match:
        return None
    rel = Path(match.group(1))
    root = find_project_root(plan_path)
    if root is None:
        return None
    return root / rel


def extract_checkbox_items_by_section(lines: list[str], section_names: tuple[str, ...]) -> list[dict[str, str]]:
    wanted = {canonical_heading(name): name for name in section_names}
    current: str | None = None
    items: list[dict[str, str]] = []
    for line in lines:
        heading = HEADING_RE.match(line)
        if heading:
            title = canonical_heading(heading.group(2))
            current = wanted.get(title)
            continue
        if current is None:
            continue
        match = re.match(r"^\s*[-*]\s+\[[ xX]\]\s+(.+?)\s*$", line)
        if not match:
            continue
        text = strip_markup(match.group(1))
        if text:
            items.append({"section": current, "text": text})
    return items


def extract_marked_decisions(lines: list[str]) -> list[dict[str, str]]:
    decisions = extract_checkbox_items_by_section(lines, DECISION_SECTIONS)
    marked: list[dict[str, str]] = []
    for item in decisions:
        text = item["text"]
        if any(marker_present(text, aliases) for _, aliases, _ in SPEC_MARKERS):
            marked.append({"section": item["section"], "text": text})
    return marked


def collect_todo_paths(plan_path: Path, governing_rows: list[list[str]]) -> tuple[list[Path], list[dict[str, str]]]:
    paths: list[Path] = []
    violations: list[dict[str, str]] = []
    for row in governing_rows:
        todo_path = next((resolve_todo_path(plan_path, cell) for cell in row if ".md" in cell), None)
        if todo_path is None:
            continue
        if todo_path.is_file():
            paths.append(todo_path)
    return paths, violations


def collect_todo_requirements(todo_paths: list[Path]) -> tuple[list[dict[str, str]], str]:
    requirements: list[dict[str, str]] = []
    full_text_parts: list[str] = []
    for todo_path in todo_paths:
        todo_text = todo_path.read_text(encoding="utf-8")
        full_text_parts.append(todo_text)
        todo_lines = todo_text.splitlines()
        for index, item in enumerate(extract_checkbox_items_by_section(todo_lines, TODO_REQUIREMENT_SECTIONS), start=1):
            requirements.append(
                {
                    "id": f"{todo_path.name}:{item['section']}:{index}",
                    "todo": str(todo_path),
                    "section": item["section"],
                    "text": item["text"],
                }
            )
    return requirements, "\n".join(full_text_parts)


def traceability_contains_requirement(requirement: dict[str, str], traceability_rows: list[list[str]]) -> bool:
    requirement_text = normalize_text(requirement["text"])
    if not requirement_text:
        return True
    for row in traceability_rows:
        normalized_row = normalize_text(row_text(row))
        if requirement_text in normalized_row:
            return True
    return False


def traceability_or_deviation_contains_marker(
    marker_aliases: tuple[str, ...],
    traceability_text: str,
    deviation_text: str,
) -> bool:
    return marker_present(traceability_text, marker_aliases) or marker_present(deviation_text, marker_aliases)


def row_has_runtime_ui_signal(row: list[str]) -> bool:
    return any(marker_present(row_text(row), (term,)) for term in UI_RUNTIME_MARKER_TERMS)


def validate_plan(plan_path: Path, require_approved: bool = False) -> dict[str, Any]:
    violations: list[dict[str, str]] = []
    context: dict[str, Any] = {
        "plan_path": str(plan_path),
        "status": "unknown",
        "todo_count": 0,
        "todo_requirement_count": 0,
        "traceability_row_count": 0,
        "spec_marker_count": 0,
        "workstream_count": 0,
        "wave_count": 0,
        "validation_row_count": 0,
        "mode": "execution-ready" if require_approved else "approval-ready",
    }

    if not plan_path.is_file():
        return {
            "blocked": True,
            "violations": [
                build_violation(
                    "PLAN-NOT-FOUND",
                    f"Plan file does not exist: {plan_path}",
                    "Create the orchestration execution plan under foundation_documentation/artifacts/execution-plans/ and rerun this guard.",
                    "Plan File",
                )
            ],
            "context": context,
        }

    lines = plan_path.read_text(encoding="utf-8").splitlines()
    text = "\n".join(lines)
    lowered = text.lower()
    sections = extract_sections(lines)

    for section in REQUIRED_SECTIONS:
        if section not in sections:
            violations.append(
                build_violation(
                    "SECTION-MISSING",
                    f"Required section is missing: {section}",
                    f"Add `## {section}` with concrete, non-placeholder content.",
                    section,
                )
            )
        elif not section_has_content(sections[section]):
            violations.append(
                build_violation(
                    "SECTION-EMPTY",
                    f"Required section has no concrete content: {section}",
                    f"Fill `## {section}` with concrete orchestration decisions.",
                    section,
                )
            )

    artifact_lines = sections.get("Artifact Identity", [])
    artifact_type = extract_field(artifact_lines, "Artifact type")
    status = extract_field(artifact_lines, "Status")
    created = extract_field(artifact_lines, "Created")
    workflow = extract_field(artifact_lines, "Governing workflow / skill")
    approval_token = extract_field(artifact_lines, "Approval token required before execution")

    if artifact_type != "orchestration_execution_plan":
        violations.append(
            build_violation(
                "ARTIFACT-TYPE-INVALID",
                f"Artifact type is `{artifact_type or 'missing'}`, expected `orchestration_execution_plan`.",
                "Set `- **Artifact type:** `orchestration_execution_plan``.",
                "Artifact Identity",
            )
        )

    if status is None or status not in ALLOWED_STATUSES:
        violations.append(
            build_violation(
                "STATUS-INVALID",
                f"Status is `{status or 'missing'}`, expected one of {sorted(ALLOWED_STATUSES)}.",
                "Set a valid status in `## Artifact Identity`.",
                "Artifact Identity",
            )
        )
    else:
        context["status"] = status
        if status not in READY_STATUSES:
            violations.append(
                build_violation(
                    "STATUS-NOT-READY",
                    f"Status `{status}` is not ready for approval/execution.",
                    "Use `Pending Approval` before asking for APROVADO, or `Approved` after approval is recorded.",
                    "Artifact Identity",
                )
            )
        if require_approved and status != "Approved":
            violations.append(
                build_violation(
                    "STATUS-NOT-APPROVED",
                    f"Execution mode requires `Approved`, found `{status}`.",
                    "Record the approval in the plan status or rerun without `--require-approved` while only checking approval readiness.",
                    "Artifact Identity",
                )
            )

    if created is None or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", created):
        violations.append(
            build_violation(
                "CREATED-DATE-INVALID",
                f"Created date is `{created or 'missing'}`, expected `YYYY-MM-DD`.",
                "Set `- **Created:** `YYYY-MM-DD``.",
                "Artifact Identity",
            )
        )

    if workflow is None or "subagent-worktree-reconciliation-method.md" not in workflow:
        violations.append(
            build_violation(
                "WORKFLOW-REFERENCE-MISSING",
                "The governing orchestration workflow reference is missing or unexpected.",
                "Reference `delphi-ai/workflows/docker/subagent-worktree-reconciliation-method.md`.",
                "Artifact Identity",
            )
        )

    if approval_token != "APROVADO":
        violations.append(
            build_violation(
                "APPROVAL-TOKEN-MISSING",
                "The required approval token is missing or not `APROVADO`.",
                "Set `- **Approval token required before execution:** `APROVADO``.",
                "Artifact Identity",
            )
        )

    governing_rows = table_rows(sections.get("Governing TODO Set", []))
    context["todo_count"] = len(governing_rows)
    todo_paths: list[Path] = []
    if not governing_rows:
        violations.append(
            build_violation(
                "TODO-SET-MISSING",
                "No governing TODO rows were found.",
                "Add at least one concrete TODO row with a valid markdown path.",
                "Governing TODO Set",
            )
        )
    for row in governing_rows:
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "TODO-ROW-PLACEHOLDER",
                    f"Governing TODO row contains placeholder content: {' | '.join(row)}",
                    "Replace all placeholder cells with concrete TODO path, role, and start eligibility.",
                    "Governing TODO Set",
                )
            )
        todo_path = next((resolve_todo_path(plan_path, cell) for cell in row if ".md" in cell), None)
        if todo_path is None:
            violations.append(
                build_violation(
                    "TODO-PATH-MISSING",
                    f"Governing TODO row does not include a resolvable markdown path: {' | '.join(row)}",
                    "Use paths like `foundation_documentation/todos/active/<lane>/<todo>.md`.",
                    "Governing TODO Set",
                )
            )
        elif not todo_path.is_file():
            violations.append(
                build_violation(
                    "TODO-PATH-NOT-FOUND",
                    f"Governing TODO path does not exist: {todo_path}",
                    "Fix the TODO path or create/update the governing TODO before delivering the orchestration plan.",
                    "Governing TODO Set",
                )
            )
        else:
            todo_paths.append(todo_path)

    traceability_rows = table_rows(sections.get("Acceptance Traceability Matrix", []))
    context["traceability_row_count"] = len(traceability_rows)
    if not traceability_rows:
        violations.append(
            build_violation(
                "TRACEABILITY-MATRIX-MISSING",
                "No acceptance traceability rows were found.",
                "Add one traceability row for every governing TODO DoD item, validation step, and literal required marker before approval.",
                "Acceptance Traceability Matrix",
            )
        )
    for row in traceability_rows:
        if len(row) < TRACEABILITY_COLUMNS:
            violations.append(
                build_violation(
                    "TRACEABILITY-ROW-INCOMPLETE",
                    f"Traceability row has fewer than {TRACEABILITY_COLUMNS} cells: {row_text(row)}",
                    "Use columns: Requirement ID, Source TODO / Criterion, Implementation Owner, Required Artifact / UI Marker, Implementation Evidence, Test Evidence, Runtime / Web Evidence, Status.",
                    "Acceptance Traceability Matrix",
                )
            )
            continue
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "TRACEABILITY-ROW-PLACEHOLDER",
                    f"Traceability row contains placeholder content: {row_text(row)}",
                    "Replace placeholders with concrete owner, required artifact/marker, planned evidence, and status.",
                    "Acceptance Traceability Matrix",
                )
            )
        owner = row[2]
        if owner_names_orchestrator(owner):
            violations.append(
                build_violation(
                    "TRACEABILITY-ORCHESTRATOR-OWNER",
                    f"Traceability implementation owner is orchestrator for row: {row_text(row)}",
                    "Assign traceability implementation ownership to a worker/subagent. The orchestrator may own only reconciliation and validation evidence collection.",
                    "Acceptance Traceability Matrix",
                )
            )
        status = row[7].strip().lower()
        if status not in TRACEABILITY_ALLOWED_STATUSES:
            violations.append(
                build_violation(
                    "TRACEABILITY-STATUS-INVALID",
                    f"Traceability row status is `{row[7]}`; expected one of {sorted(TRACEABILITY_ALLOWED_STATUSES)}.",
                    "Set traceability status to `planned` before execution, or `passed|blocked|waived` after execution.",
                    "Acceptance Traceability Matrix",
                )
            )

    spec_rows = table_rows(sections.get("Spec Deviation Ledger", []))
    deviation_text = "\n".join(row_text(row) for row in spec_rows)
    for row in spec_rows:
        if len(row) < 5:
            violations.append(
                build_violation(
                    "SPEC-DEVIATION-ROW-INCOMPLETE",
                    f"Spec deviation row has fewer than 5 cells: {row_text(row)}",
                    "Use columns: Source TODO / Criterion, Original Requirement, Proposed Deviation, Approval Evidence, Status.",
                    "Spec Deviation Ledger",
                )
            )
            continue
        normalized_row = normalize_text(row_text(row))
        if normalized_row.startswith("none no spec deviations approved"):
            continue
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "SPEC-DEVIATION-PLACEHOLDER",
                    f"Spec deviation row contains placeholder content: {row_text(row)}",
                    "Replace placeholders with concrete deviation details and approval evidence, or use the `none` row when no deviations exist.",
                    "Spec Deviation Ledger",
                )
            )
        status = row[4].strip().lower()
        if status not in SPEC_DEVIATION_ALLOWED_STATUSES:
            violations.append(
                build_violation(
                    "SPEC-DEVIATION-NOT-APPROVED",
                    f"Spec deviation status is `{row[4]}` for row: {row_text(row)}",
                    "Do not proceed with substituted artifacts or behavior until the deviation is explicitly approved, or implement the governing TODO exactly.",
                    "Spec Deviation Ledger",
                )
            )

    todo_requirements, todo_text = collect_todo_requirements(todo_paths)
    context["todo_requirement_count"] = len(todo_requirements)
    for requirement in todo_requirements:
        if not traceability_contains_requirement(requirement, traceability_rows):
            violations.append(
                build_violation(
                    "TODO-REQUIREMENT-UNTRACED",
                    f"{requirement['section']} item is not represented in the Acceptance Traceability Matrix: {requirement['text']}",
                    "Add a traceability row that quotes this governing TODO criterion exactly and assigns it to a worker with planned implementation/test/runtime evidence.",
                    "Acceptance Traceability Matrix",
                )
            )

    traceability_text = "\n".join(row_text(row) for row in traceability_rows)
    validation_rows_for_runtime = table_rows(sections.get("Consolidated Validation Matrix", []))
    spec_marker_count = 0
    for marker_label, aliases, runtime_required in SPEC_MARKERS:
        if not marker_present(todo_text, aliases):
            continue
        spec_marker_count += 1
        if not traceability_or_deviation_contains_marker(aliases, traceability_text, deviation_text):
            violations.append(
                build_violation(
                    "SPEC-MARKER-UNTRACED",
                    f"Governing TODOs mention `{marker_label}` but traceability does not preserve it and no approved spec deviation covers it.",
                    "Add the literal marker to `Required Artifact / UI Marker` or record an approved Spec Deviation Ledger row before execution.",
                    "Acceptance Traceability Matrix",
                )
            )
        if runtime_required and not any(row_has_runtime_ui_signal(row) for row in validation_rows_for_runtime):
            violations.append(
                build_violation(
                    "UI-RUNTIME-VALIDATION-MISSING",
                    f"Governing TODOs include UI/runtime marker `{marker_label}`, but the consolidated validation matrix has no web/browser/device/navigation/UI runtime evidence row.",
                    "Add consolidated validation that exercises the affected UI/navigation/runtime behavior against the reconciliation branch, or record an explicit blocker/approved waiver.",
                    "Consolidated Validation Matrix",
                )
            )
    context["spec_marker_count"] = spec_marker_count

    workstream_rows = table_rows(sections.get("Workstreams", []))
    context["workstream_count"] = len(workstream_rows)
    if not workstream_rows:
        violations.append(
            build_violation(
                "WORKSTREAMS-MISSING",
                "No workstream rows were found.",
                "Add at least one workstream row with ownership, dependencies, checkpoint, and worker-local validation.",
                "Workstreams",
            )
        )
    for row in workstream_rows:
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "WORKSTREAM-ROW-PLACEHOLDER",
                    f"Workstream row contains placeholder content: {' | '.join(row)}",
                    "Replace placeholders with concrete ownership/dependency/checkpoint/validation details.",
                    "Workstreams",
                )
            )

    ownership_rows = table_rows(sections.get("Execution Ownership Ledger", []))
    context["ownership_row_count"] = len(ownership_rows)
    if not ownership_rows:
        violations.append(
            build_violation(
                "OWNERSHIP-LEDGER-MISSING",
                "No execution ownership rows were found.",
                "Add at least one ownership row assigning each implementation workstream to a worker/subagent and limiting orchestrator code scope.",
                "Execution Ownership Ledger",
            )
        )
    for row in ownership_rows:
        if len(row) < 5:
            violations.append(
                build_violation(
                    "OWNERSHIP-ROW-INCOMPLETE",
                    f"Ownership row has fewer than 5 cells: {row_text(row)}",
                    "Use columns: Workstream, Implementation Owner, Orchestrator Code Scope, Worker Checkpoint Evidence, Reconciliation Evidence.",
                    "Execution Ownership Ledger",
                )
            )
            continue
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "OWNERSHIP-ROW-PLACEHOLDER",
                    f"Ownership row contains placeholder content: {row_text(row)}",
                    "Replace placeholders with concrete worker ownership, orchestrator scope, worker checkpoint evidence, and reconciliation evidence.",
                    "Execution Ownership Ledger",
                )
            )
        owner = row[1]
        scope = row[2]
        if owner_names_orchestrator(owner):
            violations.append(
                build_violation(
                    "ORCHESTRATOR-IMPLEMENTATION-OWNER",
                    f"Implementation owner is orchestrator for row: {row_text(row)}",
                    "Assign implementation ownership to a worker/subagent. The orchestrator may own only reconciliation, conflict resolution, validation orchestration, and evidence collection.",
                    "Execution Ownership Ledger",
                )
            )
        if not orchestrator_scope_allowed(scope):
            violations.append(
                build_violation(
                    "ORCHESTRATOR-SCOPE-TOO-BROAD",
                    f"Orchestrator code scope is not limited to reconciliation/merge-conflict work: {scope}",
                    "Set orchestrator code scope to `none`, `merge-conflict-only`, or `reconciliation-only`; do not let the orchestrator implement TODO slices.",
                    "Execution Ownership Ledger",
                )
            )

    validation_rows = table_rows(sections.get("Consolidated Validation Matrix", []))
    context["validation_row_count"] = len(validation_rows)
    if not validation_rows:
        violations.append(
            build_violation(
                "VALIDATION-MATRIX-MISSING",
                "No consolidated validation rows were found.",
                "Add concrete validation evidence rows for the orchestrator reconciliation branch.",
                "Consolidated Validation Matrix",
            )
        )
    for row in validation_rows:
        if any(is_placeholder(cell) for cell in row):
            violations.append(
                build_violation(
                    "VALIDATION-ROW-PLACEHOLDER",
                    f"Validation row contains placeholder content: {' | '.join(row)}",
                    "Replace placeholders with concrete required evidence, runtime target, and owner.",
                    "Consolidated Validation Matrix",
                )
            )

    wave_count = len(re.findall(r"^###\s+Wave\s+\d+\b", text, flags=re.MULTILINE))
    context["wave_count"] = wave_count
    if wave_count < 2:
        violations.append(
            build_violation(
                "WAVES-INCOMPLETE",
                f"Only {wave_count} execution wave(s) found.",
                "Define at least Wave 0 plus one execution wave.",
                "Execution Waves",
            )
        )

    if "reconciliation branch" not in lowered:
        violations.append(
            build_violation(
                "RECONCILIATION-BRANCH-MISSING",
                "The plan does not name an orchestrator reconciliation branch policy.",
                "Add an orchestrator reconciliation branch under `## Orchestration Topology`.",
                "Orchestration Topology",
            )
        )

    if "principal checkout" not in lowered:
        violations.append(
            build_violation(
                "PRINCIPAL-CHECKOUT-POLICY-MISSING",
                "The plan does not define principal checkout/runtime validation policy.",
                "State how browser/device/runtime validation resolves to the reconciliation branch.",
                "Orchestration Topology",
            )
        )

    autonomy_terms = ("autonom" in lowered) and ("feedback" in lowered)
    stop_terms = [
        "mandatory user decision" in lowered or "decisao obrigatoria" in lowered or "decisão obrigatória" in lowered,
        "scope change" in lowered or "mudança de escopo" in lowered,
        "todo conflict" in lowered or "conflict with a governing todo" in lowered or "conflito com" in lowered,
        "blocker" in lowered,
        "waiver" in lowered,
    ]
    if not autonomy_terms or sum(1 for item in stop_terms if item) < 4:
        violations.append(
            build_violation(
                "AUTONOMY-RULE-INCOMPLETE",
                "The plan does not clearly state that waves are internal controls and not routine feedback gates.",
                "State that the orchestrator advances autonomously between waves and stops only for mandatory decision, scope change, TODO conflict, blocker, or validation waiver.",
                "Execution Waves",
            )
        )

    approval_text = "\n".join(sections.get("Approval Request", []))
    if "APROVADO" not in approval_text:
        violations.append(
            build_violation(
                "APPROVAL-REQUEST-MISSING",
                "Approval Request does not ask for `APROVADO`.",
                "Add an explicit approval request using the token `APROVADO`.",
                "Approval Request",
            )
        )
    if "Execution authorized by approval" not in approval_text:
        violations.append(
            build_violation(
                "AUTHORIZED-SCOPE-MISSING",
                "Approval Request does not define what approval authorizes.",
                "Add `Execution authorized by approval` with exact orchestration authority.",
                "Approval Request",
            )
        )
    if "Execution not authorized by approval" not in approval_text:
        violations.append(
            build_violation(
                "EXCLUDED-SCOPE-MISSING",
                "Approval Request does not define what approval excludes.",
                "Add `Execution not authorized by approval` with explicit exclusions.",
                "Approval Request",
            )
        )

    if PLACEHOLDER_RE.search(text):
        violations.append(
            build_violation(
                "PLACEHOLDER-TEXT-REMAINS",
                "The plan still contains `<...>` placeholder text.",
                "Replace all template placeholders before delivering the plan.",
                "Plan Body",
            )
        )

    return {
        "blocked": bool(violations),
        "violations": violations,
        "context": context,
    }


def render_text(result: dict[str, Any]) -> str:
    blocked = bool(result["blocked"])
    context = result["context"]
    violations = result["violations"]
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append(f"status: {'blocked' if blocked else 'ready'}")
    lines.append(
        "enforcement: "
        + (
            "stop_before_orchestration_plan_approval_or_execution"
            if blocked
            else "allow_orchestration_plan_approval_or_execution"
        )
    )
    lines.append(f"rule_id: {RULE_ID}")
    lines.append("violation:")
    if not violations:
        lines.append("  - none")
    else:
        for violation in violations:
            lines.append(f"  - [{violation['code']}] {violation['section']}: {violation['message']}")
    lines.append("resolution_prompt:")
    if not violations:
        lines.append("  - The orchestration plan is structurally complete for the selected mode.")
        lines.append("  - Continue only within the governing TODO set and rerun this guard if plan authority, workstreams, waves, or validation scope changes.")
    else:
        seen: set[str] = set()
        for violation in violations:
            resolution = violation["resolution"]
            if resolution in seen:
                continue
            seen.add(resolution)
            lines.append(f"  - {resolution}")
    lines.append("context:")
    for key in (
        "plan_path",
        "mode",
        "status",
        "todo_count",
        "todo_requirement_count",
        "traceability_row_count",
        "spec_marker_count",
        "workstream_count",
        "ownership_row_count",
        "wave_count",
        "validation_row_count",
    ):
        lines.append(f"  {key}: {context.get(key)}")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines) + "\n"


def render_json(result: dict[str, Any]) -> str:
    payload = {
        "schema_version": "orchestration-plan-completion-guard-v1",
        "rule_id": RULE_ID,
        "status": "blocked" if result["blocked"] else "ready",
        "overall_outcome": "no-go" if result["blocked"] else "go",
        **result,
    }
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate orchestration execution plan completeness with TEACH output.")
    parser.add_argument("--plan", required=True, help="Path to the orchestration execution plan markdown file.")
    parser.add_argument(
        "--require-approved",
        action="store_true",
        help="Require Artifact Identity status to be `Approved` for execution-ready checks.",
    )
    parser.add_argument("--json-output", help="Optional path to write a JSON result artifact.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    plan_path = Path(args.plan).resolve()
    result = validate_plan(plan_path, require_approved=args.require_approved)
    text = render_text(result)
    print(text, end="")
    if args.json_output:
        Path(args.json_output).write_text(render_json(result), encoding="utf-8")
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        raise SystemExit(1)
