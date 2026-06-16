---
name: rule-docker-shared-environment-topology-contract-model-decision
description: "Rule: MUST use whenever downstream runtime topology, domains, tenants, validation targets, safe runners, or active stack evidence are inferred or relied on."
---

# Rule: Environment Topology Contract

Use this skill as the operational entrypoint for `rules/core/environment-topology-contract-model-decision.md`.

## Core Rule
Project-active topology is project-owned. Delphi may infer and prefill a draft from local evidence, but runtime/domain/tenant/stack facts remain `user_validation_required` until confirmed.

## Required Support
- Use `tools/environment_topology_contract_scaffold.py` when a project lacks a durable topology contract and enough evidence exists to draft one.
- Store validated facts in `foundation_documentation/artifacts/environment-topology.md` or the relevant project-owned contract.
- Keep `config/stack_capabilities.yaml` as available-capability context only.

## Blockers
- Guessed domains, tenants, runtime owners, compose profiles, or validation URLs.
- Real secrets copied from env files.
- Project-specific topology promoted into Delphi core.
