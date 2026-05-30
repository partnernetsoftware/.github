import type { AuthContext } from "./auth";
import { effectiveOwner } from "./auth";
import { memoryStub } from "./memory-store";

const MEM_URI_RE = /^mem:\/\/([^/]+)\/?$/;

export function memResourceUri(key: string): string {
  return `mem://${encodeURIComponent(key)}`;
}

export function parseMemResourceUri(uri: string): string | null {
  const m = uri.match(MEM_URI_RE);
  if (!m) {
    return null;
  }
  return decodeURIComponent(m[1]!);
}

export async function listMemResources(
  env: Env,
  auth: AuthContext,
  requestOwner: string,
): Promise<Array<{ uri: string; name: string; description?: string }>> {
  if (!env.MEMORY_STORE) {
    return [];
  }
  const owner = effectiveOwner(auth, env, { argOwner: requestOwner });
  const res = await memoryStub(env, owner).fetch("https://memory.internal/entries");
  if (!res.ok) {
    return [];
  }
  const { entries } = (await res.json()) as {
    entries: Array<{ key: string; preview?: string; updated_at: string }>;
  };
  return entries.map((e) => ({
    uri: memResourceUri(e.key),
    name: e.key,
    description: (e.preview ?? "").slice(0, 120) || `updated ${e.updated_at}`,
  }));
}

export async function readMemResource(
  env: Env,
  auth: AuthContext,
  requestOwner: string,
  uri: string,
): Promise<{ uri: string; mimeType: string; text: string } | null> {
  const key = parseMemResourceUri(uri);
  if (!key) {
    return null;
  }
  const owner = effectiveOwner(auth, env, { argOwner: requestOwner });
  const res = await memoryStub(env, owner).fetch(
    `https://memory.internal/entry/${encodeURIComponent(key)}`,
  );
  if (!res.ok) {
    return null;
  }
  const rec = (await res.json()) as { content: string; key: string };
  return {
    uri,
    mimeType: "text/plain",
    text: rec.content,
  };
}
