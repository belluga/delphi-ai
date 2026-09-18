#!/usr/bin/env python3
"""Inventory exact Node capability dependencies and project-owned package scripts."""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


CAPABILITY_DEPENDENCIES = {
    "nestjs": ("@nestjs/core",),
    "prisma": ("@prisma/client", "prisma"),
    "react": ("react-dom",),
    "vite": ("vite",),
}
DEPENDENCY_SECTIONS = (
    "dependencies",
    "devDependencies",
    "peerDependencies",
    "optionalDependencies",
)
IGNORED_DIRECTORIES = {
    ".git",
    ".hg",
    ".svn",
    ".turbo",
    ".next",
    "build",
    "coverage",
    "dist",
    "node_modules",
    "vendor",
}
LOCKFILES = {
    "package-lock.json": "npm",
    "npm-shrinkwrap.json": "npm",
    "pnpm-lock.yaml": "pnpm",
    "yarn.lock": "yarn",
    "bun.lock": "bun",
    "bun.lockb": "bun",
}
MAX_MANIFEST_BYTES = 1024 * 1024


@dataclass(frozen=True)
class Manifest:
    path: Path
    relative_path: str
    dependencies: dict[str, tuple[str, ...]]
    scripts: tuple[str, ...]
    package_manager: str | None
    lockfiles: tuple[str, ...]

    def capabilities(self) -> tuple[str, ...]:
        return tuple(
            capability
            for capability, dependencies in CAPABILITY_DEPENDENCIES.items()
            if any(dependency in self.dependencies for dependency in dependencies)
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Audit exact Node capability dependency evidence and project-owned "
            "package scripts without executing package-manager commands."
        )
    )
    parser.add_argument("--repo", default=".", help="Repository root to inspect.")
    parser.add_argument(
        "--expect",
        action="append",
        choices=sorted(CAPABILITY_DEPENDENCIES),
        required=True,
        help="Capability that must have exact dependency evidence; repeatable.",
    )
    parser.add_argument(
        "--require-script",
        action="append",
        default=[],
        help=(
            "Exact package.json script name required on a matching manifest; repeatable. "
            "Audit one capability at a time when packages require different scripts."
        ),
    )
    parser.add_argument(
        "--manifest",
        action="append",
        default=[],
        help=(
            "Repository-relative owning package.json to audit; repeatable. Required "
            "to disambiguate script checks when several manifests match a capability."
        ),
    )
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="Output format.",
    )
    return parser.parse_args()


def repository_root(value: str) -> Path:
    path = Path(value).expanduser().resolve()
    if not path.is_dir():
        raise ValueError(f"repository is not a directory: {value}")
    return path


def validate_script_names(values: list[str]) -> tuple[str, ...]:
    names: list[str] = []
    seen: set[str] = set()
    for value in values:
        if not value or len(value) > 128 or any(character.isspace() for character in value):
            raise ValueError(f"invalid package script name: {value!r}")
        if value not in seen:
            seen.add(value)
            names.append(value)
    return tuple(names)


def validate_manifest_selectors(values: list[str]) -> tuple[str, ...]:
    selectors: list[str] = []
    seen: set[str] = set()
    for value in values:
        candidate = Path(value)
        if (
            not value
            or candidate.is_absolute()
            or ".." in candidate.parts
            or candidate.name != "package.json"
        ):
            raise ValueError(
                f"invalid --manifest path {value!r}; use a repository-relative package.json"
            )
        normalized = candidate.as_posix()
        if normalized not in seen:
            seen.add(normalized)
            selectors.append(normalized)
    return tuple(selectors)


def manifest_paths(root: Path) -> list[Path]:
    paths: list[Path] = []
    for current, directories, files in os.walk(root, followlinks=False):
        directories[:] = sorted(
            directory
            for directory in directories
            if directory not in IGNORED_DIRECTORIES
            and not (Path(current) / directory).is_symlink()
        )
        if "package.json" in files:
            candidate = Path(current) / "package.json"
            if not candidate.is_symlink():
                paths.append(candidate)
    return sorted(paths, key=lambda path: path.relative_to(root).as_posix())


def dependency_index(data: dict[str, Any]) -> dict[str, tuple[str, ...]]:
    found: dict[str, list[str]] = {}
    for section in DEPENDENCY_SECTIONS:
        dependencies = data.get(section, {})
        if not isinstance(dependencies, dict):
            raise ValueError(f"{section} must be an object")
        for name, version in dependencies.items():
            if isinstance(name, str) and isinstance(version, str):
                found.setdefault(name, []).append(section)
    return {name: tuple(sections) for name, sections in sorted(found.items())}


def script_names(data: dict[str, Any]) -> tuple[str, ...]:
    scripts = data.get("scripts", {})
    if not isinstance(scripts, dict):
        raise ValueError("scripts must be an object")
    return tuple(
        sorted(
            name
            for name, command in scripts.items()
            if isinstance(name, str) and isinstance(command, str) and command.strip()
        )
    )


def local_manager_evidence(path: Path, data: dict[str, Any]) -> tuple[str | None, tuple[str, ...]]:
    declared = data.get("packageManager")
    package_manager = declared.strip() if isinstance(declared, str) and declared.strip() else None
    lockfiles = tuple(
        sorted(name for name in LOCKFILES if (path.parent / name).is_file())
    )
    return package_manager, lockfiles


