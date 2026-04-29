#!/usr/bin/env python3
"""Deterministic completion guard for tactical TODO delivery claims.

The guard is intentionally narrow: it validates whether a TODO that claims a
delivery milestone has concrete, row-level evidence for every release-relevant
checklist criterion. It emits a TEACH runtime response and
exits with:

  0  GO: no blocking completion-evidence issue was found.
  2  NO-GO: completion evidence blockers were found.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


RULE_ID = "paced.todo.completion-evidence"
DELIVERY_STAGE_MARKERS = (
    "Local-Implemented",
    "Local-Validated",
    "Local-Complete",
    "Lane-Promoted",
    "Production-Ready",
    "Completed",
    "Complete",
)
REQUIREMENT_SECTIONS = (
    ("Scope", "SCOPE"),
    ("Acceptance Criteria", "AC"),
    ("Definition of Done", "DOD"),
    ("Validation Steps", "VAL"),
)
ALLOWED_ROW_STATUSES = {"planned", "passed", "blocked", "waived", "n/a"}
DELIVERY_PASSING_STATUSES = {"passed"}
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FIELD_RE_TEMPLATE = r"^\s*-\s+\*\*%s:\*\*\s*(.+?)\s*$"
TABLE_ROW_RE = re.compile(r"^\s*\|(.+)\|\s*$")
PLACEHOLDER_RE = re.compile(r"<[^>]+>")

RUNTIME_REQUIRED_TERMS = (
    "web",
    "browser",
    "navegador",
    "device",
    "dispositivo",
    "navigation",
    "navegacao",
    "navegação",
    "route",
    "rota",
    "integration",
    "integracao",
    "integração",
    "e2e",
    "real-backend",
    "runtime",
    "build",
    "playwright",
    "emulator",
    "simulator",
    "scroll",
    "sticky",
)

VISIBLE_INTERACTIVE_TERMS = (
    "ui",
    "screen",
    "tela",
    "admin",
    "public",
    "publico",
    "público",
    "home",
    "discovery",
    "descoberta",
    "detail",
    "detalhe",
    "list",
    "lista",
    "card",
    "tab",
    "tabs",
    "datas",
    "programacao",
    "programação",
    "sobre",
    "fab",
    "floatingactionbutton",
    "button",
    "botao",
    "botão",
    "chip",
    "tag",
    "tags",
    "search",
    "pesquisa",
    "scroll",
    "sticky",
    "loading",
    "carregamento",
    "empty",
    "vazio",
    "error",
    "erro",
    "selected",
    "selecionado",
    "selecionada",
    "multi-select",
    "multiselect",
    "single-select",
    "form",
    "formulario",
    "formulário",
    "modal",
    "bottom sheet",
    "sheet",
)

USER_FLOW_CONTEXT_TERMS = (
    "admin",
    "public",
    "publico",
    "público",
    "user",
    "usuario",
    "usuário",
    "tenant",
    "screen",
    "tela",
    "form",
    "formulario",
    "formulário",
    "field",
    "campo",
    "list",
    "lista",
    "detail",
    "detalhe",
    "filter",
    "filtro",
    "search",
    "pesquisa",
    "route",
    "rota",
    "endpoint",
    "api",
    "request",
    "response",
    "payload",
    "validation",
    "validacao",
    "validação",
    "readback",
    "read-back",
    "projection",
    "projecao",
    "projeção",
    "read model",
    "read-model",
    "query",
    "settings",
    "configuracao",
    "configuração",
    "capability",
    "capabilities",
    "taxonomy",
    "taxonomia",
    "persisted state",
    "estado persistido",
)

USER_FLOW_DIRECT_TERMS = (
    "user flow",
    "fluxo de usuario",
    "fluxo de usuário",
    "journey",
    "jornada",
    "save flow",
    "fluxo de salvamento",
    "readback flow",
    "fluxo de readback",
    "422",
    "validation error",
    "erro de validacao",
    "erro de validação",
    "persisted selection",
    "selecao persistida",
    "seleção persistida",
    "backend-filtered",
    "real backend",
    "real-backend",
)

USER_FLOW_REFACTOR_TERMS = (
    "refactor",
    "refatora",
    "refatoracao",
    "refatoração",
    "field",
    "campo",
    "dto",
    "domain",
    "dominio",
    "domínio",
    "model",
    "modelo",
    "payload",
    "schema",
    "contract",
    "contrato",
    "projection",
    "projecao",
    "projeção",
    "read model",
    "read-model",
    "request",
    "response",
    "validation",
    "validacao",
    "validação",
    "query",
    "filter",
    "filtro",
    "settings",
    "configuracao",
    "configuração",
    "capability",
    "capabilities",
    "persisted state",
    "estado persistido",
)

NAVIGATION_COVERAGE_TERMS = (
    "integration_test",
    "integration test",
    "teste de integracao",
    "teste de integração",
    "navigation test",
    "navigation smoke",
    "navegacao",
    "navegação",
    "web_app_tests",
    "run_web_navigation_smoke",
    "run_web_navigation_smoke.sh",
    "playwright",
    "@readonly",
    "@mutation",
    "e2e",
    "browser",
    "navegador",
    "device",
    "dispositivo",
    "emulator",
    "simulator",
    "real-backend",
    "real backend",
    "runtime url",
    "flutter drive",
    "patrol",
    "maestro",
)

WEB_BROWSER_TERMS = (
    "web",
    "browser",
    "navegador",
    "chrome",
    "flutter web",
)

WEB_NAVIGATION_CONTEXT_TERMS = (
    "navigation",
    "navigation test",
    "navigation smoke",
    "navegacao",
    "navegação",
    "test",
    "teste",
    "suite",
    "smoke",
    "e2e",
    "route",
    "rota",
)

STRUCTURAL_TEST_REQUEST_TERMS = (
    "unit test",
    "unit tests",
    "package tests",
    "package/unit tests",
    "feature test",
    "feature tests",
    "feature/api tests",
    "api tests",
    "backend tests",
    "target adapter",
    "target adapter/read-model",
    "read-model tests",
    "read model tests",
    "laravel tests",
    "laravel feature",
    "parser tests",
    "domain tests",
    "dto tests",
    "repository tests",
    "controller tests",
    "widget tests",
    "golden tests",
    "migration tests",
    "backfill test",
    "analyzer",
    "focused analyzer",
    "testes unit",
    "testes de unidade",
    "testes de api",
    "testes api",
)

RUNTIME_VALIDATION_REQUEST_TERMS = (
    "integration",
    "integracao",
    "integração",
    "navigation",
    "navegacao",
    "navegação",
    "browser",
    "web",
    "device",
    "dispositivo",
    "adb",
    "playwright",
    "journey",
    "jornada",
)

PLAYWRIGHT_SPEC_TERMS = (
    "tools/flutter/web_app_tests",
    "web_app_tests",
    ".spec.ts",
    ".spec.js",
)

PLAYWRIGHT_RUNNER_TERMS = (
    "tools/flutter/run_web_navigation_smoke.sh",
    "run_web_navigation_smoke.sh",
    "run_web_navigation_smoke",
)

PLAYWRIGHT_MUTATION_TERMS = (
    "run_web_navigation_smoke.sh mutation",
    "run_web_navigation_smoke mutation",
    "nav_web_test_type=mutation",
    "@mutation",
    "playwright mutation",
    "mutation lane",
    "lane mutation",
)

WEB_BUILD_PROVENANCE_TERMS = (
    "scripts/build_web.sh",
    "flutter-app/scripts/build_web.sh",
    "build_web.sh",
    "../web-app",
    "web-app",
    "current web bundle",
    "refreshed bundle",
    "published bundle",
    "rebuilt bundle",
    "synced bundle",
    "build artifact",
    "build sha",
    "__web_build_sha__",
    "flutter build web",
)

CRUD_MUTATION_TERMS = (
    "crud",
    "create",
    "creates",
    "created",
    "creating",
    "edit",
    "edits",
    "edited",
    "editing",
    "update",
    "updates",
    "updated",
    "updating",
    "save",
    "saves",
    "saved",
    "saving",
    "delete",
    "deletes",
    "deleted",
    "deleting",
    "reorder",
    "reorders",
    "reordered",
    "reordering",
    "submit",
    "submits",
    "submitted",
    "submitting",
    "persist",
    "persists",
    "persisted",
    "persisting",
    "mutation",
    "mutacao",
    "mutação",
    "criar",
    "criacao",
    "criação",
    "editar",
    "edicao",
    "edição",
    "atualizar",
    "salvar",
    "excluir",
    "deletar",
    "remover",
    "reordenar",
    "submeter",
    "persistir",
)

MUTATION_EVIDENCE_TERMS = (
    "mutation",
    "mutacao",
    "mutação",
    "crud",
    "create",
    "edit",
    "update",
    "save",
    "delete",
    "reorder",
    "submit",
    "post",
    "put",
    "patch",
    "delete",
    "local mutation",
    "non-main",
    "excluding main",
    "excluindo main",
    "safe mutation",
    "backend mutation",
    "real mutation",
    "playwright mutation",
    "run_web_navigation_smoke.sh mutation",
    "run_web_navigation_smoke mutation",
    "NAV_WEB_TEST_TYPE=mutation",
    "@mutation",
    "mutation lane",
)

LITERAL_MARKERS = (
    ("FAB", ("fab", "floatingactionbutton")),
    ("FloatingActionButton", ("floatingactionbutton",)),
    ("endpoint", ("endpoint", "endpoints")),
    ("schema", ("schema", "schemas")),
    ("migration", ("migration", "migracao", "migração")),
    ("route", ("route", "rota")),
    ("web", ("web",)),
    ("browser", ("browser", "navegador")),
    ("device", ("device", "dispositivo")),
    ("Playwright", ("playwright",)),
)


def strip_markup(value: str) -> str:
    value = value.strip()
    if value.startswith("`") and value.endswith("`") and len(value) >= 2:
        value = value[1:-1]
    return value.strip()


def normalize_text(value: str) -> str:
    value = re.sub(r"`([^`]+)`", r"\1", value)
    value = re.sub(r"\[[ xX]\]", "", value)
    value = re.sub(r"[*_#>|]", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip().lower()


def marker_present(text: str, aliases: tuple[str, ...]) -> bool:
    normalized = normalize_text(text)
    for alias in aliases:
        normalized_alias = normalize_text(alias)
        if not normalized_alias:
            continue
        if re.search(rf"(?<![a-z0-9-]){re.escape(normalized_alias)}(?![a-z0-9-])", normalized):
            return True
    return False


def is_placeholder(value: str) -> bool:
    stripped = strip_markup(value)
    lowered = normalize_text(stripped)
    return (
        not stripped
        or bool(PLACEHOLDER_RE.search(stripped))
        or lowered in {"todo", "tbd", "unknown", "pending", "planned", "fixme"}
    )


def is_na(value: str) -> bool:
    return normalize_text(value) in {"n/a", "na", "none", "not applicable", "nao aplicavel", "não aplicável"}


def normalize_stage_label(value: str | None) -> str:
    value = strip_markup(value or "")
    value = re.sub(r"[^a-zA-Z0-9]+", "-", value)
    value = re.sub(r"-+", "-", value)
    return value.strip("-").lower()


def row_text(row: list[str]) -> str:
    return " | ".join(row)


def extract_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines:
        match = HEADING_RE.match(line)
        if match:
            current = match.group(2).strip()
            sections.setdefault(current, [])
            continue
        if current is not None:
            sections[current].append(line)
    return sections


def find_section(sections: dict[str, list[str]], wanted: str) -> list[str]:
    wanted_normalized = normalize_text(wanted)
    for title, lines in sections.items():
        if wanted_normalized == normalize_text(title):
            return lines
    for title, lines in sections.items():
        if wanted_normalized in normalize_text(title):
            return lines
    return []


def find_exact_section(sections: dict[str, list[str]], wanted: str) -> list[str]:
    wanted_normalized = normalize_text(wanted)
    for title, lines in sections.items():
        if wanted_normalized == normalize_text(title):
            return lines
    return []


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
        joined = " ".join(cells).strip()
        if not joined:
            continue
        if set(joined.replace(" ", "")) <= {"-", ":"}:
            continue
        rows.append(cells)
    if len(rows) <= 1:
        return []
    return rows[1:]


def extract_checklist_items(lines: list[str]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for line in lines:
        match = re.match(r"^\s*[-*]\s+\[[ xX]\]\s+(.+?)\s*$", line)
        if not match:
            continue
        item = strip_markup(match.group(1))
        if item:
            checked = bool(re.match(r"^\s*[-*]\s+\[[xX]\]", line))
            items.append({"text": item, "checked": checked})
    return items


def is_delivery_claim(todo_path: Path, stage: str | None, require_delivery: bool) -> bool:
    if require_delivery:
        return True
    parts = {part.lower() for part in todo_path.resolve().parts}
    if "promotion_lane" in parts or "completed" in parts:
        return True
    normalized_stage = normalize_stage_label(stage)
    for marker in DELIVERY_STAGE_MARKERS:
        normalized_marker = normalize_stage_label(marker)
        if normalized_stage == normalized_marker or normalized_stage.startswith(normalized_marker + "-"):
            return True
    return False


def build_requirements(sections: dict[str, list[str]]) -> tuple[list[dict[str, Any]], dict[str, int]]:
    requirements: list[dict[str, Any]] = []
    counts: dict[str, int] = {}
    for section_title, id_prefix in REQUIREMENT_SECTIONS:
        items = extract_checklist_items(find_exact_section(sections, section_title))
        context_key = normalize_text(section_title).replace(" ", "_") + "_count"
        counts[context_key] = len(items)
        for item in items:
            requirements.append(
                {
                    "section": section_title,
                    "id_prefix": id_prefix,
                    "text": item["text"],
                    "checked": item["checked"],
                }
            )
    return requirements, counts


def criterion_requires_runtime_evidence(criterion: str) -> bool:
    return any(marker_present(criterion, (term,)) for term in RUNTIME_REQUIRED_TERMS)


def criterion_requires_navigation_coverage(section: str, criterion: str) -> bool:
    normalized_section = normalize_text(section)
    if normalized_section not in {"definition of done", "validation steps"}:
        return False
    flow_impacting = criterion_has_user_flow_impact(criterion)
    if normalized_section == "validation steps":
        structural_test_request = any(marker_present(criterion, (term,)) for term in STRUCTURAL_TEST_REQUEST_TERMS)
        runtime_validation_request = any(marker_present(criterion, (term,)) for term in RUNTIME_VALIDATION_REQUEST_TERMS)
        if structural_test_request and not runtime_validation_request and not flow_impacting:
            return False
    return any(marker_present(criterion, (term,)) for term in VISIBLE_INTERACTIVE_TERMS) or flow_impacting


def criterion_has_user_flow_impact(criterion: str) -> bool:
    if any(marker_present(criterion, (term,)) for term in USER_FLOW_DIRECT_TERMS):
        return True
    has_context = any(marker_present(criterion, (term,)) for term in USER_FLOW_CONTEXT_TERMS)
    has_mutation = any(marker_present(criterion, (term,)) for term in CRUD_MUTATION_TERMS)
    if has_context and has_mutation:
        return True
    has_refactor = any(marker_present(criterion, (term,)) for term in USER_FLOW_REFACTOR_TERMS)
    return has_context and has_refactor


def row_has_navigation_coverage(row: list[str]) -> bool:
    combined = " ".join(row)
    return any(marker_present(combined, (term,)) for term in NAVIGATION_COVERAGE_TERMS)


def criterion_requires_playwright_coverage(section: str, criterion: str) -> bool:
    has_web_marker = any(marker_present(criterion, (term,)) for term in WEB_BROWSER_TERMS)
    if not has_web_marker:
        return False
    if criterion_requires_navigation_coverage(section, criterion):
        return True
    return any(marker_present(criterion, (term,)) for term in WEB_NAVIGATION_CONTEXT_TERMS)


def row_has_playwright_coverage(row: list[str]) -> bool:
    normalized = normalize_text(" ".join(row))
    has_spec = any(normalize_text(term) in normalized for term in PLAYWRIGHT_SPEC_TERMS)
    has_runner = any(normalize_text(term) in normalized for term in PLAYWRIGHT_RUNNER_TERMS)
    return has_spec and has_runner


def row_has_web_build_provenance(row: list[str]) -> bool:
    normalized = normalize_text(" ".join(row))
    return any(normalize_text(term) in normalized for term in WEB_BUILD_PROVENANCE_TERMS)


def criterion_requires_mutation_coverage(section: str, criterion: str) -> bool:
    return criterion_requires_navigation_coverage(section, criterion) and any(
        marker_present(criterion, (term,)) for term in CRUD_MUTATION_TERMS
    )


def row_has_mutation_coverage(row: list[str]) -> bool:
    combined = " ".join(row)
    normalized = normalize_text(combined)
    if any(
        phrase in normalized
        for phrase in (
            "no mutation",
            "without mutation",
            "sem mutacao",
            "sem mutação",
            "read only",
            "read-only",
            "readonly",
        )
    ):
        return False
    return any(marker_present(combined, (term,)) for term in MUTATION_EVIDENCE_TERMS)


def row_has_playwright_mutation_lane(row: list[str]) -> bool:
    if not row_has_playwright_coverage(row):
        return False
    normalized = normalize_text(" ".join(row))
    if any(phrase in normalized for phrase in ("read only", "read-only", "readonly")):
        return False
    return any(normalize_text(term) in normalized for term in PLAYWRIGHT_MUTATION_TERMS)


def build_violation(code: str, message: str, resolution: str, section: str) -> dict[str, str]:
    return {
        "code": code,
        "message": message,
        "resolution": resolution,
        "section": section,
    }


def validate_todo(
    todo_path: Path,
    require_delivery: bool,
    allow_waivers: bool,
) -> dict[str, Any]:
    context: dict[str, Any] = {
        "todo_path": str(todo_path),
        "current_delivery_stage": "unknown",
        "delivery_claim": False,
        "scope_count": 0,
        "acceptance_criteria_count": 0,
        "dod_count": 0,
        "validation_count": 0,
        "evidence_row_count": 0,
        "allow_waivers": allow_waivers,
    }
    violations: list[dict[str, str]] = []

    if not todo_path.is_file():
        return {
            "blocked": True,
            "violations": [
                build_violation(
                    "TODO-NOT-FOUND",
                    f"TODO file does not exist: {todo_path}",
                    "Pass a valid tactical TODO path.",
                    "TODO File",
                )
            ],
            "context": context,
        }

    lines = todo_path.read_text(encoding="utf-8").splitlines()
    sections = extract_sections(lines)
    stage = extract_field(find_section(sections, "Delivery Status Canon"), "Current delivery stage")
    context["current_delivery_stage"] = stage or "missing"
    delivery_claim = is_delivery_claim(todo_path, stage, require_delivery)
    context["delivery_claim"] = delivery_claim

    requirements, requirement_counts = build_requirements(sections)
    context.update(requirement_counts)
    context["dod_count"] = requirement_counts.get("definition_of_done_count", 0)
    context["validation_count"] = requirement_counts.get("validation_steps_count", 0)

    evidence_rows = table_rows(find_section(sections, "Completion Evidence Matrix"))
    context["evidence_row_count"] = len(evidence_rows)

    if not delivery_claim:
        return {"blocked": False, "violations": [], "context": context}

    if not evidence_rows:
        violations.append(
            build_violation(
                "COMPLETION-EVIDENCE-MATRIX-MISSING",
                "The TODO claims delivery progress but has no Completion Evidence Matrix rows.",
                "Add one concrete evidence row for every Scope, Acceptance Criteria, Definition of Done, and Validation Steps item.",
                "Completion Evidence Matrix",
            )
        )

    for requirement in requirements:
        criterion = requirement["text"]
        if not requirement["checked"]:
            violations.append(
                build_violation(
                    "CRITERION-CHECKLIST-UNCHECKED",
                    f"{requirement['section']} item is still unchecked under a delivery claim: {criterion}",
                    "Check the TODO item only after the implementation and criterion-specific evidence are complete, or move the TODO back to a non-delivery stage.",
                    requirement["section"],
                )
            )
        matching_rows = [
            row for row in evidence_rows if normalize_text(criterion) in normalize_text(row_text(row))
        ]
        if not matching_rows:
            violations.append(
                build_violation(
                    "CRITERION-EVIDENCE-MISSING",
                    f"{requirement['section']} item lacks criterion-specific evidence: {criterion}",
                    "Add a Completion Evidence Matrix row quoting this criterion exactly and record concrete evidence.",
                    "Completion Evidence Matrix",
                )
            )
            continue

        for row in matching_rows:
            if len(row) < 8:
                violations.append(
                    build_violation(
                        "EVIDENCE-ROW-INCOMPLETE",
                        f"Evidence row has fewer than 8 cells: {row_text(row)}",
                        "Use columns: Criterion ID, Source Section, Criterion, Evidence Type, Evidence Artifact / Command, Runtime Target, Status, Notes.",
                        "Completion Evidence Matrix",
                    )
                )
                continue

            evidence = row[4]
            runtime_target = row[5]
            status = normalize_text(row[6])
            notes = row[7]
            if status not in ALLOWED_ROW_STATUSES:
                violations.append(
                    build_violation(
                        "EVIDENCE-STATUS-INVALID",
                        f"Evidence row status `{row[6]}` is invalid for criterion: {criterion}",
                        f"Use one of {sorted(ALLOWED_ROW_STATUSES)}.",
                        "Completion Evidence Matrix",
                    )
                )
            elif status == "waived" and allow_waivers:
                if "approval" not in normalize_text(row_text(row)) and "aprovado" not in normalize_text(row_text(row)):
                    violations.append(
                        build_violation(
                            "WAIVER-APPROVAL-MISSING",
                            f"Waived criterion does not include approval evidence: {criterion}",
                            "Record explicit human approval evidence for the waiver or satisfy the criterion.",
                            "Completion Evidence Matrix",
                        )
                    )
                continue
            elif status not in DELIVERY_PASSING_STATUSES:
                violations.append(
                    build_violation(
                        "EVIDENCE-NOT-PASSED",
                        f"Evidence status `{row[6]}` does not satisfy delivery for criterion: {criterion}",
                        "Record `passed` with concrete evidence, or use `--allow-waivers` only after an approved waiver is recorded.",
                        "Completion Evidence Matrix",
                    )
                )

            if is_placeholder(evidence):
                violations.append(
                    build_violation(
                        "EVIDENCE-ARTIFACT-MISSING",
                        f"Evidence artifact/command is missing or placeholder for criterion: {criterion}",
                        "Replace aggregate or placeholder evidence with a real command, artifact path, file:line, PR/check, screenshot/video, runtime URL, or blocker/waiver record.",
                        "Completion Evidence Matrix",
                    )
                )

            lowered_evidence = normalize_text(" ".join((evidence, notes)))
            if any(term in lowered_evidence for term in ("not run", "nao executado", "não executado", "planned", "expected", "pending")):
                violations.append(
                    build_violation(
                        "EVIDENCE-ARTIFACT-NOT-REAL",
                        f"Evidence artifact/command is not real completed evidence for criterion: {criterion}",
                        "Run the validation or record an explicit blocker/approved waiver instead of claiming delivery.",
                        "Completion Evidence Matrix",
                    )
                )

            if criterion_requires_runtime_evidence(criterion) and (is_placeholder(runtime_target) or is_na(runtime_target)):
                violations.append(
                    build_violation(
                        "RUNTIME-EVIDENCE-MISSING",
                        f"Runtime/browser/device/integration criterion lacks a concrete runtime target: {criterion}",
                        "Record the real runtime target, device, browser, integration environment, build artifact, or CI target used for this criterion. For browser/web criteria, name the Playwright spec, runner command, target URL/lane, scripts/build_web.sh ../web-app <lane> publish proof, and refreshed real-domain bundle provenance.",
                        "Completion Evidence Matrix",
                    )
                )

            if criterion_requires_navigation_coverage(requirement["section"], criterion) and not row_has_navigation_coverage(row):
                violations.append(
                    build_violation(
                        "FLOW-CRITERION-NAVIGATION-COVERAGE-MISSING",
                        f"User-visible/interactive/flow-impacting criterion lacks item-specific integration/device or navigation/browser evidence: {criterion}",
                        "Add the integration/device test or navigation/browser test that exercises this exact item, or record an explicit approved structure-only waiver/deviation proving no user-observable flow can change. In Flutter scope, integration is ADB/device execution; browser navigation is Playwright against the final domain after build_web.sh publish.",
                        "Completion Evidence Matrix",
                    )
                )

            requires_playwright = criterion_requires_playwright_coverage(requirement["section"], criterion)
            if requires_playwright and not row_has_playwright_coverage(row):
                violations.append(
                    build_violation(
                        "BROWSER-WEB-PLAYWRIGHT-EVIDENCE-MISSING",
                        f"Browser/web-visible criterion lacks source-owned Playwright spec and runner evidence: {criterion}",
                        "Record the source-owned Playwright spec under tools/flutter/web_app_tests/** and the canonical runner command tools/flutter/run_web_navigation_smoke.sh readonly|mutation, plus target URL/lane, scripts/build_web.sh ../web-app <lane> publish proof, and refreshed real-domain bundle provenance.",
                        "Completion Evidence Matrix",
                    )
                )

            if requires_playwright and not row_has_web_build_provenance(row):
                violations.append(
                    build_violation(
                        "BROWSER-WEB-BUILD-PROVENANCE-MISSING",
                        f"Browser/web-visible criterion lacks current web build/publish provenance: {criterion}",
                        "Record the build/publish proof before Playwright, typically scripts/build_web.sh ../web-app <lane>, and evidence that the real browser-facing domain served the refreshed bundle such as __WEB_BUILD_SHA__.",
                        "Completion Evidence Matrix",
                    )
                )

            if criterion_requires_mutation_coverage(requirement["section"], criterion) and not row_has_mutation_coverage(row):
                violations.append(
                    build_violation(
                        "FLOW-CRUD-MUTATION-EVIDENCE-MISSING",
                        f"User-flow CRUD/mutation criterion lacks local mutation evidence: {criterion}",
                        "Record integration/device or navigation/browser evidence that performs the local mutation path on the approved non-main validation target. For browser/web mutation, record Playwright mutation-lane evidence; readonly web smoke is insufficient.",
                        "Completion Evidence Matrix",
                    )
                )

            if (
                requires_playwright
                and criterion_requires_mutation_coverage(requirement["section"], criterion)
                and not row_has_playwright_mutation_lane(row)
            ):
                violations.append(
                    build_violation(
                        "BROWSER-WEB-PLAYWRIGHT-MUTATION-EVIDENCE-MISSING",
                        f"Browser/web CRUD/mutation criterion lacks Playwright mutation-lane evidence: {criterion}",
                        "Record Playwright evidence from tools/flutter/run_web_navigation_smoke.sh mutation against the final domain on an approved non-main target. A readonly Playwright run, generic integration test, or ADB-only test is not web mutation evidence.",
                        "Completion Evidence Matrix",
                    )
                )

            for marker_label, aliases in LITERAL_MARKERS:
                if not marker_present(criterion, aliases):
                    continue
                if not marker_present(" ".join((evidence, runtime_target, notes)), aliases):
                    violations.append(
                        build_violation(
                            "LITERAL-MARKER-EVIDENCE-MISMATCH",
                            f"Criterion names `{marker_label}` but evidence does not prove the same marker: {criterion}",
                            "Update the evidence to name the exact required artifact, or record an explicit approved waiver/deviation.",
                            "Completion Evidence Matrix",
                        )
                    )

    return {"blocked": bool(violations), "violations": violations, "context": context}


def render_text(result: dict[str, Any]) -> str:
    blocked = bool(result["blocked"])
    context = result["context"]
    violations = result["violations"]
    lines: list[str] = []
    lines.append("TEACH runtime response")
    lines.append(f"status: {'blocked' if blocked else 'ready'}")
    lines.append("enforcement: " + ("stop_before_todo_completion_claim" if blocked else "allow_todo_completion_claim"))
    lines.append(f"rule_id: {RULE_ID}")
    lines.append("violation:")
    if not violations:
        lines.append("  - none")
    else:
        for violation in violations:
            lines.append(f"  - [{violation['code']}] {violation['section']}: {violation['message']}")
    lines.append("resolution_prompt:")
    if not violations:
        if context.get("delivery_claim"):
            lines.append("  - The TODO has criterion-specific completion evidence for its current delivery claim.")
        else:
            lines.append("  - The TODO is not currently claiming a delivery milestone that requires completion evidence.")
        lines.append("  - Rerun this guard before any Local-Implemented, Local-Validated, Local-Complete, promotion_lane, completed, or Production-Ready claim changes.")
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
        "todo_path",
        "current_delivery_stage",
        "delivery_claim",
        "scope_count",
        "acceptance_criteria_count",
        "dod_count",
        "validation_count",
        "evidence_row_count",
        "allow_waivers",
    ):
        lines.append(f"  {key}: {context.get(key)}")
    lines.append(f"Overall outcome: {'no-go' if blocked else 'go'}")
    return "\n".join(lines) + "\n"


def render_json(result: dict[str, Any]) -> str:
    payload = {
        "schema_version": "todo-completion-guard-v1",
        "rule_id": RULE_ID,
        "status": "blocked" if result["blocked"] else "ready",
        "overall_outcome": "no-go" if result["blocked"] else "go",
        **result,
    }
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def append_event(events_jsonl: str, result: dict[str, Any]) -> None:
    payload = {
        "schema_version": "rule-event-v1",
        "recorded_at_utc": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "rule_id": RULE_ID,
        "source_kind": "completion_guard",
        "status": "blocked" if result["blocked"] else "ready",
        "overall_outcome": "no-go" if result["blocked"] else "go",
        "context": result["context"],
        "violation_codes": [violation["code"] for violation in result["violations"]],
    }
    path = Path(events_jsonl)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, sort_keys=True) + "\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate tactical TODO completion evidence with TEACH output.")
    parser.add_argument("todo", help="Path to a tactical TODO markdown file.")
    parser.add_argument(
        "--require-delivery",
        action="store_true",
        help="Require completion evidence even if the TODO status/path does not yet claim a delivery milestone.",
    )
    parser.add_argument(
        "--allow-waivers",
        action="store_true",
        help="Allow rows with status `waived` only when approval evidence is present.",
    )
    parser.add_argument("--json-output", help="Optional path to write a JSON result artifact.")
    parser.add_argument("--events-jsonl", help="Optional JSONL ledger path for rule-event collection.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    todo_path = Path(args.todo).resolve()
    result = validate_todo(
        todo_path,
        require_delivery=args.require_delivery,
        allow_waivers=args.allow_waivers,
    )
    text = render_text(result)
    print(text, end="")
    if args.json_output:
        Path(args.json_output).write_text(render_json(result), encoding="utf-8")
    if args.events_jsonl:
        append_event(args.events_jsonl, result)
    return 2 if result["blocked"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        raise SystemExit(1)
