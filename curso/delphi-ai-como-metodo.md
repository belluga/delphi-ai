# Delphi AI como Concretizacao do Metodo

## Leitura geral
O repositorio `delphi-ai` nao e apenas um conjunto de prompts. Ele codifica um metodo de trabalho completo: bootloaders por agente, readiness do ambiente, workflows obrigatorios, regras executaveis, TODOs taticos persistentes, gates de aprovacao, validacao de aderencia e consolidacao do aprendizado em documentacao canonica.

## 1. O metodo e multi-agente desde a raiz
O `README.md` define bootloaders diferentes por ferramenta:
- Cline: `.clinerules/` e `.cline/skills/`
- Codex/Antigravity: `AGENTS.md`, `.codex/skills/`, `.agents/`
- Gemini: `GEMINI.md`, `.agents/skills/`

Isso e importante para a aula porque mostra que o metodo nao depende de uma unica IA; ele separa:
- bootloader
- artifacts por agente
- regras compartilhadas
- surfaces especificas por ferramenta

## 2. O repositorio trata setup e contexto como parte do produto
`init.sh`, `verify_context.sh`, `verify_adherence_sync.sh` e `initialization_checklist.md` mostram que o ambiente precisa carregar as instrucoes corretas antes do trabalho.

Mensagem pedagogica:
- Sem readiness, a IA trabalha com contexto quebrado.
- Configuracao do ambiente nao e detalhe operacional; e parte da confiabilidade do sistema.

## 3. Sessao tambem tem governanca
`workflows/docker/session-lifecycle-method.md` mostra que a sessao tem:
- start
- proposito
- reload quando instrucoes mudam
- fechamento com review

Ponto importante para aula:
- Instrucoes sao tratadas como codigo vivo.
- Se o metodo muda durante a sessao, o agente precisa reler antes de voltar ao trabalho normal.

## 4. O centro do metodo nao e "plan"; e TODO tatico persistente
`main_instructions.md` e `workflows/docker/todo-driven-execution-method.md` deixam claro:
- para implementacao, o agente deve usar um TODO tatico em `foundation_documentation/todos/active/`
- para regressao/maintenance fix, pode usar TODO efemero em `foundation_documentation/todos/ephemeral/`
- toda mudanca relevante exige refinamento do TODO e `APROVADO`

Esse e um ponto fortissimo para o curso:
- o plano embutido da IA e temporario
- o TODO tatico e memoria operacional persistente, versionavel e retomavel
- por isso ele serve melhor para continuidade entre sessoes e agentes

## 5. O TODO nao e fonte de verdade isolada
O workflow exige:
- anchors para modulos canonicos
- promotion targets
- comparacao 1:1 entre decisoes do TODO e decisoes canonicas
- gate de consistencia antes de executar

Traducao didatica:
- o TODO e contrato de execucao
- a documentacao canonica e autoridade arquitetural
- isso evita que a execucao tatica vire uma "segunda arquitetura" concorrente

## 5.1. O metodo combina SDD com TDD
O Delphi esta cada vez mais claramente apoiado em duas camadas complementares:
- **SDD** para definir o contrato do trabalho
- **TDD/test-first** para provar esse contrato durante a execucao

Na pratica:
- `project_constitution`, `system_roadmap`, `module` e `TODO` definem o que precisa ser verdade
- `profiles` definem quem pode tocar o quê e quando deve haver handoff
- `assumptions` e `execution plan` definem como a mudanca pretende chegar la
- os testes funcionam como prova executavel de que o comportamento prometido realmente existe

Essa formulacao ajuda muito na aula porque separa dois tipos de erro:
- **SDD** reduz erro de direcao
- **TDD** reduz erro de implementacao e falsa confianca

Isso tambem conversa com a tese central do curso:
- escrever rapido nao basta
- e preciso validar rapido sem perder controle do contrato do sistema

## 6. Ha um mecanismo formal para separar decisao material de detalhe local
No `TODO-Driven Execution`, todo achado e triado como:
- `Material Decision`
- `Implementation Detail`
- `Redundant/Already Covered`

Isso e excelente para sua aula, porque traduz um problema real de IA:
- sem esse filtro, o agente vira uma maquina de abrir pseudo-decisoes
- com esse filtro, reduz churn decisorio e ruido no processo

## 7. Aprovacao explicita e gate de aderencia sao parte do metodo
Antes de mudar artefatos do projeto:
- o agente precisa refinar o TODO
- congelar baseline de decisoes
- pedir `APROVADO`

