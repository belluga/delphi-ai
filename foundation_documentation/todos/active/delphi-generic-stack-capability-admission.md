# TODO: Generic Stack Capability Admission and Detection

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Delphi already states that capabilities are additive and do not activate themselves in downstream projects. The implementation is only partly generic: `tools/validate_stack_capabilities.py` validates required fields for a hard-coded original set, and `tools/environment_topology_contract_scaffold.py` cannot distinguish Node ecosystems by declared package dependencies.

The reference repository `unifast-tech/leadshug-engineering` at `98b8284` supplies NestJS, React, a project-convenience PostgreSQL/Prisma compound, and Railway. Delphi must model five independent capabilities—`nestjs`, `react`, `postgresql`, `prisma`, and `railway`—because Prisma supports non-PostgreSQL providers and PostgreSQL does not require Prisma. This first story builds the reusable admission/detection substrate and registers all five as `experimental`; it does not yet import or claim their stack-specific operating packages as available.

## Framing Source & Story Slice
- **Feature brief:** `foundation_documentation/artifacts/feature-briefs/delphi-multistack-capability-admission.md`
- **Primary story ID:** `ST-01`
- **Why this is the right current slice:** It removes the hard-coded admission bottleneck and prevents false-positive Node detection before any stack-specific authority is added.
- **Direct-to-TODO rationale:** `n/a; feature brief required because the initiative contains six separable stories`

## Contract Boundary
- This TODO changes only Delphi's shared typed capability-registry loader, registry validation, lifecycle-aware topology-detection model, focused tests, and the five experimental registry descriptors.
- Capability descriptors remain global availability metadata, never project activation evidence.
- Stack-specific rules, workflows, skills, CI commands, product versions, and deployment actions remain outside this slice.

## Implementation Intent
- **Current delivery:** Make admission/detection data-driven through one strict typed loader and add accurate experimental descriptors for NestJS, React, PostgreSQL, Prisma, and Railway.
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
- [ ] Introduce one strict typed registry loader shared by validator and topology detector; reject unsupported YAML forms, duplicate/unknown keys, wrong shapes, blank required values, and unknown detection-marker kinds fail-closed.
- [ ] Refactor registry validation so required fields and lifecycle values are checked for every declared capability, while preserving the required Delphi baseline capabilities.
- [ ] Define reusable Node package dependency predicates for stack detection without requiring an external YAML library.
- [ ] Detect exact package keys manifest-locally across `dependencies`, `devDependencies`, `peerDependencies`, and `optionalDependencies`; record manifest path, section, and exact package evidence.
- [ ] Build one bounded repository file inventory and manifest parse cache per scaffold run rather than rescanning once per capability.
- [ ] Carry capability lifecycle into topology output and render lifecycle, candidate evidence state, and activation validation as distinct facts.
- [ ] Add focused accepted/rejected registry fixtures for arbitrary capabilities, invalid optional blocks, forbidden activation flags, and lifecycle values.
- [ ] Add focused topology fixtures proving positive and negative NestJS/React detection, including generic Node, React Native/type-only, CLI-only, malformed, oversized, symlink, and multi-manifest cases.
- [ ] Register `nestjs`, `react`, `postgresql`, `prisma`, and `railway` as `experimental` capabilities with project-agnostic purposes, activation markers, detection markers, and execution policies.
- [ ] Preserve Docker, Flutter, Laravel, and future Go unchanged and available to their current consumers.
- [ ] Document that `experimental` means discoverable/admission-in-progress, not operationally supported or downstream-active.

## Out of Scope
- [ ] Copying any `leadshug-*` rule, project authority, workspace bootstrap, delivery-cycle tool, version pin, or Claude-specific policy.
- [ ] Adding NestJS, React, Prisma, or Railway rules/workflows/skills in this slice.
- [ ] Promoting any of the five new capabilities to `available`.
- [ ] Treating `package.json` alone as positive evidence for NestJS or React.
- [ ] Making Prisma or PostgreSQL mandatory for NestJS, NestJS mandatory for React, React mandatory for an API, or Railway mandatory for deployment.
- [ ] Expanding promotion `repo-kind`, package-query, or CI-audit enums that model a narrower concern rather than the capability registry.
- [ ] Editing downstream project or LeadsHug repositories.

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** parser/test refinements strictly required for accurate generic dependency markers and lifecycle validation.
- **Must update or split the TODO:** stack-specific instruction packages, new CI engines, package execution, runtime deployment, or broad refactors of topology reporting.

