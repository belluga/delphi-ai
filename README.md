# Delphi-AI Setup Guide

## Purpose
Centralized instructions to attach Delphi-AI (bootloaders, methods, templates) to any project repo.

## What Delphi-AI Is
Delphi-AI is not a prompt bundle. It is a working method for AI-assisted delivery that combines:

- bootloaders per agent
- environment/readiness checks
- rules, workflows, and skills
- tactical TODO-driven execution
- adherence and validation gates
- promotion of stable outcomes into canonical documentation

The goal is not to let an agent "just code". The goal is to make execution reviewable, resumable, and less likely to drift away from architecture, contract, and verification.

## Profiles
Delphi separates its operating roles into **profiles**, not stylistic personas.

- **Genesis**
  - `Product-Bootstrap`
- **Strategic**
  - `CTO-Tech-Lead`
- **Operational**
  - `Coder`
  - `DevOps`
- **Assurance**
  - `Tester-Quality`
  - `Security-Adversarial`

Profiles are paired with a technical scope such as `flutter`, `laravel`, `docker`, or `cross-stack`.

This separation is intentional:
- the genesis profile may start from zero-state, but it must hand ongoing governance to the canonical Delphi surfaces it creates;
- the delivery profile should not be able to quietly rewrite the gates that validate its own work;
- the strategic profile should not silently turn into an implementation profile;
- assurance profiles should try to invalidate the delivery, not quietly absorb the delivery itself.

## Method Positioning
Delphi-AI follows a **governed, distributed spec-driven execution model**.

When a project is still in zero-state, Delphi may begin with `Genesis / Product-Bootstrap`.

- zero-state means the project may not yet have `project_constitution.md`, `system_roadmap.md`, module docs, or TODOs;
- the genesis profile may work from interviews, references, and prototypes (including Stitch or disposable web prototypes);
- its job is to instantiate the first canonical Delphi package, not to become the long-term owner of delivery.

Instead of concentrating all intent in a single spec file, Delphi distributes authority across four explicit surfaces:

- `foundation_documentation/project_constitution.md`
  - project-specific system constitution: inter-module rules, cross-stack invariants, system topology, and approved deviations from the inherited Delphi baseline
- `foundation_documentation/system_roadmap.md`
  - strategic direction, stages, sequencing, and cross-stack follow-up
- `foundation_documentation/modules/*.md`
  - durable canonical truth: contracts, flows, schemas, invariants, and stable decisions
- `foundation_documentation/todos/active/*.md`
  - tactical execution contract for one change: scope, out-of-scope, done criteria, validation steps, frozen decisions, assumptions, plan, and adherence proof

Delphi may also use auxiliary non-authoritative surfaces when they improve execution discipline without replacing the canonical docs above:

- `tools/manifest.md`
  - inventory of deterministic helper tools so scripts are reused instead of recreated
- `skills/deterministic-tooling-register.md`
  - internal Delphi register that classifies canonical skills as `skill-only`, `lint/analyzer`, `partial-tool`, `full-tool-candidate`, or `already-backed`, and links any existing deterministic support
- `foundation_documentation/artifacts/dependency-readiness.md`
  - non-blocking record of external dependency health, verification method, and workarounds
- `foundation_documentation/artifacts/session-memory.md`
  - bounded continuity memory for recent session state, confirmed preferences/behaviors, and dependency references; never a substitute for canonical docs or TODO handoffs

This means Delphi is neither code-first nor a loose "vibe coding" loop. Once the canonical package exists, the normal path is:

1. load the right instructions and verify readiness
2. refine the tactical TODO (`WHAT` and what counts as done)
3. build assumptions and an execution plan (`HOW`)
4. review the plan for architecture, tests, performance, and security
5. request explicit approval (`APROVADO`)
6. ingest the rules/workflows that govern the touched surfaces
7. implement, with test-first/TDD when behavior is verifiable
8. validate decision adherence, module coherence, security risk, and verification debt
9. promote stable outcomes back into canonical docs

When the work crosses profile boundaries, Delphi records that handoff in the tactical TODO instead of relying on implicit session memory.

In practice, this makes Delphi close to Spec-Driven Development, but with **distributed authority by responsibility** rather than one feature-spec artifact:

