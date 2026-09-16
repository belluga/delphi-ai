#!/usr/bin/env python3
"""Validate a live release-package rollup before versioned promotion starts."""

from __future__ import annotations

import argparse
import hashlib
import re
import subprocess
import sys
from pathlib import Path

from github_promotion_source_authority_guard import (
    BASELINES_PARENT_LABEL,
    BRANCH_AUTHORITY_LABELS,
    BRANCH_AUTHORITY_SECTION,
    CHILD_OWNER_SECTION,
    DELIVERY_STATUS_SECTION,
    PROMOTABLE_CHILD_STAGES,
    extract_delivery_stage,
    extract_sections,
    extract_top_level_bullet_field,
    find_section,
    normalize,
    normalize_ref_name,
    parse_baselines,
    parse_child_owner_paths,
    read_lines,
    resolve_foundation_root,
)


RULE_ID = "paced.github-promotion.release-package-rollup"
LIVE_BUCKETS = ("active", "promotion_lane")
RELEASE_PACKAGE_RE = re.compile(r"release-package\.md$")
DECLARED_REPO_ORDER = (
    "root",
    "flutter-app",
    "laravel-app",
    "web-app",
    "foundation_documentation",
)


def git(repo_root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo_root), *args],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(f"git {' '.join(args)} failed: {detail}")
    return result.stdout.strip()


def bulletize(items: list[str], indent: str) -> list[str]:
    if not items:
        return [f"{indent}- none"]
    return [f"{indent}- {item}" for item in items]


def relative_todo_path(path: Path, foundation_root: Path) -> str:
    return path.resolve().relative_to(foundation_root.resolve()).as_posix()


def child_owner_fingerprint(paths: list[str]) -> str:
    digest = hashlib.sha1("\n".join(sorted(paths)).encode("utf-8")).hexdigest()
    return digest[:12]


def extract_version_key(governing_todo: Path, foundation_root: Path) -> tuple[str | None, str | None]:
    try:
        rel = governing_todo.resolve().relative_to(foundation_root.resolve())
    except ValueError:
        return None, None

    parts = rel.parts
    if len(parts) < 4 or parts[0] != "todos":
        return None, None
    lane_bucket = parts[1]
    version_key = parts[2]
    return version_key, lane_bucket


def discover_live_child_owners(foundation_root: Path, version_key: str, governing_todo: Path) -> list[Path]:
    discovered: list[Path] = []
    governing_resolved = governing_todo.resolve()
    for bucket in LIVE_BUCKETS:
        bucket_dir = foundation_root / "todos" / bucket / version_key
        if not bucket_dir.is_dir():
            continue
        for todo_file in sorted(bucket_dir.glob("TODO-*.md")):
            if todo_file.resolve() == governing_resolved:
                continue
            if RELEASE_PACKAGE_RE.search(todo_file.name):
                continue
            discovered.append(todo_file.resolve())
    return discovered


def parse_declared_repos(authority_lines: list[str]) -> tuple[list[str], dict[str, str | None], dict[str, tuple[str, str]]]:
    branch_labels: dict[str, str | None] = {}
    for repo_key, label in BRANCH_AUTHORITY_LABELS.items():
        branch_labels[repo_key] = extract_top_level_bullet_field(authority_lines, label)

    baselines, _ = parse_baselines(authority_lines)
    declared: list[str] = []
    for repo_key in DECLARED_REPO_ORDER:
        if branch_labels.get(repo_key) or normalize(repo_key) in baselines:
            declared.append(repo_key)
    return declared, branch_labels, baselines


def repo_path_for_key(workspace_root: Path, repo_key: str) -> Path | None:
    if repo_key == "root":
        return workspace_root
    if repo_key == "flutter-app":
        return workspace_root / "flutter-app"
    if repo_key == "laravel-app":
        return workspace_root / "laravel-app"
    if repo_key == "foundation_documentation":
        return workspace_root / "foundation_documentation"
    if repo_key == "web-app":
        return workspace_root / "web-app"
    return None


def is_generated_artifact(path: str) -> bool:
    parts = path.split("/")
    return "web-app" in parts or path.startswith("web-app/")


