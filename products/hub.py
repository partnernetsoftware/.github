#!/usr/bin/env python3
"""
Hub MCP — entry point.

Commands:
  python3 products/hub.py bootstrap   # first-run admin token (needs HUB_BOOTSTRAP_KEY)
  python3 products/hub.py server      # stdio MCP for Cursor / Claude CLI
  python3 products/hub.py serve       # HTTP placeholder (implement in phase 2)

Cursor (stdio, local dev):
  {
    "mcpServers": {
      "hub": {
        "command": "python3",
        "args": ["/workspace/products/hub.py", "server"],
        "env": { "HUB_TOKEN": "hub_..." }
      }
    }
  }
"""

import asyncio
import os
import sys
from pathlib import Path

# Allow running as script from repo root
_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))


def cmd_bootstrap() -> int:
    key = os.environ.get("HUB_BOOTSTRAP_KEY", "").strip()
    if not key:
        print("Set HUB_BOOTSTRAP_KEY before bootstrap", file=sys.stderr)
        return 1
    from products.hub.auth import AuthManager

    auth = AuthManager()
    try:
        token = auth.try_bootstrap(key)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    print(token)
    print("Save as HUB_TOKEN in Cursor Secrets or ~/.cursor/mcp.json env", file=sys.stderr)
    return 0


def cmd_server() -> int:
    from products.hub.server import HubMCPServer

    asyncio.run(HubMCPServer().run_stdio())
    return 0


def cmd_serve() -> int:
    print(
        "HTTP/SSE transport not implemented yet.\n"
        "Deploy plan: FastAPI + MCP Streamable HTTP + Bearer HUB_TOKEN.\n"
        "Use `server` (stdio) for local dev; point Cloud Agent to your host once serve ships.",
        file=sys.stderr,
    )
    return 2


def main() -> int:
    cmd = (sys.argv[1] if len(sys.argv) > 1 else "server").lower()
    handlers = {
        "bootstrap": cmd_bootstrap,
        "server": cmd_server,
        "serve": cmd_serve,
    }
    fn = handlers.get(cmd)
    if not fn:
        print(f"Unknown command: {cmd}. Use: bootstrap | server | serve", file=sys.stderr)
        return 1
    return fn()


if __name__ == "__main__":
    raise SystemExit(main())
