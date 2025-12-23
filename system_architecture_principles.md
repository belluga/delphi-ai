# Documentation: System Architecture Principles
**Version:** 1.0

## 1. Introduction

This document defines the architectural constitution for **our digital ecosystems**. These principles are the foundational source of truth for all design and engineering decisions. They are established to ensure any system we build is scalable, resilient, maintainable, and aligned with our core business objectives from its inception.

All modules, services, and schemas designed for this platform **must** adhere to these principles. Stack-specific expectations live in the appendices (Flutter and Laravel/API) and refine—without replacing—the core mandates below.

## 2. Architectural Modes

We operate in clearly defined modes that govern how the principles apply:

1. **Foundational Mode** (current state) – No production tenants. Design decisions favor the ideal launch architecture with zero backwards-compatibility constraints. Principles apply exactly as stated.
2. **Operational Mode** – Activated once production tenants exist. Principles remain in force, but all changes must honor migration policies (versioned APIs, data migrations, compatibility windows) documented by the CTO persona.
3. **Expansion Mode** – Large-scale re-architecture initiatives run in parallel to Operational systems. Foundational rules apply within the new scope, while compatibility plans bridge to the live platform.

Unless otherwise noted, this document assumes Foundational Mode. When transitioning to Operational or Expansion Mode, the CTO/Tech Lead must update persona roadmaps and appendices with the required policies.
Use the Architecture Mode Transition Workflow (`workflows/docker/architecture-mode-transition-method.md`) to govern those updates.

## 3. Core Architectural Philosophy

### P-1: Domain-First, Schema-Second
Our architecture is designed around the **Core Business Entities** defined in the `domain_entities.md` document. All system design decisions must originate from the needs of these domains. The technology (MongoDB, Laravel) is chosen to serve the domain, not the other way around. We will design our data structures to reflect real-world entities and their relationships, not to satisfy a specific storage mechanism.

### P-2: Document-Oriented by Default
We select MongoDB as our primary database. This choice mandates a document-oriented mindset. We will prioritize embedding related data within a single document over normalization (splitting data into multiple collections) wherever it aligns with a clear access pattern. This principle supports performance and data co-location.

### P-3: API-Centric Ecosystem
The system is defined as a set of services exposed via a secure, stable, and versioned API. The Laravel backend serves as the headless API provider. The Flutter application and any future clients (web, partner integrations) are pure consumers of this API. There will be no business logic within the client applications that is not also enforced by the API.

### P-4: Foundational, Not Minimalist
In Foundational Mode, this architecture is the definitive blueprint, not a minimal viable product (MVP). Schemas and services must incorporate long-term capabilities (analytics, AI, future integrations) from day one to minimize schema-breaking operations. In Operational Mode, new capabilities still target the ideal state but must include migration and compatibility plans before release.

## 3. Data & Schema Design Principles (MongoDB)

### P-5: Unified Data Modeling (UDM)
We will employ a Unified Data Modeling approach. Each primary collection will be designed to support the needs of its primary entity *and* the anticipated aggregation and query patterns from other services. We will embed data when the relationship is 1:few and the data is queried together. We will reference data (using `$lookup`) when the relationship is 1:many or when the referenced data is frequently updated independently.

### P-6: Single Source of Truth (SSoT)
Each piece of data must have a single, unambiguous source of truth. For example, a **Partner's** business information resides *only* in the `partners` collection. An **Offering** document may cache a Partner's name for display, but the `partners` collection remains the SSoT. Caching is a deliberate performance optimization, not a data model.

### P-7: Immutability of Records
Transactions and historical records are immutable. A `Transaction` or `Payment`, once created, must never be altered. Corrections will be handled by issuing corresponding compensatory transactions (e.g., a `Refund` transaction). This guarantees a perfect, auditable financial and activity ledger.

### P-8: Explicit Schemas
While MongoDB is schema-flexible, our application layer (Laravel) is not. All models will have a strictly defined schema. All fields, data types, and "enum" values must be explicitly defined in the architectural documentation *before* implementation. This ensures data integrity, consistency, and provides a clear contract for all services.

### P-9: Consistent ID Naming
All primary keys for documents will be named `_id` and will use MongoDB's native `ObjectId`. All foreign keys (references to other documents) will be named using the singular entity name followed by `_id` (e.g., `user_id`, `partner_id`, `offering_id`). This provides predictable and self-documenting schemas.

### P-10: Native BSON Preservation
When persisting embedded documents or arrays, we will favor the database driver's native BSON serialization (e.g., MongoDB's `DocumentModel`) and only introduce custom attribute casts when explicit normalization is required. This prevents double-encoding, preserves `ObjectId` fidelity, and keeps multi-snapshot histories (such as device fingerprints) consistent across client contexts.

## 4. API & Service Design Principles (Laravel)

### P-10: Service-Oriented Logic
The Laravel application will be structured around Domain Services. Logic pertaining to a specific domain (e.g., "Booking," "Payments") will be encapsulated within its own service class. Controllers will be lightweight, responsible only for request/response handling and invoking these services. This ensures business logic is reusable, testable, and isolated.

