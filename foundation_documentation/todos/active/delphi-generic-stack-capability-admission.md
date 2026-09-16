# TODO: Generic Stack Capability Admission and Detection

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Delphi already states that capabilities are additive and do not activate themselves in downstream projects. The implementation is only partly generic: `tools/validate_stack_capabilities.py` validates required fields for a hard-coded original set, and `tools/environment_topology_contract_scaffold.py` cannot distinguish Node ecosystems by declared package dependencies.

The reference repository `unifast-tech/leadshug-engineering` at `98b8284` supplies four candidate capabilities: `nestjs`, `react`, `postgres-prisma`, and `railway`. They must enter Delphi as independent, project-agnostic capabilities. This first story builds the reusable admission/detection substrate and registers them as `experimental`; it does not yet import or claim their stack-specific operating packages as available.

## Framing Source & Story Slice
- **Feature brief:** `foundation_documentation/artifacts/feature-briefs/delphi-multistack-capability-admission.md`
- **Primary story ID:** `ST-01`
- **Why this is the right current slice:** It removes the hard-coded admission bottleneck and prevents false-positive Node detection before any stack-specific authority is added.
- **Direct-to-TODO rationale:** `n/a; feature brief required because the initiative contains six separable stories`

## Contract Boundary
- This TODO changes only Delphi's generic capability registry validation, topology-detection model, focused tests, and the four experimental registry descriptors.
- Capability descriptors remain global availability metadata, never project activation evidence.
- Stack-specific rules, workflows, skills, CI commands, product versions, and deployment actions remain outside this slice.

## Implementation Intent
- **Current delivery:** Make admission/detection data-driven and add accurate experimental descriptors for NestJS, React, PostgreSQL/Prisma, and Railway.
- **Planned next steps:** Refine and approve separate stack-specific TODOs; promote each capability from `experimental` to `available` only when its minimum support package passes delivery gates.
- **Anticipatory implementation authorized now:** `none before explicit APROVADO`
- **Rationale:** A registry entry must not overstate operational support, and filename-only Node detection is too ambiguous.

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** `run planning-side review and request explicit APROVADO for ST-01`

## Active Work State
- **Work state:** `review`
- **Why this state now:** Discovery and story decomposition are complete; the bounded first-slice contract awaits plan review and user approval.
- **Exit condition:** The TODO is approved for implementation, revised after review, or explicitly closed.

## Scope
- [ ] Refactor registry validation so required fields and lifecycle values are checked for every declared capability, while preserving the required Delphi baseline capabilities.
- [ ] Define reusable Node package dependency markers for stack detection without requiring an external YAML library.
- [ ] Detect package dependencies across the relevant `package.json` dependency sections without treating every Node project as NestJS or React.
- [ ] Add focused accepted/rejected registry fixtures for arbitrary capabilities, invalid optional blocks, forbidden activation flags, and lifecycle values.
- [ ] Add focused topology fixtures proving positive and negative NestJS/React detection, including a generic Node-only project that activates neither.
- [ ] Register `nestjs`, `react`, `postgres-prisma`, and `railway` as `experimental` capabilities with project-agnostic purposes, activation markers, detection markers, and execution policies.
- [ ] Preserve Docker, Flutter, Laravel, and future Go unchanged and available to their current consumers.
- [ ] Document that `experimental` means discoverable/admission-in-progress, not operationally supported or downstream-active.

## Out of Scope
- [ ] Copying any `leadshug-*` rule, project authority, workspace bootstrap, delivery-cycle tool, version pin, or Claude-specific policy.
- [ ] Adding NestJS, React, Prisma, or Railway rules/workflows/skills in this slice.
- [ ] Promoting any of the four new capabilities to `available`.
- [ ] Treating `package.json` alone as positive evidence for NestJS or React.
- [ ] Making Prisma mandatory for NestJS, NestJS mandatory for React, React mandatory for an API, or Railway mandatory for deployment.
- [ ] Expanding promotion `repo-kind`, package-query, or CI-audit enums that model a narrower concern rather than the capability registry.
- [ ] Editing downstream project or LeadsHug repositories.

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** parser/test refinements strictly required for accurate generic dependency markers and lifecycle validation.
- **Must update or split the TODO:** stack-specific instruction packages, new CI engines, package execution, runtime deployment, or broad refactors of topology reporting.

