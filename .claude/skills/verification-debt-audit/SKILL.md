---
name: verification-debt-audit
description: "Audit verification debt across TODO evidence, tactical-note drift, waivers, and inline code TODO hygiene before closure."
---

# Verification Debt Audit

## Purpose
Detect closure-time debt that makes future maintenance slower or less trustworthy even when the immediate feature appears to work.

## Scope Controls
- This skill audits closure quality; it does not bypass TODO governance for code/doc changes.
- If the audit finds debt that requires project changes, follow the active TODO lane and approval rules before fixing it.
- Pair with `test-quality-audit` when the main debt signal is weak or retrofitted tests.
- Typical triggers:
  - `medium|big` TODOs
  - shared contract or cross-module changes
  - TODOs with waivers or provisional notes
  - code changes that introduce or leave inline `TODO|FIXME|HACK|TBD`

## Preferred Deterministic Helper
- Default audit path for TODO evidence + inline debt scanning:
  - `bash delphi-ai/tools/verification_debt_audit.sh --todo <todo-path>`
- Include changed/untracked files from the current branch in the inline debt scan:
  - `bash delphi-ai/tools/verification_debt_audit.sh --todo <todo-path> --scan-git-modified`
- Add explicit scan targets when the touched scope is narrower than the whole branch:
  - `bash delphi-ai/tools/verification_debt_audit.sh --todo <todo-path> --path <touched-path> [--path <touched-path> ...]`
- Exit code `2` means the audit completed and found `medium|high` debt signals. Treat that as evidence to review, not as automatic permission to rewrite scope.

## Debt Categories
- **Evidence debt**: claims in the TODO lack concrete proof.
- **Validation debt**: promised validation steps were skipped, weakened, or left ambiguous.
- **Waiver debt**: too many waivers, or waivers without a clear reason and expiration.
- **Promotion debt**: durable knowledge still trapped in tactical TODO notes instead of module docs.
- **Inline code TODO debt**: source contains `TODO|FIXME|HACK|TBD|XXX` without owner/next action/canonical link.
- **Closure drift**: TODO looks complete, but blockers/provisional status/evidence still indicate unresolved work.

## Audit Workflow
1. **Frame the audit**
   - Capture the active/completing TODO and its delivery stage.
   - Note whether the change touched shared contracts, cross-module surfaces, or critical user journeys.
2. **Check TODO evidence completeness**
   - Verify `Definition of Done`, `Validation Steps`, adherence tables, security risk assessment, and promotion evidence are complete enough to justify closure.
   - Flag any statement that claims success without artifact, command output, test evidence, or doc traceability.
3. **Check waiver quality**
   - Identify every waiver, `N/A`, explicit skip, or deferred verification item.
   - Flag waivers that lack:
     - why the waiver is safe now
     - what risk remains
     - when or how the waiver should be revisited
4. **Check promotion discipline**
   - Compare the TODO against touched module docs.
   - Flag durable conclusions still trapped in the TODO or comments instead of canonical docs.
5. **Scan code TODO hygiene**
   - Search touched files for inline debt markers:
     - `TODO`
     - `FIXME`
     - `HACK`
     - `TBD`
     - `XXX`
   - Classify each hit:
     - `acceptable`: local marker with clear next action and owner/context
     - `cleanup-required`: vague or stale marker that should be resolved now
     - `canonical-link-missing`: marker represents roadmap/contract knowledge but has no link to canonical docs/TODO
6. **Classify audit outcome**
   - `none`: no meaningful verification debt remains
   - `low`: minor debt, explicitly accepted with low maintenance risk
   - `medium`: debt is present and should be scheduled/tracked explicitly
   - `high`: closure should be blocked until debt is reduced
7. **Issue cards for material debt**
   - For each material finding record:
     - `Issue ID`
     - severity
     - evidence (`file:line`, TODO section, command/log)
     - why it matters
     - fix options `A/B/C`
     - recommended option

## Recommended Search Heuristics
- TODO/waiver scan:
  - `rg -n "waiver|not run|not needed|n/a|TODO|FIXME|HACK|TBD|blocked|provisional" foundation_documentation/todos/active foundation_documentation/todos/completed`
- Inline code debt:
  - `rg -n "\\b(TODO|FIXME|HACK|TBD|XXX)\\b" <touched-paths...>`

## Required Outputs
- Audit outcome: `none|low|medium|high`
- Short rationale for the outcome
- Inline code TODO debt classification: `none|accepted|cleanup-required`
- Evidence or artifact path for the audit
- Accepted residual debt, if any

## Done Criteria
- Closure is not declared clean while material evidence/promotion/waiver debt remains hidden.
- Inline code TODO debt is either cleaned up or explicitly classified and justified.
- Durable knowledge is promoted into canonical docs instead of staying trapped in tactical artifacts.
- Any remaining verification debt is explicit enough to survive future sessions without rediscovery.
