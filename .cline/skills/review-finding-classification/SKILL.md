---
name: review-finding-classification
description: "Canonical post-review triage for Copilot real/mimic, Codex/Claude/no-context, CI, and promotion findings using the repo taxonomy and Promotion Finding Routing Ledger."
---

# Review Finding Classification

Use this skill after findings have already been collected and deduplicated from:
- Copilot real
- Copilot mimic / `copilot-pr-review`
- Codex / Claude / no-context audits
- CI checks
- promotion preflight or promotion PR reviews

This skill does **not** change how reviewers detect issues. It only governs the post-detection triage and ledger routing.

## Canonical Sources

Read these before classifying:
- `foundation_documentation/todos/README.md` section `Review Finding Classification`
- `foundation_documentation/project_constitution.md` review/promotion classification bullets
- the governing TODO, especially:
  - approved objective
  - decisions / non-goals
  - validation matrix
  - `Promotion Finding Routing Ledger`

If prior findings already exist, also derive carry-forward context:

```bash
python3 delphi-ai/tools/finding_carry_forward_extract.py --todo <todo-path>
```

## Classification Contract

1. Freeze the exact finding first.
   - reviewer surface
   - exact text / locus
   - current evidence
   - whether the current bounded package actually changed that locus/behavior
2. Cross-check the finding against the governing TODO.
   - approved objective
   - explicit decisions
   - accepted by-design behavior
   - non-goals
   - validation/evidence expectations
3. Classify the finding as exactly one of:
   - `release-blocker`
     - real defect/risk for the current delivery or promotion claim
     - must be fixed, explicitly challenged as by-design, or re-approved before the lane is clean
   - `follow-up-fast-follow`
     - real issue, but not a blocker for the current release/package
     - requires an explicit TODO under `foundation_documentation/todos/active/fast_follow_required/followup/`
   - `follow-up-hardening`
     - real issue, but not a blocker for the current release/package
     - requires an explicit TODO under `foundation_documentation/todos/active/post_release_hardening/hardening/`
   - `by-design/no-action`
     - expected behavior, reviewer noise, or already-approved intent
     - requires rationale tied back to approved scope/decision/evidence
4. Record every classified finding in the governing TODO `Promotion Finding Routing Ledger`.
   - repeated findings stay historical/noise unless the current bounded package materially changed the same locus/behavior or the prior rationale is objectively insufficient
   - only `release-blocker` rows block the current delivery/promotion claim
   - non-blocking real findings are not disposable; split or cite the explicit follow-up owner before calling the lane clean

## Deterministic Support

Use the narrow helper only for ledger scaffolding, never for blocker authority:

```bash
python3 delphi-ai/tools/review_finding_routing_scaffold.py --input <findings.json> --section
```

The helper renders guard-compatible `Promotion Finding Routing Ledger` rows/sections from operator-supplied metadata. It does **not** decide the classification for you.

## Expected Ledger Shape

The current enforced ledger columns are:
- `Finding ID`
- `Severity`
- `Classification`
- `Routing Decision`
- `Same TODO / Split Rationale`
- `Status`
- `Approval / Follow-up Reference`

Keep rows concrete and non-placeholder before any delivery or promotion-clean claim.

## Non-Negotiables

- Do not weaken reviewer prompts or heuristics just to reduce findings.
- Do not reopen work solely because a reviewer repeated an already adjudicated finding on an unchanged locus/behavior.
- Do not leave real non-blocking findings as vague notes.
- Do not let the helper script become a second policy source.
- Do not let Copilot/Codex/CI comments outrank an approved TODO decision without explicit re-check against the governing TODO.
