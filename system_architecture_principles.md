# Documentation: System Architecture Principles
**Version:** 1.0

## 1. Introduction

This document defines the architectural constitution for **our digital ecosystems**. These principles are the foundational source of truth for all design and engineering decisions. They are established to ensure any system we build is scalable, resilient, maintainable, and aligned with our core business objectives from its inception.

All modules, services, and schemas designed for this platform **must** adhere to these principles.

## 2. Core Architectural Philosophy

### P-1: Domain-First, Schema-Second
Our architecture is designed around the **Core Business Entities** defined in the `domain_entities.md` document. All system design decisions must originate from the needs of these domains. The technology (MongoDB, Laravel) is chosen to serve the domain, not the other way around. We will design our data structures to reflect real-world entities and their relationships, not to satisfy a specific storage mechanism.

### P-2: Document-Oriented by Default
We select MongoDB as our primary database. This choice mandates a document-oriented mindset. We will prioritize embedding related data within a single document over normalization (splitting data into multiple collections) wherever it aligns with a clear access pattern. This principle supports performance and data co-location.

### P-3: API-Centric Ecosystem
The system is defined as a set of services exposed via a secure, stable, and versioned API. The Laravel backend serves as the headless API provider. The Flutter application and any future clients (web, partner integrations) are pure consumers of this API. There will be no business logic within the client applications that is not also enforced by the API.

### P-4: Foundational, Not Minimalist
This architecture is the definitive foundation, not a minimal viable product (MVP). Schemas and services will be designed with a long-term vision, incorporating fields and capabilities (e.g., for analytics, AI, future integrations) from day one. This ensures forward compatibility and minimizes schema-breaking operations.

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