### P-11: Stateless Authentication
All API endpoints will be stateless. Authentication will be managed via secure tokens (e.g., JWT or a similar standard). The server will not maintain session state, enabling horizontal scalability and simplifying client/server interaction.

### P-12: Resource-Oriented Naming
API endpoints will adhere to RESTful principles and resource-oriented naming. Endpoints will be structured as `/{version}/{resource}/{identifier}` (e.g., `/v1/offerings/`, `/v1/users/{user_id}`). We will use HTTP verbs (GET, POST, PUT, DELETE) to represent actions on those resources.

### P-13: Comprehensive Data Validation
All data entering the API (from any client) must be rigorously validated by the API layer. This includes type-checking, range validation, "enum" value checking, and business rule validation. The client-side (Flutter) validation is for user experience (UX) only; the API is the ultimate gatekeeper of data integrity.

### P-14: Defended Input Surfaces
Every externally supplied string or array is constrained to a documented, finite size that aligns with business intent (e.g., passwords 8–32 characters, display strings ≤255, email lists ≤10, permission lists ≤64, metadata payloads ≤8 KB). These bounds protect API surfaces from resource-exhaustion attacks, simplify capacity planning, and provide a repeatable contract for client implementers.

### P-15: Deterministic Pagination + Delta Streams
List endpoints are page-based by default to ensure predictable load and client caching. Real-time updates are delivered through delta streams (e.g., SSE) that emit only change events and never replace paginated listing contracts. Cursor pagination is reserved for narrowly scoped feeds where page-based ordering is insufficient.

## 5. Security & Identity Principles

### P-15: Principle of Least Privilege
All actors in the system (Users, Partners, AI agents) will operate under the principle of least privilege. An actor's access rights must be limited to the absolute minimum required to perform their function. We will utilize a robust Role-Based Access Control (RBAC) system.

### P-16: Segregation of Identity
A `User` (consumer) and a `Partner` (provider) are distinct domain entities. While a single person *may* be both, their identity, credentials, and data contexts will be managed separately within the system to ensure clear separation of concerns, permissions, and data.

### P-17: Data Privacy by Design
All personally identifiable information (PII) will be treated as sensitive. PII will be encrypted at rest, and access will be strictly logged and audited. API responses will be designed to *exclude* sensitive data by default, requiring explicit permissions to request it.

## 6. Deployment & Operations Principles

### P-18: Ingress Configuration Parity
Every time an API route, prefix, or host pattern is established or revised, we must synchronize those updates across all ingress layers (NGINX, load balancers, API gateways) and infrastructure manifests in the ecosystem. Documentation, local Docker templates, and production ingress definitions must stay in lockstep to avoid routing drift between environments.

## Appendix A: Flutter Application Tenets

These guidelines complement the core principles for any Flutter client implementation. Reference `foundation_documentation/flutter_architecture.md` for the full details.

1. **Feature-First Structure & Module Scopes** – Presentation folders follow `tenant/<feature>/screens/...` with controllers registered via `ModuleScope`. Controllers own `StreamValue` state and UI controllers; widgets remain pure UI.
2. **DTO → Domain → Projection Flow** – DTOs never reach widgets. Infrastructure mappers convert DTOs into ValueObjects; repositories expose domain entities/projections; controllers translate only when necessary. Projection diligence rules apply (ValueObjects expose UI-ready primitives).
3. **AutoRoute Governance** – New screens must be registered via AutoRoute, wrapped in their module scope, and guarded appropriately (tenant shell, auth). Route additions require documentation in the relevant module summary.
4. **Repository Contracts as API Blueprints** – When defining repositories, specify pagination, filtering, and scalability expectations. These contracts inform the Laravel persona about required API support and must be echoed in `foundation_documentation/persona_roadmaps.md` when backend work is pending.
5. **Analyzer Discipline** – `fvm flutter analyze` must stay clean. Any architectural method touching Flutter code ends with an analyzer run and, when feasible, targeted unit/widget tests.

## Appendix B: Laravel / API Tenets

These guidelines refine the core principles for the Laravel control plane and APIs. Reference `foundation_documentation/submodule_laravel-app_summary.md` for the live implementation snapshot.

1. **Multi-Tenant Routing Contracts** – Maintain the documented route groups: `/api/v1/initialize` (guest), `/admin/api/v1` (landlord middleware), `/api/v1` (tenant middleware), `/api/v1/accounts/{account_slug}` (tenant + account). Any change requires synchronized ingress updates (P‑18) and roadmap notes for Flutter clients.
2. **Tenant Resolution Chain** – Preserve the `DomainTenantFinder` → `SwitchMongoTenantDatabaseTask` sequence; new entry points must invoke the same resolver before touching tenant data.
3. **Sanctum + Ability Enforcement** – All endpoints are stateless and guarded by Sanctum abilities. Expanding abilities or scopes requires documentation updates plus corresponding Flutter contract changes.
4. **Controller-to-Service Migration** – Business logic should live in dedicated services, keeping controllers thin. When new APIs are introduced, budget time to move shared logic out of controllers per P‑10.
5. **Flutter Alignment** – Treat Flutter repository contracts and persona roadmap entries as the primary client requirements. Before altering payloads or adding endpoints, verify the Flutter blueprint and record any desync/resync effort in the Laravel roadmap section.
