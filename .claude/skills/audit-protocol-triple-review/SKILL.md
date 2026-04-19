---
name: audit-protocol-triple-review
description: "Run a restartable three-auditor no-context audit loop (Elegance, Performance, Test Quality) with deterministic round state, dispatch packets, result validation, and clean-vs-resolution-vs-adjudication classification."
---

# Triple Audit Protocol (Elegance, Performance, Test Quality)

## Purpose
Provide a repeatable, restartable no-context audit loop with three specialized reviewers. The loop continues until all three lanes are objectively clean or all findings are resolved. Contradictory findings are cross-examined and adjudicated by Delphi; the deterministic support only manages packet/state mechanics.

## When to Use
- The user requests a structured external audit loop with three specialized reviewers.
- A delivery gate requires elegance, performance, and test-quality checks before finalization.

## Required Inputs
- Bounded review package (diffs + summary + key tests) stored under `foundation_documentation/artifacts/`.
- Related TODO path (if applicable).

## Procedure
1. **Freeze a bounded package**
   - Collect only the minimum needed: diff summary, contract changes, tests added/changed, validation results.
   - Store under `foundation_documentation/artifacts/` and mark it as derived/non-authoritative.
2. **Initialize a deterministic audit session**
   - Run:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py start \
       --package <bounded_package_path> \
       [--todo <todo_path>] \
       [--run-root <explicit_run_root>]
     ```
   - The runner creates session state, dispatch packets, expected result paths, and a progress markdown file.
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
   - If the round is `needs_resolution`, resolve findings in code/docs/tests and prepare another round:
     ```bash
     python3 delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py next-round \
       --session <session_json_path>
     ```
   - If the round is `needs_adjudication`, summarize the contradiction, run the follow-up no-context challenge manually, and record Delphi’s adjudication before opening the next round.
7. **Close**
   - Record the final clean round in the governing TODO or delivery gate evidence.
   - Treat zero findings across all three lanes as the objective clean condition.

## Deterministic Support
- Session runner:
  - `delphi-ai/skills/audit-protocol-triple-review/scripts/triple_audit_session.py`
- Existing packet tools used by the session runner:
  - `delphi-ai/tools/subagent_review_dispatch.py`
  - `delphi-ai/tools/subagent_review_merge.py`

## Notes
- The deterministic support is for session state, packet generation, result validation, and merge classification only.
- Delphi still owns package bounding, contradiction adjudication, and whether a finding is truly resolved.
- If WSL, remote shells, or long sessions are unstable, resume from the stored `session.json` instead of reconstructing the audit round in-chat.

## Output
- Session state + progress markdown.
- Validated reviewer results and per-lane merge packets.
- Round summary with clean-vs-resolution-vs-adjudication status.
- Recorded resolution decisions and a clean audit gate in the TODO/delivery notes.
