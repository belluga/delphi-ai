#!/usr/bin/env python3
"""Manage a restartable dedicated multi-lane audit session for no-context review rounds."""

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

SESSION_SCHEMA_VERSION = "triple-audit-session-v2"
ROUND_SUMMARY_SCHEMA_VERSION = "triple-audit-round-summary-v2"
RESOLUTION_STATUSES = ("resolved", "accepted-debt", "blocked")

BASE_LANES = (
    {
        "id": "performance",
        "review_kind": "critique",
        "goal": (
            "Bounded critique with performance focus. Treat performance and "
            "operational fit as the primary decision lenses. Escalate as blocking "
            "only for concrete severe server/runtime risk: unbounded scans, N+1 or "
            "request-loop behavior where one query/endpoint is required, exact "
            "lookup through list/page walking, high-cardinality in-memory filtering, "
            "scheduler/job fetch-all reconciliation, load-amplifying cache/hydration "
            "paths, or resource-exhaustion/security exposure. Marginal "
            "micro-optimizations and speculative scaling polish are non-blocking "
            "debt."
        ),
    },
    {
        "id": "test-quality",
        "review_kind": "test_quality_audit",
        "goal": (
            "Bounded test-quality audit. Treat regression protection, assertion "
            "effectiveness, and test realism as the primary decision lenses. "
            "Escalate as blocking when final behavior, CRUD/mutation, backend "
            "contract semantics, required navigation/integration gates, real-backend "
            "coverage, CI execution, or anti-mock/fallback requirements are missing "
            "or invalid. Test organization/readability suggestions are non-blocking "
            "when required behavior coverage is valid."
        ),
    },
)

EXTRA_LANES = {
    "cutover-integrity": {
        "id": "cutover-integrity",
        "review_kind": "cutover_integrity_audit",
        "goal": (
            "Bounded cutover-integrity audit. Determine whether the chosen path is "
            "truly canonical or just a disguised workaround/bridge. Escalate as "
            "blocking when pseudo-canonical fields, silent fallback mirrors, "
            "dual-read/dual-write bridges, or query-time stitching remain as the "
            "effective final architecture without explicit bounded TODO "
            "authorization. If the governing TODO explicitly authorizes a "
            "temporary compatibility construct, challenge scope/removal criteria "
            "instead of blocking its mere existence."
        ),
    },
}

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


def ensure_round_resolution_paths(session: dict) -> None:
    run_root = Path(session["run_root"])
    for round_info in session.get("rounds", []):
        round_info.setdefault(
            "resolution_markdown_path",
            str(run_root / f"round-{round_info['round']:02d}" / "resolution.md"),
        )
        round_info.setdefault(
            "round_package_path",
            str(run_root / f"round-{round_info['round']:02d}" / "round-package.md"),
        )


def default_run_root(package_path: Path, label: str | None) -> Path:
    stem = label or package_path.stem
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return package_path.parent / f"{slugify(stem)}-delivery-audit-{timestamp}"


def selected_lanes(extra_lane_ids: list[str] | None = None) -> list[dict]:
    lanes = [dict(item) for item in BASE_LANES]
    for lane_id in extra_lane_ids or []:
        if lane_id not in EXTRA_LANES:
            raise SystemExit(f"Unsupported extra lane: {lane_id}")
        lanes.append(dict(EXTRA_LANES[lane_id]))
    return lanes


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


