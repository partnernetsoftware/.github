#!/usr/bin/env python3
"""Universal squad CLI — orchestration via catalog + state, not ad-hoc .md."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Allow running as script without install
_ROOT = Path(__file__).resolve().parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from engine.context import SquadContext
from engine.commands import (
    cmd_assess,
    cmd_claim,
    cmd_dispatch,
    cmd_done,
    cmd_export,
    cmd_fail,
    cmd_halt,
    cmd_init,
    cmd_agent_team,
    cmd_reflect,
    cmd_resume,
    cmd_roles,
    cmd_run_loop,
    cmd_signal,
    cmd_status,
    cmd_supervise,
    cmd_sync_md,
    cmd_task_timeout,
    cmd_verify,
    cmd_worker_tick,
    cmd_workflow_list,
    cmd_workflow_run,
)


def main() -> int:
    p = argparse.ArgumentParser(description="Squad — generic multi-role orchestration CLI")
    p.add_argument("--project-root", type=Path, help="Repo root (default: find .squadrc.yaml)")
    p.add_argument("--catalog", type=Path, help="Path to catalog.yaml")
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("roles", help="List roles from catalog").set_defaults(func=lambda ctx, a: cmd_roles(ctx, a))

    a = sub.add_parser("assess")
    a.add_argument("--json", action="store_true")
    a.set_defaults(func=cmd_assess)

    s = sub.add_parser("status")
    s.add_argument("--role")
    s.add_argument("--json", action="store_true")
    s.set_defaults(func=cmd_status)

    d = sub.add_parser("dispatch")
    d.add_argument("--max-tasks", type=int)
    d.add_argument("--force", action="store_true", help="Dispatch even if squad halted")
    d.add_argument("--include-meta", action="store_true", help="Also dispatch reviewer/commander tasks")
    d.set_defaults(func=cmd_dispatch)

    rs = sub.add_parser("resume", help="Clear halt and bump wave for next agent-team run")
    rs.add_argument("--reason", default="resume")
    rs.set_defaults(func=cmd_resume)

    c = sub.add_parser("claim")
    c.add_argument("role")
    c.add_argument("task_id")
    c.set_defaults(func=cmd_claim)

    dn = sub.add_parser("done")
    dn.add_argument("role")
    dn.add_argument("task_id")
    dn.add_argument("--commit", required=True)
    dn.add_argument("--verify-label", default="")
    dn.set_defaults(func=cmd_done)

    r = sub.add_parser("reflect")
    r.add_argument("--gate")
    r.add_argument("--status", choices=["pass", "fail", "warn"])
    r.add_argument("--note", default="")
    r.set_defaults(func=cmd_reflect)

    v = sub.add_parser("verify")
    v.add_argument("--quick", action="store_true")
    v.set_defaults(func=cmd_verify)

    sy = sub.add_parser("sync-md")
    sy.add_argument("--targets", help="Comma-separated sync target ids from catalog.sync")
    sy.set_defaults(func=cmd_sync_md)

    wl = sub.add_parser("workflow-list")
    wl.set_defaults(func=cmd_workflow_list)

    wr = sub.add_parser("workflow-run")
    wr.add_argument("workflow_id")
    wr.add_argument("--as-role", default="")
    wr.set_defaults(func=cmd_workflow_run)

    h = sub.add_parser("halt")
    h.add_argument("--reason", default="signoff")
    h.set_defaults(func=cmd_halt)

    i = sub.add_parser("init", help="Create SQLite state from catalog roles")
    i.add_argument("--force", action="store_true")
    i.set_defaults(func=cmd_init)

    ex = sub.add_parser("export-json", help="Export .squad/state.json snapshot from DB")
    ex.set_defaults(func=cmd_export)

    sup = sub.add_parser(
        "supervise",
        help="Commander while-loop until complete|failed|timeout",
    )
    sup.add_argument("--timeout", type=float, help="Global supervisor timeout (seconds)")
    sup.add_argument("--poll-interval", type=float, help="Sleep between ticks (seconds)")
    sup.add_argument("--max-waves", type=int)
    sup.add_argument("--max-tasks", type=int)
    sup.add_argument("--task-timeout", type=float, help="Per-task in_progress timeout")
    sup.add_argument(
        "--stuck-policy",
        choices=["fail", "timeout", "redispatch"],
        help="When task exceeds task-timeout",
    )
    sup.add_argument("--once", action="store_true", help="Single tick (no sleep loop)")
    sup.add_argument("--json", action="store_true")
    sup.set_defaults(func=cmd_supervise)

    sig = sub.add_parser("signal", help="Set role/supervisor signal")
    sig.add_argument("subject", help="role id or 'supervisor'")
    sig.add_argument(
        "signal",
        choices=["running", "complete", "failed", "timeout"],
    )
    sig.add_argument("--task-id", default="")
    sig.add_argument("--reason", default="")
    sig.set_defaults(func=cmd_signal)

    fl = sub.add_parser("fail", help="Mark task failed and release locks")
    fl.add_argument("role")
    fl.add_argument("task_id")
    fl.add_argument("--reason", default="")
    fl.set_defaults(func=cmd_fail)

    to = sub.add_parser("task-timeout", help="Mark task timed out and release locks")
    to.add_argument("role")
    to.add_argument("task_id")
    to.add_argument("--reason", default="")
    to.set_defaults(func=cmd_task_timeout)

    wt = sub.add_parser("worker-tick", help="One member tick (debug; prefer run-loop)")
    wt.add_argument("role")
    wt.add_argument("--task-timeout", type=float)
    wt.add_argument("--json", action="store_true")
    wt.set_defaults(func=cmd_worker_tick)

    rl = sub.add_parser(
        "run-loop",
        help="Unified while-loop for ANY role (commander=leader, others await leader signal)",
    )
    rl.add_argument("--role", required=True, help="catalog role id")
    rl.add_argument("--timeout", type=float)
    rl.add_argument("--poll-interval", type=float)
    rl.add_argument("--max-waves", type=int)
    rl.add_argument("--max-tasks", type=int)
    rl.add_argument("--max-iter", type=int, help="Follower iterations (leader uses supervise)")
    rl.add_argument("--task-timeout", type=float)
    rl.add_argument("--stuck-policy", choices=["fail", "timeout", "redispatch"])
    rl.add_argument("--once", action="store_true")
    rl.add_argument(
        "--auto-exec",
        action=argparse.BooleanOptionalAction,
        default=None,
        help="Auto claim/verify on member tick (default: catalog supervisor.auto_exec)",
    )
    rl.add_argument("--json", action="store_true")
    rl.set_defaults(func=cmd_run_loop)

    at = sub.add_parser("agent-team", help="Spawn tmux: 4x run-loop (same tool, different --role)")
    at.add_argument("--poll-interval", type=float, default=8.0)
    at.add_argument("--max-iter", type=int, default=500)
    at.add_argument(
        "--auto-exec",
        action=argparse.BooleanOptionalAction,
        default=None,
        help="Pass --auto-exec to each run-loop",
    )
    at.set_defaults(func=cmd_agent_team)

    args = p.parse_args()
    try:
        ctx = SquadContext(project_root=args.project_root, catalog=args.catalog)
    except FileNotFoundError as e:
        print(e, file=sys.stderr)
        return 2
    return args.func(ctx, args)


if __name__ == "__main__":
    sys.exit(main())
