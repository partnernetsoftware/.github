import { maybeDecryptContent, maybeEncryptContent } from "./mem-crypto";

export interface MemoryRecord {
  id: string;
  key: string;
  content: string;
  tags?: string[];
  created_at: string;
  updated_at: string;
  expires_at?: string;
  chunks?: number;
  chunk_ids?: string[];
}

type ChunkRow = {
  id: string;
  mem_key: string;
  chunk_index: number;
  content: string;
  tags: string | null;
  created_at: string;
  updated_at: string;
  expires_at: string | null;
  embedding: string | null;
};

function normalizeTags(raw: unknown): string[] | undefined {
  if (!Array.isArray(raw)) {
    return undefined;
  }
  const tags = raw.map(String).filter(Boolean);
  return tags.length > 0 ? tags : undefined;
}

function tagsToJson(tags: string[] | undefined): string | null {
  return tags?.length ? JSON.stringify(tags) : null;
}

function parseTags(raw: string | null): string[] | undefined {
  if (!raw) {
    return undefined;
  }
  try {
    return JSON.parse(raw) as string[];
  } catch {
    return undefined;
  }
}

function embeddingToJson(emb: number[] | undefined): string | null {
  return emb?.length ? JSON.stringify(emb) : null;
}

function parseEmbedding(raw: string | null): number[] | undefined {
  if (!raw) {
    return undefined;
  }
  try {
    return JSON.parse(raw) as number[];
  } catch {
    return undefined;
  }
}

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

/** SQLite-backed memory store (requires `new_sqlite_classes` migration). */
export class MemorySqliteDO implements DurableObject {
  private schemaReady: Promise<void>;

  constructor(
    private readonly state: DurableObjectState,
    private readonly env: Env,
  ) {
    this.schemaReady = this.initSchema();
  }

  private sql<T extends Record<string, unknown>>(
    query: string,
    ...bindings: unknown[]
  ): T[] {
    return [...this.state.storage.sql.exec(query, ...bindings)] as T[];
  }

