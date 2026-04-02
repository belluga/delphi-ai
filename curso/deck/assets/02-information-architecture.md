# Information Architecture

## Modelo geral
O produto deve ser um **deck-site**: a narrativa principal continua linear, mas o mesmo conteudo pode ser explorado por links internos.

## Tipos de pagina

### 1. Aula
Uso:
- apresentacao linear
- uma tela por ideia principal

Exemplos de rota:
- `/`
- `/aulas/aula-1/abertura`
- `/aulas/aula-1/velocidade-sustentada`

### 2. Conceito
Uso:
- explicar uma ideia reutilizavel
- servir como referencia interna

Exemplos:
- `/conceitos/amplifier`
- `/conceitos/paradoxo-da-percepcao`
- `/conceitos/sdd-tdd`
- `/conceitos/verification-debt`

### 3. Caso
Uso:
- exemplos concretos
- mostrar porque a tese importa

Exemplos:
- `/casos/vibe-coding`
- `/casos/amazon-kiro`
- `/casos/moltbook`

### 4. Fonte
Uso:
- pagina curta de referencia
- lastro para tese quantitativa ou conceitual

Exemplos:
- `/fontes/metr-rct-2025`
- `/fontes/dora-2025-ai`
- `/fontes/fowler-cognitive-debt`

## Navegacao

### Modo deck
- foco em uma tela por vez
- navegacao por teclado
- proximo / anterior
- progress indicator discreto
- links auxiliares nao devem quebrar a leitura principal

### Modo exploracao
- abrir conceito, caso e fonte relacionados
- voltar facilmente para a tela de origem
- manter contexto da aula

## Comportamentos importantes
- deep-link em toda tela relevante
- links para fontes com boa legibilidade
- layout responsivo desktop/mobile
- sem backend
- sem banco
- sem CMS remoto
- sem auth

## Estrutura inicial sugerida

### Aula 1
- abertura
- velocidade inicial vs velocidade sustentada
- amplifier
- paradoxo da percepcao
- SDD + TDD
- Delphi-AI como metodo
- fechamento

### Conceitos iniciais
- amplifier
- paradoxo da percepcao
- SDD + TDD
- delphi como spec-driven execution
- verification debt

### Casos iniciais
- vibe coding
- amazon kiro
- moltbook

### Fontes iniciais
- METR
- DORA
- Martin Fowler
- GitHub Spec Kit
- Anthropic Claude Code best practices
- Thoughtworks AI-aided test-first development

## Estrutura de dados
O conteudo deve ficar em arquivos locais versionados, nao em banco.

Sugestao:
- `src/content/aulas/*`
- `src/content/conceitos/*`
- `src/content/casos/*`
- `src/content/fontes/*`

Pode usar:
- `.ts`
- `.json`
- `.md`

Mas tudo precisa ser estatico e legivel como source-of-truth.
