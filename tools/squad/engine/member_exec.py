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
    r = subprocess.run(cmd, cwd=ctx.project_root)
    return r.returncode


def execute_member_action(
    ctx: SquadContext,
    store: SquadStore,
    role: str,
    tick: dict[str, Any],
    *,
    auto_verify: bool = True,
) -> dict[str, Any]:
    """
    Run claim / verify when tick requests it. Returns {executed, ok, detail, suggest_done}.
    Does not auto-commit or auto-done (needs human/agent confirmation).
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
            result["ok"] = False
            result["detail"] = str(e)
        return result

    if action == "work" and tid and auto_verify:
        code = _run_verify(ctx, quick=True)
        result["executed"] = "verify"
        result["ok"] = code == 0
        result["detail"] = f"verify exit={code}"
        if result["ok"]:
            commit = _git_short_commit(ctx.project_root)
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
