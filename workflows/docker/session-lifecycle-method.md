---
description: Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives. This method formalises how sessions start, run, and end.
---

# Method: Session Lifecycle

## Purpose
Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives. This method formalises how sessions start, run, and end.

## Triggers
- A new terminal/IDE session starts (fresh instructions must be loaded).
- The user initiates a “Self Improvement Session”.
- Instructions are edited during the current session (requires an explicit reload/transition before continuing normal work).

## Inputs
- Current `delphi-ai/main_instructions.md` and supporting core docs.
- Any updated project-specific docs referenced for the session.

## Procedure
1. **Session Start**
   - Explicitly read the active bootloader (`AGENTS.md` or the agent-specific equivalent such as `CLINE.md`/`GEMINI.md`) and `delphi-ai/main_instructions.md`.
   - Confirm availability/readiness of `foundation_documentation/policies/scope_subscope_governance.md` for route/module/screen scope tasks.
   - Note the session purpose (architecture vs. self-improvement).
2. **Normal Work Sessions**
   - Follow standard architectural workflows (create domain, repository, etc.).
   - For route/module/screen work, require explicit scope-context confirmation (`EnvironmentType`, main scope, subscope) from the canonical policy before implementation.
   - If instructions do not change, the session can continue across tasks.
   - If a task requires implementation, apply the TODO-Driven Execution Method (`workflows/docker/todo-driven-execution-method.md`) before coding.
3. **Self Improvement Sessions**
   - Redirect to `workflows/docker/self-improvement-session-method.md` and follow that checklist.
4. **Instruction Changes During Normal Session**
   - If any core instruction file is modified, finish that work and **do not** proceed to architectural tasks until we explicitly reload the updated instructions.
   - Reload means re-reading the updated `delphi-ai/` files (at minimum `main_instructions.md` plus the edited rule/workflow files) and confirming the new expectations with the user.
   - If the user prefers a hard boundary, explicitly end the session after the instruction edits and resume only after a fresh start.
5. **Session Closure**
   - Summarise the work completed.
   - Evaluate whether any friction or rework from the session warrants a new method or an update to an existing one; note the opportunity so it can be addressed next iteration.
   - If the user signals they are done, run the Post-Session Review Method (`workflows/docker/post-session-review-method.md`) before acknowledging closure.
   - If a hard boundary is desired, state “session ended” after the post-session review.

## Outputs
- Clear log of session purpose and closure statement.
- Updated instruction files when applicable.

## Validation
- User acknowledgment that the session ended before continuing work under updated instructions.
- Do not require a special “new session start” phrase. If continuing in the same conversation after instruction edits, explicitly reload the updated instruction files before resuming work.
- No architectural commits occur after instructions change within the same session.