## Definition of Done
- [ ] One typed loader is the sole registry parsing boundary used by validation and topology detection.
- [ ] Topology discovery builds one repository inventory and parses every eligible manifest at most once per run, proven by deterministic counters/instrumentation rather than timing.
- [ ] Every capability declared in the registry is structurally and semantically validated, not only the original hard-coded names.
- [ ] Existing required Delphi capabilities remain required and unchanged in meaning.
- [ ] NestJS requires exact `@nestjs/core`; React web requires exact `react-dom`; all predicates remain manifest-local and reject generic Node, type-only, CLI-only, and React Native-only evidence.
- [ ] Prisma and Railway use precise file/package markers; PostgreSQL may remain detection-unknown when no reliable project-owned marker exists.
- [ ] Topology output exposes lifecycle separately and never upgrades a detected candidate to active.
- [ ] All five candidates are present as `experimental`, and no downstream activation is inferred from their presence.
- [ ] A canonical-registry test asserts the exact five new keys and their `experimental` lifecycle so optional-key validation cannot hide an omitted descriptor.
- [ ] Focused registry and topology tests pass together with `bash self_check.sh`.
- [ ] The diff contains no LeadsHug-specific authority, paths, versions, or unconditional cross-stack coupling.

## Validation Steps
- [ ] Run `bash tools/tests/validate_stack_capabilities_test.sh`.
- [ ] Run `bash tools/tests/environment_topology_contract_scaffold_test.sh`.
- [ ] Run `python3 tools/validate_stack_capabilities.py config/stack_capabilities.yaml`.
- [ ] Run topology detection against positive NestJS, positive React, and generic Node-only fixtures.
- [ ] Run deterministic scan instrumentation proving one inventory build and at-most-once parsing per eligible manifest.
- [ ] Run `bash self_check.sh`.
- [ ] Run `git diff --check`.
- [ ] Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md --repo-root .`.

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
| `delphi-ai` | `tools/lib/stack_capability_registry.py` | `A, ??` | Single strict typed loader shared by validator and detector. |
| `delphi-ai` | `tools/tests/stack_capability_registry_test.py` | `A, ??` | Parser/schema unit coverage, including fail-closed unsupported forms. |
| `delphi-ai` | `tools/validate_stack_capabilities.py` | `M` | Validate every declared capability. |
| `delphi-ai` | `tools/tests/validate_stack_capabilities_test.sh` | `M` | Registry regression coverage. |
| `delphi-ai` | `tools/environment_topology_contract_scaffold.py` | `M` | Generic Node dependency detection. |
| `delphi-ai` | `tools/tests/environment_topology_contract_scaffold_test.sh` | `M` | Positive/negative topology fixtures. |
| `delphi-ai` | `tools/manifest.md` | `M` | Tool capability description if behavior changes materially. |

### Not Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `rules/stacks/nestjs/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `rules/stacks/react/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `rules/stacks/postgresql/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `rules/stacks/prisma/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `rules/stacks/railway/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/nestjs/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/react/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/postgresql/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/prisma/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `workflows/railway/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*nestjs*/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*react*/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*postgresql*/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*prisma*/**` | `any` | Stack-specific packages belong to later stories. |
| `delphi-ai` | `skills/*railway*/**` | `any` | Stack-specific packages belong to later stories. |
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
- [x] `D-01` Model NestJS, React, PostgreSQL, Prisma, and Railway as five independent capabilities rather than one LeadsHug stack or a PostgreSQL/Prisma compound.
- [x] `D-02` Register the five Delphi candidates as `experimental` in ST-01; `available` requires a later stack-specific minimum support package.
- [x] `D-03` Keep registry presence non-activating; project-owned evidence and user validation remain authoritative.
- [x] `D-04` Detect NestJS/React from discriminating package dependencies or stack-specific companion files, never `package.json` alone.
- [x] `D-05` Validate every capability block generically while retaining an explicit required baseline set for Delphi's existing compatibility contract.
- [x] `D-06` Keep tenant/business-unit scope and cross-stack dependencies conditional on downstream declarations.
- [x] `D-07` Use one shared typed loader for validation and detection; support only a documented block-style YAML subset and reject unsupported/unknown structures fail-closed.
- [x] `D-08` Match Node packages exactly and manifest-locally across four explicit dependency sections; use `@nestjs/core` for NestJS and `react-dom` for React web.
- [x] `D-09` Inventory files and parse each manifest once per run; bound reads to repository-root files and report malformed/oversized input without exposing content.
- [x] `D-10` Carry lifecycle into topology output; detection stays `candidate` and activation stays user/project validated.

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` NestJS, React, PostgreSQL, Prisma, and Railway remain five independent capabilities; no project bundle or PostgreSQL/Prisma compound is introduced.
- [x] `D-02` All five candidates enter as `experimental`; promotion to `available` requires a later stack-specific minimum support package.
- [x] `D-03` Registry presence and detection evidence never activate a downstream stack; project-owned evidence plus user validation remain authoritative.
- [x] `D-04` `package.json` alone never identifies NestJS or React; detection requires exact discriminating package evidence.
- [x] `D-05` Every declared capability is validated uniformly while Docker, Flutter, Laravel, and Go remain the explicit compatibility baseline.
- [x] `D-06` Tenant/business-unit rules apply only when a project declares that scope model; cross-stack handoffs apply only when both capabilities are active and the change crosses their boundary.
- [x] `D-07` One documented block-style, fail-closed typed loader owns registry parsing for both validator and detector.
- [x] `D-08` Node evidence matches exact manifest-local keys in four explicit dependency sections: `@nestjs/core` for NestJS and `react-dom` for React web.
- [x] `D-09` One bounded repository inventory and manifest cache is built per run; each eligible manifest is parsed at most once and unsafe inputs yield bounded diagnostics.
- [x] `D-10` Topology renders capability lifecycle, candidate evidence state, and activation validation separately; detection never emits active state.

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** ST-01 establishes the reusable admission and detection contract that every future stack capability will use.
- **Deviation / debt being retired:** Validator and detector separately parse a permissive YAML subset; optional blocks can bypass semantic validation; lifecycle is discarded; Node stacks have no exact dependency model; repeated walks scale with capability count.
- **Target steady-state after closeout:** One typed loader validates and serves every registry block; one bounded inventory/cache evaluates precise manifest-local evidence; topology visibly separates lifecycle, candidate evidence, and activation validation.
- **Temporary exceptions allowed:** `none`
- **Cutover / removal condition:** Focused tests prove existing and new descriptors under the generic validator/detector and all five candidates remain non-activating experimental entries.

### Patterns To Enforce
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| Registry presence is not activation | `D-03` | all capabilities | Prevents global Delphi contents from becoming downstream topology claims. |
| Validate all declared capabilities | `D-05` | registry parser | Prevents optional/new blocks from escaping schema and lifecycle validation. |
| Discriminating ecosystem evidence | `D-04,D-08` | Node detection | Prevents generic `package.json` projects from being mislabeled NestJS or React. |
| Lifecycle reflects delivered support | `D-02,D-10` | new capability descriptors and topology output | Prevents `available` from becoming a registry-only marketing claim. |
| One typed registry boundary | `D-07` | validator and detector | Prevents accepted metadata from being silently ignored by a second parser. |
| Manifest-local exact evidence | `D-08` | Node detection | Prevents substring, tooling-only, React Native, and cross-workspace false positives. |

### Prohibited Anti-Patterns
| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| Hard-coded validation only for original capability names | validator intersects declared keys with a fixed set before field checks | New capabilities could be malformed without failing. | `none` |
| `package.json`-only NestJS/React detection | Node manifest existence without dependency/companion evidence | Produces broad false-positive activation candidates. | `none` |
| Project bundle namespace | one `leadshug` capability or copied project authority | Couples reusable technology support to one downstream product. | `none` |
| Premature `available` lifecycle | new descriptor has no delivered stack rule/workflow/skill package | Overstates operational support. | Promote only in the stack-specific TODO. |
| Divergent registry parsers | validator and detector decode schema independently | Allows a block to validate while the consumer drops its markers. | `none` |
| Cross-manifest predicate joins | packages from separate workspace manifests satisfy one capability | Attributes a stack to the wrong package/scope. | `none` |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| `guard` | registry schema | `tools/validate_stack_capabilities.py` | malformed optional/new capability blocks | `implement-in-this-todo` | accepted/rejected fixtures in `validate_stack_capabilities_test.sh` |
| `test` | topology detection | `tools/tests/environment_topology_contract_scaffold_test.sh` | Node false positives and missed dependency evidence | `implement-in-this-todo` | positive NestJS/React plus generic Node-only negative fixtures |
| `test` | typed registry schema | `tools/tests/stack_capability_registry_test.py` | duplicate/unknown keys, wrong shapes, unsupported YAML, lifecycle loss | `implement-in-this-todo` | table-driven accepted/rejected fixtures |
| `test` | repository inventory/cache | deterministic counters around inventory and manifest reader seams | per-capability repository walks or repeated manifest parsing | `implement-in-this-todo` | assert one inventory and one parse per eligible manifest independent of capability count |
| `rule` | activation authority | `rules/core/environment-topology-contract-model-decision.md` | registry presence treated as project activation | `already-enforced` | preserve rule and test report wording |
| `review` | project agnosticism | rejected-term scan and bounded review | LeadsHug naming, versions, paths, or mandatory cross-stack coupling | `implement-in-this-todo` | review changed Delphi surfaces before delivery |

## Architecture Review Gates
- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `findings_integrated`
- **Decision review evidence / resolution:** `/root/generic_stack_architecture_opinion found shared-loader, lifecycle, compound-persistence, Node predicate, scan-scaling, and frozen-cross-stack gaps; all were integrated into the revised contract, which requires a fresh confirmation after baseline refresh.`
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `not_run`
- **Adherence review evidence / resolution:** `implementation not authorized`
- **No-go handling:** `return to the affected decision or evidence loop; do not request APROVADO or claim delivery with unresolved architecture divergence`

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** The medium cross-module admission contract needs a stable pushed package before planning review.
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `feat/add-stack-capabilities`
- **Baseline commit:** `a94d8b22259f15b3c3f68e0c6095352e995e4e5e`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `no_material_findings`
- **Findings summary:** `The feature brief and ST-01 TODO were committed and pushed before planning review.`
- **Evidence / reference:** `git merge-base --is-ancestor a94d8b2 origin/feat/add-stack-capabilities` exit 0
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** Review-driven changes to scope, decisions, evidence, or validation must reconverge before approval.
- **Trigger stage:** `after planning review convergence and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `Context|Contract Boundary|Scope|Out of Scope|Definition of Done|Validation Steps|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan|Local CI-Equivalent Suite Matrix`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md`
- **No-go handling rule:** `refresh and push the reviewed baseline, then rerun affected planning gates before requesting approval`
- **Gate status:** `not_run`
- **Findings summary:** `Awaiting planning review convergence.`
- **Evidence / reference:** `n/a before review`
- **Waiver authority / reference (required if waived):** `n/a`

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | A strict dependency-free typed loader can replace both existing registry parsers safely. | `tools/validate_stack_capabilities.py` and `tools/environment_topology_contract_scaffold.py` consume a small block-style YAML subset; Node manifests are JSON. | Stop and adopt an explicitly approved parsing dependency or alternate canonical format. | `Medium` | `Keep as Assumption` |
| `A-02` | `experimental` accurately represents discoverable but not fully supported capabilities. | It is an allowed lifecycle and avoids overstating `available`; current activation contract already separates presence from activation. | Add a distinct lifecycle only through a separately reviewed schema decision. | `High` | `Promote to Decision` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** ST-01 depends on the current parser/detector insertion points and on the reference descriptors remaining cleanly separable from project-specific policy.
- **Trigger stage:** `after planning-side critique convergence and before APROVADO`
- **Guard scope:** `A-01`
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md`
- **Gate status:** `no_material_findings`
- **Findings summary:** `A-01 is anchored in both current parser implementations; the shared-loader approach remains feasible and no implementation claim is made.`
- **Evidence / reference:** `tools/environment_topology_contract_scaffold.py; tools/validate_stack_capabilities.py; /home/elton/Dev/repos/Clientes/Unifast/leadshug-engineering/config/stack_capabilities.yaml`
- **Waiver authority / reference (required if waived):** `n/a`

