---
name: docker-environment-readiness
description: "Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before executing DevOps or CI/CD tasks."
---

# Workflow: DevOps Environment Readiness

## Purpose

Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before executing DevOps or CI/CD tasks. Prefer deterministic script checks over manual spot-checks to prevent drift.

## Triggers

- User explicitly requests DevOps/setup help
- Session starts in a repository that might not be canonical
- Before running scripts that depend on submodules

## Prerequisites

- [ ] Root repository accessible
- [ ] `.gitmodules` file present
- [ ] Project README available

## Procedure

### Step 1: Confirm Repository Context

Identify where we are:
- Is this the canonical boilerplate repo?
- Is this a downstream project?
- What are the expected remotes?

If downstream, note expected remotes (e.g., `belluga/festou_api`, `belluga/festou_app`, `belluga/festou_web`).

### Step 2: Run Canonical Readiness Scripts

**Preferred approach - use automated scripts:**

```bash
# Delphi context checks (symlinks, required folders)
bash delphi-ai/verify_context.sh

# Project readiness verifier (compose config + drift checks)
bash scripts/verify_environment.sh
```

**If either script fails:**
- Treat `verify_context.sh` as read-only verification. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
- If `verify_context.sh` fails on a path conflict with project-owned files/directories, stop and report the conflict for manual remediation.
- Fix reported issues before proceeding
- Do not continue with DevOps work until scripts pass

### Step 3: Validate Submodules

**Check submodule status:**
```bash
git submodule status --recursive
```

**Verify:**
- No entry should start with `-` (uninitialized)
- No entry should start with `+` (detached from recorded commit)

**Fix issues:**
```bash
# Realign working trees with recorded commits
git submodule sync --recursive
git submodule update --init --recursive
```

**Verify foundation_documentation:**
- Must be present as a submodule
- If missing, add it using the canonical docs repo

**Check submodule URLs:**
- Each entry in `.gitmodules` should point to project's own repo
- NOT `belluga/boilerplate_*`
- If referencing boilerplate, guide user to:
  ```bash
  git submodule set-url <path> <correct-url>
  ```

### Step 4: Filesystem Ownership

**Spot-check key files:**
```bash
ls -la laravel-app/.env
ls -la flutter-app
ls -la web-app
```

**Verify:**
- Files are writable by host/WSL user
- NOT owned by container/root users (UID 0)

**Fix ownership if needed:**
```bash
sudo chown -R $USER:$USER laravel-app
sudo chown -R $USER:$USER flutter-app
```

### Step 5: Symlinked Scripts

**Verify helper script symlinks:**
```bash
ls -la flutter-app/scripts
# Should symlink to ../delphi-ai/scripts/flutter
```

**If missing, recreate:**
```bash
ln -s ../delphi-ai/scripts/flutter flutter-app/scripts
```

### Step 6: README Alignment

If in setup mode, walk through README sections:
- [ ] Environment variables configured
- [ ] Submodules initialized
- [ ] Docker commands executed
- [ ] Database migrations run

Use README as canonical checklist for new environments.

### Step 7: Report Status

Summarize findings:
- [ ] Submodules: OK / Issues found
- [ ] Permissions: OK / Issues found
- [ ] Scripts: OK / Issues found
- [ ] README steps: Complete / Incomplete

**Only proceed with DevOps work after environment is confirmed healthy.**

## Common Issues & Fixes

### Issue: Submodule shows `-` prefix
```
-abc123... laravel-app (v1.0.0)
```
**Fix:** Submodule not initialized
```bash
git submodule update --init laravel-app
```

### Issue: Submodule shows `+` prefix
```
+def456... flutter-app (v1.2.0-12-gdef456)
```
**Fix:** Submodule detached from recorded commit
```bash
git submodule update flutter-app
```

### Issue: Wrong submodule URL
```
[submodule "laravel-app"]
    url = https://github.com/belluga/boilerplate_laravel.git
```
**Fix:** Update to correct project URL
```bash
git submodule set-url laravel-app https://github.com/belluga/festou_api.git
```

### Issue: Container-owned files
```
-rw-r--r-- 1 root root 1234 Jan 1 .env
```
**Fix:** Reset ownership
```bash
sudo chown -R $USER:$USER .
```

## Outputs

- [ ] Status summary of submodules
- [ ] Status summary of permissions
- [ ] Status summary of scripts
- [ ] Action items for user to fix (if any)
- [ ] Confirmation to proceed with DevOps work

## Validation Checklist

- [ ] Read-only `verify_context.sh` passes
- [ ] `verify_environment.sh` passes
- [ ] All submodules initialized and aligned
- [ ] File ownership correct
- [ ] Symlinks functional
- [ ] README steps complete
