# PACED (formerly Delphi-AI)

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

## 🧩 Extensibility
The architecture is **extensible by design**. To add a new technology stack:
1. Create `deterministic/stacks/<new_stack>/` for presets and scripts.
2. Create `rules/stacks/<new_stack>/` for instruction sets.
3. Declare `Namespace: <new_stack>` in the project's `project_constitution.md`.
4. Run `--repair` to link the new authority layer.

---

## Terminology
- **PACED**: The engineering method.
- **Delphi**: The agent persona implementing the method.
- **delphi-ai/**: The repository/install surface.
- **T.E.A.C.H.**: The communication protocol (Title, Evidence, Action, Context, Hint).
