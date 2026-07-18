# TODO: Codex Internal Review Output-Schema Compatibility

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
`codex exec --output-schema delphi-ai/schemas/subagent_review_result.schema.json` rejects the current reviewer-result schema before a no-context reviewer can inspect its bounded package. Codex strict response formats require every declared object property to be listed in `required`; the canonical merge schema intentionally has optional finding metadata. The bounded test-quality prompt also failed to restate the canonical category enum, and a fresh reviewer returned `test_effectiveness` where the merge schema accepts `tests`. Later P1/P2 reviewers returned prose in required position fields and an unsupported `adherence_position` property, while merge accepts only the canonical position enums and disallows extra top-level properties. A U03 final-review launch also terminated without a final agent message, leaving `--output-last-message` empty; a PTY-backed invocation with direct session polling completed and wrote merge-valid JSON.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** This is a reusable Delphi harness boundary exposed while dispatching the approved U03 internal review. It is independent from U03 product behavior.
- **Direct-to-TODO rationale:** The defect is a tool/schema compatibility correction, not a product feature.

## Contract Boundary
- This TODO defines a provider-compatible structured-output path for fresh internal Codex reviewers that preserves the canonical `subagent_review_result` merge contract.
- Until this TODO is implemented, an internal reviewer may omit `--output-schema` only when the prompt requires one JSON object and `subagent_review_merge.py` validates the result before it is used as gate evidence.
- This TODO does not change U03 product code, authorize external reviewers, or weaken no-context isolation.

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** approve a bounded durable adapter/normalization design after comparing strict-schema and post-parse validation options.

## Active Work State
- **Work state:** `implementation`
- **Why this state now:** The compatibility failure is reproduced and a safe operational fallback is documented, but no durable harness correction has been implemented.
- **Exit condition:** a fresh internal Codex review produces merge-valid JSON through the canonical supported path, with regression coverage.

## Scope
- [ ] Reproduce the strict response-schema rejection in a deterministic harness test.
- [ ] Choose and implement a compatible response-schema adapter or canonical normalization path.
- [ ] Preserve `subagent_review_merge.py` as the authoritative validator for gate evidence.
- [ ] Generate reviewer prompts from, or explicitly bind them to, every canonical enum required by merge validation.
- [ ] Generate reviewer prompts from, or explicitly bind them to, canonical position-field enums as well as finding categories.
- [ ] Generate reviewer prompts from, or explicitly bind them to, the canonical top-level field allowlist.
- [ ] Define and test the internal reviewer process-collection contract so a missing final message is detected and a PTY/direct-session retry preserves the required-gate retry semantics.
- [ ] Prove a fresh internal no-context review can complete with a bounded packet and merge-valid result.

## Out of Scope
- [ ] U03 application behavior, Laravel tests, or Atlas evidence.
- [ ] External reviewer/provider invocation.
- [ ] Relaxing required-review isolation or accepting unvalidated prose as gate evidence.

## Definition of Done
- [ ] Codex strict output mode no longer fails solely because canonical finding metadata is optional.
- [ ] Prompt and merge contracts cannot disagree on an accepted finding category.
- [ ] Prompt and merge contracts cannot disagree on required position-field values.
- [ ] Prompt and merge contracts cannot emit unsupported top-level fields.
- [ ] The runner distinguishes a completed valid result from an empty `--output-last-message` and captures a deterministic retryable failure record.
- [ ] The produced reviewer result validates through `subagent_review_merge.py` without manual editing.
- [ ] A focused regression test protects the selected compatibility path.

## Validation Steps
- [ ] Run the focused compatibility regression test.
- [ ] Run one fresh read-only internal reviewer against a bounded fixture and merge its result.
- [ ] Run `bash delphi-ai/self_check.sh` and `git diff --check`.

## Evidence Captured Before Approval
- **Failure command:** `codex exec ... --output-schema delphi-ai/schemas/subagent_review_result.schema.json ...`
- **Observed result:** OpenAI strict response-format validation returned `invalid_json_schema`: the nested finding object omitted optional properties from `required`.
- **Second observed result:** a no-schema fallback reviewer returned `category: test_effectiveness`, which `subagent_review_merge.py` correctly rejected because the canonical enum uses `tests`.
- **Third observed result:** a P1/P2 reviewer returned prose in `performance_position`, `elegance_position`, `structural_soundness_position`, and `operational_fit_position`; `subagent_review_merge.py` correctly rejects them because each must be one of the canonical position enums.
- **Fourth observed result:** the P1/P2 confirmation reviewer returned unsupported top-level `adherence_position`; `subagent_review_merge.py` correctly rejects it because the canonical result schema uses `additionalProperties: false`.
- **Fifth observed result:** a U03 final-review invocation ended without writing its `--output-last-message` file. Repeating the same fresh no-context review through a PTY-backed `codex exec` session and direct session polling returned merge-valid JSON. The runner must make this distinction deterministic instead of accepting an absent file or relying on transport timing.
- **Safe U03 fallback:** omit Codex `--output-schema`, require exactly one JSON object in the bounded prompt, then validate it with the existing canonical merge tool before using it as evidence.

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The correction crosses the canonical reviewer schema, dispatch/merge workflow, and internal client runner behavior.

## Decision Pending
- [ ] `D-01` Choose either a strict Codex-facing adapter plus normalization into the canonical schema, or a documented post-parse-only path with deterministic validation; compare robustness, duplication, and maintenance cost before approval.

## Audit Trigger Matrix
| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | Reusable review-harness correction. |
| `blast_radius` | `cross-module` | Schema, runner, dispatch, and merge paths. |
| `behavioral_change_or_bugfix` | `yes` | Corrects a required internal review execution failure. |
| `changes_public_contract` | `no` | Internal Delphi harness only. |
| `touches_auth_or_tenant` | `no` | No product authorization scope. |
| `touches_runtime_or_infra` | `no` | No product runtime surface. |
| `touches_tests` | `yes` | Compatibility regression evidence is required. |
| `critical_user_journey` | `no` | Internal assurance tooling. |
| `release_or_promotion_critical` | `yes` | Required review gates depend on the harness. |
| `high_severity_plan_review_issue` | `no` | No plan review yet. |
| `explicit_three_lane_request` | `no` | No dedicated multi-lane audit requested. |
