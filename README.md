# PACED (formerly Delphi-AI)

## 🚀 Quick Start (30s)

To attach PACED authority to any repository:

1.  **Clone PACED** (inside your project root, git ignored):
    ```bash
    git clone https://github.com/belluga/delphi-ai.git delphi-ai
    ```
2.  **Initialize Bootloaders:**
    ```bash
    bash delphi-ai/init.sh
    ```
3.  **Link & Validate Environment:**
    ```bash
    bash delphi-ai/verify_context.sh --repair
    ```
4.  **Automate CI:** Call the `laravel-ci-engine.yml` in your project's GitHub Actions.

*Note: Ensure your project has a `foundation_documentation/project_constitution.md` with a declared `Namespace` (e.g., `flutter`, `laravel`) to enable stack-specific rules.*

---

## The Method
**PACED** (Progressively Accelerated Controlled Engineering through Determinism) is an internal engineering method designed to compound deterministic quality inside a deliberately restricted stack. 

The core thesis is that **accumulated system complexity should accelerate correct code creation, not slow it down.** By restricting the stack, deterministic validators, architecture rules, and CI checks can accumulate project by project, ensuring that engineering velocity compounds instead of decaying.

---

## 🏗️ Cascading Architecture (Governance Hierarchy)

PACED operates under a dual-layer **governance hierarchy** to ensure architecture consistency while allowing project-specific flexibility. This is managed through two distinct surfaces:

### I. Instruction Layer (`rules/`)
Heuristic guidelines that the agent (Delphi) must interpret and apply.
1.  **Local Rules (`.agents/rules/local/`):** Project-specific constitution and decisions. **Always overrides.**
2.  **Stack Rules (`.agents/rules/stack/`):** Specialized patterns for the active stack (Flutter, Laravel, Docker, etc.).
3.  **Core Rules (`.agents/rules/core/`):** Universal Delphi instructions and T.E.A.C.H. patterns.

### II. Deterministic Layer (`deterministic/`)
Algorithmic authority (Scripts, Guards, Linters) that the agent **must obey**. This is the non-negotiable Law of the Ecosystem.
1.  **Local Deterministic (`local/`):** Project-specific configurations, exceptions, and business-logic guardrails.
2.  **Stack Deterministic (`stack/`):** Technology-specific presets (e.g., Pint, Flutter Analyze, or custom architecture scripts).
3.  **Core Deterministic (`core/`):** Global PACED guards (TODO completion, Impact classifier, Session management).

---

## 🚀 Progressive Determinism

Progressive determinism is the operating model underneath PACED. It ensures:
- The agent converges against **deterministic law** before delivery reaches a human.
- The iteration cost is mostly **computational**, not human.
- Every project leaves behind more **deterministic intelligence** than it consumed.

### Deterministic Guards (Phase 0)
The following guards are now active in the `deterministic/core/` directory:
- `todo_completion_guard.py`: Enforces Definition of Done (DoD), validation steps, and gate resolution before a TODO can be closed.
- `finding_impact_classifier.py`: Analyzes code diffs to classify findings (Logic vs. Cosmetic) and prevents risky promotions.
- `session_lock_manager.py`: Manages session state and prevents concurrent agent conflicts.
- `metrics_consolidation_trigger.py`: Automatically extracts formalizable findings and populates the rule-events ledger.

---

## 🛠️ Setup & Environment Readiness

PACED uses a "Linker" strategy to inject the correct rules and deterministic guards into any project repository without polluting the git history.

### The PACED Linker (`verify_context.sh --repair`)
The `verify_context.sh` script is the orchestrator of the environment. When run with `--repair`, it:
1.  **Detects the Namespace:** Reads the `project_constitution.md` to identify the stack (e.g., `flutter`, `laravel`).
2.  **Establishes Symlinks:** Creates the `.agents/rules/` and `.agents/deterministic/` structures pointing to the correct global and stack-specific resources in `delphi-ai/`.
3.  **Validates Adherence:** Ensures that the local environment is 100% compliant with the PACED contract.

