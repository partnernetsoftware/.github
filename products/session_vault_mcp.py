#!/usr/bin/env python3
"""Deprecated entrypoint — use products/mcp_cf_bots_mcp.py and MCP name mcp-cf-bots."""

from __future__ import annotations

import asyncio
import sys

if __name__ == "__main__":
    print(
        "session_vault_mcp.py is deprecated; use mcp_cf_bots_mcp.py (MCP id: mcp-cf-bots)",
        file=sys.stderr,
    )
    from mcp_cf_bots_mcp import _main

    asyncio.run(_main())
