# Estrutura de Slides - Aula 1

## Identidade usada nesta aula
**Programacao Estruturada com IA**  
Como acelerar o desenvolvimento com IA mantendo qualidade de codigo e uma arquitetura escalavel

## Nome recomendado da Aula 1
**Arquitetura, Regras e Fluxo de Trabalho**

## Direcao da aula
Sequencia narrativa:
1. Conceituacao geral.
2. Limites e riscos reais do trabalho com IA.
3. Exemplos praticos de desvio.
4. Transicao para "como eu trabalho".
5. Estrutura do Delphi AI.
6. Sessao padrao de trabalho.
7. Convite para a Aula 2.

## Formato de cada slide
- `Objetivo`: para que o slide existe.
- `Visual`: print, diagrama ou tela sugerida.
- `Pontos`: o que precisa aparecer intelectualmente.
- `Frases/teses tecnicas`: formulacoes seguras e uteis para orientar sua fala.

---

## Slide 1 - Titulo e tese da aula
### Objetivo
Abrir com a ideia central da aula.

### Visual
- Slide limpo, sem print.
- Talvez uma frase central em destaque.

### Pontos
- Programacao com IA nao e ausencia de metodo.
- O problema principal nao e "qual ferramenta usar".
- O problema principal e "como estruturar o trabalho para ela acertar com aderencia".

### Frases/teses tecnicas
- IA nao substitui engenharia; ela amplifica a engenharia existente.
- A mesma IA, em contextos diferentes, pode produzir resultados dramaticamente diferentes.

---

## Slide 2 - O que a IA faz bem e onde ela falha
### Objetivo
Tirar a conversa do hype e colocar no terreno pratico.

### Visual
- Tabela simples: "forte" vs "fraco".

### Pontos
- Forte em velocidade, varrida de contexto local, boilerplate, exploracao, sugestao e sintese.
- Fraca em ownership difuso, contexto ruidoso, precedentes ruins, invariantes implicitos e diagnostico sob ambiguidade.

### Frases/teses tecnicas
- O modelo e bom em completar padroes, nao em descobrir sozinho qual padrao deveria ser soberano.
- Em codigo, ele tende a tratar contexto aparente como verdade provavel.

---

## Slide 3 - Contexto validado vira precedente tecnico
### Objetivo
Explicar por que arquitetura e limpeza importam mais com IA.

### Visual
- Diagrama simples: `codigo existente -> contexto do modelo -> nova geracao -> repeticao do padrao`.

### Pontos
- Ruido tambem ensina.
- Resquicios, hacks antigos e ownership mal definido podem ser lidos como estrutura canonica.
- Quanto mais aquilo aparece, mais facil a IA reproduzir.

### Frases/teses tecnicas
- Ruido arquitetural vira precedente tecnico.
- O modelo nao sabe, por si, o que e legado acidental e o que e decisao canonica.

---

## Slide 4 - Arquitetura ruim gera codigo ruim e diagnostico ruim
### Objetivo
Subir o nivel da critica: nao e so sobre output.

### Visual
- Diagrama de causa e efeito.

### Pontos
- A IA pode corrigir o lugar errado.
- Pode abrir desvio lateral e ficar "resolvendo adjacencias".
- Pode assumir uma conexao que deveria existir, mas que na pratica e so resquicio.

### Frases/teses tecnicas
- Arquitetura ruim nao so produz implementacao ruim; produz investigacao ruim.
- Se a topologia do sistema esta ambigua, o diagnostico tambem fica probabilistico demais.

---

## Slide 5 - Caso real: sintoma vs causa
### Objetivo
Mostrar um print que prova a tendencia de corrigir sintoma antes de fechar diagnostico.

### Visual
- Usar o print do caso `account_profiles/near`.

### Pontos
- Hipotese inicial.
- Verificacao em Flutter.
- Verificacao no adaptador/backend.
- Fechamento da causa no repositorio/cache.

### Frases/teses tecnicas
- Diagnostico bom e em camadas: endpoint, adapter, repositorio, fallback, contrato.
- O erro visivel nem sempre esta no primeiro ponto suspeito.

### Observacao
- Esse e um dos melhores slides para defender "investigacao estruturada".

---

## Slide 6 - Comportamento nao deterministico e por que prompt nao basta
### Objetivo
Justificar tecnicamente por que instrucoes textuais, sozinhas, nao sao camada suficiente de governanca.

