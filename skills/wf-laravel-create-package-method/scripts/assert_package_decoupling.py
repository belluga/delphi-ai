#!/usr/bin/env python3
"""
Assert Laravel package decoupling invariants.

Checks:
1) No `App\\...` references inside package src/*.php
2) No app wrappers extending package namespace (optional)
3) Host-required contracts (ensureHostBinding) are referenced in AppServiceProvider (optional)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable, List, Tuple


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def php_files(root: Path) -> Iterable[Path]:
    if not root.exists():
        return []
    return sorted(p for p in root.rglob("*.php") if p.is_file())


def parse_namespace(package_dir: Path) -> str:
    composer_path = package_dir / "composer.json"
    if not composer_path.exists():
        raise RuntimeError(f"composer.json not found in package dir: {package_dir}")

    data = json.loads(read_text(composer_path))
    autoload = data.get("autoload", {})
    psr4 = autoload.get("psr-4", {})
    if not psr4:
        raise RuntimeError("composer.json missing autoload.psr-4 namespace")

    namespace = next(iter(psr4.keys()))
    return namespace.rstrip("\\")


def find_app_refs(src_dir: Path) -> List[Tuple[Path, int, str]]:
    findings: List[Tuple[Path, int, str]] = []
    pattern = re.compile(r"\b(?:use\s+)?App\\")

    for file in php_files(src_dir):
        for idx, line in enumerate(read_text(file).splitlines(), start=1):
            if pattern.search(line):
                findings.append((file, idx, line.strip()))

    return findings


def find_wrapper_extends(app_dir: Path, package_namespace: str) -> List[Tuple[Path, int, str]]:
    findings: List[Tuple[Path, int, str]] = []
    escaped = re.escape(package_namespace)
    pattern = re.compile(rf"\bextends\s+\\?{escaped}\\")

    for file in php_files(app_dir):
        for idx, line in enumerate(read_text(file).splitlines(), start=1):
            if pattern.search(line):
                findings.append((file, idx, line.strip()))

    return findings


def find_package_provider(src_dir: Path) -> Path | None:
    providers = sorted(src_dir.glob("*ServiceProvider.php"))
    return providers[0] if providers else None


def parse_host_required_contract_tokens(provider_text: str) -> List[str]:
    return sorted(set(re.findall(r"ensureHostBinding\(\s*([A-Za-z0-9_\\]+)::class\s*\)", provider_text)))


def missing_host_bindings(contract_tokens: List[str], app_provider_text: str) -> List[str]:
    missing = []
    for token in contract_tokens:
        short_name = token.split("\\")[-1]
        if f"{short_name}::class" not in app_provider_text:
            missing.append(token)
    return missing


def print_findings(title: str, findings: List[Tuple[Path, int, str]]) -> None:
    print(f"\n[FAIL] {title}")
    for path, line, text in findings:
        print(f"  - {path}:{line} -> {text}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Assert Laravel package decoupling invariants")
    parser.add_argument("--package-dir", required=True, help="Absolute path to package root")
    parser.add_argument("--app-dir", help="Absolute path to laravel app/ directory for wrapper scan")
    parser.add_argument("--app-provider", help="Absolute path to AppServiceProvider.php")
    parser.add_argument("--check-host-bindings", action="store_true", help="Validate ensureHostBinding contracts are bound in app provider")
    parser.add_argument("--skip-wrapper-check", action="store_true", help="Skip wrapper extends scan in app dir")
    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()

    package_dir = Path(args.package_dir).resolve()
    src_dir = package_dir / "src"
    app_dir = Path(args.app_dir).resolve() if args.app_dir else None
    app_provider = Path(args.app_provider).resolve() if args.app_provider else None

    if not package_dir.exists() or not src_dir.exists():
        print(f"[ERROR] Invalid package dir or missing src/: {package_dir}")
        return 2

    try:
        package_namespace = parse_namespace(package_dir)
    except Exception as exc:
        print(f"[ERROR] {exc}")
        return 2

    failed = False

    if args.verbose:
        print(f"Package: {package_dir}")
        print(f"Namespace: {package_namespace}")

    app_refs = find_app_refs(src_dir)
    if app_refs:
        failed = True
        print_findings("Direct App namespace reference found in package src/", app_refs)
    else:
        print("[OK] No direct App namespace reference in package src/")

    if not args.skip_wrapper_check:
        if not app_dir or not app_dir.exists():
            print("[WARN] Wrapper check skipped (missing --app-dir)")
        else:
            wrappers = find_wrapper_extends(app_dir, package_namespace)
            if wrappers:
                failed = True
                print_findings("Wrapper classes extending package namespace found in app/", wrappers)
            else:
                print("[OK] No wrapper extends from app/ to package namespace")

    if args.check_host_bindings:
        provider = find_package_provider(src_dir)
        if provider is None:
            print("[WARN] No package ServiceProvider found; host binding check skipped")
        elif not app_provider or not app_provider.exists():
            print("[WARN] Host binding check skipped (missing --app-provider)")
        else:
            provider_text = read_text(provider)
            required_tokens = parse_host_required_contract_tokens(provider_text)
            if not required_tokens:
                print("[OK] No ensureHostBinding declarations detected (host binding assertion not required)")
            else:
                app_provider_text = read_text(app_provider)
                missing = missing_host_bindings(required_tokens, app_provider_text)
                if missing:
                    failed = True
                    print("\n[FAIL] Missing host bindings in app provider for required package contracts")
                    for token in missing:
                        print(f"  - {token}")
                else:
                    print("[OK] All host-required contracts are referenced in app provider")

    if failed:
        print("\nResult: FAILED")
        return 1

    print("\nResult: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
