---
name: wf-docker-assumption-code-coherence-guard-method
description: "Workflow: MUST use whenever a tactical TODO needs the post-critique assumption-vs-code coherence guard before APROVADO."
---

# Method: Assumption-vs-Code Coherence Guard

Use after critique convergence and before `APROVADO`. Canonical details live in `workflows/docker/assumption-code-coherence-guard-method.md`.

## Responsibilities
- Check the still-live assumptions against the exact cited code/test files.
- Run `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>`.
- Record the result under `Gate: Assumption Code Coherence`.
- Reopen the TODO/review loop if a wrong code assumption is found.

## Outputs
- Deterministic guard result.
- TODO gate evidence for assumption-vs-code coherence.
