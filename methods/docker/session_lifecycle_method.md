---
description: Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives. This method formalises how sessions start, run, and end.
---

# Method: Session Lifecycle

## Purpose
Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives. This method formalises how sessions start, run, and end.

## Triggers
- A new terminal/IDE session starts (fresh instructions must be loaded).
- The user initiates a “Self Improvement Session”.
- Instructions are edited during the current session (requires session termination afterward).

## Inputs
- Current `delphi-ai/main_instructions.md` and supporting core docs.
- Any updated project-specific docs referenced for the session.

## Procedure
1. **Session Start**
   - Explicitly read the bootloader (`AGENTS.md`) and `delphi-ai/main_instructions.md`.
   - Note the session purpose (architecture vs. self-improvement).
2. **Normal Work Sessions**
   - Follow standard architectural methods (create domain, repository, etc.).
   - If instructions do not change, the session can continue across tasks.
3. **Self Improvement Sessions**
   - Redirect to `methods/generic/self_improvement_session_method.md` and follow that checklist.
4. **Instruction Changes During Normal Session**
   - If any core instruction file is modified, finish that work and then end the session explicitly.
   - Wait for a new session to restart with the updated instructions.
5. **Session Closure**
   - Summarise the work completed.
   - Evaluate whether any friction or rework from the session warrants a new method or an update to an existing one; note the opportunity so it can be addressed next iteration.
   - State “session ended” so the user can run the Post-Session Review / start a fresh context.

## Outputs
- Clear log of session purpose and closure statement.
- Updated instruction files when applicable.

## Validation
- User acknowledgment that the session ended (or a new session start) before continuing work under new instructions.
- No architectural commits occur after instructions change within the same session.
