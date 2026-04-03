# Roteiro Base das Duas Aulas

## Identidade do curso
**Programacao Estruturada com IA**  
Como acelerar o desenvolvimento com IA mantendo qualidade de codigo e uma arquitetura escalavel

## Nomes recomendados
- Aula 1: **Arquitetura, Regras e Fluxo de Trabalho**
- Aula 2: **Aplicacao Pratica em uma Sessao Real**

## Direcao geral
- Aula 1: apresentar o modelo mental completo, incluindo o fluxo inteiro, sem implementacao real.
- Aula 2: executar esse fluxo ao vivo, em formato proximo de `code in public`.

## Tese central da serie
Programar com IA exige mais estrutura, nao menos. Quanto mais canonicidade, governanca e clareza de ownership, melhor a IA trabalha. Quanto mais ruido, resquicio e ambiguidade, mais ela replica desvio como se fosse padrao valido.

## Aula 1: Estrutura, guardrails e fluxo

### Objetivo
Dar aos alunos um modelo mental operacional de programacao com IA.

### Sequencia sugerida
1. O que a IA faz bem e onde ela falha.
2. Por que contexto "validado" vira precedente tecnico.
3. Como ruido arquitetural e reproduzido e multiplicado.
4. Como arquitetura ruim tambem degrada o diagnostico.
5. Diferenca entre instrucoes, rules, skills, workflows e validacao.
6. Por que prompt sozinho nao basta para aderencia.
7. Importancia da especializacao em uma stack.
8. Diferenca entre `TODO slices` e `packages`.
9. Fluxo completo de trabalho.

### Fluxo a explicar na Aula 1
- Desenho detalhado da feature: texto, imagem, prototipo, contrato.
- Implementacao com liberdade controlada.
- Alinhamento e detalhamento de UI/UX.
- Testes automatizados e teste manual.
- Debug orientado por gap de cobertura.
- Review de arquitetura.
- Conversao de desvio recorrente em rule objetiva.

### Mensagens fortes
- IA trata contexto como verdade provavel.
- Ruido arquitetural vira precedente.
- Prompt orienta; rule restringe; teste valida; workflow coordena.
- O objetivo nao e so "entregar a feature"; e deixar o sistema mais seguro para as proximas iteracoes da IA.

## Aula 2: Aplicacao ao vivo

### Objetivo
Mostrar a operacao real do metodo.

### Formato
1. Mostrar a feature ja bem especificada.
2. Delimitar o escopo do trabalho.
3. Implementar com a IA.
4. Revisar a saida com foco em arquitetura.
5. Ajustar UX/UI quando necessario.
6. Rodar validacoes e testes.
7. Mostrar um erro escapando ou um gap de cobertura.
8. Fazer o debug no formato TDD.
9. Fechar com review arquitetural e eventual extracao de nova rule.

### O que os alunos devem perceber
- O trabalho muda de digitacao para direcao e escrutinio.
- Testes ruins tambem sao amplificados.
- Nem todo erro e "falta de teste"; as vezes e falta de invariante arquitetural.
- O sistema amadurece quando bug corrigido vira conhecimento operacional reaproveitavel.

## Distincao didatica importante
- `TODO slices`: unidade de execucao, memoria persistente e rastreabilidade entre sessoes.
- `Packages`: unidade de modularizacao, reaproveitamento, fronteira arquitetural e centralizacao de manutencao.