### Visual
- Diagrama em camadas:
  - prompt
  - instrucoes
  - rules/lints/hooks
  - testes
  - review

### Pontos
- Comportamento de IA sobre instrucoes e inerentemente nao deterministico.
- O mesmo conjunto de instrucoes pode ter graus diferentes de aderencia entre iteracoes.
- Para regra critica, texto sozinho tem variacao demais.
- O caminho maduro e combinar orientacao com mecanismos executaveis.

### Frases/teses tecnicas
- Prompt ajuda, mas nao governa sozinho.
- Regra critica nao deveria depender de obediencia probabilistica.
- Regra critica deveria ser verificavel, nao apenas lembrada.

### Referencias e citacoes
- GitHub Docs:
  - "Non-deterministic behavior: Copilot may not follow every instruction perfectly every time."
  - Fonte: https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/use-custom-instructions
- Anthropic Hooks Guide:
  - "Hooks provide deterministic control over Claude Code’s behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them."
  - Fonte: https://docs.anthropic.com/en/docs/claude-code/hooks-guide

### Uso didatico
- Esse slide faz a ponte logica entre "limite do modelo" e "necessidade de rules, hooks, lints e workflows".

---

## Slide 7 - Caso real: warning arquitetural em serie
### Objetivo
Mostrar o valor de regra objetiva e executavel.

### Visual
- Usar o print dos `51` warnings.

### Pontos
- O warning nao e opiniao subjetiva; ele formaliza um contrato arquitetural.
- O mesmo desvio apareceu varias vezes.
- Sem guardrail, a IA tenderia a replicar esse erro em escala.

### Frases/teses tecnicas
- Desvio repetitivo pede rule/lint, nao so orientacao verbal.
- Quando um problema aparece em serie, ele deixou de ser incidente e virou classe de erro.

### Frase curta boa para o slide
- "Rule objetiva > recomendacao vaga"

---

## Slide 8 - Caso real: o que a IA faz sozinha e o que exige decisao humana
### Objetivo
Mostrar que um bom sistema de trabalho reduz decisoes desnecessarias, mas preserva as decisoes realmente humanas.

### Visual
- Usar o print `Doc-only, sem decisao nova`.

### Pontos
- Ajuste de documentacao pode ser autonomo.
- Decisao de produto/escopo precisa ser explicitamente separada.
- Isso reduz tanto invencao quanto micropergunta desnecessaria.

### Frases/teses tecnicas
- Nem toda ambiguidade merece virar decisao aberta.
- Mas decisao material nao deve ser "adivinhada" pelo agente.

---

## Slide 9 - Caso real: gap de teste ou falha de invariante?
### Objetivo
Mostrar que o problema pode ser mais profundo do que cobertura.

### Visual
- Usar o print do `prepare_response`.

### Pontos
- A conversa comeca em cobertura de teste.
- Mas o diagnostico sobe para invariante de negocio.
- Isso e importante porque teste errado pode validar estado que nunca deveria existir.

### Frases/teses tecnicas
- Nem todo falso negativo e apenas falta de teste; as vezes e falta de regra de negocio imposta rigidamente.
- Teste forte protege comportamento; invariante forte protege o modelo.

---

## Slide 10 - Transicao: se esses sao os problemas, como eu trabalho?
### Objetivo
Virar da camada generica para a camada autoral.

### Visual
- Slide de transicao, sem print ou com um diagrama simples.

### Pontos
- Agora entra o seu metodo.
- Nao como "preferencia pessoal", mas como resposta a problemas concretos.
- A pergunta muda de "qual IA usar?" para "como operar IA com confiabilidade?".

### Frases/teses tecnicas
- O Delphi nao nasce de gosto pessoal; ele nasce de necessidades de governanca.
- O metodo e a resposta aos limites praticos que acabamos de ver.

---

## Slide 11 - Delphi AI como sistema de trabalho
### Objetivo
Apresentar as camadas principais do Delphi.

### Visual
- Ideal: print da raiz do repositorio ou um diagrama em pilha.
- Sugestao de camadas:
  - bootloader
  - main instructions
  - rules
  - skills
  - workflows
  - TODOs
  - validacao

### Pontos
- Nao e um prompt unico.
- E um ecossistema de artefatos com papeis diferentes.
- Cada camada existe para reduzir um tipo de erro.

