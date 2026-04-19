---
name: wf-docker-subagent-orchestration-method
description: "Workflow: MUST use whenever the scope matches this purpose: Package, dispatch, and merge no-context subagent reviews through derived packets so PACED can orchestrate bounded external opinions without creating hidden authority."
---

# Method: No-Context Subagent Orchestration

## Purpose
Provide a portable orchestration layer for PACED review subagents using derived dispatch and merge packets.

## Preferred Deterministic Helpers
1. Build the dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py ...`.
2. Merge reviewer JSON outputs with `python3 delphi-ai/tools/subagent_review_merge.py ...`.

## Procedure
1. Freeze a bounded review package.
2. Generate the dispatch packet for the chosen review kind.
3. Require reviewer outputs in JSON compatible with `schemas/subagent_review_result.schema.json`.
4. Merge the results and fold the authoritative resolution back into the governing TODO/gate.
5. Keep every packet derived and non-authoritative.
