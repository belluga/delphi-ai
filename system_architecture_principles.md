# Documentation: System Architecture Principles
**Version:** 1.1

## 1. Introduction

This document defines the architectural constitution for **our digital ecosystems**. These principles are the foundational source of truth for all design and engineering decisions. They are established to ensure any system we build is scalable, resilient, maintainable, and aligned with our core business objectives from its inception.

All modules, services, and schemas designed for a governed project **must** adhere to the stack-neutral principles below. Capability-specific appendices apply only when the project activates the corresponding namespace in its own constitution. A stack appendix may refine a core principle, but it must not silently activate itself or impose its technology on unrelated projects.

## 2. Architectural Modes

We operate in clearly defined modes that govern how the principles apply:

1. **Foundational Mode** (current state) – No production tenants. Design decisions favor the ideal launch architecture with zero backwards-compatibility constraints. Principles apply exactly as stated.
2. **Operational Mode** – Activated once production tenants exist. Principles remain in force, but all changes must honor migration policies (versioned APIs, data migrations, compatibility windows) documented by the CTO persona.
3. **Expansion Mode** – Large-scale re-architecture initiatives run in parallel to Operational systems. Foundational rules apply within the new scope, while compatibility plans bridge to the live platform.

Unless otherwise noted, this document assumes Foundational Mode. When transitioning to Operational or Expansion Mode, the CTO/Tech Lead must update `foundation_documentation/system_roadmap.md`, affected canonical docs, and appendices with the required policies.
Use the Architecture Mode Transition Workflow (`workflows/docker/architecture-mode-transition-method.md`) to govern those updates.

## 3. Core Architectural Philosophy

### P-1: Domain-First, Schema-Second
Our architecture is designed around the **Core Business Entities** defined in the project's `domain_entities.md` document. All system design decisions must originate from the needs of these domains. Frameworks, databases, build tools, and deployment platforms are chosen to serve the domain, not the other way around. Data structures must reflect real-world entities, invariants, relationships, and access patterns rather than accidental framework conventions.

### P-2: Persistence Strategy Is Explicit and Project-Owned
The project constitution and module contracts declare each active persistence technology and its ownership boundary. Relational, document, key-value, search, and event stores require different modeling rules; Delphi must never infer one from an ORM or application framework. Schema and query design must follow the activated database capability, documented access patterns, integrity requirements, and operational evidence.

### P-3: Explicit Boundary Contracts
Every boundary the project actually exposes—library API, command, event, job, service protocol, or user interface—has a secure, stable, and explicitly owned contract. Providers own authoritative business rules; consumers may improve user experience but must not replace validation, authorization, or domain enforcement at the authoritative boundary. The project declares its provider and consumer surfaces instead of Delphi assuming an HTTP API or client/server topology.

### P-4: Foundational, Not Minimalist
In Foundational Mode, this architecture is the definitive blueprint, not a minimal viable product (MVP). It may specify long-term capabilities (analytics, AI, future integrations), but future-aware documentation never by itself authorizes their implementation in a current tactical slice. For TODO-governed work, current implementation authority comes from the approved TODO and its frozen decisions; future-facing implementation explicitly authorized there remains valid. In Operational Mode, new capabilities still target the ideal state but must include migration and compatibility plans before release.

**Simplification First:** Choose the simplest faithful Clean Code/SOLID design that satisfies approved intent and the target architecture. Simplicity is not minimum diff or minimum abstraction count: subtraction, consolidation, or redesign may be necessary. Avoiding an abstraction through scattered conditionals, duplication, or hidden coupling is not simplicity. Foundation planning defines future architecture; for TODO-governed work, the approved TODO governs current implementation.

### P-4A: Explicit Scope and Ownership Governance
Route, screen, endpoint, worker, service, and module ownership must be declared against the project's canonical scope policy when that policy exists. Every externally reachable surface must identify its owning context and relevant identity, authorization, and transition boundaries. Project-specific scope vocabularies such as tenant, account, business unit, or environment apply only when declared by that project. New scopes must not emerge implicitly from folder placement or implementation convenience.

## 4. Data & Schema Design Principles

### P-5: Access-Pattern and Integrity-Aware Modeling
Each persistent model must serve its domain invariants, expected access patterns, cardinality, consistency needs, and growth profile. Embedding, normalization, references, indexes, constraints, partitioning, and denormalized projections are deliberate decisions governed by the active database capability. No technique is a universal default across databases.