### Frases/teses tecnicas
- Nao e prompt engineering isolado; e design do sistema de trabalho.
- O agente entra por bootloader e opera sob um conjunto versionado de mecanismos.

### Print adicional sugerido
- Print da estrutura do repo mostrando `rules/`, `skills/`, `workflows/`, `templates/`, `main_instructions.md`, `README.md`.

---

## Slide 12 - `TODO slices` como memoria operacional persistente
### Objetivo
Explicar por que o TODO persistente e uma peca-chave do metodo.

### Visual
- Usar o print da pasta `mvp_slices`.

### Pontos
- Plans de agentes costumam ser `in-session`.
- TODO tatico persiste entre sessoes.
- TODO pode ser retomado por outro agente ou em outra iteracao.
- TODO ajuda a nao depender so da memoria do chat.

### Frases/teses tecnicas
- Plan in-session nao e memoria de projeto.
- TODO persistente vira memoria operacional rastreavel.

### Observacao importante
- Falar explicitamente que `mvp_slices` sao TODOs, nao packages.

---

## Slide 13 - `TODO slices` nao sao `packages`
### Objetivo
Evitar confusao conceitual.

### Visual
- Slide comparativo com duas colunas.

### Pontos
- `TODO slice`: execucao, continuidade, rastreabilidade, refinamento de escopo, retomada futura.
- `Package`: modularizacao de codigo, fronteira de ownership, reaproveitamento, manutencao centralizada.

### Frases/teses tecnicas
- TODO organiza o trabalho.
- Package organiza o sistema.

### Print adicional sugerido
- Se quiser reforcar, usar um print de algum workflow ou README de package mostrando fronteiras, contratos e validacoes.

---

## Slide 14 - Packages: menos contexto e mais reaproveitamento
### Objetivo
Introduzir o tema de packages do jeito certo.

### Visual
- Diagrama simples mostrando:
  - package compartilhado
  - projetos consumidores
  - manutencao centralizada

### Pontos
- Packages reduzem o volume de codigo relevante por tarefa.
- Permitem escrutinio mais profundo uma vez, com reaproveitamento posterior.
- Reduzem reinvencao de roda e divergencia de manutencao.
- Tambem ajudam a IA porque o contexto pode ser mais local e previsivel.

### Frases/teses tecnicas
- Modularizacao nao resolve tudo, mas melhora bastante o problema de contexto e consistencia.
- Reutilizacao com fronteira clara e melhor do que reinventar o mesmo componente em varios projetos.

---

## Slide 15 - Rules, workflows e acoplamento entre processo e implementacao
### Objetivo
Mostrar que no Delphi workflow nao e texto decorativo.

### Visual
- Ideal: print de trecho de `main_instructions.md` ou `todo-driven-execution-method.md`.
- Alternativa: diagrama `regra -> dispara workflow -> gera validacao`.

### Pontos
- Rule diz quando algo precisa acontecer.
- Workflow diz como precisa acontecer.
- TODO define o contrato de execucao.
- Validacao prova aderencia.

### Frases/teses tecnicas
- Procedimento sem trigger vira aspiracao.
- Workflow so funciona de verdade quando o sistema sabe quando aplica-lo.

