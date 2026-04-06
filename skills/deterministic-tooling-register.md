# Deterministic Tooling Register

Canonical Delphi register for deciding whether a skill's repeatable mechanics should stay in prose, move into lint/analyzer enforcement, or be extracted into deterministic tooling.

This register is advisory for skill maintenance. It does not authorize tool creation by itself. If a new canonical tool is added or materially changed, `tools/manifest.md` must still be updated in the same change.

## Classification Model
- `skill-only`
  - The skill is mainly governance, judgment, orchestration, or sequencing. Tooling may support prerequisites, but the core skill should remain prose-driven.
- `lint/analyzer`
  - The right deterministic extraction path is static analysis or rule enforcement, not a generic shell/python helper.
- `partial-tool`
  - Only the mechanical subset should be scripted. Human judgment still decides framing, tradeoffs, or interpretation.
- `full-tool-candidate`
  - The workflow is objective enough that a deterministic helper could plausibly execute most of it end-to-end.
- `already-backed`
  - A canonical tool/script already materially supports the repeatable mechanics of the skill.

## Review Heuristics
- Prefer `skill-only` for rules, governance methods, design exploration, and strategic transitions.
- Prefer `lint/analyzer` for static code-shape violations that should be prevented before runtime.
- Prefer `partial-tool` for audits, scanners, scaffolders, readiness checks, and report generation.
- Prefer `full-tool-candidate` only when inputs, checks, and outputs are objective enough to avoid fake determinism.
- Prefer `already-backed` when the repo already ships a canonical helper that materially carries the repetitive portion.

## Immediate Priorities
## Rule Skills

### Docker Rules
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `rule-docker-docker-architecture-mode-transition-model-decision` | `skill-only` | Governance trigger; keep as rule, not tool. |
| `rule-docker-docker-ci-pipeline-model-decision` | `skill-only` | Governance trigger; keep as rule, not tool. |
| `rule-docker-docker-runtime-ingress-model-decision` | `skill-only` | Governance trigger; keep as rule, not tool. |
| `rule-docker-documentation-migration-model-decision` | `skill-only` | Governance trigger; keep as rule, not tool. |
| `rule-docker-flutter-architecture` | `skill-only` | Governance trigger; keep as rule, not tool. |
| `rule-docker-shared-core-instructions-always-on` | `skill-only` | Always-on baseline; deterministic tooling would be fake authority. |
| `rule-docker-shared-delphi-project-setup-model-decision` | `skill-only` | Setup trigger belongs in governance; setup reporting can be tooled elsewhere. |
| `rule-docker-shared-foundation-docs-sync-model-decision` | `skill-only` | Canonical sync requirement; not a direct tool target. |
| `rule-docker-shared-initialization-readiness-model-decision` | `skill-only` | Governance shell around readiness checks; keep rule-level. |
| `rule-docker-shared-project-mandate-always-on` | `skill-only` | Mandate authority must remain prose-driven. |
| `rule-docker-shared-realtime-delta-streams-model-decision` | `skill-only` | Architectural decision gate; not a deterministic helper target. |
| `rule-docker-shared-self-improvement-manual` | `skill-only` | Instruction-only session governance; not a deterministic helper target. |
| `rule-docker-shared-session-lifecycle-model-decision` | `skill-only` | Lifecycle governance; not a deterministic helper target. |
| `rule-docker-shared-todo-driven-execution-model-decision` | `skill-only` | Tactical authority rule; deterministic helpers can support, not replace. |
| `rule-docker-shared-workflow-definition-model-decision` | `skill-only` | Workflow integrity rule; keep as governance. |

### Flutter Rules
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `rule-flutter-flutter-architecture-always-on` | `lint/analyzer` | Architecture enforcement should keep moving into analyzer rules, not shell helpers. |
| `rule-flutter-flutter-contract-alignment-always-on` | `skill-only` | Contract alignment still needs doc and code judgment. |
| `rule-flutter-flutter-controller-workflow-glob` | `skill-only` | File-path trigger; deterministic value lives in the target workflow, not the glob rule. |
| `rule-flutter-flutter-documentation-contracts-always-on` | `skill-only` | Canonical doc sync is judgment-heavy even when checks assist. |
| `rule-flutter-flutter-domain-workflow-glob` | `skill-only` | File-path trigger; deterministic value lives in the target workflow, not the glob rule. |
| `rule-flutter-flutter-repository-workflow-glob` | `skill-only` | File-path trigger; branch-delta checks can support but not replace the rule. |
| `rule-flutter-flutter-route-workflow-glob` | `skill-only` | File-path trigger; route audit support belongs in the workflow/tooling, not this rule. |
| `rule-flutter-flutter-screen-workflow-glob` | `skill-only` | File-path trigger; keep as routing rule into the right skill/workflow. |

