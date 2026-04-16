#!/usr/bin/env python3
"""Manage a restartable triple-audit session for no-context review rounds."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from jsonschema import Draft202012Validator


SCRIPT_PATH = Path(__file__).resolve()
SKILL_ROOT = SCRIPT_PATH.parent.parent
REPO_ROOT = SKILL_ROOT.parent.parent
TOOLS_ROOT = REPO_ROOT / "tools"
SCHEMAS_ROOT = REPO_ROOT / "schemas"
RESULT_SCHEMA_PATH = SCHEMAS_ROOT / "subagent_review_result.schema.json"

SESSION_SCHEMA_VERSION = "triple-audit-session-v1"
ROUND_SUMMARY_SCHEMA_VERSION = "triple-audit-round-summary-v1"

LANES = (
    {
        "id": "elegance",
        "review_kind": "critique",
        "goal": (
            "Bounded critique with elegance focus. Treat elegance and structural "
            "soundness as the primary decision lenses."
        ),
    },
    {
        "id": "performance",
        "review_kind": "critique",
        "goal": (
            "Bounded critique with performance focus. Treat performance and "
            "operational fit as the primary decision lenses."
        ),
    },
    {
        "id": "test-quality",
        "review_kind": "test_quality_audit",
        "goal": (
            "Bounded test-quality audit. Treat regression protection, assertion "
            "effectiveness, and test realism as the primary decision lenses."
        ),
    },
)

SEVERITY_ORDER = {"none": 0, "low": 1, "medium": 2, "high": 3}


def now_utc() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.strip().lower()).strip("-")
    return slug or "audit"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def default_run_root(package_path: Path, label: str | None) -> Path:
    stem = label or package_path.stem
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return package_path.parent / f"{slugify(stem)}-triple-audit-{timestamp}"


def validate_json(payload: dict, schema_path: Path, label: str) -> None:
    validator = Draft202012Validator(load_json(schema_path))
    errors = sorted(
        validator.iter_errors(payload),
        key=lambda item: list(item.absolute_path),
    )
    if not errors:
        return

    rendered = []
    for error in errors:
        field = " -> ".join(str(part) for part in error.absolute_path) or label
        rendered.append(f"{field}: {error.message}")
    raise SystemExit(f"{label} failed schema validation:\n" + "\n".join(rendered))


def highest_severity(findings: list[dict]) -> str:
    if not findings:
        return "none"
    return max(findings, key=lambda item: SEVERITY_ORDER[item["severity"]])[
        "severity"
    ]


def run_dispatch(
    *,
    package_path: Path,
    todo_path: Path | None,
    lane: dict,
    dispatch_json_path: Path,
    dispatch_markdown_path: Path,
) -> None:
    command = [
        sys.executable,
        str(TOOLS_ROOT / "subagent_review_dispatch.py"),
        "--review-kind",
        lane["review_kind"],
        "--package",
        str(package_path),
        "--reviewer-count",
        "1",
        "--goal",
        lane["goal"],
        "--json-output",
        str(dispatch_json_path),
        "--markdown-output",
        str(dispatch_markdown_path),
    ]
    if todo_path is not None:
        command.extend(["--todo-path", str(todo_path)])
    subprocess.run(command, check=True)


def run_merge(
    *,
    dispatch_path: Path,
    review_path: Path,
    merge_json_path: Path,
    merge_markdown_path: Path,
) -> None:
    command = [
        sys.executable,
        str(TOOLS_ROOT / "subagent_review_merge.py"),
        "--dispatch",
        str(dispatch_path),
        "--review",
        str(review_path),
        "--json-output",
        str(merge_json_path),
        "--markdown-output",
        str(merge_markdown_path),
    ]
    subprocess.run(command, check=True)


def render_progress_markdown(session: dict) -> str:
    lines = [
        "# Triple Audit Session Progress",
        "",
        f"- **Session file:** `{session['session_path']}`",
        f"- **Bounded package:** `{session['package_path']}`",
        f"- **Related TODO:** `{session['todo_path'] or 'n/a'}`",
        f"- **Run root:** `{session['run_root']}`",
        f"- **Current round:** `{session['current_round']}`",
        "",
    ]

    for round_info in session["rounds"]:
        lines.extend(
            [
                f"## Round {round_info['round']:02d}",
                f"- **Status:** `{round_info['status']}`",
                f"- **Prepared at:** `{round_info['prepared_at']}`",
            ]
        )
        if round_info.get("merged_at"):
            lines.append(f"- **Merged at:** `{round_info['merged_at']}`")
        if round_info.get("round_status"):
            lines.append(f"- **Round classification:** `{round_info['round_status']}`")
        lines.append("- **Lane files:**")
        for lane in round_info["lanes"]:
            result_state = "present" if Path(lane["result_path"]).is_file() else "missing"
            lines.append(
                f"  - `{lane['id']}`: dispatch=`{lane['dispatch_markdown_path']}` "
                f"result=`{lane['result_path']}` ({result_state})"
            )
        if round_info.get("summary_markdown_path"):
            lines.append(
                f"- **Summary markdown:** `{round_info['summary_markdown_path']}`"
            )
        lines.append("")

    lines.extend(
        [
            "## Exact Next Step",
            session["exact_next_step"],
            "",
        ]
    )
    return "\n".join(lines)


def build_round(session: dict, round_number: int) -> dict:
    run_root = Path(session["run_root"])
    package_path = Path(session["package_path"])
    todo_path = Path(session["todo_path"]) if session.get("todo_path") else None
    round_root = run_root / f"round-{round_number:02d}"
    dispatch_root = round_root / "dispatch"
    results_root = round_root / "results"
    merge_root = round_root / "merge"

    lanes = []
    for lane in LANES:
        dispatch_json_path = dispatch_root / f"{lane['id']}.dispatch.json"
        dispatch_markdown_path = dispatch_root / f"{lane['id']}.dispatch.md"
        result_path = results_root / f"{lane['id']}.result.json"
        merge_json_path = merge_root / f"{lane['id']}.merge.json"
        merge_markdown_path = merge_root / f"{lane['id']}.merge.md"

        run_dispatch(
            package_path=package_path,
            todo_path=todo_path,
            lane=lane,
            dispatch_json_path=dispatch_json_path,
            dispatch_markdown_path=dispatch_markdown_path,
        )

        lanes.append(
            {
                "id": lane["id"],
                "review_kind": lane["review_kind"],
                "goal": lane["goal"],
                "dispatch_json_path": str(dispatch_json_path),
                "dispatch_markdown_path": str(dispatch_markdown_path),
                "result_path": str(result_path),
                "merge_json_path": str(merge_json_path),
                "merge_markdown_path": str(merge_markdown_path),
            }
        )

    summary_json_path = round_root / "round-summary.json"
    summary_markdown_path = round_root / "round-summary.md"
    return {
        "round": round_number,
        "status": "prepared",
        "prepared_at": now_utc(),
        "lanes": lanes,
        "summary_json_path": str(summary_json_path),
        "summary_markdown_path": str(summary_markdown_path),
    }


def save_session(session: dict) -> None:
    session_path = Path(session["session_path"])
    write_json(session_path, session)
    progress_path = Path(session["progress_markdown_path"])
    write_text(progress_path, render_progress_markdown(session) + "\n")


def load_session(path: Path) -> dict:
    session = load_json(path)
    if session.get("schema_version") != SESSION_SCHEMA_VERSION:
        raise SystemExit(
            f"Unsupported session schema version: {session.get('schema_version')}"
        )
    return session


def current_round(session: dict) -> dict:
    for round_info in session["rounds"]:
        if round_info["round"] == session["current_round"]:
            return round_info
    raise SystemExit("Current round not found in session state.")


def ensure_result_matches_lane(result_payload: dict, lane: dict) -> None:
    validate_json(result_payload, RESULT_SCHEMA_PATH, "subagent review result")
    dispatch_path = str(Path(lane["dispatch_json_path"]).resolve())
    if Path(result_payload["dispatch_path"]).resolve() != Path(dispatch_path):
        raise SystemExit(
            f"Result dispatch_path does not match lane dispatch: {lane['id']}"
        )
    if result_payload["review_kind"] != lane["review_kind"]:
        raise SystemExit(
            f"Result review_kind does not match lane {lane['id']}: "
            f"{result_payload['review_kind']} != {lane['review_kind']}"
        )


def round_result_status(round_info: dict) -> str:
    missing = [
        lane["id"]
        for lane in round_info["lanes"]
        if not Path(lane["result_path"]).is_file()
    ]
    if missing:
        return "awaiting-results"
    return round_info.get("round_status", round_info["status"])


def classify_round(round_info: dict) -> tuple[str, list[str], dict]:
    lane_summaries = {}
    recommended_paths = []
    conflicts = []

    for lane in round_info["lanes"]:
        result_payload = load_json(Path(lane["result_path"]))
        finding_count = len(result_payload["findings"])
        lane_summaries[lane["id"]] = {
            "review_kind": lane["review_kind"],
            "result_path": lane["result_path"],
            "merge_json_path": lane["merge_json_path"],
            "merge_markdown_path": lane["merge_markdown_path"],
            "overall_assessment": result_payload["overall_assessment"],
            "recommended_path": result_payload["recommended_path"],
            "finding_count": finding_count,
            "highest_finding_severity": highest_severity(result_payload["findings"]),
            "status": "clean" if finding_count == 0 else "needs_resolution",
        }
        recommended_paths.append(result_payload["recommended_path"])

    unique_paths = sorted(set(path.strip() for path in recommended_paths if path.strip()))
    if len(unique_paths) > 1:
        conflicts.append(
            "recommended_path_conflict: reviewers proposed different recommended paths"
        )

    if conflicts:
        return "needs_adjudication", conflicts, lane_summaries

    if all(item["status"] == "clean" for item in lane_summaries.values()):
        return "clean", conflicts, lane_summaries

    return "needs_resolution", conflicts, lane_summaries


def render_round_summary_markdown(summary: dict) -> str:
    lines = [
        f"# Triple Audit Round Summary: Round {summary['round']:02d}",
        "",
        "- **Artifact kind:** `triple_audit_round_summary`",
        "- **Authoritative:** `false`",
        f"- **Session path:** `{summary['session_path']}`",
        f"- **Round status:** `{summary['round_status']}`",
        f"- **Merged at:** `{summary['merged_at']}`",
        "",
        "## Lane Summary",
    ]

    for lane_id, lane in summary["lanes"].items():
        lines.extend(
            [
                f"### {lane_id}",
                f"- **Status:** `{lane['status']}`",
                f"- **Overall assessment:** `{lane['overall_assessment']}`",
                f"- **Recommended path:** `{lane['recommended_path']}`",
                f"- **Finding count:** `{lane['finding_count']}`",
                f"- **Highest severity:** `{lane['highest_finding_severity']}`",
                f"- **Merge markdown:** `{lane['merge_markdown_path']}`",
                "",
            ]
        )

    lines.extend(["## Conflicts"])
    if summary["conflicts"]:
        for conflict in summary["conflicts"]:
            lines.append(f"- {conflict}")
    else:
        lines.append("- `none`")
    lines.extend(["", "## Exact Next Step", summary["exact_next_step"], ""])
    return "\n".join(lines)


def start_session(args: argparse.Namespace) -> int:
    package_path = Path(args.package).resolve()
    if not package_path.is_file():
        raise SystemExit(f"Bounded package not found: {package_path}")

    todo_path = None
    if args.todo:
        todo_path = Path(args.todo).resolve()
        if not todo_path.is_file():
            raise SystemExit(f"Related TODO not found: {todo_path}")

    run_root = (
        Path(args.run_root).resolve()
        if args.run_root
        else default_run_root(package_path, args.label).resolve()
    )
    if run_root.exists() and any(run_root.iterdir()):
        raise SystemExit(f"Run root already exists and is not empty: {run_root}")
    run_root.mkdir(parents=True, exist_ok=True)

    session_path = run_root / "session.json"
    progress_markdown_path = run_root / "progress.md"
    session = {
        "schema_version": SESSION_SCHEMA_VERSION,
        "artifact_kind": "triple_audit_session",
        "authoritative": False,
        "skill_name": "audit-protocol-triple-review",
        "created_at": now_utc(),
        "session_path": str(session_path),
        "progress_markdown_path": str(progress_markdown_path),
        "package_path": str(package_path),
        "todo_path": str(todo_path) if todo_path else None,
        "run_root": str(run_root),
        "current_round": 1,
        "rounds": [],
        "exact_next_step": (
            "Spawn one no-context reviewer per lane using the current round dispatch "
            "markdown files, then record each JSON result with `record-result`."
        ),
    }
    session["rounds"].append(build_round(session, 1))
    save_session(session)

    print(f"Created triple audit session: {session_path}")
    print(f"Progress markdown: {progress_markdown_path}")
    print(f"Current round status: {round_result_status(current_round(session))}")
    return 0


def status_session(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    round_info = current_round(session)
    save_session(session)
    print(f"Session: {session['session_path']}")
    print(f"Run root: {session['run_root']}")
    print(f"Current round: {round_info['round']:02d}")
    print(f"Current round status: {round_result_status(round_info)}")
    print(f"Progress markdown: {session['progress_markdown_path']}")
    return 0


def record_result(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    round_info = current_round(session)
    lane_lookup = {lane["id"]: lane for lane in round_info["lanes"]}
    if args.lane not in lane_lookup:
        raise SystemExit(f"Unknown lane: {args.lane}")

    input_path = Path(args.input).resolve()
    if not input_path.is_file():
        raise SystemExit(f"Review result file not found: {input_path}")

    lane = lane_lookup[args.lane]
    result_payload = load_json(input_path)
    ensure_result_matches_lane(result_payload, lane)

    output_path = Path(lane["result_path"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(input_path, output_path)

    round_info["status"] = "results-recorded"
    session["exact_next_step"] = (
        "Record the remaining reviewer JSON results, or run `merge` once all three "
        "lane results are present."
    )
    save_session(session)
    print(f"Recorded {args.lane} result at {output_path}")
    return 0


def merge_session(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    round_info = current_round(session)

    missing = [
        lane["id"]
        for lane in round_info["lanes"]
        if not Path(lane["result_path"]).is_file()
    ]
    if missing:
        raise SystemExit(
            "Cannot merge current round; missing lane results: " + ", ".join(missing)
        )

    for lane in round_info["lanes"]:
        result_payload = load_json(Path(lane["result_path"]))
        ensure_result_matches_lane(result_payload, lane)
        run_merge(
            dispatch_path=Path(lane["dispatch_json_path"]),
            review_path=Path(lane["result_path"]),
            merge_json_path=Path(lane["merge_json_path"]),
            merge_markdown_path=Path(lane["merge_markdown_path"]),
        )

    round_status, conflicts, lane_summaries = classify_round(round_info)
    exact_next_step = {
        "clean": (
            "Record the clean round in the governing TODO or gate evidence and close "
            "the audit session."
        ),
        "needs_resolution": (
            "Resolve the recorded findings in code/docs/tests, then open the next "
            "round with `next-round`."
        ),
        "needs_adjudication": (
            "Prepare a contradiction note, run the follow-up no-context challenge if "
            "needed, adjudicate the conflict explicitly, then open the next round."
        ),
    }[round_status]

    summary = {
        "schema_version": ROUND_SUMMARY_SCHEMA_VERSION,
        "artifact_kind": "triple_audit_round_summary",
        "authoritative": False,
        "session_path": session["session_path"],
        "round": round_info["round"],
        "merged_at": now_utc(),
        "round_status": round_status,
        "conflicts": conflicts,
        "lanes": lane_summaries,
        "exact_next_step": exact_next_step,
    }

    write_json(Path(round_info["summary_json_path"]), summary)
    write_text(
        Path(round_info["summary_markdown_path"]),
        render_round_summary_markdown(summary) + "\n",
    )

    round_info["status"] = "merged"
    round_info["merged_at"] = summary["merged_at"]
    round_info["round_status"] = round_status
    session["exact_next_step"] = exact_next_step
    save_session(session)

    print(f"Merged round {round_info['round']:02d}")
    print(f"Round status: {round_status}")
    print(f"Summary markdown: {round_info['summary_markdown_path']}")
    return 0


def next_round(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    current = current_round(session)
    if current["status"] != "merged":
        raise SystemExit(
            "Current round has not been merged yet; merge it before opening the next round."
        )

    next_round_number = current["round"] + 1
    session["current_round"] = next_round_number
    session["rounds"].append(build_round(session, next_round_number))
    session["exact_next_step"] = (
        "Spawn one no-context reviewer per lane using the new current-round dispatch "
        "markdown files, then record each JSON result with `record-result`."
    )
    save_session(session)
    print(f"Prepared round {next_round_number:02d}")
    print(f"Progress markdown: {session['progress_markdown_path']}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Manage a deterministic triple-audit session."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    start = subparsers.add_parser("start", help="Create a new triple-audit session.")
    start.add_argument("--package", required=True, help="Bounded package markdown path.")
    start.add_argument("--todo", help="Optional related TODO path.")
    start.add_argument(
        "--run-root",
        help="Optional explicit run-root directory for session artifacts.",
    )
    start.add_argument(
        "--label",
        help="Optional label used when deriving the default run-root directory.",
    )
    start.set_defaults(func=start_session)

    status = subparsers.add_parser("status", help="Show current session status.")
    status.add_argument("--session", required=True, help="Session JSON path.")
    status.set_defaults(func=status_session)

    record = subparsers.add_parser(
        "record-result",
        help="Validate and copy one reviewer result into the current round.",
    )
    record.add_argument("--session", required=True, help="Session JSON path.")
    record.add_argument(
        "--lane",
        required=True,
        choices=[lane["id"] for lane in LANES],
        help="Lane id to record.",
    )
    record.add_argument("--input", required=True, help="Reviewer JSON file path.")
    record.set_defaults(func=record_result)

    merge = subparsers.add_parser(
        "merge",
        help="Merge the current round and classify it as clean/resolution/adjudication.",
    )
    merge.add_argument("--session", required=True, help="Session JSON path.")
    merge.set_defaults(func=merge_session)

    next_parser = subparsers.add_parser(
        "next-round",
        help="Prepare the next round after the current round is merged.",
    )
    next_parser.add_argument("--session", required=True, help="Session JSON path.")
    next_parser.set_defaults(func=next_round)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
