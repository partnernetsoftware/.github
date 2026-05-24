"""SQLite-backed squad state with WAL + busy retry (exponential backoff)."""
from __future__ import annotations

import json
import sqlite3
import time
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator

from .context import SquadContext

DEFAULT_BUSY_MS = 30_000
MAX_RETRY_ATTEMPTS = 10
BACKOFF_BASE_SEC = 0.05
BACKOFF_MAX_SEC = 2.0


class SquadLockError(RuntimeError):
    pass


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


class SquadStore:
    def __init__(self, ctx: SquadContext):
        self.ctx = ctx
        self.db_path = ctx.db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._bootstrap()

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(str(self.db_path), timeout=DEFAULT_BUSY_MS / 1000.0)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA journal_mode=WAL")
        conn.execute("PRAGMA synchronous=NORMAL")
        conn.execute("PRAGMA foreign_keys=ON")
        conn.execute(f"PRAGMA busy_timeout={DEFAULT_BUSY_MS}")
        return conn

    def _bootstrap(self) -> None:
        with self._connect() as conn:
            self._init_schema(conn)
            n = conn.execute("SELECT COUNT(*) AS n FROM meta").fetchone()["n"]
            if n == 0:
                self._import_json_if_present(conn)
            conn.commit()

    def _init_schema(self, conn: sqlite3.Connection) -> None:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS assignments (
              role_id TEXT PRIMARY KEY,
              task_id TEXT
            );
            CREATE TABLE IF NOT EXISTS tasks (
              task_id TEXT PRIMARY KEY,
              status TEXT NOT NULL DEFAULT 'pending',
              assign_role TEXT,
              commit_hash TEXT,
              extra_json TEXT,
              updated_at TEXT
            );
            CREATE TABLE IF NOT EXISTS path_locks (
              path TEXT PRIMARY KEY,
              role_id TEXT NOT NULL,
              task_id TEXT NOT NULL,
              acquired_at TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS manual_acks (
              gate_id TEXT PRIMARY KEY,
              status TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS findings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              body_json TEXT NOT NULL,
              created_at TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS signals (
              subject_id TEXT PRIMARY KEY,
              signal TEXT NOT NULL,
              task_id TEXT,
              reason TEXT,
              updated_at TEXT NOT NULL
            );
            """
        )

    def _empty_dict(self) -> dict[str, Any]:
        ctx = self.ctx
        return {
            "version": 2,
            "apiVersion": "squad-state/v2",
            "wave": 1,
            "signoff_percent": 0,
            "halt": False,
            "assignments": {rid: None for rid in ctx.all_role_ids()},
            "tasks": {},
            "findings": [],
            "manual_acks": {},
            "locks": {},
            "merge_order": ctx.dispatch_cfg.get("merge_order", ctx.worker_roles()),
        }

    def _hydrate_conn(self, conn: sqlite3.Connection, st: dict[str, Any]) -> None:
        for rid in self.ctx.all_role_ids():
            conn.execute(
                "INSERT OR IGNORE INTO assignments(role_id,task_id) VALUES(?,NULL)",
                (rid,),
            )
        meta_keys = ("wave", "halt", "signoff_percent", "merge_order", "last_assess", "halt_reason")
        for k in meta_keys:
            if k in st:
                conn.execute(
                    "INSERT OR REPLACE INTO meta(key,value) VALUES(?,?)",
                    (k, json.dumps(st[k], ensure_ascii=False)),
                )
        for rid, tid in (st.get("assignments") or {}).items():
            conn.execute(
                "INSERT OR REPLACE INTO assignments(role_id,task_id) VALUES(?,?)",
                (rid, tid),
            )
        for tid, spec in (st.get("tasks") or {}).items():
            extra = {
                k: v
                for k, v in spec.items()
                if k not in ("status", "assign_role", "commit", "role")
            }
            conn.execute(
                """INSERT OR REPLACE INTO tasks(task_id,status,assign_role,commit_hash,extra_json,updated_at)
                   VALUES(?,?,?,?,?,?)""",
                (
                    tid,
                    spec.get("status", "pending"),
                    spec.get("assign_role") or spec.get("role"),
                    spec.get("commit"),
                    json.dumps(extra, ensure_ascii=False) if extra else None,
                    spec.get("finished_at") or spec.get("started_at") or _utc_now(),
                ),
            )
        for path, holder in (st.get("locks") or {}).items():
            conn.execute(
                "INSERT OR REPLACE INTO path_locks(path,role_id,task_id,acquired_at) VALUES(?,?,?,?)",
                (path, holder, "", _utc_now()),
            )
        for gid, status in (st.get("manual_acks") or {}).items():
            conn.execute(
                "INSERT OR REPLACE INTO manual_acks(gate_id,status) VALUES(?,?)",
                (gid, status),
            )
        for f in st.get("findings") or []:
            conn.execute(
                "INSERT INTO findings(body_json,created_at) VALUES(?,?)",
                (json.dumps(f, ensure_ascii=False), f.get("at", _utc_now())),
            )

    def _import_json_if_present(self, conn: sqlite3.Connection) -> None:
        jp = self.ctx.state_json_path
        if jp.is_file():
            with jp.open(encoding="utf-8") as f:
                st = json.load(f)
            self._hydrate_conn(conn, st)
        else:
            self._hydrate_conn(conn, self._empty_dict())

    @contextmanager
    def write_tx(self, *, immediate: bool = True) -> Iterator[sqlite3.Connection]:
        delay = BACKOFF_BASE_SEC
        last: Exception | None = None
        for i in range(MAX_RETRY_ATTEMPTS):
            conn = self._connect()
            try:
                if immediate:
                    conn.execute("BEGIN IMMEDIATE")
                else:
                    conn.execute("BEGIN")
                yield conn
                conn.commit()
                conn.close()
                return
            except sqlite3.OperationalError as e:
                conn.rollback()
                conn.close()
                msg = str(e).lower()
                if "locked" not in msg and "busy" not in msg:
                    raise
                last = e
                if i >= MAX_RETRY_ATTEMPTS - 1:
                    break
                time.sleep(min(delay, BACKOFF_MAX_SEC))
                delay = min(delay * 2, BACKOFF_MAX_SEC)
            except Exception:
                conn.rollback()
                conn.close()
                raise
        raise SquadLockError(f"sqlite busy after {MAX_RETRY_ATTEMPTS} retries: {last}")

    def load_snapshot(self) -> dict[str, Any]:
        with self._connect() as conn:
            meta = {
                r["key"]: json.loads(r["value"])
                for r in conn.execute("SELECT key,value FROM meta")
            }
            assignments = {
                r["role_id"]: r["task_id"]
                for r in conn.execute("SELECT role_id,task_id FROM assignments")
            }
            tasks: dict[str, Any] = {}
            for r in conn.execute("SELECT * FROM tasks"):
                extra = json.loads(r["extra_json"]) if r["extra_json"] else {}
                t: dict[str, Any] = {"status": r["status"], "assign_role": r["assign_role"], **extra}
                if r["commit_hash"]:
                    t["commit"] = r["commit_hash"]
                tasks[r["task_id"]] = t
            locks = {
                r["path"]: r["role_id"]
                for r in conn.execute("SELECT path,role_id FROM path_locks")
            }
            manual_acks = {
                r["gate_id"]: r["status"]
                for r in conn.execute("SELECT gate_id,status FROM manual_acks")
            }
            findings = [
                json.loads(r["body_json"])
                for r in conn.execute("SELECT body_json FROM findings ORDER BY id")
            ]
        st = self._empty_dict()
        st.update({k: v for k, v in meta.items() if k in st or k in (
            "wave", "halt", "signoff_percent", "merge_order", "last_assess", "halt_reason",
        )})
        st["assignments"] = assignments
        st["tasks"] = tasks
        st["locks"] = locks
        st["manual_acks"] = manual_acks
        st["findings"] = findings
        st["updated_at"] = _utc_now()
        return st

    def save_snapshot(self, state: dict[str, Any]) -> None:
        with self.write_tx() as conn:
            conn.execute("DELETE FROM meta")
            conn.execute("DELETE FROM assignments")
            conn.execute("DELETE FROM tasks")
            conn.execute("DELETE FROM path_locks")
            conn.execute("DELETE FROM manual_acks")
            conn.execute("DELETE FROM findings")
            self._hydrate_conn(conn, state)

    def set_meta(self, key: str, value: Any) -> None:
        with self.write_tx() as conn:
            conn.execute(
                "INSERT OR REPLACE INTO meta(key,value) VALUES(?,?)",
                (key, json.dumps(value, ensure_ascii=False)),
            )

    def task_status(self, task_id: str) -> str:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT status FROM tasks WHERE task_id=?", (task_id,)
            ).fetchone()
            if row:
                return row["status"]
        return "pending"

    def claim(self, role: str, task_id: str, touch_paths: list[str]) -> None:
        with self.write_tx(immediate=True) as conn:
            cur = conn.execute(
                "SELECT task_id FROM assignments WHERE role_id=?", (role,)
            ).fetchone()
            if cur and cur["task_id"] and cur["task_id"] != task_id:
                raise SquadLockError(f"role {role} busy on {cur['task_id']}")
            for p in touch_paths:
                row = conn.execute(
                    "SELECT role_id FROM path_locks WHERE path=?", (p,)
                ).fetchone()
                if row and row["role_id"] != role:
                    raise SquadLockError(f"{p} locked by {row['role_id']}")
            for p in touch_paths:
                conn.execute(
                    """INSERT OR REPLACE INTO path_locks(path,role_id,task_id,acquired_at)
                       VALUES(?,?,?,?)""",
                    (p, role, task_id, _utc_now()),
                )
            conn.execute(
                "INSERT OR REPLACE INTO assignments(role_id,task_id) VALUES(?,?)",
                (role, task_id),
            )
            conn.execute(
                """INSERT OR REPLACE INTO tasks(task_id,status,assign_role,updated_at)
                   VALUES(?,?,?,?)""",
                (task_id, "in_progress", role, _utc_now()),
            )

    def release_done(self, role: str, task_id: str, commit: str, touch_paths: list[str]) -> None:
        with self.write_tx(immediate=True) as conn:
            cur = conn.execute(
                "SELECT task_id FROM assignments WHERE role_id=?", (role,)
            ).fetchone()
            if not cur or cur["task_id"] != task_id:
                raise SquadLockError(f"role {role} not on {task_id}")
            conn.execute(
                "UPDATE tasks SET status='done', commit_hash=?, updated_at=? WHERE task_id=?",
                (commit, _utc_now(), task_id),
            )
            conn.execute("UPDATE assignments SET task_id=NULL WHERE role_id=?", (role,))
            for p in touch_paths:
                conn.execute(
                    "DELETE FROM path_locks WHERE path=? AND role_id=?",
                    (p, role),
                )

    def dispatch_assign(self, role: str, task_id: str) -> bool:
        with self.write_tx(immediate=True) as conn:
            busy = conn.execute(
                "SELECT task_id FROM assignments WHERE role_id=? AND task_id IS NOT NULL",
                (role,),
            ).fetchone()
            if busy:
                return False
            conn.execute(
                "INSERT OR REPLACE INTO assignments(role_id,task_id) VALUES(?,?)",
                (role, task_id),
            )
            conn.execute(
                """INSERT OR REPLACE INTO tasks(task_id,status,assign_role,updated_at)
                   VALUES(?,?,?,?)""",
                (task_id, "assigned", role, _utc_now()),
            )
            return True

    def add_finding(self, body: dict[str, Any]) -> None:
        with self.write_tx() as conn:
            conn.execute(
                "INSERT INTO findings(body_json,created_at) VALUES(?,?)",
                (json.dumps(body, ensure_ascii=False), body.get("at", _utc_now())),
            )

    def set_manual_ack(self, gate_id: str, status: str) -> None:
        with self.write_tx() as conn:
            conn.execute(
                "INSERT OR REPLACE INTO manual_acks(gate_id,status) VALUES(?,?)",
                (gate_id, status),
            )

    def init_empty(self, *, force: bool = False) -> None:
        if force and self.db_path.is_file():
            self.db_path.unlink()
        with self.write_tx() as conn:
            self._init_schema(conn)
            for t in ("findings", "manual_acks", "path_locks", "tasks", "assignments", "meta"):
                conn.execute(f"DELETE FROM {t}")
            self._hydrate_conn(conn, self._empty_dict())

    def get_meta(self, key: str, default: Any = None) -> Any:
        with self._connect() as conn:
            row = conn.execute("SELECT value FROM meta WHERE key=?", (key,)).fetchone()
            if row:
                return json.loads(row["value"])
        return default

    def set_signal(
        self,
        subject_id: str,
        signal: str,
        *,
        task_id: str | None = None,
        reason: str | None = None,
    ) -> None:
        with self.write_tx() as conn:
            conn.execute(
                """INSERT OR REPLACE INTO signals(subject_id,signal,task_id,reason,updated_at)
                   VALUES(?,?,?,?,?)""",
                (subject_id, signal, task_id, reason, _utc_now()),
            )

    def get_signal(self, subject_id: str) -> dict[str, Any] | None:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT * FROM signals WHERE subject_id=?", (subject_id,)
            ).fetchone()
            if not row:
                return None
            return {
                "subject_id": row["subject_id"],
                "signal": row["signal"],
                "task_id": row["task_id"],
                "reason": row["reason"],
                "updated_at": row["updated_at"],
            }

    def list_signals(self, prefix: str | None = None) -> list[dict[str, Any]]:
        with self._connect() as conn:
            if prefix:
                rows = conn.execute(
                    "SELECT * FROM signals WHERE subject_id LIKE ? ORDER BY subject_id",
                    (prefix + "%",),
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT * FROM signals ORDER BY subject_id"
                ).fetchall()
            return [
                {
                    "subject_id": r["subject_id"],
                    "signal": r["signal"],
                    "task_id": r["task_id"],
                    "reason": r["reason"],
                    "updated_at": r["updated_at"],
                }
                for r in rows
            ]

    def task_set_outcome(
        self,
        role: str,
        task_id: str,
        outcome: str,
        *,
        reason: str | None = None,
        touch_paths: list[str] | None = None,
    ) -> None:
        """Mark task failed|timeout and release role + path locks."""
        if outcome not in ("failed", "timeout"):
            raise ValueError(f"invalid outcome: {outcome}")
        paths = touch_paths or []
        with self.write_tx(immediate=True) as conn:
            cur = conn.execute(
                "SELECT task_id FROM assignments WHERE role_id=?", (role,)
            ).fetchone()
            if cur and cur["task_id"] and cur["task_id"] != task_id:
                raise SquadLockError(f"role {role} on {cur['task_id']}, not {task_id}")
            extra: dict[str, Any] = {"outcome": outcome}
            if reason:
                extra["outcome_reason"] = reason
            extra["finished_at"] = _utc_now()
            conn.execute(
                """UPDATE tasks SET status=?, extra_json=?, updated_at=? WHERE task_id=?""",
                (
                    outcome,
                    json.dumps(extra, ensure_ascii=False),
                    _utc_now(),
                    task_id,
                ),
            )
            conn.execute("UPDATE assignments SET task_id=NULL WHERE role_id=?", (role,))
            for p in paths:
                conn.execute(
                    "DELETE FROM path_locks WHERE path=? AND role_id=?",
                    (p, role),
                )
        self.set_signal(role, outcome, task_id=task_id, reason=reason)

    def export_json(self, path: Path | None = None) -> Path:
        out = path or self.ctx.state_json_path
        snap = self.load_snapshot()
        out.parent.mkdir(parents=True, exist_ok=True)
        with out.open("w", encoding="utf-8") as f:
            json.dump(snap, f, indent=2, ensure_ascii=False)
            f.write("\n")
        return out