### Print adicional sugerido
- Trecho de [`main_instructions.md`](/home/elton/Dev/repos/delphi-ai/main_instructions.md#L149) ate [L178](/home/elton/Dev/repos/delphi-ai/main_instructions.md#L178).
- Trecho de [`workflows/docker/todo-driven-execution-method.md`](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L48) ate [L67](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L67).

---

## Slide 16 - De prompt a Skill
### Objetivo
Mostrar que o Delphi AI evolui a partir de caminhos de trabalho que foram validados na pratica.

### Visual
- Visual principal:
  - usar o print da execucao real com `bug-fix-evidence-loop`, `flutter-architecture-adherence` e `test-creation-standard`
- Complemento opcional:
  - um recorte menor com o prompt-base de debug
- Se houver espaco:
  - seta curta com `validado -> aprofundado -> consolidado -> reaproveitado`

### Pontos
- Um bom prompt explicita um raciocinio util.
- Quando esse raciocinio se prova recorrente, ele nao deveria precisar ser reexplicado toda vez.
- A Skill consolida esse caminho, aprofunda o processo e reduz variabilidade.
- Isso melhora fluidez de conversa, continuidade e reaproveitamento entre sessoes.
- O print mostra nao so a existencia da Skill, mas a sua operacionalizacao real:
  - evidencia real
  - backend correto
  - gap de teste
  - RED
  - correcao
  - GREEN
  - analyzer + suite ampla

### Frases/teses tecnicas
- Prompt bom resolve uma vez. Skill boa resolve de forma reaproveitavel.
- Skills consolidam caminhos e processos que validamos na pratica.
- Quando um raciocinio deixa de ser ocasional e vira padrao, ele merece ser promovido a Skill.
- O Delphi AI e um sistema vivo: ele evolui com o proprio processo de programacao.

### Exemplo que entra bem
- Prompt:
  - "Ocorreu erro X. Identifique porque os testes que ja existem nao cobriram esse caso. Se ha gap nos testes, crie novos que cubram esse caso. Se ha erro na logica de testes existentes, ajustes e confirme se elas passam a pegar o erro. Use uma abordagem TDD verificando se os novos testes ou testes corrigidos pegam o erro."
- Forma consolidada:
  - "Faca o debug de X usando nossa skill de bug fix."
- Referencia:
  - [`bug-fix-evidence-loop`](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L1)
- Prova de uso:
  - print da execucao real mostrando o protocolo aplicado e a validacao final

### Uso didatico
- Esse slide fecha muito bem o bloco Delphi porque mostra o metodo como algo vivo, e nao apenas como estrutura estatica.
- Ele tambem prova que a Skill nao substitui rigor; ela consolida rigor.

---

## Slide 17 - Workflow tambem evita erro de processo
### Objetivo
Mostrar que guardrail nao serve so para arquitetura de codigo.

### Visual
- Usar o print do caso `deeplink` / `bot/next-version`.

### Pontos
- Uma solucao tecnicamente util ainda pode estar errada na governanca.
- Cross-repo e promotion exigem disciplina de branch e lane.
- Sem esse cuidado, a IA pode "resolver" criando nova bagunca operacional.

### Frases/teses tecnicas
- Nem todo erro e de implementacao; muitos sao de processo.
- Workflow protege o sistema tambem contra solucoes operacionais erradas.

---

## Slide 18 - Validacao e prova de entrega
### Objetivo
Fechar o ciclo: implementar nao basta.

### Visual
- Usar o print `Validacao executada`.

### Pontos
- Testes.
- Analyze.
- Custom lint.
- Build.
- TODO atualizado com evidencia.

### Frases/teses tecnicas
- Entrega madura exige evidencia, nao so confianca subjetiva.
- Sem validacao multi-camada, a sessao termina em opiniao e nao em prova.

---

## Slide 19 - Como e uma sessao padrao de trabalho
### Objetivo
Consolidar o metodo em um fluxo memoravel.

### Visual
- Fluxograma com 6 a 8 etapas.

### Pontos
- Desenho da feature em detalhe.
- Implementacao com liberdade controlada.
- Alinhamento e detalhamento de UI/UX.
- Testes automatizados e manuais.
- Debug de gaps de cobertura.
- Review arquitetural.
- Promocao do aprendizado para regra ou doc canonica.

### Frases/teses tecnicas
- O trabalho nao termina quando a feature funciona; termina quando o sistema ficou mais robusto para a proxima iteracao.
- Bug corrigido e aprendizado nao promovido e maturidade desperdicada.

---

## Slide 20 - Mudanca de papel do engenheiro
### Objetivo
Fechar a aula com a mudanca de abstracao.

### Visual
- Slide limpo com poucos bullets.

### Pontos
- Menos digitacao.
- Mais especificacao.
- Mais validacao.
- Mais arquitetura.
- Mais governanca.

### Frases/teses tecnicas
- O engenheiro deixa de ser apenas executor de codigo e passa a ser operador do sistema de trabalho.
- Quanto mais autonomia da IA, maior precisa ser a qualidade da governanca.

---

## Slide 21 - Fechamento e convite para a Aula 2
### Objetivo
Encerrar a Aula 1 e abrir naturalmente a Aula 2.

### Visual
- Slide simples, sem excesso.

### Pontos
- Hoje: limites, estrutura e metodo.
- Proxima aula: aplicacao real.
- Formato: sessao ao vivo, quase um `code in public`.

### Frases/teses tecnicas
- Entender o metodo antes de executar evita transformar a segunda aula em demonstracao vazia de ferramenta.
- Na proxima aula, a ideia e mostrar esse sistema operando do inicio ao fim.

---

## Prints adicionais que valeria gerar

### 1. Estrutura do Delphi AI
### Para qual slide
- Slide 11

### O que printar
- Arvore do repo mostrando `README.md`, `main_instructions.md`, `rules/`, `skills/`, `workflows/`, `templates/`.

### 2. Gate de TODO + `APROVADO`
### Para qual slide
- Slide 15

### O que printar
- Trecho de [`main_instructions.md`](/home/elton/Dev/repos/delphi-ai/main_instructions.md#L149) ate [L178](/home/elton/Dev/repos/delphi-ai/main_instructions.md#L178).

### 3. Triage de decisao material vs detalhe local
### Para qual slide
- Slide 15 ou 18

### O que printar
- Trecho de [`workflows/docker/todo-driven-execution-method.md`](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L48) ate [L67](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L67).

### 4. Gate de aderencia antes da entrega
### Para qual slide
- Slide 18

### O que printar
- Trecho de [`workflows/docker/todo-driven-execution-method.md`](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L101) ate [L109](/home/elton/Dev/repos/delphi-ai/workflows/docker/todo-driven-execution-method.md#L109).

### 5. Rule IDs de arquitetura Flutter
### Para qual slide
- Slide 7

### O que printar
- Trecho de [`skills/flutter-architecture-adherence/SKILL.md`](/home/elton/Dev/repos/delphi-ai/skills/flutter-architecture-adherence/SKILL.md#L24) ate [L36](/home/elton/Dev/repos/delphi-ai/skills/flutter-architecture-adherence/SKILL.md#L36).

### 6. Package como fronteira arquitetural
### Para qual slide
- Slide 14

### O que printar
- Trecho de [`skills/wf-laravel-create-package-method/SKILL.md`](/home/elton/Dev/repos/delphi-ai/skills/wf-laravel-create-package-method/SKILL.md#L78) ate [L131](/home/elton/Dev/repos/delphi-ai/skills/wf-laravel-create-package-method/SKILL.md#L131).

### 7. Prompt vs Skill de bug fix
### Para qual slide
- Slide 16

### O que printar
- Prioridade 1:
  - usar o print real da execucao com:
    - `bug-fix-evidence-loop`
    - `flutter-architecture-adherence`
    - `test-creation-standard`
    - protocolo `evidencia real -> backend -> gap -> RED -> correcao -> GREEN -> rerun`
    - validacao final (`analyze` limpo + suite ampla verde)
- Prioridade 2:
  - se quiser complementar, adicionar um recorte menor lado a lado com:
    - o prompt de debug que voce formulou;
    - trechos da [`bug-fix-evidence-loop`](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L12), principalmente:
      - [L12](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L12) ate [L14](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L14)
      - [L16](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L16) ate [L20](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L20)
      - [L43](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L43) ate [L50](/home/elton/Dev/repos/delphi-ai/skills/bug-fix-evidence-loop/SKILL.md#L50)

---

## Observacoes de montagem
- Nao colocar print demais por slide; 1 print forte costuma funcionar melhor.
- Sempre que o print for textual, destaque visualmente 1 a 3 trechos principais.
- Se algum print for ambigio visualmente, complemente com uma legenda curta no proprio slide.
- Os slides mais autorais ficam melhores quando mostram "problema -> mecanismo -> ganho".

---

## Citacoes oficiais que valem usar no deck

### 1. GitHub Docs
- "Non-deterministic behavior: Copilot may not follow every instruction perfectly every time."
- Uso ideal:
  - Slide 6
  - Justificar que custom instructions nao bastam como unica camada de governanca
- Fonte:
  - https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/use-custom-instructions

### 2. Anthropic Hooks Guide
- "Hooks provide deterministic control over Claude Code’s behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them."
- Uso ideal:
  - Slide 6
  - Justificar hooks/rules executaveis
- Fonte:
  - https://docs.anthropic.com/en/docs/claude-code/hooks-guide

### 3. OpenAI - How OpenAI uses Codex
- "For large changes, start by prompting Codex for an implementation plan using Ask mode..."
- Uso ideal:
  - Slides 5, 18 ou 19
  - Sustentar planejamento/investigacao antes de implementar
- Fonte:
  - https://openai.com/business/guides-and-resources/how-openai-uses-codex/
