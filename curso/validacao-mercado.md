# Validacao com o Mercado

## Leitura geral
As teses centrais do curso estao bem alinhadas com o que OpenAI, Anthropic, GitHub, DORA/Google, Martin Fowler e Thoughtworks vem defendendo. O principal ajuste necessario nao e de direcao, e de grau de absolutismo.

## O que esta fortemente alinhado
- IA amplifica a estrutura existente.
- Contexto curado e arquitetura clara melhoram resultado.
- Prompt sozinho nao garante aderencia.
- Testes e revisao continuam centrais.
- O papel do engenheiro sobe de abstracao.
- Modularidade ajuda a IA a operar em sistemas maiores.

## Onde convem formular com nuance
- Nao dizer "menos contexto e sempre melhor"; dizer "menos contexto irrelevante e mais contexto curado".
- Nao dizer "prompt nao consegue"; dizer "prompt sozinho nao e confiavel o suficiente para governanca".
- Nao dizer "nova stack comeca do zero"; dizer "perde-se muito do capital acumulado especifico da stack".
- Nao dizer "sem digitar codigo e o normal"; dizer "isso e viavel em repositorios maduros, com bastante investimento em estrutura, testes e guardrails".

## Fontes-chave e como elas ajudam

### OpenAI
- `How OpenAI uses Codex`
  - Link: https://openai.com/business/guides-and-resources/how-openai-uses-codex/
  - Sustenta: estrutura, contexto, AGENTS.md, Ask Mode, tarefas bem escopadas, uso para testes, exploracao e produtividade.
- `Harness engineering: leveraging Codex in an agent-first world`
  - Link: https://openai.com/index/harness-engineering/
  - Sustenta: humanos em outro nivel de abstracao, feedback loops, guardrails, golden principles, drift, shared utility packages.
- `Introducing Codex`
  - Link: https://openai.com/index/introducing-codex/
  - Sustenta: AGENTS.md, necessidade de ambiente configurado, testes, revisao e validacao manual.

### GitHub
- `Responsible use of GitHub Copilot inline suggestions`
  - Link: https://docs.github.com/en/copilot/responsible-use/copilot-code-completion
  - Sustenta: revisar e validar codigo, testes gerados podem nao cobrir tudo, limites de arquitetura e contexto.
- `Using custom instructions to unlock the power of Copilot code review`
  - Link: https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/use-custom-instructions
  - Sustenta: comportamento nao deterministico, contexto limitado, especificidade, iteracao de instrucoes, organizacao por escopo.
- `Adding repository custom instructions for GitHub Copilot`
  - Link: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
  - Sustenta: `AGENTS.md` e instrucoes por contexto/proximidade.

### Anthropic
- `Automate workflows with hooks`
  - Link: https://code.claude.com/docs/en/hooks-guide
  - Sustenta: hooks como controle deterministico, enforcement de regras, bloqueio de acoes e automacao de governanca.
- `Create custom subagents`
  - Link: https://code.claude.com/docs/en/sub-agents
  - Sustenta: contextos separados, subagentes especializados, economia de contexto.
- `Extend Claude with skills`
  - Link: https://code.claude.com/docs/en/skills
  - Sustenta: skills como playbooks reutilizaveis, nested discovery em monorepo, escopo por pasta.

### Thoughtworks / Fowler / DORA
- `AI-friendly code design`
  - Link: https://www.thoughtworks.com/en-us/radar/techniques/ai-friendly-code-design
  - Sustenta: modularidade, abstracoes e DRY ajudam humanos e IA.
- `Curated shared instructions for software teams`
  - Link: https://www.thoughtworks.com/radar/techniques/curated-shared-instructions-for-software-teams
  - Sustenta: sair de prompting individual para instrucoes compartilhadas e versionadas.
- `Claude Code` no Technology Radar
  - Link: https://www.thoughtworks.com/radar/tools/claude-code
  - Sustenta: mudanca do papel do desenvolvedor, necessidade de context engineering e governanca.
- `Knowledge Priming`
  - Link: https://martinfowler.com/articles/reduce-friction-ai/knowledge-priming.html
  - Sustenta: onboarding da IA, contexto curado, anti-patterns, naming, exemplos, override de defaults genericos.
- `Design-First Collaboration`
  - Link: https://martinfowler.com/articles/reduce-friction-ai/design-first-collaboration.html
  - Sustenta: no code until design agreement, reducao de carga cognitiva, spec/design antes da implementacao.
- `Research, Review, Rebuild`
  - Link: https://martinfowler.com/articles/research-review-rebuild.html
  - Sustenta: fluxo estruturado, review como etapa indispensavel, teste sem sentido dando falsa cobertura.
- `Fostering developers' trust in generative artificial intelligence`
  - Link: https://dora.dev/insights/trust-in-ai/
  - Sustenta: feedback rapido, code review, testing, stack/language familiarity.
- `User-centric focus`
  - Link: https://dora.dev/capabilities/user-centric-focus/
  - Sustenta: AI como amplificador, importancia de especificacao orientada ao usuario.

### Pesquisa academica
- `Repository-Level Prompt Generation for Large Language Models of Code`
  - Link: https://arxiv.org/abs/2206.12839
  - Sustenta: contexto de repositorio melhora desempenho.
- `RepoFusion: Training Code Models to Understand Your Repository`
  - Link: https://arxiv.org/abs/2306.10998
  - Sustenta: modelos sofrem para entender contexto de repositorio sem ajuda.

## Aplicacao didatica
- Use essas fontes para dar legitimidade externa a teses como: "IA amplifica contexto", "modularidade ajuda", "guardrail executavel e melhor do que orientacao vaga", "testes e revisao seguem centrais".
- Use nuance ao falar de autonomia total, de "sem digitar codigo" e de migracao entre stacks.

