---
id: "PAT-CORE-001-v1"
type: "pattern"
scope: "core"
title: "TODO-Driven Execution"
category: "convention"
severity: "must"
supersedes: null
deprecated_by: null
tags: ["todo", "governance", "execution"]
created: "2026-04-18"
updated: "2026-04-18"
---

## Context

Every unit of work in a PACED-governed project must be traceable to an authorized TODO. This applies to all agents (Codex, Cline, Gemini, Manus) regardless of stack.

## Decision

No code change, configuration update, or documentation edit may be performed without an active TODO in `todos/active/`. The TODO is the single source of truth for what is authorized, scoped, and expected. Agents MUST NOT perform work outside the boundaries of the active TODO.

## Consequences

When applied correctly, every commit can be traced back to a TODO, every TODO can be traced to a roadmap item, and every roadmap item to the Constitution. This creates a full audit trail from strategy to code.

## Evidence

- `[SESSION:2026-04-18]` Extracted from PACED framework core principles during Manus audit.
