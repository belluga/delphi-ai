# Tool Manifest

Canonical inventory of deterministic tools that ship with Delphi-AI.

Use this manifest before creating a new helper script. If a new canonical tool is added under `delphi-ai/tools/`, update this file in the same change.
If the question is whether a skill should gain deterministic support at all, consult `delphi-ai/skills/deterministic-tooling-register.md` first; the register classifies skills by extractability and links existing support where relevant.

This manifest covers the canonical `delphi-ai/tools/` directory. Thin root-level wrappers such as `self_check.sh` are convenience entrypoints, not separate tools.

| Path | Type | Purpose |
| --- | --- | --- |
| `tools/audit_instruction_baselines.sh` | shell | Audit canonical Delphi skills/rules/workflows and mirror coherence. |
| `tools/audit_escalation_guard.py` | python | Read a tactical TODO `Audit Trigger Matrix`, emit a TEACH runtime decision for the minimum required audit floor, and block missing or inconsistent trigger declarations. |
| `tools/backend_concurrency_probe.sh` | shell | Send real concurrent HTTP requests and summarize response-code/latency evidence for concurrency/idempotency validation. |
| `tools/branch_rebaseline_preflight.sh` | shell | Audit non-lane branches against `origin/dev`, classify ancestry-vs-patch-equivalence false positives, optionally apply safe local cleanup, and safely rebaseline `dev` when no blockers remain. |
| `tools/bug_fix_evidence_scaffold.sh` | shell | Generate a markdown evidence packet scaffold for the Bug Fix Evidence Loop workflow. |
| `tools/ci_pipeline_surface_audit.sh` | shell | Audit CI workflow files for Flutter/Laravel/Docker coverage hints, cache hints, and permission/secret surfaces. |
| `tools/delphi_project_setup_report.sh` | shell | Produce a read-only downstream setup/recalibration inventory covering lane classification, readiness preflight, surface inventory, drift buckets, and an optional derived JSON snapshot. |
| `tools/endpoint_performance_review_scaffold.sh` | shell | Generate a markdown review scaffold for endpoint/query performance scrutiny. |
| `tools/environment_readiness_report.sh` | shell | Produce a read-only downstream readiness report by combining Genesis zero-state install preflight, Delphi readiness checks, non-mutating project environment checks, and validation-topology hints. |
| `tools/exact_lookup_anti_pattern_audit.sh` | shell | Heuristically scan Flutter/Laravel code for broad-fetch, page-walk, and in-memory exact-lookup anti-patterns. |
| `tools/frontend_race_probe.sh` | shell | Orchestrate real repeated frontend race probes by burst level and capture deterministic pass/fail evidence for stack-native test runners. |
| `tools/frontend_race_validation_scaffold.sh` | shell | Generate a markdown scenario matrix for frontend race-condition validation. |
| `tools/flutter_workflow_scaffold.sh` | shell | Generate repeatable doc/file/validation checklists for Delphi Flutter controller, domain, repository, and screen workflows. |
| `tools/gate_finding_resolution_extract.py` | python | Extract a derived machine-checkable gate-finding resolution packet from the authoritative tactical TODO. |
| `tools/gate_finding_resolution_scaffold.py` | python | Render a TODO-ready markdown resolution table scaffold from a merged subagent review packet. |
| `tools/laravel_workflow_scaffold.sh` | shell | Generate repeatable doc/file/validation checklists for Delphi Laravel endpoint and domain workflows. |
| `tools/list_public_codex_skill_mirrors.sh` | shell | Emit the canonical list of Delphi skills that must remain mirrored into `~/.codex/skills/public`. |
| `tools/paced_metrics_core.py` | python | Shared PACED metrics helpers used by CLI tools today and designed for future MCP tool exposure. |
| `tools/paced_metrics_summary.py` | python | Aggregate rule events plus TODO-derived gate resolutions into derived Clean Rate and effectiveness summaries. |
| `tools/orchestration_delivery_guard.py` | python | Validate approved orchestration execution evidence before local implementation or delivery claims, blocking missing validation rows, incomplete acceptance traceability evidence, stale runtime/browser/device provenance, unapproved spec-marker substitutions, and orchestrator-owned implementation slices while emitting a TEACH runtime response. |
| `tools/orchestration_plan_completion_guard.py` | python | Validate orchestration execution plans before approval/execution claims, requiring concrete TODO set, acceptance traceability matrix, spec deviation ledger, workstreams, execution ownership ledger, waves, autonomy semantics, topology, and consolidated validation matrix while emitting a TEACH runtime response. |
| `tools/flutter_route_contract_audit.sh` | shell | Scan the generated Flutter router for required non-URL argument signatures that must be classified before delivery. |
| `tools/github_promotion_action_guard.sh` | shell | Emit a TEACH runtime blocker for out-of-scope local promotion actions, direct lane-branch mutation, `bot/next-version` misuse, and forbidden docs promotion based on a local promotion contract. |
| `tools/github_promotion_contract_init.sh` | shell | Create a local promotion contract that makes lane scope and authorization explicit before guarded manual promotion actions. |
| `tools/github_promotion_diff_guard.sh` | shell | Emit a TEACH runtime blocker for gitlinks, unauthorized CI changes, and unauthorized promotion-tooling changes found in a staged/worktree/range diff against a local promotion contract. |
| `tools/github_stage_promotion_preflight.sh` | shell | Deterministically gate promotion source branches against the authoritative base lane and emit a TEACH runtime blocker before the first PR is opened: exit `2` stops the lane, `context` exposes the branch evidence, and `resolution_prompt` tells the operator how to repair the source branch. |
| `tools/github_promotion_completion_guard.sh` | shell | Deterministically validate whether a stage/main promotion lane is truly complete for Docker/Flutter/Laravel scenarios, including required Docker gitlink finalization and optional web follow-through evidence, and emit a TEACH runtime blocker when objective completion evidence is still missing. |
| `tools/github_stage_promotion_snapshot.sh` | shell | Collect a local/remote GitHub PR and check snapshot to support manual stage-promotion decisions. |
| `tools/guarded_git_commit.sh` | shell | Run `git commit` only after the promotion action guard and staged diff guard both pass against a local promotion contract. |
| `tools/guarded_git_push.sh` | shell | Run `git push` only after the promotion action guard and range diff guard both pass, including detection of direct pushes to lane branches. |
| `tools/guarded_pr_create.sh` | shell | Run `gh pr create` only after the promotion action guard and range diff guard both pass against a local promotion contract. |
| `tools/guarded_pr_merge.sh` | shell | Run `gh pr merge` only after the promotion action guard passes against a local promotion contract. |
| `tools/project_setup_normalization_packet.py` | python | Turn a derived project setup report into non-authoritative manual-remediation and normalization-TODO tracks for brownfield recalibration. |
| `tools/project_recalibration_doctor.sh` | shell | Run downstream recalibration automation end-to-end by generating the setup report plus normalization packet and printing the exact next step. |
| `tools/laravel_domain_resolution_test_audit.sh` | shell | Classify Laravel tenant-resolution test files as web-context, mobile-context, mixed-context, or unclassified. |
| `tools/laravel_tenant_access_guardrails_audit.sh` | shell | Scan tenant Laravel route files for `auth:sanctum` without `CheckTenantAccess` and flag guardrail review hints. |
| `tools/profile_scope_check.py` | python | Validate touched surfaces against the active Delphi profile scope rules. |
| `tools/runtime_session_index.py` | python | Generate a derived runtime/session continuity index from active TODOs, blocked fronts, handoff traces, and bounded session-memory carry-over. |
| `tools/runtime_ingress_surface_audit.sh` | shell | Audit Dockerfiles, compose files, ingress/runtime configs, and basic compose readiness before runtime or ingress changes. |
| `tools/rule_event_record.py` | python | Record explicit false positives, escapes, and lifecycle changes into the append-only PACED rule events ledger. |
| `tools/seed_rule_catalog.py` | python | Seed a project-local PACED rule catalog with canonical teaching-rule metadata and lifecycle labels. |
| `tools/subagent_review_dispatch.py` | python | Build a derived no-context subagent dispatch packet for architecture opinions, critique, test-quality audit, or final review. |
| `tools/subagent_review_merge.py` | python | Merge structured no-context subagent review results into a derived summary packet for TODO/gate resolution. |
| `tools/todo_completion_guard.py` | python | Validate close-claim tactical TODOs before delivery is trusted, requiring criterion-specific Completion Evidence Matrix rows for every Definition of Done and Validation Steps item, including item-specific integration/device or navigation/browser evidence for visible, interactive, or user-flow-impacting criteria, source-owned Playwright spec + canonical runner evidence for browser/web-visible criteria when a Playwright suite exists, local non-main mutation evidence for user-flow CRUD/mutation criteria, and explicit non-applicability rationale for structure-only criteria, while emitting a TEACH runtime response. |
| `tools/todo_deterministic_validator.py` | python | Run deterministic structural validation over tactical TODO gate/blocker/waiver fields and emit diagnostic blockers. |
| `tools/todo_validation_bundle_export.py` | python | Export a machine-checkable validation bundle from a tactical TODO markdown file. |
| `tools/todo_validation_rules.py` | python | Canonical PACED rule metadata for deterministic TODO validator issue codes and rule-catalog seeding. |
| `tools/runtime_load_probe.sh` | shell | Run deterministic staged HTTP load/stress probes with objective thresholds for latency, error rate, and throughput. |
| `tools/runtime_load_validation_scaffold.sh` | shell | Generate a markdown scaffold for runtime load/stress/spike/soak validation evidence. |
| `tools/self_check.sh` | shell | Run Delphi self-maintenance validation for instruction baselines and mirrors. |
| `tools/sync_agent_rules.sh` | shell | Sync linked agent-rule surfaces for supported agent bootloaders. |
| `tools/sync_cline_skill_mirrors.sh` | shell | Sync canonical skills into curated Cline-compatible skill mirrors. |
| `tools/sync_codex_public_skill_mirrors.sh` | shell | Sync tracked canonical skills into curated public Codex mirrors under `~/.codex/skills/public`. |
| `tools/sync_clinerules_mirrors.py` | python | Generate curated `.clinerules` mirror content from canonical Delphi rules/workflows. |
| `tools/sync_clinerules_mirrors.sh` | shell | Shell entrypoint for `.clinerules` mirror synchronization. |
| `tools/test_coverage_matrix_scaffold.sh` | shell | Generate a markdown coverage matrix scaffold for the Test Creation Standard workflow. |
| `tools/test_orchestration_status_report.sh` | shell | Generate a required-stage status report and fail closure when any required gate is missing, blocked, failed, flaky, or exception-marked. |
| `tools/test_quality_audit.sh` | shell | Scan selected test paths for bypass markers, weak assertion hints, test-only routes, auth shortcuts, and DI/mock patterns that need review. |
| `tools/lib/promotion_contract.sh` | shell-lib | Load and validate local promotion-contract JSON so deterministic guards share one schema/parser. |
| `tools/lib/teach_runtime.sh` | shell-lib | Emit a consistent TEACH runtime response envelope for deterministic guard tools. |
| `tools/verification_debt_audit.sh` | shell | Audit a target TODO for waiver/blocker/unchecked-item signals and scan selected paths for inline verification debt markers. |
| `tools/verify_adherence_sync.sh` | shell | Verify downstream adherence-sync surfaces after Delphi-managed setup. |
| `tools/verify_context.sh` | shell | Verify Delphi installation/readiness surfaces and optionally repair Delphi-managed links/artifacts. |
