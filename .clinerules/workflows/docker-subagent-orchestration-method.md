---
name: "docker-subagent-orchestration-method"
description: "Package, dispatch, and merge no-context subagent reviews through derived packets so PACED can orchestrate bounded external opinions without creating hidden authority."
---

<!-- Generated from `workflows/docker/subagent-orchestration-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: No-Context Subagent Orchestration

## Purpose
Provide a portable orchestration layer for PACED review subagents. This method packages bounded review work, standardizes what each subagent must assess, and merges reviewer output back into a derived summary packet.

The packets remain assistive only. Authority still lives in the tactical TODO, the gate decision, and human approval.

## Triggers
- Additional architectural opinions are required because no path is clearly dominant.
- A required critique, test-quality audit, or final review must be delegated to a no-context subagent.
- Multiple bounded reviewers need a consistent merge surface instead of ad hoc prose.

## Inputs
- Bounded review package (`bounded-summary` or `bounded-file-set`).
- Review kind: `architecture_opinion|critique|test_quality_audit|final_review`.
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
2. **Build dispatch**
   - Generate the dispatch packet and give the markdown form to the orchestration harness or operator.
3. **Collect structured reviewer results**
   - Each reviewer must answer in JSON compatible with `schemas/subagent_review_result.schema.json`.
   - Reject prose-only feedback when deterministic merge is the chosen path.
4. **Merge and interpret**
   - Merge reviewer outputs into a derived summary packet.
   - Record the actual authoritative resolution back in the TODO/gate as `Integrated|Challenged|Deferred with rationale`.
5. **Keep boundaries clear**
   - The dispatch packet, reviewer JSON, and merge packet are all derived artifacts.
   - They never replace the governing TODO or canonical module/project docs.

## Outputs
- `subagent-*-dispatch.{json,md}`
- reviewer result JSON files (produced by the reviewers or harness)
- `subagent-*-merge.{json,md}`

## Validation
- The dispatch packet is bounded and no-context by construction.
- Reviewers are asked the right rubric for the requested review kind.
- Merged output remains derived and is explicitly folded back into authoritative TODO/gate resolution records.
