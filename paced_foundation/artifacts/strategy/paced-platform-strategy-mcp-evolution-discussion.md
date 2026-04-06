# PACED Platform Strategy: The MCP Evolution

**Artifact role:** `discussion / provisional strategic vision`
**Authority:** `non-authoritative`
**Status:** `a discutir`
**Date:** `2026-04-06`

## How To Read This Document

- This document is a **vision artifact**, not a current PACED rule, workflow, roadmap commitment, or implementation mandate.
- It exists to capture a strategic direction worth discussing without prematurely promoting it into canonical surfaces.
- In this repository, `paced_foundation/artifacts/strategy/` is reserved for **internal PACED strategic discussion artifacts**. It must not be confused with any downstream project's authoritative `foundation_documentation/` package.
- It may inform future updates to `README.md`, `paced_foundation/system_roadmap.md`, workflows, schemas, or platform implementation work, but it does **not** change any of them by itself.
- The immediate PACED priority remains: run the current local/file-based model in real projects, accumulate rule data, and validate the method empirically before promoting MCP platform decisions.

---

## 1. The Thesis: From Method to Platform

Today, PACED governs agentic execution through local linters plus Markdown/JSON artifacts inside the repository. This works well for one agent or one operator working in a bounded local loop.

However, once multiple people and multiple agents collaborate in parallel, the local model starts to show natural limits:

- no strong concurrency locks;
- weak real-time visibility into the execution pipeline;
- fragile handoffs;
- harder coordination of dependencies;
- no first-class place for validated UX assets or shared operational state.

The long-term evolution under discussion is to move **operational artifacts** such as TODO state, stories, locks, dependencies, and metrics into a backend exposed through **Model Context Protocol (MCP)**, while keeping **code and architecture canon** in Git.

This would mean:

- keep `project_constitution.md`, `system_roadmap.md`, module docs, and code in the repo;
- move runtime operational state into a PACED MCP service;
- let the MCP layer act as deterministic workflow enforcement, not as a replacement for code-local tooling.

---

## 2. MCP Server as an Enforcement Layer

The PACED MCP Server is not imagined as a passive storage system. Its role would be to enforce process transitions and return actionable teaching responses.

### 2.1. Project Identity via Repository URL

The server should not anchor project identity on an opaque UUID first. The natural anchor is the canonical Git repository URL.

Example initialization:

```text
paced.session.init(repo_url="github.com/org/project", profile="operational")
```

The server would use that repository identity to:

1. find the project tenant;
2. load project-specific deterministic rules;
3. apply profile and access rules;
4. trigger deterministic onboarding when the project is new or not yet initialized.

### 2.2. Teaching Rule Response Contract

The most important platform principle under discussion is:

> every MCP block should return a **teaching response**, not an opaque failure.

Illustrative shape:

```json
{
  "status": "blocked",
  "rule_id": "paced.workflow.dependency",
  "violation": "Cannot mark TODO-042 as Production-Ready because dependency TODO-038 is still Pending.",
  "resolution_prompt": "Before closing this TODO, resolve TODO-038 first, or remove the dependency if it is no longer valid. Do not force-close.",
  "context": {
    "blocking_todo": "TODO-038",
    "blocking_todo_owner": "agent-ui-team"
  }
}
```

The operational idea is that the server becomes a central teacher for process adherence:

- it blocks;
- it explains;
- it instructs the next valid move.

### 2.3. Coexistence with Local Linters and CI

This platform direction does **not** replace local code validators.

The intended split remains:

| Layer | Scope | Example |
| --- | --- | --- |
| Local linters / CI | code correctness, syntax, tests, structural file integrity | import violation, failing tests, malformed TODO markdown |
| PACED MCP Server | process state, locks, dependencies, profile permissions, shared workflow transitions | blocked TODO, forbidden edit by profile, unmet dependency chain |

Local tooling validates the artifact. The MCP layer validates the collaboration process around the artifact.

---

## 3. Team Collaboration Enabled by MCP

The main reason this direction is attractive is that it could support collaboration patterns the current file-local model cannot enforce as cleanly.

### 3.1. Concurrency Locks

An agent or human could claim a TODO through MCP. A competing claim would be blocked deterministically, with the server returning guidance toward the next valid unit of work.

### 3.2. UX and Asset Attachment

Validated UX assets could be attached directly to stories or TODOs through a PACED surface, instead of being lost in ad hoc repository folders or chat context.

### 3.3. Cascading Unblock

When one team closes a blocking TODO, dependent work could be automatically unblocked or notified through the same operational surface.

---

## 4. Proposed Platform Roadmap Under Discussion

This is not a committed roadmap. It is the current staged thinking for how PACED could evolve if empirical validation continues to support it.

### Phase 0: Empirical Validation of the Local Model

- run PACED in real projects using the current local/file-based approach;
- accumulate `rule-events.jsonl` data;
- calibrate deterministic rules using `Clean Rate`, false positives, escapes, and gate usefulness.

### Phase 1: Headless PACED MCP

- build the MCP backend without a UI first;
- move operational state such as TODO state and event ledgers into the service;
- implement teaching-rule responses for workflow operations.

Expected value:

- deterministic locks;
- central process enforcement;
- project/profile-aware access control.

### Phase 2: Visualization and UX

- build a web UI or editor surface over the MCP backend;
- expose pipeline/Kanban views;
- attach UX assets and shared work evidence to operational artifacts.

Expected value:

- better human visibility;
- better human-agent collaboration;
- less reliance on repository browsing for runtime state.

### Phase 3: Handoff and Analytics

- structured handoff flows between humans and agents;
- real-time dashboards for `Clean Rate`, rule effectiveness, and team-level flow quality.

Expected value:

- executive visibility;
- measurable governance performance;
- scalable multi-agent engineering operations.

---

## 5. Promotion Rules For This Vision

Before any part of this document is treated as canon, it should be promoted intentionally into the correct authoritative surface.

- Promote to `README.md` only when PACED wants to publicly state the platform direction as part of the framework narrative.
- Promote to `paced_foundation/system_roadmap.md` only when the MCP direction becomes an actual staged strategic commitment.
- Promote to workflows, tools, schemas, or rules only when a phase becomes implementation scope.
- Until then, keep this document as a discussion artifact, not as an implicit source of truth.

---

## Conclusion

The MCP evolution does not change the essence of PACED. The idea under discussion is to scale the same thesis:

- deterministic enforcement;
- teaching responses;
- progressively accumulated intelligence;
- stronger collaboration with lower process ambiguity.

For now, this remains a strategic vision under discussion. The current obligation is still to validate the local PACED model in real projects and earn the platform step with evidence.