def render_round_package(session: dict, round_number: int, base_package_path: Path) -> str:
    base_content = base_package_path.read_text(encoding="utf-8").strip()
    prior_resolutions = []
    for round_info in session.get("rounds", []):
        if int(round_info.get("round", 0)) >= round_number:
            continue
        resolution_status = round_info.get("resolution_status")
        resolution_path = Path(round_info.get("resolution_markdown_path", ""))
        if not resolution_status or not resolution_path.is_file():
            continue
        prior_resolutions.append(
            (
                int(round_info["round"]),
                str(resolution_status),
                str(resolution_path),
                resolution_path.read_text(encoding="utf-8").strip(),
            )
        )

    lines = [
        "# Effective Dedicated Multi-Lane Audit Round Package",
        "",
        "- **Artifact kind:** `dedicated_multi_lane_audit_effective_round_package`",
        "- **Authoritative:** `false`",
        f"- **Round:** `{round_number:02d}`",
        f"- **Base package:** `{base_package_path}`",
        "",
        "This package is generated by the audit session runner. It combines the current bounded package with prior recorded resolution/adjudication artifacts so no-context reviewers do not re-open decisions that were already resolved, explicitly accepted as debt, or blocked.",
        "",
        "## Gate Calibration",
        "",
        "- The close condition is no unresolved blocking finding, not zero findings.",
        "- Performance blockers are concrete severe server/runtime risks such as unbounded scans, request loops where one endpoint/query is required, exact lookup through page walking, high-cardinality in-memory filtering, fetch-all scheduler reconciliation, or resource-exhaustion/security exposure.",
        "- Test-quality blockers are missing or invalid evidence for final behavior, CRUD/mutation, backend semantics, required navigation/integration gates, real-backend coverage, CI execution, or mocks/fallbacks that hide production behavior.",
        "- Cutover-integrity blockers are pseudo-canonical fields, silent fallback mirrors, dual-read/dual-write bridges, or query-time stitching that act as the final architecture without explicit bounded TODO authorization and removal criteria.",
        "- Pure elegance/beautification suggestions without concrete delivery risk should stay in critique/final-review debt, not reopen this dedicated delivery audit by themselves.",
        "",
        "## Current Bounded Package",
        "",
        base_content,
        "",
    ]

    lines.extend(["## Prior Round Resolutions", ""])
    if prior_resolutions:
        for prior_round, status, path_value, content in prior_resolutions:
            lines.extend(
                [
                    f"### Round {prior_round:02d} Resolution",
                    "",
                    f"- **Recorded status:** `{status}`",
                    f"- **Source artifact:** `{path_value}`",
                    "",
                    content,
                    "",
                ]
            )
    else:
        lines.extend(["`none`", ""])

    return "\n".join(lines).rstrip() + "\n"


