---
trigger: always_on
description: Preserve Go module, HTTP boundary, concurrency, and verification contracts only when a project activates Go.
---

## Rule

When `go` is project-declared:

- Resolve the owning `go.mod`, declared Go version, module path, build tags, and exact project build/test commands before changing service code. A repository may contain more than one Go module; do not run an unrelated root command as proof.
- Keep transport parsing, application behavior, persistence/external adapters, and presentation of errors separated in proportion to the service. The project's module/API documentation owns public routes, payloads, status codes, and authorization semantics.
- Bound HTTP request bodies, timeouts, concurrency, and resource lifetimes according to the service contract. Propagate request cancellation through downstream work; do not retain `http.Request.Context()` beyond request completion.
- Treat caller-controlled paths, URLs, headers, and document identifiers as untrusted. Use explicit allowlists or project-owned validation before file, network, or command access.
- Give each mutable shared value a synchronization or ownership strategy. Prefer focused tests for concurrent behavior and use `go test -race` when the project environment supports the race detector; record a real environment limitation rather than silently claiming a pass.
- Return actionable errors without leaking secrets or internal file paths. Keep sensitive credentials server-side and require a project-declared trust boundary before relying on proxy or tunnel identity headers.
- Verify affected behavior with the owning module's project-declared commands. `gofmt`, `go vet`, `go test`, and `go test -race` are relevant Go tools, but their exact use and CI-equivalent scope must match the project contract.
- Do not infer Docker, a database, a router/framework, React, Vite, a deployment provider, or a particular hosting model from Go alone.

## Enforcement

Follow `delphi-ai/workflows/go/change-service-boundary-method.md` for an HTTP handler, service operation, adapter, module, or runtime boundary change. Confirm the owning `go.mod` and required project commands before execution. Validate each changed public route and concurrency-sensitive path at the contract and runtime layers claimed by the TODO.
