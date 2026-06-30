---
name: "docker-todo-driven-execution-method"
description: "Execute work through a tactical TODO by routing each state to the correct phase workflow, preserving approval and delivery gates."
---

<!-- Generated from `workflows/docker/todo-driven-execution-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: TODO-Driven Execution

## Purpose
Use this workflow as the TODO-driven **orchestrator**. It owns the state machine, phase order, and non-negotiable gates. Phase-specific instructions live in supporting workflows so the active context stays small and the model loads only the current phase details.

## Phase Workflows
| Phase | Use When | Supporting Workflow |
| --- | --- | --- |
| Lane and framing | The work is not yet classified as micro-fix, ephemeral TODO, profile-scoped ledger, feature brief, or tactical TODO. | `workflows/docker/todo-lane-framing-method.md` |
| Contract refinement | A tactical TODO exists or will be made executable, but scope, decisions, anchors, matrices, or complexity need refinement. | `workflows/docker/todo-contract-refinement-method.md` |
| Approval gates | The TODO is refined enough to seek plan review, optional bounded pre-approval RED evidence capture, audit-floor decisions, critique, and explicit `APROVADO`. | `workflows/docker/todo-approval-gates-method.md` |
| Execution boundary | `APROVADO` exists and implementation is about to start or is underway. | `workflows/docker/todo-execution-boundary-method.md` |
| Delivery gates | Implementation is complete enough for a local delivery claim, promotion readiness, or close-claim evidence. | `workflows/docker/todo-delivery-gates-method.md` |
| Closeout and promotion | Stable outcomes need canonicalization, promotion-lane movement, completion, or blocked-state handling. | `workflows/docker/todo-closeout-promotion-method.md` |

## Required State Machine
1. **Classify lane** with `todo-lane-framing-method`.
2. **Refine contract** with `todo-contract-refinement-method`.
3. **Freeze baseline and approval gates** with `todo-approval-gates-method`.
4. **Wait for explicit `APROVADO`** before implementation.
5. **Execute within approved boundary** with `todo-execution-boundary-method`.
6. **Complete delivery gates** with `todo-delivery-gates-method`.
7. **Close or promote** with `todo-closeout-promotion-method`.

Do not skip ahead because a later phase feels obvious. A phase may be recorded as `n/a` only when the supporting workflow allows it and the TODO records the rationale.

## Non-Negotiable Gates Visible At The Umbrella
- **No implementation before `APROVADO`** for tactical and ephemeral TODO lanes.
- **Pre-APROVADO RED Evidence Capture**, when used, is a bounded test-only evidence lane rather than implementation:
  - it applies only to maintenance/regression or tactical bugfix TODOs;
  - it may touch only tests and strictly test-only support surfaces recorded in the TODO;
  - it must never touch production code, runtime/config/deploy surfaces, or canonical project docs outside TODO authoring;
  - it must record `red_reproduced|red_not_reproduced|blocked` and send the TODO back through reconvergence if the evidence invalidates the current path.
- **Decision Baseline (Frozen)** must exist before implementation and must be refreshed with renewed approval if approval-material facts change.
- **Review Baseline Freeze** must be committed and pushed before the first planning-side review or guard run, and its branch/commit/push evidence must be recorded in `Gate: Review Baseline Freeze`.
- **Post-review scope drift** must be checked before `APROVADO`:
  - `python3 delphi-ai/tools/review_scope_drift_guard.py <todo-path>`
  - if the guard reports material drift in scope-governing sections, return the TODO to the review loop, revalidate the evolved scope with the user, and refresh the pushed baseline as required before approval resumes.
- **Approval and rule-ingestion evidence** must be recorded in the TODO after `APROVADO` and before implementation:
  - `python3 delphi-ai/tools/todo_authority_guard.py <todo-path>`
- **Complexity policy (`small|medium|big`)** must be recorded during contract refinement.
- **Plan Review Gate** must run according to the recorded complexity and risk.
- **Devil's-Advocate alias mapping** is canonical at the TODO-driven umbrella:
  - when the user, TODO, or an external reference asks for a `devil's advocate` critique/review/loop, treat the canonical planning-side equivalent as `wf-docker-independent-critique-method`;
  - when that request also expects a persistent objection/finding ledger, evidence-based reopening, or repeated no-context rounds until no blocking objection remains, layer `audit-protocol-triple-review` on top;
  - `audit-protocol-triple-review` is additive and does not silently replace the required planning-side independent critique gate.
