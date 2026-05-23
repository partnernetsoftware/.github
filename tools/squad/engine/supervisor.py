"""Squad team loops — one implementation for every role (leader + followers)."""
from __future__ import annotations

import subprocess
import sys
import time
from datetime import datetime, timezone
from typing import Any

from .context import SquadContext
from .db import SquadStore
from .gates import run_assess

OUTCOME_COMPLETE = "complete"
OUTCOME_FAILED = "failed"
OUTCOME_TIMEOUT = "timeout"

TERMINAL_LEADER = frozenset({OUTCOME_COMPLETE, OUTCOME_FAILED, OUTCOME_TIMEOUT})
LEADER_ACTIVE = frozenset({"running", "standby"})
TERMINAL_TASK = frozenset({"done", "failed", "timeout"})


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _parse_ts(iso: str | None) -> float | None:
    if not iso:
        return None
    try:
        return datetime.fromisoformat(iso.replace("Z", "+00:00")).timestamp()
    except ValueError:
        return None


def _supervisor_cfg(ctx: SquadContext) -> dict[str, Any]:
    return dict(ctx.catalog.get("supervisor") or {})


def team_mode(ctx: SquadContext) -> bool:
    cfg = _supervisor_cfg(ctx)
    return cfg.get("team_mode", True) is not False


def leader_signal(store: SquadStore) -> str:
    sig = store.get_signal("supervisor")
    if not sig or not sig.get("signal"):
        return "running"
    return str(sig["signal"])


def pending_any_tasks(ctx: SquadContext, store: SquadStore) -> bool:
    for tid in ctx.tasks:
        st = store.task_status(tid)
        if st in ("pending", "assigned", "in_progress"):
            deps = ctx.tasks[tid].get("depends", [])
            if any(store.task_status(d) != "done" for d in deps):
                continue
            return True
    return False


def inflight_assignments(state: dict[str, Any]) -> bool:
    return any(v for v in (state.get("assignments") or {}).values() if v)


def team_ready_to_release(ctx: SquadContext, store: SquadStore) -> bool:
    state = store.load_snapshot()
    report, _ = run_assess(ctx, state)
    if not report.get("ready"):
        return False
    if pending_any_tasks(ctx, store):
        return False
    if inflight_assignments(state):
        return False
    # All catalog tasks must be terminal (done/failed/timeout), not only unassigned pending
    for tid in ctx.tasks:
        st = store.task_status(tid)
        if st in ("pending", "assigned", "in_progress"):
            return False
    return True


def release_team(ctx: SquadContext, store: SquadStore, reason: str) -> None:
    store.set_signal("supervisor", OUTCOME_COMPLETE, reason=reason)
    store.set_meta("supervisor_outcome", OUTCOME_COMPLETE)
    store.set_meta("halt", True)
    store.set_meta("halt_reason", reason)
    for rid in ctx.all_role_ids():
        if rid == "commander":
            continue
        store.set_signal(rid, OUTCOME_COMPLETE, reason="leader_release")


def pending_worker_tasks(ctx: SquadContext, store: SquadStore) -> list[str]:
    workers = set(ctx.worker_roles())
    out: list[str] = []
    for tid in ctx.tasks:
        if ctx.task_assign_role(tid) not in workers:
            continue
        st = store.task_status(tid)
        if st in ("pending", "assigned", "in_progress"):
            deps = ctx.tasks[tid].get("depends", [])
            if any(store.task_status(d) != "done" for d in deps):
                continue
            out.append(tid)
    return out


def idle_workers(ctx: SquadContext, state: dict[str, Any]) -> list[str]:
    return [
        rid
        for rid in ctx.worker_roles()
        if not state.get("assignments", {}).get(rid)
    ]


def worker_failed(store: SquadStore, ctx: SquadContext) -> str | None:
    for rid in ctx.worker_roles():
        sig = store.get_signal(rid)
        if sig and sig["signal"] in (OUTCOME_FAILED, OUTCOME_TIMEOUT):
            return f"{rid}:{sig['signal']}:{sig.get('reason') or ''}"
    return None


def task_failed(state: dict[str, Any]) -> str | None:
    for tid, spec in (state.get("tasks") or {}).items():
        if spec.get("status") in ("failed", "timeout"):
            return f"{tid}:{spec['status']}"
    return None


def stuck_tasks(
    ctx: SquadContext,
    state: dict[str, Any],
    *,
    task_timeout_sec: float,
    now: float,
) -> list[str]:
    stuck: list[str] = []
    for tid, spec in (state.get("tasks") or {}).items():
        if spec.get("status") not in ("assigned", "in_progress"):
            continue
        ts = _parse_ts(spec.get("started_at") or spec.get("updated_at"))
        if ts is None:
            continue
        if now - ts > task_timeout_sec:
            stuck.append(tid)
    return stuck


