---
name: backend-concurrency-idempotency-validation
description: "Validate backend mutations and lookup-critical paths against real concurrent requests so duplicate effects, lost updates, and missing idempotency are caught before delivery."
---

# Backend Concurrency / Idempotency Validation

## Purpose
Prove that backend behavior remains correct under real concurrent requests instead of assuming that ordinary functional tests or generic load tests will expose race conditions.

## Scope Controls
- Use this skill for mutation endpoints, jobs, webhooks, reservation/purchase flows, exact-once semantics, or any path where duplicate or overlapping requests can corrupt state.
- This skill complements `runtime-load-stress-validation`; it does not replace it.
- Prefer safe non-production environments.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/backend_concurrency_probe.sh --url <url> [--method <verb>] [--concurrency <n>] [--concurrency <n> ...] [--header "<name>: <value>"] [--body-file <path>] [--idempotency-header <name>] [--idempotency-mode <same|unique>] [--expect-status <code>] [--output-dir <dir>]` to send real concurrent requests and capture status/latency evidence.
- Treat the helper as evidence collection only; invariants and pass/fail interpretation remain in this skill.
- Deterministic depth: strong partial automation. The probe sends real concurrent traffic, but it cannot decide by itself whether the business invariant or idempotency contract actually held.

## Required Concurrency Thinking
- duplicate mutation on simultaneous submit
- missing idempotency for side-effectful writes
- lost update / last-write corruption
- unique-constraint or transaction boundary gaps
- concurrent job/webhook/API overlap on the same resource
- exact-key lookup path consistency under concurrent writes

## Workflow
1. **Frame the critical invariant**
   - Define what must stay true under concurrency.
2. **Classify the concurrency policy**
   - `reject duplicate`
   - `idempotent same-key replay`
   - `serialize`
   - `optimistic concurrency`
   - `last-write-wins`
3. **Freeze probe levels**
   - Default to real concurrent probes such as `5`, `10`, and `20`.
4. **Run deterministic probe**
   - Capture response code distribution and latency by concurrency level.
5. **Validate domain invariants**
   - Response summaries are not enough; confirm whether the protected invariant actually held.
6. **Issue cards**
   - Record any duplicate effect, inconsistent response contract, or missing idempotency signal as a material finding.

## Required Outputs
- Declared invariant and concurrency policy
- Probe configuration and output
- Domain-level invariant result
- Residual concurrency risk statement

## Done Criteria
- Concurrency-sensitive paths do not close on smoke-only evidence.
- Real concurrent probes were run when required or explicitly waived.
- Duplicate side-effect risk is either fixed, safely rejected, or explicitly waived.
