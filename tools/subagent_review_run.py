#!/usr/bin/env python3
"""Run a fresh internal Codex review with deterministic final-message collection."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dispatch", required=True, help="Bounded dispatch markdown path.")
    parser.add_argument("--package", required=True, help="Bounded review-package markdown path.")
    parser.add_argument("--raw-output", required=True, help="Path for the reviewer final JSON/text result.")
    parser.add_argument("--events-output", required=True, help="Path for the Codex JSONL event stream.")
    parser.add_argument("--stderr-output", required=True, help="Path for Codex stderr diagnostics.")
    parser.add_argument("--workdir", required=True, help="Codex working directory.")
    parser.add_argument("--codex-bin", default="codex", help="Codex executable (default: codex).")
    parser.add_argument("--model", help="Optional explicit internal-review model.")
    parser.add_argument(
        "--isolate-project-context",
        action="store_true",
        help=(
            "Run the reviewer from a scratch directory with user config and project rules disabled. "
            "Use only when the embedded package is self-contained and the project context prevents a fresh review."
        ),
    )
    parser.add_argument(
        "--isolation-workdir",
        default="/tmp",
        help="Scratch workdir used with --isolate-project-context (default: /tmp).",
    )
    return parser.parse_args()


def build_prompt(dispatch_path: Path, package_path: Path) -> str:
    dispatch = dispatch_path.read_text(encoding="utf-8")
    package = package_path.read_text(encoding="utf-8")
    return "\n\n".join(
        [
            "You are a fresh internal no-context reviewer, not the implementing agent. "
            "Do not edit files or call tools. The complete bounded dispatch and review package are embedded below. "
            "Assess only that package and return the dispatch-required final JSON object as your entire response.",
            "--- DISPATCH ---\n" + dispatch,
            "--- BOUNDED REVIEW PACKAGE ---\n" + package,
        ]
    )


def parse_events(events_text: str) -> list[dict]:
    events: list[dict] = []
    for line_number, line in enumerate(events_text.splitlines(), start=1):
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError as error:
            raise SystemExit(f"invalid Codex JSONL event at line {line_number}: {error}") from error
        if not isinstance(event, dict):
            raise SystemExit(f"invalid Codex JSONL event at line {line_number}: expected object")
        events.append(event)
    return events


def final_agent_message(events: list[dict]) -> str | None:
    messages = [
        event["item"].get("text")
        for event in events
        if event.get("type") == "item.completed"
        and isinstance(event.get("item"), dict)
        and event["item"].get("type") == "agent_message"
        and isinstance(event["item"].get("text"), str)
    ]
    return messages[-1] if messages else None


def main() -> int:
    args = parse_args()
    dispatch_path = Path(args.dispatch).resolve()
    package_path = Path(args.package).resolve()
    raw_output_path = Path(args.raw_output).resolve()
    events_output_path = Path(args.events_output).resolve()
    stderr_output_path = Path(args.stderr_output).resolve()
    workdir = Path(args.workdir).resolve()
    isolation_workdir = Path(args.isolation_workdir).resolve()

    for path in (raw_output_path, events_output_path, stderr_output_path):
        path.parent.mkdir(parents=True, exist_ok=True)

    command = [
        args.codex_bin,
        "exec",
        "--ephemeral",
        "--sandbox",
        "read-only",
        "--color",
        "never",
        "--json",
        "--output-last-message",
        str(raw_output_path),
    ]
    if args.isolate_project_context:
        if not isolation_workdir.is_dir():
            raise SystemExit(
                "isolated review workdir does not exist or is not a directory: "
                f"{isolation_workdir}"
            )
        command.extend(
            [
                "--ignore-user-config",
                "--ignore-rules",
                "--skip-git-repo-check",
                "-C",
                str(isolation_workdir),
            ]
        )
    else:
        command.extend(["-C", str(workdir)])
    if args.model:
        command.extend(["-m", args.model])
    command.append("-")

    completed = subprocess.run(
        command,
        input=build_prompt(dispatch_path, package_path),
        text=True,
        capture_output=True,
        check=False,
    )
    events_output_path.write_text(completed.stdout, encoding="utf-8")
    stderr_output_path.write_text(completed.stderr, encoding="utf-8")

    if completed.returncode != 0:
        raise SystemExit(
            f"Codex reviewer process failed with exit code {completed.returncode}; inspect {stderr_output_path}."
        )

    events = parse_events(completed.stdout)
    if not any(event.get("type") == "turn.completed" for event in events):
        raise SystemExit(
            "Codex reviewer stream ended without turn.completed; this is retryable collection failure. "
            f"Inspect {events_output_path} and {stderr_output_path}."
        )

    if not raw_output_path.is_file() or not raw_output_path.read_text(encoding="utf-8").strip():
        fallback = final_agent_message(events)
        if not fallback:
            raise SystemExit(
                "Codex completed without output-last-message or final agent message; this is retryable collection failure. "
                f"Inspect {events_output_path} and {stderr_output_path}."
            )
        raw_output_path.write_text(fallback.rstrip() + "\n", encoding="utf-8")

    print(f"internal review collection completed: {raw_output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