### Laravel Rules
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `rule-laravel-shared-ability-catalog-sync-model-decision` | `skill-only` | Catalog sync is governance-first; static checks can support later. |
| `rule-laravel-shared-core-instructions-always-on` | `skill-only` | Always-on baseline; deterministic tooling would be fake authority. |
| `rule-laravel-shared-domain-resolution-testing-model-decision` | `skill-only` | Decision trigger belongs in governance; route/test scanning belongs in workflow support. |
| `rule-laravel-shared-foundation-docs-sync-model-decision` | `skill-only` | Canonical sync requirement; not a direct tool target. |
| `rule-laravel-shared-initialization-readiness-model-decision` | `skill-only` | Governance shell around readiness checks; keep rule-level. |
| `rule-laravel-shared-project-mandate-always-on` | `skill-only` | Mandate authority must remain prose-driven. |
| `rule-laravel-shared-realtime-delta-streams-model-decision` | `skill-only` | Architectural decision gate; not a deterministic helper target. |
| `rule-laravel-shared-self-improvement-manual` | `skill-only` | Instruction-only session governance; not a deterministic helper target. |
| `rule-laravel-shared-session-lifecycle-model-decision` | `skill-only` | Lifecycle governance; not a deterministic helper target. |
| `rule-laravel-shared-settings-kernel-patch-contract-model-decision` | `skill-only` | Contract policy remains judgment-heavy even if future validators help. |
| `rule-laravel-shared-tenant-access-guardrails-model-decision` | `skill-only` | Decision trigger belongs in governance; scanning belongs in workflow support. |
| `rule-laravel-shared-todo-driven-execution-model-decision` | `skill-only` | Tactical authority rule; deterministic helpers can support, not replace. |
| `rule-laravel-shared-workflow-definition-model-decision` | `skill-only` | Workflow integrity rule; keep as governance. |

## Flutter Umbrella and Smell Skills
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `flutter-architecture-adherence` | `lint/analyzer` | Prefer analyzer/lint expansion; existing support includes [`reset_analyzer_state.sh`](../scripts/flutter/reset_analyzer_state.sh) for analyzer recovery plus end-of-cycle cleanup hygiene. |
| `flutter-performance-smell-scanner` | `skill-only` | Umbrella orchestration skill; deterministic support belongs in the smell-specific rules or analyzers. |
| `flutter-smell-async-navigation` | `lint/analyzer` | Best prevented by analyzer rules for async navigation ownership. |
| `flutter-smell-build-side-effects` | `lint/analyzer` | Best prevented by analyzer rules for side effects in widget lifecycle/build. |
| `flutter-smell-image-media` | `lint/analyzer` | Static heuristics are a better fit than a standalone shell tool. |
| `flutter-smell-layout-hotspots` | `lint/analyzer` | Static heuristics are a better fit than a standalone shell tool. |
| `flutter-smell-list-performance` | `lint/analyzer` | Static heuristics are a better fit than a standalone shell tool. |
| `flutter-smell-mounted-checks` | `lint/analyzer` | Analyzer/lint route is stronger than shell scripting for `mounted` misuse. |
| `flutter-widget-local-state-heuristics` | `lint/analyzer` | Widget-state boundary is primarily static-shape governance. |

