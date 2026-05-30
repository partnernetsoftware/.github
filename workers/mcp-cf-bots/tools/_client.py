"""Shared REST client for mcp-cf-bots Worker (used by tools/*.py)."""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.parse
import urllib.request


def env(primary: str, legacy: str) -> str:
    val = (os.environ.get(primary, "") or os.environ.get(legacy, "")).strip()
    if not val:
        raise RuntimeError(f"{primary} is not set (legacy: {legacy})")
    return val


def base_url() -> str:
    return env("MCP_CF_BOTS_URL", "SESSION_VAULT_URL").rstrip("/")


def bearer_token() -> str:
    return env("MCP_CF_BOTS_TOKEN", "SESSION_VAULT_TOKEN")


def owner() -> str:
    val = (
        os.environ.get("MCP_CF_BOTS_OWNER")
        or os.environ.get("SESSION_VAULT_OWNER")
        or ""
    ).strip()
    if not val:
        raise RuntimeError("MCP_CF_BOTS_OWNER is not set (legacy: SESSION_VAULT_OWNER)")
    return val


def vault_request(
    method: str,
    path: str,
    *,
    body: dict | None = None,
    query: dict | None = None,
) -> dict:
    url = f"{base_url()}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    data = None
    headers = {
        "Authorization": f"Bearer {bearer_token()}",
        "Accept": "application/json",
        "User-Agent": "mcp-cf-bots-client/1.0",
    }
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            text = resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code}: {text}") from exc
    return json.loads(text) if text else {}
