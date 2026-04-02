# Triagem de Teses - Produtividade Sustentada com IA

## Objetivo
Separar, para uso em aula, o que hoje pode ser afirmado com seguranca sobre aceleracao com IA, o que precisa de nuance e o que deve ser evitado por falta de base forte ou por excesso retorico.

## Tese central consolidada
IA pode acelerar a geracao de codigo no curto prazo, mas isso nao garante velocidade sustentada. Sem arquitetura, governanca, validacao, testes e mecanismos explicitos de aderencia, o gargalo migra da escrita para verificacao, integracao, revisao e manutencao.

## 1. O que posso afirmar com seguranca
- O gargalo do desenvolvimento pode migrar da escrita para a verificacao humana.
  - Base: a METR mostrou desaceleracao de `19%` em tarefas reais e complexas com desenvolvedores experientes em seus proprios repositorios, e a DORA afirma que o tempo economizado em criacao frequentemente e realocado para `auditing and verification`.
- Produtividade percebida pode divergir fortemente da produtividade medida.
  - Base: a METR registrou expectativa de `24%` de ganho, crenca posterior de `20%` de ganho e resultado observado de `19%` de perda.
- IA amplifica a estrutura existente do sistema e do processo.
  - Base: DORA sustenta explicitamente que AI funciona como `amplifier`; isso combina com a tese de que contexto bom melhora resultado e contexto ruim escala ruido.
- Velocidade inicial nao garante estabilidade operacional.
  - Base: a DORA relaciona maior adocao de IA a piora em `delivery stability`, e discute tradeoffs reais no SDLC.
- Prompt sozinho nao e camada suficiente de governanca.
  - Base: GitHub documenta comportamento nao deterministico; Anthropic documenta hooks como camada de controle deterministico.
- Arquitetura, contexto curado, rules, workflows, hooks, lints e testes sao mecanismos de sustentabilidade, nao apenas de "qualidade estetica".
  - Base: DORA, GitHub, Anthropic, Fowler e Thoughtworks convergem nessa direcao.
- O problema central nao e apenas "gerar codigo certo"; e manter coerencia, capacidade de revisao e previsibilidade ao longo do tempo.
  - Base: forte por sintese de METR + DORA + Fowler.

## 2. O que eu diria com nuance
- "A IA pode reduzir produtividade."
  - Melhor formulacao: em tarefas complexas, em codebases maduras e com desenvolvedores experientes no proprio contexto, isso ja foi observado de forma robusta; em cenarios greenfield, tarefas simples e bootstrap, ainda pode haver grande aceleracao.
- "O gargalo agora e verificacao."
  - Melhor formulacao: esse gargalo esta crescendo e ja aparece com forca em parte importante do trabalho real, mas nao substitui completamente todos os outros gargalos.
- "A IA cria um exercito de juniores."
  - Melhor formulacao: a velocidade de producao pode exceder a capacidade de revisao humana, gerando um efeito parecido com muitos contribuidores rapidos e pouco supervisionados.
- "Divida cognitiva" e uma descricao boa do problema.
  - Melhor formulacao: o conceito e tecnicamente util e bem defendido por Fowler, mas ainda opera mais como quadro explicativo forte do que como metrica consolidada de mercado.
- "Spec-Driven Development e a resposta."
  - Melhor formulacao: e uma das respostas mais maduras e promissoras hoje, especialmente para trabalho agentico e governanca de longo prazo.
- "Seguranca piorou por causa da IA."
  - Melhor formulacao: o risco aumenta porque o volume e a velocidade crescem e porque a IA tende a tomar atalhos perigosos para fazer o sistema "funcionar"; nao porque todo codigo gerado por IA seja invariavelmente pior em cada linha.

## 3. O que eu evitaria afirmar
- "A IA nos deixa menos produtivos no geral."
  - Forte demais. A evidencia atual nao permite generalizar assim.
- "Existe uma crise da verificacao formalmente estabelecida."
  - Melhor tratar como sua formulacao analitica para descrever um fenomeno real, nao como termo canonico consolidado.
- "A parede dos 18 meses e uma lei do mercado."
  - Melhor tratar como heuristica de mercado para explicar juros compostos de manutencao e perda de velocidade, nao como achado cientifico duro.
- "O codigo de IA e intrinsecamente mais inseguro."
  - A melhor tese hoje e sobre volume, velocidade, atalhos e capacidade insuficiente de revisao.
- "A IA vai acabar com o emprego de desenvolvedor."
  - Frase fraca, generica e facil de contestar. O debate mais serio e sobre mudanca da escada de formacao, deslocamento de tarefas e premio crescente por governanca e arquitetura.
- "Os numeros de colapso de vagas junior, TCO exato ou perdas catastroficas estao fechados."
  - Varios desses dados circulam com base heterogenea e qualidade desigual de fonte. Se usar, use como sinal de direcao, nao como pilar central.

## 4. Formulacoes seguras para a aula
- IA acelera geracao, mas isso nao garante velocidade sustentada.
- O ganho inicial pode virar imposto de verificacao se a estrutura for ruim.
- Quanto mais autonomia da IA, maior precisa ser a qualidade da governanca.
- O problema nao e so escrever rapido; e continuar rapido sem perder entendimento, aderencia e previsibilidade.
- Arquitetura, rules, TODOs persistentes, skills e testes sao mecanismos para preservar velocidade ao longo do tempo.
- O objetivo nao e apenas construir um MVP rapido; e evitar a armadilha de desacelerar depois.

## 5. Leituras-base mais confiaveis para sustentar essa parte
- METR, `Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity`
  - https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- DORA, `State of AI-assisted Software Development 2025`
  - https://dora.dev/dora-report-2025/
- DORA, `Balancing AI tensions: Moving from AI adoption to effective SDLC use`
  - https://dora.dev/insights/balancing-ai-tensions/
- Martin Fowler, `Fragments: February 13`
  - https://martinfowler.com/fragments/2026-02-13.html
- GitHub Docs, `Use custom instructions`
  - https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/use-custom-instructions
- Anthropic Docs, `Hooks guide`
  - https://docs.anthropic.com/en/docs/claude-code/hooks-guide

## 6. Como isso conversa com o Delphi AI
- O Delphi AI pode ser apresentado nao como "a resposta definitiva", mas como uma tentativa pratica de reduzir o imposto de verificacao.
- Rules, workflows, skills, TODOs persistentes e docs canonicas funcionam como mecanismos para sustentar velocidade, e nao apenas para deixar o processo mais burocratico.
- A tese autoral fica mais forte assim:
  - o problema nao e apenas acelerar;
  - o problema e continuar acelerando sem perder controle da arquitetura e da manutencao.
