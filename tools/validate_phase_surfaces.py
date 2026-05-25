#!/usr/bin/env python3
"""Validate phase-split skill surfaces that must stay in sync."""

from __future__ import annotations

import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class PhaseGroup:
    name: str
    umbrella_skill: str
    phases: tuple[str, ...]
    workflows: tuple[str, ...] = ()
    clinerules: tuple[str, ...] = ()
    require_register: bool = True


PHASE_GROUPS = (
    PhaseGroup(
        name="todo-driven",
        umbrella_skill="wf-docker-todo-driven-execution-method",
        phases=(
            "wf-docker-todo-lane-framing-method",
            "wf-docker-todo-contract-refinement-method",
            "wf-docker-todo-approval-gates-method",
            "wf-docker-todo-execution-boundary-method",
            "wf-docker-todo-delivery-gates-method",
            "wf-docker-todo-closeout-promotion-method",
        ),
        workflows=(
            "workflows/docker/todo-lane-framing-method.md",
            "workflows/docker/todo-contract-refinement-method.md",
            "workflows/docker/todo-approval-gates-method.md",
            "workflows/docker/todo-execution-boundary-method.md",
            "workflows/docker/todo-delivery-gates-method.md",
            "workflows/docker/todo-closeout-promotion-method.md",
        ),
        clinerules=(
            ".clinerules/workflows/docker-todo-lane-framing-method.md",
            ".clinerules/workflows/docker-todo-contract-refinement-method.md",
            ".clinerules/workflows/docker-todo-approval-gates-method.md",
            ".clinerules/workflows/docker-todo-execution-boundary-method.md",
            ".clinerules/workflows/docker-todo-delivery-gates-method.md",
            ".clinerules/workflows/docker-todo-closeout-promotion-method.md",
        ),
    ),
    PhaseGroup(
        name="github-stage-promotion",
        umbrella_skill="github-stage-promotion-orchestrator",
        phases=(
            "github-stage-promotion-intake-classification",
            "github-stage-promotion-contract-preflight",
            "github-stage-promotion-source-to-dev",
            "github-stage-promotion-bot-next-version-recovery",
            "github-stage-promotion-dev-to-stage",
            "github-stage-promotion-docker-finalization",
            "github-stage-promotion-failure-review",
            "github-stage-promotion-closeout-report",
        ),
    ),
)


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError:
        return ""


def same_file(a: Path, b: Path) -> bool:
    return a.is_file() and b.is_file() and read(a) == read(b)


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    register = root / "skills" / "deterministic-tooling-register.md"
    register_text = read(register)

    for group in PHASE_GROUPS:
        umbrella = root / "skills" / group.umbrella_skill / "SKILL.md"
        umbrella_text = read(umbrella)
        if not umbrella.is_file():
            errors.append(f"{group.name}: missing umbrella skill {umbrella.relative_to(root)}")
            continue

        for phase in group.phases:
            canonical = root / "skills" / phase / "SKILL.md"
            cline = root / ".cline" / "skills" / phase / "SKILL.md"
            claude = root / ".claude" / "skills" / phase / "SKILL.md"
            if not canonical.is_file():
                errors.append(f"{group.name}: missing phase skill {canonical.relative_to(root)}")
                continue
            if phase not in umbrella_text:
                errors.append(f"{group.name}: umbrella skill does not reference phase {phase}")
            if not same_file(canonical, cline):
                errors.append(f"{group.name}: .cline mirror missing or stale for {phase}")
            if not same_file(canonical, claude):
                errors.append(f"{group.name}: .claude mirror missing or stale for {phase}")
            if group.require_register and phase not in register_text:
                errors.append(f"{group.name}: deterministic tooling register missing {phase}")

        for workflow in group.workflows:
            if not (root / workflow).is_file():
                errors.append(f"{group.name}: missing phase workflow {workflow}")

        for clinerule in group.clinerules:
            if not (root / clinerule).is_file():
                errors.append(f"{group.name}: missing .clinerules phase workflow {clinerule}")

    return errors


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    errors = validate(root)
    if errors:
        print("validate_phase_surfaces: FAIL", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("validate_phase_surfaces: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
