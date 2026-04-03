# Core Concepts And Sources

## Conceito: AI as amplifier
### Tese
IA nao cria qualidade organizacional do zero. Ela amplifica as forcas e fraquezas que ja existem.

### Fonte principal
- DORA 2025 / Balancing AI tensions

### Uso
- explicar por que guardrails importam
- ligar IA a sistema, nao a magia

## Conceito: Paradoxo da percepcao
### Tese
Em tarefas complexas, desenvolvedores podem se sentir mais rapidos com IA e ainda assim ficarem mais lentos no resultado objetivo.

### Fonte principal
- METR 2025 open-source developer productivity RCT

### Uso
- separar sentimento de produtividade de produtividade medida

## Conceito: SDD + TDD
### Tese
Spec define o contrato. Testes provam o contrato.

### Fontes principais
- GitHub Spec Kit
- Anthropic Claude Code best practices
- Thoughtworks AI-aided test-first development

### Uso
- mostrar que IA funciona melhor com contrato e verificacao

## Conceito: Delphi como spec-driven execution
### Tese
Delphi-AI distribui autoridade entre roadmap, modules e TODO tatico. Isso transforma execucao com IA em metodo governado.

### Base
- leitura do proprio repositorio Delphi-AI

### Uso
- mostrar Delphi como concretizacao do curso

## Conceito: Verification debt
### Tese
Ganhar velocidade sem evidenciar, validar e promover o que aprendeu cria um imposto futuro de manutencao.

### Base
- formulacao metodologica do Delphi-AI
- conversa com DORA, TDD e validacao

## Caso: Vibe coding
### Papel
Caso guarda-chuva para criticar fluxos sem contrato, sem teste e sem governanca.

## Caso: Amazon Kiro
### Papel
Exemplo de risco de automatizar sem governanca suficiente.

### Observacao editorial
Usar com cuidado e sem vender numero fraco como fato duro se a fonte for secundaria.

## Caso: Moltbook
### Papel
Exemplo de como "fazer funcionar" sem disciplina de seguranca pode explodir.

## Fontes iniciais sugeridas

### METR
- `Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity`
- usar para:
  - 19% slower
  - expectativa de 24% faster
  - crença posterior de 20% faster

### DORA
- `DORA Report 2025`
- `Balancing AI tensions`
- usar para:
  - AI as amplifier
  - verification overhead
  - tensao entre throughput e estabilidade

### Martin Fowler
- textos sobre cognitive debt / ignorance
- usar para:
  - diferenca entre codigo funcionar e o time realmente entender o sistema

### GitHub Spec Kit
- usar para:
  - spec-driven development
  - spec como contrato executavel

### Anthropic Claude Code Best Practices
- usar para:
  - explore -> plan -> code
  - test-first como reforco para coding agents

### Thoughtworks
- usar para:
  - AI-aided test-first development
  - melhor encaixe de TDD no contexto de IA

## Regras editoriais sobre fontes
- nao inventar metrica
- nao inflar numeros fracos
- separar:
  - afirmacao forte
  - afirmacao com nuance
  - hipotese / observacao de mercado
- sempre que houver numero, associar a uma fonte concreta