## Operational and Audit Skills
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `branch-rebaseline-preflight` | `already-backed` | Existing support via [`branch_rebaseline_preflight.sh`](../tools/branch_rebaseline_preflight.sh); use the helper as the default audit path and keep remote deletion manual. |
| `backend-concurrency-idempotency-validation` | `already-backed` | Existing support via [`backend_concurrency_probe.sh`](../tools/backend_concurrency_probe.sh); this is the strongest of the new helpers because it runs real `5|10|20`-style concurrent HTTP probes. Human judgment still validates domain invariants and idempotency policy. |
| `bug-fix-evidence-loop` | `already-backed` | Existing support via [`bug_fix_evidence_scaffold.sh`](../tools/bug_fix_evidence_scaffold.sh); use it to structure reproduction, mandatory questions, and stage coverage before diagnosis. |
| `endpoint-performance-scrutiny` | `partial-tool` | Existing support via [`endpoint_performance_review_scaffold.sh`](../tools/endpoint_performance_review_scaffold.sh) plus [`exact_lookup_anti_pattern_audit.sh`](../tools/exact_lookup_anti_pattern_audit.sh), but the current tooling is still scaffold + heuristic scan. Stronger proof still depends on `explain`, query logs, benchmarks, or equivalent runtime evidence. |
| `frontend-race-condition-validation` | `already-backed` | Existing support via [`frontend_race_probe.sh`](../tools/frontend_race_probe.sh) plus [`frontend_race_validation_scaffold.sh`](../tools/frontend_race_validation_scaffold.sh); the probe runs real burst/repetition orchestration while scenario semantics remain in stack-native tests. |
| `flutter-device-test-runner` | `already-backed` | Existing support via [`device_single_test_resilient.sh`](flutter-device-test-runner/scripts/device_single_test_resilient.sh); future work is report ergonomics, not full replacement. |
| `github-stage-promotion-orchestrator` | `already-backed` | Existing support via [`github_stage_promotion_snapshot.sh`](../tools/github_stage_promotion_snapshot.sh); use it to collect the current branch/PR/check snapshot before manual promotion decisions. |
| `runtime-load-stress-validation` | `already-backed` | Existing support via [`runtime_load_probe.sh`](../tools/runtime_load_probe.sh) plus [`runtime_load_validation_scaffold.sh`](../tools/runtime_load_validation_scaffold.sh); the probe runs deterministic staged HTTP load/stress checks with threshold evaluation while non-HTTP paths may still need stack-local harnesses. |
| `security-adversarial-review` | `skill-only` | Threat modeling and exploitability judgment should stay human; helpers may collect evidence only. |
| `stitch-mcp-design-workflow` | `skill-only` | The MCP already provides the deterministic tool layer; the skill is safe sequencing and fallback strategy. |
| `test-creation-standard` | `already-backed` | Existing support via [`test_coverage_matrix_scaffold.sh`](../tools/test_coverage_matrix_scaffold.sh); use it to scaffold coverage/gate planning before choosing real tests. |
| `test-orchestration-suite` | `already-backed` | Existing support via [`test_orchestration_status_report.sh`](../tools/test_orchestration_status_report.sh); use it to enforce explicit required-stage accounting while keeping orchestration judgment human. |
| `test-quality-audit` | `already-backed` | Existing support via [`test_quality_audit.sh`](../tools/test_quality_audit.sh); use it for deterministic static findings and keep the final audit judgment in the skill. |
| `verification-debt-audit` | `already-backed` | Existing support via [`verification_debt_audit.sh`](../tools/verification_debt_audit.sh); use it for deterministic evidence collection and keep final closure judgment in the skill. |

## Docker Workflow Skills
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `wf-docker-architecture-mode-transition-method` | `skill-only` | Strategic transition workflow; keep judgment-driven. |
| `wf-docker-brownfield-normalization-method` | `already-backed` | Existing support via [`project_setup_normalization_packet.py`](../tools/project_setup_normalization_packet.py) plus [`project_recalibration_doctor.sh`](../tools/project_recalibration_doctor.sh); use them to separate manual-remediation versus normalization-TODO tracks from a derived setup report before opening remediation work. |
| `wf-docker-delphi-project-setup-method` | `already-backed` | Existing support via [`delphi_project_setup_report.sh`](../tools/delphi_project_setup_report.sh), [`project_setup_normalization_packet.py`](../tools/project_setup_normalization_packet.py), and [`project_recalibration_doctor.sh`](../tools/project_recalibration_doctor.sh); use them to collect lane/readiness/drift evidence and derive bounded normalization tracks before deciding whether remediation TODOs are required. |
| `wf-docker-documentation-migration-method` | `skill-only` | Migration/gap analysis is too judgment-heavy for deterministic extraction. |
| `wf-docker-deterministic-todo-validation-method` | `already-backed` | Existing support via [`todo_validation_bundle_export.py`](../tools/todo_validation_bundle_export.py) and [`todo_deterministic_validator.py`](../tools/todo_deterministic_validator.py); use them to block missing structural TODO obligations with diagnostic output. |
| `wf-docker-environment-readiness-method` | `already-backed` | Existing support via [`environment_readiness_report.sh`](../tools/environment_readiness_report.sh), plus [`verify_context.sh`](../tools/verify_context.sh), [`verify_adherence_sync.sh`](../tools/verify_adherence_sync.sh), and [`verify_environment.sh`](../scripts/docker/verify_environment.sh). |
| `wf-docker-genesis-bootstrap-method` | `skill-only` | Bootstrap interviews and canonicalization remain human-led. |
| `wf-docker-independent-critique-method` | `skill-only` | Independent no-context critique is governance and package hygiene; deterministic tooling may assist packaging later, but the challenge itself should stay reviewer-driven. |
| `wf-docker-independent-final-review-method` | `skill-only` | Independent no-context final review is a governance/adherence challenge lane; tooling may assist packaging later, but the review itself should stay reviewer-driven. |
| `wf-docker-persona-selection-method` | `skill-only` | Profile/persona choice is governance, not deterministic tooling. |
| `wf-docker-performance-concurrency-validation-method` | `skill-only` | This workflow is the canonical `pcv-1` policy package. Deterministic tooling belongs in the lane-specific helpers, not in faux-deterministic policy automation. |
| `wf-docker-post-session-review-method` | `skill-only` | Principle extraction and English review remain human tasks; automation should stay assistive only. |
| `wf-docker-profile-selection-method` | `skill-only` | Profile selection is governance, not deterministic tooling. |
| `wf-docker-runtime-index-method` | `already-backed` | Existing support via [`runtime_session_index.py`](../tools/runtime_session_index.py); use it to surface active TODO continuity, blockers, and open handoffs without creating a new source of truth. |
| `wf-docker-realtime-delta-streams-method` | `skill-only` | SSE contract design remains architectural judgment. |
| `wf-docker-self-improvement-session-method` | `skill-only` | Instruction-only session governance should stay human-led. |
| `wf-docker-session-lifecycle-method` | `skill-only` | Lifecycle governance should stay human-led. |
| `wf-docker-subagent-orchestration-method` | `already-backed` | Existing support via [`subagent_review_dispatch.py`](../tools/subagent_review_dispatch.py) and [`subagent_review_merge.py`](../tools/subagent_review_merge.py); use them to package bounded no-context review requests and merge structured reviewer output without inventing hidden authority. |
| `wf-docker-todo-driven-execution-method` | `skill-only` | Tactical execution governance can be supported by checks, but not replaced by tooling. |
| `wf-docker-update-ci-pipeline-method` | `already-backed` | Existing support via [`ci_pipeline_surface_audit.sh`](../tools/ci_pipeline_surface_audit.sh); use it to inventory workflow coverage and expected stack hints before/after CI edits. |
| `wf-docker-update-runtime-and-ingress-method` | `already-backed` | Existing support via [`runtime_ingress_surface_audit.sh`](../tools/runtime_ingress_surface_audit.sh); use it to inventory runtime/ingress surfaces and compose readiness before/after runtime edits. |
| `wf-docker-update-skill-method` | `already-backed` | Existing support via [`sync_cline_skill_mirrors.sh`](../tools/sync_cline_skill_mirrors.sh), [`sync_clinerules_mirrors.sh`](../tools/sync_clinerules_mirrors.sh), and [`self_check.sh`](../tools/self_check.sh); this register now tracks the missing review step. |

