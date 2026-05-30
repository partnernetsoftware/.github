#!/usr/bin/env python3
"""Deprecated — use workers/mcp-cf-bots/tools/browser_cookies.py"""
import runpy
import sys
from pathlib import Path

if __name__ == "__main__":
    print("Moved to workers/mcp-cf-bots/tools/browser_cookies.py", file=sys.stderr)
    target = Path(__file__).resolve().parents[1] / "workers/mcp-cf-bots/tools/browser_cookies.py"
    runpy.run_path(str(target), run_name="__main__")
