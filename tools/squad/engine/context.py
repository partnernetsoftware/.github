from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    yaml = None


def _load_yaml(path: Path) -> dict[str, Any]:
    if yaml is None:
        raise RuntimeError("pyyaml required: pip install pyyaml")
    with path.open(encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data if isinstance(data, dict) else {}


def _find_project_root(start: Path) -> Path:
    cur = start.resolve()
    for _ in range(12):
        if (cur / ".squadrc.yaml").is_file() or (cur / ".squadrc.yml").is_file():
            return cur
        if (cur / ".git").exists():
            return cur
        parent = cur.parent
        if parent == cur:
            break
        cur = parent
    return start.resolve()


def load_squadrc(project_root: Path) -> dict[str, Any]:
    for name in (".squadrc.yaml", ".squadrc.yml"):
        p = project_root / name
        if p.is_file():
            return _load_yaml(p)
    return {}


def normalize_catalog(raw: dict[str, Any], catalog_path: Path) -> dict[str, Any]:
    """Support squad/v2 and legacy v1 (flat signoff + tasks)."""
    if raw.get("apiVersion") == "squad/v2":
        return raw
    # legacy v1
    base = catalog_path.parent
    roles = raw.get("roles")
    if not roles:
        roles = {
            "reviewer": {"kind": "meta", "workflow": "reviewer"},
            "commander": {"kind": "orchestrator", "workflow": "commander"},
            "engineer-a": {"kind": "worker", "workflow": "worker"},
            "engineer-b": {"kind": "worker", "workflow": "worker"},
        }
        # map old A/B/R task roles
        tasks = {}
        for tid, spec in (raw.get("tasks") or {}).items():
            spec = dict(spec)
            r = spec.get("role")
            if r == "A":
                spec["assign_role"] = "engineer-a"
            elif r == "B":
                spec["assign_role"] = "engineer-b"
            elif r == "R":
                spec["assign_role"] = "reviewer"
            else:
                spec.setdefault("assign_role", r)
            tasks[tid] = spec
        dispatch = raw.get("dispatch") or {
            "assign_to": ["engineer-a", "engineer-b"],
            "max_per_wave": 2,
        }
        return {
            "apiVersion": "squad/v2",
            "project": {
                "root": str(raw.get("project_root", ".")),
                "state_file": raw.get("state_file", ".squad/state.json"),
            },
            "roles": roles,
            "dispatch": dispatch,
            "signoff": raw.get("signoff", {}),
            "tasks": tasks,
            "verify": raw.get("verify"),
            "sync": raw.get("sync"),
            "_catalog_dir": str(base),
        }
    return raw


class SquadContext:
    def __init__(self, project_root: Path | None = None, catalog: Path | None = None):
        self.project_root = project_root or _find_project_root(Path.cwd())
        rc = load_squadrc(self.project_root)
        cat_rel = catalog or rc.get("catalog") or rc.get("catalog_path")
        if cat_rel:
            self.catalog_path = (self.project_root / cat_rel).resolve()
        else:
            # default: squad/catalog.yaml under project
            self.catalog_path = (self.project_root / "squad" / "catalog.yaml").resolve()
        if not self.catalog_path.is_file():
            raise FileNotFoundError(f"catalog not found: {self.catalog_path}")
        raw = _load_yaml(self.catalog_path)
        self.catalog = normalize_catalog(raw, self.catalog_path)
        self.catalog_dir = self.catalog_path.parent
        proj = self.catalog.get("project") or {}
        root_rel = proj.get("root", ".")
        self.work_root = (self.catalog_dir / root_rel).resolve()
        state_rel = proj.get("state_file", ".squad/state.json")
        self.state_json_path = (self.work_root / state_rel).resolve()
        db_rel = proj.get("state_db", ".squad/state.db")
        self.db_path = (self.work_root / db_rel).resolve()
        # legacy alias
        self.state_path = self.db_path
        lock_cfg = self.catalog.get("locking") or {}
        self.lock_backend = lock_cfg.get("backend", "sqlite")
        wf = rc.get("workflows_dir") or self.catalog.get("workflows_dir") or "workflows"
        self.workflows_dir = (self.catalog_dir / wf).resolve()
        self.roles = self.catalog.get("roles") or {}
        self.dispatch_cfg = self.catalog.get("dispatch") or {}
        self.signoff = self.catalog.get("signoff") or {}
        self.tasks = self.catalog.get("tasks") or {}
        self.verify_cfg = self.catalog.get("verify") or {}
        self.sync_cfg = self.catalog.get("sync") or {}

    def resolve_path(self, rel: str) -> Path:
        p = Path(rel)
        if p.is_absolute():
            return p
        return (self.work_root / rel).resolve()

    def worker_roles(self) -> list[str]:
        assign = self.dispatch_cfg.get("assign_to")
        if assign:
            return list(assign)
        return [rid for rid, spec in self.roles.items() if spec.get("kind") == "worker"]

    def all_role_ids(self) -> list[str]:
        return list(self.roles.keys())

    def workflow_path(self, workflow_id: str) -> Path:
        return self.workflows_dir / f"{workflow_id}.yaml"

    def task_assign_role(self, task_id: str) -> str | None:
        spec = self.tasks.get(task_id) or {}
        return spec.get("assign_role") or spec.get("role")
