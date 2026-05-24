#!/usr/bin/env python3
"""DP frontier from v4/mindmap-frontier.json — which nodes are ready for parallel work?

Usage:
  python3 tools/mindmap-dp.py show      # all nodes by layer
  python3 tools/mindmap-dp.py ready   # status=ready, up to max_parallel
  python3 tools/mindmap-dp.py next    # suggest cc slots W1..W4
"""
from __future__ import annotations
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTIER = ROOT / "v4" / "mindmap-frontier.json"


def load() -> dict:
    return json.loads(FRONTIER.read_text())


def done_ids(data: dict) -> set[str]:
    return {n["id"] for n in data["nodes"] if n["status"] == "done"}


def deps_met(node: dict, done: set[str]) -> bool:
    return all(d in done for d in node.get("deps", []))


def cmd_show(data: dict) -> None:
    for layer in sorted({n["layer"] for n in data["nodes"]}):
        print(f"\n## layer {layer}")
        for n in sorted(data["nodes"], key=lambda x: x["id"]):
            if n["layer"] != layer:
                continue
            dep = ",".join(n.get("deps", [])) or "-"
            print(f"  [{n['status']:7}] {n['id']:22} ring={n['ring']:6} deps={dep}")


def cmd_ready(data: dict) -> None:
    done = done_ids(data)
    ready = []
    for n in data["nodes"]:
        if n["status"] != "ready":
            continue
        if deps_met(n, done):
            ready.append(n)
    cap = int(data.get("max_parallel", 4))
    print(f"ready (max {cap} parallel):")
    for n in ready[:cap]:
        slot = n.get("parallel_slot", "?")
        print(f"  {slot}  {n['id']}  accept: {n.get('accept', [])[0]}")
    if len(ready) > cap:
        print(f"  ... +{len(ready) - cap} more (next round after mindmap update)")


def cmd_next(data: dict) -> None:
    done = done_ids(data)
    ready = [n for n in data["nodes"] if n["status"] == "ready" and deps_met(n, done)]
    cap = int(data.get("max_parallel", 4))
    print("# mindmap-dp next parallel batch")
    print(f"SSOT: {data.get('ssot')}")
    for i, n in enumerate(ready[:cap], 1):
        task = n.get("cc_task", f"tools/mindmap-dp/tasks/{n['id']}.txt")
        print(f"W{i}  {n['id']}")
        print(f"    task: {task}")
        print(f"    accept: {'; '.join(n.get('accept', []))}")


def main() -> None:
    data = load()
    cmd = sys.argv[1] if len(sys.argv) > 1 else "ready"
    if cmd == "show":
        cmd_show(data)
    elif cmd == "ready":
        cmd_ready(data)
    elif cmd == "next":
        cmd_next(data)
    else:
        raise SystemExit("usage: mindmap-dp.py show|ready|next")


if __name__ == "__main__":
    main()
