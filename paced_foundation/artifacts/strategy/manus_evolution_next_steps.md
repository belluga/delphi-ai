# Proposta Consolidada: Próximos Passos de Evolução PACED

Com base na auditoria da Fase 0 e nas discussões sobre o determinismo nas skills, proponho o seguinte plano de ação imediato para a branch `manus`. O foco é resolver os problemas mais caros e frequentes do trabalho com agentes LLM, substituindo *Governance by Prompt* por **Apoio Determinístico (T.E.A.C.H.)**.

## 1. Guard Determinístico de Fechamento de TODO (Prioridade: Alta)

**O Problema:** Agentes se perdem durante a execução, esbarram em bloqueios adjacentes e declaram o TODO como "concluído" sem finalizar todos os itens ou sem documentar adequadamente as pendências.
**A Solução:** Um script `tools/todo_completion_guard.sh` que atua como barreira intransponível antes de mover um TODO para `completed/`.

**Mecânica T.E.A.C.H.:**
- **Triggered:** Disparado explicitamente quando o agente tenta finalizar a tarefa.
- **Enforced:** Retorna exit code 2 se houver pendências não justificadas.
- **Contextual/Hinting:** 
  - Se faltam marcações: *"Você tem 3 itens não marcados no checklist. Complete-os ou adicione um bloco de 'Waivers' justificando a pendência."*
  - Se faltam gates: *"O Critique Gate não foi preenchido. Execute o gate ou declare 'not_needed' com justificativa."*

## 2. Guard de Impacto de Findings (Prioridade: Alta)

**O Problema:** Findings do Copilot ou de revisões têm "autoridade implícita". O agente os aplica cegamente, correndo o risco de alterar lógicas de negócio (ex: ordem de fallbacks) de forma silenciosa.
**A Solução:** Um script `tools/finding_impact_classifier.sh` que analisa o diff de um finding antes de sua aplicação.

**Mecânica T.E.A.C.H.:**
- **Triggered:** Disparado ao processar findings que alteram código fonte.
- **Enforced:** Bloqueia a aplicação automática se detectar mudanças estruturais (condicionais, loops) ou toques em arquivos marcados como "decisão de negócio".
- **Contextual/Hinting:** *"Este finding altera o fluxo condicional (if/else) no arquivo X. Classifique o impacto (cosmetic/refactor/logic-change). Se for logic-change, verifique a Constitution e exija validação humana explícita antes de aplicar."*

## 3. Gestão de Sessão e Recuperação de Contexto (Prioridade: Média)

**O Problema:** Compactações de contexto ou falhas de sessão fazem o agente esquecer quais TODOs estavam ativos, gerando TODOs "zumbis".
**A Solução:** Implementar um protocolo de *Session Lock* e um arquivo de estado da sessão (`todos/sessions/current-session.md`).

**Mecânica:**
- No início da sessão, o agente lê ou cria seu ID de sessão.
- Marca os TODOs ativos com seu *lock*.
- Após compactação, recupera o estado lendo o arquivo da sessão.
- **Handoff:** Se uma sessão morre, um novo agente pode identificar *stale locks* e assumir o trabalho de onde parou.

## 4. Gatilho de Consolidação de Métricas (Fase 0) (Prioridade: Média)

**O Problema:** Os dados da Fase 0 (eventos de regras) estão sendo gerados pelos Triple Audits, mas ficam presos em arquivos temporários. O pipeline de métricas não é alimentado.
**A Solução:** Conectar o fechamento da sessão/TODO à extração de métricas.

**Mecânica:**
- Ao passar pelo Guard de Fechamento de TODO (Item 1), um gatilho automático extrai todos os *findings* com `formalizable_hint=yes` dos arquivos de audit vinculados àquele TODO.
- Apensa esses *findings* ao `rule-events.jsonl`.
- Transforma a revisão orgânica no motor de alimentação da Fase 0 sem fricção adicional.

---

**Por onde começar?**
Sugiro iniciarmos pelo **Guard de Fechamento de TODO (Item 1)**. Ele ataca a dor mais frequente (entregas incompletas) e estabelece o padrão de "Apoio Determinístico" que usaremos nos outros scripts.
