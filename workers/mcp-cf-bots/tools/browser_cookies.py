#!/usr/bin/env python3
"""Playwright cookie capture/apply via mcp-cf-bots REST."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.parse

from _client import owner, vault_request


def cmd_capture(url: str, site: str, profile: str, headless: bool) -> None:
    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context()
        page = context.new_page()
        print(f"Open and log in if needed: {url}", file=sys.stderr)
        page.goto(url, wait_until="domcontentloaded", timeout=120_000)
        input("Press Enter after you are logged in… ")

        body = {
            "cookies": context.cookies(),
            "js_document_cookie": page.evaluate(
                "() => document.cookie.split(';').map(s => s.trim()).filter(Boolean)"
            ),
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
        out = vault_request("PUT", path, body=body, query={"owner": owner()})
        print(json.dumps(out, indent=2, ensure_ascii=False))
        browser.close()


def cmd_apply(url: str, site: str, profile: str, headless: bool) -> None:
    from playwright.sync_api import sync_playwright

    path = (
        f"/v1/session/{urllib.parse.quote(site, safe='')}"
        f"/{urllib.parse.quote(profile, safe='')}"
    )
    stored = vault_request("GET", path, query={"owner": owner()})
    cookies = stored.get("cookies")
    if not cookies:
        raise RuntimeError("no cookies in vault for this site/profile")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context()
        if isinstance(cookies, list) and cookies and isinstance(cookies[0], dict):
            context.add_cookies(cookies)
        page = context.new_page()
        page.goto(url, wait_until="domcontentloaded", timeout=120_000)
        print(f"Loaded {url} — check login state.", file=sys.stderr)
        if not headless:
            input("Press Enter to close… ")
        browser.close()


def main() -> None:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    cap = sub.add_parser("capture")
    cap.add_argument("--url", required=True)
    cap.add_argument("--site", required=True)
    cap.add_argument("--profile", default="default")
    cap.add_argument("--headless", action="store_true")
    app = sub.add_parser("apply")
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
