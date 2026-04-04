---
name: frontend-race-condition-validation
description: "Validate Flutter/Web async UI paths against rapid repeat actions, duplicate submits, out-of-order responses, and navigation/dispose races before delivery."
---

# Frontend Race Condition Validation

## Purpose
Prove that async UI flows remain correct when the user taps repeatedly, changes filters rapidly, retries while work is already in flight, or leaves the screen before async work completes.

## Scope Controls
- This skill validates concurrency/race behavior; it does not replace TODO governance or test creation strategy.
- Use it for Flutter/Web UI flows with async buttons, refresh/search/filter flows, optimistic updates, pagination, or navigation that depends on async work.
- Pair with `test-creation-standard` when new tests must be added.
- Pair with `bug-fix-evidence-loop` when the race condition is already causing a user-visible bug.

## Preferred Deterministic Helpers
- Use `bash delphi-ai/tools/frontend_race_probe.sh --scenario <id> --runner "<command>" [--burst-level <n>] [--burst-level <n> ...] [--repetitions <n>] [--timeout-sec <n>] [--workdir <path>] [--env KEY=VALUE] [--output-dir <dir>]` to run real repeated-trigger probes against a stack-native test runner.
- The runner should consume `DELPHI_RACE_SCENARIO`, `DELPHI_RACE_BURST_LEVEL`, `DELPHI_RACE_REPEAT_INDEX`, `DELPHI_RACE_ATTEMPT_DIR`, and `DELPHI_RACE_OUTPUT_DIR`.
- Use `bash delphi-ai/tools/frontend_race_validation_scaffold.sh --surface "<surface>" [--surface "..."] [--output <path>]` when the matrix itself still needs to be written before execution starts.
- Deterministic depth: already-backed for burst/repetition orchestration. The skill still owns scenario design, guard policy, and interpretation of business-safety outcomes.

## Race Scenarios That Must Be Considered
- double tap / rapid repeated press on async CTA
- submit while loading is already active
- retry while the first request is still in flight
- rapid filter/search/sort/pagination changes
- out-of-order responses where an older response arrives after a newer one
- navigation/dispose while async work is pending
- duplicated snackbars/dialogs/navigation intents
- optimistic updates that must reconcile or roll back safely

## Workflow
1. **Frame the async surface**
   - List the buttons, gestures, lifecycle hooks, and controller methods that can overlap in time.
2. **Build the race matrix**
   - For each surface, record trigger, failure mode, expected guard, and evidence path.
3. **Freeze burst levels**
   - Default to `5`, `10`, and `20` repeated triggers for material async surfaces.
   - If a different burst profile is more appropriate, record why.
4. **Define the expected concurrency policy**
   - Classify each async action as one of:
     - `drop duplicate`
     - `serialize`
     - `cancel previous`
     - `last-write-wins`
     - `idempotent server-side`
   - If the policy is unclear, block closure until it becomes explicit.
5. **Run real repeated-trigger probes**
   - Prefer stack-native widget/integration/browser/device tests invoked through `frontend_race_probe.sh`.
   - If automation is not yet available, capture deterministic manual replay evidence and treat the missing runner as residual risk.
6. **Validate stale-response handling**
   - Confirm older responses cannot overwrite newer state unless that is the explicit policy.
7. **Validate lifecycle safety**
   - Confirm dispose/navigation does not produce post-dispose state writes, duplicate navigation, or unsafe UI effects.
8. **Validate duplicate side-effect safety**
   - Confirm duplicate submit paths cannot create duplicate purchases, saves, reservations, or other irreversible effects without explicit idempotency/guard strategy.
9. **Evidence**
   - Prefer runner output produced through `frontend_race_probe.sh`.
   - Otherwise capture deterministic manual replay steps and runtime evidence.
10. **Issue cards for material findings**
   - Record issue, evidence, failure mode, expected guard, and recommended fix.

## Required Outputs
- Race-condition scenario matrix by surface.
- Burst levels and repetition counts executed.
- Explicit concurrency policy for each material async action.
- Evidence showing duplicate/stale/dispose cases are safe or still risky.
- Residual concurrency risk statement.

## Done Criteria
- No material async trigger remains without an explicit concurrency policy.
- No duplicate-submit or stale-response path remains implicitly acceptable.
- Navigation/dispose races are either safe or explicitly blocked from closure.
- Evidence exists for the highest-risk race scenarios in scope, ideally via real `5|10|20` burst probes.