def prepare_round_package(session: dict, round_number: int, round_root: Path) -> Path:
    base_package_path = Path(session["package_path"])
    if not base_package_path.is_file():
        raise SystemExit(f"Bounded package not found: {base_package_path}")

    round_package_path = round_root / "round-package.md"
    write_text(
        round_package_path,
        render_round_package(session, round_number, base_package_path),
    )

    return round_package_path


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
    ensure_round_resolution_paths(session)
    lines = [
        "# Dedicated Multi-Lane Audit Session Progress",
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
        if round_info.get("resolution_status"):
            lines.append(
                f"- **Resolution:** `{round_info['resolution_status']}` "
                f"at `{round_info.get('resolution_markdown_path')}`"
            )
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
        if round_info.get("round_package_path"):
            lines.append(
                f"- **Effective round package:** `{round_info['round_package_path']}`"
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
    todo_path = Path(session["todo_path"]) if session.get("todo_path") else None
    round_root = run_root / f"round-{round_number:02d}"
    dispatch_root = round_root / "dispatch"
    results_root = round_root / "results"
    merge_root = round_root / "merge"
    round_package_path = prepare_round_package(session, round_number, round_root)

    lanes = []
    for lane in selected_lanes(session.get("extra_lane_ids")):
        dispatch_json_path = dispatch_root / f"{lane['id']}.dispatch.json"
        dispatch_markdown_path = dispatch_root / f"{lane['id']}.dispatch.md"
        result_path = results_root / f"{lane['id']}.result.json"
        merge_json_path = merge_root / f"{lane['id']}.merge.json"
        merge_markdown_path = merge_root / f"{lane['id']}.merge.md"

        run_dispatch(
            package_path=round_package_path,
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
    resolution_markdown_path = round_root / "resolution.md"
    return {
        "round": round_number,
        "status": "prepared",
        "prepared_at": now_utc(),
        "lanes": lanes,
        "summary_json_path": str(summary_json_path),
        "summary_markdown_path": str(summary_markdown_path),
        "resolution_markdown_path": str(resolution_markdown_path),
        "round_package_path": str(round_package_path),
    }


def save_session(session: dict) -> None:
    ensure_round_resolution_paths(session)
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
    ensure_round_resolution_paths(session)
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
        f"# Dedicated Multi-Lane Audit Round Summary: Round {summary['round']:02d}",
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
        "extra_lane_ids": list(dict.fromkeys(args.extra_lane or [])),
        "run_root": str(run_root),
        "current_round": 1,
        "rounds": [],
        "exact_next_step": (
            "Spawn one no-context reviewer per required lane using the current round dispatch "
            "markdown files, then record each JSON result with `record-result`."
        ),
    }
    session["rounds"].append(build_round(session, 1))
    save_session(session)

    print(f"Created dedicated multi-lane audit session: {session_path}")
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
        "Record the remaining reviewer JSON results, or run `merge` once all required "
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
            "Resolve the recorded findings in code/docs/tests, record the resolution "
            "with `record-resolution --status resolved`, then open the next round "
            "with `next-round`."
        ),
        "needs_adjudication": (
            "Prepare a contradiction note, run the follow-up no-context challenge if "
            "needed, adjudicate the conflict explicitly, record the resolution with "
            "`record-resolution --status resolved`, then open the next round."
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


def render_resolution_template(session: dict, round_info: dict) -> str:
    summary_path = Path(round_info["summary_json_path"])
    summary = load_json(summary_path) if summary_path.is_file() else None
    round_label = f"{round_info['round']:02d}"

    lines = [
        f"# Dedicated Multi-Lane Audit Round {round_label} Resolution",
        "",
        "Derived artifact. Non-authoritative. Record Delphi adjudication, resolution decisions, validation evidence, and remaining blockers before opening another audit round.",
        "",
        "## Status",
        "",
        "Choose one when recording with `record-resolution`:",
        "",
        "- `resolved`: all material findings were fixed and required validation passed.",
        "- `accepted-debt`: remaining findings are explicitly accepted as non-blocking debt with owner/rationale.",
        "- `blocked`: required evidence or fixes are still blocked; `next-round` must not proceed.",
        "",
        "## Adjudication",
        "",
        "- Confirm whether lane recommendations conflict materially or are additive.",
        "- If a reviewer re-raised an already accepted finding, cite the prior accepted-debt decision and explain why it remains accepted.",
        "- If a reviewer identified a valid gap, list the finding id and planned resolution.",
        "",
        "## Resolution Matrix",
        "",
        "| Finding | Decision | Resolution / Rationale | Evidence |",
        "| --- | --- | --- | --- |",
    ]

    if summary:
        for lane in summary.get("lanes", {}).values():
            result_path = Path(lane["result_path"])
            if not result_path.is_file():
                continue
            result = load_json(result_path)
            for finding in result.get("findings", []):
                lines.append(
                    f"| `{finding.get('finding_id', 'unknown')}` | `pending` |  |  |"
                )
    else:
        lines.append("| `pending` | `pending` |  |  |")

    lines.extend(
        [
            "",
            "## Validation Evidence",
            "",
            "- Commands run:",
            "- Passed/failed/blocked gates:",
            "- Runtime/navigation evidence:",
            "",
            "## Open Blockers",
            "",
            "- `none` if fully resolved.",
            "",
            "## Accepted Non-Blocking Debt",
            "",
            "- Record any valid but non-blocking performance/test-quality/cutover-integrity findings here with rationale and owner/surface. Residual elegance concerns belong here only when they still matter as explicit accepted debt tied to delivery evidence.",
            "",
            "## Next Audit Package Requirements",
            "",
            "- Include this resolution artifact in the next bounded package.",
            "- Include any accepted-debt decisions so the next no-context reviewers can distinguish unresolved gaps from explicitly accepted risk.",
            "- Do not open the next round while status is `blocked`.",
            "",
        ]
    )
    return "\n".join(lines)


def resolution_template(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    round_info = current_round(session)
    output_path = Path(args.output).resolve() if args.output else Path(
        round_info["resolution_markdown_path"]
    )
    if output_path.exists() and not args.force:
        raise SystemExit(
            f"Resolution template already exists: {output_path}. Use --force to replace it."
        )
    write_text(output_path, render_resolution_template(session, round_info))
    save_session(session)
    print(f"Wrote resolution template: {output_path}")
    return 0


def record_resolution(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    round_info = current_round(session)
    if round_info["status"] != "merged":
        raise SystemExit(
            "Current round has not been merged yet; merge it before recording resolution."
        )
    input_path = Path(args.input).resolve()
    if not input_path.is_file():
        raise SystemExit(f"Resolution markdown not found: {input_path}")
    content = input_path.read_text(encoding="utf-8").strip()
    if not content:
        raise SystemExit("Resolution markdown is empty.")

    output_path = Path(round_info["resolution_markdown_path"])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if input_path != output_path.resolve():
        shutil.copyfile(input_path, output_path)

    round_info["resolution_status"] = args.status
    round_info["resolution_recorded_at"] = now_utc()
    round_info["resolution_markdown_path"] = str(output_path)

    if args.status == "blocked":
        session["exact_next_step"] = (
            "Resolve the recorded blocker and rerun `record-resolution` with "
            "`--status resolved` or `--status accepted-debt` before `next-round`."
        )
    elif args.status == "resolved":
        session["exact_next_step"] = (
            "Update the bounded package with this resolution/adjudication record, "
            "then open the next round with `next-round`."
        )
    else:
        session["exact_next_step"] = (
            "If all remaining findings are non-blocking under the calibrated gate, "
            "record the accepted debt in the delivery evidence and close the audit gate. "
            "Open another round only for a bounded blocker/delta package."
        )
    save_session(session)
    print(
        f"Recorded round {round_info['round']:02d} resolution "
        f"({args.status}) at {output_path}"
    )
    return 0


def ensure_next_round_allowed(session: dict, round_info: dict) -> None:
    round_status = round_info.get("round_status")
    if round_status == "clean":
        return
    if round_status not in {"needs_resolution", "needs_adjudication"}:
        raise SystemExit(
            "Current round has no clean/resolution/adjudication classification; merge it first."
        )
    resolution_path = Path(round_info["resolution_markdown_path"])
    resolution_status = round_info.get("resolution_status")
    if not resolution_status or not resolution_path.is_file():
        raise SystemExit(
            "Current round requires a recorded resolution before next-round. "
            "Run `resolution-template`, fill the adjudication/resolution evidence, "
            "then run `record-resolution --status resolved|accepted-debt|blocked`."
        )
    if resolution_status == "blocked":
        raise SystemExit(
            "Current round resolution is blocked; next-round is forbidden until the "
            "blocker is resolved or explicitly accepted as debt."
        )
    if resolution_status not in {"resolved", "accepted-debt"}:
        raise SystemExit(f"Unsupported resolution status: {resolution_status}")


def next_round(args: argparse.Namespace) -> int:
    session = load_session(Path(args.session).resolve())
    current = current_round(session)
    if current["status"] != "merged":
        raise SystemExit(
            "Current round has not been merged yet; merge it before opening the next round."
        )
    ensure_next_round_allowed(session, current)

    next_round_number = current["round"] + 1
    if args.package:
        package_path = Path(args.package).resolve()
        if not package_path.is_file():
            raise SystemExit(f"Bounded package not found: {package_path}")
        session["package_path"] = str(package_path)

    session["current_round"] = next_round_number
    session["rounds"].append(build_round(session, next_round_number))
    session["exact_next_step"] = (
        "Spawn one no-context reviewer per required lane using the new current-round dispatch "
        "markdown files, then record each JSON result with `record-result`."
    )
    save_session(session)
    print(f"Prepared round {next_round_number:02d}")
    print(f"Progress markdown: {session['progress_markdown_path']}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Manage a deterministic dedicated multi-lane audit session."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    start = subparsers.add_parser("start", help="Create a new dedicated multi-lane audit session.")
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
    start.add_argument(
        "--extra-lane",
        action="append",
        choices=sorted(EXTRA_LANES.keys()),
        help="Optional extra reviewer lane to include in every round.",
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
    next_parser.add_argument(
        "--package",
        help=(
            "Optional refreshed bounded package path for the new round. The runner "
            "generates an effective round package that includes this package plus "
            "prior recorded resolutions."
        ),
    )
    next_parser.set_defaults(func=next_round)

    template = subparsers.add_parser(
        "resolution-template",
        help="Create a round resolution/adjudication markdown template.",
    )
    template.add_argument("--session", required=True, help="Session JSON path.")
    template.add_argument(
        "--output",
        help="Optional output path. Defaults to the current round resolution path.",
    )
    template.add_argument(
        "--force",
        action="store_true",
        help="Overwrite an existing template/resolution file.",
    )
    template.set_defaults(func=resolution_template)

    resolution = subparsers.add_parser(
        "record-resolution",
        help="Record the resolved/accepted/blocked status for the current merged round.",
    )
    resolution.add_argument("--session", required=True, help="Session JSON path.")
    resolution.add_argument(
        "--status",
        required=True,
        choices=RESOLUTION_STATUSES,
        help="Resolution status for the current round.",
    )
    resolution.add_argument(
        "--input",
        required=True,
        help="Filled resolution/adjudication markdown path.",
    )
    resolution.set_defaults(func=record_resolution)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