## Execution Plan
### Touched Surfaces
- `config/stack_capabilities.yaml`
- `tools/lib/stack_capability_registry.py`
- `tools/tests/stack_capability_registry_test.py`
- `tools/validate_stack_capabilities.py`
- `tools/tests/validate_stack_capabilities_test.sh`
- `tools/environment_topology_contract_scaffold.py`
- `tools/tests/environment_topology_contract_scaffold_test.sh`
- `tools/manifest.md` when its behavior description becomes stale
- this feature brief and tactical TODO

### Ordered Steps
1. Add fail-first typed-loader and topology fixtures for unsupported YAML, malformed blocks, lifecycle rendering, exact Node evidence, monorepo attribution, and bounded input failures.
2. Implement one strict typed registry loader and migrate validator/detector to it.
3. Build one bounded file inventory and JSON parse cache, preserving existing Laravel/Composer and file-marker behavior.
4. Add the five experimental descriptors with precise markers and non-activation policies; PostgreSQL may intentionally have no automatic detector until reliable evidence exists.
5. Render lifecycle, candidate state/evidence, and activation validation separately.
6. Run focused tests, self-check, diff guard, and an agnosticism review against the LeadsHug-specific terms rejected by this contract.

### Test Strategy
- **Strategy:** `test-first`
- **Why:** Registry and detection behavior are deterministic; fixtures can prove the false-positive boundary before implementation.
- **Fail-first target(s) (when required):** arbitrary invalid capability block currently passes validation; flow-style/unknown marker shapes are silently ignored; lifecycle is absent from topology output; exact NestJS/React predicates are unsupported; generic Node/type-only/CLI-only/React-Native fixtures must remain negative.

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / focused capability tests` | Registry and topology-detection behavior changes. | `python3 tools/tests/stack_capability_registry_test.py && bash tools/tests/validate_stack_capabilities_test.sh && bash tools/tests/environment_topology_contract_scaffold_test.sh` | `Local-Implemented` | `planned` | exact commands | Must cover schema rejection, lifecycle, exact evidence attribution, bounded reads, positives, and false-positive negatives. |
| `delphi-ai / self-check` | Canonical Delphi tooling and instruction surfaces must remain coherent. | `bash self_check.sh` | `Local-Implemented` | `planned` | exact command | Full Delphi self-maintenance suite. |

## Plan Review Gate
### Review Sections
- [x] Architecture
- [x] Code Quality
- [x] Tests
- [x] Performance
- [x] Security
- [x] Elegance
- [x] Structural Soundness

### Issue Cards
- **Issue `GS-01` — split PostgreSQL and Prisma (`high`).**
  - **Evidence / why now:** `schema.prisma` supports non-PostgreSQL providers and PostgreSQL does not require Prisma; freezing the compound would force later migration.
  - **Option A (chosen):** five independent capabilities. Effort `medium`; risk `low`; blast `cross-module`; maintenance `low`; performance `neutral`; elegance/structure `improves`.
  - **Option B:** keep a provider-aware composite. Effort `medium`; risk/maintenance `medium`; blast `cross-module`; performance `neutral`; elegance/structure `neutral`.
  - **Option C:** keep filename-only composite. Effort `low`; risk/maintenance `high`; performance `neutral`; elegance/structure `regresses`.
  - **Resolution:** Option A integrated into brief, decisions, descriptors, tests, and later story decomposition.
- **Issue `GS-02` — divergent permissive registry parsers (`high`).**
  - **Evidence / why now:** validator and detector independently parse different YAML subsets, allowing accepted metadata to be silently ignored by its consumer.
  - **Option A (chosen):** one strict typed loader. Effort `medium`; risk `low`; blast `cross-module`; maintenance `low`; performance/elegance/structure `improves`.
  - **Option B:** extend both parsers with parity tests. Effort `medium`; risk/maintenance `high`; performance `neutral`; elegance/structure `regresses`.
  - **Option C:** validate only top-level fields. Effort `low`; risk/maintenance `high`; elegance/structure `regresses`.
  - **Resolution:** Option A integrated into scope, diff contract, harness, tests, and execution plan.
- **Issue `GS-03` — underspecified Node/monorepo evidence (`medium`).**
  - **Evidence / why now:** loose manifest/text matching can misclassify tooling-only, React Native, or unrelated workspace packages.
  - **Option A (chosen):** exact keys in four sections, manifest-local predicates, bounded reads, one inventory/cache. Effort `medium`; risk `low`; blast `module`; maintenance `low`; performance/elegance/structure `improves`.
  - **Option B:** runtime dependencies only. Effort `low`; risk `medium` false negatives; maintenance `medium`; performance `improves`; structure `neutral`.
  - **Option C:** filename/text matching. Effort `low`; risk/maintenance `high`; performance/elegance/structure `regresses`.
  - **Resolution:** Option A frozen in `D-08/D-09` and deterministic fixtures.
- **Issue `GS-04` — broad grep tests can pass against the wrong row (`medium`).**
  - **Evidence / why now:** current shell tests can find a stack name and `candidate` in unrelated output.
  - **Option A (chosen):** table-driven typed-loader tests plus exact topology-row assertions. Effort `medium`; risk `low`; blast `module`; maintenance `low`; performance `neutral`; elegance/structure `improves`.
  - **Option B:** exact-row shell assertions only. Effort `low`; risk/maintenance `medium`; structure `neutral`.
  - **Option C:** retain broad grep. Effort `low`; risk/maintenance `high`; structure `regresses`.
  - **Resolution:** new Python test path, exact canonical-key/lifecycle assertions, and exact topology fixtures added.
- **Issue `GS-05` — lifecycle lost from topology output (`medium`).**
  - **Evidence / why now:** experimental and available candidates currently render indistinguishably.
  - **Option A (chosen):** lifecycle column beside candidate and activation validation. Effort `low`; risk `low`; blast `module`; maintenance `low`; performance `neutral`; elegance/structure `improves`.
  - **Option B:** global warning note. Effort `low`; risk `medium`; structure `neutral`.
  - **Option C:** prose only. Effort `low`; risk/maintenance `medium`; structure `regresses`.
  - **Resolution:** Option A added to scope, DoD, baseline, and fixtures.
- **Issue `GS-06` — incomplete derived governance/evidence (`medium`).**
  - **Evidence / why now:** audit floor requires critique, architecture, test-quality, final review, triple review, verification debt, and performance classification.
  - **Option A (chosen):** record every derived lane now and execute each at its gate deadline. Effort `medium`; risk `low`; blast `TODO`; maintenance `low`; performance `neutral`; elegance/structure `improves`.
  - **Option B:** defer documentation until delivery. Effort `low`; risk/maintenance `medium`; structure `regresses`.
  - **Option C:** request approval without gates. Effort `low`; risk `high`; structure `invalid`.
  - **Resolution:** exact audit decisions and deadlines are recorded below; post-implementation gates remain truthfully `not_run`.

### Failure Modes & Edge Cases
- [ ] Scoped dependency names in `package.json` are parsed without substring false positives.
- [ ] Dependencies in `dependencies`, `devDependencies`, `peerDependencies`, and `optionalDependencies` follow an explicit tested policy.
- [ ] Malformed or unreadable JSON yields bounded unknown evidence rather than guessed activation.
- [ ] A monorepo can expose different capabilities in different nested manifests without one manifest labeling every package.
- [ ] Existing Composer/Laravel and file-marker detection remains unchanged.

### Residual Unknowns / Risks
- [x] `nest-cli.json` alone is insufficient; exact `@nestjs/core` is the NestJS candidate predicate.
- [x] `react` alone is insufficient for React web; exact `react-dom` is the ST-01 candidate predicate. Broader web-family frameworks require a later explicit marker extension.

## Audit Trigger Matrix
- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md`
- **Latest TEACH evidence / artifact:** `artifacts/tmp/generic-stack-admission-audit-round2.json; overall go; triple review required after high-severity planning findings`

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | Matches the TODO complexity classification. |
| `blast_radius` | `cross-module` | Registry validation and topology detection share the contract. |
| `behavioral_change_or_bugfix` | `yes` | Deterministic validation/detection behavior changes. |
| `changes_public_contract` | `yes` | Capability descriptor validation and marker semantics are public Delphi contracts. |
| `touches_auth_or_tenant` | `no` | Tenant/BU semantics are explicitly excluded from ST-01. |
| `touches_runtime_or_infra` | `no` | No runtime, deployment, or infrastructure mutation occurs. |
| `touches_tests` | `yes` | Focused deterministic fixtures change. |
| `critical_user_journey` | `no` | No downstream UI or product flow changes. |
| `release_or_promotion_critical` | `yes` | Incorrect availability/detection claims would contaminate future project setup. |
| `high_severity_plan_review_issue` | `yes` | GS-01 and GS-02 were high-severity approval blockers and are being integrated before reconvergence. |
| `explicit_three_lane_request` | `no` | The user requested the normal Delphi admission process. |

