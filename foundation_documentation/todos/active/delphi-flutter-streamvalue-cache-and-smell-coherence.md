# TODO: Delphi Flutter StreamValue, Cache, and Smell Coherence

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The preserved local branch `chore/flutter-skills-autoroute-cache-guards` contains commit `b9995eca21f2240c30211e265c11fede2c4bb30c`, which proposed repository-owned canonical `StreamValue` state, AutoRoute-only navigation checks, cache-smell detection, and stronger Flutter performance signals.

The commit must not be cherry-picked as a unit: its patch is stale against current `main`, includes obsolete analyzer commands, contains project-specific examples, and proposes a broad `flutter-clean-code-audit` that overlaps existing Delphi review skills. Its central state-ownership decision is nevertheless valid and was independently incorporated into `main` by `be7a533fe0fabc2f8a1c6042bbde8e3bb869136a`.

Current Delphi is internally inconsistent after the umbrella-skill simplification in `654847122d3291087ac3ecb0c03e6eef822af0df`:
- the always-on Flutter rule says canonical shared, cache-backed, or persistence-aligned state is repository-owned;
- the Flutter umbrella skill says shared state is controller-owned;
- the controller workflow still instructs controllers to maintain paginated caches.

The intended architecture treats the persistent repository-owned `StreamValue` itself as the canonical reactive in-memory cache. A second mutable list, map, `cache`, or `cached*` holder for the same canonical data creates a competing source of truth.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** This is one bounded Delphi self-maintenance objective: restore a single coherent Flutter state/cache contract and preserve the useful architecture/performance signals identified while auditing `b9995ec`.
- **Direct-to-TODO rationale:** The user and Delphi have already resolved the ownership and cache semantics. A separate feature brief would repeat the same decisions without reducing ambiguity.

## Contract Boundary
- This TODO defines the first implementation slice of branch `feat/add-stack-capabilities`.
- The implementation must recover semantic intent selectively; it must not cherry-pick or mechanically replay `b9995ec`.
- The slice is limited to project-agnostic Delphi Flutter rules, workflows, skills, their generated/mirrored agent surfaces, and deterministic-tooling classification.
- Downstream Flutter product code and project-specific architecture contracts remain outside this self-improvement session.

## Implementation Intent
- **Current delivery:** Align Flutter canonical state/cache ownership across Delphi surfaces and add the bounded missing smell signals established by this analysis.
- **Planned next steps:** `evaluate actual analyzer-rule implementation in the owning analyzer repository as a separately authorized downstream slice when a missing rule is confirmed`
- **Anticipatory implementation authorized now:** `none outside delphi-ai`
- **Rationale:** One coherent instruction package is the smallest faithful implementation. It corrects the regression and records deterministic support expectations without coupling Delphi to one downstream analyzer checkout.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** `frame the separate Delphi capability-admission TODO for NestJS, React, PostgreSQL/Prisma, and Railway without mixing implementation into this Flutter slice`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** Local implementation and clean review evidence are complete; the TODO remains in review until the feature branch is integrated.
- **Exit condition:** The branch integration or promotion path is explicitly completed by the owning closeout lane.

## Scope
- [x] Reconcile the Flutter umbrella skill, always-on rules, and controller workflow around one state-ownership contract.
- [x] Establish controller-owned `StreamValue` for screen-, stage-, form-, or interaction-local state.
- [x] Establish persistent repository-owned `StreamValue` for canonical cross-screen collections, pagination, shared entity state, cache-backed state, and persistence-aligned state.
- [x] Require controllers to expose/delegate repository-owned canonical streams without mirroring their values into parallel mutable stores.
- [x] Define the persistent canonical `StreamValue` as the application-level reactive cache and prohibit duplicate list/map/cache holders for the same canonical data.
- [x] Clarify that pagination reconciliation, upsert, removal, delta application, refresh, and invalidation update the canonical repository `StreamValue` rather than a controller cache.
- [x] Distinguish canonical-data duplication from operational metadata such as cursor, `hasMore`, and in-flight guards, while requiring clear ownership for that metadata.
- [x] Distinguish application-state caching from non-duplicative technical caches owned by transport, image, filesystem, or persistence adapters.
- [x] Remove the controller-workflow instruction to maintain a paginated cache in the controller.
- [x] Treat `cache|cached|Cache` matches in controller/repository state surfaces as mandatory semantic review signals: presumed deviations until classified, not name-only automatic violations.
- [x] Preserve AutoRoute/project-router authority and direct `Navigator` bypass detection using current project-activated routing policy rather than project-specific hard-coding.
- [x] Port the still-useful narrow signals from `b9995ec`: post-async `.then`/callback navigation, timers/subscriptions initiated from `build`, hot-list network-image decode sizing, nested `shrinkWrap`, large collection sorting/filtering in `build`, and stable item keys.
- [x] Classify each material skill change in `skills/deterministic-tooling-register.md`, preferring analyzer/lint enforcement where static semantics are reliable.
- [x] Synchronize required Cline and Claude skill/rule/workflow mirrors from canonical Delphi sources.

## Out of Scope
- [ ] Cherry-picking or merging `b9995ec` as a unit.
- [ ] Creating `flutter-clean-code-audit` in the form proposed by `b9995ec`.
- [ ] Restoring `fvm flutter analyze` as local evidence in editor-managed workspaces.
- [ ] Introducing Belluga-specific package imports, repository names, domain entities, or topology into Delphi core.
- [ ] Prohibiting every occurrence of the word `cache` without semantic classification.
- [ ] Prohibiting transport, image, filesystem, or persistence-layer caches that do not duplicate canonical application state.
- [ ] Implementing analyzer-plugin rules in an external/downstream repository.
- [ ] Modifying downstream Flutter product code or `foundation_documentation` outside this Delphi TODO.
- [ ] Broadly redesigning Flutter state management beyond the ownership inconsistency and bounded smell signals listed in scope.

## Diff Expectation Contract
- **Contract status:** `required`
- **Policy:** `strict; unclassified or forbidden paths block delivery`
- **User validation:** `required on deviation`
- **Comparison mode:** `working_tree`

### Repository Baselines
| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| `delphi-ai` | `.` | `feat/add-stack-capabilities@2f2fa7722243fc0cd5b2b0d192d2f8371b03db6f` | `working_tree` |

### Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md` | `A, M, R, ??` | Governing execution contract and evidence ledger. |
| `delphi-ai` | `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md` | `A, ??` | Routed, Pending/unapproved future hardening contract only; implementation is explicitly outside this session. |
| `delphi-ai` | `skills/flutter-*/SKILL.md` | `M` | Canonical umbrella and bounded smell-skill alignment. |
| `delphi-ai` | `skills/rule-flutter-flutter-architecture-always-on/SKILL.md` | `M` | Generated/curated rule skill alignment. |
| `delphi-ai` | `skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Controller trigger wording must preserve local ownership and canonical repository delegation. |
| `delphi-ai` | `skills/rule-docker-flutter-architecture/SKILL.md` | `M` | Docker-exposed Flutter rule alignment. |
| `delphi-ai` | `skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Controller workflow skill alignment. |
| `delphi-ai` | `skills/wf-flutter-create-screen-method/SKILL.md` | `M` | Screen workflow skill must distinguish local controller state from delegated repository streams. |
| `delphi-ai` | `skills/rule-flutter-flutter-screen-workflow-glob/SKILL.md` | `M` | Screen trigger wording must not assign canonical entity/list state to controllers. |
| `delphi-ai` | `skills/deterministic-tooling-register.md` | `M` | Deterministic support classification. |
| `delphi-ai` | `rules/stacks/flutter/flutter-architecture-always-on.md` | `M` | Canonical Flutter ownership/cache wording. |
| `delphi-ai` | `rules/stacks/flutter/flutter-controller-workflow-glob.md` | `M` | Controller trigger wording must not reintroduce generic controller ownership of canonical streams. |
| `delphi-ai` | `rules/stacks/flutter/flutter-screen-workflow-glob.md` | `M` | Screen trigger wording must distinguish local controller state from repository-owned canonical streams. |
| `delphi-ai` | `rules/stacks/docker/flutter-architecture.md` | `M` | Docker-exposed canonical Flutter wording. |
| `delphi-ai` | `system_architecture_principles.md` | `M` | Appendix-level Flutter tenet must distinguish local controller state from delegated canonical repository state. |
| `delphi-ai` | `workflows/flutter/create-controller-method.md` | `M` | Canonical controller workflow correction. |
| `delphi-ai` | `workflows/flutter/create-screen-method.md` | `M` | Canonical screen workflow correction. |
| `delphi-ai` | `.cline/skills/flutter-*/SKILL.md` | `M` | Generated Cline skill mirrors. |
| `delphi-ai` | `.claude/skills/flutter-*/SKILL.md` | `M` | Generated Claude skill mirrors. |
| `delphi-ai` | `.cline/skills/rule-*-flutter-architecture*/SKILL.md` | `M` | Generated Cline mirrors for the changed Flutter architecture rule skills. |
| `delphi-ai` | `.claude/skills/rule-*-flutter-architecture*/SKILL.md` | `M` | Generated Claude mirrors for the changed Flutter architecture rule skills. |
| `delphi-ai` | `.cline/skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Generated Cline mirror for the corrected controller trigger. |
| `delphi-ai` | `.claude/skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Generated Claude mirror for the corrected controller trigger. |
| `delphi-ai` | `.cline/skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Generated Cline mirror for the changed controller workflow skill. |
| `delphi-ai` | `.claude/skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Generated Claude mirror for the changed controller workflow skill. |
| `delphi-ai` | `.cline/skills/wf-flutter-create-screen-method/SKILL.md` | `M` | Generated Cline mirror for the corrected screen workflow skill. |
| `delphi-ai` | `.claude/skills/wf-flutter-create-screen-method/SKILL.md` | `M` | Generated Claude mirror for the corrected screen workflow skill. |
| `delphi-ai` | `.cline/skills/rule-flutter-flutter-screen-workflow-glob/SKILL.md` | `A, M, ??` | Generated Cline mirror for the corrected screen trigger. |
| `delphi-ai` | `.claude/skills/rule-flutter-flutter-screen-workflow-glob/SKILL.md` | `A, M, ??` | Generated Claude mirror for the corrected screen trigger. |
| `delphi-ai` | `.claude/rules/03-flutter-architecture.md` | `M` | Active Claude Flutter architecture mirror requires the same local-versus-canonical state contract. |
| `delphi-ai` | `.claude/rules/08-flutter-glob-workflows.md` | `M` | Active Claude controller trigger must preserve the corrected ownership distinction. |
| `delphi-ai` | `.clinerules/**` | `M` | Generated Cline rule/workflow mirrors when canonical sources require synchronization. |

### Not Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `skills/flutter-clean-code-audit/**` | `any` | The proposed broad audit skill is explicitly rejected. |
| `delphi-ai` | `tools/**` | `A, D` | No new standalone deterministic tool is authorized by this slice. |
| `delphi-ai` | `scripts/**` | `any` | Runtime/build scripting is unrelated to this instruction package. |
| `delphi-ai` | `config/stack_capabilities.yaml` | `any` | Stack-capability expansion is a later branch slice, not part of this Flutter correction. |
| `downstream` | `**` | `any` | Product and analyzer repositories are outside this TODO.

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** wording refinements, mirror synchronization, tooling-register updates, and focused validation needed to make the listed ownership/cache/smell decisions internally coherent.
- **Must update or split the TODO:** new state-management architecture, analyzer implementation outside Delphi, downstream migrations, a new generic audit framework, or changes to stack-capability registration.

## Definition of Done
- [x] All active Delphi Flutter authority surfaces consistently distinguish controller-local state from repository-owned canonical shared state.
- [x] No active workflow instructs a controller to own the canonical paginated cache.
- [x] Delphi explicitly states that the persistent repository `StreamValue` is the canonical application-level reactive cache.
- [x] Parallel canonical caches or mirrored mutable collections in controllers/repositories are prohibited, while operational metadata and technical adapter caches are correctly distinguished.
- [x] The six selected performance/navigation signals are represented concisely in the existing smell skills without creating a broad duplicate audit skill.
- [x] AutoRoute/project-router wording remains generic, project-activated, and consistent across rule and umbrella surfaces.
- [x] No obsolete CLI analyzer instruction or project-specific example is introduced.
- [x] Deterministic-tooling classifications accurately identify analyzer/lint candidates and existing support.
- [x] Canonical, Cline, and Claude surfaces are synchronized where applicable.
- [x] Delphi self-maintenance validation and diff-scope checks pass.

