# Feature Brief: Delphi Multi-Stack Capability Admission

## Artifact Role
- **Why this brief exists now:** The reference engineering repository combines four independently activatable capabilities—NestJS, React, PostgreSQL/Prisma, and Railway. Admitting them safely requires a generic capability substrate plus stack-specific packages, which is broader than one tactical TODO.
- **What this brief is not:** This is not a canonical architecture source, a tactical TODO, or implementation authority.

## Source Idea / Request
- Compare Delphi with `unifast-tech/leadshug-engineering` at `98b8284` and evolve Delphi so it can support the new stack while preserving a generic core and stack-specific modules.

## Problem / Desired Outcome
- **Problem:** Delphi's registry is conceptually additive, but validation still hard-codes the original capability set and topology detection cannot distinguish Node stacks by `package.json` dependencies. Copying the reference repository directly would also import LeadsHug-specific authority, naming, tenant/BU assumptions, and fixed cross-stack coupling.
- **Desired outcome:** Delphi can discover and support NestJS, React, PostgreSQL/Prisma, and Railway as independent capabilities, compose them when a downstream project activates several, and keep all product topology in project-owned contracts.
- **Why now:** The current branch is explicitly dedicated to adding stack capabilities, and the reference repository supplies concrete candidate rules/workflows that can be generalized instead of reinvented.

## Constraints / Non-Goals
- **Constraints:** Keep capability presence separate from downstream activation; validate every registry entry; avoid `package.json`-only detection; keep cross-stack references conditional; preserve Docker, Flutter, Laravel, and future Go; require a minimal canonical rule/workflow/skill package before a capability becomes `available`.
- **Non-goals:** Import LeadsHug delivery-cycle tooling, Claude-specific project policy, workspace bootstrap scripts, project versions, product paths, mandatory tenant/BU semantics, or a monolithic "LeadsHug stack" namespace.

## Canonical Touchpoints
- **Constitution impact:** none — this is Delphi self-maintenance.
- **Roadmap impact:** none — sequencing lives in this brief and the resulting tactical TODOs.
- **Primary module candidates:** `config/stack_capabilities.yaml`, `tools/validate_stack_capabilities.py`, `tools/environment_topology_contract_scaffold.py`
- **Secondary module candidates:** `rules/stacks/<stack>/`, `workflows/<stack>/`, `skills/`, `skills/deterministic-tooling-register.md`

## Evidence / References
- Delphi `config/stack_capabilities.yaml` already separates global availability from project activation.
- Delphi `tools/validate_stack_capabilities.py` validates required fields only for the hard-coded set `docker|flutter|laravel|go`, so additional blocks can escape field/lifecycle validation.
- Delphi `tools/environment_topology_contract_scaffold.py` supports Composer dependency matching but has no equivalent package-dependency discriminator for Node stacks.
- `leadshug-engineering/config/stack_capabilities.yaml` declares `nestjs`, `react`, `postgres-prisma`, and `railway` independently.
- The reference stack rules/workflows have reusable architecture cores, but `leadshug-*` names, direct LeadsHug references, unconditional `tenant/BU`, and fixed React/NestJS/Prisma/Railway coupling must be removed or made project-conditional.

## Ambiguities To Resolve Before TODO
| ID | Ambiguity | Why It Matters | Current Evidence | Handling (`resolve now|carry as TODO assumption|block`) |
| --- | --- | --- | --- | --- |
| `AMB-01` | Whether the four technologies should be one capability. | A monolith would activate irrelevant rules and make partial stacks impossible. | The reference registry already declares four capabilities; Delphi's registry is additive. | `resolve now`: keep four independent capabilities. |
| `AMB-02` | When a new capability may be labeled `available`. | Registry-only support would overstate Delphi's real operating ability. | Existing available capabilities point to concrete default surfaces. | `resolve now`: first register as `experimental`; promote per stack only with its canonical package and validation. |
| `AMB-03` | How to detect NestJS versus React. | Both use `package.json`; filename-only detection is ambiguous. | The current scaffold only has Composer-specific dependency matching. | `resolve now`: add generic package dependency/devDependency markers and focused fixtures. |
| `AMB-04` | Whether tenant/BU scoping belongs in the NestJS/Prisma defaults. | It is valuable when active but project-specific when unconditional. | LeadsHug rules require it globally; Delphi core says topology is project-owned. | `resolve now`: require explicit scope classification, and enforce tenant/BU only when the project declares it. |

## Story Decomposition
| Story ID | Story / User Value | Primary Module | Secondary Modules | Acceptance Boundary | Candidate Validation Signal | Candidate TODO Decision (`create-now|defer|split-further|merge-with-other`) | Dependencies / Blockers | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ST-01` | Make stack admission and detection genuinely generic, then register the four candidates honestly as experimental. | capability registry/tooling | topology scaffold/tests | Every capability block is validated; Node dependency markers avoid `package.json` false positives; four candidates are discoverable but not claimed available. | registry tests, topology fixture tests, self-check | `create-now` | none | Establishes the reusable generic layer first. |
| `ST-02` | Add reusable NestJS API/domain/worker guidance. | `rules/stacks/nestjs` | workflow/skill/tooling register | NestJS becomes available without assuming LeadsHug, Prisma, React, Railway, or tenancy unless activated. | canonical/mirror checks and bounded rule review | `defer` | ST-01 | Generalize reference API-slice material. |
| `ST-03` | Add reusable React web-slice guidance and browser evidence integration. | `rules/stacks/react` | workflow/skill/test orchestration | React becomes available with adapter boundaries, explicit async states, and project-owned browser validation. | canonical/mirror checks and Playwright-policy review | `defer` | ST-01 | Do not assume Vite or NestJS unless project-declared. |
| `ST-04` | Add reusable PostgreSQL/Prisma persistence-contract guidance. | `rules/stacks/postgres-prisma` | workflow/skill/performance/concurrency | Prisma becomes available with migration, query-scope, index/cardinality, and rollout contracts. | canonical/mirror and persistence-rule review | `defer` | ST-01 | Cross-stack consumers remain conditional. |
| `ST-05` | Add reusable Railway release-readiness guidance. | `rules/stacks/railway` | workflow/skill/runtime topology | Railway becomes available with project-owned service/environment/build/health/rollback evidence. | canonical/mirror and runtime-authority review | `defer` | ST-01 | No deployment authority is implied. |
| `ST-06` | Validate composition and retire remaining closed stack enums where they truly represent capabilities. | cross-stack governance | selected generic tools/templates | A project can activate any subset of the four capabilities without disabling existing stacks or forcing unrelated rules. | mixed-fixture topology tests and agnosticism audit | `defer` | ST-02..ST-05 | Do not widen repo-kind enums that model promotion lanes rather than capabilities. |

## Retire This Brief When
- ST-01 has an approved tactical TODO and the remaining stories are each routed to an explicit stack-specific TODO or intentionally closed.
