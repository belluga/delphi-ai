# Roadmap de Evolução PACED (Branch `manus`)

Este documento detalha as melhorias estruturais planejadas para o framework PACED, focadas em duas frentes: operacionalização da Fase 0 (métricas empíricas) e expansão do determinismo T.E.A.C.H. nas skills.

## Frente 1: Operacionalização da Fase 0

O objetivo é conectar o trabalho que já ocorre organicamente (Triple Audits, fechamento de TODOs) ao ledger de eventos (`rule-events.jsonl`), sem adicionar etapas manuais ao fluxo do agente.

### 1. Gatilho de Consolidação de Métricas (Prioridade: Alta)
- **O que:** Um script que roda no fechamento de uma sessão ou TODO, extraindo *findings* com `formalizable_hint=yes` dos arquivos de audit (`artifacts/tmp/`) e apensando-os ao `rule-events.jsonl`.
- **Por que:** Transforma o esforço de revisão existente no motor de alimentação da Fase 0.
- **Onde atuar:** Criar script `tools/metrics_consolidation_trigger.sh` e adicionar regra de execução no `main_instructions.md`.

### 2. Recuperação de Sessão e Handoff (Prioridade: Alta)
- **O que:** Um protocolo e script para gerenciar sessões ativas (`todos/sessions/session-<id>.md`), permitindo que o agente recupere o contexto de TODOs após compactação ou passe o bastão para outro agente.
- **Por que:** Evita TODOs zumbis e perda de contexto em projetos complexos.
- **Onde atuar:** Criar script `tools/session_state_manager.sh` e atualizar `main_instructions.md`.

## Frente 2: Determinismo T.E.A.C.H. nas Skills

O objetivo é substituir diretrizes probabilísticas (prompts) por ferramentas determinísticas que bloqueiam ações prematuras e ensinam o caminho correto.

### 3. Guard de Fechamento de TODO (Prioridade: Média)
- **O que:** Um script `todo_completion_guard.sh` que verifica se um TODO pode ser movido para `completed/`. Verifica: preenchimento de gates, waivers documentados, resolution tables e evidência de execução.
- **Por que:** Impede que o agente declare sucesso em TODOs parcialmente preenchidos, garantindo o rigor do framework.
- **Onde atuar:** Criar o script e integrá-lo como passo obrigatório nas skills de execução.

### 4. Validador de Constituição (Prioridade: Baixa)
- **O que:** Um preflight check que roda antes de iniciar o desenvolvimento em um novo módulo, verificando se a Constitution (`project_mandate`, `policies`) está adequadamente lida e referenciada.
- **Por que:** Garante que o agente não comece a codar sem o DNA do projeto carregado no contexto.
- **Onde atuar:** Script `tools/constitution_preflight.sh`.

## Plano de Execução

Iniciaremos a implementação pelos itens de Prioridade Alta (Gatilho de Consolidação e Recuperação de Sessão), pois eles resolvem os gargalos operacionais mais imediatos da Fase 0. Em seguida, avançaremos para o Guard de Fechamento de TODO.
