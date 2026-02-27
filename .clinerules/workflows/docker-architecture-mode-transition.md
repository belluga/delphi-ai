---
name: docker-architecture-mode-transition
description: "Controlled workflow for switching between Foundational, Operational, and Expansion modes ensuring documentation, roadmaps, and enforcement rules stay coherent."
---

# Workflow: Architecture Mode Transition

## Purpose

Provide a controlled workflow for switching between Foundational, Operational, and Expansion modes. Ensures documentation, roadmaps, and enforcement rules stay coherent during the transition.

## Triggers

- First production tenant onboards (Foundational → Operational)
- Major re-architecture initiative launches alongside live system (Operational → Expansion)
- Expansion work completes and merges back into Operational baseline

## Prerequisites

- [ ] Current `system_architecture_principles.md` reviewed
- [ ] CTO/Tech Lead persona doc available
- [ ] Project mandate, domain entities, submodule summaries reviewed
- [ ] Any regulatory/business timelines understood

## Procedure

### Step 1: Persona Alignment

Run Persona Selection as **CTO/Tech Lead** - this is an architecture decision.

### Step 2: Assess Readiness

Verify triggers have been met:

**Foundational → Operational:**
- [ ] Production tenant exists
- [ ] Core features stable
- [ ] Monitoring in place

**Operational → Expansion:**
- [ ] Expansion initiative approved
- [ ] Parallel track approved
- [ ] Resources allocated

**Expansion → Operational:**
- [ ] Migration complete
- [ ] Tests passing
- [ ] Documentation updated

### Step 3: Document Target Mode

Update `system_architecture_principles.md`:

**Foundational Mode:**
- Ideal-state architecture
- No backward-compatibility
- Rapid iteration allowed

**Operational Mode:**
- Production stability required
- Backward-compatibility for live tenants
- Migration paths documented
- Feature flags for rollout

**Expansion Mode:**
- Parallel development track
- Feature branches isolated
- Merge strategy defined
- Compatibility windows enforced

### Step 4: Update Roadmaps

Record transition in `persona_roadmaps.md`:

```markdown
## Architecture Mode: Operational (Effective 2024-01-15)

### Flutter Engineer Actions
- Implement feature flags for new features
- Maintain backward-compatible API calls
- Version bump for breaking changes

### Laravel Engineer Actions
- API versioning required
- Migration scripts for schema changes
- Deprecation notices for old endpoints

### DevOps Engineer Actions
- Blue-green deployment support
- Rollback procedures documented
- Monitoring for migration issues
```

### Step 5: Notify Submodules

Add notes to `submodule_*_summary.md`:

```markdown
## Operational Constraints (Effective 2024-01-15)

- API versioning: `/api/v1/` → `/api/v2/` for breaking changes
- Feature flags: Use `Feature::enabled('new_flow')`
- Deprecation: 30-day notice for endpoint removal
```

### Step 6: Update Method References

Ensure affected workflows mention new requirements:

| Workflow | Operational Requirement |
|----------|------------------------|
| `create-api-endpoint` | Add API version to route |
| `create-domain` | Include migration script |
| `create-repository` | Support old+new data shapes |

### Step 7: Session Communication

State the mode clearly:
- In session summary
- In commit messages
- In PR descriptions

```
Mode: Operational
Breaking changes: None
Feature flags: new_booking_flow
Migration: bookings_v2 migration required
```

## Mode Definitions

### Foundational Mode
- **Focus:** Establish ideal architecture
- **Compatibility:** None required
- **Iteration:** Rapid, breaking changes OK
- **Documentation:** Forward-looking only

### Operational Mode
- **Focus:** Production stability
- **Compatibility:** Backward-compatible required
- **Iteration:** Controlled, feature-flagged
- **Documentation:** Migration paths included

### Expansion Mode
- **Focus:** Parallel development
- **Compatibility:** Isolated feature branches
- **Iteration:** Separate track, merge later
- **Documentation:** Merge strategy defined

## Outputs

- [ ] Updated `system_architecture_principles.md`
- [ ] Persona roadmaps updated with mode responsibilities
- [ ] Submodule summaries with operational constraints
- [ ] Method updates or TODOs for new policies

## Validation Checklist

- [ ] All personas acknowledge new mode
- [ ] CI/checklist updates for new gates
- [ ] Migration verification tests exist
- [ ] Documentation reflects current mode