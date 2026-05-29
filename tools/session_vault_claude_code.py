#!/usr/bin/env python3
"""
Persist Claude Code CLI auth across Cloud Agent sessions via session-vault (no new MCP).

SSOT = session-vault only (SESSION_VAULT_URL + SESSION_VAULT_TOKEN).
Do NOT require CLAUDE_CODE_OAUTH_TOKEN in Cloud Agent Secrets.

After one interactive login, capture -> vault. Each new session: restore <- vault.

  # One-time (after claude login or setup-token):
  export SESSION_VAULT_URL SESSION_VAULT_TOKEN SESSION_VAULT_OWNER=cloud-agent
  python3 tools/session_vault_claude_code.py capture

  # Every new Cloud Agent / shell:
  python3 tools/session_vault_claude_code.py restore
  claude -p "continue ..."

Vault keys: site=cli.claude  profile=default  kind=config (bundle) + optional oauth (setup-token)
"""

from __future__ import annotations

import argparse
import json
import os
import stat
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any, Dict, Optional

SITE = "cli.claude"
PROFILE = "default"
BUNDLE_VERSION = 1

CLAUDE_DIR = Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home() / ".claude"))
CREDENTIALS = CLAUDE_DIR / ".credentials.json"
SETTINGS = CLAUDE_DIR / "settings.json"
CLAUDE_JSON = Path.home() / ".claude.json"


def _env(name: str) -> str:
    v = os.environ.get(name, "").strip()
    if not v:
        raise RuntimeError(
            f"{name} is not set. "
            "In Cloud Agent: add to Secrets (same as session-vault MCP). "
            "Locally: export SESSION_VAULT_URL SESSION_VAULT_TOKEN"
        )
    return v


def _owner() -> str:
    return (os.environ.get("SESSION_VAULT_OWNER", "cloud-agent") or "cloud-agent").strip()


def _vault(method: str, path: str, *, body: Optional[dict] = None, query: Optional[dict] = None) -> dict:
    base = _env("SESSION_VAULT_URL").rstrip("/")
    url = f"{base}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    data = None
    headers = {
        "Authorization": f"Bearer {_env('SESSION_VAULT_TOKEN')}",
        "Accept": "application/json",
        "User-Agent": "session-vault-client/1.0",
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


def _read_text(path: Path) -> Optional[str]:
    if not path.is_file():
        return None
    return path.read_text(encoding="utf-8")


def _read_json(path: Path) -> Optional[Any]:
    raw = _read_text(path)
    if raw is None:
        return None
    return json.loads(raw)


def _write_secret(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)


def _session_path() -> str:
    return (
        f"/v1/session/{urllib.parse.quote(SITE, safe='')}"
        f"/{urllib.parse.quote(PROFILE, safe='')}"
    )


def build_bundle() -> Dict[str, Any]:
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
            "nothing to capture: run `claude` login or `claude setup-token`, "
            f"or set CLAUDE_CODE_OAUTH_TOKEN; expected {CREDENTIALS}"
        )

    bundle: Dict[str, Any] = {
        "version": BUNDLE_VERSION,
        "platform": sys.platform,
        "claude_config_dir": str(CLAUDE_DIR),
        "files": files,
    }
    if oauth_token:
        bundle["setup_token_hint"] = (
            "Prefer storing long-lived token via: "
            "python3 tools/session_vault_claude_code.py capture-token --token <sk-ant-oat...>"
        )
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
            "note": "capture-time token snapshot; use capture-token for setup-token",
        }
    out = _vault("PUT", _session_path(), body=body, query={"owner": _owner()})
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
    out = _vault("PUT", _session_path(), body=body, query={"owner": _owner()})
    print(json.dumps({"ok": True, "vault": out, "stored": "oauth.setup_token"}, indent=2))
    print(
        "Token stored in session-vault only. New sessions: restore + print-env (no extra Agent Secret).",
        file=sys.stderr,
    )


def cmd_restore() -> None:
    stored = _vault("GET", _session_path(), query={"owner": _owner()})
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
    export_lines = []
    if isinstance(oauth, dict):
        tok = oauth.get("token")
        if isinstance(tok, str) and tok:
            _write_secret(token_file, tok + "\n")
            os.chmod(token_file, stat.S_IRUSR | stat.S_IWUSR)
            export_lines.append(f'export CLAUDE_CODE_OAUTH_TOKEN="$(cat {token_file})"')
            restored.append("oauth.setup_token")

    if not restored:
        raise RuntimeError("vault entry empty; run capture after login")

    print(json.dumps({"restored": restored}, indent=2))
    if export_lines:
        print("\n".join(export_lines))


def cmd_print_env() -> None:
    stored = _vault("GET", _session_path(), query={"owner": _owner()})
    oauth = stored.get("oauth")
    if isinstance(oauth, dict) and isinstance(oauth.get("token"), str):
        print(f'export CLAUDE_CODE_OAUTH_TOKEN={json.dumps(oauth["token"])}')
        return
    raise RuntimeError("no setup-token in vault; use capture-token after `claude setup-token`")


def cmd_status() -> None:
    try:
        stored = _vault("GET", _session_path(), query={"owner": _owner()})
        meta = stored.get("meta", {})
        has_config = "config" in stored
        has_oauth = "oauth" in stored
        print(json.dumps({"site": SITE, "profile": PROFILE, "has_config": has_config, "has_oauth": has_oauth, "meta": meta}, indent=2))
    except RuntimeError as e:
        print(json.dumps({"site": SITE, "profile": PROFILE, "error": str(e)}, indent=2))


def main() -> None:
    ap = argparse.ArgumentParser(description="Claude Code CLI ↔ session-vault")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("capture", help="Save ~/.claude credentials bundle to vault")
    t = sub.add_parser("capture-token", help="Store claude setup-token in vault oauth")
    t.add_argument("--token", required=True, help="Output of claude setup-token")
    sub.add_parser("restore", help="Restore bundle to ~/.claude from vault")
    sub.add_parser("print-env", help="Print export CLAUDE_CODE_OAUTH_TOKEN=...")
    sub.add_parser("status", help="Check vault entry")
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