def load_manifests(root: Path) -> tuple[list[Manifest], list[str]]:
    manifests: list[Manifest] = []
    diagnostics: list[str] = []
    for path in manifest_paths(root):
        relative = path.relative_to(root).as_posix()
        try:
            if path.stat().st_size > MAX_MANIFEST_BYTES:
                raise ValueError(f"exceeds {MAX_MANIFEST_BYTES} bytes")
            data = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(data, dict):
                raise ValueError("root must be an object")
            dependencies = dependency_index(data)
            scripts = script_names(data)
            package_manager, lockfiles = local_manager_evidence(path, data)
        except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as error:
            diagnostics.append(f"invalid manifest {relative}: {error}")
            continue
        manifests.append(
            Manifest(
                path=path,
                relative_path=relative,
                dependencies=dependencies,
                scripts=scripts,
                package_manager=package_manager,
                lockfiles=lockfiles,
            )
        )
    return manifests, diagnostics


def audit(
    root: Path,
    expected: tuple[str, ...],
    required_scripts: tuple[str, ...],
    manifest_selectors: tuple[str, ...],
) -> dict[str, Any]:
    manifests, diagnostics = load_manifests(root)
    blocked: list[str] = list(diagnostics)
    capability_results: dict[str, Any] = {}
    manifests_by_path = {manifest.relative_path: manifest for manifest in manifests}

    if manifest_selectors:
        for selector in manifest_selectors:
            if selector not in manifests_by_path:
                blocked.append(f"selected manifest was not found or valid: {selector}")
        scoped_manifests = [
            manifests_by_path[selector]
            for selector in manifest_selectors
            if selector in manifests_by_path
        ]
    else:
        scoped_manifests = manifests

    for capability in expected:
        dependencies = CAPABILITY_DEPENDENCIES[capability]
        dependency_label = " or ".join(dependencies)
        matching = [
            manifest
            for manifest in scoped_manifests
            if any(dependency in manifest.dependencies for dependency in dependencies)
        ]
        script_failures: list[dict[str, Any]] = []
        if not matching:
            blocked.append(
                f"missing exact dependency evidence for {capability}: {dependency_label}"
            )
        elif required_scripts and len(matching) > 1 and not manifest_selectors:
            blocked.append(
                f"multiple manifests match {capability}; pass --manifest for the owning package.json before checking required scripts"
            )
        else:
            for manifest in matching:
                missing = [
                    script for script in required_scripts if script not in manifest.scripts
                ]
                if missing:
                    script_failures.append(
                        {"manifest": manifest.relative_path, "missing": missing}
                    )
                for script in missing:
                    blocked.append(
                        f"missing required script for {capability} in {manifest.relative_path}: {script}"
                    )
        capability_results[capability] = {
            "dependency": dependency_label,
            "accepted_dependencies": list(dependencies),
            "manifests": [manifest.relative_path for manifest in matching],
            "required_scripts": list(required_scripts),
            "script_failures": script_failures,
        }

    manifest_results = []
    for manifest in manifests:
        manifest_results.append(
            {
                "path": manifest.relative_path,
                "capabilities": list(manifest.capabilities()),
                "dependency_evidence": {
                    dependency: list(sections)
                    for dependency, sections in manifest.dependencies.items()
                    if any(
                        dependency in accepted
                        for accepted in CAPABILITY_DEPENDENCIES.values()
                    )
                },
                "scripts": list(manifest.scripts),
                "package_manager": manifest.package_manager,
                "lockfiles": list(manifest.lockfiles),
            }
        )

    return {
        "repository": str(root),
        "overall_outcome": "blocked" if blocked else "ready",
        "expected": capability_results,
        "selected_manifests": list(manifest_selectors),
        "manifests": manifest_results,
        "diagnostics": blocked,
    }


def print_text(result: dict[str, Any]) -> None:
    print("Node Capability Surface Audit")
    print(f"Repository: {result['repository']}")
    print()
    print("Expected capabilities")
    for capability, details in result["expected"].items():
        manifests = ", ".join(details["manifests"]) or "none"
        print(f"  - {capability}: {details['dependency']} -> {manifests}")
        if details["required_scripts"]:
            required = ", ".join(details["required_scripts"])
            print(f"    required scripts: {required}")
            for failure in details["script_failures"]:
                missing = ", ".join(failure["missing"])
                print(f"    missing in {failure['manifest']}: {missing}")
    print()
    print("Package manifests")
    if not result["manifests"]:
        print("  - none")
    for manifest in result["manifests"]:
        capabilities = ", ".join(manifest["capabilities"]) or "none"
        scripts = ", ".join(manifest["scripts"]) or "none"
        manager = manifest["package_manager"] or "undeclared"
        lockfiles = ", ".join(manifest["lockfiles"]) or "none"
        print(
            f"  - {manifest['path']}: capabilities={capabilities}; "
            f"package_manager={manager}; lockfiles={lockfiles}; scripts={scripts}"
        )
    print()
    print("Diagnostics")
    if not result["diagnostics"]:
        print("  - none")
    else:
        for diagnostic in result["diagnostics"]:
            print(f"  - {diagnostic}")
    print()
    print(f"Overall outcome: {result['overall_outcome']}")


def main() -> int:
    args = parse_args()
    try:
        root = repository_root(args.repo)
        required_scripts = validate_script_names(args.require_script)
        manifest_selectors = validate_manifest_selectors(args.manifest)
    except ValueError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 2

    expected = tuple(dict.fromkeys(args.expect))
    result = audit(root, expected, required_scripts, manifest_selectors)
    if args.format == "json":
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print_text(result)
    return 0 if result["overall_outcome"] == "ready" else 2


if __name__ == "__main__":
    raise SystemExit(main())
