#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import List


HIGHEST_REVIEW_TIER = "ExtraRight-or-closest-equivalent"
ROUTINE_TIER = "medium"
LOW_OR_MEDIUM_TIER = "low-or-medium"
ROUTING_CONTRACT = Path(__file__).resolve().parent.parent / "config" / "agent_role_routing.json"
ROUTING_DATA = json.loads(ROUTING_CONTRACT.read_text(encoding="utf-8"))
CLIENT_CHOICES = tuple(ROUTING_DATA["clients"])


def model_family(client: str, family: str) -> str:
    return ROUTING_DATA["clients"][client]["preferred_models"][family][0]


ACTIVE_SESSION_MODEL = "active-session-default"


def build_decision(
    surface: str,
    material_ambiguity: bool,
    goals_supported: bool,
    client: str = "codex",
) -> dict:
    reasons: List[str] = []
    model_notes: List[str] = []
    goal_policy = "not_needed"
    recommended_effort = ROUTINE_TIER
    recommended_model = ACTIVE_SESSION_MODEL
    recommended_model_family = "active_session"
    execution_state_policy = "primary-chat-state"
    chat_orchestrator_model = model_family(client, "chat_orchestrator")
    routine_executor_model = model_family(client, "routine_executor")
    formal_review_model = model_family(client, "strongest_review")
    monitoring_model = model_family(client, "monitoring")

    if surface == "ordinary-session":
        recommended_model = chat_orchestrator_model
        recommended_model_family = "chat_orchestrator"
        execution_state_policy = "primary-chat-no-implementation-code-when-executor-available"
        reasons.append("Ordinary chat/orchestrator turns stay on the routine default unless another governed surface takes over.")
        reasons.append("The chat/orchestrator plans, packages handoffs, reconciles evidence, and adjudicates gates instead of creating implementation code when executor subagents are available.")
    elif surface == "self-improvement":
        recommended_effort = HIGHEST_REVIEW_TIER
        recommended_model = formal_review_model
        recommended_model_family = "strongest_review"
        reasons.append("Instruction changes and Delphi self-improvement are broad-impact judgment surfaces.")
    elif surface == "strategic-framing":
        if material_ambiguity:
            recommended_effort = HIGHEST_REVIEW_TIER
            recommended_model = formal_review_model
            recommended_model_family = "strongest_review"
            reasons.append("First-pass planning still leaves approval-material strategic ambiguity unresolved.")
        else:
            recommended_model = chat_orchestrator_model
            recommended_model_family = "chat_orchestrator"
            reasons.append("Strategic framing is still within routine judgment because the ambiguity test is not material.")
    elif surface == "todo-approval":
        recommended_effort = HIGHEST_REVIEW_TIER
        recommended_model = chat_orchestrator_model
        recommended_model_family = "chat_orchestrator"
        reasons.append("TODO approval and plan review remain primary-chat judgment surfaces unless a separate formal reviewer is explicitly dispatched.")
    elif surface == "delivery-review":
        recommended_effort = HIGHEST_REVIEW_TIER
        recommended_model = chat_orchestrator_model
        recommended_model_family = "chat_orchestrator"
        reasons.append("Delivery, final review, and promotion-readiness adjudication stay on the orchestrator lane unless a separate formal reviewer is explicitly dispatched.")
    elif surface == "executor-subagent":
        recommended_model = routine_executor_model
        recommended_model_family = "routine_executor"
        goal_policy = "required" if goals_supported else "required-but-client-lacks-goals"
        execution_state_policy = "sticky-per-chat-or-todo-compact-state"
        reasons.append("Routine executor subagents use the central routing contract's routine-executor model when model selection is available.")
        reasons.append("Executor subagents rely on bounded GOAL contracts instead of higher effort by default.")
        reasons.append("Sticky executor state is scoped to the current chat/TODO and must retain summaries only, not raw logs, full diffs, transcripts, or artifacts.")
    elif surface == "monitoring":
        recommended_model = f"deterministic-first-or-{monitoring_model}-if-llm-needed"
        recommended_model_family = "monitoring"
        recommended_effort = LOW_OR_MEDIUM_TIER
        execution_state_policy = "ephemeral-bounded-status-pass"
        reasons.append("Monitoring should be deterministic first; if an LLM is needed, summarize bounded output with an ephemeral mini pass.")
        reasons.append("Do not use a standing watcher or let the main chat consume verbose logs continuously.")
    elif surface == "review-subagent":
        recommended_effort = HIGHEST_REVIEW_TIER
        recommended_model = formal_review_model
        recommended_model_family = "strongest_review"
        goal_policy = "stateless-default"
        execution_state_policy = "stateless-no-context-review"
        reasons.append("Formal review subagents are judgment-first surfaces and should use the highest review-focused tier.")
    elif surface == "exploratory-review":
        recommended_model = routine_executor_model
        recommended_model_family = "routine_executor"
        goal_policy = "stateless-default"
        execution_state_policy = "stateless-no-context-review"
        if material_ambiguity:
            recommended_effort = HIGHEST_REVIEW_TIER
            recommended_model = formal_review_model
            recommended_model_family = "strongest_review"
            reasons.append("Exploratory review escalates only because the ambiguity test is material.")
        else:
            reasons.append("Exploratory second opinions stay on the routine default until they become gate-satisfying or materially ambiguous.")
    else:
        raise ValueError(f"Unsupported surface: {surface}")

    if recommended_model_family == "routine_executor":
        model_notes.append("Use the model selected by config/agent_role_routing.json when model selection is available; otherwise record the closest available efficient coding/subagent model.")
    elif recommended_model_family == "strongest_review":
        model_notes.append("Use the strongest-review model selected by config/agent_role_routing.json, or record the closest available review/reasoning model.")
    elif recommended_model_family == "chat_orchestrator":
        model_notes.append("Use the contract-selected chat/orchestrator model when the active session model is configurable; otherwise keep the active session/default model.")
    elif recommended_model_family == "active_session":
        model_notes.append("Keep the active session/default model unless this turn becomes a governed review, adjudication, or executor surface.")

    return {
        "artifact_kind": "effort_selection_advice",
        "client": client,
        "surface": surface,
        "material_strategic_ambiguity": material_ambiguity,
        "goals_supported": goals_supported,
        "recommended_model": recommended_model,
        "recommended_model_family": recommended_model_family,
        "recommended_effort": recommended_effort,
        "goal_policy": goal_policy,
        "execution_state_policy": execution_state_policy,
        "advisory_only": True,
        "model_notes": model_notes,
        "reasons": reasons,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Advisory helper for Delphi effort-tier and GOAL selection."
    )
    parser.add_argument(
        "--client",
        default="codex",
        choices=CLIENT_CHOICES,
        help="Client whose model families should be resolved from the routing contract.",
    )
    parser.add_argument(
        "--surface",
        required=True,
        choices=[
            "ordinary-session",
            "self-improvement",
            "strategic-framing",
            "todo-approval",
            "delivery-review",
            "executor-subagent",
            "monitoring",
            "review-subagent",
            "exploratory-review",
        ],
    )
    parser.add_argument(
        "--material-strategic-ambiguity",
        action="store_true",
        help="Mark that first-pass planning still leaves approval-material strategic ambiguity unresolved.",
    )
    parser.add_argument(
        "--goals-supported",
        action="store_true",
        help="Mark that the active client supports persistent GOAL state.",
    )
    parser.add_argument(
        "--json-output",
        help="Optional path to write the advisory payload as JSON.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    payload = build_decision(
        surface=args.surface,
        material_ambiguity=args.material_strategic_ambiguity,
        goals_supported=args.goals_supported,
        client=args.client,
    )

    if args.json_output:
        with open(args.json_output, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, sort_keys=True)
            handle.write("\n")

    print(f"Client: {payload['client']}")
    print(f"Surface: {payload['surface']}")
    print(f"Recommended model: {payload['recommended_model']}")
    print(f"Recommended model family: {payload['recommended_model_family']}")
    print(f"Recommended effort: {payload['recommended_effort']}")
    print(f"GOAL policy: {payload['goal_policy']}")
    print(f"Execution state policy: {payload['execution_state_policy']}")
    print(f"Material strategic ambiguity: {str(payload['material_strategic_ambiguity']).lower()}")
    print("Advisory only: true")
    if payload["model_notes"]:
        print("Model notes:")
        for note in payload["model_notes"]:
            print(f"- {note}")
    print("Reasons:")
    for reason in payload["reasons"]:
        print(f"- {reason}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