## Validation Steps
- [x] Run `bash self_check.sh`.
- [x] Run `bash tools/verify_adherence_sync.sh` when applicable to the touched mirrors; classify the standalone Delphi checkout's missing downstream `.agents` directories and verify the changed mirrors directly.
- [x] Run `bash tools/sync_cline_skill_mirrors.sh <skill-name>` for every changed mirrored Flutter skill and verify no remaining canonical/mirror diff.
- [x] Run `bash tools/sync_claude_skill_mirrors.sh <skill-name>` for every changed Claude-exposed Flutter skill and verify no remaining canonical/mirror diff.
- [x] Run `bash tools/sync_clinerules_mirrors.sh` after changing curated rule/workflow sources that own `.clinerules` counterparts.
- [x] Run `rg -n "controller-owned|repository-owned|paginated cache|cache-backed|canonical shared state" skills rules workflows .cline .claude .clinerules` and manually classify every relevant ownership statement for consistency.
- [x] Run `rg -n "fvm (flutter|dart).*analy|package:belluga_now"` across changed files and require no newly introduced obsolete/project-specific instruction.
- [x] Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md --repo-root .`.
- [x] Run `git diff --check`.

## Completion Evidence Matrix (Required Before Delivery Claim)
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCP-01` | `Scope` | Reconcile the Flutter umbrella skill, always-on rules, and controller workflow around one state-ownership contract. | `review` | `skills/flutter-architecture-adherence/SKILL.md`; `rules/stacks/flutter/flutter-architecture-always-on.md`; `workflows/flutter/create-controller-method.md` | `local` | `passed` | Canonical surfaces use the same local-versus-shared ownership contract. |
| `SCP-02` | `Scope` | Establish controller-owned `StreamValue` for screen-, stage-, form-, or interaction-local state. | `review` | controller and screen workflows plus architecture rule review | `local` | `passed` | Local controller state is explicitly bounded to screen/stage/form/interaction ownership. |
| `SCP-03` | `Scope` | Establish persistent repository-owned `StreamValue` for canonical cross-screen collections, pagination, shared entity state, cache-backed state, and persistence-aligned state. | `review` | architecture rule, umbrella skill, controller and screen workflows | `local` | `passed` | Persistent entity/list streams are repository-owned canonical state. |
| `SCP-04` | `Scope` | Require controllers to expose/delegate repository-owned canonical streams without mirroring their values into parallel mutable stores. | `review` | controller/screen workflows and mirror review | `local` | `passed` | Delegation is required; controller list/map/cache mirrors are prohibited. |
| `SCP-05` | `Scope` | Define the persistent canonical `StreamValue` as the application-level reactive cache and prohibit duplicate list/map/cache holders for the same canonical data. | `review` | canonical ownership/cache surfaces | `local` | `passed` | Repository `StreamValue` is the sole mutable canonical reactive cache. |
| `SCP-06` | `Scope` | Clarify that pagination reconciliation, upsert, removal, delta application, refresh, and invalidation update the canonical repository `StreamValue` rather than a controller cache. | `review` | `workflows/flutter/create-controller-method.md` and mirrors | `local` | `passed` | Controller delegates; repository updates the canonical stream. |
| `SCP-07` | `Scope` | Distinguish canonical-data duplication from operational metadata such as cursor, `hasMore`, and in-flight guards, while requiring clear ownership for that metadata. | `review` | canonical rule and controller workflow | `local` | `passed` | Pagination metadata is not classified as a duplicate cache. |
| `SCP-08` | `Scope` | Distinguish application-state caching from non-duplicative technical caches owned by transport, image, filesystem, or persistence adapters. | `review` | canonical rule and umbrella skill | `local` | `passed` | Technical caches remain permitted when non-competing. |
| `SCP-09` | `Scope` | Remove the controller-workflow instruction to maintain a paginated cache in the controller. | `review` | `workflows/flutter/create-controller-method.md` and generated mirrors | `local` | `passed` | Obsolete controller paginated-cache instruction was removed. |
| `SCP-10` | `Scope` | Treat `cache&#124;cached&#124;Cache` matches in controller/repository state surfaces as mandatory semantic review signals: presumed deviations until classified, not name-only automatic violations. | `review` | architecture rule and tooling register review | `local` | `passed` | Normalized anchor: Treat cache cached Cache matches in controller/repository state surfaces as mandatory semantic review signals: presumed deviations until classified, not name-only automatic violations. Cache spelling triggers semantic classification rather than a lexical verdict. |
| `SCP-11` | `Scope` | Preserve AutoRoute/project-router authority and direct `Navigator` bypass detection using current project-activated routing policy rather than project-specific hard-coding. | `review` | architecture skill/rule and Claude architecture mirror | `local` | `passed` | AutoRoute/project-router remains generic and project-activated. |
| `SCP-12` | `Scope` | Port the still-useful narrow signals from `b9995ec`: post-async `.then`/callback navigation, timers/subscriptions initiated from `build`, hot-list network-image decode sizing, nested `shrinkWrap`, large collection sorting/filtering in `build`, and stable item keys. | `review` | five existing `skills/flutter-smell-*/SKILL.md` surfaces | `local` | `passed` | Exactly six bounded signals were ported; no broad audit skill was created. |
| `SCP-13` | `Scope` | Classify each material skill change in `skills/deterministic-tooling-register.md`, preferring analyzer/lint enforcement where static semantics are reliable. | `review` | `skills/deterministic-tooling-register.md` | `local` | `passed` | Each changed smell skill has deterministic classification/support evidence. |
| `SCP-14` | `Scope` | Synchronize required Cline and Claude skill/rule/workflow mirrors from canonical Delphi sources. | `test` | Cline/Claude/clinerules sync commands, direct `cmp`, `bash self_check.sh` | `local` | `passed` | Required changed mirrors were synchronized from canonical sources. |
| `P2-05` | `Promotion Finding Routing Ledger` | Route the missing deterministic active-surface coherence harness to a real follow-up contract without implementing it in this session. | `doc` | `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md` | `local` | `passed` | The real TODO is `Pending` and unapproved; it contains no implementation authorization. |
| `DOD-01` | `Definition of Done` | All active Delphi Flutter authority surfaces consistently distinguish controller-local state from repository-owned canonical shared state. | `review` | ownership scan and canonical/mirror review | `local` | `passed` | Active authority surfaces now use the local/delegated controller distinction. |
| `DOD-02` | `Definition of Done` | No active workflow instructs a controller to own the canonical paginated cache. | `review` | controller workflow and mirror review | `local` | `passed` | Pagination reconciliation is repository-owned. |
| `DOD-03` | `Definition of Done` | Delphi explicitly states that the persistent repository `StreamValue` is the canonical application-level reactive cache. | `review` | canonical architecture rule, umbrella skill, and workflows | `local` | `passed` | The repository stream is specified as canonical reactive cache. |
| `DOD-04` | `Definition of Done` | Parallel canonical caches or mirrored mutable collections in controllers/repositories are prohibited, while operational metadata and technical adapter caches are correctly distinguished. | `review` | ownership/cache rule review | `local` | `passed` | Duplicate canonical representations are blocked; metadata/technical caches are classified. |
| `DOD-05` | `Definition of Done` | The six selected performance/navigation signals are represented concisely in the existing smell skills without creating a broad duplicate audit skill. | `review` | five smell skills and rejected-path scan | `local` | `passed` | Structural-only browser/device coverage rationale: this instruction-only rule change has no product flow; local mutation language is verified as a prohibition, and six signals exist in specialized skills. |
| `DOD-06` | `Definition of Done` | AutoRoute/project-router wording remains generic, project-activated, and consistent across rule and umbrella surfaces. | `review` | architecture rule, umbrella skill, and Claude architecture rule | `local` | `passed` | No project-specific route topology was introduced. |
| `DOD-07` | `Definition of Done` | No obsolete CLI analyzer instruction or project-specific example is introduced. | `review` | changed-file analyzer/package scan | `local` | `passed` | Criterion normalization preserves the exact `fvm (flutter&#124;dart).*analy&#124;package:belluga_now` source wording; editor guidance uses the stable full-workspace VS Code Problems snapshot. |
| `DOD-08` | `Definition of Done` | Deterministic-tooling classifications accurately identify analyzer/lint candidates and existing support. | `review` | `skills/deterministic-tooling-register.md` | `local` | `passed` | Static candidates and semantic-review boundaries are recorded. |
| `DOD-09` | `Definition of Done` | Canonical, Cline, and Claude surfaces are synchronized where applicable. | `test` | sync scripts, direct `cmp`, and `bash self_check.sh` | `local` | `passed` | Changed screen/controller and rule mirrors are synchronized. |
| `DOD-10` | `Definition of Done` | Delphi self-maintenance validation and diff-scope checks pass. | `test` | `bash self_check.sh`; diff expectation guard; `git diff --check` | `local` | `passed` | Structural-only evidence: the approved scope changes no browser/device or product flow; no browser/device test is claimed or required for this non-runtime instruction package. |
| `VAL-01` | `Validation Steps` | Run `bash self_check.sh`. | `test` | `bash self_check.sh` | `local` | `passed` | Exit 0 after mirror synchronization. |
| `VAL-02` | `Validation Steps` | Run `bash tools/verify_adherence_sync.sh` when applicable to the touched mirrors; classify the standalone Delphi checkout's missing downstream `.agents` directories and verify the changed mirrors directly. | `test` | direct `cmp` plus Cline/Claude/clinerules sync commands | `local` | `passed` | Full downstream suite is n/a in this standalone checkout because required downstream `.agents` directories are absent; direct changed-mirror evidence passes. |
| `VAL-03` | `Validation Steps` | Run `bash tools/sync_cline_skill_mirrors.sh <skill-name>` for every changed mirrored Flutter skill and verify no remaining canonical/mirror diff. | `test` | `bash tools/sync_cline_skill_mirrors.sh ...`; direct `cmp` | `local` | `passed` | All changed Cline-exposed Flutter skills compare equal. |
| `VAL-04` | `Validation Steps` | Run `bash tools/sync_claude_skill_mirrors.sh <skill-name>` for every changed Claude-exposed Flutter skill and verify no remaining canonical/mirror diff. | `test` | `bash tools/sync_claude_skill_mirrors.sh ...`; direct `cmp` | `local` | `passed` | All changed Claude-exposed Flutter skills compare equal. |
| `VAL-05` | `Validation Steps` | Run `bash tools/sync_clinerules_mirrors.sh` after changing curated rule/workflow sources that own `.clinerules` counterparts. | `test` | `bash tools/sync_clinerules_mirrors.sh create-controller create-screen` | `local` | `passed` | Generated controller/screen workflow counterparts were refreshed. |
| `VAL-06` | `Validation Steps` | Run `rg -n "controller-owned&#124;repository-owned&#124;paginated cache&#124;cache-backed&#124;canonical shared state" skills rules workflows .cline .claude .clinerules` and manually classify every relevant ownership statement for consistency. | `review` | ownership/cache `rg` scan and manual classification | `local` | `passed` | Normalized anchor: Run `rg -n "controller-owned repository-owned paginated cache cache-backed canonical shared state" skills rules workflows .cline .claude .clinerules` and manually classify every relevant ownership statement for consistency. Broad controller ownership wording was corrected. |
| `VAL-07` | `Validation Steps` | Run `rg -n "fvm (flutter&#124;dart).*analy&#124;package:belluga_now"` across changed files and require no newly introduced obsolete/project-specific instruction. | `review` | changed-file analyzer/package scan | `local` | `passed` | Normalized anchor: Run `rg -n "fvm (flutter dart).*analy package:belluga_now"` across changed files and require no newly introduced obsolete/project-specific instruction. No obsolete CLI instruction or Belluga-specific example was added. |
| `VAL-08` | `Validation Steps` | Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md --repo-root .`. | `test` | `stdout: Overall outcome: go; 52 actual paths classified` | `local` | `passed` | Strict changed-path contract remains classified after P2 remediation. |
| `VAL-09` | `Validation Steps` | Run `git diff --check`. | `test` | `git diff --check` | `local` | `passed` | No whitespace errors. |

## External Dependency Readiness
| Dependency | Why It Matters | Status (`unknown|healthy|degraded|failing|rate-limited|stale`) | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| `none` | This slice changes local Delphi instruction and mirror surfaces only. | `healthy` | `2026-09-16` | `n/a` | `n/a` |

## Profile Scope & Handoffs (Required Before `APROVADO`)
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder|assurance-tester-quality`
- **Scope-check command:** `n/a - Delphi self-maintenance repository`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `operational-coder` | Execute the approved canonical instruction and mirror changes after architecture decisions are frozen. | `skills/**`, `rules/**`, `workflows/**`, mirror surfaces, tooling register | `completed - dedicated routine executor implemented the bounded package in the principal checkout` |
| `operational-coder` | `assurance-tester-quality` | Validate semantic coherence, mirror sync, and absence of rejected branch content. | final bounded diff and validation evidence | `completed - final review found and corrected residual ambiguous system/controller-trigger wording before rerunning gates` |

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The decisions are resolved and the scope is instruction-only, but the correction crosses canonical rules, workflows, umbrella/smell skills, mirrors, and deterministic-tooling classification.

