# TODO: Delphi Skill Test Drive and Promotion Routing

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade branch now uses phase skills for TODO-driven execution. The next risk is not only structural drift, but agent-behavior drift: an agent may load the umbrella skill and still skip the intended phase, closeout, or promotion gate. The same risk exists in the large stage-promotion orchestrator, which still mixes lane classification, source promotion, Docker gitlink handling, web-app boundaries, failure handling, and completion reporting.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The work is one Delphi self-maintenance slice: verify independent-agent understanding of the new skill model, then encode the highest-value routing improvements.
- **Direct-to-TODO rationale:** The user explicitly requested continuing with improvements and proposed a test drive with independent agents to validate behavior.

## Contract Boundary
- This TODO defines **WHAT** must be delivered and what counts as done.
- The work is bounded to Delphi self-maintenance under `delphi-ai/`.
- If independent-agent feedback reveals a larger architecture rewrite, record it as follow-up instead of expanding this TODO beyond skill routing, promotion closeout, and validation support.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Production-Ready`
- **Qualifiers:** `none`
- **Next exact step:** Closed; follow-up candidates are tracked in `foundation_documentation/todos/active/delphi-model-upgrade-follow-up-validation.md`.

## Scope
- [x] Run a no-context independent-agent test drive for TODO-driven routing, stage-promotion routing, and stack-capability/topology interpretation.
- [x] Preserve TODO-driven phase semantics while improving deterministic protection against missing phase surfaces.
- [x] Split or route the stage-promotion orchestrator so independent agents can choose the right promotion lane without loading a 3000-word skill body.
- [x] Clarify TODO closeout behavior for pushed-but-not-promoted work, including the `active` versus `promotion_lane` versus `completed` path.
- [x] Sync Cline/Claude/.clinerules mirrors and update deterministic maintenance registers for any new skill/workflow surfaces.

## Out of Scope
- [ ] Promote this branch through `dev`, `stage`, or `main`.
- [ ] Change downstream Belluga Now project code.
- [ ] Change GitHub promotion tooling behavior beyond instruction/routing clarity unless required by validation.
- [ ] Replace human judgment in independent-agent reviews with fake deterministic authority.

## Definition of Done
- [x] Independent-agent test drive findings are recorded and resolved as `Integrated/Challenged/Deferred`.
- [x] TODO-driven phase-surface completeness is checked deterministically or through `self_check` with explicit coverage.
- [x] Stage-promotion guidance is smaller and phase/routing-oriented while preserving hard rules for `dev-only`, `through-stage`, `bot/next-version`, gitlinks, and generated `web-app`.
- [x] TODO closeout/promotion path is unambiguous for local-only, pushed, lane-promoted, and completed states.
- [x] Local checks pass for instruction coherence, syntax, mirror sync, and TODO completion guard.

## Validation Steps
- [x] Run `bash self_check.sh`.
- [x] Run syntax checks for changed Python or shell tooling.
- [x] Run `git diff --check`.
- [x] Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`.
- [x] Run any new validator/test introduced by this TODO.

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| multi-agent subagents | Needed for the no-context test drive requested by the user. | `healthy` | `2026-05-25` | `multi_agent_v1.spawn_agent` returned three independent agent ids. | If an agent fails, record the failed lane and run one narrower retry. |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `none`
- **Scope-check command:** `n/a - Delphi self-maintenance`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `independent no-context agents` | Validate skill comprehension without chat contamination. | TODO-driven, promotion, and topology skill surfaces. | completed |

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single-pass with independent-agent evidence before final validation`
- **Why this level:** Multiple instruction and mirror surfaces may change, and no product runtime is touched. The behavior risk is real but bounded to Delphi self-maintenance.

## Canonical Module Anchors
- **Primary module doc:** `skills/github-stage-promotion-orchestrator/SKILL.md`
- **Secondary module docs:**
  - `skills/wf-docker-todo-driven-execution-method/SKILL.md`
  - `workflows/docker/todo-driven-execution-method.md`
  - `workflows/docker/todo-closeout-promotion-method.md`
  - `skills/deterministic-tooling-register.md`
- **Planned decision promotion targets (module sections):**
  - `skills/github-stage-promotion-orchestrator/SKILL.md` routing and hard-rule sections.
  - `workflows/docker/todo-closeout-promotion-method.md` closeout lane policy.
  - `skills/deterministic-tooling-register.md` support classification.
- **Module decision consolidation targets (required):**
  - Same as planned decision promotion targets.

## Decisions
- [x] `D-01` Use fresh no-context agents as challenge evidence, not as authority.
- [x] `D-02` Keep TODO-driven phase semantics intact; improve protection around comprehension and surface completeness.
- [x] `D-03` Treat stage-promotion as the next phase-routing candidate because `self_check` flags its skill body as large and local analysis found it mixes several lanes.

## Decision Baseline (Frozen Before Implementation)
- [x] The TODO-driven umbrella remains the entrypoint and state machine.
- [x] Independent-agent results must be folded back into this TODO; they do not override the governing TODO.
- [x] Stage promotion remains manual-only and must never continue to `main`.
- [x] Generated `web-app` remains derived artifact evidence only, not a manual promotion target.

## Questions To Close
- [x] Is a no-context independent-agent test drive appropriate for this package? Yes; user explicitly proposed it and subagent tooling is available.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence | Handling |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Stage-promotion can be improved by routing/splitting without changing promotion semantics. | `skills/github-stage-promotion-orchestrator/SKILL.md` is 3000 words and already has separable classification/scenario/failure/completion sections. | If false, preserve the skill and record only test-drive findings. | High | Keep as Assumption |
| `A-02` | A deterministic phase-surface validator can support TODO-driven comprehension without pretending to judge semantic quality. | Existing `self_check` already validates counterpart and mirror coherence. | If false, keep validation in `self_check` and record the gap. | Medium | Keep as Assumption |
| `A-03` | Pushed-but-not-promoted TODOs need a clearer lane than remaining indefinitely in `active` with `Local-Implemented`. | `foundation_documentation/todos/active/` currently contains three `Local-Implemented` TODOs that pass the completion guard. | If false, leave path policy unchanged and document why active is intentional. | High | Keep as Assumption |

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-skill-test-drive-and-promotion-routing.md`
- `skills/github-stage-promotion-orchestrator/SKILL.md`
- `skills/deterministic-tooling-register.md`
- `workflows/docker/todo-closeout-promotion-method.md`
- `tools/` validation support if needed.
- `.cline/`, `.claude/`, and `.clinerules/` mirrors generated by sync tools.

