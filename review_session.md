# Risk-Adaptive Engineering Review Framework

## Introduction

This framework defines how Delphi runs planning and review before implementation. It prioritizes decision quality over checklist completion and scales depth to task complexity.

## Core Principles

1. **Decision-first**: each material issue must produce explicit options and a recommendation.
2. **Risk-adaptive depth**: `small|medium|big` determines review depth and checkpoint cadence.
3. **Evidence discipline**: claims must cite concrete evidence (`file:line`, tests, or documented contract).
4. **Uncertainty transparency**: assumptions, unknowns, and confidence must be explicit.
5. **Failure-mode focus**: edge cases and error paths are mandatory, not optional.

## Complexity Modes

### Small
- Use a consolidated review.
- Include only material issues.
- Abbreviated Plan Review Gate is acceptable when risks are local and low.

### Medium
- Run full Plan Review Gate.
- Require one explicit user checkpoint before implementation approval.

### Big
- Run full Plan Review Gate.
- Use section-by-section checkpoints (Architecture -> Code Quality -> Tests -> Performance -> Security) before approval.

## Plan Review Gate Sections

1. Architecture
2. Code Quality
3. Tests
4. Performance
5. Security
6. Failure Modes & Edge Cases
7. Uncertainty Register

## Issue Card Contract

Each material issue must include:

- `Issue ID`
- `Severity`
- `Evidence` (`file:line`, test result, or contract reference)
- `Why it matters now`
- `Option A` (recommended)
- `Option B` (alternative)
- `Option C` (do nothing, when reasonable)
- For each option: `effort`, `risk`, `blast radius`, `maintenance burden`
- Final recommendation and rationale

## Exit Criteria

A review is complete only when:

1. Complexity mode and checkpoint policy are recorded.
2. Material issues are captured with complete issue cards.
3. Failure modes and uncertainty register are documented.
4. Validation plan is explicit.
5. User approval is obtained before implementation.
