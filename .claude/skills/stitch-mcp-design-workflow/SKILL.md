---
name: stitch-mcp-design-workflow
description: Use whenever the user wants UI exploration, concept screens, design-system changes, or screen variants through the Stitch MCP. Guides project/screen discovery, safe tool sequencing, prompt shaping, ID handling, and fallback strategies when Stitch rejects generation in an existing project.
---

# Stitch MCP Design Workflow

## Purpose
Use the Stitch MCP deliberately for UI exploration and design iteration without guessing tool contracts.

This skill is for:
- exploring UX alternatives before implementation;
- generating new concept screens;
- editing existing Stitch screens;
- creating or applying design systems;
- evaluating IA/navigation patterns visually without touching product code.

## Core Rules
- Start read-only whenever possible: inspect projects/screens first.
- Prefer an existing project only when the user explicitly references that project or screen.
- For speculative exploration, prefer an isolated exploration project so you do not mutate the user's main design workspace.
- Treat `create_project`, `generate_screen_from_text`, `edit_screens`, `generate_variants`, `create_design_system`, `update_design_system`, and `apply_design_system` as mutating operations that require deliberate sequencing.
- Do not blindly retry `generate_screen_from_text` or `edit_screens` on timeout or connection error. The Stitch docs explicitly warn that the operation may still succeed. For any other mutating tool, inspect resulting state before retrying.
- A Stitch exploration does not authorize product implementation. Keep design exploration and code changes separate unless the user asks for both.

## Official Tool Map
Read-only tools:
- `list_projects`
- `get_project`
- `list_screens`
- `get_screen`
- `list_design_systems`

Mutating tools:
- `create_project`
- `generate_screen_from_text`
- `edit_screens`
- `generate_variants`
- `create_design_system`
- `update_design_system`
- `apply_design_system`

## ID Handling
Use the exact ID format each tool expects.

- `list_projects` returns names like `projects/123...`.
- `get_project` expects full resource name: `projects/{project}`.
- `list_screens` expects bare `projectId` only, without `projects/`.
- `get_screen` expects:
  - full `name`: `projects/{project}/screens/{screen}`
  - bare `projectId`
  - bare `screenId`
- `selectedScreenIds` must use bare screen IDs, without `screens/`.
- `apply_design_system` uses `selectedScreenInstances`, which come from `get_project`, not `list_screens`.

If the user gives a screen title but not an ID:
1. `list_projects`
2. choose the right project
3. `list_screens`
4. map title -> screen ID
5. only then mutate.

## Default Workflow
### 1. Inspect before mutating
Use this sequence first unless the user explicitly wants a brand-new project:
1. `list_projects`
2. `get_project` if needed for screen instances / project metadata
3. `list_screens`
4. `get_screen` for the exact reference screen

### 2. Choose the right generation path
Use:
- `generate_screen_from_text` when creating a new concept screen from scratch.
- `edit_screens` when refining an existing screen in-place.
- `generate_variants` when exploring alternatives of an existing screen.

Decision rule:
- If the user wants to preserve the current screen and just evaluate ideas, prefer `generate_variants`.
- If variants/editing fail or the request is exploratory and disposable, create a separate exploration project and use `generate_screen_from_text`.
- If the user wants the existing project updated, use `edit_screens`.

### 3. Write prompts with explicit constraints
Prompt structure should be concise and concrete:
- base context: which project/screen is the inspiration;
- product intent: what behavior or IA you are testing;
- preserve: what must remain unchanged;
- forbid: what must not happen;
- emphasis: what to optimize for.

Good prompt skeleton:
- "Use `<screen>` as visual inspiration."
- "Explore `<goal>`."
- "Preserve `<layout/language/system>`."
- "Do not add `<forbidden pattern>`."
- "Optimize for `<clarity / low cognitive load / editorial tone / mobile-first>`."

### 4. Handle generation failures pragmatically
If Stitch returns `Request contains an invalid argument` or a similar rejection:
- do not loop retries on the same payload;
- simplify the prompt;
- remove optional parameters first;
- if the failure is tied to an existing project/screen, move to an isolated exploration project;
- report the limitation clearly to the user.

Known practical fallback:
- existing-project variant/edit generation may fail even when read-only inspection works;
- isolated `create_project` + `generate_screen_from_text` is a valid fallback for UX evaluation.

## Design System Workflow
Use this flow when the user wants visual theme/system work:
1. `list_design_systems` to inspect existing systems.
2. `create_design_system` only if a new system is required.
3. Immediately call `update_design_system` after `create_design_system`.
   - This is explicitly required by the Stitch tool contract.
4. `apply_design_system` to specific screen instances when the user wants the system applied visually.

Do not apply a design system blindly to all screens unless the user asked for that scope.

## Output Handling Rules
### `generate_screen_from_text`
If `output_components` contains:
- generated design/screens: summarize the created screen names and project.
- text suggestions/questions: present them to the user.
- a suggested follow-up prompt: if the user accepts it, rerun `generate_screen_from_text` with that accepted prompt.

### `generate_variants`
After variant generation:
- inspect the project/screens again so you can name what was created;
- summarize the UX pattern differences, not just the fact that variants exist.

## Reporting Back to the User
Always report:
- which project was used or created;
- which screen was used as reference;
- whether the result was in-place or exploratory;
- the UX pattern you explored;
- whether the Stitch tool succeeded directly or required fallback.

For UX evaluation, include a short recommendation such as:
- strongest option;
- why it avoids polluting the main filters;
- what tradeoff remains.

## Practical Patterns
Use these patterns when the user wants "favorites without polluting filters":
- a personal lens entered from a subtle header affordance;
- a saved-items shelf that expands into a dedicated view;
- a profile-owned or collection-owned entry point;
- a dedicated saved/favorites destination separate from the taxonomy/filter bar.

Avoid these patterns unless the user explicitly asks for them:
- adding another permanent chip beside the main discovery filters;
- collapsing personal state into the global taxonomy language;
- mutating the main production-aligned project just to test speculative IA.

## Validation
After creating/editing designs:
- confirm the created project/screen IDs;
- use `list_screens` or `get_screen` to verify the output exists;
- if the action was exploratory, keep the result isolated and clearly labeled as such.
