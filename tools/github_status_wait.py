#!/usr/bin/env python3
"""Wait on generic GitHub status conditions and emit a TEACH runtime response.

This helper is intentionally generic. It currently supports:
- waiting for a GitHub Actions run to reach a terminal conclusion;
- waiting for a repository branch to exist.

The script stays quiet while polling and emits a TEACH envelope only when the
target becomes actionable, fails, or times out.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from dataclasses import dataclass
from typing import Any
from urllib.parse import quote


RULE_ID = "paced.github-status.wait"
ENFORCEMENT = "wait_before_manual_followup"
NON_BLOCKING_JOB_CONCLUSIONS = {"success", "skipped", "neutral"}


class OperationalError(Exception):
    """Raised when the tool cannot evaluate the requested status."""


@dataclass
class TeachResult:
    status: str
    overall_outcome: str
    violations: list[str]
    resolution_prompts: list[str]
    context_lines: list[str]
    exit_code: int


def run_gh(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["gh", *args],
        check=False,
        capture_output=True,
        text=True,
    )


def gh_auth_healthy() -> bool:
    return run_gh(["auth", "status"]).returncode == 0


def gh_json(args: list[str]) -> Any:
    result = run_gh(args)
    if result.returncode != 0:
        stderr = (result.stderr or result.stdout).strip()
        raise OperationalError(f"gh {' '.join(args)} failed: {stderr or 'unknown error'}")
    payload = result.stdout.strip()
    return json.loads(payload or "null")


def gh_json_or_none_on_404(args: list[str]) -> Any | None:
    result = run_gh(args)
    if result.returncode == 0:
        payload = result.stdout.strip()
        return json.loads(payload or "null")

    stderr = f"{result.stderr}\n{result.stdout}".strip()
    lowered = stderr.lower()
    if "404" in lowered or "not found" in lowered:
        return None
    raise OperationalError(f"gh {' '.join(args)} failed: {stderr or 'unknown error'}")


def print_teach(result: TeachResult) -> None:
    print("TEACH runtime response")
    print(f"status: {result.status}")
    print(f"enforcement: {ENFORCEMENT}")
    print(f"rule_id: {RULE_ID}")
    print("violation:")
    if result.violations:
        for item in result.violations:
            print(f"  - {item}")
    else:
        print("  - none")
    print("resolution_prompt:")
    if result.resolution_prompts:
        for item in result.resolution_prompts:
            print(f"  - {item}")
    else:
        print("  - none")
    print("context:")
    if result.context_lines:
        for line in result.context_lines:
            print(f"  {line}")
    else:
        print("  none: n/a")
    print()
    print(f"Overall outcome: {result.overall_outcome}")


def ready_result(context_lines: list[str], resolution: str) -> TeachResult:
    return TeachResult(
        status="ready",
        overall_outcome="go",
        violations=[],
        resolution_prompts=[resolution],
        context_lines=context_lines,
        exit_code=0,
    )


def blocked_result(
    violation: str,
    resolution: str,
    context_lines: list[str],
) -> TeachResult:
    return TeachResult(
        status="blocked",
        overall_outcome="no-go",
        violations=[violation],
        resolution_prompts=[resolution],
        context_lines=context_lines,
        exit_code=2,
    )


def wait_loop(poll_seconds: int, timeout_seconds: int):
    deadline = time.monotonic() + timeout_seconds
    first_iteration = True
    while True:
        yield
        if time.monotonic() >= deadline:
            return
        first_iteration = False
        if poll_seconds > 0:
            time.sleep(poll_seconds if not first_iteration else 0)


def select_run(args: argparse.Namespace) -> dict[str, Any] | None:
    if args.run_id is not None:
        return {
            "databaseId": args.run_id,
            "id": args.run_id,
            "name": None,
            "event": args.event,
            "head_branch": args.branch,
            "head_sha": args.head_sha,
        }

    payload = gh_json(["api", f"repos/{args.repo}/actions/runs?per_page={args.run_limit}"])
    runs = payload.get("workflow_runs", [])
    for run in runs:
        if args.branch and run.get("head_branch") != args.branch:
            continue
        if args.event and run.get("event") != args.event:
            continue
        if args.workflow and run.get("name") != args.workflow:
            continue
        if args.head_sha and run.get("head_sha") != args.head_sha:
            continue
        return run
    return None


def summarize_jobs(jobs: list[dict[str, Any]]) -> tuple[list[str], list[str]]:
    pending: list[str] = []
    failing: list[str] = []
    for job in jobs:
        status = (job.get("status") or "").lower()
        conclusion = (job.get("conclusion") or "").lower()
        name = job.get("name") or "unnamed-job"
        if status != "completed":
            pending.append(name)
            continue
        if conclusion and conclusion not in NON_BLOCKING_JOB_CONCLUSIONS:
            failing.append(f"{name} ({conclusion})")
    return pending, failing


def wait_for_run(args: argparse.Namespace) -> TeachResult:
    allowed_conclusions = {
        item.strip().lower()
        for item in args.expect_conclusion.split(",")
        if item.strip()
    }
    if not allowed_conclusions:
        raise OperationalError("--expect-conclusion must include at least one value")

    timeout_seconds = args.timeout_seconds
    deadline = time.monotonic() + timeout_seconds
    resolved_run: dict[str, Any] | None = None

    while True:
        if resolved_run is None:
            resolved_run = select_run(args)
            if resolved_run is None:
                if time.monotonic() >= deadline:
                    context = [
                        f"mode: run",
                        f"repo: {args.repo}",
                        f"label: {args.label or 'n/a'}",
                        f"resolved_run: not-found",
                        f"branch: {args.branch or 'n/a'}",
                        f"event: {args.event or 'n/a'}",
                        f"workflow: {args.workflow or 'n/a'}",
                        f"head_sha: {args.head_sha or 'n/a'}",
                        f"timeout_seconds: {args.timeout_seconds}",
                    ]
                    return blocked_result(
                        "No matching GitHub Actions run appeared before the timeout expired.",
                        "Inspect the repository Actions page, confirm the expected branch/event/workflow filters, then rerun this helper.",
                        context,
                    )
                if args.poll_seconds > 0:
                    time.sleep(args.poll_seconds)
                continue

        run_id = resolved_run.get("databaseId") or resolved_run.get("id")
        run_payload = gh_json(
            [
                "run",
                "view",
                str(run_id),
                "--repo",
                args.repo,
                "--json",
                "databaseId,status,conclusion,workflowName,url,headSha,event,jobs",
            ]
        )
        jobs = run_payload.get("jobs", [])
        pending_jobs, failing_jobs = summarize_jobs(jobs)
        status = (run_payload.get("status") or "").lower()
        conclusion = (run_payload.get("conclusion") or "").lower()
        context = [
            "mode: run",
            f"repo: {args.repo}",
            f"label: {args.label or 'n/a'}",
            f"run_id: {run_payload.get('databaseId') or run_id}",
            f"workflow: {run_payload.get('workflowName') or resolved_run.get('name') or 'n/a'}",
            f"event: {run_payload.get('event') or resolved_run.get('event') or 'n/a'}",
            f"head_sha: {run_payload.get('headSha') or resolved_run.get('head_sha') or 'n/a'}",
            f"status: {status or 'unknown'}",
            f"conclusion: {conclusion or 'pending'}",
            f"pending_jobs: {', '.join(pending_jobs) if pending_jobs else 'none'}",
            f"failing_jobs: {', '.join(failing_jobs) if failing_jobs else 'none'}",
            f"url: {run_payload.get('url') or 'n/a'}",
        ]

        if status == "completed":
            if conclusion in allowed_conclusions:
                return ready_result(
                    context,
                    "Proceed with the next manual step; the monitored run reached the expected terminal conclusion.",
                )
            return blocked_result(
                f"GitHub Actions run concluded with '{conclusion or 'unknown'}' instead of the expected '{args.expect_conclusion}'.",
                "Open the run URL, inspect the failing job or conclusion, repair the upstream issue, and rerun this helper after a new run starts.",
                context,
            )

        if time.monotonic() >= deadline:
            return blocked_result(
                "GitHub Actions run did not reach a terminal conclusion before the timeout expired.",
                "Inspect the run URL for queue or execution stalls, then rerun this helper with a larger timeout only if the upstream workflow is still healthy.",
                context,
            )

        if args.poll_seconds > 0:
            time.sleep(args.poll_seconds)


def wait_for_branch(args: argparse.Namespace) -> TeachResult:
    encoded_branch = quote(args.branch, safe="")
    deadline = time.monotonic() + args.timeout_seconds

    while True:
        payload = gh_json_or_none_on_404(["api", f"repos/{args.repo}/branches/{encoded_branch}"])
        if payload is not None:
            context = [
                "mode: branch",
                f"repo: {args.repo}",
                f"label: {args.label or 'n/a'}",
                f"branch: {payload.get('name') or args.branch}",
                f"commit_sha: {((payload.get('commit') or {}).get('sha')) or 'n/a'}",
                f"protected: {payload.get('protected') if 'protected' in payload else 'n/a'}",
            ]
            return ready_result(
                context,
                "Proceed with the next manual step; the monitored branch now exists.",
            )

        if time.monotonic() >= deadline:
            context = [
                "mode: branch",
                f"repo: {args.repo}",
                f"label: {args.label or 'n/a'}",
                f"branch: {args.branch}",
                f"timeout_seconds: {args.timeout_seconds}",
            ]
            return blocked_result(
                "The requested branch did not appear before the timeout expired.",
                "Inspect the upstream automation responsible for creating the branch, then rerun this helper after the triggering workflow succeeds.",
                context,
            )

        if args.poll_seconds > 0:
            time.sleep(args.poll_seconds)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Wait on generic GitHub status conditions and emit a TEACH runtime response."
    )
    subparsers = parser.add_subparsers(dest="mode", required=True)

    run_parser = subparsers.add_parser(
        "run",
        help="Wait for a GitHub Actions run to reach a terminal conclusion.",
    )
    run_parser.add_argument("--repo", required=True, help="GitHub repository slug (owner/name).")
    run_parser.add_argument("--run-id", type=int, help="Exact GitHub Actions run ID to monitor.")
    run_parser.add_argument("--branch", help="Resolve the newest matching run for this branch.")
    run_parser.add_argument("--event", help="Optional event filter when resolving a run.")
    run_parser.add_argument("--workflow", help="Optional workflow name filter when resolving a run.")
    run_parser.add_argument("--head-sha", help="Optional head SHA filter when resolving a run.")
    run_parser.add_argument(
        "--expect-conclusion",
        default="success",
        help="Comma-separated list of acceptable terminal conclusions (default: success).",
    )
    run_parser.add_argument(
        "--run-limit",
        type=int,
        default=100,
        help="Maximum number of recent runs to inspect when resolving by branch/event/workflow (default: 100).",
    )
    run_parser.add_argument(
        "--poll-seconds",
        type=int,
        default=15,
        help="Polling interval in seconds while waiting (default: 15).",
    )
    run_parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=1800,
        help="Maximum wait time in seconds before blocking (default: 1800).",
    )
    run_parser.add_argument("--label", help="Optional human label echoed in TEACH context.")

    branch_parser = subparsers.add_parser(
        "branch",
        help="Wait for a repository branch to exist.",
    )
    branch_parser.add_argument("--repo", required=True, help="GitHub repository slug (owner/name).")
    branch_parser.add_argument("--branch", required=True, help="Branch name to wait for.")
    branch_parser.add_argument(
        "--poll-seconds",
        type=int,
        default=15,
        help="Polling interval in seconds while waiting (default: 15).",
    )
    branch_parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=1800,
        help="Maximum wait time in seconds before blocking (default: 1800).",
    )
    branch_parser.add_argument("--label", help="Optional human label echoed in TEACH context.")

    return parser


def validate_args(args: argparse.Namespace) -> None:
    if not gh_auth_healthy():
        raise OperationalError("gh auth status is not healthy")
    if args.poll_seconds < 0:
        raise OperationalError("--poll-seconds must be >= 0")
    if args.timeout_seconds < 0:
        raise OperationalError("--timeout-seconds must be >= 0")
    if args.mode == "run" and args.run_id is None and not args.branch:
        raise OperationalError("run mode requires either --run-id or --branch")


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        validate_args(args)
        if args.mode == "run":
            result = wait_for_run(args)
        elif args.mode == "branch":
            result = wait_for_branch(args)
        else:
            raise OperationalError(f"unsupported mode: {args.mode}")
    except OperationalError as exc:
        result = TeachResult(
            status="blocked",
            overall_outcome="no-go",
            violations=[str(exc)],
            resolution_prompts=["Repair the operational prerequisite, then rerun this helper."],
            context_lines=[f"mode: {getattr(args, 'mode', 'unknown')}"] if "args" in locals() else [],
            exit_code=1,
        )

    print_teach(result)
    return result.exit_code


if __name__ == "__main__":
    sys.exit(main())
