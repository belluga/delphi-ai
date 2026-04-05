---
name: endpoint-performance-scrutiny
description: "Scrutinize endpoint and repository access paths so exact lookups use direct indexed queries/contracts instead of list scans, page walks, or in-memory filtering."
---

# Endpoint Performance Scrutiny

## Purpose
Prevent endpoint and repository logic from shipping with fake convenience paths such as list-then-filter, page-walk exact lookup, or broad fetch followed by in-memory matching.

## Scope Controls
- Use this skill whenever an API endpoint, repository method, controller lookup path, or client-side exact-entity fetch is created or changed.
- This skill is about query/access-path quality, not just generic load.
- Pair with `runtime-load-stress-validation` when endpoint behavior is also capacity-sensitive.

## Preferred Deterministic Helpers
- Use `bash delphi-ai/tools/endpoint_performance_review_scaffold.sh --endpoint "<name>" --pattern <exact-lookup|bounded-list|search|aggregation|mutation> [--lookup-key "<key>"] [--index "<index>"] [--output <path>]` to structure the endpoint review.
- Use `bash delphi-ai/tools/exact_lookup_anti_pattern_audit.sh [--repo <repo-root>] [--path <path> ... | --scan-git-modified]` to scan for list-scan and page-walk exact-lookup heuristics.
- Treat the audit as heuristic evidence, not as a complete proof of performance quality.
- Deterministic depth: partial only. The current support catches suspicious code shapes and enforces review structure, but it does not replace real query-plan/log/benchmark evidence.

## Non-Negotiable Rules
- Exact-key lookups (`slug`, `id`, `uuid`, `code`, `handle`, external key, etc.) must use a direct query path or a dedicated endpoint/contract.
- Exact-key lookups must not iterate paginated list endpoints page by page.
- Broad fetch + in-memory filter is forbidden for exact lookup when a direct indexed/queryable path should exist.
- If the client needs exact lookup and no direct contract exists yet, create the right contract instead of normalizing the workaround.

## Workflow
1. **Classify the access pattern**
   - `exact-lookup`, `bounded-list`, `search`, `aggregation`, or `mutation`.
2. **Record the canonical lookup path**
   - Define lookup keys, expected direct query path, and expected index/constraint support.
3. **Scrutinize backend and client path together**
   - Laravel endpoint/service query shape.
   - Flutter/Web repository usage path.
4. **Run heuristic audit**
   - Scan touched files for page-walk or post-fetch exact-match anti-patterns.
5. **Capture stronger evidence when required**
   - For material endpoints, record query logs, `explain`, benchmark, or equivalent evidence.
6. **Issue cards**
   - Any suspicious workaround gets a concrete issue card with recommended fix.

## Required Outputs
- Access-pattern classification
- Canonical lookup/query path
- Expected index/constraint support
- Heuristic audit output
- Stronger query evidence when material
- Residual performance risk statement

## Done Criteria
- No exact-lookup path in scope relies on page walking or broad fetch + in-memory filtering.
- Query/access-path intent is explicit enough that later reviewers can challenge it.
- Material findings are either fixed or explicitly waived with residual risk.