## Definition of Done
- [ ] Every capability declared in the registry is structurally and semantically validated, not only the original hard-coded names.
- [ ] Existing required Delphi capabilities remain required and unchanged in meaning.
- [ ] NestJS and React detection requires discriminating package evidence and rejects generic Node-only fixtures.
- [ ] Prisma and Railway detection uses precise project-owned markers.
- [ ] All four candidates are present as `experimental`, and no downstream activation is inferred from their presence.
- [ ] Focused registry and topology tests pass together with `bash self_check.sh`.
- [ ] The diff contains no LeadsHug-specific authority, paths, versions, or unconditional cross-stack coupling.

## Validation Steps
- [ ] Run `bash tools/tests/validate_stack_capabilities_test.sh`.
- [ ] Run `bash tools/tests/environment_topology_contract_scaffold_test.sh`.
- [ ] Run `python3 tools/validate_stack_capabilities.py config/stack_capabilities.yaml`.
- [ ] Run topology detection against positive NestJS, positive React, and generic Node-only fixtures.
- [ ] Run `bash self_check.sh`.
- [ ] Run `git diff --check`.

## Diff Expectation Contract
- **Contract status:** `required`
- **Policy:** `strict; unclassified or forbidden paths block delivery`
- **User validation:** `required on deviation`
- **Comparison mode:** `working_tree`

### Repository Baselines
| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| `delphi-ai` | `.` | `feat/add-stack-capabilities@58b4107` | `working_tree` |

### Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `foundation_documentation/artifacts/feature-briefs/delphi-multistack-capability-admission.md` | `A, ??` | Non-authoritative initiative decomposition. |
| `delphi-ai` | `foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md` | `A, M, ??` | Governing ST-01 contract and evidence. |
| `delphi-ai` | `config/stack_capabilities.yaml` | `M` | Experimental descriptors and generic marker schema. |
| `delphi-ai` | `tools/validate_stack_capabilities.py` | `M` | Validate every declared capability. |
| `delphi-ai` | `tools/tests/validate_stack_capabilities_test.sh` | `M` | Registry regression coverage. |
| `delphi-ai` | `tools/environment_topology_contract_scaffold.py` | `M` | Generic Node dependency detection. |
| `delphi-ai` | `tools/tests/environment_topology_contract_scaffold_test.sh` | `M` | Positive/negative topology fixtures. |
| `delphi-ai` | `tools/manifest.md` | `M` | Tool capability description if behavior changes materially. |

