---
name: orchestrated-single-todo-implementation
description: Explicitly orchestrate implementation of one approved tactical TODO, including authorized Laravel, Flutter, or Docker changes, with canonical routing and deterministic intake checks.
---

# Orchestrated Single Todo Implementation

Invoke this skill by name only when exactly one canonical tactical TODO is approved. It may cover explicitly authorized Laravel, Flutter, or Docker work when the same TODO names those paths. Do not use it for broad or multiple-TODO initiatives, or for work without a canonical approved TODO.

Before editing, run the two deterministic helpers from the repository root:

1. `python3 tools/orchestrated_single_todo_routing.py --client <client> --surface <surface> --role <role> --json-output <ignored-temp-file>`
2. `python3 tools/orchestrated_single_todo_teach.py --todo <exact-todo> --baseline <frozen-ref@commit> --approval-gate approved --authority-gate canonical --changed-path <path> ... --expected-path <contract-path-or-glob> ... --writer-role routine-executor --raw-artifact-root <ignored-temp-root> --token-total unavailable`

Stop on a TEACH block. A successful resolver is evidence of the existing `config/agent_role_routing.json` selection, not a replacement authority. The exact TODO must authorize every expected path, including any cross-stack path. The routine executor remains the sole normal material writer; provider fallback and automatic dispatch are prohibited.

Keep raw command/review/usage payloads only under the ignored temporary execution root. Record compact command/result summaries and provider-reported token totals in the exact TODO; use `unavailable` when no provider report exists.
