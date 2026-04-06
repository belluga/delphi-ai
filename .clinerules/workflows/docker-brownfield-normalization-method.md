---
name: "docker-brownfield-normalization-method"
description: "Turn a derived PACED project setup report into explicit manual-remediation and normalization-TODO tracks without creating a new source of truth."
---

<!-- Generated from `workflows/docker/brownfield-normalization-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Brownfield Normalization

## Purpose
Translate a derived PACED project setup report into bounded remediation tracks so downstream recalibration work stays explicit, narrow, and consistent with the method.

This method is planning-only. It does not mutate project artifacts, and it does not replace the tactical TODO that governs actual normalization execution.

## Triggers
- A project setup report returns `needs-normalization`.
- A project setup report returns `manual-remediation-required`.
- The operator needs help splitting structural repair versus project-owned canonical normalization before opening remediation TODOs.

## Inputs
- `foundation_documentation/artifacts/tmp/project-setup-report.json` or equivalent derived setup report JSON.
- The corresponding text setup report when human interpretation needs to inspect readiness output directly.

## Preferred Deterministic Helpers
For the full recalibration pipeline:

```bash
bash delphi-ai/tools/project_recalibration_doctor.sh \
  --repo . \
  --lane auto \
  --artifacts-dir foundation_documentation/artifacts/tmp
```

For packet-only derivation from an already-generated setup report:

```bash
python3 delphi-ai/tools/project_setup_normalization_packet.py \
  --report foundation_documentation/artifacts/tmp/project-setup-report.json \
  --json-output foundation_documentation/artifacts/tmp/project-normalization-packet.json \
  --markdown-output foundation_documentation/artifacts/tmp/project-normalization-packet.md
```

## Procedure
1. **Validate the source report**
   - Ensure the packet is being derived from the latest setup report, not from stale drift evidence.
   - Treat the setup report as derived/non-authoritative evidence, not as a replacement for downstream canonical docs.
   - Prefer rerunning `project_recalibration_doctor.sh` over hand-inspecting stale packet files when readiness or drift may have changed.
2. **Derive bounded remediation tracks**
   - Separate `manual_remediation` from `normalization_todo` tracks.
   - Keep Delphi-managed readiness/path repairs distinct from project-owned canonical normalization.
3. **Interpret the packet**
   - If the highest-priority track is `manual_remediation`, stop feature work and clear those blockers first.
   - If the packet recommends `normalization_todo`, open or update tactical TODOs whose boundaries match the packet instead of mixing multiple unrelated repair fronts into one oversized remediation branch.
4. **Handoff correctly**
   - Manual remediation remains outside tactical product execution.
   - Any project mutation still requires the TODO-driven execution method plus `APROVADO`.
5. **Keep the packet disposable**
   - Regenerate it after meaningful setup changes rather than editing it by hand.

## Outputs
- `foundation_documentation/artifacts/tmp/project-setup-report.txt`
- `foundation_documentation/artifacts/tmp/project-normalization-packet.json`
- `foundation_documentation/artifacts/tmp/project-normalization-packet.md`
- An explicit next-step decision:
  - `manual remediation first`
  - `normalization TODO(s) required`
  - `no normalization required`

## Validation
- The packet stays derived and non-authoritative.
- Manual remediation is never disguised as a normal feature TODO.
- Normalization TODOs created from this packet stay bounded by one primary remediation front each.
