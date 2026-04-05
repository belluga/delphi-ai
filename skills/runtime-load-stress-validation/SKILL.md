---
name: runtime-load-stress-validation
description: "Validate backend/runtime behavior under load, stress, spike, and soak conditions with explicit workload models, SLOs, and evidence before delivery when runtime sensitivity justifies it."
---

# Runtime Load / Stress Validation

## Purpose
Prove that runtime-sensitive changes remain acceptable under realistic or adversarial workload pressure instead of relying only on smoke checks.

## Scope Controls
- This skill does not replace TODO governance or ordinary functional testing.
- Use it when the TODO materially affects throughput, latency, concurrency, worker pressure, queues, realtime lanes, caching, indexing, or heavy endpoints.
- Prefer safe non-production environments.
- Do not run destructive traffic against production.

## Preferred Deterministic Helpers
- Use `bash delphi-ai/tools/runtime_load_probe.sh --url <url> [--mode <load|stress|spike|soak>] [--method <verb>] [--stage <concurrency>:<duration-sec>] [--stage <concurrency>:<duration-sec> ...] [--expect-status <code>] [--max-p95-sec <seconds>] [--max-p99-sec <seconds>] [--max-error-rate <ratio>] [--min-throughput <req-per-sec>] [--output-dir <dir>]` to run deterministic staged HTTP load/stress probes with objective threshold checks.
- Use `bash delphi-ai/tools/runtime_load_validation_scaffold.sh --system "<surface>" [--mode <load|stress|spike|soak>] [--entrypoint "<target>"] [--slo "<metric>"] [--output <path>]` when the workload/SLO artifact still needs to be frozen before execution.
- Deterministic depth: already-backed for HTTP/runtime surfaces. Queue, worker, or realtime paths may still require stack-local harnesses, but the common endpoint path now has a canonical deterministic runner.

## Validation Modes
- `load`: expected workload
- `stress`: above expected workload until degradation
- `spike`: sudden burst or concurrency jump
- `soak`: sustained workload over time

## Workflow
1. **Frame the runtime surface**
   - Record the changed endpoint(s), queue/worker paths, realtime lanes, or runtime components in scope.
2. **Freeze workload model**
   - Define entry points, stages (`concurrency:duration`), request mix, and acceptable environment.
3. **Freeze SLO / acceptance targets**
   - Record the latency, error-rate, throughput, and degradation expectations that matter.
4. **Run the chosen mode(s)**
   - Prefer `runtime_load_probe.sh` for HTTP/runtime surfaces so thresholds and failure signals are evaluated objectively.
   - Use the least risky path that still produces useful evidence for non-HTTP paths.
5. **Capture evidence**
   - Record p50/p95/p99 latency, throughput, error rate, and observed saturation/degradation behavior.
6. **Classify findings**
   - Distinguish product/runtime bottlenecks from harness or environment faults.
7. **Document residual risk**
   - If full load/stress is not run, state why and what remains uncertain.

## Required Outputs
- Workload model
- Stages executed
- Mode(s) executed
- SLO / acceptance criteria
- Metrics summary
- Degradation / saturation notes
- Residual performance risk statement

## Done Criteria
- Runtime-sensitive work does not close on smoke-only evidence when stronger evidence was required.
- The executed workload and acceptance targets are explicit.
- Load/stress findings are concrete enough to guide follow-up fixes or waivers.
