/**
 * Run in DevTools Console on a logged-in page (e.g. claude.ai/code).
 * Copies a vault-ready JSON payload to clipboard.
 *
 * Note: document.cookie omits HttpOnly cookies. For full auth on many sites,
 * prefer workers/mcp-cf-bots/tools/browser_cookies.py capture (Playwright CDP).
 */
(function captureCookiesForVault() {
  const site = location.hostname.replace(/^www\./, "");
  const profile = "default";

  const pairs = document.cookie
    .split(";")
    .map((s) => s.trim())
    .filter(Boolean)
    .map((part) => {
      const i = part.indexOf("=");
      const name = decodeURIComponent(part.slice(0, i));
      const value = decodeURIComponent(part.slice(i + 1));
      return { name, value, domain: location.hostname, path: "/" };
    });

  const payload = {
    site,
    profile,
    kind: "cookies",
    data: pairs,
    meta: {
      source: "js-console",
      label: `${site} js capture`,
      captured_at: new Date().toISOString(),
      url: location.href,
    },
  };

  const text = JSON.stringify(payload, null, 2);
  if (typeof copy === "function") {
    copy(text);
    console.log("Copied vault payload (%d cookies). Paste into sess_put or MCP.", pairs.length);
  } else {
    console.log(text);
  }
  return payload;
})();
