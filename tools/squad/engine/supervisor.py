"""Supervisor while-loop: exit only on complete, failed, or timeout."""
from __future__ import annotations

import time
from datetime import datetime, timezone
from typing import Any

from .context import SquadContext
from .db import SquadStore
from .gates import run_assess

OUTCOME_COMPLETE = "complete"
OUTCOME_FAILED = "failed"
OUTCOME_TIMEOUT = "timeout"

TERMINAL_SIGNALS = frozenset({OUTCOME_COMPLETE, OUTCOME_FAILED, OUTCOME_TIMEOUT})
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


def pending_worker_tasks(ctx: SquadContext, store: SquadStore) -> list[str]:
    workers = set(ctx.worker_roles())
    out: list[str] = []
    for tid in ctx.tasks:
        if ctx.task_assign_role(tid) not in workers:
            continue
        st = store.task_status(tid)
        if st in ("pending", "assigned", "in_progress"):
            deps = ctx.tasks[tid].get("depends", [])
            if any(store.task_status(d) not in ("done",) for d in deps):
                continue
            out.append(tid)
    return out


def idle_workers(ctx: SquadContext, state: dict[str, Any]) -> list[str]:
    idle = []
    for rid in ctx.worker_roles():
        cur = state.get("assignments", {}).get(rid)
        if not cur:
            idle.append(rid)
    return idle


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
    """One dispatch pass; returns count assigned."""
    state = store.load_snapshot()
    if state.get("halt"):
        return 0
    workers = ctx.worker_roles()
    pending = pending_worker_tasks(ctx, store)
    assigned = 0
    for role in workers:
        if assigned >= max_tasks:
            break
        busy = state.get("assignments", {}).get(role)
        if busy:
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
    """Single supervisor iteration (assess → fail checks → dispatch)."""
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
    }

    if report["ready"]:
        tick["outcome"] = OUTCOME_COMPLETE
        store.set_meta("supervisor_outcome", OUTCOME_COMPLETE)
        store.set_meta("halt", True)
        store.set_meta("halt_reason", "signoff")
        store.set_signal("supervisor", OUTCOME_COMPLETE, reason="assess.ready")
        return tick

    wf = worker_failed(store, ctx)
    tf = task_failed(store.load_snapshot())
    if wf or tf:
        tick["outcome"] = OUTCOME_FAILED
        tick["fail_detail"] = wf or tf
        store.set_meta("supervisor_outcome", OUTCOME_FAILED)
        store.set_meta("halt", True)
        store.set_meta("halt_reason", tick["fail_detail"])
        store.set_signal("supervisor", OUTCOME_FAILED, reason=tick["fail_detail"])
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
            tick["outcome"] = OUTCOME_TIMEOUT
            store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
            store.set_meta("halt", True)
            store.set_meta("halt_reason", f"stuck:{','.join(stuck)}")
            reason = f"stuck:{','.join(stuck)}"
            store.set_meta("halt_reason", reason)
            store.set_signal("supervisor", OUTCOME_TIMEOUT, reason=reason)
            tick["halt_reason"] = reason
            return tick
        if stuck_policy == "fail":
            tick["outcome"] = OUTCOME_FAILED
            store.set_meta("supervisor_outcome", OUTCOME_FAILED)
            store.set_meta("halt", True)
            reason = f"stuck:{','.join(stuck)}"
            store.set_meta("halt_reason", reason)
            store.set_signal("supervisor", OUTCOME_FAILED, reason=reason)
            tick["halt_reason"] = reason
            return tick
        # redispatch: release stuck — not implemented fully; mark timeout on role signal only

    pending = pending_worker_tasks(ctx, store)
    tick["pending_count"] = len(pending)
    if pending and idle_workers(ctx, store.load_snapshot()):
        tick["dispatched"] = dispatch_wave(ctx, store, max_tasks)

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
    """
    While-loop until complete | failed | timeout.
    Returns (outcome, exit_code): complete=0, failed=1, timeout=3, tick=2.
    """
    cfg = _supervisor_cfg(ctx)
    start = time.time()
    wave = int(store.get_meta("wave", 1) or 1)
    store.set_meta("supervisor_started_at", _utc_now())
    store.set_meta("supervisor_outcome", None)
    store.set_signal("supervisor", "running", reason="supervise loop")

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

        if tick.get("outcome") in TERMINAL_SIGNALS:
            return tick["outcome"], 0 if tick["outcome"] == OUTCOME_COMPLETE else (
                3 if tick["outcome"] == OUTCOME_TIMEOUT else 1
            )

        if tick.get("dispatched") or tick.get("percent_auto", 0) > int(
            store.get_meta("last_progress_percent", 0) or 0
        ):
            last_progress = time.time()
            store.set_meta("last_progress_percent", tick["percent_auto"])
        elif time.time() - last_progress > task_timeout_sec and pending_worker_tasks(ctx, store):
            # global stall with pending work
            if stuck_policy == "timeout":
                outcome = OUTCOME_TIMEOUT
                store.set_meta("supervisor_outcome", OUTCOME_TIMEOUT)
                store.set_meta("halt", True)
                store.set_meta("halt_reason", "no_progress")
                store.set_signal("supervisor", OUTCOME_TIMEOUT, reason="no_progress")
                store.export_json()
                return outcome, 3

        # wave bump when all workers idle and no in-flight tasks
        state = store.load_snapshot()
        inflight = any(
            state.get("tasks", {}).get(tid, {}).get("status") in ("assigned", "in_progress")
            for tid in ctx.tasks
            if ctx.task_assign_role(tid) in ctx.worker_roles()
        )
        if not inflight and not pending_worker_tasks(ctx, store):
            wave += 1
            store.set_meta("wave", wave)
            if wave > max_waves and not tick["ready"]:
                outcome = OUTCOME_FAILED
                store.set_meta("supervisor_outcome", OUTCOME_FAILED)
                store.set_meta("halt", True)
                store.set_meta("halt_reason", f"max_waves={max_waves}")
                store.set_signal("supervisor", OUTCOME_FAILED, reason=store.get_meta("halt_reason"))
                store.export_json()
                return outcome, 1

        if once:
            return "", 2

        time.sleep(poll_interval_sec)


