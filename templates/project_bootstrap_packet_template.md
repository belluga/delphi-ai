# Template: Genesis Bootstrap Packet

Use this optional template when a project is still in zero-state and Delphi needs a lightweight working artifact before the first canonical docs exist.

This packet is a **capped Genesis artifact**. It is not a tactical TODO, approval gate, or implementation plan, and maintaining it does not by itself change the active profile out of `Genesis / Product-Bootstrap`.

- Its job is to collect the minimum discovery and prototype evidence needed to instantiate:
  - `foundation_documentation/project_constitution.md`
  - `foundation_documentation/system_roadmap.md`
  - `foundation_documentation/modules/*.md`
- When the session needs a live tracked ledger of open decisions or interview fronts, that live ledger should default to a profile-scoped capped TODO under `foundation_documentation/todos/active/` (for example via `templates/capped_todo_template.md`), while this packet remains the higher-level snapshot/reference companion.
- It may continue to act as the active Genesis decision ledger while the foundation interview is still refining business concepts, as long as it remains explicitly no-code.
- After those canonical docs exist and Genesis refinement is complete, promote durable truth into them and retire or archive this packet.
- Do not use this packet as a generic sink for stable truths whose final canonical home is already clear. After each answered Genesis interview turn, either promote the stabilized content into its correct artifact or keep it here/TODO explicitly as unresolved.
- If an item is clearly module-local but the module boundary is not ready yet, record the intended future home instead of parking that fact in `project_mandate.md` or leaving it here indefinitely.

## 0. Artifact Role

- **Active profile:** `Genesis / Product-Bootstrap`
- **Current Genesis phase:** `<GEN-01|GEN-02|GEN-03>`
- **Purpose in this session:** `<why this packet exists right now>`
- **What it is not:** `<tactical TODO / approval gate / implementation plan>`
- **Code-touch boundary:** `no code`

## 1. Initial Intent

- **Project idea:** `<what is being created>`
- **Primary user or buyer:** `<who this is for>`
- **Desired outcome:** `<what success looks like>`
- **Known constraints:** `<time, domain, regulatory, platform, budget, team, or unknown>`

## 2. Discovery Snapshot

- **Confirmed truths:** `<facts already supported by user evidence, research, or observation>`
- **Assumptions:** `<working assumptions that still need validation>`
- **Open questions:** `<questions that materially affect architecture, scope, or UX>`
- **Decision-critical risks:** `<what could invalidate the direction>`

## 3. Prototype & Validation

- **Prototype surface:** `<Stitch|web prototype|screens|wireframes|none yet>`
- **Flows to validate:** `<core journeys or decisions that need validation>`
- **Validated findings:** `<what the prototype or review confirmed>`
- **Rejected findings:** `<what was disproven or removed>`
- **Still unclear:** `<what the prototype did not answer>`

## 4. Canonical Bootstrap Targets

- **Project constitution topics to instantiate:** `<cross-module rules, topology, invariants, ownership>`
- **Initial modules to create:** `<module names + short responsibility>`
- **Roadmap framing:** `<initial stages, sequencing, follow-up fronts>`
- **Coverage expectation:** `<what may remain partial after bootstrap>`

## 5. Genesis Decision Register

| ID | Topic | Current State | Why It Matters | Next Interview Target |
| --- | --- | --- | --- | --- |
| `G-01` | `<topic>` | `<Open|Partial|Deferred|Closed>` | `<why it matters now>` | `<what the next question should close>` |

## 6. Handoff Readiness

- **Ready to create canonical docs:** `<yes|no>`
- **Ready for strategic maintenance after bootstrap:** `<yes|no>`
- **Ready for tactical TODO / implementation:** `<yes|no>`
- **Next exact step:** `<single next action>`
