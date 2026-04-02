---
name: bug-fix-evidence-loop
description: "Diagnose and resolve real bugs with an evidence-first, TDD-oriented workflow that audits coverage from backend payload to final UI rendering."
---

# Bug Fix Evidence Loop

## Purpose
Resolve real production-like bugs by proving the failure path end-to-end, exposing false-green tests, and only then implementing the fix.

## Scope Controls
- This skill does not bypass TODO governance. If project artifacts change, use the active tactical TODO (or eligible ephemeral TODO) and get required approval.
- Prefer TDD sequencing: identify coverage gap -> add failing test(s) -> implement minimal fix -> verify full chain.
- If a bug reproduces in runtime but tests are green, classify as `false-green` and block closure until coverage is corrected.
- When delivery confidence depends materially on new or repaired tests, pair closure with `test-quality-audit`.
- Root cause analysis must also assess whether the failure is a recurring architectural deviation that could be prevented by an analyzer-enforced rule.
- Do not create or change rules autonomously during bug resolution. Only deliver the assessment and, when justified, a candidate rule recommendation for explicit follow-up approval.

## Mandatory Questions (must be answered explicitly)
1. Do we already have tests that cover this behavior across all stages up to UI display?
2. Did we inspect current real database/backend payloads to verify compatibility with current parsing and rendering assumptions?
3. If existing tests should cover this bug, which exact test(s) failed? If none failed, why were they insufficient?
4. If tests do not cover the failure, which new tests must be created before implementing the fix?
5. Is the root cause also an architectural deviation pattern that could be prevented earlier by analyzer-enforced rule coverage? Why or why not?

## Analyzer Rule Heuristic
- Recommend a candidate rule only when the defect pattern is both architecturally invalid and statically recognizable with acceptable false-positive risk.
- Prefer `no-rule-needed` when the bug depends on runtime-only data shape, environment conditions, or one-off contract drift that is not realistically analyzable statically.
- Prefer `rule-candidate` when the root cause is a repeated code-shape violation such as forbidden dependency direction, DTO leakage into presentation/domain, disallowed navigation ownership, build side effects, or other banned structural patterns.
- A rule recommendation must describe the prevented future failure mode, likely detection boundary, and why existing analyzer/rule coverage did not already block it.

## Recommended Enhancements (efficiency + real-resolution bias)
- Add a stage-by-stage coverage matrix (`API -> DTO -> Repository -> Controller -> UI`) and mark each stage `covered|missing|false-green`.
- Capture one real payload sample (sanitized if needed) and validate parser compatibility against that shape before code changes.
- Add at least one negative-path assertion (invalid/partial payload or edge timing state) to prevent regressions that only pass on happy path.
- Require a deterministic reproduction script/steps so the bug can be replayed before and after the fix.
- Separate readiness failures from product failures: environment/harness issues are `blocked`, not proof of fix.

## Workflow
1. **Reproduce deterministically**
   - Document exact reproduction steps and expected vs actual outcome.
   - Capture runtime evidence (logs, payload snippet, UI state screenshot/trace).
2. **Map the failure chain**
   - Trace through layers that influence the symptom:
     - Backend contract/query/filters
     - DTO decode + mapping
     - Repository translation/cache
     - Controller state transitions
     - Widget render conditions
3. **Run the mandatory question gate**
   - Answer all five mandatory questions.
   - Build the coverage matrix and classify each stage.
   - Classify the architecture-prevention assessment as `no-rule-needed` or `rule-candidate`.
4. **Create failing tests first (RED)**
   - Add or update tests exactly where coverage is missing or false-green.
   - Include at least one assertion that fails on current buggy behavior.
5. **Implement minimal fix (GREEN)**
   - Apply smallest change that makes RED tests pass and preserves existing approved behavior.
6. **Cross-layer verification**
   - Run targeted suites for all touched stages.
   - Re-run deterministic repro and confirm runtime symptom is resolved.
7. **Architecture prevention review**
   - Re-evaluate whether the confirmed root cause should be prevented by analyzer-enforced rule coverage in future.
   - If `rule-candidate`, describe the candidate rule only: target layer/scope, prohibited pattern, expected signal, and false-positive risk.
   - Do not implement the rule in this bug-fix cycle unless the user explicitly converts the task into rule work.
8. **Regression hardening**
   - Add/adjust edge-case tests (timing, empty payload, partial payload, filter combinations) when applicable.
9. **Delivery report**
   - Summarize root cause, failing tests added, fix scope, architecture-prevention assessment, and residual risks.

## Required Outputs
- Reproduction record (`before` state).
- Coverage matrix with `covered|missing|false-green` per stage.
- List of tests that failed before fix and passed after fix.
- Root cause statement tied to exact stage(s).
- Architecture prevention assessment: `no-rule-needed` or `rule-candidate`.
- If `rule-candidate`, include why a rule is justified and what the rule should detect or forbid.
- Verification evidence (`after` state) with deterministic replay.

## Done Criteria
- Bug is reproducible before fix and not reproducible after fix.
- At least one previously failing test now passes and directly guards the root cause.
- No unresolved `false-green` stage in the coverage matrix.
- The delivery explicitly states whether analyzer rule prevention is warranted.
- Runtime/manual verification matches automated evidence.
