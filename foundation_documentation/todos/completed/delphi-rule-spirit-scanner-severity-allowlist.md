# TODO: Delphi Rule-Spirit Scanner Severity And Allowlist

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade follow-up validation approved `C-06`: improve `rule_spirit_anti_pattern_scan.sh` with severity classification, allowlist support, and machine-readable output. The purpose is to make the Rule-Spirit Anti-Pattern Hunt more useful before CI/Copilot finds P1/P2 issues, without pretending the heuristic scanner replaces human architecture judgment.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `C-06`
- **Why this is the right current slice:** This is one Delphi self-maintenance improvement for the existing Rule-Spirit delivery gate.
- **Direct-to-TODO rationale:** The user approved the recommendation to proceed with this split after the previous commit/push.

## Contract Boundary
- This TODO improves scanner evidence quality; it does not make the scanner the sole P1/P2 adjudicator.
- Scanner allowlists are temporary exceptions with owner, expiration, and reason. Expired entries remain active findings.
- JSON output is in scope as the first machine-readable contract. SARIF is intentionally out of scope until the JSON schema proves useful.

## Delivery Status Canon
- **Current delivery stage:** `Completed`
- **Qualifiers:** `none`
- **Next exact step:** `n/a - local-only Delphi self-maintenance slice completed and moved to completed/ by C-07 closeout cleanup.`

## Scope
- [x] Add severity taxonomy and max-active severity reporting to the scanner while preserving default nonblocking text output.
- [x] Add temporary allowlist support with finding keys, owner, expiration, and reason; expired entries remain active findings.
- [x] Add optional JSON output that records findings, severity, keys, active/allowlisted counts, and allowlist status.
- [x] Add regression fixture coverage for review findings, blocker findings, active allowlist, expired allowlist, and fail-on severity behavior.
- [x] Update canonical workflow/tooling surfaces so Rule-Spirit gate guidance does not drift from the tool contract.

## Out of Scope
- [ ] Add SARIF output in this slice.
- [ ] Replace human P1/P2 judgment or rule-specific review with scanner output.
- [ ] Change downstream Belluga Now project code or project-specific documentation.
- [ ] Make review/warning findings block by default.

## Definition of Done
- [x] Existing scanner invocation remains compatible, including text output and `--fail-on-findings`.
- [x] Severity classification is deterministic and exposes `review`, `warning`, and `blocker` levels.
- [x] Allowlist entries require key, owner, expiration, and reason, and expired entries do not suppress findings.
- [x] JSON output exposes stable finding keys, counts, severities, and allowlist status.
- [x] Canonical TODO delivery guidance tells agents how to use JSON evidence and temporary allowlists.

