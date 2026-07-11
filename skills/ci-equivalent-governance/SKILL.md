---
name: ci-equivalent-governance
description: "Canonical definition of CI Equivalent and broad local stage-parity gates such as `stage-full`. Load whenever a workflow, skill, or operator is designing, invoking, reviewing, or claiming CI-equivalent evidence."
---

# CI Equivalent Governance

Use this skill whenever a workflow, skill, TODO, execution plan, or promotion lane says `CI Equivalent`, claims `stage-full`-style parity, or needs to decide whether local evidence is truly pipeline-equivalent instead of merely diagnostic.

## Purpose
Freeze the meaning of `CI Equivalent` as current-branch local product proof on the authoritative branch under evaluation. This skill owns the shared taxonomy so promotion, test orchestration, TODO delivery, pipeline updates, and reconciliation do not redefine it differently.

## Canonical Model
- `CI Equivalent` is local proof, not published-lane proof.
- It runs on the current authoritative branch under evaluation (`feature/*`, `review/*`, `sequence/*`, `reconcile/*`, version/package branch such as `v0.2.0+8-rc`, or equivalent).
- It uses the project-owned local build/publish/runtime path and the same product-facing suites/jobs the pipeline uses for that scope on that branch.
- It is scope-complete for the touched repo/job family. A targeted rerun, representative smoke path, or single happy path is diagnostic evidence unless the approved matrix explicitly says that narrower scope is complete.
- Published `stage` or `main` probes are separate evidence. They never replace `CI Equivalent`.
- `CI Equivalent` is a generic proof concept. Reconciliation is only one possible execution topology.
- If the required local runtime surface for a broad gate is unavailable, hung, or ambiguous, the `CI Equivalent` claim is `blocked`, not `passed`, and published-lane evidence still does not replace it.

## Authoritative Branch And Wrapper Discipline
- The branch under test is the current authoritative branch for the claim being made.
- For package/version promotion lanes, the authoritative source branch is the exact branch recorded in the governing TODO `Current Branch Authority`, typically the version `*-rc` branch. Example: `v0.2.0+8-rc`.
- In those package/version lanes, the first promotion-grade `CI Equivalent` run must pass on that authoritative `*-rc` branch before any derived `review/*` remediation branch is opened.
- Reconcile-only wrappers are valid only on real `reconcile/*` states or an explicitly recorded same-commit reconcile alias.
- In real orchestration, the consolidated `reconcile/*` branch is authoritative until green; after that, replay the accepted net effect onto the recorded canonical return branch before promotion or non-orchestration closeout resumes.
- In TODO sequencing, a `sequence/*` branch may be authoritative for the per-TODO broad local gate only when that branch is the current principal-checkout authoritative branch under evaluation and owns the real local runtime/browser surface. The sequencing branch is checkpoint-only topology and is never itself a promotable source branch.
- If `sequence/*` exists only inside an isolated linked worktree while the principal checkout is reserved for another lane, treat it as non-authoritative implementation topology only: it may run an explicitly narrower checkpoint prefix gate, but it must not run or claim the parity-complete broad local gate until the accepted net effect is replayed onto the principal authoritative branch.
- Review/remediation branches may run `CI Equivalent` for their own validation loop, but they are evidence branches rather than promotable source authority.
- A `review/*` pass never substitutes for the missing authoritative `*-rc` pass. It is an additional gate.
- After replay from `review/*` back onto the authoritative `*-rc` branch, rerun `CI Equivalent` there whenever the replay was not a pure fast-forward or otherwise introduced branch-local change.

## Broad Local Stage Gate Rule
When a repo exposes a named broad local stage gate such as `stage-full`, that name is reserved for the parity-complete local mirror of the stage pipeline for the touched scope on that branch.

That parity must include both:
- the complete repo-owned suite/job family that the stage pipeline executes for that scope; and
- any pipeline-owned lifecycle work outside the inner smoke commands, such as build/publish/provenance, fixture/bootstrap seed, host-override management, cleanup/teardown, restore/readback preparation, or equivalent pre/post steps.

