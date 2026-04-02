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

### Strategic
- `strategic_cto_tech_lead.md`

### Operational
- `operational_coder.md`
- `operational_devops.md`

### Assurance
- `assurance_tester_quality.md`
- `assurance_security_adversarial.md`

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
