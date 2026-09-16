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
- **Direct-to-TODO rationale:** `n/a; feature brief required because the initiative contains seven separable stories`

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
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** `await explicit user approval for promotion of feat/add-stack-capabilities into main`

## Active Work State
- **Work state:** `review`
- **Why this state now:** The approved implementation, bounded remediation, focused tests, canonical validator, self-check, diff check, and strict diff guard pass.
- **Exit condition:** Commit/push the current validated branch state or reopen only for a concrete regression.

## Scope
- [x] Introduce one strict typed registry loader shared by validator and topology detector; reject unsupported YAML forms, duplicate/unknown keys, wrong shapes, blank required values, and unknown detection-marker kinds fail-closed.
- [x] Refactor registry validation so required fields and lifecycle values are checked for every declared capability, while preserving the required Delphi baseline capabilities.
- [x] Define reusable Node package dependency predicates for stack detection without requiring an external YAML library.
- [x] Detect exact package keys manifest-locally across `dependencies`, `devDependencies`, `peerDependencies`, and `optionalDependencies`; record manifest path, section, and exact package evidence.
- [x] Build one bounded repository file inventory and manifest parse cache per scaffold run rather than rescanning once per capability.
- [x] Carry capability lifecycle into topology output and render lifecycle, candidate evidence state, and activation validation as distinct facts.
- [x] Add focused accepted/rejected registry fixtures for arbitrary capabilities, invalid optional blocks, forbidden activation flags, and lifecycle values.
- [x] Add focused topology fixtures proving positive and negative NestJS/React detection, including generic Node, React Native/type-only, CLI-only, malformed, oversized, symlink, and multi-manifest cases.
- [x] Register `nestjs`, `react`, `postgresql`, `prisma`, and `railway` as `experimental` capabilities with project-agnostic purposes, activation markers, detection markers, and execution policies.
- [x] Preserve Docker, Flutter, Laravel, and future Go unchanged and available to their current consumers.
- [x] Document that `experimental` means discoverable/admission-in-progress, not operationally supported or downstream-active.

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
- [x] One typed loader is the sole registry parsing boundary used by validation and topology detection.
- [x] Topology discovery builds one repository inventory and parses every eligible manifest at most once per run, proven by deterministic counters/instrumentation rather than timing.
- [x] Every capability declared in the registry is structurally and semantically validated, not only the original hard-coded names.
- [x] Existing required Delphi capabilities remain required and unchanged in meaning.
- [x] NestJS requires exact `@nestjs/core`; React web requires exact `react-dom`; all predicates remain manifest-local and reject generic Node, type-only, CLI-only, and React Native-only evidence.
- [x] Prisma and Railway use precise file/package markers; PostgreSQL may remain detection-unknown when no reliable project-owned marker exists.
- [x] Topology output exposes lifecycle separately and never upgrades a detected candidate to active.
- [x] All five candidates are present as `experimental`, and no downstream activation is inferred from their presence.
- [x] A canonical-registry test asserts the exact five new keys and their `experimental` lifecycle so optional-key validation cannot hide an omitted descriptor.
- [x] Focused registry and topology tests pass together with `bash self_check.sh`.
- [x] The diff contains no LeadsHug-specific authority, paths, versions, or unconditional cross-stack coupling.

