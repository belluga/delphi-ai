# TODO: Codex Internal Review Output-Schema Compatibility

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
`codex exec --output-schema delphi-ai/schemas/subagent_review_result.schema.json` rejects the current reviewer-result schema before a no-context reviewer can inspect its bounded package. Codex strict response formats require every declared object property to be listed in `required`; the canonical merge schema intentionally has optional finding metadata. The original dispatcher merely named that schema instead of emitting its canonical top-level allowlist and enum domains, and a fresh U04 architecture reviewer therefore returned `correctness` and `scope_boundary` where the merge schema accepts `architecture` and `adherence`. Earlier test-quality/P1/P2 reviewers also returned `test_effectiveness`, prose position values, or an unsupported `adherence_position` property. A U03 final-review launch also terminated without a final agent message, leaving `--output-last-message` empty; a PTY-backed invocation with direct session polling completed and wrote merge-valid JSON.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** This is a reusable Delphi harness boundary exposed while dispatching the approved U03 internal review. It is independent from U03 product behavior.
- **Direct-to-TODO rationale:** The defect is a tool/schema compatibility correction, not a product feature.

## Contract Boundary
- This TODO defines a provider-compatible structured-output path for fresh internal Codex reviewers that preserves the canonical `subagent_review_result` merge contract.
- The selected path omits unsupported Codex `--output-schema` transport validation, derives the full prompt contract from the canonical schema, then applies only documented review-kind-specific alias normalization before strict canonical validation and merge.
- `subagent_review_merge.py` remains the authoritative gate-evidence validator; normalization never accepts arbitrary prose, unknown properties, unknown categories, or invalid position values.
- This TODO does not change U03 product code, authorize external reviewers, or weaken no-context isolation.

## Delivery Status Canon
- **Current delivery stage:** `Completed`
- **Qualifiers:** `none`
- **Next exact step:** `n/a - local Delphi review-harness correction is validated and closed.`

## Active Work State
- **Work state:** `n/a once moved out of active`
- **Why this state now:** all implementation, fresh internal-review, self-check, completion, authority, and closeout evidence passed.
- **Exit condition:** `n/a - move completed in this closeout.`

## Scope
- [x] Reproduce the strict response-schema incompatibility in a deterministic harness test and document why it is not the selected transport path.
- [x] Choose and implement a compatible canonical post-parse normalization path with a closed, review-kind-specific alias map.
- [x] Preserve `subagent_review_merge.py` as the authoritative validator for gate evidence.
- [x] Generate reviewer prompts directly from every canonical enum required by merge validation.
- [x] Generate reviewer prompts directly from canonical position-field enums as well as finding categories.
- [x] Generate reviewer prompts directly from the canonical top-level field allowlist.
- [x] Define and test the internal reviewer process-collection contract: embed the bounded packet in closed stdin, capture JSONL/stderr, require `turn.completed`, and recover an empty output-last-message only from the final streamed agent message.
- [x] Prove a fresh internal no-context review can complete with a bounded packet and merge-valid result.

## Out of Scope
- [ ] U03 application behavior, Laravel tests, or Atlas evidence.
- [ ] External reviewer/provider invocation.
- [ ] Relaxing required-review isolation or accepting unvalidated prose as gate evidence.

## Definition of Done
- [x] The selected path does not rely on unsupported Codex strict output mode; it validates post-parse against the canonical schema after only a closed alias adaptation.
- [x] Prompt and merge contracts cannot disagree on an accepted finding category.
- [x] Prompt and merge contracts cannot disagree on required position-field values.
- [x] Prompt and merge contracts cannot emit unsupported top-level fields.
- [x] The runner distinguishes a completed valid result from an empty `--output-last-message` and captures a deterministic retryable failure record.
- [x] The produced reviewer result validates through `subagent_review_merge.py` without manual editing.
- [x] Focused regression tests protect the selected compatibility path.

## Validation Steps
- [x] Run the focused compatibility regression tests.
- [x] Run one fresh read-only internal reviewer against a bounded fixture and merge its result.
- [x] Run `bash delphi-ai/self_check.sh` and `git diff --check`.

