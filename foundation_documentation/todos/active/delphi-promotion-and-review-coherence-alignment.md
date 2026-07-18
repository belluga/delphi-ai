# TODO: Delphi Promotion and Review Coherence Alignment

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Recent Delphi self-improvement decisions changed two operational canons that must now be made mechanical and consistent across the promotion and review surfaces:
1. delivery-side dedicated audit baseline is `Performance` + `Test Quality`, with `cutover-integrity` conditional and `Elegance` kept in critique/final review rather than as a dedicated audit lane; every Delphi review gate uses fresh internal no-context reviewers only;
2. Docker promotion must be surface-first, with mixed Docker lanes requiring deterministic `dev` admission checks so `dev -> stage` cannot proceed while required `-> dev` tracks are still pending.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The user approved a bounded Delphi self-maintenance package to convert the newly agreed definitions into canonical docs, guards, and tests.
- **Direct-to-TODO rationale:** This is instruction/tooling maintenance inside Delphi itself; a separate feature brief would only duplicate already-frozen session decisions.

## Contract Boundary
- This TODO defines **WHAT** must be delivered so Delphi promotion and review behavior match the newly approved operational definitions.
- The slice is limited to `delphi-ai/` instruction, skill, tool, config, and test surfaces.
- The slice must not redesign the overall promotion process; it must keep the existing process shape while making the approved definitions explicit and enforceable.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** `close out the self-maintenance slice with commit/push handling`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The bounded change set is implemented and validated; the TODO remains in `active/` only until closeout/commit handling is finished.
- **Exit condition:** Commit/closeout handling is complete or a new bounded blocker is opened.

## Scope
- [x] Add a deterministic promotion-contract representation for required Docker `dev` tracks when the lane is `through-stage`.
- [x] Block `dev -> stage` promotion actions when required Docker `-> dev` tracks are still pending or not yet absorbed into `origin/dev`.
- [x] Align stage-promotion skills/docs with the approved Docker mixed ordering: `bot/next-version -> dev` first, Docker source branch `-> dev` second, `dev -> stage` only after both are clear.
- [x] Reframe promotion guidance around primary surfaces `docker|flutter|laravel`, with Docker diff shape as secondary routing evidence.
- [x] Normalize review wording so the dedicated delivery-side audit baseline stays dual-lane (`Performance` + `Test Quality`), `cutover-integrity` stays conditional, `Elegance` stays outside the baseline audit, and required review gates use fresh internal no-context reviewers only.
- [x] Add focused regression coverage for the new deterministic promotion behavior and any touched classifiers/helpers.

## Out of Scope
- [ ] Redesign of main-promotion semantics.
- [ ] Broad replacement of the current promotion workflow with a new process.
- [ ] Downstream Belluga project code or live promotion execution.
- [ ] Any use of an external provider as critique, audit, final-review, or promotion-review gate evidence.

## Definition of Done
- [x] Promotion contracts can declare required Docker `dev` tracks for `through-stage` lanes.
- [x] `github_promotion_action_guard.sh` blocks `dev -> stage` when the contract still requires unresolved Docker `dev` tracks.
- [x] Stage-promotion skills/docs consistently describe the mixed Docker order and the surface-first authority model.
- [x] Review skills/docs consistently describe the dual-lane audit baseline, conditional `cutover-integrity`, retained `Elegance` role, and internal-only gate review policy.
- [x] Touched deterministic tests pass and Delphi self-check remains green.

## Validation Steps
- [x] `python3 -m py_compile tools/github_stage_promotion_scenario_classifier.py tools/github_release_package_rollup_guard.py`
- [x] `bash tools/tests/github_promotion_guard_policy_test.sh`
- [x] `bash tools/tests/github_stage_promotion_scenario_classifier_test.sh`
- [x] `bash tools/tests/github_release_package_rollup_guard_test.sh`
- [x] `bash self_check.sh`
- [x] `git diff --check`

## Profile Scope & Handoffs
- **Primary execution profile:** `operational-coder`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `strategic-cto|assurance-tester-quality`
- **Scope-check command:** `n/a - Delphi self-maintenance slice`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `operational-coder` | The user approved the bounded implementation plan; the session is now executing the canonical alignment. | `skills/**`, `rules/**`, `tools/**`, `templates/**`, `foundation_documentation/todos/active/**` | `completed - user replied APROVADO on 2026-07-07` |

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The change stays inside Delphi but crosses canonical docs, promotion guards, classifier wording, and deterministic tests.