def dispatch_wave(ctx: SquadContext, store: SquadStore, max_tasks: int) -> int:
    state = store.load_snapshot()
    if state.get("halt") and leader_signal(store) in TERMINAL_LEADER:
        return 0
    workers = ctx.worker_roles()
    pending = pending_worker_tasks(ctx, store)
    assigned = 0
    for role in workers:
        if assigned >= max_tasks:
            break
        if state.get("assignments", {}).get(role):
            continue
        for tid in list(pending):
            if ctx.task_assign_role(tid) != role:
                continue
            if store.dispatch_assign(role, tid):
                pending.remove(tid)
                store.set_signal(role, "running", task_id=tid, reason="dispatched")
                assigned += 1
                break
    return assigned


def supervise_tick(
    ctx: SquadContext,
    store: SquadStore,
    *,
    max_tasks: int,
    task_timeout_sec: float,
    stuck_policy: str,
    now: float | None = None,
) -> dict[str, Any]:
    """One leader tick: assess → dispatch → maybe standby (never auto-complete in team_mode)."""
    now = now if now is not None else time.time()
    state = store.load_snapshot()
    report, assess_code = run_assess(ctx, state)
    store.set_meta("last_assess", report)
    store.set_meta("signoff_percent", report["percent_auto"])

    tick: dict[str, Any] = {
        "at": _utc_now(),
        "percent_auto": report["percent_auto"],
        "ready": report["ready"],
        "assess_code": assess_code,
        "dispatched": 0,
        "outcome": None,
        "leader": leader_signal(store),
    }

    if team_mode(ctx) and report["ready"]:
        if team_ready_to_release(ctx, store):
            release_team(ctx, store, "signoff_and_all_tasks_done")
            tick["outcome"] = OUTCOME_COMPLETE
            tick["leader"] = OUTCOME_COMPLETE
            return tick
        store.set_signal("supervisor", "standby", reason="signoff_ready_team_busy")
        tick["leader"] = "standby"
        tick["signoff_ready"] = True
    elif report["ready"] and not team_mode(ctx):
        if team_ready_to_release(ctx, store):
            release_team(ctx, store, "signoff_and_all_tasks_done")
            tick["outcome"] = OUTCOME_COMPLETE
            tick["leader"] = OUTCOME_COMPLETE
            return tick
        store.set_signal("supervisor", "standby", reason="signoff_ready_team_busy")
        tick["leader"] = "standby"
        tick["signoff_ready"] = True

    wf = worker_failed(store, ctx)
    tf = task_failed(store.load_snapshot())
    if wf or tf:
        tick["outcome"] = OUTCOME_FAILED
        tick["fail_detail"] = wf or tf
        store.set_meta("supervisor_outcome", OUTCOME_FAILED)
        store.set_meta("halt", True)
        store.set_meta("halt_reason", tick["fail_detail"])
        store.set_signal("supervisor", OUTCOME_FAILED, reason=tick["fail_detail"])
        tick["leader"] = OUTCOME_FAILED
        return tick

    stuck = stuck_tasks(ctx, store.load_snapshot(), task_timeout_sec=task_timeout_sec, now=now)
    if stuck:
        tick["stuck"] = stuck
        if stuck_policy == "timeout":
            for tid in stuck:
                spec = ctx.tasks.get(tid) or {}
                role = spec.get("assign_role") or store.load_snapshot()["tasks"].get(tid, {}).get(
                    "assign_role"
                )
                if role:
                    store.task_set_outcome(
                        role,
                        tid,
                        "timeout",
                        reason="task_timeout",
                        touch_paths=list(spec.get("touch_paths") or []),
                    )
            reason = f"stuck:{','.join(stuck)}"
            store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
            store.set_meta("halt", True)
            store.set_meta("halt_reason", reason)
            store.set_signal("supervisor", OUTCOME_TIMEOUT, reason=reason)
            tick["outcome"] = OUTCOME_TIMEOUT
            tick["leader"] = OUTCOME_TIMEOUT
            return tick
        if stuck_policy == "fail":
            reason = f"stuck:{','.join(stuck)}"
            store.set_meta("supervisor_outcome", OUTCOME_FAILED)
            store.set_meta("halt", True)
            store.set_meta("halt_reason", reason)
            store.set_signal("supervisor", OUTCOME_FAILED, reason=reason)
            tick["outcome"] = OUTCOME_FAILED
            tick["leader"] = OUTCOME_FAILED
            return tick

    meta_roles = {
        rid for rid, spec in ctx.roles.items() if spec.get("kind") in ("meta", "orchestrator")
    }
    meta_idle = [
        rid for rid in meta_roles if not store.load_snapshot().get("assignments", {}).get(rid)
    ]
    meta_pending = [
        tid
        for tid in ctx.tasks
        if ctx.task_assign_role(tid) in meta_roles and store.task_status(tid) == "pending"
    ]
    if meta_pending and meta_idle:
        for rid in meta_idle:
            for tid in list(meta_pending):
                if ctx.task_assign_role(tid) != rid:
                    continue
                if store.dispatch_assign(rid, tid):
                    store.set_signal(rid, "running", task_id=tid, reason="dispatched")
                    tick["dispatched"] = tick.get("dispatched", 0) + 1
                    meta_pending.remove(tid)
                    break

    pending = pending_worker_tasks(ctx, store)
    tick["pending_count"] = len(pending)
    if pending and idle_workers(ctx, store.load_snapshot()):
        tick["dispatched"] = tick.get("dispatched", 0) + dispatch_wave(ctx, store, max_tasks)

    if team_mode(ctx) and team_ready_to_release(ctx, store):
        release_team(ctx, store, "all_tasks_done")
        tick["outcome"] = OUTCOME_COMPLETE
        tick["leader"] = OUTCOME_COMPLETE
        return tick

    return tick


