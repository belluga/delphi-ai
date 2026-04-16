#!/usr/bin/env python3
"""Deterministic session lock manager for tactical TODO execution.

Prevents TODO zombies by maintaining explicit session locks on active TODOs.
When a session starts, it acquires a lock. When it ends, it releases.
A new session can detect stale locks and recover gracefully.

This tool complements the existing session-lifecycle workflow and
runtime_session_index.py by adding deterministic lock/unlock/recover
semantics instead of relying on prompt-based discipline.

T.E.A.C.H. compliance:
  Triggered  – called at session start (acquire), end (release), or recovery
  Enforced   – prevents two sessions from working the same TODO simultaneously
  Automated  – Python script managing a JSON lock file
  Contextual – emits lock state, stale detection, and recovery evidence
  Hinting    – resolution_prompt guides handoff or recovery

Usage:
  python3 session_lock_manager.py acquire --session-id <id> --todo <path> --lock-dir <dir>
  python3 session_lock_manager.py release --session-id <id> --lock-dir <dir>
  python3 session_lock_manager.py status  --lock-dir <dir>
  python3 session_lock_manager.py recover --session-id <id> --lock-dir <dir> [--stale-hours 4]

Exit codes:
  0  Success
  2  Lock conflict (another active session holds the TODO)
  1  Operational error
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timezone, timedelta
from pathlib import Path


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

LOCK_FILE_NAME = "session_locks.json"
DEFAULT_STALE_HOURS = 4


# ---------------------------------------------------------------------------
# Lock file operations
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_locks(lock_dir: Path) -> dict:
    """Load the lock file. Returns empty dict if not found."""
    lock_path = lock_dir / LOCK_FILE_NAME
    if not lock_path.exists():
        return {"schema_version": "session-locks-v1", "locks": {}}
    try:
        return json.loads(lock_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {"schema_version": "session-locks-v1", "locks": {}}


def save_locks(lock_dir: Path, data: dict) -> None:
    """Save the lock file."""
    lock_dir.mkdir(parents=True, exist_ok=True)
    lock_path = lock_dir / LOCK_FILE_NAME
    lock_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


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
    data = load_locks(lock_dir)
    locks = data.get("locks", {})

    # Check if another session already holds this TODO
    for sid, entry in locks.items():
        if sid == session_id:
            continue
        if entry.get("todo_path") == todo_path and entry.get("status") == "active":
            # Check if it's stale
            if is_stale(entry, DEFAULT_STALE_HOURS):
                print(f"Warning: Session '{sid}' holds '{todo_path}' but is stale "
                      f"(last heartbeat: {entry.get('last_heartbeat', 'unknown')}). "
                      f"Use 'recover' to take over.", file=sys.stderr)
            else:
                print(
                    f"TEACH runtime response\n"
                    f"status: blocked\n"
                    f"enforcement: stop_before_acquire\n"
                    f"rule_id: paced.session.lock-conflict\n"
                    f"violation:\n"
                    f"  - [LOCK-CONFLICT] TODO '{todo_path}' is locked by session '{sid}' "
                    f"(acquired: {entry.get('acquired_at', 'unknown')})\n"
                    f"resolution_prompt:\n"
                    f"  - Wait for session '{sid}' to release, or use 'recover' if the session is dead.\n"
                    f"  - python3 session_lock_manager.py recover --session-id {session_id} --lock-dir {lock_dir}\n"
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
    }
    data["locks"] = locks
    save_locks(lock_dir, data)

    print(
        f"Lock acquired\n"
        f"  session_id: {session_id}\n"
        f"  todo_path: {todo_path}\n"
        f"  acquired_at: {now}\n"
        f"  status: active\n"
    )
    return 0


def cmd_release(session_id: str, lock_dir: Path) -> int:
    """Release all locks held by this session."""
    data = load_locks(lock_dir)
    locks = data.get("locks", {})

    if session_id not in locks:
        print(f"No lock found for session '{session_id}'.")
        return 0

    entry = locks[session_id]
    entry["status"] = "released"
    entry["released_at"] = utc_now()
    data["locks"] = locks
    save_locks(lock_dir, data)

    print(
        f"Lock released\n"
        f"  session_id: {session_id}\n"
        f"  todo_path: {entry.get('todo_path', 'unknown')}\n"
        f"  released_at: {entry['released_at']}\n"
    )
    return 0


def cmd_heartbeat(session_id: str, lock_dir: Path) -> int:
    """Update the heartbeat timestamp for a session's lock."""
    data = load_locks(lock_dir)
    locks = data.get("locks", {})

    if session_id not in locks or locks[session_id].get("status") != "active":
        print(f"No active lock found for session '{session_id}'.", file=sys.stderr)
        return 1

    now = utc_now()
    locks[session_id]["last_heartbeat"] = now
    data["locks"] = locks
    save_locks(lock_dir, data)

    print(f"Heartbeat updated: {session_id} at {now}")
    return 0