## Validation Steps
- [x] Run `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh`.
- [x] Run `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`.
- [x] Run `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path config --json-output /tmp/delphi-rule-spirit-scan.json`.
- [x] Run `bash self_check.sh`.
- [x] Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md --require-delivery-gates`.
- [x] Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md`.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Add severity taxonomy and max-active severity reporting to the scanner while preserving default nonblocking text output. | code + test | `tools/rule_spirit_anti_pattern_scan.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Scanner reports `Max active severity` and remains nonblocking unless a fail threshold is selected. |
| `SCOPE-02` | `Scope` | Add temporary allowlist support with finding keys, owner, expiration, and reason; expired entries remain active findings. | code + test | `tools/rule_spirit_anti_pattern_scan.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Fixture covers active and expired allowlist entries. |
| `SCOPE-03` | `Scope` | Add optional JSON output that records findings, severity, keys, active/allowlisted counts, and allowlist status. | code + test | `--json-output /tmp/delphi-rule-spirit-scan.json`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | JSON schema `rule-spirit-scan-v1` contains finding keys, counts, max severity, and allowlist metadata. |
| `SCOPE-04` | `Scope` | Add regression fixture coverage for review findings, blocker findings, active allowlist, expired allowlist, and fail-on severity behavior. | test | `tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Test exercises all C-06 behavior. |
| `SCOPE-05` | `Scope` | Update canonical workflow/tooling surfaces so Rule-Spirit gate guidance does not drift from the tool contract. | docs | `workflows/docker/todo-delivery-gates-method.md`; `skills/wf-docker-todo-delivery-gates-method/SKILL.md`; `templates/todo_template.md`; `tools/manifest.md`; `skills/deterministic-tooling-register.md` | local | passed | Guidance now mentions JSON evidence and temporary allowlist semantics. |
| `DOD-01` | `Definition of Done` | Existing scanner invocation remains compatible, including text output and `--fail-on-findings`. | test | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Existing invocation and failure option are retained. |
| `DOD-02` | `Definition of Done` | Severity classification is deterministic and exposes `review`, `warning`, and `blocker` levels. | test | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `/tmp/delphi-rule-spirit-scan.json` | local | passed | Fixture asserts `warning` and `blocker`; repo scan produced max active severity `review`. |
| `DOD-03` | `Definition of Done` | Allowlist entries require key, owner, expiration, and reason, and expired entries do not suppress findings. | test | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Active entry suppresses one finding; expired entry remains active. |
| `DOD-04` | `Definition of Done` | JSON output exposes stable finding keys, counts, severities, and allowlist status. | test | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `/tmp/delphi-rule-spirit-scan.json` | local | passed | Fixture parses and asserts JSON fields. |
| `DOD-05` | `Definition of Done` | Canonical TODO delivery guidance tells agents how to use JSON evidence and temporary allowlists. | docs | `workflows/docker/todo-delivery-gates-method.md`; `skills/wf-docker-todo-delivery-gates-method/SKILL.md`; `templates/todo_template.md` | local | passed | Delivery guidance and template now explain JSON evidence and allowlist requirements. |
| `VAL-01` | `Validation Steps` | Run `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh`. | test | `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Shell syntax check exited 0. |
| `VAL-02` | `Validation Steps` | Run `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`. | test | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | local | passed | Output: `rule_spirit_anti_pattern_scan_test: OK`. |
| `VAL-03` | `Validation Steps` | Run `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path config --json-output /tmp/delphi-rule-spirit-scan.json`. | scan | `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path config --json-output /tmp/delphi-rule-spirit-scan.json` | local | passed | Repo scan exited 0 with 9 review-level active findings and no blocker. |
| `VAL-04` | `Validation Steps` | Run `bash self_check.sh`. | test | `bash self_check.sh` | local | passed | Individual files checked: 203; individual failures: 0; coherence failures: 0. |
| `VAL-05` | `Validation Steps` | Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md --require-delivery-gates`. | guard | `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md --require-delivery-gates` | local | passed | Guard result: `Overall outcome: go`. |
| `VAL-06` | `Validation Steps` | Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md`. | guard | `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md` | local | passed | Guard result: `Overall outcome: go`. |

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | This is local Delphi scanner, test, and documentation work. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder`
- **Scope-check command:** `n/a - Delphi self-maintenance repository has no project profile checker in scope for this slice`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single approved split; implementation may proceed inside this TODO`
- **Why this level:** The change touches scanner CLI behavior, fixture tests, delivery-gate guidance, and tooling registry documentation.

## Canonical Module Anchors
- **Primary module doc:** `workflows/docker/todo-delivery-gates-method.md`
- **Secondary module docs:**
  - `skills/wf-docker-todo-delivery-gates-method/SKILL.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`
  - `tools/manifest.md`
- **Planned decision promotion targets (module sections):**
  - Rule-Spirit Anti-Pattern Hunt scanner evidence
- **Module decision consolidation targets (required):**
  - `workflows/docker/todo-delivery-gates-method.md`
  - `skills/wf-docker-todo-delivery-gates-method/SKILL.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`
  - `tools/manifest.md`

## Decisions
- [x] `D-01` Keep the scanner nonblocking by default; severity thresholds are opt-in through fail flags.
- [x] `D-02` Implement JSON output before SARIF so the schema can stabilize locally.
- [x] `D-03` Make allowlists temporary and auditable rather than permanent ignores.

