---
name: docker-self-improvement-session
description: "Run instruction-only sessions safely, ensuring delphi-ai/ stays project-agnostic and no architectural work proceeds under stale directives."
---

# Workflow: Self Improvement Session

## Purpose

Run instruction-only sessions safely, ensuring `delphi-ai/` stays project-agnostic and no architectural work proceeds under stale directives.

## Triggers

- User initiates a "Self Improvement Session"
- Delphi instructions (`delphi-ai/*.md` or `.clinerules/`) require updates/refactors

## Prerequisites

- [ ] Current core files accessible (main instructions, system principles, ecosystem config, templates)
- [ ] Manual agnosticism review available
- [ ] Applicable local checks identified for the touched file types

## Procedure

### Step 1: Persona Selection

Run the Persona Selection Method; typically CTO/Tech Lead persona for instruction work.

### Step 2: Freeze Architectural Work

**CRITICAL:** Acknowledge that implementation work is paused:
- No project code changes
- No submodule code changes
- No project-specific documentation changes

This session is for:
- Discussion about instruction improvements
- Instruction refinement within `delphi-ai/` and `.clinerules/`

### Step 3: Plan Updates

List the instruction files to edit:
- What files need to change?
- What is the rationale for each change?
- Are there dependencies between changes?

Document the plan before making changes.

### Step 4: Apply Changes

Edit instruction files as required:
- `.clinerules/*.md`
- `.cline/skills/*.md`
- `.clinerules/workflows/*.md`
- Templates and configuration

### Step 5: Agnosticism & Consistency Verification

**Manual checks:**
1. No project-specific paths/data in `delphi-ai/` or `.cline/`
2. Cross-check updated files against `system_architecture_principles.md`
3. Verify template expectations are met
4. Confirm instructions remain internally consistent
5. Project-specific references should be under `foundation_documentation/`
6. Run any applicable local checks for the changed surfaces

If the session is happening from a fully wired downstream environment and that validation is relevant, `bash delphi-ai/verify_context.sh` may be used as an additional readiness check, but it is not a prerequisite for Delphi self-maintenance.

### Step 6: Documentation Sync

If instruction changes affect project docs:
- Note required updates to project documentation
- Do NOT make project documentation changes during self-improvement session
- Add TODO for project documentation updates

### Step 7: Session Closure

**Before closing:**
1. Summarize instruction changes made
2. Confirm agnosticism check passed
3. Confirm no architectural work was done

**When closing:**
- Do NOT prematurely end during discussion
- Close only when user confirms scope is complete

**After closure:**
- If resuming normal work in same conversation: explicitly reload updated instructions
- If hard boundary preferred: state "session ended" after summary

## Session Checklist

### Start of Session

- [ ] Confirm persona (CTO/Tech Lead)
- [ ] Acknowledge implementation freeze
- [ ] List files to be modified
- [ ] Document rationale for changes

### During Session

- [ ] Only modify instruction/template files
- [ ] Do NOT touch project code or docs
- [ ] Verify agnosticism after each change
- [ ] Document any project doc dependencies

### End of Session

- [ ] Run agnosticism verification
- [ ] Summarize all changes made
- [ ] Note any required project doc updates
- [ ] Confirm session closure with user
- [ ] Reload instructions if continuing work

## Outputs

- [ ] Updated instruction/template files
- [ ] Verification note confirming agnosticism check passed
- [ ] Session closure statement
- [ ] TODO list for any project documentation updates needed

## Validation

- Documented manual agnosticism review
- Applicable local checks recorded (or explicit N/A rationale)
- User acknowledgement that session ended before any architectural tasks resume
- No project code changes made during session
