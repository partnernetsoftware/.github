import type { SessionMeta } from "./kinds";

export interface RegistryEntry {
  site: string;
  profile: string;
  updated_at: string;
  label?: string;
  source?: string;
  tags?: string[];
  expires_at?: string;
}

interface RegistryState {
  entries: RegistryEntry[];
}

export class RegistryDO implements DurableObject {
  constructor(
    private readonly state: DurableObjectState,
    private readonly env: Env,
  ) {}

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/entries") {
      const stored = (await this.state.storage.get<RegistryState>("registry")) ?? {
        entries: [],
      };
      let entries = stored.entries;
      const source = url.searchParams.get("source")?.trim();
      const tag = url.searchParams.get("tag")?.trim();
      if (source) {
        entries = entries.filter((e) => e.source === source);
      }
      if (tag) {
        entries = entries.filter((e) => e.tags?.includes(tag));
      }
      return Response.json({ entries });
    }

    if (request.method === "POST" && url.pathname === "/upsert") {
      const body = (await request.json()) as RegistryEntry;
      const stored = (await this.state.storage.get<RegistryState>("registry")) ?? {
        entries: [],
      };
      const filtered = stored.entries.filter(
        (e) => !(e.site === body.site && e.profile === body.profile),
      );
      filtered.push({
        site: body.site,
        profile: body.profile,
        updated_at: body.updated_at,
        label: body.label,
        source: body.source,
        tags: body.tags,
        expires_at: body.expires_at,
      });
      await this.state.storage.put("registry", { entries: filtered });
      return Response.json({ ok: true });
    }

    if (request.method === "POST" && url.pathname === "/remove") {
      const body = (await request.json()) as { site: string; profile: string };
      const stored = (await this.state.storage.get<RegistryState>("registry")) ?? {
        entries: [],
      };
      const filtered = stored.entries.filter(
        (e) => !(e.site === body.site && e.profile === body.profile),
      );
      await this.state.storage.put("registry", { entries: filtered });
      return Response.json({ ok: true });
    }

    return new Response("Not found", { status: 404 });
  }
}

export function registryEntryFromMeta(
  site: string,
  profile: string,
  meta: SessionMeta,
): RegistryEntry {
  return {
    site,
    profile,
    updated_at: meta.updated_at,
    label: meta.label,
    source: meta.source,
    tags: meta.tags,
    expires_at: meta.expires_at,
  };
}