  private async initSchema(): Promise<void> {
    this.sql(`
      CREATE TABLE IF NOT EXISTS mem_chunks (
        id TEXT PRIMARY KEY,
        mem_key TEXT NOT NULL,
        chunk_index INTEGER NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        expires_at TEXT,
        embedding TEXT
      )
    `);
    this.sql(
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_mem_key_chunk ON mem_chunks(mem_key, chunk_index)`,
    );
    this.sql(
      `CREATE INDEX IF NOT EXISTS idx_mem_expires ON mem_chunks(expires_at)`,
    );
    await this.migrateLegacyBlob();
  }

  private async migrateLegacyBlob(): Promise<void> {
    const legacy = await this.state.storage.get<{
      byKey: Record<
        string,
        {
          id: string;
          key: string;
          content: string;
          tags?: string[];
          created_at: string;
          updated_at: string;
          embedding?: number[];
        }
      >;
    }>("memories");
    if (!legacy?.byKey) {
      return;
    }
    for (const rec of Object.values(legacy.byKey)) {
      const enc = await maybeEncryptContent(this.env, rec.content);
      this.sql(
        `INSERT OR REPLACE INTO mem_chunks
         (id, mem_key, chunk_index, content, tags, created_at, updated_at, expires_at, embedding)
         VALUES (?, ?, 0, ?, ?, ?, ?, NULL, ?)`,
        rec.id,
        rec.key,
        enc,
        tagsToJson(rec.tags),
        rec.created_at,
        rec.updated_at,
        embeddingToJson(rec.embedding),
      );
    }
    await this.state.storage.delete("memories");
  }

  private async ready(): Promise<void> {
    await this.schemaReady;
  }

  private rowsForKey(key: string): ChunkRow[] {
    return this.sql<ChunkRow>(
      `SELECT * FROM mem_chunks WHERE mem_key = ? ORDER BY chunk_index ASC`,
      key,
    );
  }

  private async aggregateKey(key: string): Promise<MemoryRecord | null> {
    const rows = this.rowsForKey(key);
    if (rows.length === 0) {
      return null;
    }
    const parts: string[] = [];
    for (const row of rows) {
      parts.push(await maybeDecryptContent(this.env, row.content));
    }
    const first = rows[0]!;
    return {
      id: first.id,
      key,
      content: parts.join("\n\n"),
      tags: parseTags(first.tags),
      created_at: first.created_at,
      updated_at: rows[rows.length - 1]!.updated_at,
      expires_at: first.expires_at ?? undefined,
      chunks: rows.length,
      chunk_ids: rows.map((r) => r.id),
    };
  }

  private scheduleExpiryAlarm(): void {
    const rows = this.sql<{ expires_at: string }>(
      `SELECT MIN(expires_at) AS expires_at FROM mem_chunks
       WHERE expires_at IS NOT NULL AND expires_at > ?`,
      new Date().toISOString(),
    );
    const next = rows[0]?.expires_at;
    if (next) {
      const when = new Date(next).getTime();
      if (when > Date.now()) {
        void this.state.storage.setAlarm(when);
      }
    }
  }

  async alarm(): Promise<void> {
    await this.ready();
    const now = new Date().toISOString();
    this.sql(`DELETE FROM mem_chunks WHERE expires_at IS NOT NULL AND expires_at <= ?`, now);
    this.scheduleExpiryAlarm();
  }

  async fetch(request: Request): Promise<Response> {
    await this.ready();
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/stats") {
      const row = this.sql<{
        keys: number;
        chunks: number;
        bytes: number;
      }>(
        `SELECT COUNT(DISTINCT mem_key) AS keys, COUNT(*) AS chunks,
                COALESCE(SUM(LENGTH(content)), 0) AS bytes FROM mem_chunks`,
      )[0] ?? { keys: 0, chunks: 0, bytes: 0 };
      return Response.json(row);
    }

    if (request.method === "GET" && url.pathname === "/export") {
      const rows = this.sql<ChunkRow>(`SELECT * FROM mem_chunks ORDER BY mem_key, chunk_index`);
      return Response.json({
        chunks: rows.map((r) => ({
          id: r.id,
          key: r.mem_key,
          chunk_index: r.chunk_index,
          content: r.content,
          tags: parseTags(r.tags),
          expires_at: r.expires_at,
        })),
      });
    }

    if (request.method === "GET" && url.pathname === "/entries") {
      const tag = url.searchParams.get("tag")?.trim();
      const rows = this.sql<{
        mem_key: string;
        id: string;
        tags: string | null;
        created_at: string;
        updated_at: string;
        preview: string;
        chunks: number;
      }>(
        `SELECT mem_key, MIN(id) AS id, MIN(tags) AS tags, MIN(created_at) AS created_at,
                MAX(updated_at) AS updated_at, MIN(content) AS preview, COUNT(*) AS chunks
         FROM mem_chunks GROUP BY mem_key ORDER BY updated_at DESC`,
      );
      let entries = rows;
      if (tag) {
        entries = rows.filter((e) => parseTags(e.tags)?.includes(tag));
      }
      return Response.json({
        entries: entries.map((e) => ({
          id: e.id,
          key: e.mem_key,
          tags: parseTags(e.tags),
          created_at: e.created_at,
          updated_at: e.updated_at,
          preview: e.preview.slice(0, 200),
          chunks: e.chunks,
        })),
      });
    }

    const entryMatch = url.pathname.match(/^\/entry\/([^/]+)$/);
    if (entryMatch && request.method === "GET") {
      const key = decodeURIComponent(entryMatch[1]!);
      const rec = await this.aggregateKey(key);
      if (!rec) {
        return Response.json({ error: "not found" }, { status: 404 });
      }
      return Response.json(rec);
    }

    if (entryMatch && request.method === "PUT") {
      const key = decodeURIComponent(entryMatch[1]!);
      let body: {
        chunks?: Array<{ content: string; embedding?: number[] }>;
        tags?: unknown;
        expires_at?: string;
        quota?: { max_keys?: number; max_bytes?: number };
      };
      try {
        body = (await request.json()) as typeof body;
      } catch {
        return Response.json({ error: "invalid json" }, { status: 400 });
      }

      const incoming = body.chunks ?? [];
      if (incoming.length === 0) {
        return Response.json({ error: "chunks required" }, { status: 400 });
      }

      const stats = this.sql<{ keys: number; bytes: number }>(
        `SELECT COUNT(DISTINCT mem_key) AS keys, COALESCE(SUM(LENGTH(content)),0) AS bytes
         FROM mem_chunks WHERE mem_key != ?`,
        key,
      )[0] ?? { keys: 0, bytes: 0 };
      const exists = this.rowsForKey(key).length > 0;
      const newKeys = exists ? stats.keys : stats.keys + 1;
      const newBytes =
        stats.bytes +
        incoming.reduce((n, c) => n + c.content.length, 0);
      if (body.quota?.max_keys && newKeys > body.quota.max_keys) {
        return Response.json({ error: "quota: max keys exceeded" }, { status: 413 });
      }
      if (body.quota?.max_bytes && newBytes > body.quota.max_bytes) {
        return Response.json({ error: "quota: max bytes exceeded" }, { status: 413 });
      }

      const oldIds = this.rowsForKey(key).map((r) => r.id);
      this.sql(`DELETE FROM mem_chunks WHERE mem_key = ?`, key);

      const now = new Date().toISOString();
      const memId = crypto.randomUUID();
      const tags = normalizeTags(body.tags);
      const expires_at =
        typeof body.expires_at === "string" && body.expires_at
          ? body.expires_at
          : null;

      for (let i = 0; i < incoming.length; i++) {
        const chunk = incoming[i]!;
        const content = String(chunk.content).trim();
        if (!content) {
          continue;
        }
        const enc = await maybeEncryptContent(this.env, content);
        const chunkId = i === 0 ? memId : crypto.randomUUID();
        this.sql(
          `INSERT INTO mem_chunks
           (id, mem_key, chunk_index, content, tags, created_at, updated_at, expires_at, embedding)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          chunkId,
          key,
          i,
          enc,
          i === 0 ? tagsToJson(tags) : null,
          now,
          now,
          expires_at,
          embeddingToJson(chunk.embedding),
        );
      }

