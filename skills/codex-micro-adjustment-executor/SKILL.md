---
name: codex-micro-adjustment-executor
description: Explicitly run a bounded micro-adjustment using the canonical routing JSON and deterministic TEACH checks.
---

# Codex Micro-Adjustment Executor

Invoke this skill by name only for a user-authorized, small Delphi self-maintenance adjustment. It is not an automatic coordinator and does not apply to downstream product work, routing-schema migration, provider/runtime introspection, P1/P2 cutover, or broad refactors.

Before editing, run the two deterministic helpers from the repository root:

1. `python3 tools/codex_micro_adjustment_routing.py --client <client> --surface <surface> --role <role> --json-output <ignored-temp-file>`
2. `python3 tools/codex_micro_adjustment_teach.py --todo <exact-todo> --changed-path <path> ... --writer-role routine-executor --provider-fallback prohibited --runtime-introspection prohibited --schema-migration prohibited --raw-artifact-root <ignored-temp-root> --token-total unavailable`

Stop on a TEACH block. A successful resolver is evidence of the existing `config/agent_role_routing.json` selection, not a replacement authority. The routine executor remains the sole normal material writer; no provider fallback, automatic dispatch, schema cutover, or runtime model inference is permitted.

Keep raw command/review/usage payloads only under the ignored temporary execution root. Record compact command/result summaries and provider-reported token totals in the exact TODO; use `unavailable` when no provider report exists.
