---
name: create-design-system
description: Create or update a Git-backed Design System with explicit ownership, registered files, and deterministic local structural validation.
---

# Create a Design System

Use this skill to author or review a versioned set of design tokens, components, states, variants, examples, and assets. Work only in the source repository explicitly selected for the owning level; never infer ownership from a directory name or merge keys across levels.

## Resolve authority and source

First identify the owner (`project`, `company`, or `default`) and whether the request authorizes changes at that level. Effective fallback is evidence, not permission to mutate a parent. Project → Company → default is whole-source precedence, not a merge. A broken selected source is a no-go; do not fall back. Only the selected source contents are loaded. The local bindings file is a trusted operator assertion, not IAM; do not print it, expose its paths/credentials, or fabricate a binding to bypass a missing source.

Invoke the shared local API from the selected Project checkout using confirmed Project/Company identities only. Obtain the authorized owner's API-owned authoring destination via `context --project-id <id> --company-id <id> --owner-level project|company|default`; supply a confirmed `--default-owner-id` for the default owner when needed. Never ask for storage, Foundation or source-binding paths. Registration is not required for authoring. Resolve the canonical shared Delphi checkout (`DELPHI_ROOT`) independently of the caller's cwd, then read `$DELPHI_ROOT/local-api/contract.md` for the exact v1 binding and definition schemas, owner matching, limits, digest domains, contrast semantics, and operation results. The Project binding must select the chosen Foundation; committed mode requires explicit full lowercase commit SHAs for every non-null source and never infers HEAD or fetches.

Before work and after writing, run the actual launcher with confirmed identities; the API resolves its private source map:

```sh
"$DELPHI_ROOT/local-api/run" artifact-status design-system \
  --project-id '<project-id>' --company-id '<company-id>' --mode working-tree
```

A stored default owner is resolved internally; provide `--default-owner-id '<default-owner-id>'` only when its confirmed identity is missing. Missing private bindings are an API/Delphi initialization gap, not a request for paths.

Use fresh stdout only. Working-tree mode is a mutable observation; committed mode validates exact pinned trees. Exit 0 is structural `go`; exit 2 is structured `no_go`; 64 is invocation error; 70 is infrastructure error. Do not consume old output after a nonzero infrastructure result. If the source/map is missing or invalid, report the gap; do not create a real source merely to make validation green.

## Author a coherent system

Write `design/system/design-system.json`, Markdown `guide.md` and HTML `examples.html` in the authorized owner's API-provided destination, with component/asset files declared in the existing definition. A request to create the system authorizes this output; missing prior artifacts do not justify placeholders or fabricated bindings. Start with purpose, audience, owner, and existing material. Preserve stable IDs on updates. Declare unique tokens/components and component-local state/variant IDs. Supported token values are opaque `#RRGGBB` colors, finite numbers, or bounded strings; references resolve within the same definition, iteratively, without cycles or type changes. Do not use expressions, execute examples, or inherit values from another source.

Register components with their token IDs, states, variants, documentation, examples, and assets. Paths are relative to the selected definition's parent directory. The declared set must equal the complete discovered regular-file inventory: include every managed file, no extras or orphan directories, and no path collisions. Contrast pairs are only the declared opaque-sRGB checks; the evaluator compares unrounded WCAG relative-luminance ratios. Zero pairs means zero checks, not an accessibility pass.

Resolve every diagnostic and rerun against the exact source and mode intended for handoff. Check the requested owner's item, standard definition/guide/examples and complete declared inventory; inherited availability alone does not prove that a new Project system was created. For a Project system, also require fresh `builder-project status --project-id <id> --company-id <id> --artifact-kind design-system` to report its standard output available. A missing standard file means creation is incomplete even when a legacy inventory is structurally valid. Require the complete response context, selected identity/owner and revision to match, `outcome: go`, `design_system_validation: valid`, and exactly one item. Downstream references use the item's full `inventory_digest`, not `definition_digest`; changes to support files invalidate the former. A structural pass does not approve aesthetics, usability, broad accessibility, execution, review, preview, or publication.

The root `guide.md` must be declared as component documentation or an asset, including for a token-only system. Give it nonempty `## Overview`, `## Foundations`, and `## Components` sections, each exactly once and in that order, outside code fences. Additional Project-specific sections are welcome. Present the existing provider's `code`, `message`, and `resolution` diagnostics as TEACH; its guide-structure result is the sole deterministic catalogue gate. This is navigation structure, not visual approval.

## Consumer references and report

Before a conformance/version-binding claim, compare the consumer's stable Design System ID and full inventory digest to the fresh provider result at the intended revision. A match binds version only; it does not prove that consumer code uses tokens or components. Project, Company, and default revisions remain separately identified.

Report the owner, selected source identity/revision, mode, stable system ID, outcome, full inventory digest, registered paths, declared contrast-pair count, meaningful visual decisions, and unresolved questions. Keep private binding data private. Do not claim this local operation renders, authenticates, provisions a Company source, publishes, or changes a remote API.

## Local preview handoff

Keep the Design System definition, guide, examples, and registered assets in the selected owner's source. A local preview consumer may render only the files it explicitly admits, and should link back to this source and its Foundation evidence. Registration and a matching inventory digest establish source integrity/version only; they do not certify that a separate consumer visually conforms. Missing Company or default sources remain explicit gaps and do not prevent authoring an independently selected Project system when that Project owns the change.

If the owner explicitly asks to display this source in local Builder, hand off to `register-builder-project` after the selected source binding and declared inventory are ready. Authoring and initialization do not enroll Projects automatically; registration requires explicit context and consent, and never implies review or publication.
