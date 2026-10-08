---
name: rule-go-go-architecture-always-on
description: "Rule: Use for work in a project-declared Go backend or service to preserve module ownership, HTTP/trust boundaries, cancellation, concurrency, and project-owned verification without inferring other stacks."
---

# Go Architecture Rule

When a project activates `go`, load `delphi-ai/rules/stacks/go/go-architecture-always-on.md` and apply it to the owning Go module. Do not activate Go from Delphi's registry alone. For an HTTP, service, adapter, or runtime change, follow `delphi-ai/workflows/go/change-service-boundary-method.md`.
