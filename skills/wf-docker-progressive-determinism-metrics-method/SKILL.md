---
name: wf-docker-progressive-determinism-metrics-method
description: "Workflow: establish PACED Phase 1 metrics by seeding rule catalog, logging deterministic rule episodes, extracting gate finding resolutions from TODOs, and deriving clean-rate summaries."
---

# Workflow: Progressive Determinism Metrics

Use `workflows/docker/progressive-determinism-metrics-method.md` when PACED needs to measure:
- teaching-rule effectiveness;
- no-context helper usefulness/noise;
- clean-rate trends over time.

Minimum responsibilities:
1. Seed or refresh `rule-catalog.json`.
2. Feed deterministic validators into `rule-events.jsonl`.
3. Use `rule_event_record.py gate-escape` for CI/Copilot P1/P2 and Rule-Spirit escapes that automatic extraction cannot infer.
4. Keep gate finding resolutions in the authoritative TODO, then extract the derived JSON packet.
5. Generate the derived metrics summary.

Do not treat the metrics artifacts as canonical product truth. They are governance telemetry only.
