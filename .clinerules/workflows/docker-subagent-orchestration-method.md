---
name: "docker-subagent-orchestration-method"
description: "Package, dispatch, and merge no-context internal subagent reviews through derived packets so PACED can orchestrate bounded independent opinions without creating hidden authority."
---

<!-- Generated from `workflows/docker/subagent-orchestration-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: No-Context Subagent Orchestration

## Purpose
Provide a portable orchestration layer for PACED review subagents. This method packages bounded review work, standardizes what each subagent must assess, and merges reviewer output back into a derived summary packet.

Required Delphi review gates use fresh internal no-context reviewers only. A dispatched reviewer must not be the implementing agent, and an external provider cannot satisfy the gate.

The packets remain assistive only. Authority still lives in the tactical TODO, the gate decision, and human approval.

## Triggers
- Additional architectural opinions are required because no path is clearly dominant.
- A required critique, test-quality audit, or final review must be delegated to a no-context subagent.
- Multiple bounded reviewers need a consistent merge surface instead of ad hoc prose.

## Inputs
- Bounded review package (`bounded-summary` or `bounded-file-set`).
- Review kind: `architecture_opinion|architecture_adherence|critique|test_quality_audit|final_review`.
- Expected reviewer count.

## Preferred Deterministic Helpers
1. Build the dispatch packet:
   ```bash
   python3 delphi-ai/tools/subagent_review_dispatch.py \
     --review-kind critique \
     --package foundation_documentation/artifacts/tmp/critique-package.md \
     --reviewer-count 1 \
     --todo-path foundation_documentation/todos/active/docker/example.md \
     --json-output foundation_documentation/artifacts/tmp/subagent-critique-dispatch.json \
     --markdown-output foundation_documentation/artifacts/tmp/subagent-critique-dispatch.md
   ```
2. After reviewers return JSON compatible with `schemas/subagent_review_result.schema.json`, merge them:
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