## Validation Steps
- [x] Run `bash tools/tests/validate_stack_capabilities_test.sh`.
- [x] Run `bash tools/tests/environment_topology_contract_scaffold_test.sh`.
- [x] Run `python3 tools/validate_stack_capabilities.py config/stack_capabilities.yaml`.
- [x] Run topology detection against positive NestJS, positive React, and generic Node-only fixtures.
- [x] Run deterministic scan instrumentation proving one inventory build and at-most-once parsing per eligible manifest.
- [x] Run `bash self_check.sh`.
- [x] Run `git diff --check`.
- [x] Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md --repo-root .`.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCP-01` | `Scope` | Introduce one strict typed registry loader shared by validator and topology detector; reject unsupported YAML forms, duplicate/unknown keys, wrong shapes, blank required values, and unknown detection-marker kinds fail-closed. | `code+test` | shared loader and 10 loader tests | `local` | `passed` | One fail-closed boundary. |
| `SCP-02` | `Scope` | Refactor registry validation so required fields and lifecycle values are checked for every declared capability, while preserving the required Delphi baseline capabilities. | `test` | generic and missing-baseline fixtures | `local` | `passed` | Arbitrary blocks validated. |
| `SCP-03` | `Scope` | Define reusable Node package dependency predicates for stack detection without requiring an external YAML library. | `code+test` | shared loader and topology fixtures | `local` | `passed` | Dependency-free implementation. |
| `SCP-04` | `Scope` | Detect exact package keys manifest-locally across `dependencies`, `devDependencies`, `peerDependencies`, and `optionalDependencies`; record manifest path, section, and exact package evidence. | `test` | exact topology rows | `local` | `passed` | Four sections covered. |
| `SCP-05` | `Scope` | Build one bounded repository file inventory and manifest parse cache per scaffold run rather than rescanning once per capability. | `test` | inventory/parse counters | `local` | `passed` | One build and at-most-once parsing. |
| `SCP-06` | `Scope` | Carry capability lifecycle into topology output and render lifecycle, candidate evidence state, and activation validation as distinct facts. | `test` | rendered table assertions | `local` | `passed` | Facts remain separate. |
| `SCP-07` | `Scope` | Add focused accepted/rejected registry fixtures for arbitrary capabilities, invalid optional blocks, forbidden activation flags, and lifecycle values. | `test` | loader and CLI integration suites | `local` | `passed` | Rejection families covered. |
| `SCP-08` | `Scope` | Add focused topology fixtures proving positive and negative NestJS/React detection, including generic Node, React Native/type-only, CLI-only, malformed, oversized, symlink, and multi-manifest cases. | `test` | topology matrix | `local` | `passed` | Exact positive/negative cases. |
| `SCP-09` | `Scope` | Register `nestjs`, `react`, `postgresql`, `prisma`, and `railway` as `experimental` capabilities with project-agnostic purposes, activation markers, detection markers, and execution policies. | `code+test` | registry diff and exact-set assertion | `local` | `passed` | Five descriptors. |
| `SCP-10` | `Scope` | Preserve Docker, Flutter, Laravel, and future Go unchanged and available to their current consumers. | `test` | baseline requirement and Laravel compatibility fixtures | `local` | `passed` | Existing baseline preserved. |
| `SCP-11` | `Scope` | Document that `experimental` means discoverable/admission-in-progress, not operationally supported or downstream-active. | `doc+test` | registry policies, manifest, topology wording | `local` | `passed` | No activation inference. |
| `DOD-01` | `Definition of Done` | One typed loader is the sole registry parsing boundary used by validation and topology detection. | `code+test` | shared imports and focused suite | `local` | `passed` | Sole parsing boundary; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `DOD-02` | `Definition of Done` | Topology discovery builds one repository inventory and parses every eligible manifest at most once per run, proven by deterministic counters/instrumentation rather than timing. | `test` | topology fixture counters | `local` | `passed` | Deterministic proof; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `DOD-03` | `Definition of Done` | Every capability declared in the registry is structurally and semantically validated, not only the original hard-coded names. | `test` | 10 loader tests plus CLI integration | `local` | `passed` | Generic validation; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `DOD-04` | `Definition of Done` | Existing required Delphi capabilities remain required and unchanged in meaning. | `test` | missing-baseline and Laravel exact-evidence fixtures | `local` | `passed` | Baseline preserved; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `DOD-05` | `Definition of Done` | NestJS requires exact `@nestjs/core`; React web requires exact `react-dom`; all predicates remain manifest-local and reject generic Node, type-only, CLI-only, and React Native-only evidence. | `test` | React web topology matrix with exact `react-dom` and NestJS `@nestjs/core` assertions | `local` | `passed` | Near matches negative. |
| `DOD-06` | `Definition of Done` | Prisma and Railway use precise file/package markers; PostgreSQL may remain detection-unknown when no reliable project-owned marker exists. | `test` | default-registry fixtures | `local` | `passed` | Precise markers and unknown state. |
| `DOD-07` | `Definition of Done` | Topology output exposes lifecycle separately and never upgrades a detected candidate to active. | `test` | topology table assertions | `local` | `passed` | No active state. |
| `DOD-08` | `Definition of Done` | All five candidates are present as `experimental`, and no downstream activation is inferred from their presence. | `test` | canonical experimental-set assertion | `local` | `passed` | Exact set. |
| `DOD-09` | `Definition of Done` | A canonical-registry test asserts the exact five new keys and their `experimental` lifecycle so optional-key validation cannot hide an omitted descriptor. | `test` | `test_canonical_registry_contains_exact_experimental_candidates` | `local` | `passed` | Exact assertion; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `DOD-10` | `Definition of Done` | Focused registry and topology tests pass together with `bash self_check.sh`. | `test` | focused scripts and self-check | `local` | `passed` | All exit 0. |
| `DOD-11` | `Definition of Done` | The diff contains no LeadsHug-specific authority, paths, versions, or unconditional cross-stack coupling. | `review` | bounded diff review | `local` | `passed` | Project-agnostic. |
| `VAL-01` | `Validation Steps` | Run `bash tools/tests/validate_stack_capabilities_test.sh`. | `test` | exact command | `local` | `passed` | Exit 0; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `VAL-02` | `Validation Steps` | Run `bash tools/tests/environment_topology_contract_scaffold_test.sh`. | `test` | exact command | `local` | `passed` | Exit 0. |
| `VAL-03` | `Validation Steps` | Run `python3 tools/validate_stack_capabilities.py config/stack_capabilities.yaml`. | `test` | exact command | `local` | `passed` | Canonical registry valid; approved structure-only waiver: integration test coverage is inapplicable because no user-observable flow can change. |
| `VAL-04` | `Validation Steps` | Run topology detection against positive NestJS, positive React, and generic Node-only fixtures. | `test` | topology matrix | `local` | `passed` | Exact rows. |
| `VAL-05` | `Validation Steps` | Run deterministic scan instrumentation proving one inventory build and at-most-once parsing per eligible manifest. | `test` | counter assertions | `local` | `passed` | Deterministic metrics. |
| `VAL-06` | `Validation Steps` | Run `bash self_check.sh`. | `test` | exact command | `local` | `passed` | 217 files; zero failures. |
| `VAL-07` | `Validation Steps` | Run `git diff --check`. | `test` | exact command | `local` | `passed` | No errors. |
| `VAL-08` | `Validation Steps` | Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md --repo-root .`. | `test` | `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md --repo-root .` | `local` | `passed` | Overall outcome: go; 10 classified paths and zero forbidden or unclassified deviations. |

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

## Package-First Assessment
- **Query executed:** `bash delphi-ai/tools/query_packages.sh --project-root /home/elton/Dev/repos/belluga-ecosystem/belluga_now_docker --search "stack capability registry"`
- **Relevant packages found:** `none`
- **READMEs read:** `none; query returned zero matches`
- **Decision:** `local Delphi tooling implementation; no proprietary package duplicates this registry/parser boundary`
- **Tier:** `n/a`
- **Rationale:** The approved slice extends Delphi's own capability registry and topology tooling rather than a reusable downstream product package.

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

## Detection Marker Schema (Frozen For ST-01)
- Canonical YAML is limited to block mappings/sequences plus the exact scalar `[]` for an empty list; flow mappings such as `{ root_files: [...] }`, anchors, aliases, tags, duplicate keys, and unknown keys are rejected.
- Allowed top-level keys are exactly `schema_version`, `ecosystem`, `activation_contract`, and `capabilities`. Allowed `activation_contract` keys are exactly `authority_order`, `project_contract_surfaces`, and `non_activation_signals`.
- Capability fields are `lifecycle`, `purpose`, optional `default_surfaces`, `activation_markers`, `detection_markers`, and `execution_policy`; every list contains strings only and required scalars are nonblank.
- Allowed detection-marker keys are `root_files`, `nested_files`, `composer_requires`, `companion_files`, and `package_json_requires_any`; unknown keys and wrong shapes fail validation.
- `package_json_requires_any` is a block list of quoted exact package names. Each package is matched within one manifest against object-valued `dependencies`, `devDependencies`, `peerDependencies`, or `optionalDependencies`; a match requires a nonblank string version value and evidence records manifest path, section, and exact package. Wrong-shaped sections or non-string/blank values yield bounded diagnostics and never match.
- Marker categories are OR-composed evidence sources. Prisma can therefore match either an exact schema-file marker or exact `@prisma/client`; predicates within one package manifest never combine with another manifest.
- `postgresql` intentionally has empty `root_files` and `nested_files` in ST-01 because no reliable universal automatic marker exists; it remains discoverable in the registry with detection state `unknown` until project-owned evidence activates it.
- Marker categories are alternative evidence sources; predicates within one package manifest never combine with another manifest. File and manifest reads remain repository-root-confined and size-bounded.

```yaml
  nestjs:
    detection_markers:
      root_files: []
      nested_files: []
      package_json_requires_any:
        - "@nestjs/core"
  react:
    detection_markers:
      root_files: []
      nested_files: []
      package_json_requires_any:
        - "react-dom"
  postgresql:
    detection_markers:
      root_files: []
      nested_files: []
  prisma:
    detection_markers:
      root_files:
        - prisma/schema.prisma
      nested_files:
        - schema.prisma
      package_json_requires_any:
        - "@prisma/client"
  railway:
    detection_markers:
      root_files:
        - railway.toml
        - railway.json
      nested_files:
        - railway.toml
        - railway.json
