<!-- Generated from `rules/stacks/laravel/shared/mongodb-transaction-simplification-model-decision.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Laravel MongoDB Transaction Simplification (Model Decision)

# Laravel MongoDB Transaction Simplification

## Rule

Apply **Architecture Simplification First** before adding or retaining retry
behavior around a Laravel MongoDB transaction.

1. State the domain concurrency policy first: reject the conflicting command,
   replay the same command idempotently, serialize it, or accept last-write-wins.
   Do not infer transparent retry merely because a driver or adapter supports it.
2. When one atomic attempt plus a stable conflict/indeterminate response satisfies
   the approved contract, use one explicit transaction attempt on the existing
   Laravel MongoDB connection:
   - begin the transaction;
   - obtain and share that connection-owned session with Eloquent and raw MongoDB
     operations;
   - execute the mutation once;
   - commit once;
   - roll back only a known-failed transaction while its session is active.
3. An unknown commit result must remain indeterminate. Do not blindly replay the
   callback or issue an unsafe rollback whose outcome could contradict a commit
   that actually succeeded.
4. A retrying callback API is admissible only when transparent replay is an
   explicit approved requirement, every callback effect is proven replay-safe,
   external effects occur after commit, and inspection of the installed package
   version proves that adapter and driver retry policies do not compete.
5. Keep one transaction/context owner. Do not create a second session for raw
   operations when Eloquent obtains its session from the Laravel connection.

## Forbidden Compensations

Do not solve adapter/driver overlap with:

- sentinel or effectively unbounded attempt arguments such as `PHP_INT_MAX`;
- application-owned attempt constants, retry loops, clocks, deadlines, jitter,
  sleeps, or generic rereads unless the approved domain contract independently
  requires them;
- a wrapper around another wrapper whose only purpose is to neutralize its retry
  policy;
- mixed retry authorities across application, Laravel adapter, library helper,
  and driver;
- tests that assert a retry algorithm which the product contract does not own.

## Required Verification

Use the minimum discriminating proof for the approved policy:

- callback execution count;
- atomic success for every persistence API sharing the transaction;
- rollback of known callback failures;
- stable conflict mapping;
- stable unknown-commit mapping without callback replay or unsafe rollback.

When transparent retry is explicitly approved, additionally prove replay safety
and the installed adapter's exact retry/exhaustion behavior. Documentation for a
newer package version is not evidence for the installed version.

## Existing Violations and Scope Control

Applying this rule to one transaction owner does not authorize repository-wide
cleanup. If review exposes another owner with competing retry policies or an
unproven replay contract:

- report the exact locus and risk;
- do not modify it under the current TODO unless it is already in scope;
- route it to a project-owned follow-up TODO/version or an explicit exception;
- keep the current implementation blocked only when that separate violation is
  on the current delivery path and presents a real correctness risk.

## Project Architecture-Guard Integration

When the Laravel repository already provides a canonical architecture-guard
runner, enforce this rule through that runner instead of creating a parallel CI
or review-only scanner.

- Add a focused transaction subguard to the existing runner and its existing CI
  command.
- Fail new, unreviewed callback-transaction or compensating-retry shapes.
- Baseline pre-existing findings only through exact entries that name the code
  owner, rationale, and project follow-up owner. Emit those findings on every
  guard run so the baseline cannot become invisible debt.
- Fail stale or mismatched baseline entries.
- Prove both the focused subguard and its invocation by the repository's real
  architecture runner with fixture-based positive and negative tests.
- Do not duplicate the repository guard in Delphi. Delphi owns the reusable
  decision rule; the downstream repository owns detection of its concrete PHP
  shapes and approved exceptions.

## Enforcement

- Treat false-success, split-session atomicity, or blind replay risk as a
  release-blocking finding for the affected delivery.
- Reject implementation plans that introduce a retry mechanism before recording
  the domain policy and installed-package evidence above.
- During TODO review, require the chosen policy and rejected compensations to be
  visible in the transaction owner's contract and tests.
- When a canonical project architecture guard exists, block closeout until the
  changed transaction shape is covered by that guard or is demonstrably outside
  its statically detectable surface.
