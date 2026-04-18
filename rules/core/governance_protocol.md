# Protocolo de Governança de Regras (PACED Rule Governance)

Este protocolo orquestra o ciclo de vida das regras no ecossistema PACED, transformando descobertas táticas em autoridade técnica determinística. Ele é obrigatório para qualquer agente (Gemini, Codex, Cline, Manus) operando sob a governança PACED.

## 1. Os 4 Funis de Evidência (Ingestion)

O agente DEVE escanear estas 4 fontes antes de propor qualquer regra:

| Funil | Fonte de Dados | O que procurar |
| :--- | :--- | :--- |
| **Audit** | `metrics-consolidation-report.json` | Findings com `formalizable: yes|partial` |
| **Drift** | `verify_context.sh` (NO-GO) | Divergência entre o projeto local e o PACED global |
| **Recalibração** | `rule-events.jsonl` | Alta taxa de **Escapes** (erros que o guard não pegou) |
| **Scan** | Código-fonte atual | Padrões de erro repetitivos ou correções manuais frequentes |

## 2. Matriz de Decisão (Triage)

Ao identificar um candidato, o agente deve classificá-lo:

*   **Global (delphi-ai/deterministic/core):** Se protege a **Arquitetura Base** (Isolamento de Tenant, Acoplamento de Pacotes, Segurança de API, MongoDB Casts).
*   **Local (foundation_documentation/deterministic):** Se protege a **Lógica de Negócio** (Regras de Checkout, Promo Codes, Branding, Favoritos).

## 3. Ritual do Veredito (Obrigatório)

O agente NUNCA deve consolidar uma regra sem apresentar esta tabela ao usuário (Marcelo):

| Origem | Candidato a Regra | Evidência (Count/Impact) | Sugestão | Veredito |
| :--- | :--- | :--- | :--- | :--- |
| [Funil] | [Nome da Regra] | [Ex: 3 escapes / 1 drift] | [Global/Local] | [ ] |

## 4. Execução da Extração (Cirurgia)

Após o veredito, siga o protocolo de acordo com a stack:

### Para Laravel:
1.  **Local:** Criar/Editar `foundation_documentation/deterministic/rules/local_business_rules.php` usando o template do PACED.
2.  **Global:** Criar PR para `delphi-ai/deterministic/stacks/laravel/scripts/`.
3.  **Link:** Declarar a regra no `foundation_documentation/deterministic/laravel.json`.

### Para Flutter:
1.  **Local:** Criar/Editar `tool/paced_local_plugin/` (se for regra de lint exclusiva).
2.  **Global:** Evoluir o `tool/paced_global_plugin/` e consolidar no `delphi-ai`.

## 5. Fechamento de Ciclo
Sempre rodar `bash delphi-ai/verify_context.sh --repair` após a extração para validar que a nova regra está ativa e o ambiente está íntegro.

---

## 6. Cascading Patterns & Anti-Patterns

### 6.1 Hierarquia de Autoridade

Patterns e Anti-Patterns seguem a mesma cascata de autoridade do PACED:

| Nível | Diretório | Precedência | Quem Mantém |
| :--- | :--- | :--- | :--- |
| **Core** | `delphi-ai/patterns/core/` | Mais baixa (base universal) | Strategic (Manus/Marcelo) |
| **Stack** | `delphi-ai/patterns/stacks/<namespace>/` | Média (específico da stack) | Strategic + Operational |
| **Local** | `foundation_documentation/patterns/local/` | Mais alta (específico do projeto) | Operational (Codex/Cline) |

**Regra de resolução:** Local sobrescreve Stack, Stack sobrescreve Core. Toda sobrescrita DEVE ser explícita via campo `supersedes` no `_index.json`. Shadowing silencioso é uma violação.

### 6.2 Integração T.E.A.C.H.

O componente **E (Enforced)** do T.E.A.C.H. agora inclui a obrigação de rastreabilidade de patterns:

> **Enforced Rule — Pattern Traceability:**
> Quando um TODO implementa ou se baseia em um pattern catalogado, o agente DEVE incluir a referência `[PATTERN: <id>]` no corpo do TODO (preferencialmente na seção de decisão ou na DoD). O `todo_completion_guard.py` valida que todos os IDs referenciados existem na cadeia de autoridade.

### 6.3 Ciclo de Vida de um Pattern

```
Descoberta (sessão/audit) → [PATTERN] tag na session_memory
        ↓
Reconciliação (reconcile_session.py) → project_memory.md
        ↓
Formalização (humano/strategic) → pattern_template.md + _index.json
        ↓
Enforcement (guard) → Validação de referências em TODOs
```

### 6.4 Promoção de Anti-Patterns

O `reconcile_session.py` rastreia anti-patterns via `[ANTI-PATTERN]` tags e mantém um ledger de frequência (`anti_pattern_ledger.json`). Quando um anti-pattern atinge o threshold de recorrência (2x), o sistema:

1. Gera um **candidato de promoção** em `foundation_documentation/patterns/candidates/`.
2. O candidato é revisado pelo Strategic (Manus/Marcelo).
3. Após aprovação, é formalizado como anti-pattern no nível apropriado (local/stack/core).

### 6.5 Validação Determinística

O `todo_completion_guard.py` valida referências `[PATTERN: id]` em TODOs:

| Violação | Código | Ação |
| :--- | :--- | :--- |
| ID não existe em nenhum nível | `PATTERN-PHANTOM-REFERENCE` | **Bloqueia** — criar o pattern ou remover a referência |
| ID está deprecated | `PATTERN-DEPRECATED-REFERENCE` | **Bloqueia** — atualizar para o pattern substituto |
| ID foi sobrescrito por nível superior | `PATTERN-OVERRIDDEN-REFERENCE` | **Aviso** — considerar usar o override |