def run_supervise(
    ctx: SquadContext,
    store: SquadStore,
    *,
    timeout_sec: float,
    poll_interval_sec: float,
    max_waves: int,
    max_tasks: int,
    task_timeout_sec: float,
    stuck_policy: str,
    once: bool = False,
) -> tuple[str, int]:
    """Leader (commander) while-loop — only role that drives supervisor signal."""
    start = time.time()
    wave = int(store.get_meta("wave", 1) or 1)
    store.set_meta("supervisor_started_at", _utc_now())
    store.set_meta("supervisor_outcome", None)
    store.set_meta("halt", False)
    store.set_meta("idle_waves", 0)
    store.set_signal("supervisor", "running", reason="leader run-loop")

    last_progress = start
    outcome = ""

    while True:
        elapsed = time.time() - start
        if elapsed > timeout_sec:
            outcome = OUTCOME_TIMEOUT
            store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
            store.set_meta("halt", True)
            store.set_meta("halt_reason", f"supervisor_timeout>{timeout_sec}s")
            store.set_signal("supervisor", OUTCOME_TIMEOUT, reason=store.get_meta("halt_reason"))
            store.export_json()
            return outcome, 3

        tick = supervise_tick(
            ctx,
            store,
            max_tasks=max_tasks,
            task_timeout_sec=task_timeout_sec,
            stuck_policy=stuck_policy,
        )
        store.export_json()

        if tick.get("outcome") in TERMINAL_LEADER:
            return tick["outcome"], (
                0
                if tick["outcome"] == OUTCOME_COMPLETE
                else (3 if tick["outcome"] == OUTCOME_TIMEOUT else 1)
            )

        if team_mode(ctx) and team_ready_to_release(ctx, store):
            release_team(ctx, store, "signoff_and_all_tasks_done")
            store.export_json()
            return OUTCOME_COMPLETE, 0

        if tick.get("dispatched") or tick.get("percent_auto", 0) > int(
            store.get_meta("last_progress_percent", 0) or 0
        ):
            last_progress = time.time()
            store.set_meta("last_progress_percent", tick["percent_auto"])
            store.set_meta("idle_waves", 0)
        elif time.time() - last_progress > task_timeout_sec and pending_worker_tasks(ctx, store):
            if stuck_policy == "timeout":
                outcome = OUTCOME_TIMEOUT
                store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
                store.set_meta("halt", True)
                store.set_meta("halt_reason", "no_progress")
                store.set_signal("supervisor", OUTCOME_TIMEOUT, reason="no_progress")
                store.export_json()
                return outcome, 3

        state = store.load_snapshot()
        inflight = any(
            state.get("tasks", {}).get(tid, {}).get("status") in ("assigned", "in_progress")
            for tid in ctx.tasks
            if ctx.task_assign_role(tid) in ctx.worker_roles()
        )
        any_pending = pending_any_tasks(ctx, store)

        if not inflight and not any_pending:
            if tick.get("ready"):
                release_team(ctx, store, "signoff_and_all_tasks_done")
                store.export_json()
                return OUTCOME_COMPLETE, 0
            wave += 1
            store.set_meta("wave", wave)
            if wave > max_waves:
                outcome = OUTCOME_FAILED
                store.set_meta("supervisor_outcome", OUTCOME_FAILED)
                store.set_meta("halt", True)
                store.set_meta("halt_reason", f"max_waves={max_waves}")
                store.set_signal("supervisor", OUTCOME_FAILED, reason=store.get_meta("halt_reason"))
                store.export_json()
                return outcome, 1
        elif not inflight and tick.get("ready"):
            idle = int(store.get_meta("idle_waves", 0) or 0) + 1
            store.set_meta("idle_waves", idle)
            if team_ready_to_release(ctx, store):
                release_team(ctx, store, "signoff_and_all_tasks_done")
                store.export_json()
                return OUTCOME_COMPLETE, 0
            cfg_idle = int(_supervisor_cfg(ctx).get("idle_waves_max", 12))
            if idle > cfg_idle:
                outcome = OUTCOME_TIMEOUT
                store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
                store.set_meta("halt", True)
                store.set_meta("halt_reason", f"idle_waves>{cfg_idle}")
                store.set_signal("supervisor", OUTCOME_TIMEOUT, reason=store.get_meta("halt_reason"))
                store.export_json()
                return outcome, 3

        if once:
            return "", 2

        time.sleep(poll_interval_sec)