```

- The PostgreSQL row above intentionally produces lifecycle-aware `unknown` detection until project-owned documentation/config or user validation activates it; empty automatic markers do not prohibit project activation.

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
- **Decision review status:** `no_material_findings`
- **Decision review evidence / resolution:** `/root/generic_stack_architecture_opinion` findings were integrated; fresh `/root/generic_stack_architecture_final` confirmed the stable D-01..D-10 contract, five capabilities, one typed loader, exact predicates, lifecycle separation, scan invariant, and conditional cross-stack semantics with no remaining high/medium blocker.
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `findings_integrated`
- **Adherence review evidence / resolution:** `Fresh reviewer found GS-ADH-01/02. The bounded remediation restored qualified Laravel/Composer detection, added safe bounded Composer reads, surfaced bounded diagnostics, and strengthened exact negative fixtures. A repeat confirmation round was waived by the user on 2026-09-16 with "WAIVER APROVADO".`
- **No-go handling:** `return to the affected decision or evidence loop; do not request APROVADO or claim delivery with unresolved architecture divergence`

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** The medium cross-module admission contract needs a stable pushed package before planning review.
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `feat/add-stack-capabilities`
- **Baseline commit:** `d3db14cf4dd2da4f14c89ef92ffd9505afa8df22`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `no_material_findings`
- **Findings summary:** `The feature brief and ST-01 TODO were committed and pushed before planning review.`
- **Evidence / reference:** `git merge-base --is-ancestor d3db14c origin/feat/add-stack-capabilities` exit 0
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** Review-driven changes to scope, decisions, evidence, or validation must reconverge before approval.
- **Trigger stage:** `after planning review convergence and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `Context|Contract Boundary|Scope|Out of Scope|Definition of Done|Validation Steps|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan|Local CI-Equivalent Suite Matrix`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md`
- **No-go handling rule:** `refresh and push the reviewed baseline, then rerun affected planning gates before requesting approval`
- **Gate status:** `no_material_findings`
- **Findings summary:** `Fresh approval confirmation found zero material section drift from the pushed baseline.`
- **Evidence / reference:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-generic-stack-capability-admission.md -> go; 0 changed material sections`
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
| `delphi-ai / focused capability tests` | Registry and topology-detection behavior changes. | `python3 tools/tests/stack_capability_registry_test.py && bash tools/tests/validate_stack_capabilities_test.sh && bash tools/tests/environment_topology_contract_scaffold_test.sh` | `Local-Implemented` | `passed` | exact commands rerun 2026-09-16 | Covers schema rejection, lifecycle, exact evidence attribution, bounded reads, positives, and false-positive negatives. |
| `delphi-ai / self-check` | Canonical Delphi tooling and instruction surfaces must remain coherent. | `bash self_check.sh` | `Local-Implemented` | `passed` | `bash self_check.sh`, 2026-09-16 | 217 files checked; zero individual/coherence failures. |

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
  - **Evidence / why now:** `/home/elton/Dev/repos/Clientes/Unifast/leadshug-engineering/config/stack_capabilities.yaml:30` uses `schema.prisma` for a compound even though Prisma supports non-PostgreSQL providers and PostgreSQL does not require Prisma; freezing it would force later migration.
  - **Option A (chosen):** five independent capabilities. Effort `medium`; risk `low`; blast `cross-module`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** keep a provider-aware composite. Effort `medium`; risk `medium`; blast `cross-module`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** keep filename-only composite. Effort `low`; risk `high`; blast `cross-module`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A integrated into brief, decisions, descriptors, tests, and later story decomposition.