- project constitution = system-specific constitutional spec
- roadmap = strategic spec
- module docs = durable canonical spec
- tactical TODO = executable change spec

## SDD + TDD
Delphi should be read as a combination of:

- **SDD** for defining the contract of the work
- **TDD / test-first** for proving that the implementation actually satisfies that contract

In Delphi terms:

- project constitution, roadmap, module docs, and the tactical TODO define what must be true
- assumptions and the execution plan define how the current implementation intends to get there
- tests provide executable feedback that the promised behavior is real

This split matters because the two layers solve different failure modes:

- spec-driven execution reduces direction error
- test-first execution reduces implementation error and false confidence

## How Delphi Works
The core idea is simple:

- the TODO defines **what** must be delivered and what counts as done
- assumptions and the execution plan define **how** Delphi currently intends to deliver it
- implementation is not authorized until the contract, assumptions, plan, and approval line up
- delivery is not complete until the result is validated and stable knowledge is promoted out of tactical notes

This is why the framework puts so much weight on:

- evidence-backed assumptions instead of free guesses
- explicit approval before implementation
- module-first coherence checks
- test strategy recorded inside the plan
- test-first/TDD when behavior can be verified early
- explicit closing checks for security risk and verification debt

## What Delphi Borrowed From GSD
Delphi absorbed a few ideas from Get Shit Done because they improve execution ergonomics:

- make assumptions explicit instead of leaving them implicit in the plan
- expose the difference between contract and execution strategy
- prefer operational clarity over hidden agent reasoning

But Delphi intentionally does **not** adopt the full GSD shape. It does not center work around:

- `STATE.md`
- a phase-centric artifact stack
- extra planning surfaces that compete with roadmap, modules, and tactical TODOs

The tactical TODO remains the execution authority, and durable truth remains in canonical docs.

## Profiles and Scope Checks
Delphi profiles are backed by explicit scope boundaries.

- `Genesis / Product-Bootstrap` owns project inception, prototype-backed validation, and first-pass canonicalization.
- `Operational / Coder` owns product behavior and tests.
- `Operational / DevOps` owns CI/CD, runtime, ingress, and promotion-lane mechanics.
- `Strategic / CTO-Tech-Lead` owns constitution, roadmap, and cross-module direction.
- `Assurance` profiles own challenge and validation, not silent takeover of delivery.

Deterministic scope checks can be run with:

```bash
python3 delphi-ai/tools/profile_scope_check.py --profile <profile-id>
```

The check validates touched surfaces only. It does not try to infer whether mixed-scope changes came from a valid handoff, so those cases must be reconciled against the TODO handoff log.

## Where TDD Fits
Delphi now treats test strategy as part of the execution plan, not as an afterthought.

For behavior that is verifiable, the preferred path is test-first:

- the TODO and module docs define what must be true
- tests provide executable proof of that contract
- implementation is driven by those checks instead of by plausibility alone

This is especially important for bugfixes, regressions, compatibility-sensitive work, and behavior-defining UI/API changes, where false confidence is expensive.

## Supported AI Tools

| Tool | Bootloader | Artifacts |
|------|------------|-----------|
| **Cline** | Auto-loads `.clinerules/` | `.clinerules/`, `.cline/skills/` |
| **Codex/Antigravity** | `AGENTS.md` | `.codex/skills/`, `.agents/` |
| **Gemini** | `GEMINI.md` | `.agents/skills/` directory |

## Quick Setup

### Option 1: Full Setup (Recommended)
Optional preflight before making changes:
```bash
bash delphi-ai/init.sh --check
```

Run the setup helper from the project root:
```bash
bash delphi-ai/init.sh
```
- In non-interactive environments, the helper reuses the current `.gitmodules` URLs unless `DELPHI_*_URL` overrides are provided.
- Prompts for Laravel/Flutter/Web submodule URLs (defaults to current entries).
- Creates the documented bootloaders/symlinks for Cline, Codex, and Gemini, and links `.agents` rules/workflows when the downstream layout is available.
- If a required Delphi path is already occupied by a different file/symlink/directory, setup fails clearly and prints the blocking paths. Fix them manually, then rerun.
- For normal downstream environments, run `bash delphi-ai/verify_context.sh` afterward as a read-only validation pass.
- For zero-state `Genesis / Product-Bootstrap` repos, treat `init.sh --check` / `init.sh` as the install preflight and instantiate `foundation_documentation/` before expecting full `verify_context.sh` readiness to pass.
- If the validation fails only because Delphi-managed links/artifacts are missing or misaligned, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain `bash delphi-ai/verify_context.sh`.
- For full governance mirror validation after readiness passes, run `bash delphi-ai/verify_adherence_sync.sh`.

