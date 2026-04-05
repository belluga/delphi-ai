---
description: Define the versioned four-lane performance/concurrency policy package for tactical TODOs, including closed registries, lane state machine, artifact hashing rules, and gate deadlines.
---

# Method: Performance & Concurrency Validation Lanes

## Policy Schema Version
- `pcv-1`

This workflow is the canonical policy package for tactical TODO performance/concurrency validation. The closed registries, JSON normalization rules, and lane artifact contracts in this document are immutable within `pcv-1`.

## Scope Anchor
- This policy applies only to tactical TODOs under `foundation_documentation/todos/active/` that use the tactical TODO template and require explicit `APROVADO` before implementation.
- `Approval authority` means the explicit approving user or an explicitly delegated human approver recorded by the user.
- `Executor` means the agent performing the work.
- `Approver` must differ from `executor`.

## Lane Set
Every tactical TODO must contain exactly four lane rows:
- `EPS` = `endpoint-performance-scrutiny`
- `FRC` = `frontend-race-condition-validation`
- `BCI` = `backend-concurrency-idempotency-validation`
- `RLS` = `runtime-load-stress-validation`

No lane row may be missing or duplicated.

## Closed Registries

### Lane IDs
| ID | Meaning |
| --- | --- |
| `EPS` | Endpoint/query access-path scrutiny |
| `FRC` | Frontend race-condition validation |
| `BCI` | Backend concurrency/idempotency validation |
| `RLS` | Runtime load/stress validation |

### Trigger Results
| ID | Meaning |
| --- | --- |
| `required` | The lane must be resolved by its gate deadline. |
| `recommended` | The lane must still be resolved by its gate deadline, but waiver governance is lighter. |
| `not_needed` | The validated surface is absent for this TODO. |

### Gate Deadlines
| ID | Meaning |
| --- | --- |
| `before_local_implemented` | The lane must be gate-satisfying before the TODO may move to `Current delivery stage = Local-Implemented`. |
| `before_production_ready` | The lane must be gate-satisfying before the TODO may move to `Current delivery stage = Production-Ready`. |

### Lane States
| ID | Meaning |
| --- | --- |
| `not_applicable` | Valid only when `trigger_result = not_needed`; terminal. |
| `pending` | Triggered lane not yet started. |
| `running` | Validation execution in progress. |
| `blocked` | Validation cannot currently run due to a concrete blocker. |
| `passed` | Minimum evidence and acceptance rule satisfied. |
| `waived` | Explicitly accepted exception path with governance fields completed. |
| `expired` | Waiver expired; lane no longer satisfies gate. |
| `missed_gate` | The lane missed its deadline while unresolved. |

### Uncertainty Reason Codes
| Code | Meaning |
| --- | --- |
| `none` | No uncertainty claimed. |
| `U-QUERY-PATH-UNKNOWN` | Query/data-access path could not be classified with confidence. |
| `U-ASYNC-SURFACE-UNKNOWN` | Async UI overlap/lifecycle behavior could not be classified with confidence. |
| `U-WRITE-OVERLAP-UNKNOWN` | Write overlap or idempotency exposure is uncertain. |
| `U-RUNTIME-PRESSURE-UNKNOWN` | Runtime pressure/capacity impact is uncertain. |
| `U-EVIDENCE-EQUIVALENCE-CLAIM` | A non-default stronger evidence profile is being used instead of the floor profile. |

If `uncertainty_reason_code != none`, `trigger_result` cannot be `not_needed`.

## Objective Trigger Glossary
- `exact_lookup_surface_changed`
  - Changed code creates/modifies/deletes a path retrieving exactly one entity by key (`slug|id|uuid|code|handle|key`) or changes its API/repository contract.
- `query_shape_changed`
  - Changed code creates/modifies/deletes filtering, sorting, pagination, grouping, aggregation, join behavior, index expectation, cardinality, number of backend calls, or direct-lookup-vs-list-traversal behavior.
- `retriggerable_async_write`
  - The changed UI surface can issue overlapping mutations from the same visible action path.
- `retriggerable_async_read_with_order_dependence`
  - Overlapping reads can update the same visible state and later responses can overwrite newer intent.
- `lifecycle_async_effect`
  - Navigation/dispose/unmount can occur while async work still targets visible UI state or visible side effects.