## Canonical Module Anchors
- **Primary module doc:** `skills/github-stage-promotion-orchestrator/SKILL.md`
- **Secondary module docs (if any):**
  - `skills/github-stage-promotion-contract-preflight/SKILL.md`
  - `skills/github-stage-promotion-source-to-dev/SKILL.md`
  - `skills/github-stage-promotion-intake-classification/SKILL.md`
  - `skills/audit-protocol-triple-review/SKILL.md`
  - `rules/core/audit-escalation-model-decision.md`
  - `tools/github_promotion_action_guard.sh`
  - `tools/github_promotion_contract_init.sh`
  - `tools/lib/promotion_contract.sh`
- **Planned decision promotion targets (module sections):**
  - stage-promotion lane ordering
  - stage-admission gating
  - delivery-side review topology wording
- **Module decision consolidation targets (required):**
  - `skills/github-stage-promotion-orchestrator/SKILL.md`
  - `skills/github-stage-promotion-contract-preflight/SKILL.md`
  - `skills/github-stage-promotion-source-to-dev/SKILL.md`
  - `skills/github-stage-promotion-intake-classification/SKILL.md`
  - `skills/audit-protocol-triple-review/SKILL.md`
  - `rules/core/audit-escalation-model-decision.md`

## Decisions (Resolved Before Freeze)
- [x] `D-01` Keep the dedicated delivery-side audit baseline as `Performance` + `Test Quality`; `cutover-integrity` is conditional and `Elegance` remains outside the dedicated audit baseline.
- [x] `D-02` Require every Delphi review gate to use a fresh internal no-context reviewer who is not the implementing agent; external providers do not satisfy the gate.
- [x] `D-03` Model promotion around primary surfaces `docker|flutter|laravel`; keep Docker diff shape as secondary routing evidence.
- [x] `D-04` For mixed Docker promotion, require `bot/next-version -> dev` first, Docker source `-> dev` second, and permit `dev -> stage` only after both are absorbed into `origin/dev`.
- [x] `D-05` Enforce mixed Docker stage admission deterministically through the local promotion contract and action guard rather than prose-only guidance.

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` This slice preserves the existing promotion/review process shape and only tightens coherence and enforcement.
- [x] `D-02` `dev -> stage` must be blocked when the required Docker `-> dev` tracks are still pending under the current promotion contract.
- [x] `D-03` Release/promotion docs must not imply that an external provider is available, mandatory, or gate-satisfying.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | The cleanest insertion point for mixed Docker stage admission is the existing promotion contract plus `github_promotion_action_guard.sh`. | current contract/action-guard tooling already governs local promotion mutations and already blocks illegal lane movement | stage admission would need a parallel preflight-only guard, leaving local PR wrappers partially blind | `High` | `Promote to Decision` |
| `A-02` | Existing review topology text is already mostly aligned, so the remaining work is wording normalization rather than a new review protocol. | `audit-protocol-triple-review` and core audit rule already describe the dual baseline + conditional cutover model | more canonical surfaces would need deeper edits | `High` | `Keep as Assumption` |

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-promotion-and-review-coherence-alignment.md`
- `skills/github-stage-promotion-orchestrator/SKILL.md`
- `skills/github-stage-promotion-contract-preflight/SKILL.md`
- `skills/github-stage-promotion-source-to-dev/SKILL.md`
- `skills/github-stage-promotion-intake-classification/SKILL.md`
- `skills/copilot-pr-review/SKILL.md`
- `tools/github_promotion_contract_init.sh`
- `tools/lib/promotion_contract.sh`
- `tools/github_promotion_action_guard.sh`
- `tools/github_stage_promotion_scenario_classifier.py`
- `tools/github_release_package_rollup_guard.py`
- `tools/tests/github_promotion_guard_policy_test.sh`
- `tools/tests/github_stage_promotion_scenario_classifier_test.sh`
- `tools/manifest.md`
- `skills/deterministic-tooling-register.md`

### Ordered Steps
1. Extend the promotion contract schema and loader to carry required Docker `dev` tracks for `through-stage` lanes.
2. Enforce the contract in the action guard so `dev -> stage` cannot proceed while required Docker `dev` tracks are still pending.
3. Align promotion classifier/rollup wording and stage-promotion skill docs with the surface-first model and mixed Docker ordering.
4. Normalize review wording around dual-lane baseline audits and fresh internal no-context review gates.
5. Add or refresh focused regression coverage and run Delphi self-maintenance validation.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is a bounded deterministic-tooling/doc alignment slice. The implementation is small enough that focused regression updates after the patch are the most direct path.
- **Fail-first target(s) (when required):** `not_needed`
