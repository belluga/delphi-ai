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
- It runs on the current authoritative branch under evaluation (`feature/*`, `review/*`, `reconcile/*`, version/package branch such as `v0.2.0+8-rc`, or equivalent).
- It uses the project-owned local build/publish/runtime path and the same product-facing suites/jobs the pipeline uses for that scope on that branch.
- It is scope-complete for the touched repo/job family. A targeted rerun, representative smoke path, or single happy path is diagnostic evidence unless the approved matrix explicitly says that narrower scope is complete.
- Published `stage` or `main` probes are separate evidence. They never replace `CI Equivalent`.
- `CI Equivalent` is a generic proof concept. Reconciliation is only one possible execution topology.

## Authoritative Branch And Wrapper Discipline
- The branch under test is the current authoritative branch for the claim being made.
- For package/version promotion lanes, the authoritative source branch is the exact branch recorded in the governing TODO `Current Branch Authority`, typically the version `*-rc` branch. Example: `v0.2.0+8-rc`.
- In those package/version lanes, the first promotion-grade `CI Equivalent` run must pass on that authoritative `*-rc` branch before any derived `review/*` remediation branch is opened.
- Reconcile-only wrappers are valid only on real `reconcile/*` states or an explicitly recorded same-commit reconcile alias.
- In real orchestration, the consolidated `reconcile/*` branch is authoritative until green; after that, replay the accepted net effect onto the recorded canonical return branch before promotion or non-orchestration closeout resumes.
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

## Mutation And Production Semantics
- Mutation validation belongs only on an approved non-`main` lane.
- If the touched behavior includes mutation, `CI Equivalent` must include corresponding local mutation evidence on that non-production lane.
- Production/main semantics may intentionally forbid mutation. Prove that separately with a production-lane proof surface such as `main-proof`; do not weaken non-main `CI Equivalent` to avoid running mutation locally.

## Required Evidence Hygiene
Before claiming `CI Equivalent`, record:
- authoritative branch under evaluation;
- governing TODO branch authority when package/version promotion is in scope, including the exact `*-rc` branch name and validated `branch@sha` when applicable;
- exact local commands or contract profiles run;
- touched repo/job family covered;
- runtime topology, publish path, domains, tenants, and credentials lane when relevant;
- whether readonly and mutation behaviors were both required;
- whether pipeline-owned lifecycle steps were executed locally as part of the same contract;
- evidence artifacts proving the current build/branch state was the one actually served.

Browser/device evidence is invalid if it cannot prove the current build, bundle, or runtime state was what the runner exercised.

## Relationship To Other Skills
- `ci-equivalent-test-surface-admission` decides how new or changed tests, wrappers, lifecycle steps, and suite rows enter the canonical stage-facing surface without local/pipeline drift.
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

## Done Criteria
- The in-scope local matrix is current-branch local proof, not proxy evidence.
- Any `stage-full`-style gate is parity-complete for the touched scope.
- Required lifecycle/precondition steps are executed by the same local contract rather than assumed from prior state.
- Delivery or promotion claims do not rest on published-lane proof or targeted reruns alone.
