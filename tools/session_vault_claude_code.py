#!/usr/bin/env python3
"""Deprecated — use workers/mcp-cf-bots/tools/claude_code.py"""
import runpy
import sys
from pathlib import Path

if __name__ == "__main__":
    print("Moved to workers/mcp-cf-bots/tools/claude_code.py", file=sys.stderr)
    target = Path(__file__).resolve().parents[1] / "workers/mcp-cf-bots/tools/claude_code.py"
    runpy.run_path(str(target), run_name="__main__")
