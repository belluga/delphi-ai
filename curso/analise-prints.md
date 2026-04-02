# Analise dos Prints Praticos

## Leitura geral
Os prints sao fortes porque mostram IA operando dentro de um sistema de trabalho, e nao apenas "gerando codigo". Eles sustentam a tese de que qualidade vem de estrutura operacional: escopo canonico, rules, workflows, validacao, rastreabilidade e consolidacao do aprendizado.

## Print 1: `Doc-only, sem decisao nova`
### O que ele mostra
- Separacao entre ajuste mecanico e decisao de produto.
- Capacidade de dizer "isso eu consigo resolver sozinho" versus "isso exige confirmacao humana".

### O que ele prova
- IA bem guiada nao precisa abrir decisao onde nao ha decisao.
- Mas tambem nao deve inventar fechamento de produto/escopo.

### Uso em aula
- Excelente para defender a ideia de reduzir ruido e evitar falsa autonomia.

## Print 2: pasta `mvp_slices`
### O que ele mostra
- Existencia de TODOs taticos persistentes por tema.

### Correcao importante
- Esses `mvp_slices` nao sao packages de codigo.
- Eles sao unidades persistentes de execucao, memoria operacional e rastreabilidade.

### O que ele prova
- Ferramentas de plan de agentes sao limitadas ao contexto da sessao.
- Um TODO tatico pode ser retomado depois, por outro agente ou em outra sessao, sem perder o fio.

### Uso em aula
- Bom para explicar "memoria operacional fora da sessao".

## Print 3: warnings de arquitetura
### O que ele mostra
- Uma regra objetiva sendo violada em serie: `Domain fields cannot use primitive transport-oriented types directly`.

### O que ele prova
- Rule objetiva e executavel e superior a orientacao vaga.
- Desvio arquitetural se multiplica facilmente quando nao ha guardrail.

### Uso em aula
- Excelente para defender `rules > prompt`.

## Print 4: diagnostico de `account_profiles/near`
### O que ele mostra
- Hipotese inicial.
- Verificacao em camadas.
- Correcao do diagnostico.
- Fechamento baseado em contrato e evidencia.

### O que ele prova
- Nao basta "achar o arquivo suspeito".
- Arquitetura ruim ou ambigua pode levar a IA a corrigir o lugar errado.
- Diagnostico estruturado e mais importante que rapidez impulsiva.

### Uso em aula
- Excelente para falar de "diagnostico ruim tambem e custo de arquitetura ruim".

## Print 5: deeplink e branch de promocao
### O que ele mostra
- A solucao tecnicamente util ainda pode estar errada no workflow.
- A skill/regra de promotion corrige a trajetoria.

### O que ele prova
- Workflow nao e burocracia; e protecao contra erros de processo.
- Cross-repo/cross-branch precisa de governanca explicita.

### Uso em aula
- Excelente para explicar por que skill e workflow existem alem do prompt.

## Print 6: `Validacao executada`
### O que ele mostra
- Testes, analyze, lint, build e TODO atualizado com evidencia.

### O que ele prova
- O trabalho nao termina em "corrigi".
- Entrega madura exige validacao multi-camada e rastreabilidade.

### Cuidado
- Se o screenshot tambem mostra `Problems`, vale explicar em aula se eram TODOs informacionais ou issues nao bloqueantes, para nao parecer contradicao.

## Print 7: `prepare_response` / gap de teste
### O que ele mostra
- A conversa sai de "faltou teste" para "qual invariante deveria existir?".

### O que ele prova
- Nem todo bug e apenas falta de cobertura.
- As vezes o problema real e que uma regra de negocio nao esta sendo imposta rigidamente.
- Isso conversa diretamente com sua ideia de review arquitetural apos bug/teste.

### Uso em aula
- Talvez o melhor print para fechar o fluxo:
  - erro
  - gap de teste
  - invariante
  - possivel nova rule

## Sintese didatica
- `mvp_slices`: memoria de execucao e continuidade.
- `Rules/lints`: aderencia objetiva.
- `Workflow/skills`: coordenacao do processo.
- `Validacao`: prova de entrega.
- `Review arquitetural`: transformacao de bug em aprendizado sistemico.