### Not Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `rules/stacks/{nestjs,react,postgres-prisma,railway}/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/{nestjs,react,postgres-prisma,railway}/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*{nestjs,react,prisma,railway}*/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `.github/workflows/**` | `any` | No CI engine is admitted by ST-01. |
| `delphi-ai` | `tools/bootstrap_stack.sh` | `any` | Bootstrap redesign is separate from registry/detection admission. |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder|assurance-tester-quality`
- **Scope-check command:** `n/a - standalone Delphi self-maintenance`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The slice is Delphi-local and deterministic but changes the registry schema contract, two validators/detectors, and their fixtures.

## Canonical Module Anchors
- **Primary module doc:** `config/stack_capabilities.yaml`
- **Secondary module docs (if any):**
  - `tools/validate_stack_capabilities.py`
  - `tools/environment_topology_contract_scaffold.py`
  - `rules/core/environment-topology-contract-model-decision.md`
- **Planned decision promotion targets (module sections):** capability lifecycle semantics and detection-marker schema in `config/stack_capabilities.yaml`
- **Module decision consolidation targets (required):** `config/stack_capabilities.yaml` comments/contracts and tool tests

## Decisions (Resolved Before Freeze)
- [x] `D-01` Model NestJS, React, PostgreSQL/Prisma, and Railway as four independent capabilities rather than one LeadsHug stack.
- [x] `D-02` Register the four candidates as `experimental` in ST-01; `available` requires a later stack-specific minimum support package.
- [x] `D-03` Keep registry presence non-activating; project-owned evidence and user validation remain authoritative.
- [x] `D-04` Detect NestJS/React from discriminating package dependencies or stack-specific companion files, never `package.json` alone.
- [x] `D-05` Validate every capability block generically while retaining an explicit required baseline set for Delphi's existing compatibility contract.
- [x] `D-06` Keep tenant/business-unit scope and cross-stack dependencies conditional on downstream declarations.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Dependency-name matching can extend the existing dependency-free registry parser safely. | Composer markers are already parsed without PyYAML in `tools/environment_topology_contract_scaffold.py`; Node manifests are JSON. | Split detection into a dedicated parser/helper before adding candidates. | `High` | `Keep as Assumption` |
| `A-02` | `experimental` accurately represents discoverable but not fully supported capabilities. | It is an allowed lifecycle and avoids overstating `available`; current activation contract already separates presence from activation. | Add a distinct lifecycle only through a separately reviewed schema decision. | `High` | `Promote to Decision` |
| `A-03` | The four reference capability descriptors can be generalized without importing project authority. | The reusable cores are short; project-specific terms are identifiable by repository-wide search. | Stop and split any capability whose semantics cannot be made project-agnostic. | `High` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** ST-01 depends on the current parser/detector insertion points and on the reference descriptors remaining cleanly separable from project-specific policy.
- **Trigger stage:** `after planning-side critique convergence and before APROVADO`
- **Guard scope:** `A-01,A-03`
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md`
- **Gate status:** `not_run`
- **Findings summary:** `Awaiting the planning-side review baseline; no implementation claim is made.`
- **Evidence / reference:** `tools/environment_topology_contract_scaffold.py; tools/validate_stack_capabilities.py; /home/elton/Dev/repos/Clientes/Unifast/leadshug-engineering/config/stack_capabilities.yaml`
- **Waiver authority / reference (required if waived):** `n/a`

## Execution Plan
### Touched Surfaces
- `config/stack_capabilities.yaml`
- `tools/validate_stack_capabilities.py`
- `tools/tests/validate_stack_capabilities_test.sh`
- `tools/environment_topology_contract_scaffold.py`
- `tools/tests/environment_topology_contract_scaffold_test.sh`
- `tools/manifest.md` when its behavior description becomes stale
- this feature brief and tactical TODO

### Ordered Steps
1. Extend registry validation to validate every capability block and test invalid non-baseline capabilities.
2. Extend detection-marker parsing with generic package dependency categories and JSON manifest matching.
3. Add fail-first positive/negative Node topology fixtures, including generic Node-only evidence.
4. Add the four experimental descriptors with precise markers and non-activation policies.
5. Run focused tests, self-check, diff guard, and an agnosticism review against the LeadsHug-specific terms rejected by this contract.

### Test Strategy
- **Strategy:** `test-first`
- **Why:** Registry and detection behavior are deterministic; fixtures can prove the false-positive boundary before implementation.
- **Fail-first target(s) (when required):** arbitrary invalid capability block currently passes validation; NestJS/React dependency markers are currently unsupported; generic Node-only fixture must remain negative.

## Authorization Note
- **Implementation authorization:** `none until explicit APROVADO`
- **Approval status:** `unapproved`
- **No implementation statement:** Creating this brief/TODO begins the admission process but does not authorize ST-01 implementation or any stack-specific port.