- **Issue `GS-02` — divergent permissive registry parsers (`high`).**
  - **Evidence / why now:** `tools/validate_stack_capabilities.py:38` and `tools/environment_topology_contract_scaffold.py:229` independently parse different YAML subsets, allowing accepted metadata to be silently ignored by its consumer.
  - **Option A (chosen):** one strict typed loader. Effort `medium`; risk `low`; blast `cross-module`; maintenance `low`; performance `improves`; elegance `improves`; structure `improves`.
  - **Option B:** extend both parsers with parity tests. Effort `medium`; risk `high`; blast `cross-module`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** validate only top-level fields. Effort `low`; risk `high`; blast `cross-module`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A integrated into scope, diff contract, harness, tests, and execution plan.
- **Issue `GS-03` — underspecified Node/monorepo evidence (`medium`).**
  - **Evidence / why now:** `tools/environment_topology_contract_scaffold.py:311` evaluates filename markers per capability and has no exact Node manifest model, so loose additions could misclassify tooling-only, React Native, or unrelated workspace packages.
  - **Option A (chosen):** exact keys in four sections, manifest-local predicates, bounded reads, one inventory/cache. Effort `medium`; risk `low`; blast `module`; maintenance `low`; performance `improves`; elegance `improves`; structure `improves`.
  - **Option B:** runtime dependencies only. Effort `low`; risk `medium` false negatives; blast `module`; maintenance `medium`; performance `improves`; elegance `neutral`; structure `neutral`.
  - **Option C:** filename/text matching. Effort `low`; risk `high`; blast `cross-module`; maintenance `high`; performance `regresses`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A frozen in `D-08/D-09` and deterministic fixtures.
