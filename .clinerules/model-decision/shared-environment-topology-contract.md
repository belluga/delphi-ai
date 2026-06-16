<!-- Generated from `rules/core/environment-topology-contract-model-decision.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Environment Topology Contract (Model Decision)

# Rule: Environment Topology Contract

## Decision
When work depends on runtime topology, active stack usage, domains, tenants, validation URLs, compose profiles, safe runners, or build/publish targets, Delphi must resolve those facts from project-owned evidence and user validation. Delphi's global stack capability registry only describes what can be supported; it does not activate a stack in a downstream project.

## Required Behavior
- Prefill a topology draft from available downstream evidence when possible:
  - active TODOs and validation notes;
  - `foundation_documentation` and dependency-readiness artifacts;
  - `.gitmodules`, README files, compose files, `.env.example`, redacted `.env` values, and project-owned safe runners.
- Mark inferred facts as `user_validation_required` until confirmed.
- Ask the user/project owner when multiple plausible targets remain.
- Store stable topology facts in downstream `foundation_documentation`, not in Delphi core.
- Use `tools/environment_topology_contract_scaffold.py` and `workflows/docker/environment-topology-contract-method.md` when a durable topology contract is missing or stale.

## Forbidden
- Running topology-dependent commands against guessed hosts, tenants, domains, compose profiles, or runtime owners.
- Treating the presence of a Delphi skill/script/workflow/rule as evidence that a downstream stack is active.
- Copying real secrets from `.env` into generated contracts, TODOs, or Delphi instructions.
- Hard-coding Belluga-project topology into project-agnostic Delphi rules.

## Validation
- The active TODO or delivery evidence must cite the validated contract or explain why topology is not relevant.
- If inferred values remain unvalidated, the work must either stay in draft/planning or carry an explicit waiver/risk note.

## Workflow Reference

See: `.clinerules/workflows/docker-environment-topology-contract-method.md`
