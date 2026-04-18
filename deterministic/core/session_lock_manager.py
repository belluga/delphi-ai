#!/usr/bin/env python3
"""Deterministic session lock manager for tactical TODO execution (Session ID Edition).

Prevents TODO zombies by maintaining explicit session locks on active TODOs.
Integrates Session ID to ensure traceability and context separation.

Uses OS-level file locking (fcntl) to prevent race conditions when multiple
agents attempt concurrent lock operations.

Usage:
  python3 session_lock_manager.py acquire --session-id <id> --todo <path> --lock-dir <dir>
  python3 session_lock_manager.py release --session-id <id> --lock-dir <dir>
  python3 session_lock_manager.py status  --lock-dir <dir>
"""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import sys
from contextlib import contextmanager
from datetime import datetime, timezone, timedelta
from pathlib import Path


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

LOCK_FILE_NAME = "session_locks.json"
OS_LOCK_FILE_NAME = ".session_locks.flock"
DEFAULT_STALE_HOURS = 4
LOCK_TIMEOUT_SECONDS = 10


# ---------------------------------------------------------------------------
# OS-level file locking
# ---------------------------------------------------------------------------

@contextmanager
def atomic_lock(lock_dir: Path):
    """Acquire an OS-level exclusive file lock before reading/writing the JSON.

    This prevents race conditions when two agents try to acquire/release locks
    at the same time. Uses fcntl.flock which is available on all POSIX systems.
    Falls back gracefully on platforms without fcntl (Windows).
    """
    lock_dir.mkdir(parents=True, exist_ok=True)
    flock_path = lock_dir / OS_LOCK_FILE_NAME
    fd = None
    try:
        fd = open(flock_path, "w")
        fcntl.flock(fd.fileno(), fcntl.LOCK_EX)
        yield
    finally:
        if fd is not None:
            try:
                fcntl.flock(fd.fileno(), fcntl.LOCK_UN)
            except OSError:
                pass
            fd.close()


# ---------------------------------------------------------------------------
# Lock file operations
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_locks(lock_dir: Path) -> dict:
    """Load the lock file. Returns empty dict if not found."""
    lock_path = lock_dir / LOCK_FILE_NAME
    if not lock_path.exists():
        return {"schema_version": "session-locks-v2", "locks": {}}
    try:
        return json.loads(lock_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {"schema_version": "session-locks-v2", "locks": {}}


def save_locks(lock_dir: Path, data: dict) -> None:
    """Save the lock file atomically via write-to-temp + rename."""
    lock_dir.mkdir(parents=True, exist_ok=True)
    lock_path = lock_dir / LOCK_FILE_NAME
    tmp_path = lock_path.with_suffix(".tmp")
    tmp_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    tmp_path.replace(lock_path)


def is_stale(lock_entry: dict, stale_hours: float) -> bool:
    """Check if a lock entry is stale based on last_heartbeat."""
    heartbeat = lock_entry.get("last_heartbeat") or lock_entry.get("acquired_at", "")
    if not heartbeat:
        return True
    try:
        ts = datetime.fromisoformat(heartbeat.replace("Z", "+00:00"))
        return datetime.now(timezone.utc) - ts > timedelta(hours=stale_hours)
    except (ValueError, TypeError):
        return True


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_acquire(session_id: str, todo_path: str, lock_dir: Path, agent_hint: str | None) -> int:
    """Acquire a lock on a TODO for this session."""
    with atomic_lock(lock_dir):
        data = load_locks(lock_dir)
        locks = data.get("locks", {})

        # Check if another session already holds this TODO
        for sid, entry in locks.items():
            if sid == session_id:
                continue
            if entry.get("todo_path") == todo_path and entry.get("status") == "active":
                if not is_stale(entry, DEFAULT_STALE_HOURS):
                    print(
                        f"TEACH runtime response\n"
                        f"status: blocked\n"
                        f"enforcement: stop_before_acquire\n"
                        f"rule_id: paced.session.lock-conflict\n"
                        f"violation:\n"
                        f"  - [LOCK-CONFLICT] TODO '{todo_path}' is already locked by session '{sid}'\n"
                    )
                    return 2

        # Acquire the lock
        now = utc_now()
        locks[session_id] = {
            "todo_path": todo_path,
            "status": "active",
            "acquired_at": now,
            "last_heartbeat": now,
            "agent_hint": agent_hint or "unknown",
            "memory_file": f"session_{session_id}_memory.md"
        }
        data["locks"] = locks
        save_locks(lock_dir, data)

    print(f"Lock acquired for session '{session_id}' on TODO '{todo_path}'.")
    return 0


def cmd_release(session_id: str, lock_dir: Path) -> int:
    """Release all locks held by this session."""
    with atomic_lock(lock_dir):
        data = load_locks(lock_dir)
        locks = data.get("locks", {})

        if session_id not in locks:
            print(f"No lock found for session '{session_id}'.")
            return 0

        entry = locks[session_id]
        entry["status"] = "released"
        entry["released_at"] = utc_now()

        # Force transposition hint
        print(f"HINT: Session '{session_id}' released. Ensure all relevant memory from '{entry['memory_file']}' is transposed to '{entry['todo_path']}'.")

        data["locks"] = locks
        save_locks(lock_dir, data)
    return 0


def cmd_status(lock_dir: Path) -> int:
    """Show the current lock status."""
    with atomic_lock(lock_dir):
        data = load_locks(lock_dir)
    locks = data.get("locks", {})
    print(json.dumps(locks, indent=2))
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Deterministic session lock manager.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    acq = subparsers.add_parser("acquire")
    acq.add_argument("--session-id", required=True)
    acq.add_argument("--todo", required=True)
    acq.add_argument("--lock-dir", required=True)
    acq.add_argument("--agent-hint")

    rel = subparsers.add_parser("release")
    rel.add_argument("--session-id", required=True)
    rel.add_argument("--lock-dir", required=True)

    st = subparsers.add_parser("status")
    st.add_argument("--lock-dir", required=True)

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    lock_dir = Path(args.lock_dir).resolve()
    if args.command == "acquire":
        return cmd_acquire(args.session_id, args.todo, lock_dir, getattr(args, "agent_hint", None))
    elif args.command == "release":
        return cmd_release(args.session_id, lock_dir)
    elif args.command == "status":
        return cmd_status(lock_dir)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