- **Issue `GS-04` — broad grep tests can pass against the wrong row (`medium`).**
  - **Evidence / why now:** `tools/tests/environment_topology_contract_scaffold_test.sh:138` uses broad output greps that can find a stack name and `candidate` in unrelated rows.
  - **Option A (chosen):** table-driven typed-loader tests plus exact topology-row assertions. Effort `medium`; risk `low`; blast `module`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** exact-row shell assertions only. Effort `low`; risk `medium`; blast `module`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** retain broad grep. Effort `low`; risk `high`; blast `cross-module`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** new Python test path, exact canonical-key/lifecycle assertions, and exact topology fixtures added.
- **Issue `GS-05` — lifecycle lost from topology output (`medium`).**
  - **Evidence / why now:** `tools/environment_topology_contract_scaffold.py:69` omits lifecycle from `StackDetection`, and the table around `tools/environment_topology_contract_scaffold.py:466` therefore renders experimental and available candidates indistinguishably.
  - **Option A (chosen):** lifecycle column beside candidate and activation validation. Effort `low`; risk `low`; blast `module`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** global warning note. Effort `low`; risk `medium`; blast `module`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** prose only. Effort `low`; risk `medium`; blast `cross-module`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A added to scope, DoD, baseline, and fixtures.
- **Issue `GS-06` — incomplete derived governance/evidence (`medium`).**
  - **Evidence / why now:** `artifacts/tmp/generic-stack-admission-audit-round2.json:1` derives critique, architecture, test-quality, final review, triple review, verification debt, and performance obligations.
  - **Option A (chosen):** record every derived lane now and execute each at its gate deadline. Effort `medium`; risk `low`; blast `local`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** defer documentation until delivery. Effort `low`; risk `medium`; blast `local`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** request approval without gates. Effort `low`; risk `high`; blast `cross-module`; maintenance `high`; performance `unknown`; elegance `regresses`; structure `invalid`.
  - **Resolution:** exact audit decisions and deadlines are recorded below; post-implementation gates remain truthfully `not_run`.

### Failure Modes & Edge Cases
- [x] Scoped dependency names in `package.json` are parsed without substring false positives.
- [x] Dependencies in `dependencies`, `devDependencies`, `peerDependencies`, and `optionalDependencies` follow an explicit tested policy.
- [x] Malformed or unreadable JSON yields bounded unknown evidence rather than guessed activation.
- [x] A monorepo can expose different capabilities in different nested manifests without one manifest labeling every package.
- [x] Existing Composer/Laravel and file-marker detection remains unchanged.