A local bundle is not valid `stage-full` parity when any of these are true:
- it omits an in-scope stage suite/job that the pipeline still runs for that scope;
- it runs only inner smoke commands while the pipeline owns required outer lifecycle steps;
- it passes only because prior state already had healthy fixtures, seed data, runtime overrides, or published artifacts;
- it silently changes branch/topology semantics just to satisfy a reconcile-only wrapper.

Narrower diagnostic bundles must use distinct names and must not be reported as the broad stage gate.

If an isolated sequencing worktree uses a prefix derived from `stage-full`, that prefix must stop before `browser-stage-full`. That cutoff means the isolated state never enters `local-public-web-build`, readonly smoke, or mutation smoke, and it must not claim any of those surfaces. Any request to cross that cutoff from the isolated worktree is out of contract and must be refused until replay onto the principal authoritative branch.

When a broad local gate such as `stage-full` cannot complete because the local runtime surface is unhealthy or non-responsive:
- treat the gate as a blocking local infrastructure failure, not as a soft warning;
- do not continue promotion, replay, or closeout on the theory that remote `stage` or `main` evidence is "good enough";
- do not reinterpret targeted local checks as a substitute for the missing broad gate;
- only explicit human waiver may authorize progression without that gate;
- emit a PACED/TEACH stop response that names the blocked gate, the failing runtime surface, why evolution is disallowed, and the next local recovery action.

## Mutation And Production Semantics
- Mutation validation belongs only on an approved non-`main` lane.
- If the touched behavior includes mutation, `CI Equivalent` must include corresponding local mutation evidence on that non-production lane.
- Production/main semantics may intentionally forbid mutation. Prove that separately with a production-lane proof surface such as `main-proof`; do not weaken non-main `CI Equivalent` to avoid running mutation locally.

## Required Evidence Hygiene
Before claiming `CI Equivalent`, record:
- authoritative branch under evaluation;
- governing TODO branch authority when package/version promotion is in scope, including the exact `*-rc` branch name and validated `branch@sha` when applicable;
- exact local commands or contract profiles run;
- runtime freshness attestation for every manual/browser/device proof surface: authoritative `branch@sha`, local build/publish artifact or fingerprint, served target URL/device/tunnel, and the comparison/probe proving the served target matched that build before the test result was interpreted;
- touched repo/job family covered;
- runtime topology, publish path, domains, tenants, and credentials lane when relevant;
- whether readonly and mutation behaviors were both required;
- whether pipeline-owned lifecycle steps were executed locally as part of the same contract;
- evidence artifacts proving the current build/branch state was the one actually served.

Browser/device evidence is invalid if it cannot prove the current build, bundle, or runtime state was what the runner exercised. Freshness must be proven before the test result is trusted, not reconstructed afterward from assumption.

## Promotable Documentation Preflight
For a promotable broad gate, validate required delivery documentation before starting the expensive execution contract. This is a precondition of execution, not a second kind of post-execution CI-equivalent proof.

- The preflight must fail closed when a TODO or delivery record that should already describe completed implementation/evidence remains `Pending`, `Open`, or otherwise stale.
- The preflight must allow the one explicitly declared pending item that the current broad gate itself will produce (for example, the pending `promotable-stage-full` evidence row). It must not require future execution evidence before the execution that creates it.
- Correcting a scope-neutral documentation drift found by this preflight happens before `stage-full`; after the correction, run the preflight again and then run `stage-full` once on the final documented state.
- Do not make a completed `stage-full` rerun merely because a later promotion guard exposed a scope-neutral documentation omission that the preflight should have caught. Harden the preflight and correct the documentation instead.
- If the documentation correction changes declared scope, behavior, acceptance criteria, runtime contract, or another execution-relevant claim, it is no longer documentation-only: reassess the execution evidence and rerun the broad gate when the project-owned invalidation policy requires it.

