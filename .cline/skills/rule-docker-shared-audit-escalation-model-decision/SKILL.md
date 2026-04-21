---
name: rule-docker-shared-audit-escalation-model-decision
description: "Rule: MUST use whenever a tactical TODO needs deterministic audit-floor decisions for critique, final review, test-quality audit, or specialized assurance lanes."
---

## Rule
Before Delphi trusts audit decisions on a tactical TODO, it must require the canonical `Audit Trigger Matrix` and run:

```bash
python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path>
```

The guard result is the minimum required audit floor:
- stricter manual escalation is allowed;
- weaker execution is forbidden;
- any material trigger change requires a rerun.

The derived floor must be recorded into the correct TODO lifecycle sections:
- critique before `APROVADO`
- delivery-side audits after implementation and primary evidence
- security/performance/debt in their canonical delivery gates
- triple review as additive only unless a future canonical rule explicitly says otherwise

See:
- `workflows/docker/audit-escalation-method.md`
- `rules/core/audit-escalation-model-decision.md`