### Residual Unknowns / Risks
- [x] `nest-cli.json` alone is insufficient; exact `@nestjs/core` is the NestJS candidate predicate.
- [x] `react` alone is insufficient for React web; exact `react-dom` is the ST-01 candidate predicate. Broader web-family frameworks require a later explicit marker extension.
- [x] **Remaining assumption:** A dependency-free strict reader can support the frozen subset; assumption-code guard confidence is `Medium`, and implementation must stop rather than silently broaden syntax if false.
- [x] **Remaining unknown:** Reliable automatic PostgreSQL detection is intentionally absent in ST-01; confidence is `High` that explicit `unknown` is safer than heuristic detection.
- [x] **Residual delivery risk:** The global `pcv-1` not-needed sentinel wording is imperfect; confidence is `High` that the established `none`/`n/a` representation is non-blocking here, while the triggered RLS row follows closed `RLS-E1` evidence.

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
- **Critique status:** `no_material_findings`
- **Findings summary:** `GS-01 through GS-06 and subsequent confirmation findings were integrated; fresh /root/generic_stack_approval_clean returned approval-ready with no high/medium blockers.`
- **Resolution ledger:**
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `GS-01` | `Integrated` | `useful` | `yes` | `paced` | `n/a` | PostgreSQL and Prisma are independent capabilities; the brief and TODO now contain five candidates. |
| `GS-02` | `Integrated` | `useful` | `yes` | `paced` | One typed fail-closed loader is now required and classified in the diff/harness. |
| `GS-03` | `Integrated` | `useful` | `yes` | `paced` | Exact manifest-local package/section semantics and bounded input behavior are frozen. |
| `GS-04` | `Integrated` | `useful` | `yes` | `paced` | A table-driven typed-loader test plus exact topology fixtures replace broad-only evidence. |
| `GS-05` | `Integrated` | `useful` | `yes` | `paced` | Lifecycle is carried into every topology row and remains distinct from activation. |
| `GS-06` | `Integrated` | `useful` | `partial` | `paced` | Planning and delivery audit records are being completed before approval. |
- **Evidence / reference:** `/root/generic_stack_plan_critique findings; /root/generic_stack_critique_confirmation findings; /root/generic_stack_approval_confirmation findings; clean confirmation from /root/generic_stack_approval_clean`
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
| Policy | Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Trigger Rationale | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code | Recorded At UTC | Executor ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `pcv-1` | `EPS` | `endpoint-performance-scrutiny` | `not_needed` | `low` | `none` | No endpoint, query, or data-access path changes. | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` | `2026-09-16T18:00:00Z` | `root-planning-lane` |
| `pcv-1` | `FRC` | `frontend-race-condition-validation` | `not_needed` | `low` | `none` | No frontend runtime or retriggerable async UI changes. | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` | `2026-09-16T18:00:00Z` | `root-planning-lane` |
| `pcv-1` | `BCI` | `backend-concurrency-idempotency-validation` | `not_needed` | `low` | `none` | No backend write or overlapping mutation surface changes. | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` | `2026-09-16T18:00:00Z` | `root-planning-lane` |
| `pcv-1` | `RLS` | `runtime-load-stress-validation` | `recommended` | `medium` | `RLS-BATCH-OR-BULK-PATH-CHANGED` | The local scaffold performs a bounded repository batch scan whose manifest reads must not multiply by capability count. | `before_local_implemented` | `RLS-E1` | `passed` | `none within the approved inventory/parse-count contract` | `none` | `2026-09-16T18:59:45Z` | `generic-stack-executor` |

### RLS Planned Evidence Contract
- **Evidence type:** `deterministic batch-scan metrics`
- **Environment / profile:** `local Delphi test fixture / RLS-SP-L`
- **Thresholds:** exactly one repository inventory build; each eligible `package.json` parsed at most once; adding capability predicates does not increase inventory walks.
- **Artifact:** `artifacts/tmp/generic-stack-admission-rls.json` using the `pcv-1` JSON schema, canonical serialization, and SHA-256 field contract.
- **Acceptance rule:** `RLS-A1` with `RLS-E1`; the artifact records stage profile, thresholds, counters, metrics summary, executor, reviewer, and hash.
- **Recommended-lane resolution:** This recommended row is gate-satisfying only when the `RLS-E1` artifact meets the stated thresholds and is recorded `passed` (or receives an approved waiver); the narrower wording of `RLS-A1` does not permit a prose-only pass.
- **Not-needed sentinel convention:** `none`/`n/a` is the established canonical TODO representation for absent lanes, as used by `templates/todo_template.md` consumers and the accepted Flutter coherence TODO; this TODO does not change the global `pcv-1` registry.

### RLS Evidence
- **evidence_type:** `deterministic-batch-scan-metrics`
- **environment_id:** `local-delphi-fixture`
- **run_id:** `generic-stack-admission-rls-20260916`
- **artifact_uri:** `artifacts/tmp/generic-stack-admission-rls.json`
- **artifact_schema_version:** `1`
- **artifact_sha256:** `72e59baaca82874c92c078f988dce0f1aadcfe8d43dcd49fa30bbb743ff02389`
- **sample_profile_id:** `RLS-SP-L`
- **acceptance_rule_id:** `RLS-A1`
- **result_summary:** `passed; one inventory build and 14 parse attempts for 14 eligible manifests across nine capabilities`
- **reviewer_id:** `root-delivery-lane`

## Verification Debt Assessment
- **Audit outcome:** `low`
- **Why this outcome:** The automated audit initially reported expected in-progress TODO/checklist signals; all implementation/validation checklists are now closed. Remaining review-loop ceremony was explicitly waived after the user identified disproportionate meta-governance.
- **Inline code TODO debt:** `none in changed implementation/test files`
- **Evidence / audit artifact:** `verification_debt_audit.sh --scan-git-modified; focused closeout evidence in this TODO`
- **Accepted residual debt:** `No functional verification debt; remaining independent re-review rounds are waived by the user on 2026-09-16 with "WAIVER APROVADO".`

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
- **Audit status:** `findings_integrated`
- **Findings summary:** `Fresh audit found missing direct Prisma/Railway and fail-closed schema fixtures; the bounded remediation added them. The user waived another recursive confirmation round.`
- **Resolution ledger:** `TQA-01/TQ-01 Integrated: default-registry Prisma/Railway positive and near-negative fixtures; TQA-02/TQ-02 Integrated: isolated fail-closed schema families with stable assertions.`
- **Evidence / reference:** `generic_stack_test_audit and generic_stack_triple_test findings; focused suites pass after remediation`
- **Waiver authority / reference (required if waived):** `user on 2026-09-16: "WAIVER APROVADO" for remaining audit/re-review rounds`

## Independent No-Context Final Review Gate
- **Final review decision:** `required`
- **Why this decision:** The audit floor requires expanded final review for this public cross-module capability contract.
- **Impact signals in scope:** `cross-module blast radius|public capability schema|high-severity planning findings`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `approved contract|implementation/test diff|architecture adherence|test-quality audit|verification debt|residual risks`
- **Review isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required after implementation`
- **Canonical multi-lane audit protocol (when required):** `audit-protocol-triple-review; required before completion by refreshed audit escalation`
- **Audit session / round evidence (when protocol used):** `artifacts/tmp/generic-stack-admission-triple/session.json; round-01 findings integrated; further rounds waived`
- **Review focus:** `adherence|regressions|validation evidence|security/performance residuals|elegance|structural soundness`
- **Final review status:** `waived`
- **Findings summary:** `No additional final-review round was run after the bounded remediation; the user explicitly stopped the disproportionate meta-review loop.`
- **Resolution ledger:** `Architecture findings GS-ADH-01/02 and performance finding PERF-01 were Integrated through Laravel qualification, safe bounded Composer reads, visible bounded diagnostics, and reliable negative assertions. PERF-02/03/04 expansion proposals beyond the approved one-inventory/parse-once contract were not pursued under the waiver.`
- **Evidence / reference:** `focused tests, canonical validator, self_check, git diff --check, and strict diff guard all pass after remediation`
- **Waiver authority / reference (required if waived):** `user on 2026-09-16: "WAIVER APROVADO"`