- `overlapping_write_surface`
  - The changed system allows two or more requests/jobs/webhooks to mutate the same logical resource concurrently.
- `runtime_pressure_surface`
  - The changed code touches queue/worker/realtime fan-out, batch/bulk path, cache/index-sensitive request path, or the TODO explicitly claims latency/throughput/capacity/SLO impact.

## Severity Scale
| ID | Meaning |
| --- | --- |
| `low` | Localized, reversible, non-core flow. |
| `medium` | User-visible or business-relevant degradation/corruption risk. |
| `high` | Payment, reservation, inventory, auth-critical, realtime core path, or TODO runtime impact explicitly classified high. |

## Row Schema

### Always-Required Row Fields
- `policy_schema_version`
- `lane_id`
- `trigger_result`
- `trigger_severity`
- `trigger_reason_code`
- `trigger_rationale`
- `gate_deadline`
- `min_evidence_rule_id`
- `state`
- `residual_risk`
- `uncertainty_reason_code`
- `recorded_at_utc`
- `executor_id`

### Conditional Objects
- `evidence`
  - Required only when `state in {running, passed}`.
- `blocker`
  - Required only when `state = blocked`.
- `waiver`
  - Required only when `state in {waived, expired}`.
- `classification_change`
  - Required only when `trigger_result` changed after `APROVADO`.

## Gate-Satisfying States
- For `required`: only `passed` or `waived`
- For `recommended`: only `passed` or `waived`
- For `not_needed`: only `not_applicable`
- `blocked`, `pending`, `running`, `expired`, and `missed_gate` never satisfy a gate.

## State Machine
- Initial state:
  - `not_applicable` only when `trigger_result = not_needed`
  - `pending` when `trigger_result in {required, recommended}`
- Allowed transitions:
  - `pending -> running|blocked|waived|missed_gate`
  - `running -> passed|blocked|waived|missed_gate`
  - `blocked -> running|waived|missed_gate`
  - `waived -> expired`
  - `expired -> pending`
  - `missed_gate -> running|waived`
  - `passed -> terminal`
  - `not_applicable -> terminal`
- No row may transition to `not_applicable` after `APROVADO`.

## Classification Control
- After `APROVADO`, `trigger_result` may only change `required <-> recommended`.
- Any change that reduces obligation (`required -> recommended`) requires renewed `APROVADO`.
- `recommended -> required` requires a recorded change, but not renewed approval unless the user explicitly constrains the prior lighter path.
- `required -> not_needed` and `recommended -> not_needed` are forbidden after `APROVADO`.
- `classification_change` object fields:
  - `previous_trigger_result`
  - `new_trigger_result`
  - `classification_changed_by`
  - `classification_changed_at_utc`
  - `classification_change_reason`
  - `approval_reference`

## Waiver Control
- Any gate-satisfying waiver requires:
  - `waiver_reason_code`
  - `waiver_reason`
  - `waiver_expiry_utc`
  - `approver_id`
  - `approval_reference`
  - `follow_up_task_id`
  - `follow_up_owner`
  - `mitigation_summary`
- `approver_id` must differ from `executor_id`.
- Required-lane waiver additionally requires `reviewer_id`, and `reviewer_id` must differ from both `executor_id` and `approver_id`.
- Expired waiver automatically reopens the lane as `pending`.

## Blocker Control
- `blocker` object fields:
  - `blocker_reason_code`
  - `blocker_reason`
  - `unblock_condition`
  - `follow_up_task_id`
  - `follow_up_owner`
- If a gate deadline is reached while the lane is still `pending|running|blocked`, the state must become `missed_gate`.

## Evidence Control
- Prose-only evidence is invalid.
- Each `evidence` object must include:
  - `evidence_type`
  - `environment_id`
  - `run_id`
  - `artifact_uri`
  - `artifact_schema_version`
  - `artifact_sha256`
  - `sample_profile_id`
  - `acceptance_rule_id`
  - `result_summary`
  - `reviewer_id`
- The artifact at `artifact_uri` must be a machine-checkable JSON document.
- The artifact JSON must include:
  - `policy_schema_version`
  - `schema_version`
  - `lane_id`
  - `todo_id`
  - `run_id`
  - `environment_id`
  - `executor_id`
  - `reviewer_id`
  - `recorded_at_utc`
  - `evidence_type`
  - `sample_profile_id`
  - `acceptance_rule_id`
  - `result_summary`
  - `artifact_payload`
  - `artifact_sha256`