### P-6: Single Source of Truth (SSoT)
Each piece of authoritative data must have one unambiguous owner. Replicas, caches, read models, search documents, and client state are derived projections with explicit freshness and invalidation contracts; they must never become accidental competing authorities.

### P-7: Immutability of Records
Records whose business meaning is historical, financial, audit-sensitive, or event-like are immutable unless the project contract explicitly defines a safe correction model. Corrections should use compensating records or a versioned history where auditability is required.

### P-8: Explicit Schemas
All persisted and externally exchanged models have explicit schemas. Fields, types, nullability, enums, constraints, compatibility expectations, and ownership must be defined in canonical contracts before implementation. Database constraints and application validation complement rather than silently replace each other.

### P-9: Consistent ID Naming
Identifier type and naming are declared per project and persistence capability, then used consistently across schema, application, API, events, and clients. Do not impose a database-native identifier such as `ObjectId`, UUID, sequence, or composite key on a project that has not activated that contract.

### P-9A: Native Type and Boundary Preservation
Persistence adapters should preserve the active database driver's native types and semantics until a documented boundary requires normalization. Avoid double encoding, lossy identifier conversion, timezone drift, precision loss, and framework casts that obscure the stored representation.

## 5. Boundary & Service Design Principles

### P-10: Service-Oriented Logic
Applications are structured around bounded domain or use-case behavior. When transport adapters exist, controllers, resolvers, handlers, commands, and consumers remain thin: they validate and map protocol input, invoke application behavior, and map results. Business decisions remain reusable, testable, and independent from a transport framework.

### P-11: Stateless Authentication
When a boundary requires authentication, its identity and session semantics must be explicit. Stateless request authentication is preferred for horizontally scaled service APIs unless the project documents a stateful session requirement and its storage, revocation, CSRF, and scaling behavior. Libraries, local commands, internal jobs, and public resources do not acquire authentication requirements merely from this principle.

### P-12: Resource-Oriented Naming
When HTTP APIs are active, use resource-oriented naming and standard method semantics unless the project documents another protocol or an action contract that cannot be represented faithfully as a resource. For HTTP, events, RPC, commands, and libraries alike, applicable versioning, identifiers, errors, idempotency, and compatibility behavior are explicit parts of the public contract.

### P-13: Comprehensive Data Validation
All data entering a service boundary must be rigorously validated. This includes type, range, enum, size, shape, authorization context, and applicable business rules. Client-side validation is for user experience only; the authoritative service boundary remains the gatekeeper of data integrity.

### P-14: Defended Input Surfaces
Every externally supplied string or array is constrained to a documented, finite size that aligns with business intent (e.g., passwords 8–32 characters, display strings ≤255, email lists ≤10, permission lists ≤64, metadata payloads ≤8 KB). These bounds protect API surfaces from resource-exhaustion attacks, simplify capacity planning, and provide a repeatable contract for client implementers.

### P-15: Deterministic Pagination + Delta Streams
When a project exposes large collection reads, it must choose and document a deterministic bounded-access strategy such as page, cursor, window, stream, or domain-specific batching based on ordering, consistency, caching, and scale needs. When real-time delivery is active, the project declares the transport and recovery semantics; SSE is one option, not a core default, and delta streams do not silently replace authoritative snapshot/listing contracts.

## 6. Security & Identity Principles

### P-15A: Principle of Least Privilege
All actors in the system—human users, service identities, organizations, integrations, and AI agents—operate under least privilege. Access rights are limited to what the declared role, attributes, scope, or capability requires. The project documents its authorization model rather than assuming RBAC is the only valid mechanism.

### P-16: Segregation of Identity
Authentication identity, domain actors, credentials, organizations, and authorization contexts are separate concepts unless a project contract deliberately unifies them. A person may act in multiple roles or scopes, but credentials and permissions must not be conflated with the domain entities they represent.

### P-17: Data Privacy by Design
All personally identifiable information (PII) will be treated as sensitive. PII will be encrypted at rest, and access will be strictly logged and audited. API responses will be designed to *exclude* sensitive data by default, requiring explicit permissions to request it.

## 7. Deployment & Operations Principles

### P-18: Ingress Configuration Parity
When a project has ingress, every established or revised externally reachable route, protocol, prefix, host, or port must be synchronized across the ingress layers and infrastructure manifests that the project actually uses. Documentation and active local/production runtime definitions must stay in lockstep. This principle does not require NGINX, Docker, HTTP, or ingress for projects whose topology has none.

