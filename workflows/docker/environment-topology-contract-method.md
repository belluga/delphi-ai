---
description: Generate and validate a portable environment topology contract before using runtime, tenant, domain, or stack-activation assumptions.
---

# Method: Environment Topology Contract

## Purpose
Create a project-owned topology contract that separates Delphi's available capabilities from the downstream project's active stack, runtime owner, domains, tenants, compose profiles, and safe runners.

## Triggers
- Validation, browser, build, publish, tenant/domain probing, CI, or DevOps work depends on environment topology.
- Active stack usage is ambiguous or only inferred from Delphi capability files.
- A downstream project lacks a durable `foundation_documentation/artifacts/environment-topology.md` contract.
- The user asks Delphi to infer what the environment already exposes while still validating facts with them.

## Inputs
- Downstream repository root.
- `.gitmodules`, README files, compose files, `.env.example`, redacted `.env` values, safe-runner scripts, and existing `foundation_documentation`.
- Delphi stack capability registry (`config/stack_capabilities.yaml`) as available-capability context only.

## Procedure
1. Confirm this is downstream topology discovery, not a global Delphi capability decision.
2. Generate a redacted draft when the project has enough local evidence:
   - `python3 delphi-ai/tools/environment_topology_contract_scaffold.py --repo <repo-root> --output foundation_documentation/artifacts/environment-topology.md`
   - Use `--force` only when intentionally refreshing an existing draft.
3. Review the generated tables:
   - active stack candidates;
   - runtime owners and safe runners;
   - public domains, tenant hints, URLs, and compose profiles;
   - compose/service hints;
   - submodules and role inferences.
4. Treat every `user_validation_required` row as a question, not as authority.
   - If only one plausible value exists, prefill it in the draft and ask the user/project owner to confirm it.
   - If multiple plausible values exist, present the candidates and ask which one is canonical.
   - If no evidence exists, mark `unknown` and do not guess.
5. Never write real secrets. Secret-like keys and unknown private env values must be redacted or omitted.
6. Promote only validated, stable facts into durable project surfaces:
   - keep the contract in `foundation_documentation/artifacts/environment-topology.md`;
   - reference it from `dependency-readiness.md`, active TODO validation notes, or module docs when those facts control execution;
   - keep project-specific topology out of `delphi-ai/`.
7. Before running topology-dependent validation, cite the validated contract or explicitly state which values remain unvalidated.

## Outputs
- Redacted environment topology contract draft or refreshed validated contract.
- User-validation checklist for inferred stack/runtime/domain/tenant values.
- Clear boundary between available Delphi capabilities and active downstream topology.

## Non-Negotiables
- Do not infer active project stacks from Delphi skills, scripts, workflows, or rules alone.
- Do not guess tenant/domain/runtime targets when project evidence is ambiguous.
- Do not store secrets in generated contracts, TODOs, or Delphi core.
- Do not promote project-specific topology into global Delphi instructions.
