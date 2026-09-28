#!/usr/bin/env python3
"""Resolve a declared single-TODO route from the canonical JSON contract."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


CONTRACT = Path(__file__).resolve().parent.parent / "config" / "agent_role_routing.json"


def normalize(value: str) -> str:
    return value.strip().lower().replace("_", "-")


def resolve(*, client: str, surface: str, role: str, review_kind: str | None = None) -> dict[str, Any]:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    if client not in contract["clients"]:
        raise ValueError(f"Unknown client `{client}`.")
    if surface not in contract["surfaces"]:
        raise ValueError(f"Unknown surface `{surface}`.")

    client_config = contract["clients"][client]
    surface_config = contract["surfaces"][surface]
    normalized_role = normalize(role)
    allowed_roles = {normalize(item) for item in surface_config["allowed_roles"]}
    if normalized_role not in allowed_roles:
        raise ValueError(f"Role `{role}` is not allowed for surface `{surface}`.")

    family = surface_config["preferred_model_family"]
    if review_kind:
        family = contract["review_kind_model_families"].get(review_kind, "")
        if not family:
            raise ValueError(f"Unknown review kind `{review_kind}`.")
    for declared_role, declared_family in surface_config.get("role_model_family_overrides", {}).items():
        if normalize(declared_role) == normalized_role:
            family = declared_family
            break

    return {
        "artifact_kind": "orchestrated_single_todo_routing",
        "authority": "config/agent_role_routing.json",
        "client": client,
        "surface": surface,
        "role": role,
        "review_kind": review_kind or "n/a",
        "model_family": family,
        "model_aliases": list(client_config["preferred_models"][family]),
        "effort_aliases": list(contract["effort_aliases"][surface_config["required_effort_key"]]),
        "proof_modes": list(client_config["allowed_proof_modes"]),
        "provider_fallback": "prohibited",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client", required=True)
    parser.add_argument("--surface", required=True)
    parser.add_argument("--role", required=True)
    parser.add_argument("--review-kind")
    parser.add_argument("--json-output")
    args = parser.parse_args()
    try:
        result = resolve(client=args.client, surface=args.surface, role=args.role, review_kind=args.review_kind)
    except (KeyError, ValueError) as exc:
        print(f"TEACH: blocked: {exc}")
        return 2
    if args.json_output:
        output = Path(args.json_output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