## Decision Adherence Validation
| Decision ID | Status (`Adherent`/`Exception`) | Evidence | Notes |
| --- | --- | --- | --- |
| `D-01` | `Adherent` | five independent registry keys and exact experimental-set test | No bundle or PostgreSQL/Prisma compound. |
| `D-02` | `Adherent` | `config/stack_capabilities.yaml`; canonical registry test | All five remain `experimental`. |
| `D-03` | `Adherent` | topology table uses candidate state plus user validation | Registry/detection never emits active state. |
| `D-04` | `Adherent` | Node positive/near-negative topology matrix | `package.json` alone is insufficient. |
| `D-05` | `Adherent` | generic loader tests; required-baseline fixture; Laravel exact evidence test | Every capability is validated and baseline compatibility is preserved. |
| `D-06` | `Adherent` | bounded diff contains no tenant/BU or unconditional handoff policy | Conditional downstream semantics remain outside ST-01. |
| `D-07` | `Adherent` | shared loader imports plus 10 fail-closed tests | One documented strict parser boundary. |
| `D-08` | `Adherent` | exact four-section package fixtures and attributed evidence rows | Manifest-local exact keys only. |
| `D-09` | `Adherent` | inventory/parse counters; safe bounded package/composer reads; diagnostics fixtures | One inventory, at-most-once manifest reads, root confinement, bounded diagnostics. |
| `D-10` | `Adherent` | rendered lifecycle/candidate/user-validation columns | Detection remains candidate evidence. |

