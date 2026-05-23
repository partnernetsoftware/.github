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
from engine.supervisor import team_ready_to_release


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


if __name__ == "__main__":
    unittest.main()
