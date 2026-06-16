# Documentation: Ecosystem Template Configuration

**Version:** 1.1

## 1. Capability Model

Delphi is the reusable method layer for the Belluga ecosystem. Its stack support is additive: Delphi may carry scripts, workflows, rules, skills, package guidance, and deterministic helpers for multiple stacks even when a downstream project uses only a subset of them.

The stack capability registry is [`config/stack_capabilities.yaml`](config/stack_capabilities.yaml). That registry describes what Delphi can support globally; it does not activate a stack inside a project by itself.

## 2. Available Belluga Capabilities

The current Belluga baseline keeps these capabilities available:

| Capability | Status | Role |
| --- | --- | --- |
| `docker` | available | Runtime orchestration, environment readiness, ingress, CI, and promotion coordination. |
| `flutter` | available | Client app, Flutter web publication, device/browser validation, and reusable Flutter packages. |
| `laravel` | available | Backend/API/domain workflows, package extraction, tenant access, and domain-resolution guardrails. |
| `go` | future | Reserved backend/service capability for future migration or new services. |

Availability means Delphi can provide reusable support. It does not mean every downstream project has the stack active.

## 3. Project Activation Contract

Active project topology is project-owned. Before running stack-specific commands, validations, builds, migrations, browser checks, or tenant/domain probes, resolve the active surface from:

1. the active TODO and its validation notes;
2. `foundation_documentation/project_constitution.md`, module docs, and policies;
3. `foundation_documentation/artifacts/dependency-readiness.md`;
4. `.gitmodules`, README, compose files, `.env.example`, and project-owned safe runners/wrappers;
5. direct user clarification when multiple plausible targets remain.

Do not infer active stack usage from the mere presence of Delphi files under `delphi-ai/`.

## 4. Runtime and Environment Contracts

Environment, tenants, domains, validation tenants/subdomains, runtime owners, compose profiles, publish targets, and safe-runner commands are not global Delphi facts. They must be declared by the downstream project through foundation documentation, dependency-readiness notes, README/config, or approved project-owned env/config surfaces.

Delphi may ship Belluga defaults for convenience and backward compatibility, but defaults must remain configurable. Existing Flutter/Laravel/Docker helpers should stay available; projects execute only the helpers their topology declares active.

When available downstream evidence can be collected safely, Delphi should scaffold `foundation_documentation/artifacts/environment-topology.md` with `tools/environment_topology_contract_scaffold.py`. The scaffold fills known public topology hints and redacts private env values; generated rows stay pending user validation until confirmed.

## 5. Package Registry Boundary

Ecosystem package ownership is tracked separately in [`config/ecosystem_packages.yaml`](config/ecosystem_packages.yaml). Package availability is not stack activation either: a global package can exist before a project consumes it, and a project-local package belongs in the project-local package registry until promoted.
