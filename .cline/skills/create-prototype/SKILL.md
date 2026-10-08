---
name: create-prototype
description: Create or update a Project Prototype candidate and validate its local structural inventory without claiming conformance or publication.
---

# Create a Prototype

A Prototype is a versioned, inspectable source artifact, not an executed or published application. Use this skill for a candidate in an explicitly selected Project. Resolve the canonical shared Delphi checkout (`DELPHI_ROOT`) independently of the caller's cwd, then read `$DELPHI_ROOT/local-api/contract.md` for the exact catalog, manifest, inventory, reference, and response schemas.

## Inspect before authoring

Invoke from the selected Project checkout. Obtain its API-owned authoring destination using `$DELPHI_ROOT/local-api/run context --project-id <id> [--company-id <id>]`; never ask for storage, repository or Foundation paths. Read relevant managed documents and inspect the current catalog with `$DELPHI_ROOT/local-api/run artifact-status prototypes --project-id <id> --mode working-tree`. Registration is not required. Use that invocation's fresh stdout, not a saved snapshot. Check response identity, target, authority scope, mode, revision, outcome, items, diagnostics, and `design_system_validation`.

If the catalog or provider is absent, report that gap. An explicit creation request may create the standard catalog and candidate; never create placeholders merely to make a check green. Keep unapproved exploration outside the managed `prototypes/` tree. Before changing a managed candidate, confirm that its owner approved the governing scope and requested mutation; a request to create a concept or a structural `go` result is not itself authorization.

## Authoring modes, Screens and States

Choose and record exactly one mode in `authoring_mode`: `image_first` explores a composition with images, validates the selected direction, then implements it in navigable HTML/JavaScript; `design_system_first` applies the effective Design System directly in the implementation. If an implemented element diverges from the selected Design System, explicitly evaluate whether to align the Prototype or request a separately authorized Design System change. Image approval alone never authorizes a Design System change. Report a missing or unusable Design System as a gap.

Give each Screen a stable ID, one HTML path, `scope: null`, a `default_state_id`, and one or more nested States. State IDs are stable within their Screen; a State is not a separate Screen. Group related fields into a Screen or meaningful group according to the Project context; screen granularity is interpretative, with no arbitrary field-count target or evaluator rejection for grouping choices. Set `entry_point` to one of the declared Screen paths so the default entry and Builder's selected Screen agree. Give every State a concise name and an `identifier_image` that is an actual browser capture of that implemented state. Do not use an exploratory mock, generated illustration, or stale image as an implementation capture. Declare identifier images in `assets`.

Implement state selection using the same Screen HTML path with `?prototype_state=<state-id>`. The viewer and standalone link use the same immutable snapshot and this query parameter. Make the default State render when the parameter is absent or equals the default ID. List Screen/state transitions explicitly with source Screen/State, an action label, and target Screen/State; do not make the viewer infer them by parsing HTML.

Prototype HTML presents the product interface and its real interactions only. Do not add a second reviewer menu, Scenario selector, review toolbar, or mock-device shell unless that is genuinely part of the product being prototyped. Builder owns review controls and viewport presentation.

Keep unapproved visual explorations outside the managed `prototypes/` tree; they may be discarded. Store only visual references the human owner explicitly approved. Each `approved_references` row has a stable State-local ID, an image path in `assets`, and an `approval_evidence` Foundation path also listed in `related`. The evaluator checks structure and safe admission only: the author must confirm approval with its owner, and neither the field nor a successful structural check independently proves approval or visual fidelity.

## Build a bounded candidate

Write the v3 `prototypes/catalog.json` and direct-child `prototypes/<candidate>/` root in the API-owned destination. The catalog record includes `status: active|archived`; archival retains discoverability and does not grant approval. The matching `prototype.json` uses `schema_version: "3"`, `authoring_mode`, `entry_point`, `screens`, `sources`, `assets`, `transitions`, required nonnull `scenarios` (`[]` when none are authored), `related`, and explicit `design_system_ref` (null or `{id,content_digest}`). Preserve stable IDs when updating; do not infer identities from folder names. Entry point and Screen paths must be declared sources. Identifier/reference images must be declared assets. Sources and assets are unique and disjoint. Transition endpoints must identify declared Screen/State pairs. Related paths are Foundation-root-relative evidence, not authorization or compatibility proof.

Keep drafts outside the managed inventory. The structural evaluator does not execute HTML/JavaScript or inspect image contents. Locally render each Screen and State, exercise declared navigation and verify that the query-selected state matches its identifying capture. Do not fetch remote Git, publish assets, create product routes or enroll the Project without separate authorization. Use only intentionally admitted sources/assets. Schema v3 is authoritative; there is no v1 or v2 reader or compatibility writer. For legacy v2 source, run fresh Prototype status, adapt every offending catalog and manifest (including archived candidates), verify the complete collection is `go`, and only then refresh registration. A structural `go` establishes bounded schema and inventory validity only; the Prototype operation always reports `design_system_validation: not_evaluated`.

## Resolve Design System evidence

If the manifest has a nonnull Design System reference, separately run `artifact-status design-system --project-id <id> --company-id <id> --mode working-tree` for the same Project (or its intended committed mode). Require the fresh provider response to have matching identity/selected source and revision, `outcome: go`, `design_system_validation: valid`, and exactly one item. Compare the manifest's `design_system_ref.id` to the item ID and `content_digest` to the provider's complete `inventory_digest`, never its raw `definition_digest`.

For a Project-owned committed system, pin Prototype and provider to the same intended Foundation SHA. Company/default sources use their own explicit full-SHA pins. Working-tree results are exploratory only. A missing/no-go provider, null reference, identity/digest mismatch, or stale revision blocks the version-binding claim, though the Prototype can still be structurally valid. A matching reference does not prove CSS/component use, visual quality, accessibility, behavior, QA, user approval, or publication.

## Report

After writing, rerun the complete Prototype evaluator and `builder-project status --project-id <id> --company-id <id> --artifact-kind prototype --artifact-id <candidate-id>`. Require the requested stable ID among the complete accepted catalog and `state: available`, with its entry and declared files. An empty catalog, missing requested ID, invalid inventory or absent support file is not completed creation; the collection remains all-or-nothing. Keep integrity, Design System version binding, browser behavior, visual fidelity and human approval separate.

Keep creation status separate from registered Builder currency. Requested Prototype `available` means the current catalog/candidate is structurally admitted. If Builder readiness for an already registered Project is in scope, run full `builder-project status`; it compares current admitted files/metadata with the saved snapshot while ignoring timestamps and review/origin observations. A mismatch leaves the authored Prototype structurally complete but Builder `not_ready`; follow the API's TEACH action to explicitly refresh the matching registration, then check status again. Correct invalid source or access problems before refreshing. Structural availability alone does not prove Builder serves the current Prototype.

Report whether the candidate was created, updated, or deferred; its stable ID and relative paths; mode and full revision; outcome and full inventory digest; Design System version-binding evidence or gap; and what remains unverified. On no-go, report actionable relative diagnostics without implying partial success. Never record human review, approval, or publication for another person.

When a local preview is in scope, provide its consumer only the exact registered Prototype files and Foundation evidence links it needs. Keep the Prototype iframe isolated from viewer-origin privileges, and state that the local preview demonstrates rendering/navigation only; it does not add human approval or publication authority to the Prototype evaluator.

If the owner explicitly asks to display the candidate in local Builder, hand off to `register-builder-project` after the catalog and declared inventory are ready. Authoring never enrolls automatically; registration is explicit and does not authorize execution, review, or publication.