## Independent No-Context Critique Gate
- **Critique decision:** `required`
- **Why this decision:** Medium cross-module public-contract work needs an independent challenge before approval.
- **Impact signals in scope:** `cross-module blast radius|public capability contract`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `feature brief|TODO|current registry validator/detector|reference descriptors|known rejected project-specific terms`
- **Critique isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; /root/generic_stack_plan_critique completed the first round; a fresh confirmation is required after baseline refresh`
- **Canonical multi-lane audit protocol (when required):** `audit-protocol-triple-review; rerun audit escalation after high-severity integration to confirm the floor`
- **Audit session / round evidence (when protocol used):** `n/a`
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`
- **Critique status:** `findings_integrated`
- **Findings summary:** `GS-01 through GS-06 were integrated; approval remains blocked until refreshed-baseline confirmation and derived gates pass.`
- **Resolution ledger:**
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `GS-01` | `Integrated` | `useful` | `yes` | `paced` | `n/a` | PostgreSQL and Prisma are independent capabilities; the brief and TODO now contain five candidates. |
| `GS-02` | `Integrated` | `useful` | `yes` | `paced` | One typed fail-closed loader is now required and classified in the diff/harness. |
| `GS-03` | `Integrated` | `useful` | `yes` | `paced` | Exact manifest-local package/section semantics and bounded input behavior are frozen. |
| `GS-04` | `Integrated` | `useful` | `yes` | `paced` | A table-driven typed-loader test plus exact topology fixtures replace broad-only evidence. |
| `GS-05` | `Integrated` | `useful` | `yes` | `paced` | Lifecycle is carried into every topology row and remains distinct from activation. |
| `GS-06` | `Integrated` | `useful` | `partial` | `paced` | Planning and delivery audit records are being completed before approval. |
- **Evidence / reference:** `/root/generic_stack_plan_critique final findings; revised brief and TODO`
- **Waiver authority / reference (required if waived):** `n/a`

