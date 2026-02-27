---
name: docker-update-ci-pipeline
description: "Modify CI workflows (GitHub Actions, GitLab CI, etc.) safely—ensuring analyzer/test steps for Flutter, Laravel, and Docker stay intact and cost-effective."
---

# Workflow: Update CI/Pipeline (DevOps)

## Purpose

Modify CI workflows (GitHub Actions, GitLab CI, etc.) safely—ensuring analyzer/test steps for Flutter, Laravel, and Docker stay intact and cost-effective.

## Triggers

- Need to add or change CI jobs
- Credentials/secrets or runners change
- Pipeline runtimes/cost require optimization

## Prerequisites

- [ ] Existing workflow files reviewed
- [ ] Analyzer/test requirements understood
- [ ] Secrets management notes available

## Procedure

### Step 1: Persona Alignment

Select **DevOps Engineer** persona and review roadmap context.

### Step 2: Plan Changes

List affected items:
- Workflows/jobs to modify
- Required secrets
- Target environments
- Expected impact

### Step 3: Edit Workflow

**Standard jobs to maintain:**

```yaml
# Flutter
- name: Flutter Analyze
  run: cd flutter-app && fvm flutter analyze

- name: Flutter Test
  run: cd flutter-app && fvm flutter test

# Laravel
- name: Laravel Test
  run: cd laravel-app && composer test

# Docker
- name: Docker Build
  run: docker compose build
```

**Optimization strategies:**
- Use caching for dependencies
- Use matrix strategies for multiple versions
- Parallelize independent jobs
- Use conditional execution

### Step 4: Secrets & Permissions

Verify secrets:
- [ ] All required secrets exist
- [ ] New secrets documented in secure channel
- [ ] Never commit secrets to repo

**Common secrets:**
| Secret | Usage |
|--------|-------|
| `DOCKER_USERNAME` | Docker Hub login |
| `DOCKER_PASSWORD` | Docker Hub password |
| `DEPLOY_KEY` | SSH deploy key |
| `SENTRY_DSN` | Error tracking |

### Step 5: Dry-run / Validation

**Validate workflow syntax:**
```bash
# GitHub Actions with act
act -j <job-name>

# Or push to test branch
git push origin feature/ci-update --force-with-lease
```

### Step 6: Documentation + Roadmap

- Note change in DevOps roadmap
- Mention expected benefits
- Alert other personas if local workflows affected

### Step 7: Session Summary

Capture:
- Changes made
- Secrets updated (without values)
- Follow-up items

## Standard Pipeline Structure

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      - name: Install dependencies
        run: cd flutter-app && fvm flutter pub get
      - name: Analyze
        run: cd flutter-app && fvm flutter analyze
      - name: Test
        run: cd flutter-app && fvm flutter test

  laravel:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
      - name: Install dependencies
        run: cd laravel-app && composer install
      - name: Test
        run: cd laravel-app && composer test

  docker:
    runs-on: ubuntu-latest
    needs: [flutter, laravel]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: docker compose build
      - name: Push
        run: docker compose push
```

## Optimization Patterns

### Caching
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: flutter-app/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

### Matrix Strategy
```yaml
strategy:
  matrix:
    flutter-version: ['3.16.0', '3.19.0']
```

### Conditional Execution
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## Outputs

- [ ] Updated workflow files
- [ ] Roadmap entry with expected benefits
- [ ] Notes to other personas if needed

## Validation Checklist

- [ ] CI run succeeds with new configuration
- [ ] Analyzer/test steps enforced
- [ ] No secrets committed to repo
- [ ] Caching implemented
- [ ] Cost/runtime acceptable