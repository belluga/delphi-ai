# TODO: Flutter Active-Instruction Coherence Guard

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Active Flutter consumer instruction surfaces can drift from their canonical rules and workflows after independent mirror or documentation edits. A future read-only guard should make that drift visible without creating a second architecture authority.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The routed P2-05 finding identifies a bounded missing hardening mechanism after the current instruction coherence delivery.
- **Direct-to-TODO rationale:** This is Delphi self-maintenance; no downstream product feature is involved.

## Contract Boundary
- This TODO is strictly limited to planning a future read-only guard for active Flutter instruction consumer surfaces.
- The guard must validate active consumer references, reject local analyzer CLI guidance in editor-managed surfaces, and detect contradictions between controller-local and repository-canonical `StreamValue` ownership.
- This TODO does not authorize implementation, tool changes, analyzer changes, downstream changes, or instruction edits in the current session.

## Implementation Intent
- **Current delivery:** `none; planning contract only`
- **Planned next steps:** `obtain explicit approval, design the read-only guard, implement it, and add focused tests in a separate session`
- **Anticipatory implementation authorized now:** `none`
- **Rationale:** The current approval covers the Flutter instruction correction, not a new deterministic harness.

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** `await explicit user approval before implementing any guard or test`

## Active Work State
- **Work state:** `review`
- **Why this state now:** The future hardening need is recorded but no implementation authority has been granted.
- **Exit condition:** Explicit approval either authorizes the bounded guard implementation or closes this unapproved TODO.

## Scope
- [ ] Implement a read-only guard that validates references from active Flutter consumer instruction surfaces to canonical rules, workflows, and skills.
- [ ] Detect local `flutter analyze` or `dart analyze` guidance in editor-managed Flutter instruction surfaces, while keeping pipeline analyzer guidance separate.
- [ ] Detect contradictions that assign canonical shared entity/list state to controllers instead of persistent repository-owned `StreamValue` instances.
- [ ] Add focused guard tests and register the guard only after explicit approval.

## Out of Scope
- [ ] Implementing this guard, its tests, or tooling registration in the current session.
- [ ] Any downstream Flutter product, analyzer-plugin, runtime, or `config/stack_capabilities.yaml` change.
- [ ] Replacing canonical architecture rules or broadening Flutter state-management architecture.

## Bounded But Elastic Guardrails
- **May stay inside this TODO after approval:** read-only validation, focused tests, register entry, and canonical mirror adjustments strictly necessary for the guard.
- **Must update or split the TODO:** product/runtime behavior, analyzer-plugin implementation, or a new architecture authority.

## Definition of Done
- [ ] A read-only active-instruction coherence guard validates the bounded reference, analyzer-guidance, and ownership-contradiction conditions.
- [ ] Focused tests prove accepted and rejected instruction examples deterministically.
- [ ] The guard is registered and documented without becoming a second canonical Flutter architecture source.

## Validation Steps
- [ ] Run the focused guard test suite after implementation is explicitly approved.
- [ ] Run `bash self_check.sh` after implementation is explicitly approved.
- [ ] Run `git diff --check` after implementation is explicitly approved.

## Profile Scope & Handoffs
- **Primary execution profile:** `operational-coder`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `strategic-cto|assurance-tester-quality`
- **Scope-check command:** `n/a - standalone Delphi future hardening contract`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** A new deterministic guard crosses active consumer-surface discovery, canonical reference policy, tests, and tooling registration, but remains read-only and Delphi-local.

## Canonical Module Anchors
- **Primary module doc:** `rules/stacks/flutter/flutter-architecture-always-on.md`
- **Secondary module docs (if any):**
  - `skills/flutter-architecture-adherence/SKILL.md`
  - `workflows/flutter/create-controller-method.md`
  - `workflows/flutter/create-screen-method.md`
  - `tools/self_check.sh`
- **Planned decision promotion targets (module sections):** `active consumer-surface coherence only after approval`
- **Module decision consolidation targets (required):** `n/a until implementation approval`

## Decisions (Resolved Before Freeze)
- [x] `D-01` The future mechanism is read-only and validates existing canonical authority rather than defining architecture.
- [x] `D-02` The future mechanism must cover active consumer references, local analyzer CLI guidance, and controller-local versus repository-canonical ownership contradictions.
- [x] `D-03` No implementation is authorized by creating this TODO.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Existing instruction inventory and deterministic tooling conventions can support a bounded read-only guard. | `tools/self_check.sh`, `tools/audit_instruction_baselines.sh`, and `skills/deterministic-tooling-register.md` | Reassess the design only after approval. | `Medium` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `recommended`
- **Why this decision:** The future read-only guard design must later verify that its proposed consumer-surface inventory is anchored in the active tree.
- **Trigger stage:** `after approval and before future implementation`
- **Guard scope:** `A-01`
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md`
- **Gate status:** `not_run`
- **Findings summary:** `Not run because this unapproved TODO authorizes no implementation session.`
- **Evidence / reference:** `tools/self_check.sh; tools/audit_instruction_baselines.sh; skills/deterministic-tooling-register.md`
- **Waiver authority / reference (required if waived):** `n/a`

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-flutter-active-instruction-coherence-guard.md` only in this session.
- Future approved surfaces may include `tools/**`, focused `tools/tests/**`, `skills/deterministic-tooling-register.md`, and relevant canonical/mirror instructions.

### Ordered Steps
1. Obtain explicit approval for the future deterministic guard.
2. Freeze active consumer-surface discovery and canonical references.
3. Implement the read-only guard and focused test cases.
4. Register and validate the guard without changing downstream products.

### Test Strategy
- **Strategy:** `test-first after approval`
- **Why:** Rejected and accepted instruction fixtures define the future guard contract.
- **Fail-first target(s) (when required):** `focused guard tests; not authorized in this session`

## Authorization Note
- **Implementation authorization:** `none in this session`
- **Approval status:** `unapproved`
- **No implementation statement:** `This active TODO records routing only and must not cause implementation before a separate explicit approval.`
