#!/usr/bin/env python3
"""Deterministic pre-execution routing guard for Delphi model/role policy.

This guard validates that a declared next action is routed to the correct lane
before implementation, implementation-side validation, monitoring, review, or
self-improvement begins.

It emits a concise deterministic response and exits with:

  0  GO: routing is valid or an explicit approved exception is in effect.
  2  NO-GO: routing must change, waiver evidence is missing, or the contract
     is misapplied.
  1  Tool/runtime misuse.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


RULE_ID = "paced.agent-role-routing"
DEFAULT_CONTRACT_PATH = Path(__file__).resolve().parent.parent / "config" / "agent_role_routing.json"
OUTCOME_GO = "go"
OUTCOME_DELEGATE = "delegate-required"
OUTCOME_REVIEW = "review-required"
OUTCOME_WAIVER = "waiver-required"
OUTCOME_BLOCKED = "blocked"
ALLOWED_OUTCOMES = {
    OUTCOME_GO,
    OUTCOME_DELEGATE,
    OUTCOME_REVIEW,
    OUTCOME_WAIVER,
    OUTCOME_BLOCKED,
}
PLACEHOLDER_RE = re.compile(r"<[^>]+>")
NON_ALNUM_RE = re.compile(r"[^a-z0-9]+")
MISSING_TOKENS = {
    "",
    "missing",
    "pending",
    "tbd",
    "todo",
    "placeholder",
    "unknown",
}
NA_TOKENS = {
    "n-a",
    "na",
    "none",
    "not-applicable",
}


def strip_markup(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"`", "'", '"'}:
        value = value[1:-1].strip()
    return value


def normalize_token(value: str) -> str:
    value = strip_markup(value).lower()
    value = NON_ALNUM_RE.sub("-", value)
    return value.strip("-")


def is_missing(value: str | None, *, allow_na: bool = False) -> bool:
    if value is None:
        return True
    stripped = strip_markup(value)
    normalized = normalize_token(stripped)
    if normalized in NA_TOKENS:
        return not allow_na
    return (
        not stripped
        or bool(PLACEHOLDER_RE.search(stripped))
        or normalized in MISSING_TOKENS
    )


def load_contract(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def build_violation(code: str, message: str, resolution: str) -> dict[str, str]:
    return {
        "code": code,
        "message": message,
        "resolution": resolution,
    }


def match_token(actual: str, expected: str) -> bool:
    actual_norm = normalize_token(actual)
    expected_norm = normalize_token(expected)
    if not actual_norm or not expected_norm:
        return False
    return (
        actual_norm == expected_norm
        or actual_norm.startswith(expected_norm)
        or expected_norm.startswith(actual_norm)
        or f"-{expected_norm}-" in f"-{actual_norm}-"
    )


def model_matches(actual: str, expected_aliases: list[str]) -> bool:
    return any(match_token(actual, alias) for alias in expected_aliases)


def effort_matches(actual: str, expected_aliases: list[str]) -> bool:
    return any(match_token(actual, alias) for alias in expected_aliases)


def set_outcome(current: str, new: str) -> str:
    priority = {
        OUTCOME_GO: 0,
        OUTCOME_DELEGATE: 1,
        OUTCOME_REVIEW: 1,
        OUTCOME_WAIVER: 2,
        OUTCOME_BLOCKED: 3,
    }
    return new if priority[new] >= priority[current] else current


def validate_contract(contract: dict[str, Any]) -> None:
    if "clients" not in contract or "surfaces" not in contract or "effort_aliases" not in contract:
        raise ValueError("Contract must define clients, surfaces, and effort_aliases.")


def evaluate_routing(
    *,
    contract: dict[str, Any],
    client: str,
    surface: str,
    role: str,
    model: str | None,
    effort: str | None,
    proof_mode: str,
    exception_reason: str | None,
    waiver_reference: str | None,
) -> dict[str, Any]:
    validate_contract(contract)
    context: dict[str, Any] = {
        "client": client,
        "surface": surface,
        "selected_role": role,
        "selected_model": strip_markup(model or ""),
        "selected_effort": strip_markup(effort or ""),
        "proof_mode": proof_mode,
        "exception_reason": strip_markup(exception_reason or ""),
        "waiver_reference_present": False,
        "waiver_in_effect": False,
        "exception_in_effect": False,
    }
    violations: list[dict[str, str]] = []
    outcome = OUTCOME_GO

    if client not in contract["clients"]:
        return {
            "blocked": True,
            "outcome": OUTCOME_BLOCKED,
            "context": context,
            "violations": [
                build_violation(
                    "CLIENT-UNKNOWN",
                    f"Unknown client `{client}`.",
                    "Use a client declared in config/agent_role_routing.json.",
                )
            ],
        }
    if surface not in contract["surfaces"]:
        return {
            "blocked": True,
            "outcome": OUTCOME_BLOCKED,
            "context": context,
            "violations": [
                build_violation(
                    "SURFACE-UNKNOWN",
                    f"Unknown governed surface `{surface}`.",
                    "Use a surface declared in config/agent_role_routing.json.",
                )
            ],
        }

    client_cfg = contract["clients"][client]
    surface_cfg = contract["surfaces"][surface]
    expected_models = list(client_cfg["preferred_models"][surface_cfg["preferred_model_family"]])
    expected_efforts = list(contract["effort_aliases"][surface_cfg["required_effort_key"]])
    allowed_roles = list(surface_cfg["allowed_roles"])
    allowed_proof_modes = list(client_cfg["allowed_proof_modes"])
    allowed_exception_reasons = list(surface_cfg["allowed_exception_reasons"])

    context["required_lane"] = surface_cfg["required_lane"]
    context["allowed_roles"] = ", ".join(allowed_roles)
    context["expected_models"] = ", ".join(expected_models)
    context["expected_efforts"] = ", ".join(expected_efforts)

    role_value = normalize_token(role)
    proof_mode_value = normalize_token(proof_mode)
    exception_value = normalize_token(exception_reason or "")
    waiver_present = not is_missing(waiver_reference)
    context["waiver_reference_present"] = waiver_present

    if role_value not in {normalize_token(item) for item in allowed_roles} | {
        "primary-chat",
        "deterministic-only",
        "formal-reviewer",
        "routine-executor",
        "process-monitor",
    }:
        outcome = set_outcome(outcome, OUTCOME_BLOCKED)
        violations.append(
            build_violation(
                "ROLE-UNKNOWN",
                f"Selected role `{role}` is not a recognized routing role.",
                "Use one of the canonical roles such as primary-chat, routine-executor, formal-reviewer, process-monitor, or deterministic-only.",
            )
        )

    if proof_mode_value not in {normalize_token(item) for item in allowed_proof_modes}:
        outcome = set_outcome(outcome, OUTCOME_BLOCKED)
        violations.append(
            build_violation(
                "PROOF-MODE-UNSUPPORTED",
                f"Proof mode `{proof_mode}` is not allowed for client `{client}`.",
                f"Use one of: {', '.join(allowed_proof_modes)}.",
            )
        )

    if exception_value and exception_value not in NA_TOKENS:
        if exception_value not in {normalize_token(item) for item in allowed_exception_reasons}:
            outcome = set_outcome(outcome, OUTCOME_BLOCKED)
            violations.append(
                build_violation(
                    "EXCEPTION-UNSUPPORTED",
                    f"Exception reason `{exception_reason}` is not allowed for surface `{surface}`.",
                    "Remove the exception or use an exception reason explicitly allowed by the routing contract.",
                )
            )
        elif not waiver_present:
            outcome = set_outcome(outcome, OUTCOME_WAIVER)
            violations.append(
                build_violation(
                    "EXCEPTION-REFERENCE-MISSING",
                    f"Exception reason `{exception_reason}` is declared without waiver/approval evidence.",
                    "Record the explicit waiver/exception reference before using a routing exception.",
                )
            )
        else:
            context["exception_in_effect"] = True

    role_allowed = role_value in {normalize_token(item) for item in allowed_roles}
    if not role_allowed and not context["exception_in_effect"]:
        outcome = set_outcome(outcome, surface_cfg["failure_outcome"])
        violations.append(
            build_violation(
                "ROLE-MISMATCH",
                f"Surface `{surface}` requires role(s) {', '.join(allowed_roles)}, but selected role is `{role}`.",
                f"Route the action to {', '.join(allowed_roles)}, or use an approved explicit exception if the contract allows it.",
            )
        )

    llm_free = role_value == "deterministic-only"
    if not llm_free:
        if is_missing(model):
            if proof_mode_value == "waiver" and waiver_present and surface_cfg["waiver_allowed"]:
                context["waiver_in_effect"] = True
            else:
                outcome = set_outcome(outcome, OUTCOME_WAIVER)
                violations.append(
                    build_violation(
                        "MODEL-MISSING",
                        f"Surface `{surface}` requires a declared selected model for client `{client}`.",
                        f"Record one of the expected models ({', '.join(expected_models)}), or record approved waiver evidence.",
                    )
                )
        elif not model_matches(model or "", expected_models):
            outcome = set_outcome(outcome, surface_cfg["failure_outcome"])
            violations.append(
                build_violation(
                    "MODEL-MISMATCH",
                    f"Selected model `{model}` does not match the expected routing model(s) for `{client}` on `{surface}`.",
                    f"Use one of: {', '.join(expected_models)}.",
                )
            )

        if client_cfg["requires_effort"]:
            if is_missing(effort):
                if proof_mode_value == "waiver" and waiver_present and surface_cfg["waiver_allowed"]:
                    context["waiver_in_effect"] = True
                else:
                    outcome = set_outcome(outcome, OUTCOME_WAIVER)
                    violations.append(
                        build_violation(
                            "EFFORT-MISSING",
                            f"Client `{client}` requires declared effort for surface `{surface}`.",
                            f"Record one of the expected effort values ({', '.join(expected_efforts)}), or record approved waiver evidence.",
                        )
                    )
            elif not effort_matches(effort or "", expected_efforts):
                outcome = set_outcome(outcome, surface_cfg["failure_outcome"])
                violations.append(
                    build_violation(
                        "EFFORT-MISMATCH",
                        f"Selected effort `{effort}` does not match the expected effort tier for `{surface}`.",
                        f"Use one of: {', '.join(expected_efforts)}.",
                    )
                )

    if proof_mode_value == "waiver":
        if not waiver_present:
            outcome = set_outcome(outcome, OUTCOME_WAIVER)
            violations.append(
                build_violation(
                    "WAIVER-REFERENCE-MISSING",
                    "Proof mode `waiver` was selected without explicit waiver/approval evidence.",
                    "Record the waiver or approval reference before continuing.",
                )
            )
        else:
            context["waiver_in_effect"] = True

    return {
        "blocked": outcome != OUTCOME_GO,
        "outcome": outcome,
        "context": context,
        "violations": violations,
    }


def format_response(result: dict[str, Any]) -> str:
    lines = [
        "Agent Role Routing Guard",
        f"Rule: {RULE_ID}",
        f"Overall outcome: {result['outcome']}",
        "",
        "Context:",
    ]
    for key in sorted(result["context"]):
        lines.append(f"  - {key}: {result['context'][key]}")
    lines.append("")
    lines.append("Violations:")
    if result["violations"]:
        for violation in result["violations"]:
            lines.append(f"  - [{violation['code']}] {violation['message']}")
            lines.append(f"    resolution: {violation['resolution']}")
    else:
        lines.append("  - none")
    return "\n".join(lines)


def write_json(path: Path, result: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client", required=True, help="Client name from config/agent_role_routing.json.")
    parser.add_argument("--surface", required=True, help="Governed surface from config/agent_role_routing.json.")
    parser.add_argument("--role", required=True, help="Selected routing role.")
    parser.add_argument("--model", help="Selected model or declared model family alias.")
    parser.add_argument("--effort", help="Selected effort tier or alias.")
    parser.add_argument(
        "--proof-mode",
        required=True,
        help="How the routing choice is proved: artifact, declared, or waiver.",
    )
    parser.add_argument(
        "--exception-reason",
        help="Optional routing exception reason when the selected role deviates from the default lane.",
    )
    parser.add_argument(
        "--waiver-reference",
        help="Explicit waiver or approval reference when proof or role deviation requires one.",
    )
    parser.add_argument(
        "--contract",
        default=str(DEFAULT_CONTRACT_PATH),
        help="Optional path to an alternate routing contract JSON file.",
    )
    parser.add_argument("--json-output", help="Optional JSON output path.")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    contract_path = Path(args.contract).resolve()
    if not contract_path.is_file():
        print(f"Routing contract not found: {contract_path}", file=sys.stderr)
        return 1

    contract = load_contract(contract_path)
    result = evaluate_routing(
        contract=contract,
        client=args.client,
        surface=args.surface,
        role=args.role,
        model=args.model,
        effort=args.effort,
        proof_mode=args.proof_mode,
        exception_reason=args.exception_reason,
        waiver_reference=args.waiver_reference,
    )
    result["context"]["contract_path"] = str(contract_path)
    result["context"]["contract_id"] = contract.get("contract_id", "unknown")

    if args.json_output:
        write_json(Path(args.json_output), result)

    print(format_response(result))
    return 0 if result["outcome"] == OUTCOME_GO else 2


if __name__ == "__main__":
    raise SystemExit(main())
