#!/usr/bin/env python3
"""Wrapper that exposes the canonical gate-finding extractor under delphi-ai/tools."""

from __future__ import annotations

import sys
from pathlib import Path


DETERMINISTIC_CORE_ROOT = Path(__file__).resolve().parents[1] / "deterministic" / "core"
if str(DETERMINISTIC_CORE_ROOT) not in sys.path:
    sys.path.insert(0, str(DETERMINISTIC_CORE_ROOT))

from gate_finding_resolution_extract import *  # type: ignore  # noqa: F401,F403


if __name__ == "__main__":
    from gate_finding_resolution_extract import main

    raise SystemExit(main())
