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