def worker_tick(
    ctx: SquadContext,
    store: SquadStore,
    role: str,
    *,
    task_timeout_sec: float,
) -> dict[str, Any]:
    """One worker-loop step for AI/human: what to do next."""
    if role not in ctx.all_role_ids():
        return {"error": f"unknown role {role}"}

    state = store.load_snapshot()
    cur = state.get("assignments", {}).get(role)
    spec = (state.get("tasks") or {}).get(cur or "", {})
    status = spec.get("status", "idle")
    now = time.time()

    result: dict[str, Any] = {
        "role": role,
        "task_id": cur,
        "status": status,
        "action": "idle",
        "signal": store.get_signal(role),
    }

    sig = store.get_signal(role)
    if sig and sig["signal"] in TERMINAL_SIGNALS - {OUTCOME_COMPLETE}:
        result["action"] = "halt"
        result["reason"] = sig.get("reason")
        return result

    if not cur:
        pending = [
            tid
            for tid in pending_worker_tasks(ctx, store)
            if ctx.task_assign_role(tid) == role
        ]
        if pending:
            result["action"] = "wait_dispatch"
            result["pending"] = pending
        else:
            result["action"] = "idle"
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

    if status == "done":
        result["action"] = "idle"
        store.set_signal(role, OUTCOME_COMPLETE, task_id=cur, reason="task done")
        return result

    if status in ("failed", "timeout"):
        result["action"] = "halt"
        result["reason"] = status
        return result

    result["action"] = "work"
    return result