## Security Risk Assessment
- **Risk level:** `low`
- **Why this risk level:** The loader reads repository-owned metadata but executes nothing; malformed, oversized, or out-of-root inputs require bounded handling.
- **Attack surface in scope:** `registry and package-manifest parsing only`
- **Attack simulation decision:** `not_needed` per audit floor; focused hostile-input fixtures remain required.
- **Review evidence:** `planned typed-loader and topology fixtures for malformed/oversized/symlinked inputs`
- **Residual security risk:** `parser denial-of-service or content leakage if read bounds/diagnostics are implemented incorrectly`

## Performance & Concurrency Risk Assessment
- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** No runtime product path changes; the only performance concern is repeated repository traversal during a local scaffold command.
- **Current delivery stage at review time:** `Pending`
- **Evaluation timestamp / evaluator:** `2026-09-16 / root planning lane`
- **Decision rationale:** Product-runtime performance lanes are absent, but the local repository batch-scan path requires a recommended RLS-style scalability check resolved through deterministic inventory/parse counters rather than load generation.
| Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `EPS` | `endpoint-performance-scrutiny` | `not_needed` | `low` | `no-endpoint-surface` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `FRC` | `frontend-race-condition-validation` | `not_needed` | `low` | `no-frontend-runtime` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `BCI` | `backend-concurrency-idempotency-validation` | `not_needed` | `low` | `no-backend-mutation` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `RLS` | `runtime-load-stress-validation` | `recommended` | `medium` | `RLS-BATCH-OR-BULK-PATH-CHANGED` | `before_local_implemented` | `deterministic counter proves one inventory and at-most-once manifest parsing as capability count grows` | `planned` | `repository scan could scale as capabilities × files if the cache is bypassed` | `implementation-not-started` |