## Evidence Captured Before Approval
- **Failure command:** `codex exec ... --output-schema delphi-ai/schemas/subagent_review_result.schema.json ...`
- **Observed result:** OpenAI strict response-format validation returned `invalid_json_schema`: the nested finding object omitted optional properties from `required`.
- **Second observed result:** a no-schema fallback reviewer returned `category: test_effectiveness`, which `subagent_review_merge.py` correctly rejected because the canonical enum uses `tests`.
- **Third observed result:** a P1/P2 reviewer returned prose in `performance_position`, `elegance_position`, `structural_soundness_position`, and `operational_fit_position`; `subagent_review_merge.py` correctly rejects them because each must be one of the canonical position enums.
- **Fourth observed result:** the P1/P2 confirmation reviewer returned unsupported top-level `adherence_position`; `subagent_review_merge.py` correctly rejects it because the canonical result schema uses `additionalProperties: false`.
- **Fifth observed result:** a U03 final-review invocation ended without writing its `--output-last-message` file. Repeating the same fresh no-context review through a PTY-backed `codex exec` session and direct session polling returned merge-valid JSON. The runner must make this distinction deterministic instead of accepting an absent file or relying on transport timing.
- **Sixth observed result:** the U04 architecture reviewer returned an otherwise structured result with `category: correctness` and `category: scope_boundary`. The initial direct merge correctly rejected it. `subagent_review_normalize.py` maps those aliases only for `architecture_opinion`, validates the derived JSON against the unchanged canonical schema, and `subagent_review_merge.py` produced the valid U04 decision merge without manual content edits.
- **Seventh observed result:** a first fresh fixture reviewer used prose for `formalizable_hint` and unsupported `candidate_rule_level` values. The strict normalizer rejected it. The dispatcher now renders every finding enum directly from the canonical schema, and the retry result uses only canonical values.
- **Eighth observed result:** file-reading reviews could terminate after the first tool call without `turn.completed` or `--output-last-message`. The runner now embeds the bounded dispatch/package in closed stdin, records JSONL/stderr, requires `turn.completed`, and can recover only the final streamed message. The fresh runner result merged successfully at `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md`.
- **Selected safe path:** omit Codex `--output-schema`; generate a one-object prompt that includes the canonical top-level allowlist and exact enum domains; normalize only documented review-kind-specific aliases; then validate and merge with the existing canonical tools.

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one checkpoint`
- **Why this level:** The correction crosses the canonical reviewer schema, dispatch/merge workflow, and internal client runner behavior.

## Decision Baseline (Frozen)
| ID | Decision | Rationale |
| --- | --- | --- |
| `D-01` | Select a post-parse path: do not pass the canonical optional-field schema to Codex strict-output transport; generate the result contract from that schema, normalize only documented review-kind-specific aliases, and then require the unchanged canonical schema and merge. | A strict transport adapter would duplicate optional-field modeling solely to satisfy a provider constraint and risks drift. The dispatcher-derived contract prevents predictable mismatch; the closed normalizer protects observed historical aliases without weakening the canonical merge boundary. |
| `D-02` | Run internal Codex reviews through `subagent_review_run.py`: embed bounded artifacts in closed stdin, capture JSONL/stderr, require `turn.completed`, and use the final streamed agent message only as a fallback when output-last-message is absent. | The direct file-reading client path can terminate after a tool call without a final event. The runner keeps the review no-context and read-only while distinguishing a retryable collection failure from valid final evidence without any rigid wall-clock timeout. |

## Test Strategy
- **Strategy:** `test-first`
- **RED evidence:** the pre-change dispatcher omitted `schema_version` and a synthetic required top-level field; the normalizer accepted duplicate JSON keys; and the runner test failed because `subagent_review_run.py` did not exist.
- **GREEN evidence:** `subagent_review_dispatch_test.sh`, `subagent_review_normalize_test.sh`, `subagent_review_run_test.sh`, and `subagent_review_strict_schema_compatibility_test.sh` now pass.

## Architecture Review Findings
| Finding ID | Resolution | Rationale / Evidence |
| --- | --- | --- |
| `ARCH-001` | `Integrated` | `ALIAS_MAP_VERSION = v1`, review-kind-specific maps, duplicate-key rejection, no unknown-field stripping, and canonical schema validation keep normalization a closed compatibility layer. `subagent_review_normalize_test.sh` covers aliases, unknown values, unexpected properties, and duplicate keys. |
| `OPS-001` | `Integrated` | The dispatcher renders all required top-level fields and finding enums from `subagent_review_result.schema.json`; the synthetic-schema assertion in `subagent_review_dispatch_test.sh` catches projection drift. |

## Approval
- **Approved by:** product owner, active implementation GOAL; `OK, após ajustar essas instruções, pode voltar direto para a execução. Não precisa de nova autorização para seguir implementando.`
- **Approval scope:** internal Delphi review harness only: schema-derived dispatch, closed normalization, deterministic internal runner, tests, and instruction mirrors. It does not authorize external reviewers or product behavior changes.
- **Approval status:** `approved_for_blocker_remediation`

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | Scope | Reproduce the strict response-schema incompatibility in a deterministic harness test and document why it is not the selected transport path. | test | `bash tools/tests/subagent_review_strict_schema_compatibility_test.sh` | local | passed | The canonical finding object has deliberate optional metadata; the runner omits `--output-schema`. |
| `SCOPE-02` | Scope | Choose and implement a compatible canonical post-parse normalization path with a closed, review-kind-specific alias map. | code + test | `tools/subagent_review_normalize.py`; `bash tools/tests/subagent_review_normalize_test.sh` | local | passed | Alias map `v1` is review-kind-scoped and strict validation remains mandatory. |
| `SCOPE-03` | Scope | Preserve `subagent_review_merge.py` as the authoritative validator for gate evidence. | integration | `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md` | local | passed | Fresh runner output was normalized then merged with the unchanged canonical tool. |
| `SCOPE-04` | Scope | Generate reviewer prompts directly from every canonical enum required by merge validation. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Renderer reads all finding-enum domains from the canonical schema. |
| `SCOPE-05` | Scope | Generate reviewer prompts directly from canonical position-field enums as well as finding categories. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Position enum and category enum are rendered from schema. |
| `SCOPE-06` | Scope | Generate reviewer prompts directly from the canonical top-level field allowlist. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Synthetic required-field fixture proves dynamic top-level rendering. |
| `SCOPE-07` | Scope | Define and test the internal reviewer process-collection contract: embed the bounded packet in closed stdin, capture JSONL/stderr, require `turn.completed`, and recover an empty output-last-message only from the final streamed agent message. | code + test | `tools/subagent_review_run.py`; `bash tools/tests/subagent_review_run_test.sh` | local | passed | Fixture covers completed stream, missing output fallback, and missing-turn rejection. |
| `SCOPE-08` | Scope | Prove a fresh internal no-context review can complete with a bounded packet and merge-valid result. | integration | `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md` | local internal Codex | passed | JSONL contains `turn.completed`; no external reviewer was used. |
| `DOD-01` | Definition of Done | The selected path does not rely on unsupported Codex strict output mode; it validates post-parse against the canonical schema after only a closed alias adaptation. | code + test | `tools/subagent_review_run.py`; `bash tools/tests/subagent_review_strict_schema_compatibility_test.sh` | local | waived | Approval reference: product owner `APROVADO` for the active GOAL. Structure-only internal CLI transport has no user-visible navigation/browser/device flow. |
| `DOD-02` | Definition of Done | Prompt and merge contracts cannot disagree on an accepted finding category. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Category enum is rendered from the canonical schema. |
| `DOD-03` | Definition of Done | Prompt and merge contracts cannot disagree on required position-field values. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Position enum is rendered from the canonical schema. |
| `DOD-04` | Definition of Done | Prompt and merge contracts cannot emit unsupported top-level fields. | code + test | `tools/subagent_review_dispatch.py`; `bash tools/tests/subagent_review_dispatch_test.sh` | local | passed | Top-level required fields are schema-derived and synthetic-field tested. |
| `DOD-05` | Definition of Done | The runner distinguishes a completed valid result from an empty `--output-last-message` and captures a deterministic retryable failure record. | code + test | `tools/subagent_review_run.py`; `bash tools/tests/subagent_review_run_test.sh` | local | waived | Approval reference: product owner `APROVADO` for the active GOAL. Structure-only runner protocol has no user-visible navigation/browser/device flow. |
| `DOD-06` | Definition of Done | The produced reviewer result validates through `subagent_review_merge.py` without manual editing. | integration | `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md` | local internal Codex | passed | Normalizer reported zero aliases and merge succeeded. |
| `DOD-07` | Definition of Done | Focused regression tests protect the selected compatibility path. | test | `bash tools/tests/subagent_review_dispatch_test.sh`; `bash tools/tests/subagent_review_normalize_test.sh`; `bash tools/tests/subagent_review_run_test.sh`; `bash tools/tests/subagent_review_strict_schema_compatibility_test.sh` | local | waived | Approval reference: product owner `APROVADO` for the active GOAL. Deterministic Delphi tooling tests do not expose a user-visible navigation/browser/device journey. |
| `VAL-01` | Validation Steps | Run the focused compatibility regression tests. | test | four focused test commands listed in `DOD-05` | local | passed | All commands pass. |
| `VAL-02` | Validation Steps | Run one fresh read-only internal reviewer against a bounded fixture and merge its result. | internal no-context review | `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md` | local internal Codex | passed | Fresh `--ephemeral`, read-only, stdin-embedded review passed the canonical merge. |
| `VAL-03` | Validation Steps | Run `bash delphi-ai/self_check.sh` and `git diff --check`. | test | `bash self_check.sh`; `git diff --check` | local | passed | Self-check: 216 individual checks, 0 failures, 0 coherence failures; diff check passed. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / review harness tests | New dispatcher, normalizer, runner, and strict transport policy. | four focused test commands listed in `DOD-05` | Local-Implemented | passed | `bash tools/tests/subagent_review_*_test.sh` | Focused deterministic coverage passed. |
| delphi-ai / self-check | Canonical workflow, manifest, skill, and mirrors changed. | `bash self_check.sh` | Completed | passed | `bash self_check.sh` | 216 individual checks, 0 failures, 0 coherence failures. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| fresh internal no-context architecture fixture | Canonical boundary, alias normalization, and dispatch-schema drift. | passed | `foundation_documentation/artifacts/tmp/delphi-review-schema-compatibility-runner.merge.md` | `ARCH-001` medium; `OPS-001` low | Both integrated in this TODO and protection tests. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| no-context reviewer contract | Provider-specific schema fork, permissive normalization, incomplete stream accepted as review evidence, or external reviewer substitution. | passed | `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path workflows --path skills --json-output /tmp/delphi-review-schema-rule-spirit.json` | 14 review-severity heuristic hits, none in the new `subagent_review_*` surfaces and no blocker | Existing scanner/self-test/loopback literals are unrelated to this harness; no P1/P2 or new bypass shape was found. |

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | The discovered review-harness failure is governed TODO work. | Explicit approval, RED/GREEN evidence, and criterion-specific closeout. | Chat-only or unrecorded workaround authority. | Record the correction and run completion/authority guards. |
| `workflows/docker/subagent-orchestration-method.md` | Dispatcher, collection, normalization, and merge form one no-context review path. | Internal isolation, bounded packets, strict canonical merge. | External reviewer substitution or permissive result repair. | Add the runner/normalizer and update the canonical workflow/mirrors. |
| `workflows/docker/update-skill-method.md` | The orchestration workflow skill and support classification changed. | Canonical, `.cline`, `.claude`, `.clinerules`, and tooling-register coherence. | Script-only behavior with stale mirrors. | Synchronize mirrors and run `self_check.sh`. |

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** local-only Delphi harness correction; no promotion lane applies once local validation and commit/push are complete.
- **Post-commit/push status:** `complete`
- **Next path/status action:** `n/a - moved to foundation_documentation/todos/completed/ in the Delphi harness closeout commit.`

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