## Decision Baseline
- [x] `D-01` Default scanner runs remain advisory evidence.
- [x] `D-02` JSON is the machine-readable C-06 contract; SARIF is deferred.
- [x] `D-03` Allowlist entries require owner, expiration, and reason.

## Approval
- **Approved by:** user approved C-06 implementation on 2026-05-25 with "Na sequência, pode fazer de acordo com sua recomendação."
- **Approval scope:** implement the recommended C-06 split: severity taxonomy, temporary allowlist semantics, JSON output, compatibility preservation, fixtures, and canonical documentation.
- **Execution not authorized by approval:** SARIF output, downstream project changes, automated P1/P2 adjudication, or default blocking on review/warning findings.
- **Renewed approval required when:** scanner output becomes mandatory blocking authority, SARIF is added as a new CI artifact contract, or allowlist semantics change from temporary exception to permanent suppression.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | C-06 changes tooling used by the mandatory Rule-Spirit Anti-Pattern Hunt. | Rule-Spirit review stays required and unresolved P1/P2 findings block delivery. | Treating scanner output as a replacement for human P1/P2 judgment. | Add severity and JSON evidence while preserving review ownership. |
| `workflows/docker/todo-delivery-gates-method.md` | Delivery gate guidance must explain the stronger scanner contract. | JSON evidence and allowlist semantics remain transparent. | Hidden or permanent allowlist bypasses. | Update canonical delivery guidance and skill mirror. |
| `workflows/docker/update-skill-method.md` | C-06 edits workflow, skill, template, and registry surfaces. | Canonical and mirror surfaces must remain synchronized. | Tool behavior that exists only in the script. | Run self-check after documentation updates. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / shell syntax | Scanner and shell fixture changed. | `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh` | Local-Implemented | passed | `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh` | Syntax check exited 0. |
| delphi-ai / scanner regression | New severity, allowlist, and JSON behavior. | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | Local-Implemented | passed | `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh` | Fixture suite passed. |
| delphi-ai / self-check | Workflow, skill, template, manifest, and registry docs changed. | `bash self_check.sh` | Local-Implemented | passed | `bash self_check.sh` | Individual files checked: 203; individual failures: 0; coherence failures: 0. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| C-06 scanner package | CI/Copilot priority risks in shell parsing, exit codes, allowlist semantics, JSON output, and false high-severity findings | passed | `bash -n tools/rule_spirit_anti_pattern_scan.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path config --json-output /tmp/delphi-rule-spirit-scan.json` | none | Initial blocker false positive was narrowed before delivery evidence; repo scan now has no active blocker. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO delivery gates and rule-spirit scanner | Scanner becoming hidden authority, permanent allowlist bypass, false blocker noise, or documentation drift | passed | `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path config --json-output /tmp/delphi-rule-spirit-scan.json` | 9 review-level heuristic findings; no blocker | Findings are existing review-only guard/bypass strings in test/tool surfaces; no unresolved blocking priority finding. |

## Security Risk Assessment
- **Risk level:** `low`
- **Why this risk level:** The change adds local scanner output and allowlist parsing; it does not process secrets, credentials, or remote inputs.
- **Attack surface in scope:** local shell invocation and generated JSON artifacts.
- **Attack simulation decision:** `not_needed`
- **Review evidence:** scanner only searches selected source paths and existing fixture verifies `.env` secret text is not printed.
- **Residual security risk:** malformed allowlist inputs are rejected; JSON artifact paths remain caller-controlled local paths.

## Performance & Concurrency Risk Assessment
- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** The scanner remains an offline `rg`-based heuristic over selected paths; no runtime service or concurrent mutation path is changed.
- **Current delivery stage at review time:** `Local-Implemented`
- **Concurrency surfaces in scope:** none.
- **Performance evidence:** repo scan over tools/skills/workflows/rules/templates/config completed locally.
- **Residual performance risk:** large repositories may need scoped `--path` arguments as before.

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `n/a` | `n/a` | `n/a` | `n/a` | This TODO is not executing a promotion lane. | `accepted` | `n/a` |
