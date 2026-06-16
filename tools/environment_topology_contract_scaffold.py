#!/usr/bin/env python3
"""Generate a redacted environment topology contract draft for a downstream repo."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo


SECRET_KEY_RE = re.compile(
    r"(^|_)(SECRET|TOKEN|PASSWORD|PASS|PRIVATE|CREDENTIAL|KEY|DB_URI|DATABASE_URL|DSN|AUTH|SESSION|COOKIE)(_|$)",
    re.I,
)
PUBLIC_TOPOLOGY_KEYS = {
    "APP_ENV",
    "APP_URL",
    "COMPOSE_PROFILES",
    "DOMAIN",
    "FRONTEND_URL",
    "NAV_LANDLORD_URL",
    "NAV_TENANT_URL",
    "PUBLIC_URL",
    "TENANT_DOMAIN",
    "TENANT_HOST",
    "TENANT_SUBDOMAIN",
    "WEB_URL",
}
ENV_FILE_NAMES = {".env", ".env.example", ".env.local.example", ".env.testing.example"}
README_NAMES = {"README.md", "README", "docs/README.md"}
COMPOSE_NAMES = (
    "compose.yml",
    "compose.yaml",
    "docker-compose.yml",
    "docker-compose.yaml",
)
KNOWN_RUNNER_PATTERNS = (
    "scripts/delphi",
    "scripts/build_web.sh",
    "scripts/run_",
    "tools/flutter",
    "tools/laravel",
)


@dataclass(frozen=True)
class EnvValue:
    key: str
    value: str
    source: str
    secret_handling: str
    validation: str


@dataclass(frozen=True)
class StackEvidence:
    stack: str
    evidence_state: str
    evidence: str
    confidence: str
    validation: str


@dataclass(frozen=True)
class StackDetection:
    stack: str
    root_files: tuple[str, ...]
    nested_files: tuple[str, ...]
    composer_requires: tuple[str, ...]
    companion_files: tuple[str, ...]


def run_git_root(path: Path) -> Path:
    try:
        result = subprocess.run(
            ["git", "-C", str(path), "rev-parse", "--show-toplevel"],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        return Path(result.stdout.strip()).resolve()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return path.resolve()


def rel(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def strip_yaml_comment(line: str) -> str:
    quote: str | None = None
    for idx, char in enumerate(line):
        if char in {"'", '"'}:
            quote = None if quote == char else char
        elif char == "#" and quote is None:
            return line[:idx]
    return line


def clean_yaml_scalar(value: str) -> str:
    return value.strip().strip('"').strip("'")


def discover_files(root: Path, names: set[str] | tuple[str, ...], max_depth: int = 3) -> list[Path]:
    found: list[Path] = []
    for base, dirs, files in os.walk(root):
        base_path = Path(base)
        depth = len(base_path.relative_to(root).parts)
        if depth > max_depth:
            dirs[:] = []
            continue
        dirs[:] = [d for d in dirs if d not in {".git", "node_modules", "vendor", "build", ".dart_tool"}]
        for file_name in files:
            candidate = base_path / file_name
            candidate_rel = rel(candidate, root)
            if file_name in names or candidate_rel in names:
                found.append(candidate)
    return sorted(found)


def iter_project_files(root: Path, pattern: str, max_depth: int = 5) -> list[Path]:
    found: list[Path] = []
    for base, dirs, files in os.walk(root):
        base_path = Path(base)
        depth = len(base_path.relative_to(root).parts)
        if depth > max_depth:
            dirs[:] = []
            continue
        dirs[:] = [
            d
            for d in dirs
            if d not in {".git", "node_modules", "vendor", "build", ".dart_tool", "coverage", "dist"}
        ]
        for file_name in files:
            if Path(file_name).match(pattern):
                found.append(base_path / file_name)
    return sorted(found)


def parse_gitmodules(root: Path) -> list[tuple[str, str]]:
    gitmodules = root / ".gitmodules"
    if not gitmodules.is_file():
        return []
    entries: dict[str, dict[str, str]] = {}
    current = ""
    for line in read_text(gitmodules).splitlines():
        section = re.match(r'\s*\[submodule "(.+)"\]\s*$', line)
        if section:
            current = section.group(1)
            entries.setdefault(current, {})
            continue
        match = re.match(r"\s*(path|url)\s*=\s*(.+?)\s*$", line)
        if current and match:
            entries.setdefault(current, {})[match.group(1)] = match.group(2)
    rows = []
    for data in entries.values():
        path = data.get("path", "")
        url = data.get("url", "")
        if path:
            rows.append((path, url))
    return sorted(rows)


def redact_env_value(key: str, value: str) -> tuple[str, str]:
    stripped = value.strip().strip('"').strip("'")
    if SECRET_KEY_RE.search(key):
        return ("<redacted>", "redacted")
    if key in PUBLIC_TOPOLOGY_KEYS:
        return (stripped or "<empty>", "plain")
    if re.search(r"https?://|^[A-Za-z0-9.-]+\.[A-Za-z]{2,}(:[0-9]+)?(/.*)?$", stripped):
        return (stripped, "plain")
    if stripped:
        return ("<set>", "redacted")
    return ("<empty>", "not-secret")


def parse_env_files(root: Path) -> list[EnvValue]:
    rows: list[EnvValue] = []
    for env_file in discover_files(root, ENV_FILE_NAMES):
        for line in read_text(env_file).splitlines():
            if not line or line.lstrip().startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", key):
                continue
            rendered, handling = redact_env_value(key, value)
            if key not in PUBLIC_TOPOLOGY_KEYS and handling == "redacted" and rendered == "<set>":
                continue
            rows.append(
                EnvValue(
                    key=key,
                    value=rendered,
                    source=rel(env_file, root),
                    secret_handling=handling,
                    validation="user_validation_required",
                )
            )
    return rows


def is_composer_for_stack(path: Path, composer_requires: tuple[str, ...], companion_files: tuple[str, ...]) -> bool:
    text = read_text(path)
    if any(re.search(rf'"{re.escape(package)}"', text) for package in composer_requires):
        return True
    return any((path.parent / companion).exists() for companion in companion_files)


def default_stack_capability_registry() -> Path:
    return Path(__file__).resolve().parents[1] / "config" / "stack_capabilities.yaml"


def load_stack_detections(registry_path: Path) -> list[StackDetection]:
    if not registry_path.is_file():
        return []

    raw: dict[str, dict[str, list[str]]] = {}
    in_capabilities = False
    current_stack: str | None = None
    in_detection_markers = False
    current_marker: str | None = None

    for raw_line in registry_path.read_text(encoding="utf-8").splitlines():
        line = strip_yaml_comment(raw_line).rstrip()
        if not line.strip():
            continue

        if re.match(r"^capabilities:\s*$", line):
            in_capabilities = True
            current_stack = None
            in_detection_markers = False
            current_marker = None
            continue

        if re.match(r"^[A-Za-z_][A-Za-z0-9_-]*:", line):
            if not re.match(r"^capabilities:\s*$", line):
                in_capabilities = False
            current_stack = None
            in_detection_markers = False
            current_marker = None
            continue

        if not in_capabilities:
            continue

        stack_match = re.match(r"^  ([A-Za-z0-9_-]+):\s*$", line)
        if stack_match:
            current_stack = stack_match.group(1)
            raw.setdefault(current_stack, {})
            in_detection_markers = False
            current_marker = None
            continue

        if not current_stack:
            continue

        field_match = re.match(r"^    ([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if field_match:
            field, value = field_match.groups()
            in_detection_markers = field == "detection_markers"
            current_marker = None
            if in_detection_markers and value and clean_yaml_scalar(value) not in {"", "[]"}:
                raw.setdefault(current_stack, {}).setdefault("_inline", []).append(clean_yaml_scalar(value))
            continue

        if not in_detection_markers:
            continue

        marker_match = re.match(r"^      ([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if marker_match:
            current_marker, value = marker_match.groups()
            raw.setdefault(current_stack, {}).setdefault(current_marker, [])
            if value and clean_yaml_scalar(value) not in {"", "[]"}:
                raw[current_stack][current_marker].append(clean_yaml_scalar(value))
            continue

        item_match = re.match(r"^        -\s+(.+?)\s*$", line)
        if item_match and current_marker:
            raw.setdefault(current_stack, {}).setdefault(current_marker, []).append(clean_yaml_scalar(item_match.group(1)))

    detections: list[StackDetection] = []
    for stack, markers in raw.items():
        detections.append(
            StackDetection(
                stack=stack,
                root_files=tuple(markers.get("root_files", [])),
                nested_files=tuple(markers.get("nested_files", [])),
                composer_requires=tuple(markers.get("composer_requires", [])),
                companion_files=tuple(markers.get("companion_files", [])),
            )
        )
    return detections


def marker_applies(path: Path, detection: StackDetection) -> bool:
    if path.name == "composer.json" and (detection.composer_requires or detection.companion_files):
        return is_composer_for_stack(path, detection.composer_requires, detection.companion_files)
    return True


def detect_stack_evidence(root: Path, registry_path: Path) -> list[StackEvidence]:
    rows: list[StackEvidence] = []
    detections = load_stack_detections(registry_path)

    for detection in detections:
        evidence: set[str] = set()

        for marker in detection.root_files:
            candidate = root / marker
            if candidate.is_file() and marker_applies(candidate, detection):
                evidence.add(marker)

        for marker in detection.nested_files:
            for candidate in iter_project_files(root, marker, max_depth=3):
                if candidate.is_file() and marker_applies(candidate, detection):
                    evidence.add(rel(candidate, root))

        sorted_evidence = sorted(evidence)
        rows.append(
            StackEvidence(
                stack=detection.stack,
                evidence_state="candidate" if sorted_evidence else "unknown",
                evidence=", ".join(sorted_evidence) if sorted_evidence else f"No {detection.stack} registry marker found",
                confidence="high" if sorted_evidence else "low",
                validation="user_validation_required" if sorted_evidence else "n/a",
            )
        )

    return rows


def detect_safe_runners(root: Path) -> list[tuple[str, str, str, str, str]]:
    rows: list[tuple[str, str, str, str, str]] = []
    for path in iter_project_files(root, "*.sh", max_depth=6):
        path_rel = rel(path, root)
        if any(pattern in path_rel for pattern in KNOWN_RUNNER_PATTERNS):
            surface = "web publish" if "build_web" in path.name else "safe runner"
            rows.append((surface, "safe runner", path_rel, "script path exists", "user_validation_required"))
    if not rows:
        rows.append(("backend/client validation", "unknown", "n/a", "No project-owned runner discovered", "user_validation_required"))
    return rows


def detect_compose(root: Path) -> list[tuple[str, str, str, str]]:
    rows: list[tuple[str, str, str, str]] = []
    for compose_file in discover_files(root, COMPOSE_NAMES, max_depth=2):
        text = read_text(compose_file)
        service_block = False
        for line in text.splitlines():
            if re.match(r"^services:\s*$", line):
                service_block = True
                continue
            if service_block:
                service = re.match(r"^\s{2}([A-Za-z0-9_.-]+):\s*$", line)
                if service:
                    rows.append((rel(compose_file, root), f"service:{service.group(1)}", line.strip(), "user_validation_required"))
            if "profiles:" in line:
                rows.append((rel(compose_file, root), "profiles", line.strip(), "user_validation_required"))
    return rows


def readme_hints(root: Path) -> list[str]:
    hints: list[str] = []
    pattern = re.compile(r"(https?://|DOMAIN|TENANT|SUBDOMAIN|COMPOSE_PROFILES|build_web|run_.*safe|cloudflare|cloudflared)", re.I)
    for readme in discover_files(root, README_NAMES, max_depth=2):
        for idx, line in enumerate(read_text(readme).splitlines(), start=1):
            if pattern.search(line):
                hints.append(f"{rel(readme, root)}:{idx}: {line.strip()[:180]}")
            if len(hints) >= 20:
                return hints
    return hints


def foundation_documentation_hints(root: Path) -> list[str]:
    hints: list[str] = []
    foundation = root / "foundation_documentation"
    if not foundation.is_dir():
        return hints
    candidate_files = [
        foundation / "artifacts" / "dependency-readiness.md",
        foundation / "artifacts" / "environment-topology.md",
        foundation / "project_constitution.md",
    ]
    active_todos = sorted((foundation / "todos" / "active").glob("*.md")) if (foundation / "todos" / "active").is_dir() else []
    pattern = re.compile(
        r"(DOMAIN|TENANT|SUBDOMAIN|COMPOSE_PROFILES|NAV_|APP_URL|PUBLIC_URL|WEB_URL|runtime|topology|safe runner|active stack)",
        re.I,
    )
    for doc in [*candidate_files, *active_todos]:
        if not doc.is_file():
            continue
        for idx, line in enumerate(read_text(doc).splitlines(), start=1):
            if pattern.search(line):
                hints.append(f"{rel(doc, root)}:{idx}: {line.strip()[:180]}")
            if len(hints) >= 20:
                return hints
    return hints


def submodule_role(path: str) -> str:
    lowered = path.lower()
    if "foundation" in lowered or "doc" in lowered:
        return "documentation authority"
    if "flutter" in lowered:
        return "client/source app candidate"
    if "laravel" in lowered or "api" in lowered:
        return "backend/source app candidate"
    if "web" in lowered:
        return "derived artifact candidate"
    return "unknown"


def table_row(values: list[str]) -> str:
    escaped = [value.replace("|", "\\|").replace("\n", " ").strip() for value in values]
    return "| " + " | ".join(escaped) + " |"


def render_contract(root: Path, registry_path: Path) -> str:
    now = datetime.now(ZoneInfo("America/Sao_Paulo")).strftime("%Y-%m-%d %H:%M %Z")
    stack_rows = detect_stack_evidence(root, registry_path)
    env_rows = parse_env_files(root)
    runner_rows = detect_safe_runners(root)
    compose_rows = detect_compose(root)
    submodules = parse_gitmodules(root)
    hints = readme_hints(root)
    doc_hints = foundation_documentation_hints(root)

    lines: list[str] = []
    lines.extend(
        [
            "# Environment Topology Contract",
            "",
            "**Draft / User Validation Required**",
            "",
            "## Snapshot",
            "- **Status:** `draft`",
            f"- **Last generated/updated:** `{now}`",
            "- **Generated by:** `delphi-ai/tools/environment_topology_contract_scaffold.py`",
            "- **Review owner:** `user/project owner`",
            "- **Validation summary:** `Generated from available repository evidence; rows marked user_validation_required need confirmation before use as hard targets.`",
            "",
            "## Source Priority",
            "1. User/project-owner validation.",
            "2. Existing `foundation_documentation` contracts, dependency-readiness artifacts, active TODOs, and validation notes when present.",
            "3. `.gitmodules`, README files, compose files, `.env.example`, redacted `.env` values, and project-owned safe runners.",
            "4. Direct user validation for any inferred or ambiguous value.",
            "",
            "This scaffold can surface repository evidence and documentation hints, but it does not mark a stack as active by itself. Do not promote inferred domains, tenants, runtime owners, or stack activation into hard validation targets until the user or project owner confirms them.",
            "",
            "## Active Stack Topology",
            table_row(["Stack", "Activation Evidence State", "Evidence", "Confidence", "User Validation"]),
            table_row(["---", "---", "---", "---", "---"]),
        ]
    )
    for row in stack_rows:
        lines.append(table_row([row.stack, row.evidence_state, row.evidence, row.confidence, row.validation]))

    lines.extend(
        [
            "",
            "## Runtime Owners and Safe Runners",
            table_row(["Surface", "Owner", "Command / Path", "Evidence", "User Validation"]),
            table_row(["---", "---", "---", "---", "---"]),
        ]
    )
    for row in runner_rows:
        lines.append(table_row(list(row)))

    lines.extend(
        [
            "",
            "## Domains, Tenants, and Validation Targets",
            table_row(["Target Kind", "Key / Name", "Value", "Source", "Secret Handling", "User Validation"]),
            table_row(["---", "---", "---", "---", "---", "---"]),
        ]
    )
    if env_rows:
        for item in env_rows:
            target_kind = "compose-profile" if item.key == "COMPOSE_PROFILES" else "env-topology"
            lines.append(table_row([target_kind, item.key, item.value, item.source, item.secret_handling, item.validation]))
    else:
        lines.append(table_row(["unknown", "n/a", "n/a", "No env topology values found", "n/a", "user_validation_required"]))

    lines.extend(
        [
            "",
            "## Compose and Service Hints",
            table_row(["Compose File", "Service/Profile Hint", "Evidence", "User Validation"]),
            table_row(["---", "---", "---", "---"]),
        ]
    )
    if compose_rows:
        for row in compose_rows:
            lines.append(table_row(list(row)))
    else:
        lines.append(table_row(["n/a", "n/a", "No compose files found", "n/a"]))

    lines.extend(
        [
            "",
            "## Submodules and Repositories",
            table_row(["Path", "URL / Remote", "Role Inference", "User Validation"]),
            table_row(["---", "---", "---", "---"]),
        ]
    )
    if submodules:
        for path, url in submodules:
            lines.append(table_row([path, url, submodule_role(path), "user_validation_required"]))
    else:
        lines.append(table_row(["n/a", "n/a", "No .gitmodules entries found", "n/a"]))

    lines.extend(["", "## README / Documentation Hints"])
    combined_hints = [*doc_hints, *hints]
    if combined_hints:
        lines.extend(f"- `{hint}`" for hint in combined_hints)
    else:
        lines.append("- No topology hints found in README surfaces.")

    lines.extend(
        [
            "",
            "## User Validation Checklist",
            "- [ ] Confirm active stacks and inactive available capabilities.",
            "- [ ] Confirm canonical backend/runtime owner and safe runner.",
            "- [ ] Confirm canonical client/web build and publish wrapper.",
            "- [ ] Confirm public validation domains and any preferred tenant/subdomain.",
            "- [ ] Confirm whether any inferred `.env` value should be promoted into docs or kept local-only.",
            "",
            "## Notes",
            "- Real secrets are redacted and must not be copied into this artifact.",
            "- This draft is not automatically authoritative; confirm `user_validation_required` rows before treating them as hard validation targets.",
            "- If a topology value is stable and execution-critical, reference this artifact from `dependency-readiness.md` or the active TODO.",
            "",
        ]
    )
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a redacted environment topology contract draft.")
    parser.add_argument("--repo", default=".", help="Repository/environment root. Defaults to current directory.")
    parser.add_argument(
        "--output",
        default="foundation_documentation/artifacts/environment-topology.md",
        help="Output markdown path relative to repo root unless absolute.",
    )
    parser.add_argument("--stdout", action="store_true", help="Print the generated contract instead of writing it.")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing output file.")
    parser.add_argument(
        "--registry",
        default=str(default_stack_capability_registry()),
        help="Stack capability registry path. Defaults to delphi-ai/config/stack_capabilities.yaml.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = run_git_root(Path(args.repo))
    registry_path = Path(args.registry).resolve()
    content = render_contract(root, registry_path)
    if args.stdout:
        print(content, end="")
        return 0

    output = Path(args.output)
    if not output.is_absolute():
        output = root / output
    if output.exists() and not args.force:
        raise SystemExit(f"Refusing to overwrite existing topology contract without --force: {output}")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")
    print(f"Wrote environment topology contract draft: {output}")
    print("Review rows marked user_validation_required with the user before using them as hard validation targets.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
