#!/usr/bin/env python3
"""
Session Vault MCP — stdio tools for Cloudflare session-vault Worker.

  claude mcp add session-vault python3 /workspace/products/session_vault_mcp.py server

Env: SESSION_VAULT_URL, SESSION_VAULT_TOKEN, optional SESSION_VAULT_OWNER (default: default)
"""

from __future__ import annotations

import json
import os
import sys
import traceback
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional

KINDS = ("oauth", "cookies", "storage_state", "config")


def _meta_from_args(args: Dict[str, Any]) -> Dict[str, Any]:
    meta: Dict[str, Any] = {}
    for key in ("expires_at", "label", "source", "notes"):
        val = args.get(key)
        if isinstance(val, str) and val:
            meta[key] = val
    tags = args.get("tags")
    if isinstance(tags, list):
        meta["tags"] = [str(t) for t in tags]
    return meta


def _base_url() -> str:
    url = os.environ.get("SESSION_VAULT_URL", "").strip().rstrip("/")
    if not url:
        raise RuntimeError("SESSION_VAULT_URL is not set")
    return url


def _vault_token() -> str:
    token = os.environ.get("SESSION_VAULT_TOKEN", "").strip()
    if not token:
        raise RuntimeError("SESSION_VAULT_TOKEN is not set")
    return token


def _default_owner() -> str:
    return (os.environ.get("SESSION_VAULT_OWNER", "default") or "default").strip() or "default"


def _resolve_owner(args: Dict[str, Any]) -> str:
    owner = str(args.get("owner", "")).strip()
    return owner or _default_owner()


def _session_path(site: str, profile: str) -> str:
    return (
        f"/v1/session/{urllib.parse.quote(site, safe='')}"
        f"/{urllib.parse.quote(profile, safe='')}"
    )


def _vault_fetch(
    method: str,
    path: str,
    *,
    body: Optional[Dict[str, Any]] = None,
    query: Optional[Dict[str, str]] = None,
) -> Any:
    url = f"{_base_url()}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"

    data = None
    headers = {
        "Authorization": f"Bearer {_vault_token()}",
        "Accept": "application/json",
    }
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            text = resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace")
        try:
            parsed = json.loads(text) if text else {}
        except json.JSONDecodeError:
            parsed = {"raw": text}
        err = parsed.get("error", exc.reason) if isinstance(parsed, dict) else exc.reason
        raise RuntimeError(f"HTTP {exc.code}: {err}") from exc

    if not text:
        return {}
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return {"raw": text}


def _tool_browser_session_save(args: Dict[str, Any]) -> str:
    body: Dict[str, Any] = {}
    for key in ("storage_state", "oauth", "cookies", "config"):
        if key in args and args[key] is not None:
            body[key] = args[key]
    meta = _meta_from_args(args)
    if not meta.get("source"):
        meta["source"] = "browser-use"
    if meta:
        body["meta"] = meta
    if len(body) <= (1 if "meta" in body else 0):
        raise ValueError("provide at least one of storage_state, oauth, cookies, config")
    result = _vault_fetch(
        "PUT",
        _session_path(str(args["site"]), str(args["profile"])),
        body=body,
        query={"owner": _resolve_owner(args)},
    )
    return json.dumps(result, indent=2, ensure_ascii=False)


def _tool_browser_session_load(args: Dict[str, Any]) -> str:
    result = _vault_fetch(
        "GET",
        _session_path(str(args["site"]), str(args["profile"])),
        query={"owner": _resolve_owner(args)},
    )
    if not args.get("include_oauth") and not args.get("include_cookies") and not args.get("include_config"):
        slim = {"meta": result.get("meta")}
        if "storage_state" in result:
            slim["storage_state"] = result["storage_state"]
        return json.dumps(slim, indent=2, ensure_ascii=False)
    return json.dumps(result, indent=2, ensure_ascii=False)