### Ordered Steps
1. Collect independent-agent test-drive findings.
2. Resolve findings into this TODO as integrated, challenged, or deferred.
3. Implement bounded routing/split/validation improvements.
4. Sync mirrors and run local validation.
5. Fill completion evidence and run the TODO completion guard.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is instruction/tooling maintenance; validation is structural coherence, deterministic helper tests, and no-context behavior review rather than product runtime TDD.
- **Fail-first target(s):** `n/a - no product behavior or parser bug is being fixed yet`

### Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi instruction routing | `structure-only` | `n/a` | `n/a` | `no` | `no` | self-check, validator/tests, independent-agent evidence | No product runtime or user-facing app flow changes. |

### Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / instruction self-check` | Skills/workflows/mirrors may change. | `bash self_check.sh` | `Local-Implemented` | passed | `bash self_check.sh` | Passed with 203 files checked, 0 individual failures, and 0 coherence failures. |
| `delphi-ai / syntax checks` | Python and shell tooling changed. | `python3 -m py_compile tools/environment_topology_contract_scaffold.py tools/validate_phase_surfaces.py`; `bash -n tools/github_promotion_action_guard.sh tools/github_promotion_diff_guard.sh tools/tests/environment_topology_contract_scaffold_test.sh tools/tests/github_promotion_guard_policy_test.sh tools/self_check.sh` | `Local-Implemented` | passed | listed commands | Python and shell syntax checks passed. |
| `delphi-ai / focused helper tests` | Promotion guard policy, topology scaffold, and phase-surface validator changed. | `bash tools/tests/environment_topology_contract_scaffold_test.sh`; `bash tools/tests/github_promotion_guard_policy_test.sh`; `python3 tools/validate_phase_surfaces.py` | `Local-Implemented` | passed | listed commands | All focused tests passed. |
| `delphi-ai / diff hygiene` | Markdown/config/tool edits can introduce whitespace issues. | `git diff --check` | `Local-Implemented` | passed | `git diff --check` | No whitespace errors. |

### Runtime / Rollout Notes
- `n/a - Delphi instruction/tooling maintenance only`

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
- **Issue ID:** ARCH-01
  - **Severity:** medium
  - **Evidence:** `skills/github-stage-promotion-orchestrator/SKILL.md` is the only skill over the self-check large-body threshold.
  - **Why it matters now:** Agents may miss lane-specific hard rules when a single skill mixes too many scenarios.
  - **Recommendation:** Split or route stage-promotion phases while keeping hard rules visible in the parent skill.
- **Issue ID:** TEST-01
  - **Severity:** medium
  - **Evidence:** TODO-driven phase split currently relies on `self_check` plus mirror coherence, not a focused phase-surface completeness validator.
  - **Why it matters now:** A future phase skill could be added without its workflow/mirror/register counterpart and still rely on human memory.
  - **Recommendation:** Add or extend deterministic validation for the phase-surface map.