def cmd_status(lock_dir: Path, stale_hours: float) -> int:
    """Show the current lock status."""
    data = load_locks(lock_dir)
    locks = data.get("locks", {})

    if not locks:
        print("No session locks found.")
        return 0

    print("Session Lock Status")
    print(f"  Lock file: {lock_dir / LOCK_FILE_NAME}")
    print(f"  Total entries: {len(locks)}")
    print()

    active_count = 0
    stale_count = 0
    released_count = 0

    for sid, entry in sorted(locks.items()):
        status = entry.get("status", "unknown")
        stale_flag = ""
        if status == "active":
            active_count += 1
            if is_stale(entry, stale_hours):
                stale_count += 1
                stale_flag = " [STALE]"
        elif status == "released":
            released_count += 1

        print(f"  {sid}: {status}{stale_flag}")
        print(f"    todo: {entry.get('todo_path', 'unknown')}")
        print(f"    acquired: {entry.get('acquired_at', 'unknown')}")
        print(f"    heartbeat: {entry.get('last_heartbeat', 'unknown')}")
        if entry.get("released_at"):
            print(f"    released: {entry['released_at']}")
        print()

    print(f"Summary: {active_count} active, {stale_count} stale, {released_count} released")

    if stale_count > 0:
        print(
            f"\nTEACH hint: {stale_count} stale lock(s) detected. "
            f"Use 'recover' to take over stale sessions."
        )

    return 0


def cmd_recover(session_id: str, lock_dir: Path, stale_hours: float) -> int:
    """Recover stale locks by marking them as recovered and optionally re-acquiring."""
    data = load_locks(lock_dir)
    locks = data.get("locks", {})

    now = utc_now()
    recovered: list[str] = []
    todo_paths: list[str] = []

    for sid, entry in list(locks.items()):
        if sid == session_id:
            continue
        if entry.get("status") != "active":
            continue
        if is_stale(entry, stale_hours):
            entry["status"] = "recovered"
            entry["recovered_at"] = now
            entry["recovered_by"] = session_id
            recovered.append(sid)
            todo_paths.append(entry.get("todo_path", "unknown"))

    if not recovered:
        print("No stale locks found to recover.")
        return 0

    data["locks"] = locks
    save_locks(lock_dir, data)

    print(f"Recovered {len(recovered)} stale session(s):")
    for sid, tp in zip(recovered, todo_paths):
        print(f"  - {sid}: {tp}")
    print()
    print("TEACH hint:")
    print(f"  - Review the TODO(s) above for incomplete work.")
    print(f"  - Use 'acquire' to lock the TODO you want to resume.")
    print(f"  - Check the session-memory.md and runtime-index for context.")

    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Deterministic session lock manager for tactical TODO execution."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # acquire
    acq = subparsers.add_parser("acquire", help="Acquire a lock on a TODO")
    acq.add_argument("--session-id", required=True, help="Unique session identifier")
    acq.add_argument("--todo", required=True, help="Path to the TODO being worked on")
    acq.add_argument("--lock-dir", required=True, help="Directory for the lock file")
    acq.add_argument("--agent-hint", help="Optional agent/profile hint")

    # release
    rel = subparsers.add_parser("release", help="Release locks for a session")
    rel.add_argument("--session-id", required=True, help="Session to release")
    rel.add_argument("--lock-dir", required=True, help="Directory for the lock file")

    # heartbeat
    hb = subparsers.add_parser("heartbeat", help="Update session heartbeat")
    hb.add_argument("--session-id", required=True, help="Session to heartbeat")
    hb.add_argument("--lock-dir", required=True, help="Directory for the lock file")

    # status
    st = subparsers.add_parser("status", help="Show lock status")
    st.add_argument("--lock-dir", required=True, help="Directory for the lock file")
    st.add_argument("--stale-hours", type=float, default=DEFAULT_STALE_HOURS,
                     help=f"Hours after which a lock is considered stale (default: {DEFAULT_STALE_HOURS})")

    # recover
    rec = subparsers.add_parser("recover", help="Recover stale locks")
    rec.add_argument("--session-id", required=True, help="New session taking over")
    rec.add_argument("--lock-dir", required=True, help="Directory for the lock file")
    rec.add_argument("--stale-hours", type=float, default=DEFAULT_STALE_HOURS,
                      help=f"Hours after which a lock is considered stale (default: {DEFAULT_STALE_HOURS})")

    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.command == "acquire":
        return cmd_acquire(
            args.session_id,
            args.todo,
            Path(args.lock_dir).resolve(),
            getattr(args, "agent_hint", None),
        )
    elif args.command == "release":
        return cmd_release(args.session_id, Path(args.lock_dir).resolve())
    elif args.command == "heartbeat":
        return cmd_heartbeat(args.session_id, Path(args.lock_dir).resolve())
    elif args.command == "status":
        return cmd_status(Path(args.lock_dir).resolve(), args.stale_hours)
    elif args.command == "recover":
        return cmd_recover(
            args.session_id,
            Path(args.lock_dir).resolve(),
            args.stale_hours,
        )
    else:
        print(f"Unknown command: {args.command}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
