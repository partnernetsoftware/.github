from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .context import SquadContext, _load_yaml
from .db import SquadLockError, SquadStore
from .gates import run_assess
from .state import empty_state, get_store, load_state, save_state, task_status
from .lockfile import flock
from .supervisor import (
    OUTCOME_COMPLETE,
    OUTCOME_FAILED,
    OUTCOME_TIMEOUT,
    member_tick,
    run_member_loop,
    run_supervise,
    spawn_agent_team,
    supervise_tick,
    team_mode,
    worker_tick,
)


def cmd_assess(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    state = store.load_snapshot()
    report, code = run_assess(ctx, state)
    store.set_meta("signoff_percent", report["percent_auto"])
    store.set_meta("last_assess", report)
    if report["ready"] and not team_mode(ctx):
        store.set_meta("halt", True)
    store.export_json()
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        tr = report.get("terminal_ready", report["ready"])
        print(
            f"signoff: {report['signoff_id']}  scoped={report.get('percent_scoped', report['percent_auto'])}% "
            f"terminal={report.get('percent_terminal', '?')}%  ready={report['ready']} "
            f"(scoped_ready={report.get('scoped_ready')} terminal_ready={tr})"
        )
        print(f"state.db: {ctx.db_path}")
        for x in report["auto"]:
            mark = "OK" if x["ok"] else "FAIL"
            print(f"  [{mark}] {x['id']}: {x['detail']}")
        for x in report["manual"]:
            mark = "OK" if x["ok"] else f"ACK:{x['ack']}"
            print(f"  [{mark}] {x['id']}: {x['detail']}")
    return code


def cmd_status(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    state = store.load_snapshot()
    if args.json:
        print(json.dumps(state, indent=2, ensure_ascii=False))
    else:
        print(f"project: {ctx.work_root}")
        print(f"catalog: {ctx.catalog_path}")
        print(f"state.db: {ctx.db_path}")
        print(f"lock: {ctx.lock_backend} (WAL + busy_timeout + backoff)")
        for rid in ctx.all_role_ids():
            cur = state.get("assignments", {}).get(rid)
            print(f"  {rid}: {cur or 'idle'}")
    if args.role and args.role not in state.get("assignments", {}):
        print(f"unknown role: {args.role}", file=sys.stderr)
        return 1
    return 0


def _pending_tasks(ctx: SquadContext, store: SquadStore, roles: set[str]) -> list[str]:
    out: list[str] = []
    for tid in ctx.tasks:
        role = ctx.task_assign_role(tid)
        if role not in roles:
            continue
        if store.task_status(tid) != "pending":
            continue
        deps = ctx.tasks[tid].get("depends", [])
        if any(store.task_status(d) != "done" for d in deps):
            continue
        out.append(tid)
    return out


def cmd_dispatch(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    state = store.load_snapshot()
    if state.get("halt") and not getattr(args, "force", False):
        print("squad halted (use: squad resume && squad dispatch --force)", file=sys.stderr)
        return 2
    report, _ = run_assess(ctx, state)
    store.set_meta("last_assess", report)
    store.set_meta("signoff_percent", report["percent_auto"])
    workers = set(ctx.worker_roles())
    meta_roles = {rid for rid, spec in ctx.roles.items() if spec.get("kind") in ("meta", "orchestrator")}
    include_meta = getattr(args, "include_meta", False)
    roles_to_fill = set(workers)
    if include_meta:
        roles_to_fill |= meta_roles

    meta_pending = _pending_tasks(ctx, store, meta_roles)
    worker_pending = _pending_tasks(ctx, store, workers)
    if report["ready"] and not worker_pending and not (include_meta and meta_pending):
        store.set_meta("halt", True)
        store.export_json()
        print("100% — no dispatch")
        return 0
    if report["ready"] and worker_pending:
        print("signoff ready but worker tasks pending — dispatch continues", file=sys.stderr)

    max_n = args.max_tasks or ctx.dispatch_cfg.get("max_per_wave", len(workers))
    if include_meta:
        max_n = args.max_tasks or max(max_n, len(meta_roles))
    assigned = 0
    pending = _pending_tasks(ctx, store, roles_to_fill)
    for role in sorted(roles_to_fill, key=lambda r: (r not in workers, r)):
        if assigned >= max_n and role in workers:
            break
        busy = state.get("assignments", {}).get(role)
        if busy:
            continue
        for tid in list(pending):
            if ctx.task_assign_role(tid) != role:
                continue
            if store.dispatch_assign(role, tid):
                pending.remove(tid)
                assigned += 1
                store.set_signal(role, "running", task_id=tid, reason="dispatched")
                print(f"dispatch {role} <- {tid}")
                break
    store.export_json()
    return 0


def cmd_resume(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    store.set_meta("halt", False)
    store.set_meta("halt_reason", None)
    store.set_meta("supervisor_outcome", None)
    wave = int(store.get_meta("wave", 1) or 1) + 1
    store.set_meta("wave", wave)
    store.set_signal("supervisor", "running", reason=args.reason or "resume")
    for rid in ctx.all_role_ids():
        if rid != "commander":
            store.set_signal(rid, "running", reason="wave_open")
    store.export_json()
    print(f"resumed wave={wave} leader=running")
    return 0


def cmd_claim(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    role, tid = args.role, args.task_id
    if role not in ctx.all_role_ids():
        print(f"unknown role {role}; catalog: {', '.join(ctx.all_role_ids())}", file=sys.stderr)
        return 1
    spec = ctx.tasks.get(tid) or {}
    touch = list(spec.get("touch_paths") or [])
    try:
        store.claim(role, tid, touch)
    except SquadLockError as e:
        print(str(e), file=sys.stderr)
        return 1
    store.export_json()
    print(f"claimed {role} {tid}")
    return 0


def cmd_done(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    role, tid = args.role, args.task_id
    spec = ctx.tasks.get(tid) or {}
    touch = list(spec.get("touch_paths") or [])
    try:
        store.release_done(role, tid, args.commit, touch)
    except SquadLockError as e:
        print(str(e), file=sys.stderr)
        return 1
    store.export_json()
    print(f"done {role} {tid}")
    return 0


def cmd_reflect(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    if args.gate and args.status in ("pass", "fail", "warn"):
        if args.status == "pass":
            store.set_manual_ack(args.gate, "pass")
        store.add_finding({
            "gate": args.gate,
            "status": args.status,
            "note": args.note or "",
            "at": datetime.now(timezone.utc).isoformat(),
        })
    elif args.note:
        store.add_finding({
            "note": args.note,
            "at": datetime.now(timezone.utc).isoformat(),
        })
    store.export_json()
    return 0


def cmd_verify(ctx: SquadContext, args: argparse.Namespace) -> int:
    cfg = ctx.verify_cfg
    steps = cfg.get("commands") if isinstance(cfg, dict) else None
    if not steps:
        print("no verify.commands in catalog", file=sys.stderr)
        return 2
    lock_path = ctx.work_root / ".squad" / "verify.lock"
    with flock(lock_path):
        return _run_verify_steps(ctx, args, steps)


def _run_verify_steps(ctx: SquadContext, args: argparse.Namespace, steps: list) -> int:
    for step in steps:
        if args.quick and step.get("optional"):
            continue
        script = step.get("script") or step.get("run")
        if not script:
            continue
        cwd = ctx.resolve_path(step.get("cwd", "."))
        env = {**subprocess.os.environ, **(step.get("env") or {})}
        r = subprocess.run(
            ["bash", str(ctx.resolve_path(script))],
            cwd=cwd,
            capture_output=True,
            text=True,
            env=env,
        )
        out = r.stdout + r.stderr
        print("\n".join(out.splitlines()[-12:]))
        expect = step.get("expect", {})
        if "exit" in expect and r.returncode != expect["exit"]:
            return 1
        if step.get("fail_on_nonzero") and r.returncode != 0:
            return 1
    return 0


def _render_board(ctx: SquadContext, state: dict[str, Any]) -> str:
    lines = [
        "### 派单板（SQLite state 导出 · 勿手改）",
        "",
        f"- **project**: `{ctx.work_root}`",
        f"- **state.db**: `{ctx.db_path}`",
        f"- **signoff_id**: `{ctx.signoff.get('id', '?')}`",
        f"- **updated_at**: {state.get('updated_at', '?')}",
        f"- **signoff_auto**: {state.get('signoff_percent', '?')}%",
        f"- **halt**: {state.get('halt', False)}",
        "",
        "| role | task | status |",
        "|------|------|--------|",
    ]
    for rid in ctx.all_role_ids():
        cur = state.get("assignments", {}).get(rid) or "—"
        st = "idle"
        if cur != "—":
            st = state.get("tasks", {}).get(cur, {}).get("status", "?")
        lines.append(f"| {rid} | {cur} | {st} |")
    lines.extend(["", "| task_id | status | commit |", "|---------|--------|--------|"])
    for tid, spec in sorted(state.get("tasks", {}).items()):
        lines.append(f"| {tid} | {spec.get('status')} | {spec.get('commit', '—')} |")
    pending = [
        tid for tid in ctx.tasks
        if task_status(ctx, state, tid) == "pending"
    ]
    if pending:
        lines.append("")
        lines.append(f"**pending**: {', '.join(pending)}")
    locks = state.get("locks") or {}
    if locks:
        lines.append("")
        lines.append("**path_locks**:")
        for p, holder in sorted(locks.items()):
            lines.append(f"- `{p}` → {holder}")
    return "\n".join(lines)


def cmd_sync_md(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    state = store.load_snapshot()
    targets = args.targets.split(",") if args.targets else list((ctx.sync_cfg or {}).keys())
    sync = ctx.sync_cfg or {}
    for name in targets:
        name = name.strip()
        spec = sync.get(name)
        if not spec:
            if name == "squad-board" and sync.get("board"):
                spec = sync["board"]
            elif name == "reflection-changelog" and sync.get("reflection"):
                spec = sync["reflection"]
            else:
                print(f"skip unknown sync target: {name}", file=sys.stderr)
                continue
        if spec.get("template") == "board" or name == "board":
            board = _render_board(ctx, state)
            fpath = ctx.resolve_path(spec["file"])
            begin = spec.get("begin", "<!-- SQUAD_STATE_BEGIN -->")
            end = spec.get("end", "<!-- SQUAD_STATE_END -->")
            text = fpath.read_text(encoding="utf-8") if fpath.is_file() else ""
            block = f"{begin}\n{board}\n{end}"
            if begin in text:
                text = re.sub(
                    rf"{re.escape(begin)}.*?{re.escape(end)}",
                    block,
                    text,
                    count=1,
                    flags=re.DOTALL,
                )
            else:
                text = text.rstrip() + "\n\n" + block + "\n"
            fpath.parent.mkdir(parents=True, exist_ok=True)
            fpath.write_text(text, encoding="utf-8")
            print(f"wrote {fpath}")
        elif spec.get("template") == "changelog_row" or name == "reflection":
            la = state.get("last_assess") or {}
            if not la:
                continue
            day = datetime.now(timezone.utc).strftime("%Y-%m-%d")
            line = f"| {day} | squad assess auto={la.get('percent_auto')}% ready={la.get('ready')} |\n"
            fpath = ctx.resolve_path(spec["file"])
            if fpath.is_file() and line not in fpath.read_text(encoding="utf-8"):
                body = fpath.read_text(encoding="utf-8")
                anchor = spec.get(
                    "changelog_anchor",
                    "## 6. 变更日志\n\n| 日期 | 摘要 |\n|------|------|\n",
                )
                if anchor in body:
                    body = body.replace(anchor, anchor + line)
                    fpath.write_text(body, encoding="utf-8")
                    print(f"appended {fpath}")
    return 0


def cmd_workflow_list(ctx: SquadContext, args: argparse.Namespace) -> int:
    if not ctx.workflows_dir.is_dir():
        return 0
    for p in sorted(ctx.workflows_dir.glob("*.yaml")):
        spec = _load_yaml(p)
        binds = spec.get("binds_role") or spec.get("role") or "?"
        print(f"{p.stem}\t{spec.get('name', p.stem)}\tbinds={binds}")
    return 0


def cmd_workflow_run(ctx: SquadContext, args: argparse.Namespace) -> int:
    path = ctx.workflow_path(args.workflow_id)
    if not path.is_file():
        print(f"missing {path}", file=sys.stderr)
        return 1
    spec = _load_yaml(path)
    role = args.as_role or ""
    print(f"# {spec.get('name', args.workflow_id)}")
    for step in spec.get("steps", []):
        print(f"\n## {step['id']}")
        act = step.get("action")
        if act == "cli" and step.get("cmd"):
            cmd = step["cmd"].replace("<ROLE>", role).replace("<PROJECT>", str(ctx.work_root))
            print(f"  $ squad {cmd.replace('squad ', '')}")
        elif act == "run":
            print(f"  $ {step.get('cmd', '')}")
        else:
            print(f"  [{act}] {step.get('note', '')}")
    return 0


def cmd_init(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    store.init_empty(force=args.force)
    store.export_json()
    print(f"initialized {ctx.db_path}")
    return 0


def cmd_export(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    p = store.export_json()
    print(p)
    return 0


def cmd_halt(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    store.set_meta("halt", True)
    store.set_meta("halt_reason", args.reason)
    store.export_json()
    return 0


def cmd_roles(ctx: SquadContext, args: argparse.Namespace) -> int:
    for rid, spec in ctx.roles.items():
        print(f"{rid}\tkind={spec.get('kind')}\tworkflow={spec.get('workflow', '-')}")
    return 0


def _supervisor_options(ctx: SquadContext, args: argparse.Namespace) -> dict:
    cfg = ctx.catalog.get("supervisor") or {}
    return {
        "timeout_sec": float(args.timeout if args.timeout is not None else cfg.get("timeout_sec", 7200)),
        "poll_interval_sec": float(
            args.poll_interval if args.poll_interval is not None else cfg.get("poll_interval_sec", 15)
        ),
        "max_waves": int(args.max_waves if args.max_waves is not None else cfg.get("max_waves", 50)),
        "max_tasks": int(args.max_tasks if args.max_tasks is not None else ctx.dispatch_cfg.get("max_per_wave", 2)),
        "task_timeout_sec": float(
            args.task_timeout if args.task_timeout is not None else cfg.get("task_timeout_sec", 3600)
        ),
        "stuck_policy": args.stuck_policy or cfg.get("stuck_policy", "fail"),
        "max_iter": int(args.max_iter if getattr(args, "max_iter", None) is not None else cfg.get("max_iter", 500)),
        "auto_exec": _resolve_auto_exec(ctx, args),
        "auto_done": _resolve_auto_done(ctx, args),
    }


def _resolve_auto_exec(ctx: SquadContext, args: argparse.Namespace) -> bool:
    cfg = ctx.catalog.get("supervisor") or {}
    if getattr(args, "auto_exec", None) is not None:
        return bool(args.auto_exec)
    return bool(cfg.get("auto_exec", False))


def _resolve_auto_done(ctx: SquadContext, args: argparse.Namespace) -> bool:
    cfg = ctx.catalog.get("supervisor") or {}
    if getattr(args, "auto_done", None) is not None:
        return bool(args.auto_done)
    return bool(cfg.get("auto_done", False))


def cmd_supervise(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    opts = _supervisor_options(ctx, args)
    if args.once:
        tick = supervise_tick(
            ctx,
            store,
            max_tasks=opts["max_tasks"],
            task_timeout_sec=opts["task_timeout_sec"],
            stuck_policy=opts["stuck_policy"],
        )
        store.export_json()
        if args.json:
            print(json.dumps(tick, indent=2, ensure_ascii=False))
        else:
            oc = tick.get("outcome") or "continue"
            print(
                f"supervise-tick: outcome={oc} ready={tick['ready']} "
                f"auto={tick['percent_auto']}% dispatched={tick.get('dispatched', 0)}"
            )
        if tick.get("outcome") == OUTCOME_COMPLETE:
            return 0
        if tick.get("outcome") == OUTCOME_FAILED:
            return 1
        if tick.get("outcome") == OUTCOME_TIMEOUT:
            return 3
        return 2

    outcome, code = run_supervise(
        ctx,
        store,
        timeout_sec=opts["timeout_sec"],
        poll_interval_sec=opts["poll_interval_sec"],
        max_waves=opts["max_waves"],
        max_tasks=opts["max_tasks"],
        task_timeout_sec=opts["task_timeout_sec"],
        stuck_policy=opts["stuck_policy"],
        once=False,
    )
    if args.json:
        print(json.dumps({"outcome": outcome or "tick", "exit_code": code}, indent=2))
    else:
        label = outcome or "interrupted"
        print(f"supervise: outcome={label} exit={code}")
    return code


def cmd_signal(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    store.set_signal(
        args.subject,
        args.signal,
        task_id=args.task_id or None,
        reason=args.reason or None,
    )
    store.export_json()
    print(f"signal {args.subject} -> {args.signal}")
    return 0


def cmd_fail(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    spec = ctx.tasks.get(args.task_id) or {}
    touch = list(spec.get("touch_paths") or [])
    try:
        store.task_set_outcome(
            args.role,
            args.task_id,
            "failed",
            reason=args.reason or "failed",
            touch_paths=touch,
        )
    except SquadLockError as e:
        print(str(e), file=sys.stderr)
        return 1
    store.export_json()
    print(f"failed {args.role} {args.task_id}")
    return 0


def cmd_task_timeout(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    spec = ctx.tasks.get(args.task_id) or {}
    touch = list(spec.get("touch_paths") or [])
    try:
        store.task_set_outcome(
            args.role,
            args.task_id,
            "timeout",
            reason=args.reason or "timeout",
            touch_paths=touch,
        )
    except SquadLockError as e:
        print(str(e), file=sys.stderr)
        return 1
    store.export_json()
    print(f"timeout {args.role} {args.task_id}")
    return 0


def cmd_run_loop(ctx: SquadContext, args: argparse.Namespace) -> int:
    """Same tool for commander / engineer-a / engineer-b / reviewer."""
    store = get_store(ctx)
    role = args.role
    if role not in ctx.all_role_ids():
        print(f"unknown role {role}; catalog: {', '.join(ctx.all_role_ids())}", file=sys.stderr)
        return 1
    opts = _supervisor_options(ctx, args)
    max_iter = opts["max_iter"]
    outcome, code = run_member_loop(
        ctx,
        store,
        role,
        max_iter=max_iter,
        poll_interval_sec=opts["poll_interval_sec"],
        timeout_sec=opts["timeout_sec"],
        max_tasks=opts["max_tasks"],
        task_timeout_sec=opts["task_timeout_sec"],
        stuck_policy=opts["stuck_policy"],
        once=args.once,
        auto_exec=opts["auto_exec"],
        auto_done=opts["auto_done"],
    )
    store.export_json()
    if args.json:
        print(json.dumps({"role": role, "outcome": outcome, "exit_code": code}, indent=2))
    else:
        print(f"run-loop role={role} outcome={outcome} exit={code}")
    return code


def cmd_agent_team(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    cmd_resume(ctx, argparse.Namespace(reason="agent-team"))
    cmd_dispatch(ctx, argparse.Namespace(max_tasks=4, force=True, include_meta=True))
    poll = float(args.poll_interval if args.poll_interval is not None else 8.0)
    max_iter = int(args.max_iter if args.max_iter is not None else 500)
    auto_exec = _resolve_auto_exec(ctx, args)
    auto_done = _resolve_auto_done(ctx, args)
    return spawn_agent_team(
        ctx, poll_sec=poll, max_iter=max_iter, auto_exec=auto_exec, auto_done=auto_done
    )


def cmd_worker_tick(ctx: SquadContext, args: argparse.Namespace) -> int:
    store = get_store(ctx)
    cfg = ctx.catalog.get("supervisor") or {}
    task_timeout = float(
        args.task_timeout if args.task_timeout is not None else cfg.get("task_timeout_sec", 3600)
    )
    result = member_tick(ctx, store, args.role, task_timeout_sec=task_timeout)
    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(f"worker-tick {args.role}: action={result.get('action')} task={result.get('task_id')}")
        if result.get("reason"):
            print(f"  reason: {result['reason']}")
        if result.get("pending"):
            print(f"  pending: {', '.join(result['pending'])}")
    if result.get("action") in ("halt", "stand_down"):
        return 1 if result.get("action") == "halt" else 0
    return 0