- `artifact_sha256` must be the `SHA-256` hash of the full canonical JSON serialization excluding the `artifact_sha256` field itself.
- Canonical JSON normalization for hashing in `pcv-1`:
  - UTF-8 encoding
  - sorted object keys at every depth
  - arrays preserved in declared order
  - no insignificant whitespace
  - no comments or trailing commas
- If one artifact is reused by multiple lanes, each lane row must reference it explicitly, and the artifact payload must satisfy every referenced lane's required evidence fields and rules.

## Lane Policies

### EPS
**Trigger Reason Codes**
- `EPS-EXACT-LOOKUP-SURFACE-CHANGED`
- `EPS-QUERY-SHAPE-CHANGED`
- `EPS-LIST-SEARCH-SEMANTICS-CHANGED`
- `EPS-DATA-PATH-CHANGED`

**Classification**
- `required` when `exact_lookup_surface_changed` or `query_shape_changed` is true
- `recommended` when a read path changed but neither `exact_lookup_surface_changed` nor `query_shape_changed` is true
- `not_needed` when no read/data-access/query surface changed

**Gate Deadline**
- `before_local_implemented`

**Closed Evidence Rules**
| Rule ID | Required Evidence |
| --- | --- |
| `EPS-E1` | Access-pattern classification + touched-path audit artifact |
| `EPS-E2` | `EPS-E1` plus `explain|query-log|benchmark-equivalent` artifact |

**Closed Acceptance Rules**
| Rule ID | Pass Requirement |
| --- | --- |
| `EPS-A1` | Low-severity row satisfies `EPS-E1`. |
| `EPS-A2` | Medium/high-severity row satisfies `EPS-E2`. |

**Closed Sample Profiles**
| ID | Meaning |
| --- | --- |
| `EPS-SP-AUDIT` | Touched-path audit profile |
| `EPS-SP-STRONG` | Strong query evidence profile |

### FRC
**Trigger Reason Codes**
- `FRC-DUPLICATE-MUTATION`
- `FRC-STALE-RESPONSE`
- `FRC-LIFECYCLE-ASYNC-EFFECT`
- `FRC-RETRIGGERABLE-LIST`
- `FRC-OPTIMISTIC-RECONCILE`

**Classification**
- `required` when `retriggerable_async_write`, `retriggerable_async_read_with_order_dependence`, or `lifecycle_async_effect` is true on the changed UI surface
- `recommended` when only low-risk retriggerable async read behavior changed and no mutation/lifecycle risk applies
- `not_needed` when no retriggerable/lifecycle-sensitive async UI surface changed

**Gate Deadline**
- `before_local_implemented`

**Closed Evidence Rules**
| Rule ID | Required Evidence |
| --- | --- |
| `FRC-POLICY` | `concurrency_policy` enum present in artifact payload |
| `FRC-E1` | `FRC-POLICY` + low floor profile evidence |
| `FRC-E2` | `FRC-POLICY` + medium floor profile evidence |
| `FRC-E3` | `FRC-POLICY` + high floor profile evidence |

**Closed Acceptance Rules**
| Rule ID | Pass Requirement |
| --- | --- |
| `FRC-A1` | Required lane row cannot pass without concurrency policy plus deterministic runner/manual evidence artifact. |
| `FRC-A2` | Alternate stronger profile allowed only with `U-EVIDENCE-EQUIVALENCE-CLAIM` and explicit rationale. |

**Closed Sample Profiles**
| ID | Meaning |
| --- | --- |
| `FRC-SP-L` | `5` repeated triggers x `2` repetitions |
| `FRC-SP-M` | `10` repeated triggers x `3` repetitions |
| `FRC-SP-H` | `20` repeated triggers x `5` repetitions |

### BCI
**Trigger Reason Codes**
- `BCI-NON-IDEMPOTENT-WRITE`
- `BCI-IRREVERSIBLE-SIDE-EFFECT`
- `BCI-LOST-UPDATE-RISK`
- `BCI-DUPLICATE-SUBMIT-OR-REPLAY`
- `BCI-JOB-WEBHOOK-API-OVERLAP`
- `BCI-EXACT-ONCE-SEMANTICS`