- **Issue ID:** OPS-01
  - **Severity:** medium
  - **Evidence:** Three `Local-Implemented` TODOs pass the completion guard but remain under `active/`.
  - **Why it matters now:** Closeout policy is ambiguous after push but before promotion.
  - **Recommendation:** Clarify `active` versus `promotion_lane` versus `completed` semantics.

### Failure Modes & Edge Cases
- [x] Independent agents identify contradictory routing expectations; resolve explicitly instead of averaging opinions.
- [x] Stage-promotion split hides hard rules; keep manual-only/main/web-app/gitlink gates visible in the umbrella.
- [x] Validator becomes fake semantic authority; keep it structural only.

### Residual Unknowns / Risks
- [x] Subagent behavior in this environment may differ from future model versions; record findings as regression signals, not proof forever.

## Approval
- **Approved by:** user instruction on 2026-05-25: "Pode seguir."

## Independent-Agent Test Drive
| Agent | Scope | Status | Findings Summary | Resolution |
| --- | --- | --- | --- | --- |
| `Jason` | TODO-driven routing scenarios. | completed | Routing was mostly understandable; risks: completion guard is necessary but narrow, `APROVADO`/rule ingestion can be skipped by a careless agent, typo-only docs lane was ambiguous, closeout after push must stay tied to the same TODO. | Integrated: delivery gates now state guard pass is not a substitute for approval/rule ingestion; lane framing clarifies typo-only operational notes; closeout workflow clarifies `active`/`promotion_lane`/`completed`. Deferred: deeper deterministic APROVADO/rule-ingestion validation as future guard work. |
| `Cicero` | Stage-promotion routing and split candidate. | completed | Stage promotion was not reliable enough for independent agents: large skill body, `dev-only` Docker-finalization ambiguity, `bot/next-version -> stage` loophole, missing scenario phase routing, weak `web-app` mutation enforcement. | Integrated: stage promotion is now an umbrella plus eight phase skills; `dev-only` semantics are explicit; action/diff guards block `bot/next-version -> stage`; action guard blocks generated `web-app` PR mutation; guard-policy test added. Deferred: a full deterministic scenario classifier and exact dispatcher recovery commands. |
| `Hilbert` | Global capabilities versus active project topology. | completed | Capability registry was conceptually correct, but topology scaffold used `Active? yes` for inferred evidence, generic Composer could imply Laravel, runners could come from dependency folders, and foundation docs were named as priority without being surfaced. | Integrated: scaffold now emits `candidate` activation evidence, avoids generic Composer-as-Laravel, prunes dependency/build folders for runners, surfaces foundation documentation hints, and adds negative tests. Deferred: registry-driven stack detection for future capability additions. |

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Run a no-context independent-agent test drive for TODO-driven routing, stage-promotion routing, and stack-capability/topology interpretation. | review | `multi_agent_v1` agents `Jason`, `Cicero`, `Hilbert` | local agents | passed | Three independent no-context agents completed and findings were resolved in this TODO. |
| `SCOPE-02` | `Scope` | Preserve TODO-driven phase semantics while improving deterministic protection against missing phase surfaces. | tool/self-check | `tools/validate_phase_surfaces.py`; `python3 tools/validate_phase_surfaces.py` | local shell | passed | Validator checks TODO-driven and stage-promotion phase skills/mirrors/register surfaces. |
| `SCOPE-03` | `Scope` | Split or route the stage-promotion orchestrator so independent agents can choose the right promotion lane without loading a 3000-word skill body. | file diff | `skills/github-stage-promotion-orchestrator/SKILL.md` phase route list; `skills/github-stage-promotion-*/SKILL.md` | local files | passed | Stage promotion now routes through an umbrella plus eight phase skills. |
| `SCOPE-04` | `Scope` | Clarify TODO closeout behavior for pushed-but-not-promoted work, including the `active` versus `promotion_lane` versus `completed` path. | file diff | `workflows/docker/todo-closeout-promotion-method.md`; `skills/github-stage-promotion-closeout-report/SKILL.md` | local files | passed | Closeout path now distinguishes active, promotion lane, completed, and local-only Delphi self-maintenance. |
| `SCOPE-05` | `Scope` | Sync Cline/Claude/.clinerules mirrors and update deterministic maintenance registers for any new skill/workflow surfaces. | self-check | `bash self_check.sh`; `skills/deterministic-tooling-register.md`; `.cline/skills`; `.claude/skills`; `.clinerules` | local shell | passed | Self-check synchronized 83 Cline skills, 81 Claude skills, 46 `.clinerules` mirrors, and passed coherence. |
| `DOD-01` | `Definition of Done` | Independent-agent test drive findings are recorded and resolved as `Integrated/Challenged/Deferred`. | review | `Independent-Agent Test Drive` section in this TODO | local agents | passed | Findings from all three agents are recorded with integrated/deferred resolutions. |
| `DOD-02` | `Definition of Done` | TODO-driven phase-surface completeness is checked deterministically or through `self_check` with explicit coverage. | tool/self-check | `python3 tools/validate_phase_surfaces.py`; `bash self_check.sh` | local shell | passed | Phase-surface validator returned OK and is now part of `tools/self_check.sh`. |
| `DOD-03` | `Definition of Done` | Stage-promotion guidance is smaller and phase/routing-oriented while preserving hard rules for `dev-only`, `through-stage`, `bot/next-version`, gitlinks, and generated `web-app`. | file diff | `skills/github-stage-promotion-orchestrator/SKILL.md`; `skills/github-stage-promotion-*/SKILL.md`; `tools/github_promotion_action_guard.sh`; `tools/github_promotion_diff_guard.sh` | local files | passed | Umbrella retains manual-only, no-main, dev-only, through-stage, gitlink, and web-app gates; guards enforce bot/web constraints. |
| `DOD-04` | `Definition of Done` | TODO closeout/promotion path is unambiguous for local-only, pushed, lane-promoted, and completed states. | file diff | `workflows/docker/todo-closeout-promotion-method.md`; `skills/github-stage-promotion-closeout-report/SKILL.md` | local files | passed | Closeout lane semantics are explicit. |
| `DOD-05` | `Definition of Done` | Local checks pass for instruction coherence, syntax, mirror sync, and TODO completion guard. | command | `bash self_check.sh`; `python3 -m py_compile ...`; `bash -n ...`; `git diff --check` | local shell | passed | Approved structure-only waiver/deviation: Delphi instruction-only change, no user-visible interactive flow or product runtime behavior. |
| `VAL-01` | `Validation Steps` | Run `bash self_check.sh`. | command | `bash self_check.sh` | local shell | passed | Passed with 203 files checked, 0 individual failures, and 0 coherence failures. |
| `VAL-02` | `Validation Steps` | Run syntax checks for changed Python or shell tooling. | command | `python3 -m py_compile tools/environment_topology_contract_scaffold.py tools/validate_phase_surfaces.py`; `bash -n tools/github_promotion_action_guard.sh tools/github_promotion_diff_guard.sh tools/tests/environment_topology_contract_scaffold_test.sh tools/tests/github_promotion_guard_policy_test.sh tools/self_check.sh` | local shell | passed | Python and shell syntax checks passed. |
| `VAL-03` | `Validation Steps` | Run `git diff --check`. | command | `git diff --check` | local shell | passed | No whitespace errors. |
| `VAL-04` | `Validation Steps` | Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`. | command | `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-skill-test-drive-and-promotion-routing.md` | local shell | passed | Final guard returned `Overall outcome: go`. |
| `VAL-05` | `Validation Steps` | Run any new validator/test introduced by this TODO. | command | `python3 tools/validate_phase_surfaces.py`; `bash tools/tests/github_promotion_guard_policy_test.sh`; `bash tools/tests/environment_topology_contract_scaffold_test.sh` | local shell | passed | New validator and updated/new tests passed. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| independent-agent test drive + bounded diff review | CI/Copilot-style risk from skill routing, promotion guards, topology inference, mirror drift, and phase-surface omissions | passed | `Jason`, `Cicero`, `Hilbert` no-context reviews; `bash self_check.sh`; `bash tools/tests/github_promotion_guard_policy_test.sh`; `python3 tools/validate_phase_surfaces.py`; `git diff --check` | High-severity issues found and fixed: `bot/next-version -> stage` guard loophole and ambiguous `dev-only` app completion semantics. Medium-severity issues found and fixed/deferred: topology candidate wording, generic Composer Laravel inference, phase-surface validator, closeout path clarity. | Integrated findings are implemented; deferred items are non-blocking future work: full promotion scenario classifier, registry-driven topology detection, and stronger APROVADO/rule-ingestion deterministic validation. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO-driven and promotion phase routing | New subskills or validators hiding approval/promotion gates, replacing user approval, bypassing `APROVADO`, allowing direct lane mutation, or treating generated artifacts as source lanes | passed | `skills/github-stage-promotion-orchestrator/SKILL.md`; `skills/github-stage-promotion-*/SKILL.md`; `workflows/docker/todo-delivery-gates-method.md`; `tools/github_promotion_action_guard.sh`; `tools/github_promotion_diff_guard.sh`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules` | Scanner reported six review-only self/tool/test references around the words bypass/guard; independent review found no unresolved high-severity issue after the guard and routing fixes. | Umbrellas keep hard gates visible; validator is structural only; completion guard pass is explicitly not a substitute for approval/rule ingestion; generated `web-app` PR mutation is blocked by action guard. |