## Canonical Module Anchors (Required Before APROVADO)
- **Primary module doc:** `rules/stacks/flutter/flutter-architecture-always-on.md`
- **Secondary module docs (if any):**
  - `skills/flutter-architecture-adherence/SKILL.md`
  - `workflows/flutter/create-controller-method.md`
  - `system_architecture_principles.md`
  - `skills/deterministic-tooling-register.md`
- **Planned decision promotion targets (module sections):**
  - Flutter state ownership
  - canonical reactive cache semantics
  - controller/repository pagination responsibilities
  - performance and navigation smell detection
- **Module decision consolidation targets (required):**
  - `rules/stacks/flutter/flutter-architecture-always-on.md`
  - `skills/flutter-architecture-adherence/SKILL.md`
  - `workflows/flutter/create-controller-method.md`
  - existing `skills/flutter-smell-*/SKILL.md` files
  - `skills/deterministic-tooling-register.md`

## Decisions (Resolved Before Freeze)
- [x] `RES-D-01` Do not cherry-pick `b9995ec`; selectively reconstruct valid intent against current Delphi architecture.
- [x] `RES-D-02` Controller-owned `StreamValue` is limited to local screen, stage, form, and interaction state.
- [x] `RES-D-03` Canonical cross-screen, paginated, cache-backed, or persistence-aligned state is a persistent repository-owned `StreamValue` exposed through controller delegation.
- [x] `RES-D-04` The persistent repository `StreamValue` is itself the canonical application-level reactive cache; parallel mutable copies of the same canonical data are prohibited.
- [x] `RES-D-05` Cache-name scans are mandatory semantic-review triggers. A match is presumed suspect until classified, but the final violation decision depends on duplicated canonical state rather than spelling alone.
- [x] `RES-D-06` Cursor, `hasMore`, and in-flight request guards are operational metadata, not automatically duplicate caches; their ownership must still be coherent with repository pagination.
- [x] `RES-D-07` Transport, image, filesystem, and persistence caches may exist when they do not become a competing application-state source of truth.
- [x] `RES-D-08` Port only the six bounded smell signals identified in scope and do not introduce `flutter-clean-code-audit`.
- [x] `RES-D-09` Prefer analyzer/lint enforcement for statically reliable signals, but keep external analyzer implementation outside this Delphi-only TODO.
- [x] `RES-D-10` This TODO is the first implementation slice of `feat/add-stack-capabilities`; stack-capability expansion remains a later independent slice on the branch.

## Module Decision Baseline Snapshot (Required Before APROVADO)
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `flutter-always-on#canonical-shared-state` | Repository owns cross-controller/module, cache-backed, persistence-aligned state. | `Preserve` | Introduced on main by `be7a533`; still present in the active always-on rule. |
| `flutter-umbrella#state-and-navigation` | Current shortened wording says official shared state is controller-owned. | `Supersede (Intentional)` | Introduced by umbrella simplification in `6548471`; conflicts with the always-on rule. |
| `create-controller#realtime-delta-handling` | Controller maintains a paginated cache. | `Supersede (Intentional)` | Surviving workflow text originates from `cbfff86` and conflicts with repository-owned canonical state. |
| `system-principles#single-source-of-truth` | Cache is a deliberate optimization and must not become the data model/source of truth. | `Preserve` | `system_architecture_principles.md`, Single Source of Truth principle. |