def member_tick(
    ctx: SquadContext,
    store: SquadStore,
    role: str,
    *,
    task_timeout_sec: float,
) -> dict[str, Any]:
    """One step for any non-leader role — waits on leader signal first."""
    if role not in ctx.all_role_ids():
        return {"error": f"unknown role {role}"}

    leader = leader_signal(store)
    result: dict[str, Any] = {
        "role": role,
        "leader": leader,
        "action": "await_leader",
        "task_id": None,
        "status": "idle",
    }

    if leader in TERMINAL_LEADER:
        result["action"] = "stand_down"
        result["reason"] = f"leader={leader}"
        return result

    if team_ready_to_release(ctx, store):
        result["action"] = "stand_down"
        result["reason"] = "team_ready"
        return result

    if leader == "standby" and not pending_any_tasks(ctx, store):
        result["action"] = "await_leader"
        result["reason"] = "standby_no_pending"
        return result

    if leader not in LEADER_ACTIVE and leader != "running":
        result["action"] = "await_leader"
        result["reason"] = f"unknown_leader_signal={leader}"
        return result

    state = store.load_snapshot()
    cur = state.get("assignments", {}).get(role)
    spec = (state.get("tasks", {}).get(cur or "", {}))
    status = spec.get("status", "idle")
    now = time.time()
    result["task_id"] = cur
    result["status"] = status
    result["signal"] = store.get_signal(role)

    role_sig = store.get_signal(role)
    if role_sig and role_sig["signal"] in (OUTCOME_FAILED, OUTCOME_TIMEOUT):
        result["action"] = "halt"
        result["reason"] = role_sig.get("reason")
        return result

    if not cur:
        pending = [
            tid
            for tid in pending_worker_tasks(ctx, store)
            if ctx.task_assign_role(tid) == role
        ]
        meta_pending = [
            tid
            for tid in ctx.tasks
            if ctx.task_assign_role(tid) == role and store.task_status(tid) == "pending"
        ]
        all_p = pending + meta_pending
        if all_p:
            result["action"] = "wait_dispatch"
            result["pending"] = all_p
        else:
            result["action"] = "await_leader"
            result["reason"] = "no_task_wait_leader"
        return result

    if status == "assigned":
        result["action"] = "claim"
        return result

    if status == "in_progress":
        ts = _parse_ts(spec.get("started_at") or spec.get("updated_at"))
        if ts and now - ts > task_timeout_sec:
            result["action"] = "timeout"
            result["reason"] = "task_timeout"
        else:
            result["action"] = "work"
            result["steps"] = ["verify", "done"]
        return result

    if status in ("failed", "timeout"):
        result["action"] = "halt"
        result["reason"] = status
        return result

    if status == "done":
        result["action"] = "await_leader"
        result["reason"] = "task_done_wait_leader"
        return result

    result["action"] = "work"
    return result


# Back-compat alias
worker_tick = member_tick


def _role_kind(ctx: SquadContext, role: str) -> str:
    return (ctx.roles.get(role) or {}).get("kind", "worker")


def _exit_code_for_leader(leader: str) -> int:
    if leader == OUTCOME_COMPLETE:
        return 0
    if leader == OUTCOME_TIMEOUT:
        return 3
    if leader == OUTCOME_FAILED:
        return 1
    return 2


