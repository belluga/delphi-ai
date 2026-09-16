#!/usr/bin/env python3
"""Deterministic hook runtime for Delphi session/process loops.

This tool provides a single canonical runtime for Delphi hook governance across
clients. The current focus is:

- Claude Code: enforced SessionStart / PreToolUse / PostToolUse / ConfigChange
- Cline IDE: reminder-only session start using the same runtime state

The runtime state is reconstructible and non-authoritative. It exists only to
make objective process preconditions explicit instead of relying on chat memory.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def read_payload() -> dict[str, Any]:
    raw = sys.stdin.read()
    if not raw.strip():
        return {}
    return json.loads(raw)


def git_toplevel(start: Path) -> Path | None:
    try:
        result = subprocess.run(
            ["git", "-C", str(start), "rev-parse", "--show-toplevel"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

    output = result.stdout.strip()
    if not output:
        return None
    return Path(output).resolve()


def detect_repo_root(payload: dict[str, Any], explicit_root: str | None) -> Path:
    if explicit_root:
        return Path(explicit_root).resolve()

    candidates = [
        payload.get("workspacePath"),
        os.environ.get("CLAUDE_PROJECT_DIR"),
        payload.get("cwd"),
        os.getcwd(),
    ]
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(str(candidate)).resolve()
        top = git_toplevel(path)
        if top is not None:
            return top
        return path
    return Path(os.getcwd()).resolve()


def detect_delphi_root(repo_root: Path) -> Path:
    if (repo_root / "main_instructions.md").is_file() and (repo_root / "tools").is_dir():
        return repo_root
    nested = repo_root / "delphi-ai"
    if (nested / "main_instructions.md").is_file() and (nested / "tools").is_dir():
        return nested
    raise SystemExit(f"Unable to resolve Delphi root from {repo_root}")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def unique_sorted(items: list[str] | set[str]) -> list[str]:
    return sorted({item for item in items if item})


def normalize_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if str(item).strip()]


def to_logical_path(path_value: str, delphi_root: Path) -> str | None:
    try:
        path = Path(path_value).resolve()
    except OSError:
        return None
    try:
        return path.relative_to(delphi_root).as_posix()
    except ValueError:
        return None


def logical_to_path(logical_path: str, delphi_root: Path) -> Path:
    return delphi_root / logical_path


def expand_read_groups(contract: dict[str, Any], group_names: list[str]) -> list[str]:
    groups = contract.get("read_groups", {})
    expanded: list[str] = []
    for group_name in group_names:
        expanded.extend(normalize_list(groups.get(group_name)))
    return unique_sorted(expanded)


def matching_path_classes(contract: dict[str, Any], logical_path: str) -> list[str]:
    matches: list[str] = []
    for class_name, class_cfg in contract.get("path_classes", {}).items():
        for pattern in normalize_list(class_cfg.get("matchers")):
            if fnmatch.fnmatch(logical_path, pattern):
                matches.append(class_name)
                break
    return matches


def required_reads_for_targets(
    contract: dict[str, Any],
    logical_targets: list[str],
    delphi_root: Path,
) -> tuple[list[str], list[str]]:
    required: set[str] = set()
    matched_classes: set[str] = set()

    for logical_path in logical_targets:
        class_names = matching_path_classes(contract, logical_path)
        matched_classes.update(class_names)
        for class_name in class_names:
            class_cfg = contract["path_classes"][class_name]
            group_names = normalize_list(class_cfg.get("required_read_groups"))
            required.update(expand_read_groups(contract, group_names))

    filtered_required: set[str] = set()
    for logical_path in required:
        candidate = logical_to_path(logical_path, delphi_root)
        if logical_path in logical_targets and not candidate.exists():
            continue
        filtered_required.add(logical_path)

    return unique_sorted(filtered_required), unique_sorted(matched_classes)


def required_validation_categories_for_classes(
    contract: dict[str, Any],
    class_names: list[str],
) -> list[str]:
    categories: set[str] = set()
    for class_name in class_names:
        class_cfg = contract.get("path_classes", {}).get(class_name, {})
        categories.update(normalize_list(class_cfg.get("required_validation_categories")))
    return unique_sorted(categories)


def command_categories(contract: dict[str, Any], command: str) -> list[str]:
    categories: list[str] = []
    for category, patterns in contract.get("validation_command_categories", {}).items():
        for pattern in normalize_list(patterns):
            if re.search(pattern, command):
                categories.append(category)
                break
    return unique_sorted(categories)


def is_closeout_command(contract: dict[str, Any], command: str) -> bool:
    for pattern in normalize_list(contract.get("closeout_command_patterns")):
        if re.search(pattern, command):
            return True
    return False


def fresh_state(
    contract: dict[str, Any],
    client: str,
    repo_root: Path,
    delphi_root: Path,
    payload: dict[str, Any],
) -> dict[str, Any]:
    return {
        "bootloader_loaded": True,
        "client": client,
        "contract_id": contract["contract_id"],
        "contract_version": contract["version"],
        "delphi_root": str(delphi_root),
        "dirty_since_validation": False,
        "edited_logical_paths": [],
        "last_guard_event": payload.get("hook_event_name", ""),
        "last_validation_at": "",
        "last_validation_commands": [],
        "loaded_logical_paths": [],
        "repo_root": str(repo_root),
        "session_id": str(payload.get("session_id", "")),
        "session_started_at": utc_now(),
        "touched_path_classes": [],
        "updated_at": utc_now(),
        "validation_categories_since_edit": [],
    }


def load_state(
    state_path: Path,
    contract: dict[str, Any],
    client: str,
    repo_root: Path,
    delphi_root: Path,
    payload: dict[str, Any],
) -> dict[str, Any]:
    if state_path.exists():
        state = load_json(state_path)
    else:
        state = fresh_state(contract, client, repo_root, delphi_root, payload)

    state.setdefault("loaded_logical_paths", [])
    state.setdefault("edited_logical_paths", [])
    state.setdefault("touched_path_classes", [])
    state.setdefault("validation_categories_since_edit", [])
    state.setdefault("last_validation_commands", [])
    state.setdefault("dirty_since_validation", False)
    state.setdefault("bootloader_loaded", True)
    state["updated_at"] = utc_now()
    return state


def update_loaded_paths(state: dict[str, Any], logical_paths: list[str]) -> None:
    state["loaded_logical_paths"] = unique_sorted(
        normalize_list(state.get("loaded_logical_paths")) + logical_paths
    )


def record_edit(state: dict[str, Any], logical_paths: list[str], class_names: list[str]) -> None:
    state["edited_logical_paths"] = unique_sorted(
        normalize_list(state.get("edited_logical_paths")) + logical_paths
    )
    state["touched_path_classes"] = unique_sorted(
        normalize_list(state.get("touched_path_classes")) + class_names
    )
    state["dirty_since_validation"] = True
    state["validation_categories_since_edit"] = []


def record_validation(state: dict[str, Any], command: str, categories: list[str]) -> None:
    state["validation_categories_since_edit"] = unique_sorted(
        normalize_list(state.get("validation_categories_since_edit")) + categories
    )
    commands = normalize_list(state.get("last_validation_commands"))
    commands.append(command)
    state["last_validation_commands"] = commands[-10:]
    state["last_validation_at"] = utc_now()


def build_session_context(contract: dict[str, Any], repo_root: Path) -> str:
    bootstrap = expand_read_groups(contract, ["bootstrap"])
    self_improvement = expand_read_groups(contract, ["self_improvement"])
    tool_inventory = expand_read_groups(contract, ["tool_inventory"])
    hook_contract = expand_read_groups(contract, ["hook_contract"])
    lines: list[str] = []

    if (repo_root / "foundation_documentation" / "project_mandate.md").is_file():
        lines.append("Project mandate found. Remember to load context from foundation_documentation/.")

    lines.append(
        "Delphi hook governance active. Before editing Delphi canonical surfaces, read: "
        + ", ".join(f"`{item}`" for item in bootstrap + self_improvement)
        + "."
    )
    lines.append(
        "When touching `tools/**`, also read: "
        + ", ".join(f"`{item}`" for item in tool_inventory)
        + "."
    )
    lines.append(
        "When touching hook-governed surfaces such as `.claude/settings.json`, `.claude/hooks/**`, "
        "`.clinerules/hooks/**`, `scripts/setup_delphi.sh`, or `initialization_checklist.md`, also read: "
        + ", ".join(f"`{item}`" for item in hook_contract)
        + "."
    )
    lines.append(
        "Git `commit`/`push` for Delphi self-maintenance stays blocked until the latest edits have fresh "
        "`bash tools/self_check.sh`, `git diff --check`, and tool-test evidence when `tools/**` or hook-governed surfaces changed."
    )
    return " ".join(lines)


def collect_logical_targets(tool_name: str, payload: dict[str, Any], delphi_root: Path) -> list[str]:
    tool_input = payload.get("tool_input", {})
    tool_response = payload.get("tool_response", {})
    candidates: list[str] = []

    if tool_name in {"Write", "Edit", "MultiEdit", "Read"}:
        file_path = tool_input.get("file_path") or tool_response.get("filePath")
        if isinstance(file_path, str):
            logical = to_logical_path(file_path, delphi_root)
            if logical:
                candidates.append(logical)

    if tool_name == "ConfigChange":
        file_path = payload.get("file_path")
        if isinstance(file_path, str):
            logical = to_logical_path(file_path, delphi_root)
            if logical:
                candidates.append(logical)

    return unique_sorted(candidates)


def claude_context_output(event_name: str, additional_context: str | None = None) -> dict[str, Any]:
    payload: dict[str, Any] = {"hookSpecificOutput": {"hookEventName": event_name}}
    if additional_context:
        payload["hookSpecificOutput"]["additionalContext"] = additional_context
    return payload


def claude_pretool_decision(
    decision: str,
    reason: str,
    additional_context: str | None = None,
) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }
    if additional_context:
        payload["hookSpecificOutput"]["additionalContext"] = additional_context
    return payload


def cline_session_output(context: str) -> dict[str, Any]:
    return {
        "cancel": False,
        "contextModification": context,
    }


def missing_required_reads(
    required_reads: list[str],
    state: dict[str, Any],
) -> list[str]:
    loaded = set(normalize_list(state.get("loaded_logical_paths")))
    return unique_sorted([item for item in required_reads if item not in loaded])


def validate_claude_settings(settings_path: Path, contract: dict[str, Any]) -> list[str]:
    try:
        settings = load_json(settings_path)
    except (OSError, json.JSONDecodeError) as exc:
        return [f".claude/settings.json is unreadable or invalid JSON: {exc}"]

    errors: list[str] = []
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return ["Missing top-level `hooks` object in .claude/settings.json."]

    required_hooks = contract.get("required_claude_project_hooks", {})
    for event_name, scripts in required_hooks.items():
        hook_groups = hooks.get(event_name)
        if not isinstance(hook_groups, list) or not hook_groups:
            errors.append(f"Missing `{event_name}` hook group in .claude/settings.json.")
            continue

        for script_name in normalize_list(scripts):
            found = False
            for group in hook_groups:
                if not isinstance(group, dict):
                    continue
                for hook in group.get("hooks", []):
                    if not isinstance(hook, dict):
                        continue
                    if hook.get("type") != "command":
                        continue
                    command = str(hook.get("command", ""))
                    if script_name in command:
                        found = True
                        break
                if found:
                    break
            if not found:
                errors.append(f"`{event_name}` does not call `.claude/hooks/{script_name}`.")

    deny_rules = normalize_list(settings.get("permissions", {}).get("deny"))
    forbidden = set(normalize_list(contract.get("forbidden_claude_deny_rules")))
    for rule in deny_rules:
        if rule in forbidden:
            errors.append(
                f"Forbidden deny rule `{rule}` reintroduces unconditional write blocking that bypasses hook governance."
            )

    return errors


def handle_session_start(
    contract: dict[str, Any],
    client: str,
    repo_root: Path,
    delphi_root: Path,
    state_path: Path,
    payload: dict[str, Any],
) -> tuple[dict[str, Any], int]:
    state = fresh_state(contract, client, repo_root, delphi_root, payload)
    save_json(state_path, state)
    context = build_session_context(contract, repo_root)
    if client == "claude-code":
        return claude_context_output("SessionStart", context), 0
    return cline_session_output(context), 0


def handle_pretooluse(
    contract: dict[str, Any],
    client: str,
    repo_root: Path,
    delphi_root: Path,
    state_path: Path,
    payload: dict[str, Any],
) -> tuple[dict[str, Any] | None, int]:
    state = load_state(state_path, contract, client, repo_root, delphi_root, payload)
    tool_name = str(payload.get("tool_name", ""))
    logical_targets = collect_logical_targets(tool_name, payload, delphi_root)

    if tool_name in {"Write", "Edit", "MultiEdit"}:
        required_reads, class_names = required_reads_for_targets(contract, logical_targets, delphi_root)
        if class_names:
            missing = missing_required_reads(required_reads, state)
            if missing:
                reason = (
                    "Delphi hook governance blocked this edit until the required canonical surfaces are read: "
                    + ", ".join(missing)
                )
                return claude_pretool_decision("deny", reason), 0
        return None, 0

    if tool_name == "Bash":
        command = str(payload.get("tool_input", {}).get("command", ""))
        categories = command_categories(contract, command)
        if categories:
            bootstrap_reads = expand_read_groups(contract, ["bootstrap", "self_improvement"])
            missing = missing_required_reads(bootstrap_reads, state)
            if missing:
                reason = (
                    "Delphi hook governance blocked this validation command until the lifecycle surfaces are read: "
                    + ", ".join(missing)
                )
                return claude_pretool_decision("deny", reason), 0

        if is_closeout_command(contract, command):
            touched_classes = normalize_list(state.get("touched_path_classes"))
            if touched_classes and state.get("dirty_since_validation", False):
                required_categories = required_validation_categories_for_classes(contract, touched_classes)
                present_categories = set(normalize_list(state.get("validation_categories_since_edit")))
                missing_categories = unique_sorted(
                    [item for item in required_categories if item not in present_categories]
                )
                if missing_categories:
                    reason = (
                        "Delphi hook governance blocked this closeout command because fresh validation is missing: "
                        + ", ".join(missing_categories)
                    )
                    return claude_pretool_decision("deny", reason), 0
        return None, 0

    return None, 0


def handle_posttooluse(
    contract: dict[str, Any],
    client: str,
    repo_root: Path,
    delphi_root: Path,
    state_path: Path,
    payload: dict[str, Any],
) -> tuple[dict[str, Any] | None, int]:
    state = load_state(state_path, contract, client, repo_root, delphi_root, payload)
    tool_name = str(payload.get("tool_name", ""))

    if tool_name == "Read":
        update_loaded_paths(state, collect_logical_targets(tool_name, payload, delphi_root))

    elif tool_name in {"Write", "Edit", "MultiEdit"}:
        logical_targets = collect_logical_targets(tool_name, payload, delphi_root)
        _, class_names = required_reads_for_targets(contract, logical_targets, delphi_root)
        if class_names:
            record_edit(state, logical_targets, class_names)

    elif tool_name == "Bash":
        command = str(payload.get("tool_input", {}).get("command", ""))
        categories = command_categories(contract, command)
        if categories:
            record_validation(state, command, categories)

    save_json(state_path, state)
    return None, 0


def handle_config_change(
    contract: dict[str, Any],
    delphi_root: Path,
    payload: dict[str, Any],
) -> tuple[dict[str, Any] | None, int]:
    if str(payload.get("source", "")) != "project_settings":
        return None, 0

    file_path = payload.get("file_path")
    if not isinstance(file_path, str):
        return None, 0

    logical_path = to_logical_path(file_path, delphi_root)
    if logical_path != ".claude/settings.json":
        return None, 0

    errors = validate_claude_settings(Path(file_path).resolve(), contract)
    if not errors:
        return None, 0

    return {
        "decision": "block",
        "reason": "Delphi hook governance rejected the settings change: " + " ".join(errors),
    }, 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client", required=True, choices=["claude-code", "cline-ide", "codex"])
    parser.add_argument(
        "--event",
        required=True,
        choices=["SessionStart", "PreToolUse", "PostToolUse", "ConfigChange", "TaskStart"],
    )
    parser.add_argument("--repo-root", help="Optional repository root override.")
    parser.add_argument("--state-path", help="Optional runtime state path override.")
    parser.add_argument("--contract-path", help="Optional hook contract path override.")
    args = parser.parse_args(argv)

    payload = read_payload()
    repo_root = detect_repo_root(payload, args.repo_root)
    delphi_root = detect_delphi_root(repo_root)
    if args.contract_path:
        contract_path = Path(args.contract_path).resolve()
    else:
        contract_path = delphi_root / "config" / "hook_governance.json"
    contract = load_json(contract_path)

    runtime_logical = str(contract["runtime_state"]["logical_path"])
    if args.state_path:
        state_path = Path(args.state_path).resolve()
    else:
        state_path = delphi_root / runtime_logical

    if args.event in {"SessionStart", "TaskStart"}:
        output, status = handle_session_start(contract, args.client, repo_root, delphi_root, state_path, payload)
    elif args.event == "PreToolUse":
        output, status = handle_pretooluse(contract, args.client, repo_root, delphi_root, state_path, payload)
    elif args.event == "PostToolUse":
        output, status = handle_posttooluse(contract, args.client, repo_root, delphi_root, state_path, payload)
    elif args.event == "ConfigChange":
        output, status = handle_config_change(contract, delphi_root, payload)
    else:
        raise SystemExit(f"Unsupported event {args.event}")

    if output:
        sys.stdout.write(json.dumps(output))
    return status


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
