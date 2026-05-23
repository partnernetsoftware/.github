#!/usr/bin/env python3
"""
Hub MCP Server — login, config, and credential vault for multi-client access.

Deploy on your server as HTTP/SSE (phase 2); develop locally via stdio:

  HUB_BOOTSTRAP_KEY=dev-secret python3 products/hub.py bootstrap
  HUB_TOKEN=<printed-token> python3 products/hub.py server

Cursor mcp.json (remote, after HTTP deploy):

  {
    "mcpServers": {
      "hub": {
        "url": "https://your.host/mcp",
        "headers": { "Authorization": "Bearer ${env:HUB_TOKEN}" }
      }
    }
  }
"""

from __future__ import annotations

import asyncio
import json
import os
import sys
import traceback
from typing import Any, Dict, Optional

from products.mcp_core import MCPTool

from .auth import AuthManager
from .store import HubStore


class HubMCPServer:
    def __init__(self) -> None:
        self.server_info = {
            "name": "hub-mcp",
            "version": "0.1.0",
            "description": "Self-hosted hub: login, config, credentials for Cursor/Cloud Agent",
        }
        self.store = HubStore()
        self.auth = AuthManager(self.store)
        self.tools = self._register_tools()

    def _register_tools(self) -> Dict[str, MCPTool]:
        return {
            "hub_whoami": MCPTool(
                name="hub_whoami",
                description="Show current authenticated user (from HUB_TOKEN or token argument)",
                parameters={
                    "token": {
                        "type": "string",
                        "description": "Optional API token; defaults to HUB_TOKEN env",
                    }
                },
                handler=self._whoami,
                annotations={"readOnlyHint": True},
            ),
            "hub_login": MCPTool(
                name="hub_login",
                description="Validate an API token and return user identity",
                parameters={
                    "token": {
                        "type": "string",
                        "description": "Hub API token (hub_...)",
                    }
                },
                handler=self._login,
                annotations={"readOnlyHint": True},
            ),
            "hub_bootstrap": MCPTool(
                name="hub_bootstrap",
                description="First-run: create admin user when HUB_BOOTSTRAP_KEY is set and store is empty",
                parameters={
                    "bootstrap_key": {
                        "type": "string",
                        "description": "Must match server HUB_BOOTSTRAP_KEY",
                    },
                    "admin_name": {
                        "type": "string",
                        "description": "Display name for the admin user",
                    },
                },
                handler=self._bootstrap,
            ),
            "hub_config_get": MCPTool(
                name="hub_config_get",
                description="Get a config value in a namespace for the authenticated user",
                parameters={
                    "namespace": {"type": "string", "description": "Config namespace, e.g. cloudflare"},
                    "key": {"type": "string", "description": "Config key"},
                    "token": {"type": "string", "description": "Optional API token"},
                },
                handler=self._config_get,
                annotations={"readOnlyHint": True},
            ),
            "hub_config_set": MCPTool(
                name="hub_config_set",
                description="Set a config value (JSON-serializable) for the authenticated user",
                parameters={
                    "namespace": {"type": "string", "description": "Config namespace"},
                    "key": {"type": "string", "description": "Config key"},
                    "value": {"type": "string", "description": "JSON string value"},
                    "token": {"type": "string", "description": "Optional API token"},
                },
                handler=self._config_set,
            ),
            "hub_config_list": MCPTool(
                name="hub_config_list",
                description="List config entries for the authenticated user",
                parameters={
                    "namespace": {
                        "type": "string",
                        "description": "Optional namespace filter",
                    },
                    "token": {"type": "string", "description": "Optional API token"},
                },
                handler=self._config_list,
                annotations={"readOnlyHint": True},
            ),
            "hub_credential_set": MCPTool(
                name="hub_credential_set",
                description="Store a provider secret (e.g. cloudflare API token) for the authenticated user",
                parameters={
                    "provider": {"type": "string", "description": "Provider id, e.g. cloudflare"},
                    "name": {"type": "string", "description": "Credential name within provider"},
                    "secret": {"type": "string", "description": "Secret value"},
                    "meta": {
                        "type": "string",
                        "description": "Optional JSON metadata",
                    },
                    "token": {"type": "string", "description": "Optional API token"},
                },
                handler=self._credential_set,
            ),
            "hub_credential_list": MCPTool(
                name="hub_credential_list",
                description="List stored credentials (names only, no secrets)",
                parameters={
                    "provider": {
                        "type": "string",
                        "description": "Optional provider filter",
                    },
                    "token": {"type": "string", "description": "Optional API token"},
                },
                handler=self._credential_list,
                annotations={"readOnlyHint": True},
            ),
        }

    async def _whoami(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        return json.dumps(
            {
                "user_id": ctx.user_id,
                "name": ctx.name,
                "token_label": ctx.token_label,
                "source": ctx.source,
            },
            ensure_ascii=False,
            indent=2,
        )

    async def _login(self, args: Dict[str, Any]) -> str:
        token = args.get("token", "")
        ctx = self.auth.from_token(token)
        if not ctx:
            return json.dumps({"ok": False, "error": "invalid token"}, ensure_ascii=False)
        return json.dumps(
            {
                "ok": True,
                "user_id": ctx.user_id,
                "name": ctx.name,
                "token_label": ctx.token_label,
            },
            ensure_ascii=False,
            indent=2,
        )

    async def _bootstrap(self, args: Dict[str, Any]) -> str:
        key = args.get("bootstrap_key", "")
        admin_name = args.get("admin_name") or "admin"
        try:
            api_token = self.auth.try_bootstrap(key, admin_name=admin_name)
        except PermissionError as exc:
            return json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False)
        return json.dumps(
            {
                "ok": True,
                "message": "Hub bootstrapped. Save this token as HUB_TOKEN in Cursor Secrets.",
                "api_token": api_token,
                "admin_name": admin_name,
            },
            ensure_ascii=False,
            indent=2,
        )

    async def _config_get(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        ns, key = args.get("namespace", ""), args.get("key", "")
        val = self.store.config_get(ctx.user_id, ns, key)
        return json.dumps({"namespace": ns, "key": key, "value": val}, ensure_ascii=False, indent=2)

    async def _config_set(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        ns, key = args.get("namespace", ""), args.get("key", "")
        raw = args.get("value", "{}")
        try:
            value = json.loads(raw) if isinstance(raw, str) else raw
        except json.JSONDecodeError as exc:
            return json.dumps({"ok": False, "error": f"invalid JSON: {exc}"}, ensure_ascii=False)
        self.store.config_set(ctx.user_id, ns, key, value)
        return json.dumps({"ok": True, "namespace": ns, "key": key}, ensure_ascii=False)

    async def _config_list(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        ns = args.get("namespace") or None
        items = self.store.config_list(ctx.user_id, ns)
        return json.dumps({"items": items}, ensure_ascii=False, indent=2)

    async def _credential_set(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        meta_raw = args.get("meta") or "{}"
        try:
            meta = json.loads(meta_raw) if isinstance(meta_raw, str) else meta_raw
        except json.JSONDecodeError:
            meta = {}
        self.store.credential_set(
            ctx.user_id,
            args.get("provider", ""),
            args.get("name", "default"),
            args.get("secret", ""),
            meta=meta,
        )
        return json.dumps(
            {"ok": True, "provider": args.get("provider"), "name": args.get("name")},
            ensure_ascii=False,
        )

    async def _credential_list(self, args: Dict[str, Any]) -> str:
        ctx = self.auth.require(args.get("token"))
        provider = args.get("provider") or None
        items = self.store.credential_list(ctx.user_id, provider)
        return json.dumps({"credentials": items}, ensure_ascii=False, indent=2)

    def _create_response(self, request_id: Any, result: Any) -> Dict[str, Any]:
        return {"jsonrpc": "2.0", "id": request_id, "result": result}

    def _create_error(self, request_id: Any, code: int, message: str) -> Dict[str, Any]:
        return {"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}}

    async def handle_request(self, request: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        method = request.get("method")
        params = request.get("params", {})
        request_id = request.get("id")

        handlers = {
            "initialize": self._handle_initialize,
            "initialized": lambda *_: None,
            "tools/list": self._handle_list_tools,
            "tools/call": self._handle_tool_call,
        }
        handler = handlers.get(method)
        if not handler:
            return self._create_error(request_id, -32601, f"Method not found: {method}")
        try:
            return await handler(request_id, params) if asyncio.iscoroutinefunction(handler) else handler(
                request_id, params
            )
        except Exception as exc:
            traceback.print_exc()
            return self._create_error(request_id, -32603, f"Internal error: {exc}")

    def _handle_initialize(self, request_id: Any, params: Dict[str, Any]) -> Dict[str, Any]:
        return self._create_response(
            request_id,
            {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": self.server_info,
            },
        )

    def _handle_list_tools(self, request_id: Any, params: Dict[str, Any]) -> Dict[str, Any]:
        return self._create_response(
            request_id, {"tools": [t.to_dict() for t in self.tools.values()]}
        )

    async def _handle_tool_call(self, request_id: Any, params: Dict[str, Any]) -> Dict[str, Any]:
        tool_name = params.get("name")
        arguments = params.get("arguments", {})
        tool = self.tools.get(tool_name)
        if not tool:
            return self._create_error(request_id, -32602, f"Unknown tool: {tool_name}")
        try:
            result = await tool.execute(arguments)
        except PermissionError as exc:
            result = json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False)
        return self._create_response(
            request_id, {"content": [{"type": "text", "text": result}]}
        )

    async def run_stdio(self) -> None:
        print("Hub MCP started (stdio)", file=sys.stderr)
        while True:
            line = await asyncio.get_event_loop().run_in_executor(None, sys.stdin.readline)
            if not line:
                break
            line = line.strip()
            if not line:
                continue
            try:
                request = json.loads(line)
                response = await self.handle_request(request)
                if response is not None:
                    print(json.dumps(response), flush=True)
            except json.JSONDecodeError:
                continue
