---
name: wf-docker-environment-readiness-method
description: "Workflow: MUST use whenever the scope matches this purpose: Ensure the working copy is correctly wired before DevOps/CI work proceeds."
---

# Method: DevOps Environment Readiness

Use this skill as the operational entrypoint for the canonical workflow in `workflows/docker/environment-readiness-method.md`.
The workflow file is the normative source for readiness sequencing and topology-resolution details.

## Purpose
Verify that a downstream working copy is wired well enough for DevOps, CI, build, publish, or validation work without guessing stack activation or runtime topology.

## Canonical Sources
- `workflows/docker/environment-readiness-method.md`
- `workflows/docker/environment-topology-contract-method.md`
- `config/stack_capabilities.yaml`
- `ecosystem_template_configuration.md`
- `rules/core/initialization-readiness-model-decision.md`

## Procedure
1. Confirm repository context and whether the project is zero-state.
2. Treat `config/stack_capabilities.yaml` as available-capability context only.
3. Resolve active stacks and runtime topology from project-owned sources: active TODO, `foundation_documentation`, dependency-readiness, `.gitmodules`, README, compose/env examples, and safe runners.
   - If the project lacks a durable topology contract or available evidence has drifted, run `python3 delphi-ai/tools/environment_topology_contract_scaffold.py --repo <repo-root> --output foundation_documentation/artifacts/environment-topology.md`, then validate inferred rows with the user before treating them as authority.
4. Run `bash delphi-ai/verify_context.sh` read-only; use `--repair` only for Delphi-managed link/artifact issues.
5. Run the project readiness verifier when the downstream topology exists.
6. Validate submodules, filesystem ownership, declared script links, and validation topology before build/deploy/CI work proceeds.

## Preferred Deterministic Helper
- `bash delphi-ai/tools/environment_readiness_report.sh`
- `bash delphi-ai/tools/environment_readiness_report.sh --include-adherence-sync` when full downstream sync validation is required.
- `python3 delphi-ai/tools/environment_topology_contract_scaffold.py --repo <repo-root> --output foundation_documentation/artifacts/environment-topology.md` when runtime/domain/tenant/active-stack facts need a portable draft.

## Non-Negotiables
- Do not infer active Flutter, Laravel, Docker, or Go usage from Delphi files alone.
- Do not guess tenant/domain/runtime targets. If project-owned artifacts leave multiple plausible choices, ask.
- Stable environment facts belong in `foundation_documentation` or project-owned config/env, not in Delphi.
