#!/usr/bin/env python3
"""
Claude Code CLI ↔ mcp-cf-bots Worker REST.

  python3 workers/mcp-cf-bots/tools/claude_code.py capture
  python3 workers/mcp-cf-bots/tools/claude_code.py restore
"""

from __future__ import annotations

import argparse
import json
import os
import stat
import sys
import urllib.parse
from pathlib import Path
from typing import Any, Dict, Optional

from _client import owner, vault_request

SITE = "cli.claude"
PROFILE = "default"
BUNDLE_VERSION = 1

CLAUDE_DIR = Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home() / ".claude"))
CREDENTIALS = CLAUDE_DIR / ".credentials.json"
SETTINGS = CLAUDE_DIR / "settings.json"
CLAUDE_JSON = Path.home() / ".claude.json"


def _session_path() -> str:
    return (
        f"/v1/session/{urllib.parse.quote(SITE, safe='')}"
        f"/{urllib.parse.quote(PROFILE, safe='')}"
    )


def _read_json(path: Path) -> Optional[Any]:
    if not path.is_file():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def _write_secret(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)


def build_bundle() -> tuple[Dict[str, Any], str]:
    files: Dict[str, Any] = {}
    creds = _read_json(CREDENTIALS)
    if creds is not None:
        files[".credentials.json"] = creds
    settings = _read_json(SETTINGS)
    if settings is not None:
        files["settings.json"] = settings
    root_json = _read_json(CLAUDE_JSON)
    if root_json is not None:
        files[".claude.json"] = root_json

    oauth_token = os.environ.get("CLAUDE_CODE_OAUTH_TOKEN", "").strip()
    if not oauth_token and creds and isinstance(creds, dict):
        oauth_token = str(creds.get("claudeAiOauth", {}).get("accessToken", "") or "").strip()

    if not files and not oauth_token:
        raise RuntimeError(
            "nothing to capture: run `claude` login or `claude setup-token`; "
            f"expected {CREDENTIALS}"
        )

    bundle: Dict[str, Any] = {
        "version": BUNDLE_VERSION,
        "platform": sys.platform,
        "claude_config_dir": str(CLAUDE_DIR),
        "files": files,
    }
    return bundle, oauth_token


def cmd_capture() -> None:
    bundle, oauth_token = build_bundle()
    body: Dict[str, Any] = {
        "config": bundle,
        "meta": {
            "source": "claude-code-cli",
            "label": "Claude Code CLI auth bundle",
            "tags": ["claude-code", "cli"],
        },
    }
    if oauth_token:
        body["oauth"] = {
            "type": "claude_code_oauth",
            "token_env": "CLAUDE_CODE_OAUTH_TOKEN",
        }
    out = vault_request("PUT", _session_path(), body=body, query={"owner": owner()})
    print(json.dumps({"ok": True, "vault": out, "files": list(bundle.get("files", {}).keys())}, indent=2))


def cmd_capture_token(token: str) -> None:
    token = token.strip()
    if not token:
        raise RuntimeError("empty token")
    body = {
        "oauth": {"type": "claude_code_setup_token", "token": token},
        "meta": {
            "source": "claude-code-cli",
            "label": "claude setup-token",
            "tags": ["claude-code", "setup-token"],
        },
    }
    out = vault_request("PUT", _session_path(), body=body, query={"owner": owner()})
    print(json.dumps({"ok": True, "vault": out}, indent=2))


def cmd_restore() -> None:
    stored = vault_request("GET", _session_path(), query={"owner": owner()})
    config = stored.get("config")
    oauth = stored.get("oauth")
    restored = []

    if isinstance(config, dict) and isinstance(config.get("files"), dict):
        target_dir = Path(config.get("claude_config_dir", str(CLAUDE_DIR)))
        for name, data in config["files"].items():
            if name == ".credentials.json":
                dest = target_dir / ".credentials.json"
            elif name == "settings.json":
                dest = target_dir / "settings.json"
            elif name == ".claude.json":
                dest = CLAUDE_JSON
            else:
                dest = target_dir / name
            _write_secret(dest, json.dumps(data, indent=2) if not isinstance(data, str) else data)
            restored.append(str(dest))

    token_file = Path(os.environ.get("CLAUDE_CODE_TOKEN_FILE", Path.home() / ".claude-setup-token"))
    if isinstance(oauth, dict) and isinstance(oauth.get("token"), str):
        _write_secret(token_file, oauth["token"] + "\n")
        os.chmod(token_file, stat.S_IRUSR | stat.S_IWUSR)
        print(f'export CLAUDE_CODE_OAUTH_TOKEN="$(cat {token_file})"')
        restored.append("oauth.setup_token")

    if not restored:
        raise RuntimeError("vault entry empty; run capture after login")
    print(json.dumps({"restored": restored}, indent=2))


def cmd_print_env() -> None:
    stored = vault_request("GET", _session_path(), query={"owner": owner()})
    oauth = stored.get("oauth")
    if isinstance(oauth, dict) and isinstance(oauth.get("token"), str):
        print(f'export CLAUDE_CODE_OAUTH_TOKEN={json.dumps(oauth["token"])}')
        return
    raise RuntimeError("no setup-token in vault")


def cmd_status() -> None:
    try:
        stored = vault_request("GET", _session_path(), query={"owner": owner()})
        print(
            json.dumps(
                {
                    "site": SITE,
                    "profile": PROFILE,
                    "has_config": "config" in stored,
                    "has_oauth": "oauth" in stored,
                    "meta": stored.get("meta"),
                },
                indent=2,
            )
        )
    except RuntimeError as e:
        print(json.dumps({"site": SITE, "profile": PROFILE, "error": str(e)}, indent=2))


def main() -> None:
    ap = argparse.ArgumentParser(description="Claude Code CLI ↔ mcp-cf-bots")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("capture")
    t = sub.add_parser("capture-token")
    t.add_argument("--token", required=True)
    sub.add_parser("restore")
    sub.add_parser("print-env")
    sub.add_parser("status")
    args = ap.parse_args()
    if args.cmd == "capture":
        cmd_capture()
    elif args.cmd == "capture-token":
        cmd_capture_token(args.token)
    elif args.cmd == "restore":
        cmd_restore()
    elif args.cmd == "print-env":
        cmd_print_env()
    else:
        cmd_status()


if __name__ == "__main__":
    main()
