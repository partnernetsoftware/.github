"""Lightweight supervisor / release invariants."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

_ROOT = Path(__file__).resolve().parents[1]
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from engine.context import SquadContext
from engine.db import SquadStore
from engine.supervisor import OUTCOME_TIMEOUT, run_member_loop, team_ready_to_release


class TeamReadyTests(unittest.TestCase):
    def _ctx_and_store(self):
        catalog = Path(__file__).resolve().parents[3] / "lab/nano-lisp-jit/squad/catalog-v4.yaml"
        ctx = SquadContext(
            project_root=Path(__file__).resolve().parents[3],
            catalog=catalog,
        )
        store = SquadStore(ctx)
        return ctx, store

    def test_not_ready_with_pending_catalog_task(self):
        ctx, store = self._ctx_and_store()
        store.set_meta("halt", False)
        for tid in ctx.tasks:
            if store.task_status(tid) == "pending":
                self.assertFalse(team_ready_to_release(ctx, store))
                break


    def test_max_iter_maps_to_timeout(self):
        catalog = Path(__file__).resolve().parents[3] / "lab/nano-lisp-jit/squad/catalog-v4.yaml"
        ctx = SquadContext(
            project_root=Path(__file__).resolve().parents[3],
            catalog=catalog,
        )
        store = SquadStore(ctx)
        store.set_signal("supervisor", "running", reason="test")
        outcome, code = run_member_loop(
            ctx,
            store,
            "engineer-a",
            max_iter=1,
            poll_interval_sec=0.01,
            timeout_sec=7200,
            max_tasks=2,
            task_timeout_sec=3600,
            stuck_policy="fail",
            once=False,
            auto_exec=False,
        )
        self.assertEqual(outcome, OUTCOME_TIMEOUT)
        self.assertEqual(code, 3)


if __name__ == "__main__":
    unittest.main()
