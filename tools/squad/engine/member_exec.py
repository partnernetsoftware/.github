"""Optional auto-execution of member_tick actions (claim / verify)."""
from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Any

from .context import SquadContext
from .db import SquadLockError, SquadStore


def _git_short_commit(project_root: Path) -> str:
    r = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        cwd=project_root,
        capture_output=True,
        text=True,
    )
    if r.returncode == 0:
        return r.stdout.strip()
    return "0000000"


def _run_verify(ctx: SquadContext, *, quick: bool = True) -> int:
    squad = ctx.project_root / "tools/squad/squad.sh"
    cmd = [str(squad)]
    if ctx.catalog_path != (ctx.project_root / ".squadrc.yaml"):
        cmd.extend(["--catalog", str(ctx.catalog_path)])
    cmd.append("verify")
    if quick:
        cmd.append("--quick")
    r = subprocess.run(cmd, cwd=ctx.project_root, env={**subprocess.os.environ, "SQUAD_VERIFY": "1"})
    return r.returncode


def execute_member_action(
    ctx: SquadContext,
    store: SquadStore,
    role: str,
    tick: dict[str, Any],
    *,
    auto_verify: bool = True,
    auto_done: bool = False,
) -> dict[str, Any]:
    """
    Run claim / verify when tick requests it. Returns {executed, ok, detail, suggest_done}.
    With auto_done, calls release_done after verify passes (no git commit).
    """
    result: dict[str, Any] = {"executed": None, "ok": True, "detail": "", "suggest_done": None}
    action = tick.get("action")
    tid = tick.get("task_id")
    spec = ctx.tasks.get(tid or "") or {}

    if action == "claim" and tid:
        touch = list(spec.get("touch_paths") or [])
        try:
            store.claim(role, tid, touch)
            result["executed"] = "claim"
            result["detail"] = f"claimed {tid}"
        except SquadLockError as e:
            msg = str(e)
            # Path held by another role — poll until merge_order releases it.
            if " locked by " in msg:
                result["executed"] = "wait_lock"
                result["detail"] = msg
            else:
                result["ok"] = False
                result["detail"] = msg
        return result

    if action == "work" and tid and auto_verify:
        global _last_verify_fail_at
        ready, why = _touch_paths_ready(ctx, spec)
        if not ready:
            result["executed"] = "defer_verify"
            result["detail"] = why
            return result
        cooling, left = _verify_cooldown_active()
        if cooling:
            result["executed"] = "defer_verify"
            result["detail"] = f"verify cooldown {left:.0f}s"
            return result
        code = _run_verify(ctx, quick=True)
        result["executed"] = "verify"
        result["ok"] = code == 0
        result["detail"] = f"verify exit={code}"
        if code != 0:
            _last_verify_fail_at = time.time()
        if result["ok"]:
            commit = _git_short_commit(ctx.project_root)
            touch = list(spec.get("touch_paths") or [])
            if auto_done:
                try:
                    store.release_done(role, tid, commit, touch)
                    result["executed"] = "done"
                    result["detail"] = f"auto_done {tid} @{commit}"
                except SquadLockError as e:
                    result["ok"] = False
                    result["detail"] = str(e)
            else:
                result["suggest_done"] = (
                    f"tools/squad/squad.sh --catalog {ctx.catalog_path} "
                    f"done {role} {tid} --commit {commit}"
                )
        return result

    if action == "timeout" and tid:
        touch = list(spec.get("touch_paths") or [])
        try:
            store.task_set_outcome(
                role, tid, "timeout", reason="auto_exec_timeout", touch_paths=touch
            )
            result["executed"] = "timeout"
            result["detail"] = f"task_timeout {tid}"
        except SquadLockError as e:
            result["ok"] = False
            result["detail"] = str(e)
        return result

    return result
