---
name: create-prototype-scenario
description: Compose and validate a named review path from existing Prototype Screen/State identities without creating a second review interface or scenario authority.
---

# Create a Prototype Scenario

A Scenario is an ordered review path through existing Screen/State pairs in one Project Prototype. It is not product navigation, another Screen or State, HTML, a global fixture, or a new authorization scope. Use this skill only within the owner's explicitly authorized Project Prototype scope. Read the shared `$DELPHI_ROOT/local-api/contract.md`; schema v3 is the only supported Prototype contract.

## Inspect and resolve identities

Invoke from the selected Project checkout. Obtain the API-owned destination with `$DELPHI_ROOT/local-api/run context --project-id <id> [--company-id <id>]`, then run fresh `$DELPHI_ROOT/local-api/run artifact-status prototypes --project-id <id> --mode working-tree`. Use this invocation's stdout, confirm its Project/target/authority/mode and `outcome`, and read the current manifest from the API-owned destination. Do not infer IDs from labels, file names, paths, HTML, or an old snapshot.

Resolve every requested step to the stable `screen_id` and `state_id` declared in that manifest. Keep the requested order, including repeated pairs; steps do not need a declared product Transition between them. If the request leaves ordering or identity materially ambiguous, return TEACH with the unresolved choice instead of inventing it.

If the catalog or a manifest is v2, stop and TEACH the owning Project agent: run fresh Prototype status, adapt every offending catalog and manifest (including archived candidates) to v3, verify the complete collection is `go`, then explicitly refresh registration if Builder currency is in scope. Registration alone cannot repair source. There is no v2 reader or compatibility writer.

## Author missing Screens or States only within authority

When a requested pair exposes a genuinely missing Screen or State, invoke the shared `create-prototype` skill only when the owner has authorized creation of that missing product source within the same Project Prototype scope. That skill authors the missing Screen/State and real identifier capture; this skill does not duplicate its authoring rules.

After creation, rerun fresh Prototype status and reread the current manifest before composing the Scenario. If the missing element requires a new design decision, human approval, unavailable evidence, or authority beyond the approved Prototype scope, stop and report TEACH. Never create placeholder IDs, fabricated states, or an unverified Scenario step, and do not claim completion until the full candidate validates.

## Compose and validate

Add or update only the intended `{id,name,steps}` row in the existing v3 `prototype.json`, preserving unrelated manifest fields and stable identities. Scenario IDs are stable and unique within that Prototype; names use 1–160 Unicode characters; `steps` is a required nonempty ordered array of exact `{screen_id,state_id}` pairs. Keep the collection within 256 Scenarios and 4,096 total steps. Do not create per-Scenario HTML/data, a second catalog, a validator, or a Project-authored reviewer shell. Builder owns the Scenario selector, step navigation, and viewport controls; Prototype HTML remains product UI only unless a similar control is genuinely part of the product.

Rerun the complete Prototype evaluator and require `outcome: go`, the intended Scenario in the complete response, and every step to resolve. Then run `builder-project status --project-id <id> --company-id <id>` when registered Builder currency is in scope. If the source is valid but the saved snapshot is stale, follow fresh status TEACH and obtain an explicit matching registration refresh; do not register automatically. Structural success does not establish rendering, behavior, accessibility, visual quality, human approval, QA, or publication.

Report the Scenario ID, ordered resolved pairs, fresh evaluator result and inventory digest, and any Builder currency or human decision still outstanding. On no-go, report the actionable relative diagnostics without implying partial success.
