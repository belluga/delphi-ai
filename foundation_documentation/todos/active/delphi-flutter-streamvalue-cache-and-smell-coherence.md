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
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** `await an explicit branch integration or promotion decision before moving this TODO from active/review`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The approved instruction package is implemented and local validation has passed; it awaits the branch-owned delivery review/closeout.
- **Exit condition:** The bounded diff, validation evidence, and architecture-adherence review are accepted by the owning closeout lane.

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
| `delphi-ai` | `skills/flutter-*/SKILL.md` | `M` | Canonical umbrella and bounded smell-skill alignment. |
| `delphi-ai` | `skills/rule-flutter-flutter-architecture-always-on/SKILL.md` | `M` | Generated/curated rule skill alignment. |
| `delphi-ai` | `skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Controller trigger wording must preserve local ownership and canonical repository delegation. |
| `delphi-ai` | `skills/rule-docker-flutter-architecture/SKILL.md` | `M` | Docker-exposed Flutter rule alignment. |
| `delphi-ai` | `skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Controller workflow skill alignment. |
| `delphi-ai` | `skills/deterministic-tooling-register.md` | `M` | Deterministic support classification. |
| `delphi-ai` | `rules/stacks/flutter/flutter-architecture-always-on.md` | `M` | Canonical Flutter ownership/cache wording. |
| `delphi-ai` | `rules/stacks/flutter/flutter-controller-workflow-glob.md` | `M` | Controller trigger wording must not reintroduce generic controller ownership of canonical streams. |
| `delphi-ai` | `rules/stacks/docker/flutter-architecture.md` | `M` | Docker-exposed canonical Flutter wording. |
| `delphi-ai` | `system_architecture_principles.md` | `M` | Appendix-level Flutter tenet must distinguish local controller state from delegated canonical repository state. |
| `delphi-ai` | `workflows/flutter/create-controller-method.md` | `M` | Canonical controller workflow correction. |
| `delphi-ai` | `.cline/skills/flutter-*/SKILL.md` | `M` | Generated Cline skill mirrors. |
| `delphi-ai` | `.claude/skills/flutter-*/SKILL.md` | `M` | Generated Claude skill mirrors. |
| `delphi-ai` | `.cline/skills/rule-*-flutter-architecture*/SKILL.md` | `M` | Generated Cline mirrors for the changed Flutter architecture rule skills. |
| `delphi-ai` | `.claude/skills/rule-*-flutter-architecture*/SKILL.md` | `M` | Generated Claude mirrors for the changed Flutter architecture rule skills. |
| `delphi-ai` | `.cline/skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Generated Cline mirror for the corrected controller trigger. |
| `delphi-ai` | `.claude/skills/rule-flutter-flutter-controller-workflow-glob/SKILL.md` | `M` | Generated Claude mirror for the corrected controller trigger. |
| `delphi-ai` | `.cline/skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Generated Cline mirror for the changed controller workflow skill. |
| `delphi-ai` | `.claude/skills/wf-flutter-create-controller-method/SKILL.md` | `M` | Generated Claude mirror for the changed controller workflow skill. |
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
| `DOD-01` | `Definition of Done` | Ownership rules are coherent across active Delphi Flutter authority surfaces. | `review` | ownership consistency search plus canonical/mirror file review | `local` | `passed` | Final review also aligned the system-principles tenet, controller glob rule/skill, Cline glob rule, and Claude glob rule; all active surfaces now limit controllers to local state/delegation and repositories to canonical state. |
| `DOD-02` | `Definition of Done` | Controller-owned canonical paginated cache guidance is removed. | `review` | `rg` ownership/cache scan | `local` | `passed` | Controller workflow and its Cline/Claude mirrors direct delta/pagination reconciliation to the repository stream. |
| `DOD-03` | `Definition of Done` | Persistent repository `StreamValue` is defined as canonical reactive cache. | `doc` | canonical rule, umbrella skill, and controller workflow | `local` | `passed` | All three explicitly identify the repository `StreamValue` as the sole canonical reactive cache. |
| `DOD-04` | `Definition of Done` | Selected smell signals are present without a duplicate audit skill. | `review` | five changed smell skills and rejected-path check | `local` | `passed` | Exactly the six accepted signals were added to existing smell skills; no `flutter-clean-code-audit` path exists. |
| `DOD-05` | `Definition of Done` | Mirrors and tooling classifications are synchronized. | `test` | sync scripts, canonical/mirror `cmp`, `bash self_check.sh` | `local` | `passed` | Cline/Claude synchronization covered all ten changed skills; controller workflow and controller-trigger surfaces were aligned. |
| `VAL-01` | `Validation Steps` | Delphi self-check passes. | `test` | `bash self_check.sh` | `local` | `passed` | Exit 0; changed skills passed and all curated mirrors were synchronized. |
| `VAL-02` | `Validation Steps` | Diff expectation guard passes. | `test` | `python3 tools/todo_diff_expectation_guard.py ... --repo-root .` | `local` | `passed` | `Overall outcome: go`; 42 actual paths match the strict contract after final-review coherence fixes. |
| `VAL-03` | `Validation Steps` | Patch is whitespace/error clean. | `test` | `git diff --check` | `local` | `passed` | Exit 0. |

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
- [x] `D-01` Do not cherry-pick `b9995ec`; selectively reconstruct valid intent against current Delphi architecture.
- [x] `D-02` Controller-owned `StreamValue` is limited to local screen, stage, form, and interaction state.
- [x] `D-03` Canonical cross-screen, paginated, cache-backed, or persistence-aligned state is a persistent repository-owned `StreamValue` exposed through controller delegation.
- [x] `D-04` The persistent repository `StreamValue` is itself the canonical application-level reactive cache; parallel mutable copies of the same canonical data are prohibited.
- [x] `D-05` Cache-name scans are mandatory semantic-review triggers. A match is presumed suspect until classified, but the final violation decision depends on duplicated canonical state rather than spelling alone.
- [x] `D-06` Cursor, `hasMore`, and in-flight request guards are operational metadata, not automatically duplicate caches; their ownership must still be coherent with repository pagination.
- [x] `D-07` Transport, image, filesystem, and persistence caches may exist when they do not become a competing application-state source of truth.
- [x] `D-08` Port only the six bounded smell signals identified in scope and do not introduce `flutter-clean-code-audit`.
- [x] `D-09` Prefer analyzer/lint enforcement for statically reliable signals, but keep external analyzer implementation outside this Delphi-only TODO.
- [x] `D-10` This TODO is the first implementation slice of `feat/add-stack-capabilities`; stack-capability expansion remains a later independent slice on the branch.

