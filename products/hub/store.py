#!/usr/bin/env python3
"""Persistent store for hub users, tokens, config, and provider credentials."""

from __future__ import annotations

import hashlib
import json
import secrets
import threading
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

import duckdb


def _utcnow() -> str:
    return datetime.now(timezone.utc).isoformat()


def _hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


class HubStore:
    """DuckDB-backed store; default data dir ~/.hub (override with HUB_DATA_DIR)."""

    _instance: Optional["HubStore"] = None
    _lock = threading.Lock()

    def __new__(cls, base_path: Optional[Path] = None) -> "HubStore":
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self, base_path: Optional[Path] = None) -> None:
        if getattr(self, "_initialized", False):
            return
        import os

        env_path = os.environ.get("HUB_DATA_DIR")
        self.base_path = base_path or (
            Path(env_path) if env_path else Path.home() / ".hub"
        )
        self.base_path.mkdir(parents=True, exist_ok=True)
        db_path = self.base_path / "hub.db"
        self._conn = duckdb.connect(str(db_path))
        self._create_tables()
        self._initialized = True

    def _create_tables(self) -> None:
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS api_tokens (
                token_hash TEXT PRIMARY KEY,
                user_id TEXT NOT NULL,
                label TEXT,
                created_at TEXT NOT NULL,
                revoked INTEGER DEFAULT 0
            )
            """
        )
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS config (
                user_id TEXT NOT NULL,
                namespace TEXT NOT NULL,
                key TEXT NOT NULL,
                value_json TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                PRIMARY KEY (user_id, namespace, key)
            )
            """
        )
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS credentials (
                user_id TEXT NOT NULL,
                provider TEXT NOT NULL,
                name TEXT NOT NULL,
                secret TEXT NOT NULL,
                meta_json TEXT,
                updated_at TEXT NOT NULL,
                PRIMARY KEY (user_id, provider, name)
            )
            """
        )

    def user_count(self) -> int:
        row = self._conn.execute("SELECT COUNT(*) FROM users").fetchone()
        return int(row[0]) if row else 0

    def create_user(self, name: str, user_id: Optional[str] = None) -> Dict[str, str]:
        uid = user_id or secrets.token_hex(8)
        self._conn.execute(
            "INSERT INTO users (id, name, created_at) VALUES (?, ?, ?)",
            [uid, name, _utcnow()],
        )
        return {"id": uid, "name": name}

    def issue_token(self, user_id: str, label: str = "default") -> str:
        token = f"hub_{secrets.token_urlsafe(32)}"
        self._conn.execute(
            """
            INSERT INTO api_tokens (token_hash, user_id, label, created_at)
            VALUES (?, ?, ?, ?)
            """,
            [_hash_token(token), user_id, label, _utcnow()],
        )
        return token

    def resolve_token(self, token: str) -> Optional[Dict[str, str]]:
        row = self._conn.execute(
            """
            SELECT u.id, u.name, t.label
            FROM api_tokens t
            JOIN users u ON u.id = t.user_id
            WHERE t.token_hash = ? AND t.revoked = 0
            """,
            [_hash_token(token)],
        ).fetchone()
        if not row:
            return None
        return {"user_id": row[0], "name": row[1], "token_label": row[2]}

    def bootstrap_admin(self, bootstrap_key: str, admin_name: str = "admin") -> str:
        """First-run: create admin user and return a long-lived API token."""
        if self.user_count() > 0:
            raise RuntimeError("Hub already bootstrapped; use login with an existing token")
        user = self.create_user(admin_name)
        token = self.issue_token(user["id"], label="bootstrap")
        self.config_set(user["id"], "_system", "bootstrap_key_hash", _hash_token(bootstrap_key))
        return token

    def config_get(self, user_id: str, namespace: str, key: str) -> Optional[Any]:
        row = self._conn.execute(
            """
            SELECT value_json FROM config
            WHERE user_id = ? AND namespace = ? AND key = ?
            """,
            [user_id, namespace, key],
        ).fetchone()
        if not row:
            return None
        return json.loads(row[0])

    def config_set(self, user_id: str, namespace: str, key: str, value: Any) -> None:
        self._conn.execute(
            """
            INSERT INTO config (user_id, namespace, key, value_json, updated_at)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT (user_id, namespace, key) DO UPDATE SET
                value_json = excluded.value_json,
                updated_at = excluded.updated_at
            """,
            [user_id, namespace, key, json.dumps(value, ensure_ascii=False), _utcnow()],
        )

    def config_list(self, user_id: str, namespace: Optional[str] = None) -> List[Dict[str, Any]]:
        if namespace:
            rows = self._conn.execute(
                """
                SELECT namespace, key, value_json, updated_at FROM config
                WHERE user_id = ? AND namespace = ?
                ORDER BY namespace, key
                """,
                [user_id, namespace],
            ).fetchall()
        else:
            rows = self._conn.execute(
                """
                SELECT namespace, key, value_json, updated_at FROM config
                WHERE user_id = ? AND NOT starts_with(namespace, '_')
                ORDER BY namespace, key
                """,
                [user_id],
            ).fetchall()
        return [
            {
                "namespace": r[0],
                "key": r[1],
                "value": json.loads(r[2]),
                "updated_at": r[3],
            }
            for r in rows
        ]

    def credential_set(
        self,
        user_id: str,
        provider: str,
        name: str,
        secret: str,
        meta: Optional[Dict[str, Any]] = None,
    ) -> None:
        self._conn.execute(
            """
            INSERT INTO credentials (user_id, provider, name, secret, meta_json, updated_at)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT (user_id, provider, name) DO UPDATE SET
                secret = excluded.secret,
                meta_json = excluded.meta_json,
                updated_at = excluded.updated_at
            """,
            [
                user_id,
                provider,
                name,
                secret,
                json.dumps(meta or {}, ensure_ascii=False),
                _utcnow(),
            ],
        )

    def credential_get(self, user_id: str, provider: str, name: str) -> Optional[Dict[str, Any]]:
        row = self._conn.execute(
            """
            SELECT secret, meta_json, updated_at FROM credentials
            WHERE user_id = ? AND provider = ? AND name = ?
            """,
            [user_id, provider, name],
        ).fetchone()
        if not row:
            return None
        return {
            "provider": provider,
            "name": name,
            "secret": row[0],
            "meta": json.loads(row[1] or "{}"),
            "updated_at": row[2],
        }

    def credential_list(self, user_id: str, provider: Optional[str] = None) -> List[Dict[str, str]]:
        if provider:
            rows = self._conn.execute(
                """
                SELECT provider, name, updated_at FROM credentials
                WHERE user_id = ? AND provider = ?
                ORDER BY provider, name
                """,
                [user_id, provider],
            ).fetchall()
        else:
            rows = self._conn.execute(
                """
                SELECT provider, name, updated_at FROM credentials
                WHERE user_id = ?
                ORDER BY provider, name
                """,
                [user_id],
            ).fetchall()
        return [{"provider": r[0], "name": r[1], "updated_at": r[2]} for r in rows]
