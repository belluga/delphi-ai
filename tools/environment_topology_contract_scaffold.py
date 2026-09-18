#!/usr/bin/env python3
"""Generate a redacted environment topology contract draft for a downstream repo."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo
from lib.stack_capability_registry import RegistryValidationError, load_registry


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
    lifecycle: str
    evidence_state: str
    evidence: str
    confidence: str
    validation: str


@dataclass
class RepositoryInventory:
    root: Path
    files: tuple[Path, ...]
    manifest_cache: dict[Path, object]
    diagnostics: list[str]
    inventory_builds: int = 1
    manifest_parses: int = 0

    @classmethod
    def build(cls, root: Path) -> "RepositoryInventory":
        return cls(root, tuple(iter_project_files(root, "*", max_depth=5)), {}, [])

    def manifests(self) -> tuple[Path, ...]:
        return tuple(path for path in self.files if path.name == "package.json")

    def diagnostic(self, message: str) -> None:
        if message not in self.diagnostics:
            self.diagnostics.append(message)

    def manifest(self, path: Path) -> object:
        return self.json_object(path, "manifest")

    def composer(self, path: Path) -> object:
        return self.json_object(path, "composer")

    def json_object(self, path: Path, kind: str) -> object:
        if path in self.manifest_cache:
            return self.manifest_cache[path]
        self.manifest_parses += 1
        try:
            if path.is_symlink() or path.stat().st_size > 1_000_000:
                raise ValueError("unsafe or oversized manifest")
            try:
                path.resolve().relative_to(self.root.resolve())
            except ValueError as error:
                raise ValueError("manifest escapes repository root") from error
            value: object = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(value, dict):
                self.diagnostic(
                    f"{kind} ignored: {rel(path, self.root)} (root must be an object)"
                )
                value = None
        except (OSError, ValueError, json.JSONDecodeError):
            self.diagnostic(f"{kind} ignored: {rel(path, self.root)}")
            value = None
        self.manifest_cache[path] = value
        return value


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
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


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


def is_composer_for_stack(
    path: Path,
    data: object,
    composer_requires: tuple[str, ...],
    companion_files: tuple[str, ...],
) -> bool:
    if not isinstance(data, dict):
        return False
    requires = data.get("require")
    if isinstance(requires, dict) and any(
        isinstance(requires.get(package), str) and requires[package].strip()
        for package in composer_requires
    ):
        return True
    return any(
        (path.parent / companion).is_file() and not (path.parent / companion).is_symlink()
        for companion in companion_files
    )


def default_stack_capability_registry() -> Path:
    return Path(__file__).resolve().parents[1] / "config" / "stack_capabilities.yaml"


def detect_stack_evidence(
    root: Path,
    registry_path: Path,
    inventory: RepositoryInventory | None = None,
) -> list[StackEvidence]:
    inventory = inventory or RepositoryInventory.build(root)
    try:
        registry = load_registry(registry_path)
    except RegistryValidationError:
        inventory.diagnostic("stack registry ignored: invalid registry")
        return []
    rows: list[StackEvidence] = []
    for detection in registry.capabilities.values():
        markers = detection.detection_markers
        evidence: set[str] = set()
        for marker in markers.root_files:
            candidate = root / marker
            if candidate.is_file() and not candidate.is_symlink(): evidence.add(marker)
        for marker in markers.nested_files:
            evidence.update(
                rel(candidate, root)
                for candidate in inventory.files
                if (
                    (Path(marker).name == marker and candidate.name == marker)
                    or rel(candidate, root) == marker
                    or ("/" in marker and rel(candidate, root).endswith(f"/{marker}"))
                )
                and not (
                    candidate.name == "composer.json"
                    and (markers.composer_requires or markers.companion_files)
                )
                and candidate.is_file()
                and not candidate.is_symlink()
            )
        for manifest in inventory.manifests():
            data = inventory.manifest(manifest)
            if not isinstance(data, dict): continue
            for section in ("dependencies", "devDependencies", "peerDependencies", "optionalDependencies"):
                values = data.get(section)
                if values is not None and not isinstance(values, dict):
                    inventory.diagnostic(f"manifest ignored section: {rel(manifest, root)}:{section}")
                    continue
                if not isinstance(values, dict):
                    continue
                for package in markers.package_json_requires_any:
                    version = values.get(package)
                    if isinstance(version, str) and version.strip(): evidence.add(f"{rel(manifest, root)} [{section}:{package}]")
        for candidate in inventory.files:
            if candidate.name != "composer.json":
                continue
            if not (markers.composer_requires or markers.companion_files):
                continue
            if is_composer_for_stack(
                candidate,
                inventory.composer(candidate),
                markers.composer_requires,
                markers.companion_files,
            ):
                evidence.add(rel(candidate, root))
        sorted_evidence = sorted(evidence)
        rows.append(
            StackEvidence(
                stack=detection.name,
                lifecycle=detection.lifecycle,
                evidence_state="candidate" if sorted_evidence else "unknown",
                evidence=", ".join(sorted_evidence) if sorted_evidence else f"No {detection.name} registry marker found",
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
    inventory = RepositoryInventory.build(root)
    stack_rows = detect_stack_evidence(root, registry_path, inventory)
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
            table_row(["Stack", "Lifecycle", "Candidate Evidence State", "Evidence", "Confidence", "User Validation"]),
            table_row(["---", "---", "---", "---", "---", "---"]),
        ]
    )
    for row in stack_rows:
        lines.append(table_row([row.stack, row.lifecycle, row.evidence_state, row.evidence, row.confidence, row.validation]))

    if inventory.diagnostics:
        lines.extend(["", "## Detection Diagnostics"])
        lines.extend(f"- {diagnostic}" for diagnostic in inventory.diagnostics)

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
