---
name: docker-session-lifecycle
description: "Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives."
---

# Workflow: Session Lifecycle

## Purpose

Ensure every Delphi session respects instruction-loading rules, especially during Self Improvement Sessions, and that no architectural work proceeds with stale directives.

## Triggers

- A new terminal/IDE session starts (fresh instructions must be loaded)
- The user initiates a "Self Improvement Session"
- Instructions are edited during the current session (requires reload)

## Procedure

### Step 1: Session Start

At the beginning of each session:

1. **Read bootloader and core instructions**
   - Read `CLINE.md` (or `AGENTS.md`)
   - Read `.clinerules/00-main-instructions.md`
   - Load relevant project documentation

2. **Note the session purpose**
   - Architecture work
   - Self-improvement
   - Bug fixes / maintenance

### Step 2: Normal Work Sessions

For standard architectural work:

1. **Follow standard workflows**
   - Use appropriate workflow for the task (create domain, repository, etc.)
   - Apply architecture rules from `.clinerules/`

2. **Session continuity**
   - If instructions do not change, session can continue across tasks
   - If a task requires implementation, apply TODO-driven execution

3. **Task transitions**
   - When switching between major tasks, reload relevant workflows
   - Confirm context with user if scope changes significantly

### Step 3: Self Improvement Sessions

When the user requests a self-improvement session:

1. **Redirect to self-improvement workflow**
   - Load `docker-self-improvement-session` workflow
   - Follow that checklist exclusively

2. **Constraint during self-improvement**
   - Only instruction refinement occurs
   - No implementation work until session ends
   - Must reload updated instructions before architectural work

### Step 4: Instruction Changes During Session

If any core instruction file is modified:

1. **Stop architectural work**
   - Finish current task
   - Do NOT proceed to new architectural tasks

2. **Reload instructions**
   - Re-read updated `.clinerules/` files
   - Confirm new expectations with user
   - Document the instruction change

3. **Optional hard boundary**
   - User may prefer to explicitly end session
   - Resume only after fresh start

### Step 5: Session Closure

When ending a session:

1. **Summarize work completed**
   - List files modified
   - List decisions made
   - Note any pending work

2. **Evaluate friction/rework**
   - Identify any process improvements
   - Note opportunities for method/workflow updates

3. **Run Post-Session Review**
   - Load `docker-post-session-review` workflow
   - Follow the review checklist

4. **Acknowledge closure**
   - State "session ended" after review
   - User can start fresh session when ready

## Session State Tracking

### Session Start Checklist

- [ ] Read bootloader (`CLINE.md`)
- [ ] Read core instructions (`.clinerules/00-main-instructions.md`)
- [ ] Load project-specific documentation
- [ ] Confirm session purpose with user
- [ ] Note any special considerations

### Session End Checklist

- [ ] Summarize work completed
- [ ] List files modified
- [ ] Evaluate process improvements
- [ ] Run post-session review
- [ ] Acknowledge session end

## Outputs

- Clear log of session purpose and closure statement
- Updated instruction files when applicable
- Notes on process improvement opportunities

## Validation

- User acknowledgment that session ended before continuing under updated instructions
- No architectural commits after instructions change within same session
- Explicit reload of updated instructions before resuming work