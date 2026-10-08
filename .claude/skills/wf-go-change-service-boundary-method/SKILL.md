---
name: wf-go-change-service-boundary-method
description: "Workflow: Use when adding or changing a project-declared Go HTTP handler, service operation, adapter, module, or runtime boundary."
---

# Change a Go Service Boundary

Use `delphi-ai/workflows/go/change-service-boundary-method.md` as the canonical procedure. Resolve the owning `go.mod` and project commands first; declare the HTTP and trust contracts, preserve cancellation and shared-state ownership, test observable behavior, and compose other stack workflows only when separately activated. The Go rule is `delphi-ai/rules/stacks/go/go-architecture-always-on.md`.
