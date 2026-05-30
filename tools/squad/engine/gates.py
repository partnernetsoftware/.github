from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from .context import SquadContext


def parse_kv_count(text: str, key: str) -> int | None:
    m = re.search(rf"{re.escape(key)}=(\d+)", text)
    return int(m.group(1)) if m else None


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def check_gate(ctx: SquadContext, gate: dict[str, Any], state: dict[str, Any]) -> dict[str, Any]:
    gid = gate["id"]
    kind = gate.get("check", "manual")
    ok = False
    detail = ""

    if kind == "artifact":
        rel = gate.get("path_glob", "")
        paths = list(ctx.work_root.glob(rel)) if rel else []
        if not paths:
            detail = f"missing {rel}"
        else:
            body = read_text(paths[0])
            if gate.get("plan_must_not_match"):
                if re.search(gate["plan_must_not_match"], body):
                    detail = f"forbidden pattern in {paths[0].name}"
                else:
                    ok = True
            elif gate.get("plan_must_match"):
                ok = bool(re.search(gate["plan_must_match"], body))
                detail = "matched" if ok else f"need {gate['plan_must_match']}"
            else:
                ok = True
                detail = str(paths[0].relative_to(ctx.work_root))

    elif kind == "results":
        fpath = ctx.resolve_path(gate["file"])
        text = read_text(fpath)
        key = gate.get("results_key")
        val = parse_kv_count(text, key) if key else None
        if val is None and gate.get("pattern"):
            m = re.search(gate["pattern"], text)
            if m:
                tail = re.search(r"=(\d+)", m.group(0))
                if tail:
                    val = int(tail.group(1))
        min_pass = gate.get("min_pass", 0)
        ok = val is not None and val >= min_pass
        detail = f"{fpath.name} val={val} need>={min_pass}"

    elif kind == "command":
        # extensibility: run shell, expect exit 0
        import subprocess

        cmd = gate.get("run", "")
        cwd = ctx.resolve_path(gate.get("cwd", "."))
        if not cmd:
            detail = "no command"
        else:
            r = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
            ok = r.returncode == 0
            detail = f"exit={r.returncode}"

    elif kind == "manual":
        ack = state.get("manual_acks", {}).get(gid)
        ok = ack == "pass"
        detail = gate.get("description", "")
        return {"id": gid, "ok": ok, "detail": detail, "manual": True, "ack": ack or "pending"}

    return {"id": gid, "ok": ok, "detail": detail, "manual": False}


def _gate_list(signoff: dict[str, Any], key: str) -> list[dict[str, Any]]:
    raw = signoff.get(key, [])
    return list(raw) if isinstance(raw, list) else []


def run_assess(ctx: SquadContext, state: dict[str, Any]) -> tuple[dict[str, Any], int]:
    signoff = ctx.signoff
    scoped = [check_gate(ctx, g, state) for g in signoff.get("gates", [])]
    terminal = [check_gate(ctx, g, state) for g in _gate_list(signoff, "terminal_gates")]
    auto = scoped + terminal
    manual_defs = signoff.get("manual_gates", [])
    manual = []
    for mg in manual_defs:
        mid = mg["id"]
        ack = state.get("manual_acks", {}).get(mid)
        manual.append({
            "id": mid,
            "ok": ack == "pass",
            "detail": mg.get("description", ""),
            "manual": True,
            "ack": ack or "pending",
        })
    all_auto_ok = all(x["ok"] for x in auto)
    all_manual_ok = all(x["ok"] for x in manual) if manual else True
    auto_done = sum(1 for x in auto if x["ok"])
    pct = int(100 * auto_done / len(auto)) if auto else 0
    cap = signoff.get("percent_cap_until_manual", 92)
    if all_auto_ok and not all_manual_ok:
        pct = min(pct, cap)
    scoped_ok = all(x["ok"] for x in scoped) if scoped else True
    terminal_ok = all(x["ok"] for x in terminal) if terminal else True
    require_terminal = bool(signoff.get("require_terminal")) and bool(terminal)
    ready = scoped_ok and terminal_ok and all_manual_ok
    report = {
        "signoff_id": signoff.get("id"),
        "percent_auto": pct,
        "percent_scoped": int(100 * sum(1 for x in scoped if x["ok"]) / len(scoped)) if scoped else 100,
        "percent_terminal": int(100 * sum(1 for x in terminal if x["ok"]) / len(terminal))
        if terminal
        else 100,
        "ready": ready,
        "scoped_ready": scoped_ok and all_manual_ok,
        "terminal_ready": terminal_ok,
        "require_terminal": require_terminal,
        "auto": auto,
        "scoped": scoped,
        "terminal": terminal,
        "manual": manual,
    }
    state["signoff_percent"] = pct
    state["last_assess"] = report
    return report, 0 if report["ready"] else 1
