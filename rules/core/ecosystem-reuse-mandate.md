# Ecosystem Reuse & Abstraction Boundary Mandate

## Context
O PACED opera em uma lógica de ecossistema, onde o conhecimento e as capacidades são compartilhados entre projetos para acelerar o desenvolvimento e garantir a consistência técnica.

## Doctrine: The Reuse Bias
A implementação de qualquer funcionalidade significativa deve considerar deliberadamente o seu potencial de reuso.

### 1. Decision Criteria
- **Ecosystem Bias:** Se uma capacidade for credivelmente reutilizável e puder ser abstraída sem vazar semânticas específicas do produto, ela deve ser desenhada com uma **fronteira compatível com pacotes**.
- **Project Sovereignty:** Funcionalidades ligadas estritamente ao modelo de negócio, tenant ou postura específica de um produto devem permanecer **locais ao projeto**.
- **Anti-Pattern (Premature Abstraction):** A abstração nunca deve ser forçada. Se for artificial ou imatura, mantenha a implementação local.

## Workflow Enforcement
1. **Registry Consultation:** Before implementing any feature, the agent must consult `foundation_documentation/package_registry.md` to check for existing packages or libraries that cover the planned capability. See companion rule `paced.core.package-first`.
2. **Planning:** TODOs de planejamento de features devem incluir uma seção `Ecosystem Impact Analysis` e um `Package-First Assessment`.
3. **Constitution:** O `project_constitution.md` deve listar os candidatos identificados para reuso.
4. **Extraction:** A extração para pacotes deve ocorrer quando a estabilidade da abstração for comprovada em pelo menos um uso real.
5. **Registration:** Every new package or library must be registered in `foundation_documentation/package_registry.md` within the same TODO that creates it.

---
**Authority:** PACED Core Architecture
**Rule ID:** `paced.core.ecosystem-reuse`