def classify_root_diff_shape(repo_root: Path, base_ref: str, source_ref: str) -> str:
    output = git(repo_root, "diff", "--raw", "--ignore-submodules=none", f"{base_ref}..{source_ref}", "--")
    gitlink_paths: list[str] = []
    normal_paths: list[str] = []

    for line in output.splitlines():
        if not line.strip() or "\t" not in line:
            continue
        meta, path_blob = line.split("\t", 1)
        fields = meta.split()
        if len(fields) < 5:
            continue
        old_mode = fields[0].lstrip(":")
        new_mode = fields[1]
        path = path_blob.split("\t")[-1]
        if old_mode == "160000" or new_mode == "160000":
            gitlink_paths.append(path)
            continue
        if is_generated_artifact(path):
            continue
        normal_paths.append(path)

    if gitlink_paths and normal_paths:
        return "source+gitlinks"
    if gitlink_paths:
        return "gitlink-only"
    if normal_paths:
        return "source-only"
    return "no-diff"


def compute_repo_state(repo_root: Path, repo_key: str, base_ref: str, source_ref: str) -> dict[str, str]:
    source_sha = git(repo_root, "rev-parse", "--verify", f"{source_ref}^{{commit}}")
    base_sha = git(repo_root, "rev-parse", "--verify", f"{base_ref}^{{commit}}")
    stage_ref = "origin/stage"
    stage_ref_available = "yes"
    stage_sha = ""

    try:
        stage_sha = git(repo_root, "rev-parse", "--verify", f"{stage_ref}^{{commit}}")
    except RuntimeError:
        stage_ref_available = "no"

    contains_base = "yes"
    result = subprocess.run(
        ["git", "-C", str(repo_root), "merge-base", "--is-ancestor", base_sha, source_sha],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        contains_base = "no"

    has_diff = "yes"
    result = subprocess.run(
        ["git", "-C", str(repo_root), "diff", "--quiet", "--ignore-submodules=none", f"{base_ref}..{source_ref}", "--"],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode == 0:
        has_diff = "no"

    stage_contains = "unknown"
    stage_has_diff = "unknown"
    pending_stage = "unknown"
    if stage_ref_available == "yes":
        stage_contains = "yes"
        result = subprocess.run(
            ["git", "-C", str(repo_root), "merge-base", "--is-ancestor", stage_sha, source_sha],
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode != 0:
            stage_contains = "no"

        stage_has_diff = "yes"
        result = subprocess.run(
            ["git", "-C", str(repo_root), "diff", "--quiet", "--ignore-submodules=none", f"{stage_ref}..{source_ref}", "--"],
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode == 0:
            stage_has_diff = "no"

        pending_stage = "yes" if stage_has_diff == "yes" else "no"

    state = "promotable"
    detail = "diff-present"
    if has_diff == "no":
        state = "already-absorbed-by-dev"
        detail = "no-promotable-diff"
    elif repo_key == "root":
        detail = classify_root_diff_shape(repo_root, base_ref, source_ref)
        state = detail
    elif contains_base == "no":
        state = "promotable-but-base-missing"
        detail = "diff-present"

    return {
        "repo_key": repo_key,
        "source_ref": source_ref,
        "source_sha": source_sha,
        "base_ref": base_ref,
        "base_sha": base_sha,
        "contains_base": contains_base,
        "has_diff": has_diff,
        "stage_ref_available": stage_ref_available,
        "stage_sha": stage_sha,
        "stage_contains": stage_contains,
        "stage_has_diff": stage_has_diff,
        "pending_stage": pending_stage,
        "state": state,
        "detail": detail,
    }


def recommend_opening_track(repo_states: dict[str, dict[str, str]]) -> str:
    flutter_state = repo_states.get("flutter-app", {}).get("state", "")
    laravel_state = repo_states.get("laravel-app", {}).get("state", "")
    root_state = repo_states.get("root", {}).get("state", "")

    flutter_live = flutter_state in {"promotable", "promotable-but-base-missing"}
    laravel_live = laravel_state in {"promotable", "promotable-but-base-missing"}

    if flutter_live and laravel_live:
        return "flutter-laravel"
    if flutter_live:
        return "flutter-only"
    if laravel_live:
        return "laravel-only"
    if root_state == "gitlink-only":
        return "docker-bot-next-version"
    if root_state == "source+gitlinks":
        return "docker-mixed"
    if root_state == "source-only":
        return "docker-normal"
    return "no-promotable-opening-track"


def opening_primary_surface(opening_track: str) -> str:
    if opening_track.startswith("docker-"):
        return "docker"
    if opening_track == "flutter-only":
        return "flutter"
    if opening_track == "laravel-only":
        return "laravel"
    if opening_track == "flutter-laravel":
        return "flutter+laravel"
    return "unknown"


def opening_docker_diff_shape(opening_track: str) -> str:
    if opening_track == "docker-bot-next-version":
        return "gitlink-only"
    if opening_track == "docker-mixed":
        return "source+gitlinks"
    if opening_track == "docker-normal":
        return "source-only"
    return "n/a"


def build_context_lines(
    *,
    version_key: str,
    lane_bucket: str | None,
    package_stage: str,
    listed_paths: list[str],
    live_paths: list[str],
    live_stage_rows: list[str],
    declared_repos: list[str],
    repo_state_lines: list[str],
    opening_track: str,
    pending_stage_repos: list[str],
) -> list[str]:
    context = [
        f"version_key: {version_key}",
        f"package_lane_bucket: {lane_bucket or 'unknown'}",
        f"package_delivery_stage: {package_stage or 'missing'}",
        f"listed_child_owner_count: {len(listed_paths)}",
        f"live_child_owner_count: {len(live_paths)}",
        f"listed_child_owner_fingerprint: {child_owner_fingerprint(listed_paths)}",
        f"live_child_owner_fingerprint: {child_owner_fingerprint(live_paths)}",
        f"declared_package_repos: {', '.join(declared_repos) if declared_repos else 'none'}",
        f"recommended_opening_track: {opening_track}",
        f"recommended_primary_surface: {opening_primary_surface(opening_track)}",
        f"recommended_docker_diff_shape: {opening_docker_diff_shape(opening_track)}",
        f"pending_stage_repos: {', '.join(pending_stage_repos) if pending_stage_repos else 'none'}",
        "listed_child_owners:",
        *bulletize(listed_paths, "  "),
        "live_child_owners:",
        *bulletize(live_paths, "  "),
        "live_child_owner_stages:",
        *bulletize(live_stage_rows, "  "),
        "package_repo_states:",
        *bulletize(repo_state_lines, "  "),
    ]
    return context


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate that a release-package TODO is fresh against the live version "
            "membership and derive the current opening-track recommendation."
        )
    )
    parser.add_argument(
        "--governing-todo",
        required=True,
        help="Path to the governing release-package TODO.",
    )
    parser.add_argument(
        "--base-ref",
        default="origin/dev",
        help="Authoritative base ref used to derive live repo opening states. Default: origin/dev.",
    )
    parser.add_argument(
        "--workspace-root",
        help=(
            "Optional workspace root that owns root/flutter/laravel sibling repos. "
            "Defaults to the parent directory of foundation_documentation."
        ),
    )
    args = parser.parse_args()

    governing_todo = Path(args.governing_todo).resolve()
    if not governing_todo.is_file():
        print(f"Error: governing TODO not found: {governing_todo}", file=sys.stderr)
        return 1

    foundation_root = resolve_foundation_root(governing_todo)
    if foundation_root is None:
        print("Error: could not resolve foundation_documentation root from governing TODO path", file=sys.stderr)
        return 1

    workspace_root = Path(args.workspace_root).resolve() if args.workspace_root else foundation_root.parent
    if not workspace_root.is_dir():
        print(f"Error: workspace root is not a directory: {workspace_root}", file=sys.stderr)
        return 1
    version_key, lane_bucket = extract_version_key(governing_todo, foundation_root)
    if not version_key:
        print("Error: governing TODO is not inside foundation_documentation/todos/<bucket>/<version>/", file=sys.stderr)
        return 1

    sections = extract_sections(read_lines(governing_todo))
    delivery_lines = find_section(sections, DELIVERY_STATUS_SECTION)
    authority_lines = find_section(sections, BRANCH_AUTHORITY_SECTION)
    child_owner_lines = find_section(sections, CHILD_OWNER_SECTION)
    package_stage = extract_delivery_stage(delivery_lines) or ""

    listed_paths = [
        path
        for path in parse_child_owner_paths(child_owner_lines)
        if not RELEASE_PACKAGE_RE.search(Path(path).name)
    ]

    live_children = discover_live_child_owners(foundation_root, version_key, governing_todo)
    live_paths = [relative_todo_path(path, foundation_root) for path in live_children]

    declared_repos, branch_labels, baselines = parse_declared_repos(authority_lines)
    repo_states: dict[str, dict[str, str]] = {}
    repo_state_lines: list[str] = []
    live_stage_rows: list[str] = []
    pending_stage_repos: list[str] = []
    violations: list[str] = []
    resolutions: list[str] = []

    if not package_stage:
        violations.append("The release package does not declare `Current delivery stage`.")
        resolutions.append("Record the package `Current delivery stage` before using the package as promotion authority.")
    elif package_stage not in PROMOTABLE_CHILD_STAGES:
        violations.append(
            f"The release package delivery stage `{package_stage}` is below the minimum promotable threshold."
        )
        resolutions.append(
            "Advance the release package to `Local-Implemented` or beyond before starting versioned promotion review."
        )

    if not child_owner_lines:
        violations.append(f"The release package does not contain `{CHILD_OWNER_SECTION}`.")
        resolutions.append(
            f"Add `{CHILD_OWNER_SECTION}` so the package freezes the current child-owner set before promotion."
        )
    elif not listed_paths:
        violations.append("The release package lists no child owners.")
        resolutions.append("List every in-scope version child TODO under `Current Diff Child Owners` before promotion.")

    if not live_paths:
        violations.append(
            f"No live child owners were discovered under foundation_documentation/todos/{'{active,promotion_lane}'}/{version_key}/."
        )
        resolutions.append(
            "Place the current version child TODOs under `active/<version>` or `promotion_lane/<version>` before promotion review."
        )

    listed_set = set(listed_paths)
    live_set = set(live_paths)
    missing_from_package = sorted(live_set - listed_set)
    stale_in_package = sorted(listed_set - live_set)

    if missing_from_package:
        violations.append(
            "The live version membership includes child TODOs that are not frozen in the release package: "
            + ", ".join(missing_from_package)
        )
        resolutions.append(
            "Refresh the release package rollup so `Current Diff Child Owners` matches the live version membership exactly."
        )
        resolutions.append(
            "If the new child-owner set is intentional, renew package approval before promotion resumes."
        )

    if stale_in_package:
        violations.append(
            "The release package still lists child TODOs that are not present in the live version directories: "
            + ", ".join(stale_in_package)
        )
        resolutions.append(
            "Remove stale child-owner entries or restore the missing TODOs before promotion resumes."
        )

    for live_child in live_children:
        child_stage = extract_delivery_stage(read_lines(live_child)) or ""
        live_stage_rows.append(f"{relative_todo_path(live_child, foundation_root)} => {child_stage or 'missing'}")
        if not child_stage:
            violations.append(
                f"Live child owner `{relative_todo_path(live_child, foundation_root)}` does not declare `Current delivery stage`."
            )
            continue
        if child_stage not in PROMOTABLE_CHILD_STAGES:
            violations.append(
                f"Live child owner `{relative_todo_path(live_child, foundation_root)}` is still at delivery stage `{child_stage}`, below the minimum promotable threshold."
            )

    if any("Live child owner" in violation and "minimum promotable threshold" in violation for violation in violations):
        resolutions.append(
            "Finish or reroute live child TODOs that are still below `Local-Implemented` before promotion review."
        )

    if not authority_lines:
        violations.append(f"The release package does not contain a `{BRANCH_AUTHORITY_SECTION}` section.")
        resolutions.append(
            "Record the package repo authorities and exact `branch@sha` baselines before promotion review."
        )
    else:
        for repo_key in declared_repos:
            if repo_key in {"web-app", "foundation_documentation"}:
                branch_name = branch_labels.get(repo_key) or (baselines.get(normalize(repo_key)) or ("", ""))[0]
                if repo_key == "web-app":
                    repo_state_lines.append(
                        f"{repo_key} | branch={branch_name or 'missing'} | state=derived-artifact-only | detail=generated-bundle-surface"
                    )
                else:
                    repo_state_lines.append(
                        f"{repo_key} | branch={branch_name or 'missing'} | state=doc-authority | detail=main-only-doc-surface"
                    )
                continue

            branch_name = branch_labels.get(repo_key)
            baseline = baselines.get(normalize(repo_key))
            if not branch_name:
                violations.append(
                    f"`{BRANCH_AUTHORITY_SECTION}` does not declare `{BRANCH_AUTHORITY_LABELS[repo_key]}`."
                )
                resolutions.append(
                    f"Add `{BRANCH_AUTHORITY_LABELS[repo_key]}: <branch>` to the release package before promotion review."
                )
                continue
            if baseline is None:
                violations.append(
                    f"`{BASELINES_PARENT_LABEL}` does not include an entry for repo `{repo_key}`."
                )
                resolutions.append(
                    f"Add a `{repo_key}` `branch@sha` baseline entry to the release package before promotion review."
                )
                continue

            baseline_branch, baseline_sha = baseline
            if normalize_ref_name(baseline_branch) != normalize_ref_name(branch_name):
                violations.append(
                    f"The release package records `{branch_name}` as the authority branch for `{repo_key}`, but its baseline entry uses `{baseline_branch}`."
                )
                resolutions.append(
                    f"Keep `{BRANCH_AUTHORITY_SECTION}` and `{BASELINES_PARENT_LABEL}` synchronized for repo `{repo_key}`."
                )
                continue

            repo_path = repo_path_for_key(workspace_root, repo_key)
            if repo_path is None or not repo_path.exists():
                violations.append(
                    f"Workspace repo path for `{repo_key}` is unavailable at `{repo_path}`."
                )
                resolutions.append(
                    f"Repair the workspace checkout for repo `{repo_key}` before release-package review."
                )
                continue

            try:
                repo_state = compute_repo_state(repo_path, repo_key, args.base_ref, baseline_branch)
            except RuntimeError as exc:
                violations.append(f"Unable to derive live repo state for `{repo_key}`: {exc}")
                resolutions.append(
                    f"Repair local git access for repo `{repo_key}` and rerun the release-package rollup guard."
                )
                continue

            repo_states[repo_key] = repo_state
            if repo_key in {"flutter-app", "laravel-app"} and repo_state.get("pending_stage") == "yes":
                pending_stage_repos.append(repo_key)
            repo_state_lines.append(
                f"{repo_key} | branch={baseline_branch} | baseline_sha={baseline_sha} | state={repo_state['state']} | contains_base={repo_state['contains_base']} | has_diff={repo_state['has_diff']} | pending_stage={repo_state['pending_stage']}"
            )

    opening_track = recommend_opening_track(repo_states)

    if not violations:
        resolutions.append(
            "The release package rollup is fresh against live version membership. Continue with repo-specific authority and source preflight."
        )
    else:
        resolutions.append(
            "Rerun github_release_package_rollup_guard.py and require `Overall outcome: go` before versioned promotion starts."
        )

    print("GitHub Release Package Rollup Guard")
    print(f"Workspace root: {workspace_root}")
    print(f"Foundation root: {foundation_root}")
    print(f"Governing TODO: {governing_todo}")
    print(f"Version key: {version_key}")
    print(f"Base ref: {args.base_ref}")
    print("")
    print("Live rollup summary")
    print(f"  - package delivery stage: {package_stage or 'missing'}")
    print(f"  - listed child owners: {len(listed_paths)}")
    print(f"  - live child owners: {len(live_paths)}")
    print(f"  - membership drift: {'yes' if missing_from_package or stale_in_package else 'no'}")
    print(f"  - declared package repos: {', '.join(declared_repos) if declared_repos else 'none'}")
    print(f"  - recommended opening track: {opening_track}")
    print(f"  - pending stage repos: {', '.join(pending_stage_repos) if pending_stage_repos else 'none'}")
    print("")
    print("TEACH runtime response")
    print(f"status: {'blocked' if violations else 'ready'}")
    print(
        "enforcement: "
        + (
            "stop_before_release_package_promotion_review"
            if violations
            else "allow_release_package_promotion_review"
        )
    )
    print(f"rule_id: {RULE_ID}")
    print("violation:")
    if violations:
        for violation in violations:
            print(f"  - {violation}")
    else:
        print("  - none")
    print("resolution_prompt:")
    for resolution in resolutions:
        print(f"  - {resolution}")
    print("context:")
    for line in build_context_lines(
        version_key=version_key,
        lane_bucket=lane_bucket,
        package_stage=package_stage,
        listed_paths=listed_paths,
        live_paths=live_paths,
        live_stage_rows=live_stage_rows,
        declared_repos=declared_repos,
        repo_state_lines=repo_state_lines,
        opening_track=opening_track,
        pending_stage_repos=pending_stage_repos,
    ):
        print(f"  {line}")
    print("")
    print(f"Overall outcome: {'no-go' if violations else 'go'}")
    return 2 if violations else 0


if __name__ == "__main__":
    raise SystemExit(main())
