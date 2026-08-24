---
name: laravel-suite-tail-recovery
description: "Resume a broad Laravel suite from the first failing file by generating the canonical file order, writing inventory/logs into artifacts/tmp, and replaying the tail sequentially through the project safe runner."
---

# Laravel Suite Tail Recovery

Use this skill when a broad Laravel suite already ran once and rerunning from zero is too expensive. This skill is for ordered tail recovery: map the canonical file order, rerun the first failing file, then continue file-by-file through every later file.

Do not use this skill for ordinary focused tests, and do not use it to bypass CI-equivalent obligations. It is a recovery and proof workflow for slow suites.

## Required contract
- Use the project-owned safe runner, not raw `php artisan test` with inherited environment.
- Write all inventories, raw list output, per-file logs, and status summaries under `foundation_documentation/artifacts/tmp/laravel-suite-tail-recovery/<run-id>/`.
- Treat `.delphi-locks/` as lock-only infrastructure. Do not put human review logs there.
- Stop on the first new failure. Classify it before changing code:
  - `product regression`
  - `test/assertion defect`
  - `CI/harness defect`
  - `environment/transient infra defect`

## Default flow
1. Confirm the first failing file from the previous broad run or pipeline.
2. Generate the canonical Laravel file order and persist it into `artifacts/tmp`.
3. Rerun the failing file through the safe runner.
4. If the failure is harness or stale expectation, fix only that scope unless explicit approval expands it.
5. Continue through every later file in canonical order, one file at a time.
6. Keep the inventory, raw PHPUnit list output, per-file logs, and status summary as transient artifacts.

## Deterministic helper
Use the bundled helper:

```bash
bash delphi-ai/skills/laravel-suite-tail-recovery/scripts/replay_suite_tail.sh \
  --from tests/Api/v1/Tenants/Middleware/T2Test.php
```

Useful variants:

```bash
# inventory only
bash delphi-ai/skills/laravel-suite-tail-recovery/scripts/replay_suite_tail.sh \
  --inventory-only

# replay from a failing file without the .php suffix
bash delphi-ai/skills/laravel-suite-tail-recovery/scripts/replay_suite_tail.sh \
  --from tests/Api/v1/Admin/ApiV1AdminMiddlewareTest

# custom artifact base
bash delphi-ai/skills/laravel-suite-tail-recovery/scripts/replay_suite_tail.sh \
  --from tests/Feature/Accounts/AccountControllerTest.php \
  --artifacts-dir foundation_documentation/artifacts/tmp/laravel-suite-tail-recovery-manual
```

## Outputs
- `phpunit-list-tests.out`
- `laravel-suite-files.txt`
- `run-status.tsv`
- `logs/<index>-<file>.log`

All of those stay under `foundation_documentation/artifacts/tmp/...` and remain non-authoritative transient evidence.

## Notes
- The helper normalizes PHPUnit `Tests\...::test...` output into `tests/...php` file paths.
- If the requested `--from` target is not found exactly, the helper attempts a unique suffix match before failing closed.
- The helper stops on the first failing file and prints the artifact directory so the agent can inspect the exact log before deciding the fix path.