**Classification**
- `required` when `overlapping_write_surface` is true and a closed `BCI` reason code applies
- `recommended` when `overlapping_write_surface` may exist but changed code only strengthens protections without altering write semantics
- `not_needed` when no write surface changed and no overlapping mutation surface exists

**Gate Deadline**
- `before_local_implemented`

**Closed Evidence Rules**
| Rule ID | Required Evidence |
| --- | --- |
| `BCI-INV` | `invariant_id` present in artifact payload |
| `BCI-POLICY` | `concurrency_policy` enum present in artifact payload |
| `BCI-E1` | `BCI-INV` + `BCI-POLICY` + low floor profile evidence |
| `BCI-E2` | `BCI-INV` + `BCI-POLICY` + medium floor profile evidence |
| `BCI-E3` | `BCI-INV` + `BCI-POLICY` + high floor profile evidence |

**Closed Acceptance Rules**
| Rule ID | Pass Requirement |
| --- | --- |
| `BCI-A1` | Required row cannot pass without invariant and deterministic overlapping-operation probe artifact. |
| `BCI-A2` | Alternate stronger profile allowed only with `U-EVIDENCE-EQUIVALENCE-CLAIM` and explicit rationale. |

**Closed Sample Profiles**
| ID | Meaning |
| --- | --- |
| `BCI-SP-L` | `5` overlapping operations x `2` batches |
| `BCI-SP-M` | `10` overlapping operations x `3` batches |
| `BCI-SP-H` | `20` overlapping operations x `5` batches |

### RLS
**Trigger Reason Codes**
- `RLS-SLO-CLAIM`
- `RLS-QUEUE-WORKER-REALTIME-CHANGED`
- `RLS-BATCH-OR-BULK-PATH-CHANGED`
- `RLS-CACHE-INDEX-SENSITIVE-PATH-CHANGED`

**Classification**
- `required` when `runtime_pressure_surface` is true and either the TODO includes explicit latency/throughput/capacity/SLO acceptance or TODO runtime impact is classified `high`
- `recommended` when `runtime_pressure_surface` is true but no explicit performance commitment exists and runtime impact is `low|medium`
- `not_needed` when no runtime-pressure surface changed

**Gate Deadline**
- `before_production_ready` by default
- `before_local_implemented` only when the TODO `Definition of Done` explicitly includes runtime capacity/performance acceptance

**Closed Evidence Rules**
| Rule ID | Required Evidence |
| --- | --- |
| `RLS-E1` | One stage profile + thresholds + metrics artifact |
| `RLS-E2` | Two stage profiles + thresholds + metrics artifact |
| `RLS-E3` | Three stage profiles + thresholds + metrics artifact |

**Closed Acceptance Rules**
| Rule ID | Pass Requirement |
| --- | --- |
| `RLS-A1` | Required row cannot pass without thresholds, stage profile, and metrics comparison artifact. |

**Closed Sample Profiles**
| ID | Meaning |
| --- | --- |
| `RLS-SP-L` | One stage load profile |
| `RLS-SP-M` | Two stage load profile |
| `RLS-SP-H` | Three stage load profile |

## Required Artifact Payload Fields By Lane
- `EPS`
  - `access_pattern_classification`
  - `touched_path_audit_summary`
  - For `EPS-E2`, `strong_query_evidence_type`
- `FRC`
  - `concurrency_policy`
  - `burst_profile_observed`
  - `runner_or_manual_path`
- `BCI`
  - `invariant_id`
  - `concurrency_policy`
  - `probe_profile_observed`
- `RLS`
  - `stage_profile_observed`
  - `thresholds`
  - `metrics_summary`

## Representation In Tactical TODOs
- Tactical TODOs may represent the always-required row fields in a matrix and place conditional objects under per-lane subsections, as long as all required fields from this workflow remain present and unambiguous.
- The tactical TODO template provides the canonical markdown representation for `pcv-1`.

## Known v1 Limits
- `required -> recommended` renewal language remains slightly asymmetric and may be tightened in a future schema version.
- Some classification heuristics still depend on human judgment; this is acceptable for `pcv-1` because the policy now constrains the exploitable parts (state, waiver, evidence, and deadline behavior).
