# TODO: Delphi Platform-Scenario-Settings Routing Contract

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Delphi already improved model-role routing, but the current canon still mixes multiple representation styles:
- some surfaces define only the model;
- some define model plus effort;
- some are prose-first while others are config-first;
- the current machine-readable contract is still organized mainly around client plus surface, not around a generic platform/scenario/settings contract.

The next bounded correction is to promote one canonical routing contract in the shape:

`platform -> scenario -> settings`

so Delphi can describe Codex, Claude Code, Cline IDE, and future clients through the same routing vocabulary and the same deterministic validation path.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The user explicitly requested consolidation of model and effort routing in a generic platform-aware form rather than another Codex-specific policy pass.
- **Direct-to-TODO rationale:** This is Delphi self-maintenance and the directional policy is already known; the missing piece is the canonical representation and its consistent enforcement.

## Contract Boundary
- This TODO defines **WHAT** must be delivered so Delphi has one generic routing contract that separates:
  - platform/client identity
  - supported capabilities
  - governed scenarios
  - per-scenario settings
- The slice is limited to Delphi self-maintenance surfaces in `delphi-ai/`.
- The slice must preserve the current role split and routing intent while changing the representation into a generic, extensible contract.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** `define the canonical contract shape for platform, scenario, and settings before changing guards or workflow prose`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `implementation`
- **Why this state now:** The desired representation has been clarified, but Delphi still lacks a canonical platform/scenario/settings contract.
- **Exit condition:** The machine-readable contract, deterministic validation path, and derived documentation surfaces are aligned and validated.

## Scope
- [ ] Define one machine-readable canonical routing contract in the shape `platform -> scenario -> settings`.
- [ ] Define or refresh the canonical schema/versioning boundary for that contract so deterministic tools can validate format evolution explicitly.
- [ ] Define the canonical scenario vocabulary for Delphi routing, including at least: `chat_orchestrator`, `routine_executor`, `high_risk_executor`, `monitoring`, `todo_approval`, `formal_review`, `delivery_review`, and `self_improvement`.
- [ ] Define the canonical settings vocabulary per scenario, including at least: `model`, `effort`, `goal_policy`, `state_policy`, `proof_mode_policy`, and any required escalation/exception hooks.
- [ ] Make `settings` expressive enough for both fixed values and policy-driven escalation, such as `high by default, xhigh only when explicitly justified`, rather than only static literal assignments.
- [ ] Represent platform-specific capability differences explicitly so Codex, Claude Code, and Cline IDE can share the same scenario contract without pretending they support identical features.
- [ ] Move canonical truth toward the machine-readable contract and reduce prose-only policy drift in workflows/instructions.
- [ ] Align guards, advisors, generated client-facing artifacts, and relevant documentation to derive from or obey that same contract.
- [ ] Define the bounded migration/compatibility approach from the current client/surface representation to the new platform/scenario/settings representation so existing guard callers do not silently drift during the transition.
- [ ] Add or refresh deterministic validation so stale, partial, or contradictory platform/scenario/settings declarations are rejected.

## Out of Scope
- [ ] Redesign of the promotion/review workflow topology itself.
- [ ] Downstream Belluga project code.
- [ ] Runtime introspection beyond the current declared/artifact/waiver proof model unless required to finish this contract cleanly.
- [ ] Replacing the current Delphi role split with a different delegation philosophy.

## Definition of Done
- [ ] Delphi has one canonical machine-readable routing contract that expresses `platform -> scenario -> settings`.
- [ ] The contract explicitly covers both model and effort for the governed scenarios instead of splitting those truths inconsistently across prose and config.
- [ ] The contract schema/versioning and migration rules are explicit enough that deterministic tooling can validate old-vs-new representation boundaries during the transition.
- [ ] The contract can express conditional effort policy, not only static effort literals, for cases such as review defaulting to `high` while permitting `xhigh` only under explicit criteria.
- [ ] Platform capability differences are represented explicitly without claiming unsupported behavior for any client.
- [ ] Canonical instructions/workflows no longer act as independent policy sources that can disagree with the contract.
- [ ] Deterministic validation can reject stale or incomplete platform/scenario/settings routing declarations.
- [ ] Local validation evidence exists for the touched routing surfaces.

## Validation Steps
- [ ] `bash tools/tests/agent_role_routing_guard_test.sh`
- [ ] `bash tools/tests/effort_selection_advisor_test.sh`
- [ ] `bash tools/tests/todo_authority_guard_test.sh`
- [ ] `bash self_check.sh`
- [ ] `git diff --check`