## Module Decision Consistency Validation
| Module Decision Ref | Planned Handling | Delivery Status (`Preserved|Superseded (Approved)|Regression`) | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `stack-capabilities#registry-vs-activation` | preserve | `Preserved` | registry descriptors and topology wording | Availability metadata remains non-activating. |
| `environment-topology#user-validation` | preserve | `Preserved` | lifecycle-aware candidate table | Inferred evidence still requires user validation. |
| `laravel-detection#composer-qualification` | preserve | `Preserved` | exact Laravel evidence assertion after GS-ADH-01 remediation | Arbitrary Composer packages remain negative. |
| `baseline-capabilities#docker-flutter-laravel-go` | preserve | `Preserved` | required-baseline validation fixture | Existing compatibility meaning remains intact. |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `GS-ADH-01` | `high` | `release-blocker` | `same TODO correction` | Laravel compatibility is an explicit ST-01 requirement. | `corrected` | qualified Composer evidence plus reliable negative assertion |
| `GS-ADH-02` | `medium` | `release-blocker` | `same TODO correction` | Bounded visible diagnostics are part of D-09. | `corrected` | scaffold diagnostic section and hostile-input fixtures |
| `PERF-01` | `high` | `release-blocker` | `same TODO correction` | Safe bounded Composer reads are part of D-09. | `corrected` | shared root-confined bounded reader and Composer fixtures |
| `TQA-01/TQ-01` | `medium` | `release-blocker` | `same TODO correction` | Prisma/Railway are delivered by ST-01. | `corrected` | direct default-registry positive/near-negative fixtures |
| `TQA-02/TQ-02` | `medium` | `release-blocker` | `same TODO correction` | Frozen schema rejection boundaries require direct proof. | `corrected` | expanded isolated loader rejection matrix |
| `PERF-02/PERF-03` | `medium` | `by-design/no-action` | `retain approved bounded contract` | Proposed indexing and capability-growth instrumentation exceed the frozen requirement of one inventory plus at-most-once parsing; the user stopped further meta-expansion. | `closed by waiver` | user `WAIVER APROVADO`, 2026-09-16 |
| `PERF-04` | `medium` | `release-blocker` | `same TODO correction` | Bounded diagnostics were already required. | `corrected` | capped content-free diagnostics rendered by scaffold |
| `RULE-SPIRIT-LEXICAL` | `warning` | `by-design/no-action` | `scanner false positives` | Fixture domain `example.test`, tool descriptions, and Python prose matched stack heuristics without introducing bypass/runtime authority. | `closed` | manual classification of `artifacts/tmp/generic-stack-admission-rule-spirit.json` |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `bounded ST-01 diff after remediation` | `compatibility, unsafe reads, weak assertions, CI failure modes` | `passed` | focused suites; canonical validator; `bash self_check.sh`; `git diff --check` | `none` | Concrete high/medium findings were corrected; recursive confirmation was explicitly waived. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `registry, topology, tests, tooling manifest` | `activation inference, project coupling, guard bypass, unsafe input handling` | `passed` | `artifacts/tmp/generic-stack-admission-rule-spirit.json`; manual diff review | `18 lexical hints; no material violation` | All hints classified `by-design/no-action`; no allowlist used. |

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | Defines additive capabilities and project-owned activation. | Capability/activation separation and agnostic core. | Project truth in Delphi registry. | Keep descriptors non-activating. |
| `rules/core/environment-topology-contract-model-decision.md` | Governs detection evidence and downstream validation. | Project-owned topology authority. | Inferring activation from Delphi files. | Detection remains candidate evidence only. |
| `workflows/docker/environment-topology-contract-method.md` | Owns topology discovery semantics. | Explicit user validation for inferred stack candidates. | Silent activation. | Preserve report language and tests. |
| `workflows/docker/self-improvement-session-method.md` | This is Delphi instruction/tooling maintenance. | Agnosticism and instruction-only boundary. | Downstream edits. | Limit all changes to Delphi. |
| `workflows/docker/todo-driven-execution-method.md` | Durable tooling behavior requires approved TODO execution. | Approval, strict diff, evidence. | Work outside the approved ST-01 boundary. | Execute only after the normal authority guard returns `go`. |
| `workflows/docker/todo-execution-boundary-method.md` | `APROVADO` moved ST-01 into implementation. | Frozen D-01..D-10 and single-writer principal checkout. | Hidden scope expansion or unapproved worktree topology. | Run routing and authority guards before functional edits. |
| `skills/package-first-verification/SKILL.md` | The slice introduces a shared parser/tooling boundary. | Reuse an existing proprietary package when one exists. | Duplicating package-owned behavior. | Zero relevant packages found; local Delphi tooling is appropriate. |
| `skills/test-creation-standard/SKILL.md` | Parser and detector tests define the public registry contract. | Fail-first evidence, effective assertions, negative fixtures. | Pass-the-test shortcuts or broad unrelated greps. | Add focused unit/integration fixtures before implementation. |

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

## Approval
- **Approved by:** `user on 2026-09-16 with explicit "APROVADO"`
- **Approval scope:** `implement ST-01's generic typed registry admission and lifecycle-aware detection substrate for NestJS, React, PostgreSQL, Prisma, and Railway; no stack-specific rule, workflow, skill, CI engine, or runtime port is authorized`

## TODO Closeout Disposition
- **Disposition:** `keep-active`
- **Disposition reason:** `ST-01 is Local-Implemented and validated; after this authorized publication, only explicit branch promotion into main remains for this slice, while later stack-specific stories remain separate work.`
- **Post-commit/push status:** `complete`
- **Next path/status action:** `await explicit user approval for promotion of feat/add-stack-capabilities into main; keep this TODO active for branch-integration traceability.`
