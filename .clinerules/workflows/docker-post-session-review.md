---
name: docker-post-session-review
description: "Close a session with discipline: capture newly surfaced business principles, keep foundation_documentation authoritative, and provide rigorous English feedback."
---

# Workflow: Post-Session Review

## Purpose

Close a session with discipline: capture newly surfaced business principles, keep `foundation_documentation/` authoritative, and provide rigorous English feedback.

## Triggers

- The user explicitly signals the session is ending
- Examples: "session ended", "we're done", "stop here"

## Prerequisites

- [ ] Full session dialogue available for review
- [ ] `foundation_documentation/project_mandate.md` accessible
- [ ] Any adjacent mandate docs referenced during session

## Procedure

### Step 1: Principle Extraction

Review the entire session dialogue and identify:

1. **New Core Business Principles**
   - Ethical principles discussed
   - Social principles discussed
   - Visionary/strategic principles discussed

2. **Evolved Principles**
   - Existing principles that were refined
   - Principles that changed scope or application

3. **Principles to Consider**
   - Document candidate principles
   - Note context where they surfaced

### Step 2: Mandate Validation

For each candidate principle:

1. **Present to user**
   - State the principle clearly
   - Provide context from session
   - Ask for confirmation

2. **If confirmed**
   - Update `foundation_documentation/project_mandate.md`
   - Follow project documentation conventions
   - Note the addition date

3. **If rejected**
   - Document why it was rejected
   - Note for future reference

### Step 3: English Feedback

Provide a direct, technically rigorous review:

1. **Grammar issues**
   - Subject-verb agreement
   - Tense consistency
   - Article usage

2. **Style issues**
   - Clarity of expression
   - Word choice
   - Sentence structure

3. **Technical writing**
   - Consistency of terminology
   - Proper use of technical terms
   - Documentation style

**Note:** Focus on correctness over encouragement. Be objective and specific.

### Step 4: Closure

Only after steps 1–3 are complete:

1. **Summarize review results**
   - Principles identified (confirmed or rejected)
   - English feedback highlights
   - Any follow-up actions

2. **Acknowledge session end**
   - State "Session review complete"
   - Note any pending work for next session

## Template: Principle Documentation

```markdown
## Principle: [Name]

**Type:** Ethical | Social | Visionary
**Added:** [Date]
**Context:** [Where/why this surfaced]

### Statement
[Clear, concise principle statement]

### Application
[How this principle should be applied]

### Rationale
[Why this principle matters]
```

## Template: English Feedback

```markdown
## English Feedback

### Grammar
- [Issue 1]: [Correction]
- [Issue 2]: [Correction]

### Style
- [Issue 1]: [Suggestion]
- [Issue 2]: [Suggestion]

### Technical Writing
- [Issue 1]: [Recommendation]

### Overall Assessment
[Brief summary of language proficiency and areas for improvement]
```

## Outputs

- [ ] Confirmed list of new principles (or explicit "none found")
- [ ] Any required mandate updates (only if user confirms)
- [ ] English feedback delivered
- [ ] Session closure acknowledged

## Validation Checklist

- [ ] All steps 1–4 completed in order
- [ ] No new work requests accepted until review complete
- [ ] User has opportunity to respond to feedback
- [ ] Documentation updated if principles were added