### Option 2: Manual Setup

1. Clone Delphi-AI (if not present):
   ```bash
   git clone https://github.com/belluga/delphi-ai.git delphi-ai
   ```

2. **For Cline** (auto-loads rules):
   ```bash
   ln -s delphi-ai/.clinerules .clinerules
   mkdir -p .cline
   ln -s ../delphi-ai/.cline/skills .cline/skills
   ```

3. **For Codex/Antigravity**:
   ```bash
   ln -s delphi-ai/templates/agents/root.md AGENTS.md
   mkdir -p .codex
   ln -s ../delphi-ai/skills .codex/skills
   bash delphi-ai/tools/sync_agent_rules.sh
   ```

4. **For Gemini**:
   ```bash
   ln -s delphi-ai/GEMINI.md GEMINI.md
   mkdir -p .agents
   ln -s ../delphi-ai/skills .agents/skills
   ```

5. Check `git status` to ensure submodule URLs point to your project forks, not boilerplate.

## If Setup Fails

The installer now fails on path conflicts instead of trying to overwrite them silently.

Common blocking paths are:
- `AGENTS.md`
- `CLINE.md`
- `GEMINI.md`
- `.agents/skills/`
- `.agents/rules/`
- `.agents/workflows/`
- `.clinerules/`
- `.cline/skills/`
- `.codex/skills/`
- `flutter-app/AGENTS.md`
- `laravel-app/AGENTS.md`
- `flutter-app/foundation_documentation`
- `laravel-app/foundation_documentation`
- `flutter-app/delphi-ai`
- `laravel-app/delphi-ai`
- `flutter-app/scripts`
- `laravel-app/scripts/delphi`

Manual resolution rules:
- If the path already belongs to your project, keep it and install Delphi manually only where it does not conflict.
- If the path is supposed to be Delphi-managed, rename or remove the conflicting file/directory, then rerun `bash delphi-ai/init.sh`.
- After any manual fix, run `bash delphi-ai/init.sh --check`, then `bash delphi-ai/init.sh`, then `bash delphi-ai/verify_context.sh`.

## AI Install Guide

If an AI agent is asked to install Delphi in a host repo, it should follow this exact behavior:

1. Inspect the required Delphi-owned paths before running setup.
2. If any required path already exists and is not the expected Delphi symlink, stop immediately and report the exact conflicting paths.
3. Do not overwrite project-owned files or directories.
4. After the user resolves conflicts, run:
   ```bash
   bash delphi-ai/init.sh --check
   bash delphi-ai/init.sh
   bash delphi-ai/verify_context.sh
   bash delphi-ai/verify_adherence_sync.sh
   ```
5. If `verify_context` fails only on repairable Delphi-managed links/artifacts, run:
   ```bash
   bash delphi-ai/verify_context.sh --repair
   bash delphi-ai/verify_context.sh
   ```
6. Report whether setup completed cleanly or whether manual remediation is still required.

## Cline-Specific Details

Cline automatically discovers artifacts without a bootloader file:

| Artifact | Location | Auto-Loaded |
|----------|----------|-------------|
| Rules | `.clinerules/*.md` | ✅ Always |
| Conditional Rules | `.clinerules/glob/*.md` | ✅ On file match |
| Workflows | `.clinerules/workflows/*.md` | ✅ Via `/filename.md` |
| Hooks | `.clinerules/hooks/*` | ✅ If executable |
| Skills | `.cline/skills/*/SKILL.md` | ✅ On-demand |

### Available Workflows
- `/create-controller.md` - New Flutter controller
- `/create-screen.md` - New Flutter screen
- `/create-domain.md` - New Flutter domain
- `/create-repository.md` - New Flutter repository

## Notes
- Delphi instructions remain agnostic; project-specific stack details should live under `foundation_documentation/`.
- Always run the DevOps readiness workflow before builds (`delphi-ai/workflows/docker/environment-readiness-method.md`).
