---
id: "PAT-CORE-003-v1"
type: "pattern"
scope: "core"
title: "Cascading Authority Resolution"
category: "architecture"
severity: "must"
supersedes: null
deprecated_by: null
tags: ["cascading", "authority", "core", "stack", "local"]
created: "2026-04-18"
updated: "2026-04-18"
---

## Context

The PACED ecosystem operates under a dual-layer governance hierarchy (Instruction Layer + Deterministic Layer), each with three precedence levels: Local, Stack, and Core.

## Decision

When resolving any rule, pattern, or deterministic check, the agent MUST follow the precedence chain: Local overrides Stack, Stack overrides Core. An override MUST be explicit (via `supersedes` field for patterns, or via local config for deterministic). Silent shadowing is forbidden — if a local artifact conflicts with a core artifact without declaring `supersedes`, it is a violation.

## Consequences

Projects can customize behavior without forking the framework. The override chain is auditable and reversible. No "magic" behavior from undeclared local overrides.

## Evidence

- `[SESSION:2026-04-18]` Codified from `main_instructions.md` Section 4.A during Manus audit.
