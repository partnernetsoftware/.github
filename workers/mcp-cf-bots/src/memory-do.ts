export interface MemoryRecord {
  id: string;
  key: string;
  content: string;
  tags?: string[];
  created_at: string;
  updated_at: string;
  /** Workers AI embedding (768-d) when Vectorize not used yet */
  embedding?: number[];
}

interface MemoryState {
  byKey: Record<string, MemoryRecord>;
}

function normalizeTags(raw: unknown): string[] | undefined {
  if (!Array.isArray(raw)) {
    return undefined;
  }
  const tags = raw.map(String).filter(Boolean);
  return tags.length > 0 ? tags : undefined;
}

export class MemoryDO implements DurableObject {
  constructor(private readonly state: DurableObjectState) {}

  private async load(): Promise<MemoryState> {
    return (
      (await this.state.storage.get<MemoryState>("memories")) ?? { byKey: {} }
    );
  }

  private async save(data: MemoryState): Promise<void> {
    await this.state.storage.put("memories", data);
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/entries") {
      const data = await this.load();
      let entries = Object.values(data.byKey);
      const tag = url.searchParams.get("tag")?.trim();
      if (tag) {
        entries = entries.filter((e) => e.tags?.includes(tag));
      }
      entries.sort((a, b) => b.updated_at.localeCompare(a.updated_at));
      return Response.json({
        entries: entries.map((e) => ({
          id: e.id,
          key: e.key,
          tags: e.tags,
          created_at: e.created_at,
          updated_at: e.updated_at,
          preview: e.content.slice(0, 200),
        })),
      });
    }

    const entryMatch = url.pathname.match(/^\/entry\/([^/]+)$/);
    if (entryMatch && request.method === "GET") {
      const key = decodeURIComponent(entryMatch[1]!);
      const data = await this.load();
      const rec = data.byKey[key];
      if (!rec) {
        return Response.json({ error: "not found" }, { status: 404 });
      }
      return Response.json(rec);
    }

    if (entryMatch && request.method === "PUT") {
      const key = decodeURIComponent(entryMatch[1]!);
      let body: { content?: string; tags?: unknown; embedding?: number[] };
      try {
        body = (await request.json()) as {
          content?: string;
          tags?: unknown;
          embedding?: number[];
        };
      } catch {
        return Response.json({ error: "invalid json" }, { status: 400 });
      }
      const content = String(body.content ?? "").trim();
      if (!content) {
        return Response.json({ error: "content is required" }, { status: 400 });
      }
      const data = await this.load();
      const now = new Date().toISOString();
      const existing = data.byKey[key];
      const rec: MemoryRecord = {
        id: existing?.id ?? crypto.randomUUID(),
        key,
        content,
        tags: normalizeTags(body.tags) ?? existing?.tags,
        embedding: Array.isArray(body.embedding) ? body.embedding : existing?.embedding,
        created_at: existing?.created_at ?? now,
        updated_at: now,
      };
      data.byKey[key] = rec;
      await this.save(data);
      return Response.json(rec);
    }

    if (entryMatch && request.method === "DELETE") {
      const key = decodeURIComponent(entryMatch[1]!);
      const data = await this.load();
      const rec = data.byKey[key];
      if (!rec) {
        return Response.json({ error: "not found" }, { status: 404 });
      }
      delete data.byKey[key];
      await this.save(data);
      return Response.json({ ok: true, id: rec.id, key: rec.key });
    }

    if (request.method === "POST" && url.pathname === "/search_semantic") {
      let body: { embedding?: number[]; top_k?: number };
      try {
        body = (await request.json()) as { embedding?: number[]; top_k?: number };
      } catch {
        return Response.json({ error: "invalid json" }, { status: 400 });
      }
      const embedding = body.embedding;
      if (!Array.isArray(embedding) || embedding.length === 0) {
        return Response.json({ error: "embedding required" }, { status: 400 });
      }
      const topK = Math.min(Math.max(Number(body.top_k) || 5, 1), 20);
      const data = await this.load();

      function cosine(a: number[], b: number[]): number {
        let dot = 0;
        let na = 0;
        let nb = 0;
        const n = Math.min(a.length, b.length);
        for (let i = 0; i < n; i++) {
          dot += a[i]! * b[i]!;
          na += a[i]! * a[i]!;
          nb += b[i]! * b[i]!;
        }
        const denom = Math.sqrt(na) * Math.sqrt(nb);
        return denom > 0 ? dot / denom : 0;
      }

      const scored = Object.values(data.byKey)
        .filter((rec) => Array.isArray(rec.embedding) && rec.embedding!.length > 0)
        .map((rec) => ({
          rec,
          score: cosine(embedding, rec.embedding!),
        }))
        .sort((a, b) => b.score - a.score)
        .slice(0, topK);

      return Response.json({
        matches: scored.map(({ rec, score }) => ({
          id: rec.id,
          key: rec.key,
          score,
          content: rec.content,
          tags: rec.tags,
          updated_at: rec.updated_at,
        })),
        mode: "do_embed",
      });
    }

    if (request.method === "POST" && url.pathname === "/search") {
      let body: { query?: string; top_k?: number };
      try {
        body = (await request.json()) as { query?: string; top_k?: number };
      } catch {
        return Response.json({ error: "invalid json" }, { status: 400 });
      }
      const query = String(body.query ?? "").trim().toLowerCase();
      if (!query) {
        return Response.json({ error: "query is required" }, { status: 400 });
      }
      const topK = Math.min(Math.max(Number(body.top_k) || 5, 1), 20);
      const data = await this.load();
      const scored = Object.values(data.byKey)
        .map((rec) => {
          const hay = `${rec.key}\n${rec.content}`.toLowerCase();
          const score = hay.includes(query) ? 1 : 0;
          return { rec, score };
        })
        .filter((x) => x.score > 0)
        .slice(0, topK);
      return Response.json({
        matches: scored.map(({ rec, score }) => ({
          id: rec.id,
          key: rec.key,
          score,
          content: rec.content,
          tags: rec.tags,
          updated_at: rec.updated_at,
        })),
        mode: "keyword",
      });
    }

    return new Response("Not found", { status: 404 });
  }
}