## Decision Baseline (Frozen Before Implementation)
- [x] `BASE-D-01` There will be one canonical mutable representation of shared application state: the persistent repository-owned `StreamValue`.
- [x] `BASE-D-02` Controllers orchestrate and expose canonical streams but do not mirror canonical repository data into local caches.
- [x] `BASE-D-03` Cache review is semantic and fail-closed: suspected parallel state must be removed or explicitly proven to be non-duplicative technical caching/metadata.
- [x] `BASE-D-04` The resulting Delphi instructions remain project-agnostic and compatible with project-local architecture overrides through the existing cascading hierarchy.
- [x] `BASE-D-05` No rejected or obsolete content from `b9995ec` may re-enter through mechanical copying.

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** The TODO corrects contradictory active Flutter authority surfaces and retires a recurring second-source-of-truth architecture path.
- **Deviation / debt being retired:** umbrella/workflow guidance that assigns canonical shared state or paginated cache ownership to controllers despite the always-on repository-ownership rule
- **Target steady-state after closeout:** controller-local streams for local interaction state; one persistent repository stream/cache for canonical shared state; controllers delegate without mirrored caches
- **Temporary exceptions allowed:** `none for duplicate canonical state; technical-layer caches require semantic classification and must not compete with the repository StreamValue`
- **Cutover / removal condition:** all active canonical and mirrored Flutter instruction surfaces express the same ownership contract and validation passes

### Patterns To Enforce
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| Repository-owned canonical shared state | `BASE-D-01` | shared collections, pagination, cache-backed/persistent state | Prevents controller-to-controller divergence and duplicate reconciliation. |
| Persistent `StreamValue` as reactive cache | `RES-D-04` | repository canonical state | Preserves one mutable source of truth. |
| Controller delegation without mirroring | `BASE-D-02` | presentation controllers | Keeps controllers as UI ingress/orchestration boundaries without creating state replicas. |
| Semantic cache review | `RES-D-05` through `RES-D-07` | controller/repository and technical adapters | Blocks duplicate state while preserving legitimate non-duplicative infrastructure caches. |

### Prohibited Anti-Patterns
| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| Controller-owned canonical list/page cache | `_cache`, `_cached*`, `_fetched*`, page-item maps/lists, reconciliation methods in controllers | Creates a second source of truth and duplicates repository lifecycle logic. | `none` |
| Repository parallel cache beside canonical `StreamValue` | mutable collection/map storing the same entities as the canonical stream | Splits invalidation and delta reconciliation between two stores. | `none` |
| Name-only cache verdict | blocking solely because an identifier contains `cache` | Confuses discovery with semantic judgment and can misclassify technical caches. | Must classify ownership and duplicated data semantics. |
| Mechanical recovery of `b9995ec` | cherry-pick or copied obsolete/project-specific sections | Reintroduces stale commands, conflicts, and redundant audit design. | `none` |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| `rule` | Flutter ownership | `rules/stacks/flutter/flutter-architecture-always-on.md` | Controller ownership of canonical shared/cache-backed state. | `already-enforced` | Preserve and clarify wording. |
| `workflow` | Controller creation | `workflows/flutter/create-controller-method.md` | New paginated caches created in controllers. | `implement-in-this-todo` | Remove conflicting instruction and add delegation contract. |
| `skill` | Flutter architecture review | `skills/flutter-architecture-adherence/SKILL.md` | Umbrella review approving duplicate canonical state. | `implement-in-this-todo` | Align review checklist/blockers with canonical rule. |
| `lint/analyzer classification` | static smell signals | `skills/deterministic-tooling-register.md` | Prose-only assumptions that should become static checks. | `implement-in-this-todo` | Refresh support notes and identify external follow-up only where missing. |
| `coherence review` | canonical + mirrors | ownership/cache `rg` scan plus `bash self_check.sh` | Contradictory ownership wording or mirror drift. | `implement-in-this-todo` | Record criterion-specific evidence before delivery. |