## Module Decision Baseline Snapshot (Required Before APROVADO)
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `flutter-always-on#canonical-shared-state` | Repository owns cross-controller/module, cache-backed, persistence-aligned state. | `Preserve` | Introduced on main by `be7a533`; still present in the active always-on rule. |
| `flutter-umbrella#state-and-navigation` | Current shortened wording says official shared state is controller-owned. | `Supersede (Intentional)` | Introduced by umbrella simplification in `6548471`; conflicts with the always-on rule. |
| `create-controller#realtime-delta-handling` | Controller maintains a paginated cache. | `Supersede (Intentional)` | Surviving workflow text originates from `cbfff86` and conflicts with repository-owned canonical state. |
| `system-principles#single-source-of-truth` | Cache is a deliberate optimization and must not become the data model/source of truth. | `Preserve` | `system_architecture_principles.md`, Single Source of Truth principle. |

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` There will be one canonical mutable representation of shared application state: the persistent repository-owned `StreamValue`.
- [x] `D-02` Controllers orchestrate and expose canonical streams but do not mirror canonical repository data into local caches.
- [x] `D-03` Cache review is semantic and fail-closed: suspected parallel state must be removed or explicitly proven to be non-duplicative technical caching/metadata.
- [x] `D-04` The resulting Delphi instructions remain project-agnostic and compatible with project-local architecture overrides through the existing cascading hierarchy.
- [x] `D-05` No rejected or obsolete content from `b9995ec` may re-enter through mechanical copying.

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
| Repository-owned canonical shared state | `D-03` | shared collections, pagination, cache-backed/persistent state | Prevents controller-to-controller divergence and duplicate reconciliation. |
| Persistent `StreamValue` as reactive cache | `D-04` | repository canonical state | Preserves one mutable source of truth. |
| Controller delegation without mirroring | `D-02` | presentation controllers | Keeps controllers as UI ingress/orchestration boundaries without creating state replicas. |
| Semantic cache review | `D-05` through `D-07` | controller/repository and technical adapters | Blocks duplicate state while preserving legitimate non-duplicative infrastructure caches. |

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

## Decision Adherence Validation
| Decision | Status | Evidence |
| --- | --- | --- |
| `D-01` | `Adherent` | No cherry-pick was used; the bounded diff contains only reconstructed Delphi instruction intent. |
| `D-02` | `Adherent` | `flutter-architecture-adherence`, rules, and controller workflow limit controller-owned streams to local state. |
| `D-03` | `Adherent` | Canonical rules and controller workflow define persistent repository-owned streams for shared/paginated/cache-backed state. |
| `D-04` | `Adherent` | Canonical rules, umbrella skill, workflow, Cline, and Claude surfaces define the repository stream as the sole reactive cache and prohibit mirrors. |
| `D-05` | `Adherent` | Cache-name guidance is a semantic-review trigger; it explicitly distinguishes canonical streams, metadata, and technical caches. |
| `D-06` | `Adherent` | Cursor, `hasMore`, and in-flight guards are named as operational metadata with repository-pagination ownership. |
| `D-07` | `Adherent` | Transport, image, filesystem, and persistence-adapter caches remain allowed when non-duplicative. |
| `D-08` | `Adherent` | Five existing smell skills hold exactly the six authorized signals; no broad audit skill was added. |
| `D-09` | `Adherent` | The deterministic-tooling register identifies AST/analyzer candidates and documents the remaining semantic-review boundary. |
| `D-10` | `Adherent` | No stack-capability registry, downstream analyzer, or product path changed. |

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
| `A-03` | The six accepted smell signals can be expressed as concise additions to existing skills. | Each signal maps directly to an existing smell-specific skill already classified as an analyzer candidate. | Any signal requiring a new general audit framework must be removed or split. | `High` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** The execution plan depends on the current canonical/mirror topology and on the identified ownership contradictions still existing at the named insertion points.
- **Trigger stage:** `after decision review convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `manual bounded source/history inspection; no standalone assumption-code guard is required for this instruction-only slice`
- **Gate status:** `no_material_findings`
- **Findings summary:** `A-01 is confirmed by current canonical-source precedence and git history; A-02 is confirmed by existing Cline/Claude/clinerules sync scripts; A-03 is confirmed by the one-to-one mapping between each accepted signal and an existing smell-specific skill.`
- **Evidence / reference:** `git blame/log/show for b9995ec, be7a533, 6548471; current rules/stacks/flutter/flutter-architecture-always-on.md; current skills/flutter-architecture-adherence/SKILL.md; current workflows/flutter/create-controller-method.md; skills/deterministic-tooling-register.md`
- **Waiver authority / reference (required if waived):** `n/a`

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md`
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
| Repository / CI Surface | Why In Scope | Exact Behavior / Scenario Proved | Fixture / Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / self-check` | Canonical skills, workflows, rules, and mirrors change. | Delphi instruction and mirror coherence remains valid. | Final bounded working tree. | `bash self_check.sh` | `Local-Implemented` | `passed` | `bash self_check.sh` | Exit 0; refreshed all curated mirrors without unrelated working-tree changes. |
| `delphi-ai / adherence sync` | Flutter architecture surfaces and mirrors change. | Canonical adherence surfaces do not drift from generated/consumer forms. | The parent workspace must expose Flutter/Laravel `.agents` rule/workflow links. | `bash tools/verify_adherence_sync.sh` | `Local-Implemented` | `waived` | `bash tools/verify_adherence_sync.sh`; direct canonical/mirror comparisons | Exit 1 only because pre-existing `/home/elton/Dev/repos/{flutter-app,laravel-app}/.agents/{rules,workflows}` directories are absent. Delphi self-maintenance policy uses `self_check.sh` plus explicit mirror checks; direct Cline/Claude comparisons for all ten changed skills passed. |
| `delphi-ai / diff boundary` | The branch also has later stack-capability intent. | This first slice changes only its approved Flutter instruction package. | Baseline `2f2fa77`; TODO diff contract populated. | `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-flutter-streamvalue-cache-and-smell-coherence.md --repo-root .` | `Local-Implemented` | `passed` | guard output | `Overall outcome: go`; all 42 actual paths are classified. |

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
- **Post-commit/push status:** `complete - implementation commit d08390e pushed to origin/feat/add-stack-capabilities on 2026-09-16`
- **Next path/status action:** `remain in active/review after push until the branch integration or promotion path is explicitly selected`
