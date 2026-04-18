---
id: "ANTI-CORE-001-v1"
type: "anti-pattern"
scope: "core"
title: "Silent Guard Bypass"
category: "security"
severity: "must"
supersedes: null
deprecated_by: null
tags: ["guard", "ci", "bypass", "fail-open"]
created: "2026-04-18"
updated: "2026-04-18"
---

## Context

When a CI engine or guard script fails, there is a temptation to add `|| echo "skip"` or `|| true` to keep the pipeline green. This is especially common during initial setup or when the guard is "too strict."

## Problem

```yaml
# WRONG: masks guard failures
- run: python3 todo_completion_guard.py --all-completed || echo "No todos to check"
```

## Why It Fails

A guard that cannot fail is not a guard. If the Python script crashes (syntax error, missing dependency, malformed TODO), the pipeline passes silently. Violations accumulate undetected until they cause production incidents.

## Correct Alternative

`[PATTERN: PAT-CORE-002-v1]` — Fail-Closed Guard Design. Let the guard fail, fix the input.

## Evidence

- `[SESSION:2026-04-18]` Found in Flutter and Next.js CI engines during Manus audit v1.
