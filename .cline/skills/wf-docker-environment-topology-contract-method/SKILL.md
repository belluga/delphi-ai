---
name: wf-docker-environment-topology-contract-method
description: "Workflow: MUST use whenever environment topology, runtime ownership, domains, tenants, validation URLs, or active stack evidence must be inferred or confirmed before downstream execution."
---

# Method: Environment Topology Contract

Use this skill as the operational entrypoint for `workflows/docker/environment-topology-contract-method.md`.

## Purpose
Build a redacted, project-owned topology contract from available downstream evidence while keeping every inferred runtime/domain/tenant/stack fact subject to user validation before it becomes authoritative.

## Canonical Sources
- `workflows/docker/environment-topology-contract-method.md`
- `templates/environment_topology_contract_template.md`
- `tools/environment_topology_contract_scaffold.py`
- `config/stack_capabilities.yaml`

## Procedure
1. Confirm the work depends on downstream topology rather than Delphi's global capability registry.
2. Run the scaffold when evidence exists:
   - `python3 delphi-ai/tools/environment_topology_contract_scaffold.py --repo <repo-root> --output foundation_documentation/artifacts/environment-topology.md`
3. Review generated rows with the user/project owner.
4. Promote only confirmed facts to durable project docs or TODO validation notes.

## Non-Negotiables
- Redact secrets and never store private env values.
- Prefill values already available in `.gitmodules`, README, compose, env examples, redacted env files, and safe runners, but keep them marked `user_validation_required` until confirmed.
- Keep project-specific topology in downstream `foundation_documentation`, not in Delphi core.