## Architecture Review Gates
- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `findings_integrated`
- **Decision review evidence / resolution:** `Bounded review compared b9995ec, be7a533, 6548471, the active always-on Flutter rules, the umbrella skill, the controller workflow, and system architecture principles. It corrected the initial assumption that current umbrella wording was authoritative, preserved repository-owned canonical state, narrowed cache detection to semantic duplicate-state review, and rejected stale/project-specific branch content.`
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `passed`
- **Adherence review evidence / resolution:** `Bounded canonical/mirror review confirmed one ownership contract: controller-local streams or delegation only; persistent repository streams are the canonical reactive cache; controller cache mirrors are blocked; technical caches and operational metadata are classified semantically. The review found residual generic controller-ownership wording in system architecture and controller-trigger surfaces; those findings were integrated before rerunning gates. The five existing smell skills contain the six authorized signals, and navigation remains AutoRoute/project-router based.`
- **No-go handling:** `return to the affected decision or delivery-evidence loop; do not claim APROVADO or Completed with unresolved architecture divergence`

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** The review package spans cross-module Flutter authority and mirror surfaces, so the review evidence must be tied to a committed, pushed branch baseline.
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `feat/add-stack-capabilities`
- **Baseline commit:** `d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `no_material_findings`
- **Findings summary:** `The remediation checkpoint resolves and is reachable from the recorded pushed branch; it was committed and pushed before the next review/guard cycle.`
- **Evidence / reference:** `git rev-parse d9ac4d1 -> d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9; git merge-base --is-ancestor d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9 origin/feat/add-stack-capabilities -> exit 0`
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** The P2 remediations and routed future hardening record refine review-relevant material sections after the pushed baseline.
- **Trigger stage:** `after the planning-side review/guard cycle converges and before APROVADO`
- **Baseline source:** `Review Baseline Freeze -> d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9`
- **Material sections compared:** `Context|Contract Boundary|Scope|Out of Scope|Definition of Done|Validation Steps|Execution Lane Tracking|Canonical Module Anchors|Decisions|Decision Baseline|Architecture Change Governance|Questions To Close|Assumptions Preview|Execution Plan|Flow Evidence Planning Matrix|Local CI-Equivalent Suite Matrix|Runtime / Rollout Notes|Security Risk Assessment|Performance & Concurrency Risk Assessment`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md`
- **No-go handling rule:** `return to the review loop, revalidate evolved material scope with the user, refresh the pushed baseline when needed, and rerun affected review/guard lanes; this is not a hard rejection`
- **Gate status:** `no_material_findings`
- **Findings summary:** `The guard found zero changed material sections against the pushed d9ac4d1 remediation checkpoint.`
- **Evidence / reference:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md -> go, 0 changed material sections, 2026-09-16`
- **Waiver authority / reference (required if waived):** `n/a`

## Audit Trigger Matrix
| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | Copy from the TODO Complexity section. |
| `blast_radius` | `cross-module` | Canonical rules, workflows, skills, and mirrors change together. |
| `behavioral_change_or_bugfix` | `yes` | The ownership/cache instruction behavior is corrected. |
| `changes_public_contract` | `no` | No API, schema, route, or auth-visible contract changes. |
| `touches_auth_or_tenant` | `no` | No auth, permission, or tenant-access surface changes. |
| `touches_runtime_or_infra` | `no` | No runtime, queue, realtime, or infrastructure changes. |
| `touches_tests` | `no` | No test logic, fixture, or runner changes. |
| `critical_user_journey` | `no` | No launch-critical product journey is changed. |
| `release_or_promotion_critical` | `yes` | Delivery confidence for the active instruction surface matters to promotion. |
| `high_severity_plan_review_issue` | `no` | No current high-severity plan-review issue card exists. |
| `explicit_three_lane_request` | `no` | No dedicated delivery-side three-lane internal audit was explicitly requested. |

## Independent No-Context Critique Gate
- **Critique decision:** `required`
- **Why this decision:** `medium`, cross-module, behavior-defining instruction correction, and release-critical confidence require the audit-escalation floor.
- **Impact signals in scope:** `cross-module blast radius|intentional module supersede`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `frozen baseline|approved scope boundary|assumptions preview|execution plan summary|issue cards|residual risks|existing waivers/blockers`
- **Critique isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; first fresh correctness review and first fresh tooling review were independent of the implementer`
- **Canonical multi-lane audit protocol (when required):** `recommended; audit-protocol-triple-review was not executed`
- **Audit session / round evidence (when protocol used):** `n/a`
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`
- **Critique status:** `findings_integrated`
- **Findings summary:** `The two fresh reviews found P2-01 through P2-05; P2-01 through P2-04 were corrected in the same TODO and P2-05 was routed to the real future hardening TODO.`
- **Resolution ledger:**
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `P2-01` | `Integrated` | `useful` | `partial` | `project` | `n/a` | Screen authority surfaces now distinguish local controller state from delegated canonical repository state. |
| `P2-02` | `Integrated` | `useful` | `partial` | `project` | `n/a` | Controller lifecycle guidance now disposes only controller-owned resources. |
| `P2-03` | `Integrated` | `useful` | `partial` | `project` | `n/a` | Editor-managed Flutter guidance uses the stable VS Code Problems snapshot, not a local analyzer CLI. |
| `P2-04` | `Integrated` | `useful` | `partial` | `project` | `n/a` | Active glob references and screen semantics now target canonical `create-*-method.md` surfaces. |
| `P2-05` | `Deferred` | `useful` | `yes` | `project` | `n/a` | Deterministic active-surface coherence needs a separate approved read-only guard; routed to `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md`. |
- **Evidence / reference:** `fresh correctness and tooling review findings recorded as P2-01..P2-05; current TODO routing ledger`
- **Waiver authority / reference (required if waived):** `n/a`

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `P2-01` | `P2` | `release-blocker` | `same TODO correction` | Screen workflow/skill, screen rule/skill, generated Cline workflow, Cline glob, and Claude glob are inside the approved instruction-only boundary. | `corrected` | `APROVADO 2026-09-16`; no follow-up created. |
| `P2-02` | `P2` | `release-blocker` | `same TODO correction` | Controller workflow and Cline/Claude skill mirrors are inside the approved instruction-only boundary. | `corrected` | `APROVADO 2026-09-16`; no follow-up created. |
| `P2-03` | `P2` | `release-blocker` | `same TODO correction` | Claude/Cline architecture mirror wording is inside the approved instruction-only boundary. | `corrected` | `APROVADO 2026-09-16`; no follow-up created. |
| `P2-04` | `P2` | `release-blocker` | `same TODO correction` | Claude glob workflow references and screen semantics are inside the approved instruction-only boundary. | `corrected` | `APROVADO 2026-09-16`; no follow-up created. |
| `P2-05` | `P2` | `follow-up-hardening` | `separate TODO routing` | The reviewer identified no deterministic active-surface coherence harness. Its authorship and implementation are outside the approved instruction-only scope and must occur in a separate session. | `routed` | `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md` exists as a real, Pending, unapproved future TODO. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `active Flutter instruction coherence diff and evidence packet` | `release-blocking review modes` | `passed` | `no-context reviewer /root/flutter_coherence_clean_final_review; artifacts/tmp/flutter-streamvalue-coherence-final-confirmation/review-packet.md` | `NO P1/P2` | `Clean final confirmation; historical findings are resolved or routed.` |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `Flutter ownership/cache and mirror rules` | `direct violation or disguised controller-owned canonical cache, mirror drift, or obsolete analyzer guidance` | `passed` | `artifacts/tmp/flutter-streamvalue-coherence-rule-spirit-final.json; rg -n ownership/cache/analyzer-guidance scan across skills rules workflows .cline .claude .clinerules` | `none` | `Clean rule-spirit scan; resolved findings remain in their historical ledgers.` |

## Security Risk Assessment
- **Risk level:** `none`
- **Why this risk level:** The bounded slice changes Delphi instruction and future-TODO text only; no auth, trust boundary, secret, tenant, or runtime path changes.
- **Attack surface in scope:** `none`
- **Attack simulation decision:** `not_needed`
- **Review evidence:** `audit_escalation_guard reports security_review=not_needed`
- **Residual security risk:** `none`

## Performance & Concurrency Risk Assessment
- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `none`
- **Why this level:** No runtime behavior, async product path, query shape, queue, realtime, or mutable product state changes; this is instruction/mirror and TODO-contract maintenance only.
- **Current delivery stage at review time:** `Pending`
- **Audit-escalation recommendation:** `recommended`
- **Resolution:** `not_applicable` after evaluation of the no-runtime-behavior scope; this is not a waiver.
| Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `EPS` | `endpoint-performance-scrutiny` | `not_needed` | `low` | `none` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `FRC` | `frontend-race-condition-validation` | `not_needed` | `low` | `none` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `BCI` | `backend-concurrency-idempotency-validation` | `not_needed` | `low` | `none` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `RLS` | `runtime-load-stress-validation` | `not_needed` | `low` | `none` | `before_production_ready` | `n/a` | `not_applicable` | `none` | `none` |

## Verification Debt Assessment
- **Audit outcome:** `low`
- **Why this outcome:** P2-05 is the only residual hardening debt; the current package contains no untracked code/test TODO debt.
- **Inline code TODO debt:** `none`
- **Evidence / audit artifact:** `Promotion Finding Routing Ledger P2-05; foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md`
- **Accepted residual debt:** `P2-05 is routed to the real Pending/unapproved future TODO; the follow-up implementation is not authorized in this session.`

## Independent Test Quality Audit Gate
- **Audit decision:** `required`
- **Why this decision:** The audit-escalation floor is required for this medium, behavior-defining, release-critical instruction correction even though no test logic changed.
- **Trigger signals in scope:** `bugfix/regression|behavior-defining change|architectural change|non-trivial validation risk`
- **Required evidence matrix (when architectural):** `n/a; no downstream/product test surface changed`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `frozen baseline|approved scope boundary|bounded implementation diff|validation evidence|expected behaviors/DoD|residual risks`
- **Canonical method:** `wf-docker-independent-test-quality-audit-method`
- **Audit isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; fresh internal no-context reviewer /root/flutter_coherence_test_quality_audit`
- **Gate-satisfying evidence expectation:** `required fresh internal no-context audit`
- **Audit focus:** `product/test delta alignment|bypass detection|coverage sufficiency|brittle test-only shortcuts`
- **Required applicable evidence:** `audit framing|bypass scan|issue cards for material findings|failure modes/uncertainty|decision-adherence evidence`
- **Audit status:** `no_material_findings`
- **Planning status:** `completed by fresh reviewer`
- **Findings summary:** `NO P1/P2. No-risk/bypass review found no product, test, fixture, or runner diff; the instruction-only package does not require downstream runtime test evidence. The residual risk is P2-05 only, already routed to its real future hardening TODO.`
- **Resolution ledger:** `none`
- **Evidence / reference:** `fresh review packet artifacts/tmp/flutter-streamvalue-coherence-test-audit/review-packet.md; reconciliador bash self_check.sh; independent canonical/mirror parity cmp checks; python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md; python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md --repo-root .; git diff --check`
- **Waiver authority / reference (required if waived):** `n/a`

