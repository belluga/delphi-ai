---
name: "docker-subagent-orchestration-method"
description: "Package, dispatch, and merge no-context internal subagent reviews through derived packets so PACED can orchestrate bounded independent opinions without creating hidden authority."
---

<!-- Generated from `workflows/docker/subagent-orchestration-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: No-Context Subagent Orchestration

## Purpose
Provide a portable orchestration layer for PACED subagents. It supports bounded no-context reviews and executor delegation on the principal checkout without creating hidden authority or implicitly selecting Git-isolation topology.

Required Delphi review gates use fresh internal no-context reviewers only. A dispatched reviewer must not be the implementing agent, and an external provider cannot satisfy the gate.

The packets remain assistive only. Authority still lives in the tactical TODO, the gate decision, and human approval.

## Git Topology Authorization Boundary
- Subagent, delegation, and parallelism authorization is independent from worktree/auxiliary-checkout authorization.
- Default executor topology is `primary-checkout-single-writer`: all edits occur in the principal checkout, only one agent writes at a time, additional writers are serialized, and parallel readers/reviewers must not edit.
- Do not create `git worktree`, auxiliary checkouts, `worker/*`, `reconcile/*`, or writable repository copies without separate human authorization that explicitly mentions worktrees or auxiliary checkouts.
- If simultaneous writers need isolation, stop and request that specific authorization. Only then load `subagent-worktree-reconciliation-method.md`.
- Authoritative Docker, browser, device, and CI-Equivalent validation always targets the consolidated principal-checkout state.

## Triggers
- Additional architectural opinions are required because no path is clearly dominant.
- A required critique, test-quality audit, or final review must be delegated to a no-context subagent.
- Multiple bounded reviewers need a consistent merge surface instead of ad hoc prose.
- One or more executor subagents are authorized to work serially in the principal checkout.

## Inputs
- Bounded review package (`bounded-summary` or `bounded-file-set`).
- Review kind: `architecture_opinion|architecture_adherence|critique|test_quality_audit|final_review`.
- Expected reviewer count.

## Reviewer Lifecycle Wait Invariant
- Reviewer lifecycle status, not elapsed wall-clock time, is authoritative.
- While a dispatched reviewer reports `pending_init` or `running`, keep waiting without a rigid time limit. A client-side `wait`/poll timeout means only that no terminal event arrived during that polling window; it is not reviewer failure, reviewer breakage, or permission to change the review plan.
- Never interrupt, close, recycle, replace, or spawn a duplicate for a `pending_init` or `running` reviewer merely because it is slow. Never reduce, tighten, or otherwise alter the bounded package as a response to elapsed time.
- A retry or replacement is allowed only after objective terminal evidence such as `errored`, unexpected `shutdown`/`interrupted`, a runner process that exited unsuccessfully, or a completed stream that fails the deterministic collection contract. Explicit human cancellation may also end a run.
- After terminal failure, retry the same complete gate-satisfying package by default. Change the package only to correct a concrete package defect proven by the failure, and preserve every required rubric, file, evidence item, and scope boundary; package reduction is not a generic recovery strategy.
- If no reviewer slot is available, recycle only a completed, errored, shutdown, or otherwise terminal inactive lane. A live reviewer is not a recyclable slot.

## Preferred Deterministic Helpers
1. Build the dispatch packet:
   ```bash
   python3 delphi-ai/tools/subagent_review_dispatch.py \
     --review-kind critique \
     --lifecycle planning \
     --package foundation_documentation/artifacts/tmp/critique-package.md \
     --reviewer-count 1 \
     --todo-path foundation_documentation/todos/active/docker/example.md \
     --json-output foundation_documentation/artifacts/tmp/subagent-critique-dispatch.json \
     --markdown-output foundation_documentation/artifacts/tmp/subagent-critique-dispatch.md
   ```
   Use `--lifecycle delivery` when the bounded critique is reviewing an implemented/delivery package. Critique dispatch fails closed when lifecycle is omitted.
2. Run the fresh internal reviewer through the canonical runner. It embeds the bounded package in a closed stdin prompt, records JSONL/stderr, requires `turn.completed`, and falls back to the final streamed message only when `--output-last-message` is absent:
   ```bash
   python3 delphi-ai/tools/subagent_review_run.py \
     --model gpt-5.6-sol \
     --dispatch foundation_documentation/artifacts/tmp/subagent-critique-dispatch.md \
     --package foundation_documentation/artifacts/tmp/critique-package.md \
     --raw-output foundation_documentation/artifacts/tmp/reviewer-a.raw.json \
     --events-output foundation_documentation/artifacts/tmp/reviewer-a.events.jsonl \
     --stderr-output foundation_documentation/artifacts/tmp/reviewer-a.stderr.log \
     --workdir "$PWD"
   ```
   - When an embedded bounded package is fully self-contained and the project context prevents a fresh reviewer from reaching `turn.completed` (for example, skill-context exhaustion), add `--isolate-project-context`. This starts the reviewer in `/tmp` with user config and project rules disabled, while retaining the closed stdin package. Do not use it for a reviewer that must inspect repository files beyond that package.
3. When a reviewer uses a documented historical category alias, normalize it before validation; the normalizer is not a permissive parser and rejects every unlisted field/value:
   ```bash
   python3 delphi-ai/tools/subagent_review_normalize.py \
     --input foundation_documentation/artifacts/tmp/reviewer-a.raw.json \
     --output foundation_documentation/artifacts/tmp/reviewer-a.normalized.json
   ```
4. Merge the canonical or normalized reviewer JSON only after strict schema validation:
   ```bash
   python3 delphi-ai/tools/subagent_review_merge.py \
     --dispatch foundation_documentation/artifacts/tmp/subagent-critique-dispatch.json \
     --review foundation_documentation/artifacts/tmp/reviewer-a.json \
     --json-output foundation_documentation/artifacts/tmp/subagent-critique-merge.json \
     --markdown-output foundation_documentation/artifacts/tmp/subagent-critique-merge.md
   ```

## Procedure
1. **Bound the review package**
   - Freeze the files/summary the reviewer may use.
   - Do not leak thread context into the subagent request.
   - For cross-stack or producer-surface work, include the TODO's `Frontend / Consumer Matrix` in the package. Producer surfaces include backend endpoints, jobs, settings namespaces, payloads, schemas, projections, capabilities, read models, webhooks, and integration contracts.
   - If that matrix is triggered but missing, stop dispatch and return to TODO preparation. The review package must make one of these states explicit for every producer surface: `consumer implemented + evidenced` or `consumer intentionally absent + approved waiver`.
   - Ask reviewers to flag any backend/settings/payload/projection/capability producer whose declared frontend/admin/operator consumer is missing, untested, or replaced by backend-only evidence.
2. **Build dispatch**
   - Generate the dispatch packet and give the markdown form to the orchestration harness or operator.
3. **Collect structured reviewer results**
   - Each reviewer must answer in JSON compatible with `schemas/subagent_review_result.schema.json`.
   - The dispatch markdown must enumerate the canonical top-level field allowlist, position enum, and finding-category enum from that schema; do not rely on a vague compatibility instruction.
   - Use `subagent_review_run.py` for internal Codex gates. It must receive the dispatch and bounded package as files, embed both in the initial closed stdin prompt, and record the raw result, JSONL stream, and stderr. Only after the runner/stream terminates may a missing `turn.completed`, or both a missing output-last-message and final streamed agent message, be classified as retryable collection failure. While the reviewer is still `pending_init` or `running`, continue waiting under the Reviewer Lifecycle Wait Invariant.
   - If an otherwise structured result uses a documented historical alias, run `subagent_review_normalize.py` and merge only its schema-valid derived output. The normalizer must remain review-kind-specific and closed: it must never repair prose, unknown fields, unknown categories, or invalid position values.
   - When the dispatch packet records `review_result_dispatch_path`, the reviewer result's `dispatch_path` must equal that exact JSON dispatch path. It must never point to the bounded package, governing TODO, or reviewer-output file; merge rejects those substitutions.
   - Reject prose-only feedback when deterministic merge is the chosen path.
4. **Merge and interpret**
   - Merge reviewer outputs into a derived summary packet.
   - Record the actual authoritative resolution back in the TODO/gate as `Integrated|Challenged|Deferred` plus usefulness/formalizable classification using the machine-checkable resolution table from the tactical TODO template.
   - When the review feeds delivery, promotion, or no-context release scrutiny, run `review-finding-classification` and then reconcile each deduplicated finding into the governing TODO's `Promotion Finding Routing Ledger` with one of: `release-blocker`, `follow-up-fast-follow`, `follow-up-hardening`, or `by-design/no-action`.
   - Non-blocking real findings are not disposable. Before the delivery claim can be called clean, route them to an explicit follow-up TODO and record that path in the governing TODO.
   - If you want a ready-to-paste table, render it from the merge packet:
     ```bash
     python3 delphi-ai/tools/gate_finding_resolution_scaffold.py \
       --merge foundation_documentation/artifacts/tmp/subagent-critique-merge.json
     ```
   - After the TODO table is filled, derive the machine-checkable packet:
     ```bash
     python3 delphi-ai/tools/gate_finding_resolution_extract.py \
       --todo foundation_documentation/todos/active/docker/example.md \
       --review-kind critique \
       --output foundation_documentation/artifacts/tmp/example-critique-resolution.json
     ```
5. **Keep boundaries clear**
   - The dispatch packet, reviewer JSON, and merge packet are all derived artifacts.
   - They never replace the governing TODO or canonical module/project docs.

## Outputs
- `subagent-*-dispatch.{json,md}`
- reviewer result JSON files (produced by the reviewers or harness)
- `subagent-*-merge.{json,md}`
- derived `*-resolution.json` packets extracted from the authoritative TODO when finding metrics are needed

## Validation
- The dispatch packet is bounded and no-context by construction.
- Reviewers are asked the right rubric for the requested review kind.
- Merged output remains derived and is explicitly folded back into authoritative TODO/gate resolution records.
