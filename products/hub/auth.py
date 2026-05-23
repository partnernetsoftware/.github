#!/usr/bin/env python3
"""Authentication context for hub MCP requests."""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Optional

from .store import HubStore


@dataclass
class AuthContext:
    user_id: str
    name: str
    token_label: str
    source: str  # "env" | "argument" | "bootstrap"


class AuthManager:
    def __init__(self, store: Optional[HubStore] = None) -> None:
        self.store = store or HubStore()

    def from_token(self, token: str, source: str = "argument") -> Optional[AuthContext]:
        if not token or not token.strip():
            return None
        row = self.store.resolve_token(token.strip())
        if not row:
            return None
        return AuthContext(
            user_id=row["user_id"],
            name=row["name"],
            token_label=row["token_label"],
            source=source,
        )

    def from_env(self) -> Optional[AuthContext]:
        token = os.environ.get("HUB_TOKEN") or os.environ.get("HUB_API_KEY")
        if not token:
            return None
        return self.from_token(token, source="env")

    def require(self, token: Optional[str] = None) -> AuthContext:
        ctx = self.from_token(token) if token else None
        if ctx is None:
            ctx = self.from_env()
        if ctx is None:
            raise PermissionError(
                "Not authenticated. Set HUB_TOKEN env or call hub_login / bootstrap."
            )
        return ctx

    def try_bootstrap(self, bootstrap_key: str, admin_name: str = "admin") -> str:
        """One-time setup when HUB_BOOTSTRAP_KEY matches and no users exist."""
        expected = os.environ.get("HUB_BOOTSTRAP_KEY", "").strip()
        if not expected or bootstrap_key.strip() != expected:
            raise PermissionError("Invalid bootstrap key")
        return self.store.bootstrap_admin(expected, admin_name=admin_name)