## Appendix A: Flutter Application Tenets

These guidelines apply only when the project activates the `flutter` capability. They complement the core principles for Flutter client implementations. Reference project-owned Flutter architecture documentation for the live details.

1. **Feature-First Structure & Module Scopes** – Presentation folders follow `tenant/<feature>/screens/...` with controllers registered via `ModuleScope`. Controllers own local `StreamValue` state and UI controllers, expose repository-owned canonical streams by delegation, and keep widgets pure UI.
2. **DTO → Domain → Projection Flow** – DTOs never reach widgets. Infrastructure mappers convert DTOs into ValueObjects; repositories expose domain entities/projections; controllers translate only when necessary. Projection diligence rules apply (ValueObjects expose UI-ready primitives).
3. **AutoRoute Governance** – New screens must be registered via AutoRoute, wrapped in their module scope, and guarded appropriately (tenant shell, auth). Route additions require documentation in the relevant canonical module docs. AutoRoute remains the canonical navigation authority: do not bypass it with ad-hoc `Navigator` usage, synthetic browser-history seeding, manual ancestry fabrication, or mutable singleton stores whose only purpose is to hand off route outcomes between layers.
4. **Warm vs. Cold Entry Discipline** – Route design must explicitly classify cold entry (`URL`, deeplink, startup/deepLinkBuilder) versus warm in-app navigation initiated by an already-visible app route. Cold entry may remain guard/builder owned and must define deterministic fallback when required context is absent. Warm flows that must preserve predecessor history must commit a real router entry before any interruption/boundary logic resolves; unresolved guard redirects are not a substitute for warm in-app history.
5. **Boundary Route Contract** – Interruption routes (for example permission gates, promotion handoffs, auth continuation boundaries, confirmation boundaries) are first-class architectural surfaces, not ad-hoc exceptions. Each such route must declare success, cancel/dismiss, and no-history outcomes explicitly. Visible back, system/device back, and browser back must converge on the same semantic contract for that route family.
6. **Repository Contracts as API Blueprints** – When defining repositories, specify pagination, filtering, and scalability expectations. These contracts inform required backend support and must be recorded in `foundation_documentation/system_roadmap.md` when cross-stack work is pending.
7. **Static Analysis Discipline** – Flutter agents obtain local static-analysis evidence from a stable, full-workspace VS Code Problems bridge snapshot: no `Error` or `Warning`, with every retained `Information` diagnostic classified. They must not launch `dart analyze`, `flutter analyze`, `custom_lint`, or another concurrent analyzer in an editor-managed workspace. Remote CI may execute its own analyzer job as separate evidence. Any architectural method touching Flutter code ends with that snapshot and, when feasible, targeted unit/widget tests.

## Appendix B: Laravel / API Tenets

These guidelines apply only when the project activates the `laravel` capability. They refine the core principles for Laravel control planes and APIs. References to MongoDB, tenancy, Sanctum, route groups, or Flutter coordination apply only when those contracts are also declared by the project.

0. **Conditional MongoDB Modeling** – When MongoDB is active, document embedding versus referencing from access patterns and cardinality; preserve native BSON/ObjectId semantics through the driver; use `_id` and reference naming consistently with the project contract; do not transfer these rules to relational schemas.

1. **Multi-Tenant Routing Contracts** – Maintain the documented route groups: `/api/v1/initialize` (guest), `/admin/api/v1` (landlord middleware), `/api/v1` (tenant middleware), `/api/v1/accounts/{account_slug}` (tenant + account). Any change requires synchronized ingress updates (P‑18) and roadmap notes for Flutter clients.
2. **Tenant Resolution Chain** – Preserve the `DomainTenantFinder` → `SwitchMongoTenantDatabaseTask` sequence; new entry points must invoke the same resolver before touching tenant data.
3. **Sanctum + Ability Enforcement** – All endpoints are stateless and guarded by Sanctum abilities. Expanding abilities or scopes requires documentation updates plus corresponding Flutter contract changes.
4. **Controller-to-Service Migration** – Business logic should live in dedicated services, keeping controllers thin. When new APIs are introduced, budget time to move shared logic out of controllers per P‑10.
5. **Flutter Alignment** – Treat Flutter repository contracts, canonical module docs, and relevant `foundation_documentation/system_roadmap.md` entries as the primary client requirements. Before altering payloads or adding endpoints, verify the Flutter blueprint and record any desync/resync effort in the shared roadmap.
