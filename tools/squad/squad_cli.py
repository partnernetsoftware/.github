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
    cmd_halt,
    cmd_init,
    cmd_reflect,
    cmd_roles,
    cmd_status,
    cmd_sync_md,
    cmd_verify,
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
    d.set_defaults(func=cmd_dispatch)

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

    args = p.parse_args()
    try:
        ctx = SquadContext(project_root=args.project_root, catalog=args.catalog)
    except FileNotFoundError as e:
        print(e, file=sys.stderr)
        return 2
    return args.func(ctx, args)


if __name__ == "__main__":
    sys.exit(main())
