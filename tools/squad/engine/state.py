from __future__ import annotations

from typing import Any

from .context import SquadContext
from .db import SquadStore


def get_store(ctx: SquadContext) -> SquadStore:
    return SquadStore(ctx)


def load_state(ctx: SquadContext) -> dict[str, Any]:
    return get_store(ctx).load_snapshot()


def save_state(ctx: SquadContext, state: dict[str, Any]) -> None:
    get_store(ctx).save_snapshot(state)


def task_status(ctx: SquadContext, state: dict[str, Any], task_id: str) -> str:
    store = get_store(ctx)
    if state.get("tasks", {}).get(task_id):
        return state["tasks"][task_id].get("status", "pending")
    return store.task_status(task_id)


def empty_state(ctx: SquadContext) -> dict[str, Any]:
    return SquadStore(ctx)._empty_dict()
