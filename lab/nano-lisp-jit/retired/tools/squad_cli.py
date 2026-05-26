#!/usr/bin/env python3
"""v3.5 squad CLI — 状态机 + 证据，替代 .md 手工派单。

用法:
  python3 squad/squad_cli.py assess [--json]
  python3 squad/squad_cli.py status [--role A|B|R|C]
  python3 squad/squad_cli.py dispatch [--max-tasks 2]
  python3 squad/squad_cli.py claim A L2-companion
  python3 squad/squad_cli.py done A --commit abc1234 --run-pass 250
  python3 squad/squad_cli.py reflect --gate aarch64-real-codegen --status warn --note "..."
  python3 squad/squad_cli.py verify [--quick]
  python3 squad/squad_cli.py sync-md [--targets squad-board,reflection-changelog]
  python3 squad/squad_cli.py role run reviewer|commander|engineer [--role A]
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

LAB = Path(__file__).resolve().parent.parent
SQUAD = Path(__file__).resolve().parent
CATALOG = SQUAD / "catalog.yaml"
STATE_PATH = LAB / ".squad" / "state.json"


def _load_yaml(path: Path) -> dict:
    if yaml is None:
        sys.stderr.write("pip install pyyaml required for squad CLI\n")
        sys.exit(2)
    with path.open(encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_catalog() -> dict:
    return _load_yaml(CATALOG)


def load_state() -> dict:
    if not STATE_PATH.exists():
        return {
            "version": 1,
            "wave": 1,
            "signoff_percent": 0,
            "halt": False,
            "assignments": {"A": None, "B": None, "R": None},
            "tasks": {},
            "findings": [],
            "manual_acks": {},
            "merge_order": ["A", "B", "R"],
            "updated_at": None,
        }
    with STATE_PATH.open(encoding="utf-8") as f:
        return json.load(f)


def save_state(state: dict) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    state["updated_at"] = datetime.now(timezone.utc).isoformat()
    with STATE_PATH.open("w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
        f.write("\n")


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def parse_results_count(text: str, key: str) -> int | None:
    m = re.search(rf"{re.escape(key)}=(\d+)", text)
    return int(m.group(1)) if m else None


def check_gate(gate: dict, state: dict) -> dict:
    gid = gate["id"]
    kind = gate["check"]
    ok = False
    detail = ""

    if kind == "artifact":
        rel = gate.get("path_glob", "")
        paths = list(LAB.glob(rel)) if rel else []
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
                detail = paths[0].name

    elif kind == "results":
        fpath = LAB / gate["file"]
        text = read_text(fpath)
        key = gate.get("results_key")
        if key:
            val = parse_results_count(text, key)
        else:
            pat = gate.get("pattern", "")
            val = None
            m = re.search(pat, text) if pat else None
            if m:
                tail = re.search(r"=(\d+)", m.group(0))
                if tail:
                    val = int(tail.group(1))
        min_pass = gate.get("min_pass", 0)
        ok = val is not None and val >= min_pass
        detail = f"{fpath.name} val={val} need>={min_pass}"

    return {"id": gid, "ok": ok, "detail": detail, "manual": False}


def assess(signoff: dict, state: dict) -> tuple[dict, int]:
    auto = [check_gate(g, state) for g in signoff.get("gates", [])]
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
    if all_auto_ok and not all_manual_ok:
        pct = min(pct, 92)
    report = {
        "signoff_id": signoff.get("id"),
        "percent_auto": pct,
        "ready": all_auto_ok and all_manual_ok,
        "auto": auto,
        "manual": manual,
    }
    state["signoff_percent"] = pct
    state["last_assess"] = report
    save_state(state)
    exit_code = 0 if report["ready"] else 1
    return report, exit_code


def task_status(state: dict, task_id: str) -> str:
    return state.get("tasks", {}).get(task_id, {}).get("status", "pending")


def cmd_assess(args: argparse.Namespace) -> int:
    cat = load_catalog()
    state = load_state()
    report, code = assess(cat["signoff"], state)
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print(f"signoff: {report['signoff_id']}  auto={report['percent_auto']}%  ready={report['ready']}")
        for x in report["auto"]:
            mark = "OK" if x["ok"] else "FAIL"
            print(f"  [{mark}] {x['id']}: {x['detail']}")
        for x in report["manual"]:
            mark = "OK" if x["ok"] else f"ACK:{x['ack']}"
            print(f"  [{mark}] {x['id']}: {x['detail']}")
    return code


def cmd_status(args: argparse.Namespace) -> int:
    state = load_state()
    print(json.dumps(state, indent=2, ensure_ascii=False))
    if args.role:
        t = state.get("assignments", {}).get(args.role)
        print(f"role {args.role}: {t}", file=sys.stderr)
    return 0


def cmd_dispatch(args: argparse.Namespace) -> int:
    cat = load_catalog()
    state = load_state()
    if state.get("halt"):
        print("squad halted", file=sys.stderr)
        return 2
    report, _ = assess(cat["signoff"], state)
    if report["ready"]:
        state["halt"] = True
        save_state(state)
        print("100% — no dispatch")
        return 0
    tasks = cat.get("tasks", {})
    pending = [tid for tid, spec in tasks.items() if task_status(state, tid) == "pending" and spec.get("role") in ("A", "B")]
    max_n = args.max_tasks
    assigned = 0
    for role in ("A", "B"):
        if assigned >= max_n:
            break
        if state["assignments"].get(role):
            continue
        for tid in pending:
            if tasks[tid].get("role") != role:
                continue
            deps = tasks[tid].get("depends", [])
            if any(task_status(state, d) != "done" for d in deps):
                continue
            state["assignments"][role] = tid
            state.setdefault("tasks", {})[tid] = {"status": "assigned", "role": role}
            pending.remove(tid)
            assigned += 1
            print(f"dispatch {role} <- {tid}")
            break
    save_state(state)
    return 0


def cmd_claim(args: argparse.Namespace) -> int:
    state = load_state()
    role, tid = args.role.upper(), args.task_id
    cur = state.get("assignments", {}).get(role)
    if cur and cur != tid:
        print(f"role {role} busy on {cur}", file=sys.stderr)
        return 1
    state["assignments"][role] = tid
    state.setdefault("tasks", {})[tid] = {
        "status": "in_progress",
        "role": role,
        "started_at": datetime.now(timezone.utc).isoformat(),
    }
    save_state(state)
    print(f"claimed {role} {tid}")
    return 0


def cmd_done(args: argparse.Namespace) -> int:
    state = load_state()
    role, tid = args.role.upper(), args.task_id
    if state.get("assignments", {}).get(role) != tid:
        print(f"role {role} not on {tid}", file=sys.stderr)
        return 1
    state.setdefault("tasks", {})[tid] = {
        "status": "done",
        "role": role,
        "commit": args.commit,
        "run_pass": args.run_pass,
        "finished_at": datetime.now(timezone.utc).isoformat(),
    }
    state["assignments"][role] = None
    save_state(state)
    print(f"done {role} {tid}")
    return 0


def cmd_reflect(args: argparse.Namespace) -> int:
    state = load_state()
    if args.gate and args.status in ("pass", "fail", "warn"):
        if args.status == "pass":
            state.setdefault("manual_acks", {})[args.gate] = "pass"
        state.setdefault("findings", []).append({
            "gate": args.gate,
            "status": args.status,
            "note": args.note or "",
            "at": datetime.now(timezone.utc).isoformat(),
        })
    elif args.note:
        state.setdefault("findings", []).append({
            "note": args.note,
            "at": datetime.now(timezone.utc).isoformat(),
        })
    save_state(state)
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    run_sh = LAB / "run.sh"
    root = LAB.parent.parent
    r = subprocess.run(["bash", str(run_sh)], cwd=root, capture_output=True, text=True)
    out = r.stdout + r.stderr
    tail = "\n".join(out.splitlines()[-15:])
    print(tail)
    fail = parse_results_count(out, "tests.fail") or 0
    if fail != 0:
        return 1
    if not args.quick:
        b = subprocess.run(
            ["bash", str(LAB / "build_nano_jit.sh")],
            cwd=root,
            env={**subprocess.os.environ, "NANO_SELFHOST_THOROUGH": "1", "NANO_SLICE_COMPILER": "native"},
            capture_output=True,
            text=True,
        )
        bout = b.stdout + b.stderr
        print("\n".join(bout.splitlines()[-10:]))
        bfail = parse_results_count(bout, "build.fail") or 0
        if bfail != 0:
            return 1
    return 0


def cmd_sync_md(args: argparse.Namespace) -> int:
    state = load_state()
    targets = set((args.targets or "squad-board").split(","))
    if "squad-board" in targets:
        board = _render_squad_board(state, load_catalog())
        squad_md = LAB / "v3.5" / "SQUAD.md"
        text = squad_md.read_text(encoding="utf-8") if squad_md.is_file() else ""
        marker_start = "<!-- SQUAD_STATE_BEGIN -->"
        marker_end = "<!-- SQUAD_STATE_END -->"
        block = f"{marker_start}\n{board}\n{marker_end}"
        if marker_start in text:
            text = re.sub(
                rf"{marker_start}.*?{marker_end}",
                block,
                text,
                count=1,
                flags=re.DOTALL,
            )
        else:
            text = text.rstrip() + "\n\n" + block + "\n"
        squad_md.write_text(text, encoding="utf-8")
        print(f"wrote {squad_md}")
    if "reflection-changelog" in targets:
        line = _render_reflection_line(state)
        ref = LAB / "v3.5" / "REFLECTION.md"
        if ref.is_file() and line:
            body = ref.read_text(encoding="utf-8")
            if line not in body:
                body = body.replace(
                    "## 6. 变更日志\n\n| 日期 | 摘要 |\n|------|------|\n",
                    "## 6. 变更日志\n\n| 日期 | 摘要 |\n|------|------|\n" + line,
                )
                ref.write_text(body, encoding="utf-8")
                print(f"appended changelog to {ref}")
    return 0


def _render_squad_board(state: dict, cat: dict) -> str:
    lines = [
        "### 派单板（state 生成 · 勿手改）",
        "",
        f"- **updated_at**: {state.get('updated_at', '?')}",
        f"- **signoff_auto**: {state.get('signoff_percent', '?')}%",
        f"- **halt**: {state.get('halt', False)}",
        "",
        "| 角色 | 当前任务 | 状态 |",
        "|------|----------|------|",
    ]
    for role in ("A", "B", "R"):
        cur = state.get("assignments", {}).get(role) or "—"
        st = "idle"
        if cur != "—":
            st = state.get("tasks", {}).get(cur, {}).get("status", "?")
        lines.append(f"| {role} | {cur} | {st} |")
    lines.append("")
    lines.append("| task_id | status | commit |")
    lines.append("|---------|--------|--------|")
    for tid, spec in sorted(state.get("tasks", {}).items()):
        lines.append(
            f"| {tid} | {spec.get('status')} | {spec.get('commit', '—')} |"
        )
    pending = [tid for tid in cat.get("tasks", {}) if task_status(state, tid) == "pending"]
    if pending:
        lines.append("")
        lines.append(f"**pending**: {', '.join(pending)}")
    return "\n".join(lines)


def _render_reflection_line(state: dict) -> str:
    la = state.get("last_assess") or {}
    if not la:
        return ""
    day = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    return f"| {day} | squad assess auto={la.get('percent_auto')}% ready={la.get('ready')} |\n"


def cmd_role_run(args: argparse.Namespace) -> int:
    wf = SQUAD / "workflows" / f"{args.workflow}.yaml"
    if not wf.is_file():
        print(f"missing {wf}", file=sys.stderr)
        return 1
    spec = _load_yaml(wf)
    print(f"# {spec.get('name')} ({spec.get('role')})")
    for step in spec.get("steps", []):
        print(f"\n## {step['id']}")
        act = step.get("action")
        if act == "cli" and step.get("cmd"):
            cmd = step["cmd"].replace("<ROLE>", args.role or "A")
            print(f"  $ python3 squad/squad_cli.py {cmd.replace('squad ', '')}")
        elif act == "run":
            print(f"  $ {step.get('cmd', '')[:80]}...")
        else:
            print(f"  action={act} {step.get('note', '')}")
    return 0


def cmd_halt(args: argparse.Namespace) -> int:
    state = load_state()
    state["halt"] = True
    state["halt_reason"] = args.reason
    save_state(state)
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="v3.5 squad CLI")
    sub = p.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("assess", help="评估签收门禁")
    a.add_argument("--json", action="store_true")
    a.set_defaults(func=cmd_assess)

    s = sub.add_parser("status")
    s.add_argument("--role", choices=["A", "B", "R", "C"])
    s.set_defaults(func=cmd_status)

    d = sub.add_parser("dispatch")
    d.add_argument("--max-tasks", type=int, default=2)
    d.set_defaults(func=cmd_dispatch)

    c = sub.add_parser("claim")
    c.add_argument("role", choices=["A", "a", "B", "b"])
    c.add_argument("task_id")
    c.set_defaults(func=cmd_claim)

    dn = sub.add_parser("done")
    dn.add_argument("role", choices=["A", "a", "B", "b"])
    dn.add_argument("task_id")
    dn.add_argument("--commit", required=True)
    dn.add_argument("--run-pass", type=int, default=0)
    dn.set_defaults(func=cmd_done)

    r = sub.add_parser("reflect")
    r.add_argument("--gate")
    r.add_argument("--status", choices=["pass", "fail", "warn"])
    r.add_argument("--note", default="")
    r.set_defaults(func=cmd_reflect)

    v = sub.add_parser("verify", help="跑 run.sh (+ build)")
    v.add_argument("--quick", action="store_true")
    v.set_defaults(func=cmd_verify)

    sy = sub.add_parser("sync-md")
    sy.add_argument("--targets", default="squad-board")
    sy.set_defaults(func=cmd_sync_md)

    rr = sub.add_parser("role")
    rr.add_argument("action", choices=["run"])
    rr.add_argument("workflow", choices=["reviewer", "commander", "engineer"])
    rr.add_argument("--role", choices=["A", "B"])
    rr.set_defaults(func=cmd_role_run)

    h = sub.add_parser("halt")
    h.add_argument("--reason", default="signoff")
    h.set_defaults(func=cmd_halt)

    args = p.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
