"""Generic squad orchestration engine (project-agnostic)."""

from .context import SquadContext
from .gates import check_gate
from .state import empty_state, load_state, save_state, task_status

__all__ = [
    "SquadContext",
    "check_gate",
    "empty_state",
    "load_state",
    "save_state",
    "task_status",
]
