---
name: create-prototype
description: Create or update a Project Prototype candidate and validate its local structural inventory without claiming conformance or publication.
---

# Create a Prototype

A Prototype is a versioned, inspectable source artifact, not an executed or published application. Use this skill for a candidate in an explicitly selected Project. Resolve the canonical shared Delphi checkout (`DELPHI_ROOT`) independently of the caller's cwd, then read `$DELPHI_ROOT/local-api/contract.md` for the exact catalog, manifest, inventory, reference, and response schemas.

## Inspect before authoring

Invoke from the selected Project checkout. Obtain its API-owned authoring destination using `$DELPHI_ROOT/local-api/run context --project-id <id> [--company-id <id>]`; never ask for storage, repository or Foundation paths. Read relevant managed documents and inspect the current catalog with `$DELPHI_ROOT/local-api/run artifact-status prototypes --project-id <id> --mode working-tree`. Registration is not required. Use that invocation's fresh stdout, not a saved snapshot. Check response identity, target, authority scope, mode, revision, outcome, items, diagnostics, and `design_system_validation`.

If the catalog or provider is absent, report that gap. An explicit creation request may create the standard catalog and candidate; never create placeholders merely to make a check green. Keep unapproved exploration outside the managed `prototypes/` tree. Before changing a managed candidate, confirm that its owner approved the governing scope and requested mutation; a request to create a concept or a structural `go` result is not itself authorization.

## Authoring modes and screen navigation

Use one of two explicit visual authoring modes: (1) explore a proposed composition with preview-only images, inspect the result against the effective Design System, then implement only the selected direction in HTML; or (2) apply the effective Design System directly in HTML. In either mode, resolve visual divergence against the selected system rather than silently treating exploratory imagery as authority. If no usable Design System is selected, report the gap and keep any illustrative draft clearly labeled.

Describe Screens as distinct navigable views. Describe a Screen's interaction states separately in the prose/evidence note; v1 does not store a state model or active/archived lifecycle, so do not imply those are registered or validated. Use local links between declared Screens and show the relationship between the catalog, manifest and source paths in the handoff.

## Build a bounded candidate

Write `prototypes/catalog.json` and a direct-child `prototypes/<candidate>/` root in the API-owned destination. Produce navigable HTML Screens with local CSS/JavaScript/assets as needed, plus a README/evidence note separating Screens and their states. Coordinate the catalog entry, `<root>/prototype.json`, and declared files as one change. Preserve stable IDs when updating; do not infer identities from folder names. The catalog registers each direct-child Prototype root using the `prototypes/` prefix (for example, `prototypes/demo`). The manifest includes a matching ID, entry point, nonnull Screens/sources/assets/links/related arrays, and explicit `design_system_ref` (null or `{id,content_digest}`). Every Screen has stable ID, name, path, and explicit `scope: null`. Entry point and Screen paths must be declared sources. Paths are safe, unique, root-relative regular files; sources and assets are disjoint. Links refer only to local Screens. Related paths are Foundation-root-relative evidence, not authority or compatibility proof.

Keep drafts outside the managed inventory. The structural evaluator does not execute HTML/JavaScript. Local browser rendering and navigation checks are part of requested Prototype authoring; do not fetch remote Git, publish assets, create product routes or enroll the Project without separate authorization. Use only intentionally admitted source/assets. V1 has no recorded exploration-mode field, separate Screen-state model, or active/archived lifecycle; requests for those capabilities need separately governed Project schema/UI work. Do not invent new fields. A structural `go` establishes bounded schema and inventory validity only; the Prototype operation always reports `design_system_validation: not_evaluated`.

## Resolve Design System evidence

If the manifest has a nonnull Design System reference, separately run `artifact-status design-system --project-id <id> --company-id <id> --mode working-tree` for the same Project (or its intended committed mode). Require the fresh provider response to have matching identity/selected source and revision, `outcome: go`, `design_system_validation: valid`, and exactly one item. Compare the manifest's `design_system_ref.id` to the item ID and `content_digest` to the provider's complete `inventory_digest`, never its raw `definition_digest`.

For a Project-owned committed system, pin Prototype and provider to the same intended Foundation SHA. Company/default sources use their own explicit full-SHA pins. Working-tree results are exploratory only. A missing/no-go provider, null reference, identity/digest mismatch, or stale revision blocks the version-binding claim, though the Prototype can still be structurally valid. A matching reference does not prove CSS/component use, visual quality, accessibility, behavior, QA, user approval, or publication.

## Report

After writing, rerun the complete Prototype evaluator and `builder-project status --project-id <id> --company-id <id> --artifact-kind prototype --artifact-id <candidate-id>`. Require the requested stable ID among the complete accepted catalog and `state: available`, with its entry and declared files. An empty catalog, missing requested ID, invalid inventory or absent support file is not completed creation; the collection remains all-or-nothing. Keep integrity, Design System version binding, browser behavior, visual fidelity and human approval separate.

Report whether the candidate was created, updated, or deferred; its stable ID and relative paths; mode and full revision; outcome and full inventory digest; Design System version-binding evidence or gap; and what remains unverified. On no-go, report actionable relative diagnostics without implying partial success. Never record human review, approval, or publication for another person.

When a local preview is in scope, provide its consumer only the exact registered Prototype files and Foundation evidence links it needs. Keep the Prototype iframe isolated from viewer-origin privileges, and state that the local preview demonstrates rendering/navigation only; it does not add execution, lifecycle schema, approval or publication authority to the Prototype evaluator.

If the owner explicitly asks to display the candidate in local Builder, hand off to `register-builder-project` after the catalog and declared inventory are ready. Authoring never enrolls automatically; registration is explicit and does not authorize execution, review, or publication.
