#!/usr/bin/env python3
"""
Capture / apply browser cookies via Playwright + session-vault REST API.

  # After login in headed browser, save (includes HttpOnly via CDP):
  python3 tools/session_vault_browser_cookies.py capture \
    --url https://claude.ai/code --site claude.ai --profile code

  # Later, inject cookies and open (cross-session reuse):
  python3 tools/session_vault_browser_cookies.py apply \
    --url https://claude.ai/code --site claude.ai --profile code

Env: SESSION_VAULT_URL, SESSION_VAULT_TOKEN, optional SESSION_VAULT_OWNER
Requires: pip install playwright && playwright install chromium
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


def _env(name: str) -> str:
    v = os.environ.get(name, "").strip()
    if not v:
        raise RuntimeError(f"{name} is not set")
    return v


def _owner() -> str:
    return (os.environ.get("SESSION_VAULT_OWNER", "default") or "default").strip()


def _vault(method: str, path: str, *, body: dict | None = None, query: dict | None = None) -> dict:
    base = _env("SESSION_VAULT_URL").rstrip("/")
    url = f"{base}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    data = None
    headers = {
        "Authorization": f"Bearer {_env('SESSION_VAULT_TOKEN')}",
        "Accept": "application/json",
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


def cmd_capture(url: str, site: str, profile: str, headless: bool) -> None:
    from playwright.sync_api import sync_playwright

    owner = _owner()
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context()
        page = context.new_page()
        print(f"Open and log in if needed: {url}", file=sys.stderr)
        page.goto(url, wait_until="domcontentloaded", timeout=120_000)
        input("Press Enter after you are logged in… ")

        cdp_cookies = context.cookies()
        js_pairs = page.evaluate(
            """() => document.cookie.split(';').map(s => s.trim()).filter(Boolean)"""
        )

        body = {
            "cookies": cdp_cookies,
            "js_document_cookie": js_pairs,
            "meta": {
                "source": "playwright+capture",
                "label": f"{site}/{profile}",
                "captured_url": page.url,
            },
        }
        path = (
            f"/v1/session/{urllib.parse.quote(site, safe='')}"
            f"/{urllib.parse.quote(profile, safe='')}"
        )
        out = _vault("PUT", path, body=body, query={"owner": owner})
        print(json.dumps(out, indent=2, ensure_ascii=False))
        browser.close()


def cmd_apply(url: str, site: str, profile: str, headless: bool) -> None:
    from playwright.sync_api import sync_playwright

    owner = _owner()
    path = (
        f"/v1/session/{urllib.parse.quote(site, safe='')}"
        f"/{urllib.parse.quote(profile, safe='')}"
    )
    stored = _vault("GET", path, query={"owner": owner})
    cookies = stored.get("cookies")
    if not cookies:
        raise RuntimeError("no cookies in vault for this site/profile")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context()
        if isinstance(cookies, list) and cookies and isinstance(cookies[0], dict) and "name" in cookies[0]:
            context.add_cookies(cookies)
        page = context.new_page()
        page.goto(url, wait_until="domcontentloaded", timeout=120_000)
        print(f"Loaded {url} — check login state.", file=sys.stderr)
        if not headless:
            input("Press Enter to close… ")
        browser.close()


def main() -> None:
    ap = argparse.ArgumentParser(description="Capture/apply cookies via vault + Playwright")
    sub = ap.add_subparsers(dest="cmd", required=True)

    cap = sub.add_parser("capture", help="Open browser, save cookies to vault after login")
    cap.add_argument("--url", required=True)
    cap.add_argument("--site", required=True, help="vault site key, e.g. claude.ai")
    cap.add_argument("--profile", default="default")
    cap.add_argument("--headless", action="store_true")

    app = sub.add_parser("apply", help="Load cookies from vault and open URL")
    app.add_argument("--url", required=True)
    app.add_argument("--site", required=True)
    app.add_argument("--profile", default="default")
    app.add_argument("--headless", action="store_true")

    args = ap.parse_args()
    if args.cmd == "capture":
        cmd_capture(args.url, args.site, args.profile, args.headless)
    else:
        cmd_apply(args.url, args.site, args.profile, args.headless)


if __name__ == "__main__":
    main()