def run_member_loop(
    ctx: SquadContext,
    store: SquadStore,
    role: str,
    *,
    max_iter: int,
    poll_interval_sec: float,
    timeout_sec: float,
    max_tasks: int,
    task_timeout_sec: float,
    stuck_policy: str,
    once: bool = False,
    auto_exec: bool = False,
    auto_done: bool = False,
) -> tuple[str, int]:
    """
    Unified run-loop for every catalog role.
    - commander / orchestrator → leader supervise loop
    - worker / meta → follower loop (await leader signal, never call supervise)
    """
    kind = _role_kind(ctx, role)
    if kind == "orchestrator" or role == "commander":
        return run_supervise(
            ctx,
            store,
            timeout_sec=timeout_sec,
            poll_interval_sec=poll_interval_sec,
            max_waves=int(_supervisor_cfg(ctx).get("max_waves", 50)),
            max_tasks=max_tasks,
            task_timeout_sec=task_timeout_sec,
            stuck_policy=stuck_policy,
            once=once,
        )

    store.set_signal(role, "running", reason="member run-loop joined")
    start = time.time()

    for i in range(1, max_iter + 1):
        if time.time() - start > timeout_sec:
            store.set_signal(role, OUTCOME_TIMEOUT, reason="member_loop_timeout")
            store.export_json()
            return OUTCOME_TIMEOUT, 3

        leader = leader_signal(store)
        if leader in TERMINAL_LEADER:
            store.export_json()
            return leader, _exit_code_for_leader(leader)

        tick = member_tick(ctx, store, role, task_timeout_sec=task_timeout_sec)
        action = tick.get("action", "await_leader")

        if auto_exec and action in ("claim", "work", "timeout"):
            from .member_exec import execute_member_action

            ex = execute_member_action(ctx, store, role, tick, auto_done=auto_done)
            tick["auto_exec"] = ex
            if ex.get("suggest_done"):
                print(f"[{role}] {ex['suggest_done']}", file=sys.stderr)
            if ex.get("executed") == "wait_lock":
                store.export_json()
                time.sleep(poll_interval_sec)
                continue
            if not ex.get("ok", True) and action not in ("await_leader", "wait_dispatch"):
                store.export_json()
                return OUTCOME_FAILED, 1

        if action == "stand_down":
            store.export_json()
            return leader, _exit_code_for_leader(leader)

        if action == "halt":
            store.export_json()
            return OUTCOME_FAILED, 1

        if action == "claim" and tick.get("task_id"):
            store.export_json()
            if once:
                return "tick", 2
            time.sleep(poll_interval_sec)
            continue

        if action in ("work", "timeout", "wait_dispatch"):
            store.export_json()
            if once:
                return "tick", 2
            time.sleep(poll_interval_sec)
            continue

        # await_leader / idle → keep waiting for commander
        store.export_json()
        if once:
            return "tick", 2
        time.sleep(poll_interval_sec)

    store.set_signal(role, OUTCOME_TIMEOUT, reason=f"max_iter={max_iter}")
    store.export_json()
    return OUTCOME_TIMEOUT, 3


def spawn_agent_team(
    ctx: SquadContext,
    *,
    poll_sec: float = 8.0,
    max_iter: int = 500,
    auto_exec: bool = True,
    auto_done: bool = False,
) -> int:
    """Start tmux sessions — each runs the same `squad run-loop --role`."""
    root = ctx.project_root
    squad = root / "tools/squad/squad.sh"
    cat_flag = f'--catalog "{ctx.catalog_path}"'
    ae = " --auto-exec" if auto_exec else ""
    ad = " --auto-done" if auto_done else ""
    tmux = "tmux -f /exec-daemon/tmux.portal.conf"
    roles = ["commander", "engineer-a", "engineer-b", "reviewer"]
    for name in roles:
        session = f"squad-{name}"
        subprocess.run(
            f"{tmux} kill-session -t {session} 2>/dev/null || true",
            shell=True,
            check=False,
        )
        cmd = (
            f"cd {root!s} && {squad!s} {cat_flag} resume --reason agent-team 2>/dev/null; "
            f"{squad!s} {cat_flag} dispatch --force --include-meta --max-tasks 4 2>/dev/null; "
            f"{squad!s} {cat_flag} run-loop --role {name} --max-iter {max_iter} "
            f"--poll-interval {poll_sec}{ae}{ad}"
        )
        subprocess.run(
            [tmux, "new-session", "-d", "-s", session, "-c", str(root), "--", "bash", "-lc", cmd],
            check=False,
        )
    print("agent-team sessions:", ", ".join(f"squad-{r}" for r in roles))
    return 0
