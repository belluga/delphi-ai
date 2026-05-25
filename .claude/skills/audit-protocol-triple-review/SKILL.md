---
name: audit-protocol-triple-review
description: "Run a restartable three-auditor no-context audit loop (Elegance, Performance, Test Quality) with deterministic round state, dispatch packets, result validation, and clean-vs-resolution-vs-adjudication classification."
---

# Triple Audit Protocol (Elegance, Performance, Test Quality)

## Purpose
Provide a repeatable, restartable no-context audit loop with three specialized reviewers. The loop is a release gate for blocking risk, not an endless search for every possible improvement. It continues until all blocking findings are resolved or remaining findings are explicitly accepted as non-blocking debt. Contradictory findings are cross-examined and adjudicated by Delphi; the deterministic support only manages packet/state mechanics.

## When to Use
- The user requests a structured external audit loop with three specialized reviewers.
- A delivery gate requires elegance, performance, and test-quality checks before finalization.
- In a multi-TODO orchestration run: trigger one independent audit per TODO delivery. Complete the current audit (reach `clean` or record `accepted-debt`) before advancing to the next TODO in the sequence.

## Orchestration Cadence
When this skill is invoked as part of a multi-TODO orchestration run:
- Each TODO's delivery is a fully independent audit scope with its own bounded package.
- The orchestrator must not advance to the next TODO until the current audit reaches `clean` or all findings are recorded as `accepted-debt`.
- Do not consolidate multiple TODO deliveries into a single audit package. Consolidation before the first audit creates wide code-path loops, making each round larger and harder to close.
- Track the open audit session in the TODO's delivery notes so the orchestrator can resume from `session.json` without re-reading the full diff across sessions.

## Required Inputs
- Bounded review package (diffs + summary + key tests) stored under `foundation_documentation/artifacts/`.
- `Frontend / Consumer Matrix` when the TODO creates or changes producer surfaces such as backend endpoints, jobs, settings namespaces, payloads, schemas, projections, capabilities, read models, webhooks, or integration contracts that could feed app/web/admin/operator behavior.
- Related TODO path (if applicable).

## Gate Calibration
- The close condition is **no unresolved blocking finding**, not zero findings.
- Delphi must classify every finding as one of:
  - `blocking`: must be fixed before promotion or next gate closure.
  - `accepted-debt`: valid but non-blocking; record rationale, owner/surface, and next action.
  - `out-of-scope`: useful observation outside the frozen package/gate; do not let it expand the current round.
- Do not treat marginal improvements as release blockers. A reviewer may report them, but Delphi must not keep opening rounds for them unless they expose a concrete release risk.
- For follow-up rounds after fixes, prefer delta-only audit packages. Re-auditing the full diff is valid only when the fix materially changed architecture, data flow, performance-critical access paths, or test coverage.

## Lane-Specific Blocking Criteria
- **Performance blockers:** concrete server/runtime risk, including unbounded scans, fetch-all reconciliation, N+1 or request-loop behavior where a single query/endpoint is required, exact lookup through page walking/list filtering, high-cardinality in-memory filtering, scheduler/job queries that scale over all data without bounded criteria, cache or hydration logic that can amplify backend load, or security-sensitive resource exhaustion. Marginal micro-optimizations, cosmetic component decomposition, and speculative scaling concerns without a plausible severe impact are non-blocking debt at most.
- **Elegance blockers:** structural remnants that contradict the implemented canonical direction and create real drift, duplicate old/new paths likely to diverge, package-first violations in the changed surface, decentralized mutation or query logic that bypasses the canonical domain/service path, or architecture changes that also carry correctness/performance/security risk. Pure preference refactors, naming polish, smaller decoupling opportunities, and architectural beautification without behavior/performance/security impact are non-blocking debt.
- **Test-quality blockers:** missing or invalid evidence for final user-visible behavior, CRUD/mutation flows, backend contract semantics, required navigation/integration gates, real-backend coverage where required, CI gates that cannot run, mocks/fallbacks that hide production behavior, or assertions that cannot catch the targeted regression. Test organization or readability suggestions are non-blocking when required behavior coverage is already valid.
- **Consumer-surface blockers:** producer surfaces delivered with only backend evidence when a frontend/admin/operator/integration consumer is required; missing `Frontend / Consumer Matrix` for a triggered package; or a matrix row that claims no consumer without an explicit approved backend-only/internal-only/external-only waiver.

## Procedure
1. **Freeze a bounded package**
   - Collect only the minimum needed: diff summary, contract changes, tests added/changed, validation results.
   - Include the `Frontend / Consumer Matrix` whenever producer surfaces are in scope. The package must make every producer row explicit as either `consumer implemented + evidenced` or `consumer intentionally absent + approved waiver`.
   - If a triggered package lacks the matrix, stop before opening the audit session and update the TODO/package. Do not rely on no-context reviewers to discover frontend/admin omissions from unrelated backend diffs.
   - Store under `foundation_documentation/artifacts/` and mark it as derived/non-authoritative.
   - For round 02+, include the prior round's recorded resolution/adjudication artifact in the package. This is the guard against audit loops where a later reviewer re-raises a finding that was already resolved, blocked, or explicitly accepted as debt.
