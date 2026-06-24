#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from typing import List


HIGHEST_REVIEW_TIER = "ExtraRight-or-closest-equivalent"
ROUTINE_TIER = "medium"


def build_decision(surface: str, material_ambiguity: bool, goals_supported: bool) -> dict:
    reasons: List[str] = []
    goal_policy = "not_needed"
    recommended_effort = ROUTINE_TIER

    if surface == "ordinary-session":
        reasons.append("Ordinary sessions stay on the routine default unless another governed surface takes over.")
    elif surface == "self-improvement":
        recommended_effort = HIGHEST_REVIEW_TIER
        reasons.append("Instruction changes and Delphi self-improvement are broad-impact judgment surfaces.")
    elif surface == "strategic-framing":
        if material_ambiguity:
            recommended_effort = HIGHEST_REVIEW_TIER
            reasons.append("First-pass planning still leaves approval-material strategic ambiguity unresolved.")
        else:
            reasons.append("Strategic framing is still within routine judgment because the ambiguity test is not material.")
    elif surface == "todo-approval":
        recommended_effort = HIGHEST_REVIEW_TIER
        reasons.append("TODO approval and plan review are gate-satisfying judgment surfaces.")
    elif surface == "delivery-review":
        recommended_effort = HIGHEST_REVIEW_TIER
        reasons.append("Delivery, final review, and promotion-readiness adjudication are gate-satisfying judgment surfaces.")
    elif surface == "executor-subagent":
        goal_policy = "required" if goals_supported else "required-but-client-lacks-goals"
        reasons.append("Executor subagents stay on the routine default and rely on bounded GOAL contracts instead of higher effort.")
    elif surface == "review-subagent":
        recommended_effort = HIGHEST_REVIEW_TIER
        goal_policy = "stateless-default"
        reasons.append("Formal review subagents are judgment-first surfaces and should use the highest review-focused tier.")
    elif surface == "exploratory-review":
        goal_policy = "stateless-default"
        if material_ambiguity:
            recommended_effort = HIGHEST_REVIEW_TIER
            reasons.append("Exploratory review escalates only because the ambiguity test is material.")
        else:
            reasons.append("Exploratory second opinions stay on the routine default until they become gate-satisfying or materially ambiguous.")
    else:
        raise ValueError(f"Unsupported surface: {surface}")

    return {
        "artifact_kind": "effort_selection_advice",
        "surface": surface,
        "material_strategic_ambiguity": material_ambiguity,
        "goals_supported": goals_supported,
        "recommended_effort": recommended_effort,
        "goal_policy": goal_policy,
        "advisory_only": True,
        "reasons": reasons,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Advisory helper for Delphi effort-tier and GOAL selection."
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
    )

    if args.json_output:
        with open(args.json_output, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, sort_keys=True)
            handle.write("\n")

    print(f"Surface: {payload['surface']}")
    print(f"Recommended effort: {payload['recommended_effort']}")
    print(f"GOAL policy: {payload['goal_policy']}")
    print(f"Material strategic ambiguity: {str(payload['material_strategic_ambiguity']).lower()}")
    print("Advisory only: true")
    print("Reasons:")
    for reason in payload["reasons"]:
        print(f"- {reason}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
