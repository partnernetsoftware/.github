/**
 * Run in DevTools Console BEFORE or on a fresh login page of the same site.
 * Paste the `data` array from vault session_get?kind=cookies (or capture output).
 *
 * Usage:
 *   applyCookiesFromVault([{name,value,domain,path}, ...])
 */
function applyCookiesFromVault(cookieList) {
  if (!Array.isArray(cookieList)) {
    throw new Error("expected array of {name,value,domain?,path?}");
  }
  const host = location.hostname;
  let n = 0;
  for (const c of cookieList) {
    if (!c.name) continue;
    const domain = c.domain || host;
    if (!host.endsWith(domain.replace(/^\./, "")) && domain.replace(/^\./, "") !== host) {
      continue;
    }
    const path = c.path || "/";
    const secure = location.protocol === "https:" ? "; Secure" : "";
    document.cookie = `${encodeURIComponent(c.name)}=${encodeURIComponent(c.value)}; domain=${domain}; path=${path}${secure}; SameSite=Lax`;
    n++;
  }
  console.log("Set %d cookies via document.cookie — reload the page.", n);
  return n;
}
