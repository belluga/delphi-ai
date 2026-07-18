---
name: wf-docker-subagent-orchestration-method
description: "Workflow: MUST use whenever the scope matches this purpose: Package, dispatch, and merge no-context internal subagent reviews through derived packets so PACED can orchestrate bounded independent opinions without creating hidden authority."
---

# Method: No-Context Subagent Orchestration

## Purpose
Provide a portable orchestration layer for PACED review subagents using derived dispatch and merge packets.

Required Delphi review gates use fresh internal no-context reviewers only. A dispatched reviewer must not be the implementing agent, and an external provider cannot satisfy the gate.

## Preferred Deterministic Helpers
1. Build the dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py ...`.
2. Run fresh internal Codex reviews with `python3 delphi-ai/tools/subagent_review_run.py ...`; it embeds the bounded packet, records JSONL/stderr, and requires `turn.completed` before a result can be considered collected.
3. If a structured result uses a documented historical alias, normalize it with `python3 delphi-ai/tools/subagent_review_normalize.py ...`; unknown fields/categories/positions must still fail.
4. Merge only canonical-schema-valid reviewer JSON outputs with `python3 delphi-ai/tools/subagent_review_merge.py ...`.

## Procedure
1. Freeze a bounded review package.
   - For cross-stack or producer-surface work, include the TODO's `Frontend / Consumer Matrix` in the package. Producer surfaces include backend endpoints, jobs, settings namespaces, payloads, schemas, projections, capabilities, read models, webhooks, and integration contracts.
   - If the matrix is missing for a triggered package, stop package dispatch and return to TODO preparation. The valid package states are `consumer implemented + evidenced` or `consumer intentionally absent + approved waiver`; reviewers should not be expected to infer absent frontend/admin consumers from a code diff.
   - If the package participates in a multi-TODO orchestration or a pre-promotion review loop, summarize package stage in the orchestration execution plan rather than creating a new version-status file. Package-level stage belongs to the plan; per-finding authority remains in the governing TODOs.
2. Generate the dispatch packet for the chosen review kind.
3. Require reviewer outputs in JSON compatible with `schemas/subagent_review_result.schema.json`; the dispatch must enumerate the canonical top-level allowlist plus position/category enums rather than merely naming the schema.
4. Use the internal runner for Codex gates; missing `turn.completed` is retryable collection failure, not a valid review result.
5. Normalize only documented review-kind-specific historical aliases before strict validation; never repair arbitrary prose or contract violations.
6. Merge the results and fold the authoritative resolution back into the governing TODO/gate.
   - When the review participates in delivery or promotion gates, run `review-finding-classification` before reconciling every deduplicated finding into the governing TODO's `Promotion Finding Routing Ledger` as `release-blocker | follow-up-fast-follow | follow-up-hardening | by-design/no-action`.
   - Real non-blocking findings must be routed to explicit follow-up TODOs before the package can be considered clean.
7. Keep every packet derived and non-authoritative.