## Profile Scope & Handoffs
- **Primary execution profile:** `operational-coder`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `strategic-cto|assurance-tester-quality`
- **Scope-check command:** `n/a - Delphi self-maintenance slice`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `operational-coder` | The user requested bounded implementation of a generic routing contract expressed by platform, scenario, and settings. | `config/**`, `main_instructions.md`, `workflows/docker/**`, `tools/**`, `.claude/**`, `.cline/**`, `.clinerules/**` | `planned` |

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The policy intent is already clear, but the representation change crosses canonical config, deterministic guards, workflows, and generated compatibility surfaces.

## Canonical Module Anchors
- **Primary module doc:** `config/agent_role_routing.json`
- **Secondary module docs (if any):**
  - `workflows/docker/effort-selection-method.md`
  - `main_instructions.md`
  - `workflows/docker/todo-execution-boundary-method.md`
  - `skills/deterministic-tooling-register.md`
  - `tools/manifest.md`
- **Planned decision promotion targets (module sections):**
  - platform capability mapping
  - scenario taxonomy
  - settings schema
  - derivation boundaries between config and prose
- **Module decision consolidation targets (required):**
  - `config/agent_role_routing.json`
  - `tools/agent_role_routing_guard.py`
  - `workflows/docker/effort-selection-method.md`
  - `main_instructions.md`

## Decisions (Resolved Before Freeze)
- [x] `D-01` The routing contract should be generic by platform rather than centered on one client.
- [x] `D-02` The routing contract should be expressed in the shape `platform -> scenario -> settings`.
- [x] `D-03` Model and effort must be first-class settings in the same canonical contract.
- [x] `D-04` Platform differences should be expressed through capability and settings variation, not through separate incompatible routing philosophies.
- [x] `D-05` Workflow and instruction prose should become derived or subordinate to the canonical machine-readable contract rather than acting as parallel policy sources.
- [x] `D-06` The new contract must be able to represent policy semantics such as default effort plus bounded escalation criteria, not only static per-scenario literals.
- [x] `D-07` The migration from the current client/surface form to the new platform/scenario/settings form must be explicit and machine-checkable.

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` The contract must remain generic enough to represent Codex, Claude Code, Cline IDE, and future clients.
- [x] `D-02` The contract must represent both the process-governance chat role and delegated executor/review roles.
- [x] `D-03` Effort escalation should remain explicit and justified by scenario semantics rather than hidden inside free-text prose.
- [x] `D-04` A scenario setting may need to carry policy metadata, not just a final scalar value, when the final selection depends on explicit gate criteria.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | The existing `config/agent_role_routing.json` can be evolved into the canonical platform/scenario/settings contract instead of being replaced by an entirely new file. | current machine-readable routing already exists and is the nearest canonical surface | the slice may need a new config artifact and migration path | `Medium` | `Keep as Assumption` |
| `A-02` | Existing routing guard/advisor infrastructure can be adapted to the new representation without inventing a second routing subsystem. | `agent_role_routing_guard.py` and `effort_selection_advisor.py` already enforce/advise routing behavior | the deterministic layer may need a deeper redesign | `Medium` | `Keep as Assumption` |

## Execution Plan
### Touched Surfaces
- `foundation_documentation/todos/active/delphi-platform-scenario-settings-routing-contract.md`
- `config/agent_role_routing.json`
- `tools/agent_role_routing_guard.py`
- `tools/effort_selection_advisor.py`
- `main_instructions.md`
- `workflows/docker/effort-selection-method.md`
- `workflows/docker/todo-execution-boundary-method.md`
- `tools/tests/agent_role_routing_guard_test.sh`
- `tools/tests/effort_selection_advisor_test.sh`
- `tools/tests/todo_authority_guard_test.sh`
- any generated `.claude/**`, `.cline/**`, `.clinerules/**` routing mirrors required by the final canon

### Ordered Steps
1. Freeze the canonical contract shape for `platform`, `scenario`, and `settings`.
2. Freeze the schema/versioning and migration semantics, including how current client/surface callers map into the new representation during the transition.
3. Refactor the existing routing config into that shape, keeping backward compatibility only where truly needed for a bounded migration.
4. Align deterministic guards/advisors to the new contract semantics, including conditional effort policy where applicable.
5. Align workflow/instruction prose so it is subordinate to the contract and does not remain an independent policy source.
6. Refresh generated client-facing routing artifacts if the contract changed.
7. Run focused routing tests and Delphi self-check.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This slice is about canonical representation and deterministic coherence; the important proof is that the final config/guard/docs surfaces stay aligned.
- **Fail-first target(s) (when required):** `not_needed`