## Flutter Workflow Skills
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `wf-flutter-create-controller-method` | `already-backed` | Existing support via [`flutter_workflow_scaffold.sh`](../tools/flutter_workflow_scaffold.sh) with `--kind controller`; use it for the repeatable checklist before controller implementation. |
| `wf-flutter-create-domain-method` | `already-backed` | Existing support via [`flutter_workflow_scaffold.sh`](../tools/flutter_workflow_scaffold.sh) with `--kind domain`; use it for repeatable doc/file/test preparation before aggregate design. |
| `wf-flutter-create-repository-method` | `already-backed` | Existing support via [`flutter_workflow_scaffold.sh`](../tools/flutter_workflow_scaffold.sh) with `--kind repository`; use it for repeatable mapper/contract/test preparation before implementation. |
| `wf-flutter-create-route-method` | `already-backed` | Existing support via [`flutter_route_contract_audit.sh`](../tools/flutter_route_contract_audit.sh); use it after route generation and classify every hit before delivery. |
| `wf-flutter-create-screen-method` | `already-backed` | Existing support via [`flutter_workflow_scaffold.sh`](../tools/flutter_workflow_scaffold.sh) with `--kind screen`; use it for repeatable screen/controller/route checklist preparation. |

## Laravel Workflow Skills
| Skill | Classification | Support / Preferred Shape |
| --- | --- | --- |
| `wf-laravel-create-api-endpoint-method` | `already-backed` | Existing support via [`laravel_workflow_scaffold.sh`](../tools/laravel_workflow_scaffold.sh) with `--kind api-endpoint`; use it to structure contract/route/security/test preparation before edits. |
| `wf-laravel-create-domain-method` | `already-backed` | Existing support via [`laravel_workflow_scaffold.sh`](../tools/laravel_workflow_scaffold.sh) with `--kind domain`; use it to structure docs/model/migration/test preparation before implementation. |
| `wf-laravel-create-package-method` | `already-backed` | Existing support via [`assert_package_decoupling.py`](wf-laravel-create-package-method/scripts/assert_package_decoupling.py); more validators could be added later. |
| `wf-laravel-domain-resolution-testing` | `already-backed` | Existing support via [`laravel_domain_resolution_test_audit.sh`](../tools/laravel_domain_resolution_test_audit.sh); use it to classify touched tests before claiming resolution coverage. |
| `wf-laravel-tenant-access-guardrails` | `already-backed` | Existing support via [`laravel_tenant_access_guardrails_audit.sh`](../tools/laravel_tenant_access_guardrails_audit.sh); use it for static route-file guardrail checks before deeper validation. |
