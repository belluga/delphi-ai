#!/usr/bin/env python3
"""Classify GitHub stage-promotion scenarios from local git evidence."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


RULE_ID = "paced.github-promotion.scenario-classification"
SCENARIOS = {
    "docker-normal",
    "docker-bot-next-version",
    "docker-mixed",
    "flutter-only",
    "laravel-only",
    "flutter-laravel",
}
REPO_KINDS = {"auto", "docker", "flutter", "laravel", "flutter-laravel"}


@dataclass(frozen=True)
class DiffEntry:
    path: str
    old_mode: str
    new_mode: str
    status: str

    @property
    def is_gitlink(self) -> bool:
        return self.old_mode == "160000" or self.new_mode == "160000"


def die(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def run_git(repo: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        die(f"git {' '.join(args)} failed: {detail}")
    return result.stdout


def repo_root(path: str) -> Path:
    result = subprocess.run(
        ["git", "-C", path, "rev-parse", "--show-toplevel"],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        die(f"path is not inside a git repository: {path}")
    return Path(result.stdout.strip())


def resolve_ref(repo: Path, ref: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo), "rev-parse", "--verify", f"{ref}^{{commit}}"],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        die(f"unable to resolve ref: {ref}")
    return result.stdout.strip()


def normalize_ref(ref: str) -> str:
    for prefix in ("refs/heads/", "refs/remotes/origin/", "origin/"):
        if ref.startswith(prefix):
            return ref[len(prefix) :]
    return ref


def parse_diff_entries(repo: Path, base_ref: str, source_ref: str) -> list[DiffEntry]:
    output = run_git(repo, "diff", "--raw", "--ignore-submodules=none", f"{base_ref}..{source_ref}", "--")
    entries: list[DiffEntry] = []
    for line in output.splitlines():
        if not line.strip() or "\t" not in line:
            continue
        meta, paths = line.split("\t", 1)
        fields = meta.split()
        if len(fields) < 5:
            continue
        old_mode = fields[0].lstrip(":")
        new_mode = fields[1]
        status = fields[4]
        path = paths.split("\t")[-1]
        entries.append(DiffEntry(path=path, old_mode=old_mode, new_mode=new_mode, status=status))
    return entries


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def has_laravel_composer(path: Path) -> bool:
    text = read_text(path)
    return bool(re.search(r'"laravel/(framework|lumen-framework|sanctum|tinker)"', text))


def detect_repo_evidence(repo: Path) -> dict[str, list[str]]:
    evidence: dict[str, list[str]] = {"docker": [], "flutter": [], "laravel": []}

    for marker in ("docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml", "Dockerfile", ".gitmodules"):
        if (repo / marker).exists():
            evidence["docker"].append(marker)

    if (repo / "pubspec.yaml").is_file():
        evidence["flutter"].append("pubspec.yaml")
    for path in repo.glob("*/pubspec.yaml"):
        if path.is_file():
            evidence["flutter"].append(path.relative_to(repo).as_posix())

    if (repo / "artisan").is_file():
        evidence["laravel"].append("artisan")
    if (repo / "composer.json").is_file() and has_laravel_composer(repo / "composer.json"):
        evidence["laravel"].append("composer.json")
    for path in repo.glob("*/artisan"):
        if path.is_file():
            evidence["laravel"].append(path.relative_to(repo).as_posix())
    for path in repo.glob("*/composer.json"):
        if path.is_file() and has_laravel_composer(path):
            evidence["laravel"].append(path.relative_to(repo).as_posix())

    return {key: sorted(set(values)) for key, values in evidence.items()}


def is_generated_artifact(path: str) -> bool:
    parts = path.split("/")
    return "web-app" in parts or path.startswith("web-app/")


def role_for_path(path: str, evidence: dict[str, list[str]]) -> str:
    parts = path.split("/")
    first = parts[0] if parts else path
    name = Path(path).name

    if is_generated_artifact(path):
        return "web-app"
    if first in {"flutter-app", "flutter"} or path == "pubspec.yaml":
        return "flutter"
    if first in {"laravel-app", "laravel"} or path in {"artisan", "composer.json"}:
        return "laravel"
    if name.startswith("Dockerfile") or name in {"docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml", ".gitmodules"}:
        return "docker"
    if first in {"docker", "nginx", "traefik", ".github"}:
        return "docker"
    if evidence["flutter"] and first in {"lib", "test", "integration_test", "android", "ios", "web"}:
        return "flutter"
    if evidence["laravel"] and first in {"app", "routes", "database", "config", "tests", "resources"}:
        return "laravel"
    return "unknown"


def infer_repo_kind(entries: list[DiffEntry], evidence: dict[str, list[str]], override: str) -> str:
    if override != "auto":
        return override
    if any(entry.is_gitlink for entry in entries) or evidence["docker"]:
        return "docker"
    roles = {role_for_path(entry.path, evidence) for entry in entries if not entry.is_gitlink}
    if "flutter" in roles and "laravel" in roles:
        return "flutter-laravel"
    if evidence["flutter"] and evidence["laravel"]:
        return "flutter-laravel"
    if "flutter" in roles or evidence["flutter"]:
        return "flutter"
    if "laravel" in roles or evidence["laravel"]:
        return "laravel"
    return "unknown"


def classify(
    repo_kind: str,
    entries: list[DiffEntry],
    evidence: dict[str, list[str]],
) -> tuple[str | None, dict[str, list[str]], list[str]]:
    gitlink_paths = sorted({entry.path for entry in entries if entry.is_gitlink})
    normal_paths = sorted({entry.path for entry in entries if not entry.is_gitlink and not is_generated_artifact(entry.path)})
    generated_paths = sorted({entry.path for entry in entries if is_generated_artifact(entry.path)})
    roles = sorted({role_for_path(entry.path, evidence) for entry in entries if not entry.is_gitlink})
    violations: list[str] = []

    details = {
        "gitlink_paths": gitlink_paths,
        "normal_paths": normal_paths,
        "generated_artifact_paths": generated_paths,
        "path_roles": roles,
    }

    if generated_paths:
        violations.append("Generated `web-app` artifact paths are present; `web-app` is evidence only and must not be promoted as a source lane.")

    if not entries:
        return None, details, ["No diff exists between base and source refs."]

    if repo_kind == "docker":
        if gitlink_paths and normal_paths:
            return "docker-mixed", details, violations
        if gitlink_paths:
            return "docker-bot-next-version", details, violations
        if normal_paths:
            return "docker-normal", details, violations
        return None, details, violations or ["No authoritative Docker/source diff remains after excluding generated artifacts."]

    if gitlink_paths:
        violations.append("App-source scenarios must not contain gitlink changes.")

    has_flutter = "flutter" in roles or repo_kind in {"flutter", "flutter-laravel"}
    has_laravel = "laravel" in roles or repo_kind in {"laravel", "flutter-laravel"}
    if has_flutter and has_laravel:
        return "flutter-laravel", details, violations
    if has_flutter:
        return "flutter-only", details, violations
    if has_laravel:
        return "laravel-only", details, violations
    return None, details, violations or ["Unable to classify the promotion scenario from stack evidence and changed paths."]


def format_list(values: list[str]) -> str:
    return ", ".join(values) if values else "none"


def emit_teach(
    *,
    blocked: bool,
    violations: list[str],
    resolutions: list[str],
    context: list[str],
) -> int:
    print("TEACH runtime response")
    print(f"status: {'blocked' if blocked else 'ready'}")
    print("enforcement: classify_stage_promotion_scenario")
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
    for line in context:
        print(f"  {line}")
    print(f"\nOverall outcome: {'no-go' if blocked else 'go'}")
    return 2 if blocked else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify a GitHub stage-promotion scenario from local git evidence.")
    parser.add_argument("--repo", default=".", help="repository path to inspect")
    parser.add_argument("--base", required=True, help="authoritative base ref, for example origin/dev")
    parser.add_argument("--source", required=True, help="source ref proposed for promotion")
    parser.add_argument("--repo-kind", choices=sorted(REPO_KINDS), default="auto", help="optional repo kind override")
    parser.add_argument("--expected-scenario", choices=sorted(SCENARIOS), help="optional expected scenario to verify")
    args = parser.parse_args()

    root = repo_root(args.repo)
    base_sha = resolve_ref(root, args.base)
    source_sha = resolve_ref(root, args.source)
    entries = parse_diff_entries(root, args.base, args.source)
    evidence = detect_repo_evidence(root)
    repo_kind = infer_repo_kind(entries, evidence, args.repo_kind)
    scenario, details, violations = classify(repo_kind, entries, evidence)

    normalized_base = normalize_ref(args.base)
    normalized_source = normalize_ref(args.source)
    if normalized_source == "bot/next-version" and normalized_base == "stage":
        violations.append("`bot/next-version` must not be promoted directly to `stage`; use the lane-owned `bot/next-version -> dev` path first.")
    if scenario == "docker-bot-next-version" and normalized_source != "bot/next-version":
        violations.append("A gitlink-only Docker scenario must use the lane-owned `bot/next-version` source ref.")
    if args.expected_scenario and scenario != args.expected_scenario:
        violations.append(f"Expected scenario `{args.expected_scenario}` but classified `{scenario or 'unknown'}`.")

    context = [
        f"repo_root: {root}",
        f"base_ref: {args.base}",
        f"base_sha: {base_sha[:12]}",
        f"source_ref: {args.source}",
        f"source_sha: {source_sha[:12]}",
        f"repo_kind: {repo_kind}",
        f"scenario: {scenario or 'unknown'}",
        f"changed_path_count: {len(entries)}",
        f"gitlink_paths: {format_list(details['gitlink_paths'])}",
        f"normal_paths: {format_list(details['normal_paths'])}",
        f"generated_artifact_paths: {format_list(details['generated_artifact_paths'])}",
        f"path_roles: {format_list(details['path_roles'])}",
        f"docker_evidence: {format_list(evidence['docker'])}",
        f"flutter_evidence: {format_list(evidence['flutter'])}",
        f"laravel_evidence: {format_list(evidence['laravel'])}",
    ]

    if scenario:
        resolutions = [
            f"Record scenario `{scenario}` in the promotion intake before any mutating PR action.",
            "Use the existing promotion contract, source preflight, guarded wrappers, and completion guards after this classification.",
        ]
        if scenario == "docker-mixed":
            resolutions.append("Split Docker normal changes first, then handle gitlink movement through the lane-owned bot path.")
    else:
        resolutions = ["Stop before promotion and provide explicit repo/source evidence or a repo-kind override."]

    if violations:
        resolutions.append("Resolve the listed blocker(s), rerun this classifier, and require `Overall outcome: go` before continuing.")

    return emit_teach(blocked=bool(violations or not scenario), violations=violations, resolutions=resolutions, context=context)


if __name__ == "__main__":
    raise SystemExit(main())