2. **Initialize a deterministic audit session**
   - Run:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py start \
       --package <bounded_package_path> \
       [--todo <todo_path>] \
       [--run-root <explicit_run_root>]
     ```
   - The runner creates session state, dispatch packets, expected result paths, and a progress markdown file.
   - The runner generates an effective `round-package.md` for each round. That package includes the current bounded package plus prior recorded `resolution.md` artifacts, so no-context reviewers receive prior decisions without relying on chat memory.
3. **Spawn three no-context reviewers**
   - Use the generated round dispatch markdown files only:
     - `dispatch/elegance.dispatch.md`
     - `dispatch/performance.dispatch.md`
     - `dispatch/test-quality.dispatch.md`
   - One reviewer per lane, with no extra context.
   - Ask each reviewer to return JSON compatible with `schemas/subagent_review_result.schema.json`.
4. **Record reviewer results deterministically**
   - Save each returned JSON to a temp file, then validate/copy it into the session with:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py record-result \
       --session <session_json_path> \
       --lane <elegance|performance|test-quality> \
       --input <review_result_json>
     ```
5. **Merge and classify the round**
   - Run:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py merge \
       --session <session_json_path>
     ```
   - The runner produces lane merges plus a round summary and classifies the round as:
     - `clean`: all three result files are present and all three lanes have zero findings.
     - `needs_resolution`: findings exist but no clear contradiction packet is required.
     - `needs_adjudication`: reviewer outputs conflict materially and Delphi must cross-examine/adjudicate.
6. **Resolve findings**
   - If the round is `needs_resolution`, resolve findings in code/docs/tests, then create/fill a resolution artifact:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py resolution-template \
       --session <session_json_path>
     ```
   - Record the completed resolution before opening another round:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py record-resolution \
       --session <session_json_path> \
       --status <resolved|accepted-debt|blocked> \
       --input <filled_resolution_markdown>
     ```
   - If the round is `needs_adjudication`, summarize the contradiction, run the follow-up no-context challenge manually if needed, and record Delphi's adjudication in the resolution artifact.
   - `next-round` is intentionally blocked until the current non-clean round has a recorded resolution with status `resolved` or `accepted-debt`.
   - If the resolution status is `blocked`, do not open a new audit round. Fix the blocker or explicitly accept the remaining risk as debt first.
   - If all remaining findings are non-blocking under the gate calibration, record `accepted-debt` instead of implementing marginal refactors to chase zero findings.
7. **Prepare the next round**
   - Update the bounded package with:
     - the current diff/evidence state;
     - the recorded resolution/adjudication artifact for the prior round;
     - accepted-debt decisions, if any;
     - open blockers, if any.
   - Then run:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py next-round \
       --session <session_json_path> \
       [--package <refreshed_bounded_package_path>]
     ```
   - Use `--package` when the diff/evidence package has been refreshed after fixes. The runner still wraps it in the generated effective round package with prior decisions.
   - Never open a new no-context round using a stale manually assembled package that omits the prior round decisions; the generated `round-package.md` is the dispatch source of truth.
8. **Close**
   - Record the final clean round in the governing TODO or delivery gate evidence.
   - Treat either zero findings or zero unresolved blocking findings with recorded accepted debt as the objective clean condition.

## Deterministic Support
- Session runner:
  - `delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py`
- Existing packet tools used by the session runner:
  - `delphi-ai/tools/subagent_review_dispatch.py`
  - `delphi-ai/tools/subagent_review_merge.py`

## Notes
- The deterministic support is for session state, packet generation, result validation, and merge classification only.
- Delphi still owns package bounding, contradiction adjudication, and whether a finding is truly resolved.
- A non-clean round without a recorded `resolution.md` is incomplete. Do not treat it as ready for the next audit round.
- A `blocked` resolution is a stop sign, not a degraded pass.
- `accepted-debt` is allowed only when the remaining issue is explicitly non-blocking with rationale, owner, and next action; it must be included in the next package so auditors do not treat it as accidental omission.
- New findings that are valid but non-blocking should be consolidated as debt/backlog, not used to extend the audit loop indefinitely.
- If WSL, remote shells, or long sessions are unstable, resume from the stored `session.json` instead of reconstructing the audit round in-chat.

## Output
- Session state + progress markdown.
- Validated reviewer results and per-lane merge packets.
- Round summary with clean-vs-resolution-vs-adjudication status.
- Recorded resolution decisions and a clean audit gate in the TODO/delivery notes.
