# Prompt para Gemini Deep Research

```text
Quero um relatorio de pesquisa aprofundada, em portugues do Brasil, sobre boas praticas e limitacoes de programacao assistida por IA / agentic coding / AI-assisted software engineering.

Objetivo:
Validar, corrigir ou nuancar as teses abaixo com base em fontes reais, atuais e confiaveis. Nao quero um texto promocional. Quero confronto critico entre afirmacoes, incluindo consenso, divergencia e grau de evidencia.

Data de referencia:
Use informacoes atuais ate a data de hoje. Sempre cite datas exatas das publicacoes.

Escopo:
Quero confrontar estas teses:

1. IA amplifica a estrutura existente do codigo e do processo.
2. Arquitetura limpa e baixo ruido melhoram significativamente a qualidade das saidas da IA.
3. Ruidos arquiteturais, resquicios de codigo e padroes ambiguos podem ser tratados pela IA como “estrutura valida”, gerando bugs e diagnostico ruim.
4. Prompt sozinho nao garante aderencia suficiente; e preciso rules, guardrails, hooks, workflows, instruction files ou mecanismos equivalentes.
5. Regras objetivas e executaveis sao mais confiaveis do que instrucoes apenas textuais.
6. Modularizacao em packages ou modulos reduz carga de contexto e ajuda a IA a operar melhor em sistemas grandes.
7. Reutilizacao de packages/shared modules centraliza manutencao, seguranca e invariantes, reduzindo reinvencao de roda entre projetos.
8. Especializacao em uma stack especifica e abrangente aumenta a confiabilidade do uso de IA, porque acumula rules, guardrails, exemplos e sensibilidade arquitetural.
9. Ao mudar de stack, perde-se muito do capital acumulado de regras, convencoes e conhecimento operacional especifico.
10. O papel do engenheiro muda de digitacao de codigo para especificacao, validacao, revisao e evolucao do sistema de trabalho.
11. Testes continuam centrais; IA pode gerar testes uteis, mas tambem testes fracos, falsos positivos, cobertura enganosa ou duplicacao ruim.
12. O fluxo ideal tende a ser: especificacao detalhada da feature -> implementacao assistida por IA -> ajuste de UI/UX -> testes -> investigacao de gaps de teste -> revisao arquitetural -> conversao de desvios recorrentes em novas regras.
13. Para trabalho nao trivial, design-first/spec-first e mais confiavel do que pedir implementacao imediata.
14. “Sem digitar codigo” e possivel em alguns contextos maduros, mas depende fortemente de estrutura, tooling, testes e guardrails.
15. Menos contexto bruto nao e necessariamente melhor; melhor e contexto curado, relevante e bem estruturado.

O que pesquisar:
- O que especialistas, empresas e pesquisadores de referencia dizem sobre esses pontos.
- Onde ha consenso forte, consenso parcial ou discordancia.
- Quais dessas teses sao suportadas por:
  a) documentacao oficial de ferramentas
  b) relatos de engenharia reais
  c) research / papers / benchmarks
  d) consultorias ou autores respeitados
- Quais afirmacoes acima estao corretas, imprecisas, exageradas ou dependem de nuance.

Fontes prioritarias:
Priorize, nesta ordem:
1. Documentacao oficial e blogs de engenharia de OpenAI, Anthropic, GitHub, Google/DORA, Microsoft Research.
2. Martin Fowler / Thoughtworks / Technology Radar / artigos tecnicos reconhecidos.
3. Papers academicos relevantes sobre repository context, prompting com contexto de repositorio, code generation, agentic coding, long-context limitations, test generation, code quality.
4. Pesquisas quantitativas sobre qualidade de codigo, duplicacao, churn, confianca excessiva, code review, testes, produtividade e estabilidade.

Evite:
- Blogs genericos de SEO
- Conteudo sem autor identificado
- Medium aleatorio sem reputacao tecnica
- Posts sem evidencia
- Resumos sem links verificaveis

Quero confronto explicito destas perguntas:
1. Ha evidencia de que IA replica padroes ruins ja presentes no repositorio?
2. Ha evidencia de que contexto curado supera contexto grande porem ruidoso?
3. Ha evidencia de que instrucoes textuais tem comportamento nao deterministico?
4. Ha evidencia de que guardrails executaveis, hooks, policies ou rules objetivas melhoram aderencia?
5. Ha evidencia de que modularidade / packages / abstracoes claras ajudam IA em codebases grandes?
6. Ha evidencia de que testes gerados por IA podem criar falsa sensacao de cobertura?
7. Ha evidencia de que revisao humana continua necessaria, mesmo com agentes mais autonomos?
8. Ha evidencia de que stack familiarity ou language familiarity melhora o uso seguro e eficaz da IA?
9. Ha fontes fortes que contradizem ou relativizam alguma das teses acima?
10. Em que pontos o discurso de mercado esta mais otimista do que a evidencia realmente permite?

Formato obrigatorio da resposta:
Quero 6 secoes, exatamente nesta estrutura.

Secao 1 — Resumo Executivo
- Para cada tese, classifique como:
  - Fortemente suportada
  - Parcialmente suportada
  - Plausivel, mas com pouca evidencia
  - Contestada
- De uma justificativa curta para cada uma.

Secao 2 — Matriz de Validacao
Monte uma tabela com colunas:
- Tese
- Status
- Tipo de evidencia
- Melhor fonte
- Data da fonte
- Citacao curta
- Comentario critico

Secao 3 — Evidencias por Tema
Agrupe por:
- arquitetura e contexto
- rules / guardrails / instruction files / hooks
- modularizacao / packages / contexto reduzido
- especializacao em stack
- testes, revisao e falsos positivos
- workflow e mudanca do papel do engenheiro

Para cada grupo:
- resuma o consenso
- mostre divergencias
- destaque limitacoes da evidencia

Secao 4 — Citacoes Reais
Forneca no minimo 15 citacoes curtas, com:
- texto exato entre aspas
- autor ou organizacao
- titulo da fonte
- data
- link direto

Use citacoes curtas. Nao quero parafrases nesta secao.

Secao 5 — Objecoes e Nuances
Liste tudo que poderia enfraquecer ou exigir cuidado ao apresentar essas teses em aula.
Exemplos:
- risco de generalizacao indevida
- diferencas entre autocomplete, chat coding e agentes
- diferencas entre greenfield e legacy
- limites do long context
- diferenca entre evidencia empirica e opiniao forte de especialista

Secao 6 — Conclusao para Aula
Transforme tudo em orientacao pratica para aula:
- o que posso afirmar com seguranca
- o que devo formular com nuance
- o que devo evitar afirmar de forma absoluta

Requisitos metodologicos:
- Sempre diferencie opiniao de especialista, guideline oficial, evidencia empirica e paper academico.
- Sempre indique data exata.
- Sempre inclua links reais.
- Sempre procure ao menos uma fonte que apoie e uma que relativize cada bloco importante.
- Se uma afirmacao for intuitiva, mas nao bem comprovada, diga isso claramente.
- Se nao encontrar evidencia forte, nao preencha com opiniao.
- Nao invente consenso.
- Nao omita contradicoes relevantes.

Criterio de qualidade:
Quero um relatorio util para preparar duas aulas. Portanto, priorize precisao, confronto e utilidade pedagogica acima de volume.
```

