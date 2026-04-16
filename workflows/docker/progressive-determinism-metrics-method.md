---
description: Seed the rule catalog, record deterministic rule episodes, extract no-context gate finding resolutions, and derive clean-rate summaries for PACED Phase 1 metrics.
---

# Method: Progressive Determinism Metrics

## Purpose
Provide the Phase 1 metrics loop that lets PACED measure whether progressive determinism is actually improving delivery quality over time.

This method is intentionally:
- event-sourced;
- adjudication-light;
- summary-derived.

It does not maintain central manual counters. It records rule/gate events, extracts authoritative resolutions from the TODO, and derives summary metrics from those inputs.

## Phase 1 Artifacts
- `foundation_documentation/artifacts/metrics/rule-catalog.json`
  - project-local rule catalog covering PACED-level and PROJECT-level teaching rules
- `foundation_documentation/artifacts/metrics/events/rule-events.jsonl`
  - append-only event stream for deterministic rule episodes, escapes, and lifecycle changes
- `foundation_documentation/artifacts/tmp/<slug>-<review-kind>-resolution.json`
  - derived gate-finding resolution packet extracted from the authoritative TODO
- `foundation_documentation/artifacts/metrics/project-metrics-summary.json`
- `foundation_documentation/artifacts/metrics/project-metrics-summary.md`

## Triggers
- A project wants to start measuring teaching-rule effectiveness and no-context helper effectiveness.
- Deterministic validators are already blocking work and the team wants episode-level visibility.
- Independent critique/test-audit/final-review findings should be tracked for usefulness and formalizability.

## Core Rules
- The tactical TODO remains the execution authority. Gate finding resolutions must live there first.
- `rule-events.jsonl` records events, not counters.
- `Clean Rate` is derived; it is never hand-maintained.
- False positives and escapes require explicit adjudication.
- True positives should be inferred by default when an observed episode disappears after correction.

## Procedure
1. **Seed the project rule catalog**
   ```bash
   python3 delphi-ai/tools/seed_rule_catalog.py \
     --output foundation_documentation/artifacts/metrics/rule-catalog.json
   ```
2. **Record deterministic rule episodes**
   - When running the tactical TODO validator, include:
     ```bash
     python3 delphi-ai/tools/todo_deterministic_validator.py \
       --todo foundation_documentation/todos/active/<lane>/<slug>.md \
       --bundle-output foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json \
       --report-json foundation_documentation/artifacts/tmp/<slug>-todo-validation-report.json \
       --events-jsonl foundation_documentation/artifacts/metrics/events/rule-events.jsonl
     ```
   - Use `python3 delphi-ai/tools/rule_event_record.py ...` only when inference is not enough (for example false positives, escapes, or lifecycle changes).
3. **Capture no-context gate findings**
   - Merge structured reviewer output:
     ```bash
     python3 delphi-ai/tools/subagent_review_merge.py ...
     ```
   - Render a TODO-ready resolution table:
     ```bash
     python3 delphi-ai/tools/gate_finding_resolution_scaffold.py \
       --merge foundation_documentation/artifacts/tmp/subagent-<kind>-merge.json
     ```
   - Paste/fill that table into the authoritative TODO gate section.
4. **Extract machine-checkable gate resolutions from the TODO**
   ```bash
   python3 delphi-ai/tools/gate_finding_resolution_extract.py \
     --todo foundation_documentation/todos/active/<lane>/<slug>.md \
     --review-kind <critique|test_quality_audit|final_review> \
     --output foundation_documentation/artifacts/tmp/<slug>-<review-kind>-resolution.json
   ```
5. **Aggregate the summary**
   ```bash
   python3 delphi-ai/tools/paced_metrics_summary.py \
     --repo . \
     --summary-json foundation_documentation/artifacts/metrics/project-metrics-summary.json \
     --summary-markdown foundation_documentation/artifacts/metrics/project-metrics-summary.md
   ```

## Metrics Derived In Phase 1
- Deterministic rule metrics:
  - block episodes
  - true positives
  - false positives
  - escapes
  - recalibrations
- Gate metrics:
  - executed gates
  - clean gates
  - useful findings
  - discarded findings
  - mixed findings
  - formalizable useful findings (`yes|partial`)
- Clean rates:
  - deterministic clean rate
  - gate clean rate
  - work clean rate

## Non-Authority Rule
- The catalog, event log, extracted resolution packets, and metrics summaries are governance artifacts.
- They do not replace constitution, roadmap, modules, or the tactical TODO.
- The future PACED MCP Server may expose these same operations as native tools, but Phase 1 must keep the business logic independent from CLI parsing so that migration is additive rather than a rewrite.
