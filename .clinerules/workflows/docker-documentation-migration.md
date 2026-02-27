---
name: docker-documentation-migration
description: "Turn temporary or legacy documentation into canonical Delphi documentation set using templates, close gaps, and produce progressive milestones plus team task lists."
---

# Workflow: Documentation Migration & Expansion

## Purpose

Turn temporary or legacy documentation (e.g., scratch specs, prototype UI notes) into the canonical Delphi documentation set using templates, close gaps, and produce progressive milestones plus team task lists.

## Triggers

- Temporary documentation needs to be made canonical
- Legacy docs need migration to current templates
- Gap analysis required for documentation coverage

## Prerequisites

- [ ] Run `bash delphi-ai/tools/verify_context.sh` - fix any failures
- [ ] Load main instructions and always_on rules
- [ ] Identify source docs and target templates
- [ ] Confirm submodule scope if task lists needed

## Procedure

### Step 1: Load Core Context

Load:
- System principles
- Project mandate
- Relevant module templates

**Do NOT edit temporary files directly.**

### Step 2: Inventory Source Materials

Identify:
- Temporary files (`foundation_documentation/temporary_files/*`)
- PRDs and specs
- Prototype screens
- Uploaded specifications

Classify each:
- **Authoritative** - Use as source of truth
- **Outdated** - Note but don't migrate
- **Partial** - Needs completion

### Step 3: Map Scope

Determine requirements:
- [ ] Required modules
- [ ] Domain entities
- [ ] API endpoints
- [ ] Screens/views
- [ ] Real-time needs
- [ ] Landlord vs tenant boundaries

### Step 4: Gap Analysis

Check for missing documentation:

| Area | Check For |
|------|-----------|
| Validation | Bounds, formats, constraints |
| Enums | All values defined with descriptions |
| Auth/Abilities | Sanctum abilities, policies |
| Real-time | SSE/WebSocket definitions |
| Rankings/Badges | Event → job → broadcast flow |
| Profile | User profile schema |
| Catalog | Product/service rules |
| Roadmaps | Implementation status |

### Step 5: Create/Update Canonical Docs

Use templates for:

**Project Mandate:**
```markdown
# Project Mandate

## Vision
[Project vision]

## Core Business Principles
- [Principle 1]
- [Principle 2]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

**Domain Entities:**
```markdown
# Domain Entity: [Name]

## Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | yes | Unique identifier |

## Invariants
- [Business rule 1]

## Enums
- Status: pending, active, completed
```

**Endpoints:**
```markdown
## Endpoint: [Name]

**Status:** Defined | Mocked | Implemented | Tested & Ready

**Method:** GET | POST | PUT | DELETE
**Path:** /api/v1/resource
**Auth:** sanctum + ability

### Request
[Schema]

### Response
[Schema]

### Rate Limit
X requests per minute
```

### Step 6: Add Milestones

Create progressive implementation milestones:

```markdown
## Milestone 1: Core API
- [ ] Domain model defined
- [ ] Migration created
- [ ] Controller implemented
- [ ] Tests passing
**Target:** Week 1

## Milestone 2: Real-time Updates
- [ ] SSE endpoint created
- [ ] Client integration
- [ ] Fallback polling
**Target:** Week 2
```

### Step 7: Produce Team Task Lists

**Flutter Tasks:**
```markdown
- [ ] Create booking screen
  - Controller: BookingController
  - Screen: BookingScreen
  - Tests: Widget tests
```

**Laravel Tasks:**
```markdown
- [ ] Create booking endpoint
  - Route: POST /api/v1/bookings
  - Validation: BookingStoreRequest
  - Tests: Feature tests
```

### Step 8: Document Real-time Flows

If badges/rankings/real-time introduced:

```markdown
## Event Flow

1. User action triggers event
2. Event stored in database
3. Job processes event
4. Job broadcasts via SSE
5. Client receives update

## Fallback
If SSE unavailable, poll `/api/v1/events` every 30s
```

### Step 9: Surface Landing Content

Document unauthenticated content for client teams:
- Landing page content
- Public endpoints
- Marketing copy

**Do not embed in temp code - document only.**

## Outputs

- [ ] Updated canonical docs in `foundation_documentation/`
- [ ] Progressive milestones defined
- [ ] Team task lists created
- [ ] Real-time payload definitions (if applicable)
- [ ] Roadmap status updated

## Validation Checklist

- [ ] All docs in `foundation_documentation/` (not temp files)
- [ ] Template structure followed
- [ ] Endpoints listed with statuses
- [ ] Indexes/rate limits/enums documented
- [ ] No edits to temporary files