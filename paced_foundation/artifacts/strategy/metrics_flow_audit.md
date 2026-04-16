# Auditoria dos Fluxos Geradores de Métricas

**Data:** 2026-04-16
**Auditor:** Manus (branch `manus`)

## Produtores de rule-events.jsonl

| Script | source_kind | Schema-valid? | Notas |
| --- | --- | --- | --- |
| `todo_deterministic_validator.py` | `validator` | SIM | Referência gold. Emite `rule_block_observed` e `rule_episode_resolved`. Usa `validate_schema()`. |
| `rule_event_record.py` | `manual` / arg | SIM | Emite `rule_block_observed`, `rule_episode_resolved`, `rule_escape_recorded`. Usa `validate_schema()`. |
| `todo_completion_guard.py` | `completion_guard` | **NÃO** | `source_kind: "completion_guard"` não está no enum do schema (`ci|lint|analyzer|validator|hybrid|manual`). **BUG.** |
| `finding_impact_classifier.py` | N/A | N/A | Não emite rule events (apenas classifica). OK. |
| `session_lock_manager.py` | N/A | N/A | Não emite rule events. OK. |

## Consumidores de rule-events.jsonl

| Script | O que consome | Notas |
| --- | --- | --- |
| `seed_rule_catalog.py` | `rule_catalog.json` | Gera catálogo de regras. Não consome events diretamente. |
| `paced_metrics_core.py` | Funções utilitárias | Provê `append_jsonl`, `load_jsonl`, `build_rule_*`. Não consome diretamente. |
| `todo_deterministic_validator.py` | `rule-events.jsonl` | Lê eventos prévios para detectar episódios abertos e emitir resoluções. |

## Problemas Encontrados

### P-01: source_kind enum incompleto no schema (ALTA)
- **Arquivo:** `schemas/rule_event.schema.json`
- **Problema:** O enum de `source_kind` é `["ci", "lint", "analyzer", "validator", "hybrid", "manual"]`. O novo `todo_completion_guard.py` usa `"completion_guard"` que não está no enum.
- **Fix:** Adicionar `"completion_guard"` ao enum, ou usar `"validator"` no completion guard.
- **Decisão:** Expandir o enum para incluir `"completion_guard"` — é semanticamente distinto de `"validator"` (um valida formato, outro valida completude).

### P-02: todo_completion_guard.py não usa validate_schema() (MÉDIA)
- **Arquivo:** `tools/todo_completion_guard.py`
- **Problema:** Emite rule events sem chamar `validate_schema()` antes de `append_jsonl()`.
- **Fix:** Adicionar chamada de validação antes de emitir.

### P-03: episode_id ausente nos events do completion guard (MÉDIA)
- **Arquivo:** `tools/todo_completion_guard.py`
- **Problema:** O schema exige `episode_id` para `rule_block_observed`, mas o completion guard não emite `episode_id`.
- **Fix:** Adicionar `episode_id` usando `build_rule_episode_id()` ou `next_rule_episode_id()`.

### P-04: Campos faltantes nos events do completion guard (MÉDIA)
- **Arquivo:** `tools/todo_completion_guard.py`
- **Problema:** `resolution_instruction` é obrigatório para `rule_block_observed` mas o campo é chamado `"resolution"` no guard.
- **Fix:** Renomear para `"resolution_instruction"` no payload.

## Plano de Correção

1. Expandir `source_kind` enum no schema para incluir `"completion_guard"`
2. Corrigir `todo_completion_guard.py`: adicionar `validate_schema()`, `episode_id`, renomear `resolution` → `resolution_instruction`
3. Verificar que todos os produtores passam na validação de schema
