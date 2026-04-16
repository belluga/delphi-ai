---
name: wf-docker-brownfield-normalization-method
description: "Workflow: MUST use whenever the scope matches this purpose: Turn a derived PACED project setup report into explicit manual-remediation and normalization-TODO tracks without creating a new source of truth."
---

# Method: Brownfield Normalization

## Purpose
Translate a derived PACED project setup report into bounded remediation tracks so downstream recalibration work stays explicit, narrow, and consistent with the method.

## Preferred Deterministic Helpers
```bash
bash delphi-ai/tools/project_recalibration_doctor.sh \
  --repo . \
  --lane auto \
  --artifacts-dir foundation_documentation/artifacts/tmp
```

For packet-only derivation from an existing setup report:

```bash
python3 delphi-ai/tools/project_setup_normalization_packet.py \
  --report foundation_documentation/artifacts/tmp/project-setup-report.json \
  --json-output foundation_documentation/artifacts/tmp/project-normalization-packet.json \
  --markdown-output foundation_documentation/artifacts/tmp/project-normalization-packet.md
```

## Procedure
1. Validate the setup report is the latest derived drift snapshot.
2. Separate `manual_remediation` from `normalization_todo` tracks.
3. Clear manual remediation before feature work or normalization TODO execution resumes.
4. Open/update bounded tactical TODOs only for the `normalization_todo` tracks, then require `APROVADO`.
5. Regenerate the packet after meaningful setup changes instead of editing it by hand; prefer rerunning `project_recalibration_doctor.sh` when the full readiness/drift picture may have changed.

## Outputs
- `foundation_documentation/artifacts/tmp/project-setup-report.txt`
- `foundation_documentation/artifacts/tmp/project-normalization-packet.json`
- `foundation_documentation/artifacts/tmp/project-normalization-packet.md`
