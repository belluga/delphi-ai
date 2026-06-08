#!/usr/bin/env python3
"""Wrapper that exposes the canonical TODO bundle exporter under delphi-ai/tools."""

from __future__ import annotations

from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "deterministic" / "core" / "todo_validation_bundle_export.py"
MODULE_NAME = "_delphi_deterministic_core_todo_validation_bundle_export"

SPEC = spec_from_file_location(MODULE_NAME, MODULE_PATH)
if SPEC is None or SPEC.loader is None:
    raise ImportError(f"Unable to load deterministic core module: {MODULE_PATH}")
MODULE = module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

PUBLIC_NAMES = getattr(MODULE, "__all__", None)
if PUBLIC_NAMES is None:
    PUBLIC_NAMES = [name for name in dir(MODULE) if not name.startswith("_")]
for name in PUBLIC_NAMES:
    globals()[name] = getattr(MODULE, name)
__all__ = list(PUBLIC_NAMES)


if __name__ == "__main__":
    raise SystemExit(MODULE.main())
