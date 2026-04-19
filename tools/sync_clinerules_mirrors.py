#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Mirror:
    key: str
    kind: str
    source: str
    destination: str
    title: str
    workflow_name: str | None = None
    append_text: str | None = None


MIRRORS: tuple[Mirror, ...] = (
    Mirror(
        key="shared-initialization-readiness",
        kind="model_decision",
        source="rules/core/initialization-readiness-model-decision.md",
        destination=".clinerules/model-decision/shared-initialization-readiness.md",
        title="Initialization Readiness (Model Decision)",
        append_text="## Workflow Reference\n\nSee: `.clinerules/workflows/docker-environment-readiness.md`\n",
    ),
    Mirror(
        key="shared-workflow-definition",
        kind="model_decision",
        source="rules/core/workflow-definition-model-decision.md",
        destination=".clinerules/model-decision/shared-workflow-definition.md",
        title="Workflow Definition (Model Decision)",
    ),
    Mirror(
        key="shared-session-lifecycle",
        kind="model_decision",
        source="rules/core/session-lifecycle-model-decision.md",
        destination=".clinerules/model-decision/shared-session-lifecycle.md",
        title="Session Lifecycle (Model Decision)",
        append_text="## Workflow Reference\n\nSee: `.clinerules/workflows/docker-session-lifecycle.md`\n",
    ),
    Mirror(
        key="shared-delphi-project-setup",
        kind="model_decision",
        source="rules/core/delphi-project-setup-model-decision.md",
        destination=".clinerules/model-decision/shared-delphi-project-setup.md",
        title="Delphi Project Setup (Model Decision)",
        append_text="## Workflow Reference\n\nSee: `.clinerules/workflows/docker-delphi-project-setup.md`\n",
    ),
    Mirror(
        key="docker-documentation-migration",
        kind="workflow",
        source="workflows/docker/documentation-migration-method.md",
        destination=".clinerules/workflows/docker-documentation-migration.md",
        title="Workflow: Documentation Migration & Expansion",
        workflow_name="docker-documentation-migration",
    ),
    Mirror(
        key="docker-deterministic-todo-validation-method",
        kind="workflow",
        source="workflows/docker/deterministic-todo-validation-method.md",
        destination=".clinerules/workflows/docker-deterministic-todo-validation-method.md",
        title="Workflow: Deterministic TODO Validation",
        workflow_name="docker-deterministic-todo-validation-method",
    ),
    Mirror(
        key="docker-environment-readiness",
        kind="workflow",
        source="workflows/docker/environment-readiness-method.md",
        destination=".clinerules/workflows/docker-environment-readiness.md",
        title="Workflow: DevOps Environment Readiness",
        workflow_name="docker-environment-readiness",
    ),
    Mirror(
        key="docker-independent-critique-method",
        kind="workflow",
        source="workflows/docker/independent-critique-method.md",
        destination=".clinerules/workflows/docker-independent-critique-method.md",
        title="Workflow: Independent No-Context Critique",
        workflow_name="docker-independent-critique-method",
    ),
    Mirror(
        key="docker-independent-final-review-method",
        kind="workflow",
        source="workflows/docker/independent-final-review-method.md",
        destination=".clinerules/workflows/docker-independent-final-review-method.md",
        title="Workflow: Independent No-Context Final Review",
        workflow_name="docker-independent-final-review-method",
    ),
    Mirror(
        key="docker-independent-test-quality-audit-method",
        kind="workflow",
        source="workflows/docker/independent-test-quality-audit-method.md",
        destination=".clinerules/workflows/docker-independent-test-quality-audit-method.md",
        title="Workflow: Independent Test Quality Audit",
        workflow_name="docker-independent-test-quality-audit-method",
    ),
    Mirror(
        key="docker-todo-driven-execution-method",
        kind="workflow",
        source="workflows/docker/todo-driven-execution-method.md",
        destination=".clinerules/workflows/docker-todo-driven-execution-method.md",
        title="Workflow: TODO-Driven Execution",
        workflow_name="docker-todo-driven-execution-method",
    ),
    Mirror(
        key="docker-performance-concurrency-validation-method",
        kind="workflow",
        source="workflows/docker/performance-concurrency-validation-method.md",
        destination=".clinerules/workflows/docker-performance-concurrency-validation-method.md",
        title="Workflow: Performance & Concurrency Validation Lanes",
        workflow_name="docker-performance-concurrency-validation-method",
    ),
    Mirror(
        key="docker-update-skill-method",
        kind="workflow",
        source="workflows/docker/update-skill-method.md",
        destination=".clinerules/workflows/docker-update-skill-method.md",
        title="Workflow: Update Skill Across Agent Surfaces",
        workflow_name="docker-update-skill-method",
    ),
    Mirror(
        key="docker-delphi-project-setup",
        kind="workflow",
        source="workflows/docker/delphi-project-setup-method.md",
        destination=".clinerules/workflows/docker-delphi-project-setup.md",
        title="Workflow: Delphi Project Setup",
        workflow_name="docker-delphi-project-setup",
    ),
    Mirror(
        key="docker-delphi-project-setup-method",
        kind="workflow",
        source="workflows/docker/delphi-project-setup-method.md",
        destination=".clinerules/workflows/docker-delphi-project-setup-method.md",
        title="Workflow: Delphi Project Setup",
        workflow_name="docker-delphi-project-setup-method",
    ),
    Mirror(
        key="docker-brownfield-normalization-method",
        kind="workflow",
        source="workflows/docker/brownfield-normalization-method.md",
        destination=".clinerules/workflows/docker-brownfield-normalization-method.md",
        title="Workflow: Brownfield Normalization",
        workflow_name="docker-brownfield-normalization-method",
    ),
    Mirror(
        key="docker-subagent-orchestration-method",
        kind="workflow",
        source="workflows/docker/subagent-orchestration-method.md",
        destination=".clinerules/workflows/docker-subagent-orchestration-method.md",
        title="Workflow: No-Context Subagent Orchestration",
        workflow_name="docker-subagent-orchestration-method",
    ),
    Mirror(
        key="docker-profile-selection",
        kind="workflow",
        source="workflows/docker/profile-selection-method.md",
        destination=".clinerules/workflows/docker-profile-selection.md",
        title="Workflow: Profile Selection",
        workflow_name="docker-profile-selection",
    ),
    Mirror(
        key="docker-profile-selection-method",
        kind="workflow",
        source="workflows/docker/profile-selection-method.md",
        destination=".clinerules/workflows/docker-profile-selection-method.md",
        title="Workflow: Profile Selection",
        workflow_name="docker-profile-selection-method",
    ),
    Mirror(
        key="docker-session-lifecycle",
        kind="workflow",
        source="workflows/docker/session-lifecycle-method.md",
        destination=".clinerules/workflows/docker-session-lifecycle.md",
        title="Workflow: Session Lifecycle",
        workflow_name="docker-session-lifecycle",
    ),
    Mirror(
        key="docker-post-session-review",
        kind="workflow",
        source="workflows/docker/post-session-review-method.md",
        destination=".clinerules/workflows/docker-post-session-review.md",
        title="Workflow: Post-Session Review",
        workflow_name="docker-post-session-review",
    ),
    Mirror(
        key="docker-runtime-index-method",
        kind="workflow",
        source="workflows/docker/runtime-index-method.md",
        destination=".clinerules/workflows/docker-runtime-index-method.md",
        title="Workflow: Runtime Index / Session Handoff Index",
        workflow_name="docker-runtime-index-method",
    ),
    Mirror(
        key="docker-genesis-bootstrap-method",
        kind="workflow",
        source="workflows/docker/genesis-bootstrap-method.md",
        destination=".clinerules/workflows/docker-genesis-bootstrap-method.md",
        title="Workflow: Genesis Bootstrap",
        workflow_name="docker-genesis-bootstrap-method",
    ),
    Mirror(
        key="create-controller",
        kind="workflow",
        source="workflows/flutter/create-controller-method.md",
        destination=".clinerules/workflows/create-controller.md",
        title="Workflow: Create Controller (Flutter)",
        workflow_name="create-controller",
    ),
    Mirror(
        key="create-screen",
        kind="workflow",
        source="workflows/flutter/create-screen-method.md",
        destination=".clinerules/workflows/create-screen.md",
        title="Workflow: Create Screen (Flutter)",
        workflow_name="create-screen",
    ),
    Mirror(
        key="create-repository",
        kind="workflow",
        source="workflows/flutter/create-repository-method.md",
        destination=".clinerules/workflows/create-repository.md",
        title="Workflow: Create Repository (Flutter)",
        workflow_name="create-repository",
    ),
    Mirror(
        key="create-repository-method",
        kind="workflow",
        source="workflows/flutter/create-repository-method.md",
        destination=".clinerules/workflows/create-repository-method.md",
        title="Workflow: Create Repository (Flutter)",
        workflow_name="create-repository-method",
    ),
    Mirror(
        key="laravel-create-api-endpoint",
        kind="workflow",
        source="workflows/laravel/create-api-endpoint-method.md",
        destination=".clinerules/workflows/laravel-create-api-endpoint.md",
        title="Workflow: Create/Update API Endpoint (Laravel)",
        workflow_name="laravel-create-api-endpoint",
    ),
    Mirror(
        key="laravel-create-api-endpoint-method",
        kind="workflow",
        source="workflows/laravel/create-api-endpoint-method.md",
        destination=".clinerules/workflows/laravel-create-api-endpoint-method.md",
        title="Workflow: Create/Update API Endpoint (Laravel)",
        workflow_name="laravel-create-api-endpoint-method",
    ),
    Mirror(
        key="laravel-create-domain",
        kind="workflow",
        source="workflows/laravel/create-domain-method.md",
        destination=".clinerules/workflows/laravel-create-domain.md",
        title="Workflow: Create Domain (Laravel)",
        workflow_name="laravel-create-domain",
    ),
    Mirror(
        key="laravel-create-domain-method",
        kind="workflow",
        source="workflows/laravel/create-domain-method.md",
        destination=".clinerules/workflows/laravel-create-domain-method.md",
        title="Workflow: Create Domain (Laravel)",
        workflow_name="laravel-create-domain-method",
    ),
    Mirror(
        key="laravel-create-package-method",
        kind="workflow",
        source="workflows/laravel/create-package-method.md",
        destination=".clinerules/workflows/laravel-create-package-method.md",
        title="Workflow: Create or Refactor Laravel Package",
        workflow_name="laravel-create-package-method",
    ),
)


FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n*", re.DOTALL)
DESCRIPTION_RE = re.compile(r'^description:\s*(.+?)\s*$', re.MULTILINE)
H1_RE = re.compile(r"^# .*$", re.MULTILINE)


def strip_quotes(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def split_frontmatter(text: str) -> tuple[str | None, str]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None, text.lstrip("\n")
    return match.group(1), text[match.end() :].lstrip("\n")


def extract_description(frontmatter: str | None, source: str) -> str:
    if not frontmatter:
        raise ValueError(f"Missing frontmatter in {source}")
    match = DESCRIPTION_RE.search(frontmatter)
    if not match:
        raise ValueError(f"Missing description frontmatter in {source}")
    return strip_quotes(match.group(1))


def replace_or_prepend_h1(body: str, title: str) -> str:
    body = body.strip()
    replacement = f"# {title}"
    if H1_RE.search(body):
        return H1_RE.sub(replacement, body, count=1)
    return f"{replacement}\n\n{body}"


def generated_comment(mirror: Mirror) -> str:
    return (
        f"<!-- Generated from `{mirror.source}` by `tools/sync_clinerules_mirrors.py`. "
        "Do not edit directly. -->"
    )


def render_model_decision(mirror: Mirror, body: str) -> str:
    rendered = [generated_comment(mirror), "", f"# {mirror.title}", "", body.strip()]
    if mirror.append_text:
        rendered.extend(["", mirror.append_text.strip()])
    return "\n".join(rendered).rstrip() + "\n"


def render_workflow(mirror: Mirror, description: str, body: str) -> str:
    if not mirror.workflow_name:
        raise ValueError(f"Workflow mirror {mirror.key} is missing workflow_name")
    body = replace_or_prepend_h1(body, mirror.title)
    return (
        f"---\n"
        f'name: "{mirror.workflow_name}"\n'
        f'description: "{description}"\n'
        f"---\n\n"
        f"{generated_comment(mirror)}\n\n"
        f"{body.strip()}\n"
    )


def render_mirror(repo_root: Path, mirror: Mirror) -> str:
    source_path = repo_root / mirror.source
    source_text = source_path.read_text(encoding="utf-8")
    frontmatter, body = split_frontmatter(source_text)

    if mirror.kind == "model_decision":
        return render_model_decision(mirror, body)
    if mirror.kind == "workflow":
        description = extract_description(frontmatter, mirror.source)
        return render_workflow(mirror, description, body)
    raise ValueError(f"Unknown mirror kind: {mirror.kind}")


def selected_mirrors(selectors: list[str]) -> list[Mirror]:
    if not selectors:
        return list(MIRRORS)

    by_key = {mirror.key: mirror for mirror in MIRRORS}
    chosen: list[Mirror] = []
    seen: set[str] = set()
    for selector in selectors:
        mirror = by_key.get(selector)
        if mirror is None:
            valid = ", ".join(sorted(by_key))
            raise ValueError(f"Unknown mirror selector '{selector}'. Valid selectors: {valid}")
        if selector not in seen:
            chosen.append(mirror)
            seen.add(selector)
    return chosen


def write_if_changed(path: Path, content: str) -> bool:
    if path.exists() and path.read_text(encoding="utf-8") == content:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Synchronize curated .clinerules mirrors from canonical Delphi rules/workflows."
    )
    parser.add_argument(
        "selectors",
        nargs="*",
        help="Optional curated mirror selectors. Omit to sync all curated mirrors.",
    )
    parser.add_argument(
        "--list-targets",
        action="store_true",
        help="Print generated destination paths and exit.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parent.parent

    try:
        mirrors = selected_mirrors(args.selectors)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    if args.list_targets:
        for mirror in mirrors:
            print(mirror.destination)
        return 0

    updated = 0
    for mirror in mirrors:
        content = render_mirror(repo_root, mirror)
        if write_if_changed(repo_root / mirror.destination, content):
            updated += 1

    print(f"Synchronized {len(mirrors)} curated .clinerules mirror(s); updated {updated}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
