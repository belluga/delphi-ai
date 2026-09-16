# Feature Brief: Delphi Multi-Stack Capability Admission

## Artifact Role
- **Why this brief exists now:** The reference engineering repository combines NestJS, React, PostgreSQL/Prisma, and Railway. A generic Delphi model must decompose that reference bundle into five independently activatable capabilities—NestJS, React, PostgreSQL, Prisma, and Railway—then supply a generic capability substrate plus stack-specific packages.
- **What this brief is not:** This is not a canonical architecture source, a tactical TODO, or implementation authority.

## Source Idea / Request
- Compare Delphi with `unifast-tech/leadshug-engineering` at `98b8284` and evolve Delphi so it can support the new stack while preserving a generic core and stack-specific modules.

## Problem / Desired Outcome
- **Problem:** Delphi's registry is conceptually additive, but validation still hard-codes the original capability set, validator and detector use divergent permissive parsers, topology output drops capability lifecycle, and Node detection cannot distinguish stacks by exact `package.json` dependencies. Copying the reference repository directly would also import LeadsHug-specific authority and an ambiguous `postgres-prisma` compound identity.
- **Desired outcome:** Delphi can discover and support NestJS, React, PostgreSQL, Prisma, and Railway as independent capabilities, compose them when a downstream project activates several, and keep all product topology in project-owned contracts.
- **Why now:** The current branch is explicitly dedicated to adding stack capabilities, and the reference repository supplies concrete candidate rules/workflows that can be generalized instead of reinvented.

## Constraints / Non-Goals
- **Constraints:** Use one strict typed registry loader; keep capability lifecycle, detection evidence, and downstream activation distinct; validate every registry entry; avoid `package.json`-only detection; keep cross-stack references conditional; preserve Docker, Flutter, Laravel, and future Go; require a minimal canonical rule/workflow/skill package before a capability becomes `available`.
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
- `leadshug-engineering/config/stack_capabilities.yaml` declares `nestjs`, `react`, a project-convenience `postgres-prisma` compound, and `railway`; Delphi must split the compound because `schema.prisma` neither proves PostgreSQL nor covers PostgreSQL without Prisma.
- The reference stack rules/workflows have reusable architecture cores, but `leadshug-*` names, direct LeadsHug references, unconditional `tenant/BU`, and fixed React/NestJS/Prisma/Railway coupling must be removed or made project-conditional.

## Ambiguities To Resolve Before TODO
| ID | Ambiguity | Why It Matters | Current Evidence | Handling (`resolve now|carry as TODO assumption|block`) |
| --- | --- | --- | --- | --- |
| `AMB-01` | Whether PostgreSQL and Prisma should remain one reference-derived capability. | Prisma supports non-PostgreSQL providers and PostgreSQL does not require Prisma. | `schema.prisma` proves neither half of the compound; project composition is already downstream-owned. | `resolve now`: split into five independent capabilities. |
| `AMB-02` | When a new capability may be labeled `available`. | Registry-only support would overstate Delphi's real operating ability. | Existing available capabilities point to concrete default surfaces. | `resolve now`: first register as `experimental`; promote per stack only with its canonical package and validation. |
| `AMB-03` | How to detect NestJS versus React. | Both use `package.json`; filename-only and loose text detection are ambiguous. | The current scaffold only has a raw Composer text scan. | `resolve now`: exact manifest-local package predicates; `@nestjs/core` for NestJS and `react-dom` for React web. |
| `AMB-04` | Whether tenant/BU scoping belongs in the NestJS/Prisma defaults. | It is valuable when active but project-specific when unconditional. | LeadsHug rules require it globally; Delphi core says topology is project-owned. | `resolve now`: require explicit scope classification, and enforce tenant/BU only when the project declares it. |

## Story Decomposition
| Story ID | Story / User Value | Primary Module | Secondary Modules | Acceptance Boundary | Candidate Validation Signal | Candidate TODO Decision (`create-now|defer|split-further|merge-with-other`) | Dependencies / Blockers | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ST-01` | Make stack admission and detection genuinely generic, then register the five candidates honestly as experimental. | capability registry/tooling | topology scaffold/tests | One typed loader validates every block and feeds lifecycle-aware detection; exact Node predicates avoid false positives; five candidates are registered but not claimed available. | typed-loader tests, registry tests, topology fixture tests, self-check | `create-now` | none | Establishes the reusable generic layer first. |
| `ST-02` | Add reusable NestJS API/domain/worker guidance. | `rules/stacks/nestjs` | workflow/skill/tooling register | NestJS becomes available without assuming LeadsHug, Prisma, React, Railway, or tenancy unless activated. | canonical/mirror checks and bounded rule review | `defer` | ST-01 | Generalize reference API-slice material. |
| `ST-03` | Add reusable React web-slice guidance and browser evidence integration. | `rules/stacks/react` | workflow/skill/test orchestration | React becomes available with adapter boundaries, explicit async states, and project-owned browser validation. | canonical/mirror checks and Playwright-policy review | `defer` | ST-01 | Do not assume Vite or NestJS unless project-declared. |
| `ST-04` | Add reusable PostgreSQL persistence guidance. | `rules/stacks/postgresql` | workflow/skill/performance/concurrency | PostgreSQL becomes available without assuming Prisma or a specific application framework. | canonical/mirror and persistence-rule review | `defer` | ST-01 | Automatic detection may remain unknown when no reliable marker exists; project-owned activation is authoritative. |
| `ST-05` | Add reusable Prisma persistence-contract guidance. | `rules/stacks/prisma` | workflow/skill/performance/concurrency | Prisma becomes available with migration, provider, query-scope, generated-client, and rollout contracts. | canonical/mirror and persistence-rule review | `defer` | ST-01 | Database-provider capability remains independently activated. |
| `ST-06` | Add reusable Railway release-readiness guidance. | `rules/stacks/railway` | workflow/skill/runtime topology | Railway becomes available with project-owned service/environment/build/health/rollback evidence. | canonical/mirror and runtime-authority review | `defer` | ST-01 | No deployment authority is implied. |
| `ST-07` | Validate composition and retire remaining closed stack enums where they truly represent capabilities. | cross-stack governance | selected generic tools/templates | A project can activate any subset of the five capabilities without disabling existing stacks or forcing unrelated rules. | mixed-fixture topology tests and agnosticism audit | `defer` | ST-02..ST-06 | Do not widen repo-kind enums that model promotion lanes rather than capabilities. |

## Retire This Brief When
- ST-01 has an approved tactical TODO and the remaining stories are each routed to an explicit stack-specific TODO or intentionally closed.
