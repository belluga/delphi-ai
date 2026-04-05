# Template: Tool Manifest

Use this file as a starting point for a canonical deterministic-tool inventory, typically at `tools/manifest.md`.

This manifest is an index, not a backlog or a changelog.

- Create/update it when the project has reusable scripts or helper tools that an agent might duplicate by accident.
- Check it before creating a new deterministic helper script.
- Update it in the same change when a canonical tool is added, removed, renamed, or repurposed.

## Scope
- **Manifest owner:** `<repo or package>`
- **Covered directory/directories:** `<tools/** or equivalent>`
- **What is excluded:** `<thin wrappers, generated files, external vendor tools, etc.>`

## Rules
- Each listed tool must have one stable, concrete job.
- Descriptions should say what the tool does, not how to think about it.
- If a tool’s contract is non-obvious, add a short `Notes` column entry instead of expanding the description.

## Tool Inventory

| Path | Type | Purpose | Notes |
| --- | --- | --- | --- |
| `tools/<tool-name>.sh` | `<shell|python|node|other>` | `<single-sentence deterministic job>` | `<inputs, constraints, or n/a>` |
