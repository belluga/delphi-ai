---
name: create-executive-landing
description: Create or review an executive Landing with evidence-linked decisions, clear visual direction, and truthful project status.
---

# Create an Executive Landing

Create a concise, relevance-led Landing for executives and other non-specialist readers. Explain why the work matters, the confirmed decisions behind it, its actual state, and the next meaningful direction. Keep facts, plans, and open questions distinct; cite material claims to their canonical owner. A Landing is a navigational summary, not a second source of truth.

## Establish ownership and evidence

Classify the request as a Project Landing or Company portfolio/proposal before selecting sources, tools, a Design System, or visual direction. Keep the branches separate throughout research and output. For mixed requests, prepare separately scoped outputs.

- A Project Landing uses only the explicitly selected Project Foundation and current sources: `project_mandate.md`, `domain_entities.md`, `project_constitution.md`, `system_roadmap.md`, and relevant policy/module Markdown.
- A Company proposal uses only Company evidence explicitly supplied for that request. Keep it a manual draft and identify missing Company evidence or authority as a gap. Never invoke Project-bound knowledge operations as evidence for a Company claim or substitute Project/default output for missing Company evidence.

Author a Project Landing only in the selected Project's authoritative Foundation already established by Project/Delphi context; its paths below are relative to that Git root. If that authority is ambiguous or absent, stop with TEACH instead of guessing a folder or asking for an API write path. Invoke the shared local API from the selected Project checkout with confirmed Project/Company identities only; registration is not required for authoring. Resolve the canonical shared Delphi checkout (`DELPHI_ROOT`) independently of the caller's cwd, then read `$DELPHI_ROOT/local-api/contract.md` for Knowledge fields, selectors, packet binding, and result semantics. These local operations are operator-context assertions, not ownership proof, IAM, publication, or remote freshness attestation. Never infer facts, dates, metrics, approval, or delivery from a stale snapshot, image, or structurally valid artifact.

For the selected Project, obtain fresh Knowledge status and Landing integrity status before work and again after writing:

```sh
"$DELPHI_ROOT/local-api/run" knowledge-status status --project-id '<project-id>'
"$DELPHI_ROOT/local-api/run" builder-project status \
  --project-id '<project-id>' --company-id '<company-id>' --artifact-kind landing
```

Use only this invocation's stdout. If Landing is `review_required` or unverifiable, state the gap. When a committed revision is needed, invoke `"$DELPHI_ROOT/local-api/run" knowledge-status review-packet --target landing` with the same Project identity, then inspect its full revision and packet/source/document digests against the named sources. A packet is not approval. `record-review` is a separate human action: do not run it during authoring or infer approval from a reference string. Record only after explicit approval of that exact packet, with its exact full revision and packet digest and the authorized reviewer/reference values.

For a Project Landing's effective Design System, use fresh `artifact-status design-system --project-id <id> --company-id <id> --mode working-tree` stdout; source bindings are private API context. Require the response context and selected owner to match, `outcome: go`, `design_system_validation: valid`, and exactly one item. In committed mode, the selected Project definition must be pinned to the intended Landing Foundation revision; Company/default fallbacks use separate explicit full-SHA pins. Selection is whole-source Project → Company → default; a broken selected source never falls back. The response's inventory digest covers the full managed source, unlike the raw definition digest. A Prototype reference binds a version only; it does not prove use, visual consistency, accessibility, QA, review, or publication.

## Visual direction and composition

For a substantive new or redesigned Landing, explore materially different compositions with the available image-generation capability before implementation. Compare hierarchy, section flow, emphasis, and executive scanability; record the selected direction and meaningful rejected alternatives. Reuse an existing concept only if it belongs to the same owner and still fits the audience and evidence. Minor copy/source corrections do not need new exploration. If image generation is unavailable, provide a clearly labeled textual composition draft and state that limitation.

Exploration images communicate composition, not documentary evidence or finished production assets. Check displayed facts against canonical sources. A visual choice does not approve a review packet. Lead with relevance and outcome, then decisions, actual status, meaningful progress, next direction, and unresolved questions. Keep implementation detail subordinate to executive consequence; preserve responsive reading order, keyboard/focus semantics, and text alternatives in downstream requirements.

## Authoring and local handoff

