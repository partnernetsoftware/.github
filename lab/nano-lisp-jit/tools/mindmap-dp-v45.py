#!/usr/bin/env python3
"""DP frontier for v4.5 onion×mindmap tree — ready nodes for parallel work."""
from __future__ import annotations
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTIER = ROOT / "v4.5" / "mindmap-frontier-v45.json"


def load() -> dict:
    return json.loads(FRONTIER.read_text())


def done_ids(data: dict) -> set[str]:
    return {n["id"] for n in data["nodes"] if n["status"] == "done"}


def deps_met(node: dict, done: set[str]) -> bool:
    return all(d in done for d in node.get("deps", []))


def cmd_ready(data: dict) -> None:
    done = done_ids(data)
    ready = [n for n in data["nodes"] if n["status"] == "ready" and deps_met(n, done)]
    cap = int(data.get("max_parallel", 4))
    print(f"v45-mindmap-dp ready (max {cap}):")
    for n in ready[:cap]:
        print(f"  {n.get('parallel_slot','?')}  {n['id']}  plan={n.get('plan','')}")


def cmd_stats(data: dict) -> None:
    total = len(data["nodes"])
    done = sum(1 for n in data["nodes"] if n["status"] == "done")
    pct = (100 * done // total) if total else 0
    print(f"v45-mindmap-stats nodes={done}/{total} pct={pct}")


def main() -> None:
    data = load()
    cmd = sys.argv[1] if len(sys.argv) > 1 else "ready"
    if cmd == "ready":
        cmd_ready(data)
    elif cmd == "stats":
        cmd_stats(data)
    else:
        raise SystemExit("usage: mindmap-dp-v45.py ready|stats")


if __name__ == "__main__":
    main()
