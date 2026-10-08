---
name: "go-change-service-boundary-method"
description: "Add or change a Go service boundary using the owning module, explicit HTTP and trust contracts, and project-declared verification."
---

<!-- Generated from `workflows/go/change-service-boundary-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Change a Go Service Boundary

## Purpose

Deliver a Go HTTP handler, application operation, adapter, or runtime boundary without assuming a framework, persistence layer, frontend, container, or deployment target.

## Inputs

- Project constitution, active capability namespaces, owning module/API contract, and relevant security and runtime topology.
- Owning `go.mod`, Go version/toolchain, module path, build tags, and exact project-owned build, test, vet, race, and service-run commands.
- Existing transport/application/adapter boundaries, error conventions, cancellation rules, and test fixtures.

## Procedure

1. Select `Operational / Coder` with `go` plus only independently activated capabilities. Resolve the owning Go module and commands; if ownership is ambiguous, stop and locate the correct module before running checks.
2. Define the observable contract: request/response shape, status and error mapping, authorization/trust source, validation, cancellation, limits, and health behavior as applicable.
3. Keep parsing and response writing at the transport edge; place business decisions in focused application code and external access behind explicit interfaces where doing so removes real coupling.
4. Make shared-state ownership, goroutine lifetime, timeout, and shutdown behavior explicit for changed paths. Do not spawn detached request work accidentally.
5. Restrict file/network/command access derived from requests. Validate all proxy identity or tunnel headers against the project's declared trusted ingress; never treat a client-supplied header as authentication by default.
6. Test the changed contract with project-owned fixtures and commands. Include unhappy paths, cancellation, unknown resources, and concurrent behavior where relevant; run race detection when supported and needed for the changed concurrency surface.
7. Compose database, frontend, Docker, ingress, browser, or deployment workflows only when those capabilities are separately active. Validate the actual served route through the declared runtime when a runtime-visible claim is made.
8. Synchronize the owning module contract and TODO evidence. Do not promote a local tool command into CI-equivalent proof without a project-owned parity contract.

## Validation

- The exact owning `go.mod` and project commands are identified.
- Changed HTTP and trust contracts, limits, errors, and cancellation behavior are covered by relevant evidence.
- Concurrent paths have an ownership strategy and appropriate race/runtime evidence or an explicit limitation.
- No undeclared framework, database, frontend, container, or deployment capability was inferred.