## Verification Debt Assessment
- **Audit outcome:** `not_run`
- **Why this outcome:** Required before completion; implementation has not begun.
- **Inline code TODO debt:** `none planned`
- **Evidence / audit artifact:** `pending post-implementation verification-debt audit`
- **Accepted residual debt:** `none before implementation`

## Independent Test Quality Audit Gate
- **Audit decision:** `required`
- **Why this decision:** The audit floor is full because deterministic parser/detector behavior and tests change.
- **Trigger signals in scope:** `changed test logic|behavior-defining change|public contract|non-trivial validation risk`
- **Required evidence matrix (when architectural):** `typed loader unit fixtures|registry integration|topology integration|n/a for product runtime`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `frozen baseline|approved scope|implementation diff|test diff|fail-first evidence|validation outputs|residual risks`
- **Canonical method:** `wf-docker-independent-test-quality-audit-method`
- **Audit isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required after implementation`
- **Gate-satisfying evidence expectation:** `full independent audit of schema, predicate, negative, attribution, and bounded-input fixtures`
- **Audit focus:** `fail-first alignment|assertion efficacy|coverage sufficiency|bypass detection|fixture realism`
- **Required applicable evidence:** `test output plus direct review of exact-row/typed assertions`
- **Audit status:** `not_run`
- **Findings summary:** `Implementation not authorized.`
- **Resolution ledger:** `none before audit`
- **Evidence / reference:** `n/a before implementation`
- **Waiver authority / reference (required if waived):** `n/a`

## Independent No-Context Final Review Gate
- **Final review decision:** `required`
- **Why this decision:** The audit floor requires expanded final review for this public cross-module capability contract.
- **Impact signals in scope:** `cross-module blast radius|public capability schema|high-severity planning findings`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `approved contract|implementation/test diff|architecture adherence|test-quality audit|verification debt|residual risks`
- **Review isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required after implementation`
- **Canonical multi-lane audit protocol (when required):** `audit-protocol-triple-review; required before completion by refreshed audit escalation`
- **Audit session / round evidence (when protocol used):** `pending`
- **Review focus:** `adherence|regressions|validation evidence|security/performance residuals|elegance|structural soundness`
- **Final review status:** `not_run`
- **Findings summary:** `Implementation not authorized.`
- **Resolution ledger:** `none before review`
- **Evidence / reference:** `n/a before implementation`
- **Waiver authority / reference (required if waived):** `n/a`

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | Defines additive capabilities and project-owned activation. | Capability/activation separation and agnostic core. | Project truth in Delphi registry. | Keep descriptors non-activating. |
| `rules/core/environment-topology-contract-model-decision.md` | Governs detection evidence and downstream validation. | Project-owned topology authority. | Inferring activation from Delphi files. | Detection remains candidate evidence only. |
| `workflows/docker/environment-topology-contract-method.md` | Owns topology discovery semantics. | Explicit user validation for inferred stack candidates. | Silent activation. | Preserve report language and tests. |
| `workflows/docker/self-improvement-session-method.md` | This is Delphi instruction/tooling maintenance. | Agnosticism and instruction-only boundary. | Downstream edits. | Limit all changes to Delphi. |
| `workflows/docker/todo-driven-execution-method.md` | Durable tooling behavior requires approved TODO execution. | Approval, strict diff, evidence. | Implementation before APROVADO. | Stop after approval-ready planning. |

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-terra`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Subagent / delegation authorization:** `not-requested`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Worktree authorization evidence:** `n/a`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a`

## Authorization Note
- **Implementation authorization:** `none until explicit APROVADO`
- **Approval status:** `unapproved`
- **No implementation statement:** Creating this brief/TODO begins the admission process but does not authorize ST-01 implementation or any stack-specific port.