- **Completion Evidence Matrix** must contain criterion-specific evidence for every `Definition of Done` and `Validation Steps` item before delivery claims.
- **Local CI-Equivalent Suite Matrix** must list and pass every in-scope repo-owned CI suite/job for the touched slice, or carry an approved `n/a`/waiver.
- **Behavior-targeted CI validity** is mandatory: every CI-equivalent row must declare the exact scenario it proves plus the required fixture/seed/runtime preconditions, and a green suite is invalid when the intended behavior was never actually exercised.
- **Decision Adherence** must be validated before delivery.
- **Pipeline/Copilot P1/P2 Preflight** must be completed before delivery claims; unresolved `P1|P2` blocks delivery.
- **Review Finding Classification** must run after Copilot/audit/reviewer findings are collected and deduplicated. Use `review-finding-classification`. Reviewers keep their normal detection behavior; blocking vs follow-up is decided in a separate triage step recorded in the governing TODO's `Promotion Finding Routing Ledger`. Every finding must be classified as `release-blocker`, `follow-up-fast-follow`, `follow-up-hardening`, or `by-design/no-action`. Only findings classified as `release-blocker` may block the current delivery/promotion claim. Findings classified as `follow-up-fast-follow` or `follow-up-hardening` must be split into explicit post-version TODOs under an approved active lane root, and the governing TODO must record the exact follow-up path/reference before the delivery claim is clean.
- **Rule-Spirit Anti-Pattern Hunt** must be completed before delivery claims; unresolved `P1|P2` blocks delivery.
- **Final Deterministic Guards** must return `Overall outcome: go`:
  - `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates`
  - `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`
- **Closeout Disposition** must be explicit before pausing after a delivery claim:
  - `python3 delphi-ai/tools/todo_closeout_guard.py <todo-path>`
- **Same governing TODO** stays authoritative through local implementation and `promotion_lane/`; do not create a new tactical TODO solely for operational promotion follow-through.

## Inputs
- Active user request and repository context.
- Active TODO under `foundation_documentation/todos/active/`, or a decision to create one.
- Feature brief under `foundation_documentation/artifacts/feature-briefs/` when framing is required.
- Relevant project `foundation_documentation`, module docs, dependency-readiness/topology artifacts, and touched-surface workflows.

## Outputs
- One governing TODO with clear lane, scope, decisions, plan, approval, execution notes, delivery evidence, and closeout status.
- One explicit `Active Work State` whenever the governing TODO still lives under `foundation_documentation/todos/active/`.
- Supporting feature brief only when needed.
- Canonical module/doc updates when stable truth changed.
- When package-level orchestration or pre-promotion review loops are in scope, the authoritative package-stage ledger lives in the orchestration execution plan, not in a parallel version-status file. Per-finding dispositions remain authoritative in the governing TODOs.

## Validation
- The TODO records which phase workflow governed each major transition.
- Any TODO that remains in `active/` records `Active Work State = implementation|review|blocked` plus an exact exit condition.
- No phase-specific requirements are left only in chat.
- Delivery claims are blocked unless `todo_authority_guard.py --require-delivery-gates` and `todo_completion_guard.py` both return `Overall outcome: go`.
- Closeout is blocked unless delivered active TODOs have a valid `TODO Closeout Disposition` and `todo_closeout_guard.py` returns `Overall outcome: go`.
- Any waived or `n/a` gate has explicit rationale and approval evidence where required.