## Evidence Reuse And Invalidation
- Exact `branch@sha` remains the traceability anchor for CI-equivalent and promotion claims. Do not stop recording it.
- SHA drift alone is not the canonical rerun trigger once a passed CI-equivalent artifact already exists.
- Reuse is allowed only when a deterministic, project-owned invalidation/reuse guard proves the current authoritative branch differs from that passed baseline only on explicitly safe-reuse surfaces.
- Rerun is required when the guard reports any invalidating drift in product code, test ownership, wrappers, lifecycle steps, build/publish/provenance paths, runtime/bootstrap/config, or other stage-facing surfaces.
- Manual admission/authority refresh is required when the current branch is dirty, diverged from the baseline topology, or the baseline artifact/TODO/policy no longer line up deterministically.
- Backward-compatibility note: if an older report artifact lacks recorded repo head metadata, the guard may fall back to the governing TODO `branch@sha` entries, but that is weaker than artifact-native repo-state evidence and should be phased out.

## Relationship To Other Skills
- `ci-equivalent-test-surface-admission` decides how new or changed tests, wrappers, lifecycle steps, and suite rows enter the canonical stage-facing surface without local/pipeline drift.
- `ci_equivalent_evidence_invalidation_guard.py` decides whether a previously passed CI-equivalent artifact is still reusable on the current heads or whether the broad gate must rerun.
- `test-orchestration-suite` decides the concrete suite matrix and execution order.
- `wf-docker-todo-delivery-gates-method` uses this skill when deciding whether TODO evidence really counts as `CI Equivalent`.
- `github-stage-promotion-orchestrator` and `github-main-promotion-orchestrator` use this skill before any promotion-ready claim.
- `wf-docker-update-ci-pipeline-method` uses this skill whenever a pipeline edit changes stage-facing suite/job ownership or lifecycle steps.
- `wf-docker-subagent-worktree-reconciliation-method` uses this skill to keep reconcile topology from hijacking the generic definition.

## Required Operator Actions
1. Load this skill before designing, invoking, or claiming a `CI Equivalent` surface.
2. If a named broad stage gate already exists, compare it against the actual stage pipeline job family for the touched scope.
3. If the local gate is narrower, rename it or expand it; do not keep a misleading broad name.
4. If suite membership, wrapper ownership, lifecycle steps, or readonly/mutation rows changed, load `ci-equivalent-test-surface-admission` and complete that admission before claiming parity.
5. Record any deliberate same-commit reconcile alias or waiver explicitly.
6. Treat published-lane checks as additional evidence only.
7. When the current sequencing lane is an isolated worktree and the broad local gate is `stage-full`, record the exact pre-browser prefix that runs now, explicitly note that the skipped boundary starts at `local-public-web-build`, and record the deferred principal-authoritative broad gate that still remains mandatory after replay.
8. Before any manual/browser/device validation lane, produce or refresh the runtime freshness attestation and stop immediately if the served target cannot be proven fresh for the current authoritative build.
9. For a promotable broad gate, run the documentation preflight before the execution contract. It must reject stale prerequisite delivery documentation while allowing only the explicitly designated future-evidence row for this exact gate.
10. Before rerunning or reusing an already-passed broad local gate such as `stage-full`, run the project-owned evidence invalidation/reuse guard and record whether the outcome was `reusable`, `rerun-required`, or `manual-admission-required`.
11. If the required broad local gate is unavailable, hung, or fails for local runtime-health reasons, stop the lane and report it as a blocked local infrastructure surface. Do not convert to remote-lane progression or completion claims without an explicit human waiver.

## Done Criteria
- The in-scope local matrix is current-branch local proof, not proxy evidence.
- Any `stage-full`-style gate is parity-complete for the touched scope.
- Required lifecycle/precondition steps are executed by the same local contract rather than assumed from prior state.
- Delivery or promotion claims do not rest on published-lane proof or targeted reruns alone.
- Missing or non-responsive runtime surfaces block the claim rather than silently downgrading the local proof requirement.