      if (expires_at) {
        this.scheduleExpiryAlarm();
      }

      const rec = await this.aggregateKey(key);
      return Response.json({ ...rec, replaced_chunk_ids: oldIds });
    }

    if (entryMatch && request.method === "DELETE") {
      const key = decodeURIComponent(entryMatch[1]!);
      const rows = this.rowsForKey(key);
      if (rows.length === 0) {
        return Response.json({ error: "not found" }, { status: 404 });
      }
      const ids = rows.map((r) => r.id);
      this.sql(`DELETE FROM mem_chunks WHERE mem_key = ?`, key);
      return Response.json({ ok: true, key, deleted_chunk_ids: ids });
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
      const rows = this.sql<ChunkRow>(
        `SELECT * FROM mem_chunks WHERE embedding IS NOT NULL`,
      );
      const scored: Array<{ row: ChunkRow; score: number }> = [];
      for (const row of rows) {
        const emb = parseEmbedding(row.embedding);
        if (!emb) {
          continue;
        }
        scored.push({ row, score: cosine(embedding, emb) });
      }
      scored.sort((a, b) => b.score - a.score);
      const top = scored.slice(0, topK);
      const matches = [];
      for (const { row, score } of top) {
        matches.push({
          id: row.id,
          key: row.mem_key,
          score,
          content: await maybeDecryptContent(this.env, row.content),
          tags: parseTags(row.tags),
          updated_at: row.updated_at,
        });
      }
      return Response.json({ matches, mode: "do_embed" });
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
      const like = `%${query.replace(/%/g, "")}%`;
      const rows = this.sql<ChunkRow>(
        `SELECT * FROM mem_chunks
         WHERE LOWER(mem_key) LIKE ? OR LOWER(content) LIKE ?
         LIMIT ?`,
        like,
        like,
        topK * 3,
      );
      const matches = [];
      for (const row of rows.slice(0, topK)) {
        matches.push({
          id: row.id,
          key: row.mem_key,
          score: 1,
          content: await maybeDecryptContent(this.env, row.content),
          tags: parseTags(row.tags),
          updated_at: row.updated_at,
        });
      }
      return Response.json({ matches, mode: "keyword" });
    }

    return new Response("Not found", { status: 404 });
  }
}