When the Project requests an actual visual Landing, produce responsive HTML and its stylesheet at `design/landing/index.html` inside that Project Foundation, plus a Markdown evidence note with links to the canonical sources. Keep the Foundation Landing and manifest as the canonical executive content and source record; the visual artifact is a rendered expression of that content, not a competing authority. Record generation time, exact source paths, effective Design System identity/version, and the hash encoding used for each digest. Landing source hashes and artifact inventory hashes may use different encodings; never compare or relabel them as interchangeable. A Company proposal remains a separate manual draft and never gains a Project Foundation write target by this instruction.

Write canonical `project_landing.md` and `project_landing.manifest.json`, declaring the HTML, CSS/assets and required evidence using the existing schema. After writing, require fresh requested-Landing status to contain `state: available` and its declared entry/files **from the same selected Foundation**. The provisional local launcher's documented unregistered standard `foundation_documentation` convention establishes that match only when it is the Project's authoritative Git root and no different private binding applies. Otherwise use independently matchable source identity/revision/digest evidence if the operation exposes it; `go`, Project ID or an opaque registered binding alone is insufficient. If the source cannot be proven or differs, report API verification `unverifiable` with TEACH; keep authored-file evidence separate, never redirect writes to the status source, and do not claim Builder admission. Missing or invalid files mean creation is incomplete; Knowledge freshness/review and browser fidelity remain separate checks. Never treat a registered Project or matching documentary hash as proof that HTML was created.

Use direct Foundation links for canonical evidence. A local preview may expose only files explicitly admitted by its consumer inventory; authoring a file does not publish it or broaden an anonymous catalog. Keep locally generated pages separate from the generic Foundation Markdown view, and make each source/navigation link resolve to its admitted evidence entry. A missing origin or review record remains missing, and a source change requests review without implying the prose or visual artifact is wrong. Never create or update a human-review marker.

Keep creation status separate from registered Builder currency. A fresh requested-Landing `available` result describes the API-bound source; it describes the authored Landing only after the same-Foundation check above. If the Project is already registered and Builder readiness is in scope, run full `builder-project status`; it compares current admitted files/metadata with the saved snapshot while ignoring timestamps and review/origin observations. A mismatch leaves that API-bound Landing structurally admitted but Builder `not_ready`; follow the API's TEACH action to explicitly refresh the matching registration only after source equivalence is established, then check status again. Correct invalid source or access problems before refreshing. Do not treat structural availability alone as proof that Builder serves the authored Landing.

When the owner explicitly requests local Builder integration, hand off to `register-builder-project` after the manifest and declared Landing inventory are ready. Registration is optional, requires fresh status and explicit consent when absent, and does not imply visual approval or publication. Never register automatically as part of authoring.

## Approved-reference fidelity gate

When a visual reference has been approved, fidelity to that image is a delivery criterion, not optional inspiration. Preserve its composition, visual hierarchy, relative proportions, typography, spacing, section rhythm, palette, and the character of its illustrations. Implement the approved direction rather than redesigning it during coding. A flat schematic is not an equivalent replacement for a dimensional illustration merely because both convey the same concept.

Before declaring the visual Landing ready:

- Identify the exact approved image and inspect it alongside screenshots of the actual browser-rendered artifact, at a comparable desktop width and through its intended preview surface. Check the full page, not only the hero. Also inspect a narrow mobile viewport; responsive reflow must retain hierarchy and visual character without clipping, overlap, or unreadable labels.
- Compare the main composition and focal artwork first, then title wrapping and scale, content density, section proportions, imagery, and component details. Minor differences from font rendering, browser behavior, or responsive adaptation are acceptable only when they preserve the approved visual result. Shared colors or working navigation alone do not establish fidelity.
- Record the reference and screenshot paths, material discrepancies, and the comparison outcome in the existing evidence note. Correct material discrepancies and capture the rendered result again before reporting visual readiness. Functional tests, valid manifests, source hashes, and successful builds do not substitute for this visual comparison.
- If the approved design cannot be reproduced within the available assets, Design System, or implementation constraints, state that limitation and request approval for the specific visual departure. Do not silently simplify away its defining features or claim fidelity without inspecting the rendered result. This comparison does not create a human-approval or documentary-review marker.

## Report and boundaries

For a Project, identify its Foundation revision, canonical sources, fresh local review state, effective Design System source/revision and full inventory digest when available, selected visual direction, authored artifact paths, source/hash encoding, and remaining gaps. For a Company proposal, identify only supplied Company evidence and separately supplied design direction; do not include Project-derived status, revision, Design System, or concept claims. Do not publish, broaden an anonymous catalog, or present unavailable capabilities as delivered. When an input, binding, status, authority, or capability is missing, stop that claim and state the next evidence needed.
