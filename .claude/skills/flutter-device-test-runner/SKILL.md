---
name: flutter-device-test-runner
description: Run Flutter integration/device tests via ADB with a persistent checkbox checklist. Use whenever executing Flutter integration tests on a real device/emulator, especially when WSL/session disconnects are likely or when you need to resume a partial run.
---

# Flutter Device Test Runner

## Overview

Establish a durable, restartable process for running Flutter integration tests on ADB devices with a persistent checklist that is refreshed from the current test set and updated after each run. The default expectation is to run **all** integration tests one-by-one and mark each result.

This skill is **only** for device-level Flutter integration runs. For full-system test orchestration across Laravel + Flutter + Web, use the `test-orchestration-suite` skill.

## Workflow (must follow)

### Step 0: Skill availability

If the skill was just created or updated, restart Codex so it loads the latest skill contents before running tests.

### Step 1: Discover tests (always refresh)

1) Locate the Flutter app root (typically `flutter-app/`).
2) Discover integration tests dynamically:

```bash
rg --files -g 'integration_test/*_test.dart' flutter-app
```

3) Create/refresh the checklist file (overwrite each run):

```
<flutter_app_root>/../foundation_documentation/artifacts/tmp/flutter-device-runner/test-run-progress.md
```

If the repository has no sibling `foundation_documentation/artifacts/tmp/`, use a local fallback under:

```
<flutter_app_root>/build/runner_artifacts/flutter-device-runner/test-run-progress.md
```

Checklist format:

```
# Integration Test Progress (Flaky-First)

Status key: [ ] pending, [x] passed, [!] failed (needs retry)

- [ ] relative/path/to/test_a.dart
- [ ] relative/path/to/test_b.dart
```

Notes:
- Always rebuild the list before running, in case new tests were added.
- Keep the checklist file stable across runs; clear and repopulate it each time you start a new run.

4) Create/refresh a **suite reference file** for the current run:

```
<flutter_app_root>/../foundation_documentation/artifacts/tmp/flutter-device-runner/touched-branch-suite-reference.md
```

Use this template as the source:

```
<flutter_app_root>/../foundation_documentation/artifacts/flutter-device-runner/suite-reference-template.md
```

If the repository has no sibling `foundation_documentation/artifacts/`, use fallback under:

```
<flutter_app_root>/build/runner_artifacts/flutter-device-runner/touched-branch-suite-reference.md
```

5) Add/update this line near the top of the checklist file:

```
Suite reference: `foundation_documentation/artifacts/tmp/flutter-device-runner/touched-branch-suite-reference.md`
```

This is mandatory for traceability of which files were in scope for that run.

### Step 2: Device readiness

1) Confirm ADB device:

```bash
adb devices
```

2) If no device is attached, connect (example):

```bash
adb connect <ip:port>
```

3) If the device is flaky, force-stop the app before test runs:

```bash
adb -s <device> shell am force-stop <appId>
```

4) Pre-grant runtime permissions **before every test run** (avoid blocking dialogs).  
If the package is not installed yet in the current cycle, skip grant errors and continue:

```bash
if adb -s <device> shell pm list packages | tr -d '\r' | rg -q "^package:<appId>$"; then
  adb -s <device> shell pm grant <appId> android.permission.ACCESS_FINE_LOCATION || true
  adb -s <device> shell pm grant <appId> android.permission.ACCESS_COARSE_LOCATION || true
  adb -s <device> shell pm grant <appId> android.permission.POST_NOTIFICATIONS || true
  adb -s <device> shell appops set <appId> POST_NOTIFICATION allow || true
fi
```

### Step 2.5: Flutter test cache warm-up (required once per session)

Before the first integration run, clear stale Flutter incremental test cache to avoid long `loading...` stalls and false `No tests ran` outcomes:

```bash
if [ -d flutter-app/build/test_cache ]; then
  mv flutter-app/build/test_cache flutter-app/build/test_cache.bak.$(date +%s)
fi
```

Notes:
- Prefer move/rotate over destructive delete so diagnostics remain available.
- The resilient device runner script already applies this cache reset automatically at `start`.

### Step 3: Run tests (flaky-first)

1) Choose the flakiest or previously failing tests first (top of checklist).
2) Run tests **one file at a time**, in checklist order, until all entries are marked.
3) For WSL/remote instability, use the resilient detached runner as the default path:

```bash
export DEVICE_RUNNER_SKIP_APP_RESET=true
export DEVICE_RUNNER_REPORTER=expanded
export DEVICE_RUNNER_INNER_TIMEOUT_SECONDS=2400
export DEVICE_RUNNER_MODE=auto

bash /home/elton/.codex/skills/flutter-device-test-runner/scripts/device_single_test_resilient.sh start \
  <flutter_app_root> <device> <appId> <flavor> <define_file> integration_test/<test_file>.dart 1200

bash /home/elton/.codex/skills/flutter-device-test-runner/scripts/device_single_test_resilient.sh status <flutter_app_root>
bash /home/elton/.codex/skills/flutter-device-test-runner/scripts/device_single_test_resilient.sh wait <flutter_app_root>
```

4) Use `DEVICE_RUNNER_SKIP_APP_RESET=false` for the first run of a cycle (clean baseline). Switch back to `true` for iterative reruns to accelerate.

5) After **each** run, update the checklist item:
   - `[x]` on pass
   - `[!]` on fail
6) Continue to the next unchecked entry; do **not** batch-run multiple files in one command (this reduces the impact of WSL disconnects).

7) If a test fails:
   - Capture the error.
   - Fix the test or app code.
   - Re-run the same file until it passes.
8) Keep `DEVICE_RUNNER_MODE=auto` unless you intentionally want only one lane:
   - `auto`: run WSL-safe `flutter test` first, then auto-fallback to `flutter drive` when harness-only `streamListen` defects are detected.
   - `test`: force only `flutter test` lane.
   - `drive`: force only `flutter drive` lane.
9) Urgent single-file retest command (fast path):

```bash
adb connect <ip:port> >/dev/null 2>&1 || true
fvm flutter drive --no-pub \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/<test_file>.dart \
  -d <ip:port> \
  --flavor <flavor> \
  --dart-define-from-file=<define_file> \
  --dart-define=DISABLE_PUSH=true \
  --no-dds \
  --device-timeout 60
```

### Step 4: Resume after disconnect

1) Reconnect device (`adb devices`).
2) If using resilient mode, check current run state:

```bash
bash /home/elton/.codex/skills/flutter-device-test-runner/scripts/device_single_test_resilient.sh status <flutter_app_root>
```

3) Open the checklist file.
4) Resume from the first unchecked or failed (`[!]`) entry.

## Monitoring + Triage

- Live monitor:
  - `.../device_single_test_resilient.sh status <flutter_app_root>`
  - `tail -f <log_file>`
- ADB recovery:
  - `adb kill-server && adb start-server`
  - `adb connect <ip:port>`
  - `adb devices`
- Known harness classifications:
  - `streamListen ... VmServiceProxyGoldenFileComparator`: toolchain/harness defect, not app logic. Re-run same file via `flutter drive` (or `DEVICE_RUNNER_MODE=auto` so fallback happens automatically).
  - `Could not find EOCD` / invalid APK: build artifact corruption; rerun with WSL-safe runner (it rotates corrupted APK and retries once).
  - ADB offline/unreachable: environment defect; reconnect before retry.

## Completion

The run is complete when all checklist items are `[x]`.

Only after all single-file runs are green should you run the full suite in one command (optional).
