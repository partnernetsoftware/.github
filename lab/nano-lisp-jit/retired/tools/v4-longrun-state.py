#!/usr/bin/env python3
"""Longrun SSOT: read/write v4/longrun-state.json and sync LONG-RUN-TODO.md."""
from __future__ import annotations
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / "v4" / "longrun-state.json"
TODO = ROOT / "v4" / "LONG-RUN-TODO.md"


def load() -> dict:
    if STATE.exists():
        return json.loads(STATE.read_text())
    return {"next_wave": 86, "next_add": 81, "last_tests_pass": 0, "status": "idle"}


def save(st: dict) -> None:
    st["updated_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    STATE.write_text(json.dumps(st, indent=2) + "\n")


def sync_todo(st: dict) -> None:
    if not TODO.exists():
        return
    t = TODO.read_text()
    nw, na, tp = st["next_wave"], st["next_add"], st.get("last_tests_pass", 0)
    t = re.sub(r"下一波 \| \*\*\d+\*\*", f"下一波 | **{nw}**", t, count=1)
    t = re.sub(r"下一 add \| \*\*\d+\*\*", f"下一 add | **{na}**", t, count=1)
    t = re.sub(r"tests\.pass=\d+", f"tests.pass={tp}", t, count=1)
    TODO.write_text(t)


def bump(lo: int, hi: int, tests_pass: int) -> dict:
    st = load()
    st["next_wave"] = hi + 1
    st["next_add"] = st.get("next_add", lo - 5 + 17) + (hi - lo + 1)
    st["last_tests_pass"] = tests_pass
    st["last_batch"] = {"lo": lo, "hi": hi}
    st["status"] = "idle"
    save(st)
    sync_todo(st)
    return st


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "show"
    if cmd == "show":
        st = load()
        for k, v in st.items():
            if k != "last_batch":
                print(f"{k}={v}")
            else:
                print(f"batch_lo={v['lo']} batch_hi={v['hi']}")
    elif cmd == "get":
        print(load().get(sys.argv[2], ""))
    elif cmd == "bump":
        st = bump(int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))
        print(json.dumps(st))
    elif cmd == "set-status":
        st = load()
        st["status"] = sys.argv[2]
        save(st)
    elif cmd == "sync":
        sync_todo(load())
    else:
        raise SystemExit(f"unknown cmd {cmd}")


if __name__ == "__main__":
    main()