### Quick Install
1. Clone PACED into your project (git ignored):
   ```bash
   git clone https://github.com/belluga/delphi-ai.git delphi-ai
   ```
2. Run the initialization:
   ```bash
   bash delphi-ai/init.sh
   ```
3. Repair and Validate:
   ```bash
   bash delphi-ai/verify_context.sh --repair
   ```

---

## 📊 Metrics & Self-Improvement (Phase 0)

PACED closes the feedback loop by collecting metrics at the end of every session:
- **Location:** `foundation_documentation/artifacts/metrics/rule-events.jsonl`
- **Automation:** The `post-session-review` workflow automatically triggers metrics collection.
- **Goal:** Identify which rules are effective (True Positives) and which are escaping, allowing the ecosystem to recalibrate its deterministic layer.

---

## 🧩 How-to: Extending & Using the Ecosystem

### 1. How to Add a New Technology Stack
To introduce a new stack (e.g., `python`, `go`, `react`) into the PACED ecosystem:
1.  **Create the Deterministic Layer:** Create `deterministic/stacks/<new_stack>/` and add presets like `lint_config.yaml` or architecture scripts.
2.  **Create the Instruction Layer:** Create `rules/stacks/<new_stack>/` and add Markdown files explaining the patterns and standards for that stack.
3.  **Update the Linker (Optional):** If you want auto-detection, update the `get_project_namespace` function in `tools/verify_context.sh`. Otherwise, manual declaration in the project is sufficient.

### 2. How to "Subscribe" a Project to a Stack
In the project's `foundation_documentation/project_constitution.md`, add the following metadata:
```markdown
## PACED Context
- **Namespace:** <new_stack>
- **Rule Subscriptions:**
  - [x] **Core Rules:** (Always enabled)
  - [x] **Stack Rules:** (Enabled for <new_stack>)
```

### 3. How to Apply Changes (The Linker)
After updating the constitution or the `delphi-ai` core, always run:
```bash
bash delphi-ai/verify_context.sh --repair
```
This will dynamically rebuild the symlinks in `.agents/rules/` and `.agents/deterministic/`, ensuring the agent is operating under the latest authority.

### 4. How to Add Local Project Guardrails
If a project has a unique business rule that must be enforced:
1.  Create a script or config in `foundation_documentation/deterministic/`.
2.  The `verify_context.sh --repair` will automatically link it to `.agents/deterministic/local/`.
3.  The Delphi agent will prioritize this local check over stack or core rules.

---

## 🏗️ Cascading CI/CD (GitHub Actions)

O PACED centraliza a inteligência do CI/CD no `delphi-ai`. Os projetos (ex: `belluga_now_backend`) apenas "assinam" o contrato de CI global, garantindo que os **Deterministic Guards** rodem em todos os commits.

#### Exemplo: Assinatura do Belluga Now (`.github/workflows/ci.yml`)

```yaml
name: "CI: Belluga Now Backend"

on:
  push:
    branches: [dev, stage, main]
  pull_request:
    branches: [dev, stage, main]

jobs:
  paced-ci:
    uses: belluga/delphi-ai/.github/workflows/shared/laravel-ci-engine.yml@main
    with:
      namespace: "belluga-now"
      php_version: "8.2"
      node_version: "18"
      lint_command: "composer lint:strict"
      architecture_guard_command: "php scripts/architecture_guardrails.php"
    secrets:
      # O token deve ter acesso de leitura ao repositório belluga/delphi-ai
      GH_PAT: ${{ secrets.GH_PAT }}
```

**Benefícios da Assinatura:**
- **Zero Drift:** O CI remoto é 100% simétrico ao ambiente local (via `--repair`).
- **Guardrails Obrigatórios:** O `todo_completion_guard.py` barra o commit se houver TODOs inconsistentes.
- **Manutenção Centralizada:** Atualize o motor no `delphi-ai` e todos os projetos herdam a melhoria instantaneamente.

---

## Terminology
- **PACED**: The engineering method.
- **Delphi**: The agent persona implementing the method.
- **delphi-ai/**: The repository/install surface.
- **T.E.A.C.H.**: The communication protocol (Title, Evidence, Action, Context, Hint).