def _tool_session_meta(args: Dict[str, Any]) -> str:
    owner = _resolve_owner(args)
    url = f"{_session_path(str(args['site']), str(args['profile']))}?{urllib.parse.urlencode({'owner': owner, 'meta_only': '1'})}"
    req = urllib.request.Request(
        f"{_base_url()}{url}",
        headers={
            "Authorization": f"Bearer {_vault_token()}",
            "Accept": "application/json",
        },
        method="GET",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.dumps(json.loads(resp.read().decode()), indent=2, ensure_ascii=False)


def _tool_session_put(args: Dict[str, Any]) -> str:
    kind = str(args.get("kind", ""))
    if kind not in KINDS:
        raise ValueError(f"invalid kind: {kind}")
    body: Dict[str, Any] = {kind: args.get("data")}
    meta = _meta_from_args(args)
    if meta:
        body["meta"] = meta
    result = _vault_fetch(
        "PUT",
        _session_path(str(args["site"]), str(args["profile"])),
        body=body,
        query={"owner": _resolve_owner(args)},
    )
    return json.dumps(result, indent=2, ensure_ascii=False)


def _tool_session_get(args: Dict[str, Any]) -> str:
    query: Dict[str, str] = {"owner": _resolve_owner(args)}
    kind = args.get("kind")
    if isinstance(kind, str) and kind:
        query["kind"] = kind
    result = _vault_fetch(
        "GET",
        _session_path(str(args["site"]), str(args["profile"])),
        query=query,
    )
    return json.dumps(result, indent=2, ensure_ascii=False)


def _tool_session_delete(args: Dict[str, Any]) -> str:
    result = _vault_fetch(
        "DELETE",
        _session_path(str(args["site"]), str(args["profile"])),
        query={"owner": _resolve_owner(args)},
    )
    return json.dumps(result, indent=2, ensure_ascii=False)


def _tool_session_list(args: Dict[str, Any]) -> str:
    query: Dict[str, str] = {"owner": _resolve_owner(args)}
    if isinstance(args.get("source"), str) and args["source"]:
        query["source"] = args["source"]
    if isinstance(args.get("tag"), str) and args["tag"]:
        query["tag"] = args["tag"]
    result = _vault_fetch("GET", "/v1/sessions", query=query)
    return json.dumps(result, indent=2, ensure_ascii=False)


TOOLS: List[Dict[str, Any]] = [
    {
        "name": "browser_session_save",
        "description": "Save browser-use session for cross-agent reuse",
        "required": ["site", "profile"],
        "properties": {
            "site": {"type": "string"},
            "profile": {"type": "string"},
            "storage_state": {"description": "Playwright storageState"},
            "oauth": {"description": "OAuth JSON"},
            "cookies": {"description": "Cookie list JSON"},
            "config": {"description": "browser-use agent config JSON"},
            "label": {"type": "string"},
            "source": {"type": "string"},
            "tags": {"type": "array", "items": {"type": "string"}},
            "notes": {"type": "string"},
            "expires_at": {"type": "string"},
            "owner": {"type": "string"},
        },
        "handler": _tool_browser_session_save,
    },
    {
        "name": "browser_session_load",
        "description": "Load browser-use session (storage_state + optional fields)",
        "required": ["site", "profile"],
        "properties": {
            "site": {"type": "string"},
            "profile": {"type": "string"},
            "include_oauth": {"type": "boolean"},
            "include_cookies": {"type": "boolean"},
            "include_config": {"type": "boolean"},
            "owner": {"type": "string"},
        },
        "handler": _tool_browser_session_load,
    },
    {
        "name": "session_meta",
        "description": "Read session metadata (label, tags, expiry) only",
        "required": ["site", "profile"],
        "properties": {
            "site": {"type": "string"},
            "profile": {"type": "string"},
            "owner": {"type": "string"},
        },
        "handler": _tool_session_meta,
    },
    {
        "name": "session_put",
        "description": "Store oauth, cookies, or Playwright storage_state for site/profile",
        "required": ["site", "profile", "kind", "data"],
        "properties": {
            "site": {"type": "string", "description": "Site key (e.g. claude.ai)"},
            "profile": {"type": "string", "description": "Profile name"},
            "kind": {"type": "string", "enum": list(KINDS)},
            "data": {"description": "JSON-serializable session payload"},
            "owner": {"type": "string", "description": "Owner namespace"},
            "label": {"type": "string"},
            "source": {"type": "string"},
            "tags": {"type": "array", "items": {"type": "string"}},
            "notes": {"type": "string"},
            "expires_at": {"type": "string", "description": "Optional ISO8601 expiry"},
        },
        "handler": _tool_session_put,
    },
    {
        "name": "session_get",
        "description": "Read stored session fields (optional single kind)",
        "required": ["site", "profile"],
        "properties": {
            "site": {"type": "string"},
            "profile": {"type": "string"},
            "kind": {"type": "string", "enum": list(KINDS)},
            "owner": {"type": "string"},
        },
        "handler": _tool_session_get,
    },
    {
        "name": "session_delete",
        "description": "Delete all encrypted session data for site/profile",
        "required": ["site", "profile"],
        "properties": {
            "site": {"type": "string"},
            "profile": {"type": "string"},
            "owner": {"type": "string"},
        },
        "handler": _tool_session_delete,
    },
    {
        "name": "session_list",
        "description": "List known site/profile entries (Registry DO index)",
        "required": [],
        "properties": {
            "owner": {"type": "string", "description": "Owner namespace"},
            "source": {"type": "string"},
            "tag": {"type": "string"},
        },
        "handler": _tool_session_list,
    },
]

TOOL_MAP = {t["name"]: t for t in TOOLS}


class SessionVaultMCPServer:
    server_info = {
        "name": "session-vault-mcp",
        "version": "0.3.0",
        "description": "Cross-agent OAuth / browser-use vault (Cloudflare DO)",
    }

    @staticmethod
    def _ok(request_id: Any, result: Any) -> Dict[str, Any]:
        return {"jsonrpc": "2.0", "id": request_id, "result": result}

    @staticmethod
    def _err(request_id: Any, code: int, message: str) -> Dict[str, Any]:
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "error": {"code": code, "message": message},
        }

    async def handle_request(self, request: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        method = request.get("method")
        params = request.get("params") or {}
        request_id = request.get("id")

        if method == "initialize":
            return self._ok(
                request_id,
                {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {"tools": {}},
                    "serverInfo": self.server_info,
                },
            )
        if method == "initialized":
            return None

        if method == "tools/list":
            return self._ok(
                request_id,
                {
                    "tools": [
                        {
                            "name": t["name"],
                            "description": t["description"],
                            "inputSchema": {
                                "type": "object",
                                "properties": t["properties"],
                                "required": t["required"],
                            },
                        }
                        for t in TOOLS
                    ]
                },
            )

        if method == "tools/call":
            name = str(params.get("name", ""))
            arguments = params.get("arguments") or {}
            tool = TOOL_MAP.get(name)
            if not tool:
                return self._err(request_id, -32602, f"Unknown tool: {name}")
            try:
                text = tool["handler"](arguments)
                return self._ok(request_id, {"content": [{"type": "text", "text": text}]})
            except Exception as exc:
                return self._ok(
                    request_id,
                    {"content": [{"type": "text", "text": f"Error: {exc}"}]},
                )

        return self._err(request_id, -32601, f"Method not found: {method}")

    async def run_stdio(self) -> None:
        print("Session Vault MCP started (stdio, python)", file=sys.stderr)
        while True:
            line = sys.stdin.readline()
            if not line:
                break
            line = line.strip()
            if not line:
                continue
            try:
                request = json.loads(line)
            except json.JSONDecodeError:
                continue
            try:
                response = await self.handle_request(request)
            except Exception:
                traceback.print_exc(file=sys.stderr)
                continue
            if response is not None:
                print(json.dumps(response, ensure_ascii=False), flush=True)


async def _main() -> None:
    import asyncio

    if len(sys.argv) < 2 or sys.argv[1] != "server":
        print("Usage: python3 session_vault_mcp.py server", file=sys.stderr)
        sys.exit(1)
    await SessionVaultMCPServer().run_stdio()


if __name__ == "__main__":
    import asyncio

    asyncio.run(_main())
