export interface RegistryEntry {
  site: string;
  profile: string;
  updated_at: string;
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
      return Response.json({ entries: stored.entries });
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
