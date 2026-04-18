---
id: "PAT-CORE-002-v1"
type: "pattern"
scope: "core"
title: "Fail-Closed Guard Design"
category: "security"
severity: "must"
supersedes: null
deprecated_by: null
tags: ["guard", "ci", "fail-closed", "deterministic"]
created: "2026-04-18"
updated: "2026-04-18"
---

## Context

Deterministic guards (CI engines, completion guards, linters) are the non-negotiable law of the ecosystem. When a guard encounters an error, ambiguity, or unexpected state, it must default to blocking.

## Decision

All guard scripts MUST exit with a non-zero code on any error, including internal failures (parse errors, missing files, malformed input). The `|| echo` or `|| true` pattern is strictly forbidden in guard invocations. If a guard cannot determine compliance, it MUST assume non-compliance and block.

## Consequences

False negatives (letting violations through) are eliminated. The cost is occasional false positives (blocking valid work), which are resolved by fixing the guard input, never by weakening the guard.

## Evidence

- `[SESSION:2026-04-18]` Discovered during Manus audit v1: Flutter and Next.js CI engines used `|| echo` to mask guard failures.
