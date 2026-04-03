Quero que voce gere um projeto completo de **site estatico com comportamento de deck**, usando os arquivos anexados como **fonte de verdade editorial**.

Leia todos os arquivos anexados antes de propor a estrutura final.

## Objetivo
Construir a **Aula 1** do curso **Programacao Estruturada com IA** como um site navegavel, visualmente forte, mas com narrativa linear de apresentacao.

O resultado deve servir para dois usos ao mesmo tempo:
- **apresentacao ao vivo**, como se fosse um deck
- **consulta posterior**, como se fosse um site de referencia com links internos

## Regra principal
Este projeto deve ser **100% estatico**.

Isso significa:
- sem banco de dados
- sem backend
- sem auth
- sem CMS
- sem dependencia de conteudo remoto para funcionar
- sem geracao server-side obrigatoria

Se voce usar framework, ele deve gerar um build estatico simples.

## Stack
Pode escolher a stack frontend mais adequada para um projeto estatico e elegante.

Preferencia:
- Vite + React + TypeScript

Mas o critero principal e:
- navegacao boa
- excelente qualidade visual
- estrutura de conteudo simples
- build estatico facil

## O que construir
Quero um **deck-site** com:

1. **narrativa principal linear**
   - uma tela por ideia principal da Aula 1
   - navegacao por teclado
   - anterior/proximo
   - progress indicator discreto

2. **paginas de aprofundamento**
   - conceitos
   - casos
   - fontes

3. **links profundos**
   - cada tela relevante deve ter URL propria
   - cada conceito/caso/fonte deve ter URL propria

4. **conteudo local**
   - o conteudo deve ficar em arquivos locais versionados
   - preferencialmente em `src/content/`
   - pode usar `.ts`, `.json` ou `.md`

## Como organizar o produto
Quero pelo menos estes tipos de pagina:

- `aula`
- `conceito`
- `caso`
- `fonte`

Quero que a Aula 1 contenha, no minimo, telas para:
- abertura
- velocidade inicial vs velocidade sustentada
- AI as amplifier
- paradoxo da percepcao
- SDD + TDD
- Delphi-AI como metodo
- fechamento

Quero tambem paginas especificas para:
- `amplifier`
- `paradoxo-da-percepcao`
- `sdd-tdd`
- `delphi-spec-driven-execution`
- `verification-debt`
- `vibe-coding`
- `amazon-kiro`
- `moltbook`
- fontes principais usadas na narrativa

## Direcao editorial
O tom do produto deve ser:
- rigoroso
- claro
- maduro
- elegante
- sem hype
- sem linguagem de propaganda

O Delphi-AI deve aparecer como:
- um metodo
- um sistema de trabalho
- um exemplo concreto de programacao estruturada com IA

Nao quero:
- linguagem exageradamente elogiosa
- manifesto artificial
- texto corporativo genérico
- "AI slop"

## Direcao visual
Quero um visual com **apelo editorial forte**.

A interface deve parecer:
- sofisticada
- intencional
- densa na medida certa
- premium
- contemporanea

Ela nao deve parecer:
- dashboard SaaS
- landing page de startup
- template comum de slides
- visual cyberpunk neon
- visual roxo genérico de IA

Quero:
- composicao forte
- tipografia expressiva
- grids editoriais
- espacamento generoso
- hierarquia clara
- poucos elementos, mas bem escolhidos

Pode usar:
- serif forte para headlines
- sans limpa para corpo e navegacao
- paleta clara por default
- transicoes suaves e discretas

## Comportamento esperado
Quero:
- navegacao por teclado nas telas da aula
- bom comportamento em desktop e mobile
- links laterais ou discretos para aprofundamento
- paginas de conceito/caso/fonte com layout mais de leitura
- deep linking em toda tela principal

## Regra de conteudo
Use os arquivos anexados como base editorial.

Voce pode:
- reorganizar
- sintetizar
- transformar em estrutura de site

Mas nao pode:
- inventar numeros
- inventar casos
- inflar conclusoes sem base
- transformar hipotese em fato

Se faltar alguma informacao estrutural, crie placeholder claro e local, sem fingir que a fonte existe.

## Diferenciacao conceitual obrigatoria
Quero que a implementacao preserve claramente estas ideias:

1. **IA amplifica o sistema que ja existe**
2. **velocidade inicial nao e velocidade sustentada**
3. **SDD reduz erro de direcao**
4. **TDD reduz erro de implementacao e falsa confianca**
5. **Delphi-AI combina SDD + TDD dentro de um metodo governado**
6. **roadmap, module e TODO distribuem autoridade**

## Estrutura tecnica esperada
Gere um projeto com:
- componentes reutilizaveis
- dados de conteudo locais
- roteamento claro
- estilos consistentes
- estrutura facil de manter

Idealmente:
- `src/pages` ou equivalente
- `src/components`
- `src/content`
- `src/styles`

## Entrega
Quero que voce gere:
1. a estrutura do projeto
2. o codigo das paginas principais
3. os componentes principais
4. o sistema de navegacao
5. o styling completo
6. o conteudo inicial da Aula 1
7. as paginas iniciais de conceitos, casos e fontes

## Criterios de qualidade
O resultado so e bom se:
- parecer um produto editorial forte
- funcionar como deck e como site
- continuar simples de manter
- ficar bonito de verdade
- nao soar artificial
- e respeitar os limites editoriais dos arquivos anexados

## Pedido final
Antes de gerar a solucao, pense no produto como:
- **deck navegavel**
- **site de referencia**
- **artefato intelectual**

Quero um resultado que tenha clareza tecnica, forca visual e navegabilidade real.