Antes de entregar:
- precisa rodar `Decision Adherence Gate`
- provar aderencia com evidencia

Mensagem pedagogica:
- nao basta "implementou o combinado"
- precisa provar aderencia ao combinado

## 8. Aprendizado nao morre no TODO; ele e promovido
O workflow exige `Module Consolidation Gate`:
- promover resultados estaveis para docs canonicos
- atualizar ledger de promocao
- remover notas taticas superseded

O `templates/module_template.md` reforca isso com:
- `Canonical Decision Register`
- `Canonical Coverage Status`

Esse talvez seja um dos pontos mais sofisticados do metodo:
- o TODO nao e destino final
- ele e uma area de trabalho tatica
- o conhecimento estavel precisa ser promovido para a camada canonica
- e as decisoes duraveis ficam no modulo como verdade atual, nao como log infinito de execucao

## 9. Rules e workflows estao acoplados deliberadamente
O repositorio nao trata workflow como texto solto. Ha regra pedindo que todo workflow relevante tenha:
- scaffold consistente
- contraparte de rule
- referencia explicita entre rule e workflow

Mensagem para a aula:
- procedimento sem trigger vira aspiracao
- workflow so funciona de verdade quando o sistema sabe quando aplica-lo

## 10. Flutter: arquitetura vira contrato executavel
`skills/flutter-architecture-adherence/SKILL.md` mostra:
- fontes canonicas
- lint contract executavel
- lista de rule IDs
- ownership de controller/UI/state
- politica de "sem excecao": calibrar lint em vez de suprimir finding

Isso sustenta diretamente sua tese de que:
- prompt nao basta
- o melhor caminho e transformar principios em contrato executavel

## 11. Packages aparecem como eixo arquitetural diferente dos TODOs
`skills/wf-laravel-create-package-method/SKILL.md` mostra que package, aqui, e:
- fronteira de acoplamento
- contrato/adaptador
- ownership de rotas
- classificacao de multitenancy
- README fiel para onboarding de humano e IA
- decoupling assertions e full-suite validation

Conclusao didatica:
- `TODO slices` e `packages` resolvem problemas diferentes
- TODO slice: continuidade operacional
- package: modularidade, reaproveitamento, manutencao e seguranca compartilhada

## 12. Teste e tratado como governanca, nao so como cobertura
`skills/test-creation-standard/SKILL.md` mostra preocupacoes explicitas com:
- falsos positivos
- blocked vs failed
- anti-bypass
- cobertura por camadas
- real backend para claims de compatibilidade
- prova de aderencia das decisoes de teste

Isso encaixa perfeitamente no seu discurso sobre:
- cuidado com falso verde
- teste como instrumento de confianca real
- necessidade de distinguir falha de produto de falha de harness/ambiente

## 13. O metodo tambem governa promocao e CI
`skills/github-stage-promotion-orchestrator/SKILL.md` e `.github/workflows/instruction-integrity.yml` mostram:
- promocao por lane
- root cause antes de retry
- review de Copilot como gate
- CI protegendo a propria integridade do sistema de instrucoes

Mensagem forte:
- o metodo se protege de drift
- ate as instrucoes possuem verificacao automatizada

## 14. Visao de fundo do Delphi AI
Lendo `system_architecture_principles.md`, a visao por tras do metodo parece ser:
- arquitetura ideal-state, nao MVP simplificado
- domain-first
- API-centric
- escopo/subscope explicitos
- contratos e invariantes documentados
- compatibilidade governada por modo arquitetural

Em outras palavras:
- primeiro define-se a constituicao do sistema
- depois a execucao tatica fica subordinada a ela

## Como isso pode entrar na aula
### Mensagens fortes
- Delphi AI e um exemplo de "programacao estruturada com IA".
- O repositorio transforma opinioes em mecanismos.
- O processo nao confia em memoria de sessao como unica fonte.
- O TODO tatico faz a ponte entre execucao local e conhecimento persistente.
- O conhecimento estavel e promovido para a camada canonica.

### Formulacoes boas
- "Nao e prompt engineering isolado; e design do sistema de trabalho."
- "O agente nao opera solto: ele entra por bootloader, passa por readiness, segue workflow, executa sob TODO e entrega com prova de aderencia."
- "A memoria persistente do trabalho nao esta no chat; esta nos artefatos canonicos e taticos."
