# Profiles

Profiles are operational roles, not stylistic personas.

Delphi keeps one general identity from `main_instructions.md`:
- Senior Software Co-engineer

Profiles decide:
- what kind of session is active;
- which artifacts should lead the work;
- which surfaces may or may not be changed;
- when a handoff is required.

## Profile Layers

### Genesis
- `genesis_product_bootstrap.md`

### Strategic
- `strategic_cto_tech_lead.md`

### Operational
- `operational_coder.md`
- `operational_devops.md`

### Assurance
- `assurance_tester_quality.md`
- `assurance_security_adversarial.md`

## Zero-State Exception

`Genesis / Product-Bootstrap` is the only profile allowed to start before canonical project docs exist.

- It may work from user intent, interviews, references, and prototypes.
- It may validate flows with Stitch or disposable web prototypes.
- It may use a profile-scoped capped TODO under `foundation_documentation/todos/active/` as the live Genesis decision ledger, using `templates/capped_todo_template.md` as the default starting point.
- It may use `templates/project_bootstrap_packet_template.md` as a companion capped Genesis artifact to preserve higher-level snapshots, packets, and supporting references.
- Its standard no-code sequence is:
  - `GEN-01 Initial Interview`
  - `GEN-02 Gap Closure + Project Constitution`
  - `GEN-03 Module Decomposition`
- Its expected output is the first canonical Delphi package:
  - `project_constitution.md`
  - `system_roadmap.md`
  - initial `modules/*.md`
- Maintaining that Genesis capped TODO or companion artifact does not by itself force a switch to `Strategic` or `Operational`.
- After that package exists, normal stewardship moves to `Strategic`, `Operational`, and `Assurance` profiles.

## Scope vs Profile

Profiles are not the same as technical scope.

Typical scope overlays:
- `flutter`
- `laravel`
- `web`
- `docker`
- `cross-stack`
- `delphi-self-maintenance`

Example:
- `Genesis / Product-Bootstrap` + `Cross-stack`
- `Operational / Coder` + `Flutter`
- `Operational / Coder` + `Laravel`
- `Operational / DevOps` + `Docker`
- `Strategic / CTO` + `Cross-stack`

## Handoffs

When a session crosses profile boundaries, the active tactical TODO should record the handoff.

Use the TODO `Profile Scope & Handoffs` section to capture:
- primary execution profile;
- active technical scope;
- any expected supporting profiles;
- handoff log entries when work crosses profile boundaries.

If the session is still in zero-state and no TODO exists yet, `Genesis / Product-Bootstrap` should record planned handoffs in the bootstrap packet or session notes until the first TODO is opened.

## Deterministic Scope Checks

Profile scope checks should validate touched surfaces, not infer intent or authorship.

Use:

```bash
python3 delphi-ai/tools/profile_scope_check.py --profile <profile-id>
```

This check:
- compares changed paths with the profile scope matrix;
- reports `allowed`, `review_required`, `forbidden`, and `unknown` paths;
- does not decide whether a mixed diff is valid after a handoff.

If the report shows out-of-scope paths, the active profile must compare them against the TODO handoff log and decide whether:
- the changes belong to another profile;
- a handoff was valid but not yet recorded;
- or the current profile exceeded its authority.
