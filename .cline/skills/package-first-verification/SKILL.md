---
name: package-first-verification
description: "Guardrail: MUST invoke before implementing any new feature, endpoint, domain, screen, controller, service, or repository. Queries proprietary packages via deterministic CLI tool across three tiers (Local, Ecosystem, External)."
---

# Skill: Package-First Verification

## Purpose
Enforce the package-first architecture by querying proprietary packages via a **deterministic CLI tool** before every implementation. The agent does not read YAML files directly — it runs the script and gets structured results.

## CLI Tool

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> [options]
```

| Option | Purpose |
| :--- | :--- |
| `--all` | List all proprietary packages (ecosystem + local) |
| `--search <term>` | Search by name or description (case-insensitive) |
| `--tier local\|ecosystem` | Filter by tier |
| `--stack flutter\|laravel` | Filter by stack |
| `--unused` | Show local packages that exist but are not in use |
| `--detail <name>` | Full detail including README content |

## Package Tier Model

| Tier | Autonomy | Agent Behavior |
| :--- | :--- | :--- |
| **Local** | Total | Treat as modular code. Modify freely. Breaking changes OK — fix callers in the same PR. |
| **Ecosystem** | High | Can modify, but version and evaluate cross-project impact. Prefer additive changes. |
| **External** | Low | Do not modify. Wrap in adapter if behavior needs to change. |

## When to Invoke
- Before planning implementation of any new feature.
- Before creating a new controller, service, repository, utility, or helper.
- Before adding a third-party dependency.
- When a TODO involves creating new files in `app/Services/`, `app/Helpers/`, `lib/utils/`, or similar host-level utility paths.

## Procedure

### 1. Query Packages
Run the CLI with a keyword relevant to the planned implementation:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"
```

If unsure about keywords, list all:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> --all
```

The script auto-generates `local_packages.yaml` if missing. No manual setup needed.

### 2. Read Details for Relevant Packages
For each package returned, get full details including README:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> --detail "<package_name>"
```

### 3. Evaluate and Decide (Tier-Aware)

| Situation | Local Package | Ecosystem Package | External Package |
| :--- | :--- | :--- | :--- |
| Package covers the need | **Use directly.** Modify API if needed. | **Use directly.** Prefer additive extension. | **Use directly.** Do not modify. |
| Partial match | **Extend.** Breaking changes OK. | **Extend** with additive API. Version bump. | **Wrap** in a local adapter. |
| No match, code is reusable | Create **new local package**. | Propose ecosystem package if cross-project. | N/A |
| Code is host-specific | Implement locally. Document rationale. | N/A | N/A |

### 4. Record the Assessment
Add to the TODO:

```markdown
## Package-First Assessment
- Query executed: bash delphi-ai/tools/query_packages.sh --search "<term>"
- Relevant packages found:
  - [Local] <name> — <action taken>
  - [Ecosystem] <name> — <action taken>
  - [External] <name> — <action taken>
- READMEs read: <list>
- Decision: Use <package> / Adopt <package> / Extend <package> / New package <name> / Local implementation
- Tier: Local / Ecosystem / External
- Rationale: <brief>
```

### 5. Post-Implementation
If a new proprietary package was created:
- [ ] Package has `README.md` following canonical format (`delphi-ai/templates/package_readme_template.md`)
- [ ] Run `bash delphi-ai/tools/verify_package_registry.sh` to update `local_packages.yaml`
- [ ] If ecosystem-level, add entry to `delphi-ai/config/ecosystem_packages.yaml`
- [ ] Verify: `bash delphi-ai/tools/query_packages.sh --detail "<new_package>"`

## Validation
- Package-First Assessment is present in the TODO with query output.
- If a proprietary package was found, the implementation leverages it.
- No new host-level utility files duplicate proprietary package capabilities.
- Local packages are modified directly when needed — no workarounds in host app.
- External packages are never forked without explicit user approval.