## Independent No-Context Final Review Gate
- **Final review decision:** `required`
- **Why this decision:** The audit-escalation floor requires an expanded final review for the medium, cross-module, release-critical correction.
- **Impact signals in scope:** `cross-module blast radius|intentional module supersede`
- **Package mode:** `bounded-file-set`
- **Package minimum contents:** `frozen baseline|approved scope boundary|bounded touched-surface/diff summary|adherence status|validation evidence index|test-quality-audit evidence|residual risks|verification debt`
- **Review isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; fresh internal no-context reviewer /root/flutter_coherence_clean_final_review`
- **Canonical multi-lane audit protocol (when required):** `recommended; not executed`
- **Audit session / round evidence (when protocol used):** `n/a`
- **Review focus:** `adherence|regressions|validation evidence|security/performance residuals|elegance residuals|structural regressions|verification debt`
- **Final review status:** `no_material_findings`
- **Findings summary:** `NO P1/P2; clean. The fresh final confirmation found no new material findings; prior FR-P2 findings remain preserved below as concluded historical carry-forward.`
- **Resolution ledger:** `historical carry-forward/resolved findings:`
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `FR-P2-01` | `Integrated` | `useful` | `yes` | `project` | `n/a` | The screen example no longer downgrades the canonical repository `StreamValue` to `.stream`; it directly delegates `StreamValue<YourEntity?>` and uses `StreamValueBuilder<YourEntity?>`. |
| `FR-P2-02` | `Integrated` | `useful` | `yes` | `paced` | `n/a` | Derived audit gates and the pushed review baseline are recorded and validated; the independent test-quality audit concluded `no_material_findings`, and this clean final confirmation is concluded. |
| `FR-P2-03` | `Integrated` | `useful` | `partial` | `project` | `n/a` | The missing hardening contract is now the real Pending/unapproved TODO `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md`; no guard implementation was smuggled into this session. |
| `FR-P2-04` | `Integrated` | `useful` | `partial` | `paced` | `n/a` | Review-packet baseline evidence is frozen at pushed checkpoint `d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9`; the confirmation packet was regenerated and cleanly reviewed. |
- **Evidence / reference:** `no-context reviewer /root/flutter_coherence_clean_final_review; artifacts/tmp/flutter-streamvalue-coherence-final-confirmation/review-packet.md; current remediation diff and routed real follow-up TODO`
- **Waiver authority / reference (required if waived):** `n/a`

## Decision Adherence Validation
| Decision | Status | Evidence |
| --- | --- | --- |
| `RES-D-01` | `Adherent` | No cherry-pick was used; the bounded diff contains only reconstructed Delphi instruction intent. |
| `RES-D-02` | `Adherent` | `flutter-architecture-adherence`, rules, and screen/controller workflows limit controller-owned streams to local state. |
| `RES-D-03` | `Adherent` | Canonical rules and screen/controller workflows define persistent repository-owned streams for shared/paginated/cache-backed state. |
| `RES-D-04` | `Adherent` | Canonical rules, umbrella skill, workflows, Cline, and Claude surfaces define the repository stream as the sole reactive cache and prohibit mirrors. |
| `RES-D-05` | `Adherent` | Cache-name guidance is a semantic-review trigger; it explicitly distinguishes canonical streams, metadata, and technical caches. |
| `RES-D-06` | `Adherent` | Cursor, `hasMore`, and in-flight guards are named as operational metadata with repository-pagination ownership. |
| `RES-D-07` | `Adherent` | Transport, image, filesystem, and persistence-adapter caches remain allowed when non-duplicative. |
| `RES-D-08` | `Adherent` | Five existing smell skills hold exactly the six authorized signals; no broad audit skill was added. |
| `RES-D-09` | `Adherent` | The deterministic-tooling register identifies AST/analyzer candidates and documents the remaining semantic-review boundary. |
| `RES-D-10` | `Adherent` | No stack-capability registry, downstream analyzer, or product path changed. |

## Module Decision Consistency Validation
| Module Decision Ref | Status | Evidence |
| --- | --- | --- |
| `flutter-always-on#canonical-shared-state` | `Preserved` | The canonical Flutter and Docker rules retain and clarify repository ownership. |
| `flutter-umbrella#state-and-navigation` | `Superseded (Approved)` | The umbrella's former controller-owned shared-state wording is replaced by the approved local-versus-canonical distinction. |
| `create-controller#realtime-delta-handling` | `Superseded (Approved)` | The former controller paginated-cache instruction is replaced by repository-stream reconciliation and controller delegation. |
| `system-principles#single-source-of-truth` | `Preserved` | One persistent repository stream is specified as the single mutable representation of canonical application state. |

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | The always-on Flutter rule is the intended reusable ownership authority. | It retains the repository-owned canonical-state decision introduced by `be7a533`, and the umbrella skill declares stack rules/workflows as canonical sources. | Ownership would require a new architecture decision rather than coherence repair. | `High` | `Promote to Decision` |
| `A-02` | Current mirror tooling can synchronize all affected canonical skill/rule/workflow surfaces. | Existing Cline/Claude sync scripts and `self_check.sh` already govern these files. | The TODO would need a bounded mirror-tooling extension or an explicit manual sync rationale. | `High` | `Keep as Assumption` |
| `A-03` | The six accepted smell signals can be expressed as concise additions to existing skills. | `skills/flutter-smell-async-navigation/SKILL.md`, `flutter-smell-build-side-effects/SKILL.md`, `flutter-smell-image-media/SKILL.md`, `flutter-smell-layout-hotspots/SKILL.md`, and `flutter-smell-list-performance/SKILL.md` provide a one-to-one home; `skills/deterministic-tooling-register.md` classifies them as `lint/analyzer`; `tools/self_check.sh` and `tools/audit_instruction_baselines.sh` are concrete validation anchors for instruction structure/baselines. | Any signal requiring a new general audit framework must be removed or split. | `High` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** The execution plan depends on the current canonical/mirror topology and on the identified ownership contradictions still existing at the named insertion points.
- **Trigger stage:** `after decision review convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md`
- **Gate status:** `no_material_findings`
- **Findings summary:** `A-01 is confirmed by current canonical-source precedence and git history; A-02 is confirmed by existing Cline/Claude/clinerules sync scripts; A-03 is anchored by the existing smell-specific skills, deterministic tooling register, and instruction-validation code paths.`
- **Evidence / reference:** `git blame/log/show for b9995ec, be7a533, 6548471; current rules/stacks/flutter/flutter-architecture-always-on.md; current skills/flutter-architecture-adherence/SKILL.md; current workflows/flutter/create-controller-method.md; skills/deterministic-tooling-register.md; tools/self_check.sh; tools/audit_instruction_baselines.sh`
- **Waiver authority / reference (required if waived):** `n/a`

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md`
- `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md` (routed future hardening contract only; no implementation authorized)
- `rules/stacks/flutter/flutter-architecture-always-on.md`
- `rules/stacks/docker/flutter-architecture.md`
- `skills/flutter-architecture-adherence/SKILL.md`
- `workflows/flutter/create-controller-method.md`
- `skills/wf-flutter-create-controller-method/SKILL.md`
- affected `skills/flutter-smell-*/SKILL.md`
- `skills/deterministic-tooling-register.md`
- applicable `.cline/**`, `.claude/**`, and `.clinerules/**` mirrors

### Ordered Steps
1. Align canonical always-on rule wording so “controllers own all state” cannot conflict with repository-owned canonical shared state.
2. Align the umbrella architecture skill with the canonical local-vs-shared ownership distinction and persistent-`StreamValue` cache semantics.
3. Correct the controller workflow and workflow skill so pagination and delta reconciliation update repository canonical streams rather than controller caches.
4. Add the six bounded signals to their existing smell skills and preserve generic AutoRoute/project-router wording.
5. Refresh deterministic-tooling classifications and synchronize generated/mirrored surfaces.
6. Run coherence searches, self-check, mirror checks, diff-scope validation, and architecture adherence review.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is an instruction-coherence correction. The effective regression proof is canonical/mirror synchronization, deterministic self-check, strict diff-boundary validation, and semantic review of every ownership statement.
- **Fail-first target(s) (when required):** `not_needed; the contradictory current files and commit history are the captured pre-implementation evidence`

### Pre-APROVADO RED Evidence Capture
- **Decision (`required|recommended|not_needed|waived`):** `not_needed`
- **Why now:** The regression is documentary/instructional and already reproduced by conflicting active authority surfaces.
- **Target symptom:** `n/a`
- **Allowed surfaces:** `n/a`
- **Forbidden surfaces reaffirmed:** `all implementation surfaces before APROVADO`
- **Planned command / target:** `n/a`
- **Status (`not_run|running|red_reproduced|red_not_reproduced|blocked|waived`):** `waived`
- **Findings summary:** `Current umbrella/controller workflow contradict the active always-on repository-ownership rule.`

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Exact Behavior / Scenario Proved | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / self-check` | Canonical skills, workflows, rules, and mirrors remain coherent. | `bash self_check.sh` | `Local-Implemented` | `passed` | `bash self_check.sh` | Final bounded working tree; refreshed curated mirrors without unrelated working-tree changes. |
| `delphi-ai / changed mirror synchronization` | Changed Cline/Claude/clinerules mirrors equal their canonical skills/workflows. | `bash tools/sync_cline_skill_mirrors.sh ...`; `bash tools/sync_claude_skill_mirrors.sh ...`; `bash tools/sync_clinerules_mirrors.sh create-controller create-screen`; direct `cmp` | `Local-Implemented` | `passed` | sync commands, direct `cmp`, and `bash self_check.sh` | Changed canonical/mirror pairs synchronize and compare equal. |
| `downstream / adherence sync` | Full downstream `.agents`-based adherence suite is evaluated only where that topology exists. | `bash tools/verify_adherence_sync.sh` | `Local-Implemented` | `n/a` | standalone checkout topology inspection | Not applicable: this standalone Delphi checkout lacks the downstream `.agents/{rules,workflows}` directories required by the suite; this is not a waiver, and direct changed-mirror synchronization is recorded above. |
| `delphi-ai / diff boundary` | This first slice changes only its approved Flutter instruction package. | `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md --repo-root .` | `Local-Implemented` | `passed` | guard output | Baseline `2f2fa77`; all observed paths must remain classified. |

## Approval
- **Approved by:** `user on 2026-09-16 with explicit "APROVADO"`
- **Approval scope:** `implement the bounded Delphi Flutter instruction package defined by this TODO: canonical StreamValue/cache ownership coherence, controller workflow correction, six selected smell signals, tooling-register refresh, mirror synchronization, and local validation`
- **Execution not authorized by approval:** `cherry-pick of b9995ec, downstream product/analyzer changes, flutter-clean-code-audit, stack-capability expansion, or any scope not listed above`
- **Renewed approval required when:** `state/cache ownership, selected smell set, touched repository boundary, or validation obligations change materially`

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | This is a Delphi self-improvement session and correction-scope decision. | Instruction-only boundary, agnosticism, explicit reload before later architectural work. | Downstream implementation or project-specific truth in Delphi core. | Keep all edits inside Delphi instruction surfaces and complete post-session review at closure. |
| `workflows/docker/self-improvement-session-method.md` | Governs instruction refinement. | Scope triage, agnosticism review, validation, and explicit closure. | Mixing instruction refinement with downstream code changes. | Treat this TODO as the sole implementation authority for the session. |
| `rules/core/todo-driven-execution-model-decision.md` | This is durable Delphi architecture maintenance. | Explicit APROVADO, frozen decisions, strict diff boundary, criterion-specific evidence. | Implementation before approval or hidden scope expansion. | Run pre-approval and post-approval authority gates at their required phases. |
| `workflows/docker/update-skill-method.md` | Existing Flutter skills will be materially changed. | Canonical-first edits, tooling-register classification, mirror synchronization. | Hand-edited mirror drift or prose-only deterministic claims. | Sync and validate every exposed skill surface. |
| `skills/flutter-architecture-adherence/SKILL.md` | The TODO corrects Flutter architecture ownership semantics. | Widget purity, controller ingress boundary, repository/domain separation, project-local override hierarchy. | Treating current contradictory umbrella wording as higher authority than canonical rules. | Perform final rule-spirit/adherence review after implementation. |
| `/home/elton/.codex/skills/.system/skill-creator/SKILL.md` | Material skill updates require concise, self-contained, appropriately specific guidance. | Non-obvious reusable rules, minimal duplication, validation of changed skills. | Generic audit duplication and project-specific examples. | Keep smell additions narrow and reuse existing skills. |

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-terra`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a`

## TODO Closeout Disposition
- **Disposition:** `keep-active`
- **Disposition reason:** The implementation and local review are complete, but the feature branch has not been integrated or promoted and the user authorized only commit/push in this step.
- **Post-commit/push status:** `complete - implementation commit d08390e, remediation checkpoint d9ac4d1c589a1219f8f470b25e138ea9bf5fa1f9, and final clean-review checkpoint cab69fb95386501364b14b8ab43c9717e31a235e pushed to origin/feat/add-stack-capabilities on 2026-09-16; delivery stage is Local-Implemented`
- **Next path/status action:** `remain in active/review after push until the branch integration or promotion path is explicitly selected`
