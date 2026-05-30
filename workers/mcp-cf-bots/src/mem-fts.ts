/** FTS5 helpers for MemorySqliteDO keyword search. */

export function escapeFtsQuery(raw: string): string {
  const terms = raw
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .map((t) => t.replace(/"/g, '""'));
  if (terms.length === 0) {
    return "";
  }
  return terms.map((t) => `"${t}"`).join(" ");
}

export type FtsSearchOpts = {
  query: string;
  topK: number;
  tag?: string;
  updated_after?: string;
  updated_before?: string;
};

export function initFtsSchema(exec: (sql: string, ...bindings: unknown[]) => void): void {
  exec(`
    CREATE VIRTUAL TABLE IF NOT EXISTS mem_fts USING fts5(
      chunk_id UNINDEXED,
      mem_key,
      body,
      tags,
      updated_at UNINDEXED,
      tokenize='porter unicode61'
    )
  `);
}

export function ftsIndexChunk(
  exec: (sql: string, ...bindings: unknown[]) => void,
  row: {
    chunkId: string;
    memKey: string;
    body: string;
    tags: string | null;
    updatedAt: string;
  },
): void {
  exec(`DELETE FROM mem_fts WHERE chunk_id = ?`, row.chunkId);
  exec(
    `INSERT INTO mem_fts (chunk_id, mem_key, body, tags, updated_at)
     VALUES (?, ?, ?, ?, ?)`,
    row.chunkId,
    row.memKey,
    row.body,
    row.tags,
    row.updatedAt,
  );
}

export function ftsRemoveKey(
  exec: (sql: string, ...bindings: unknown[]) => void,
  memKey: string,
): void {
  exec(`DELETE FROM mem_fts WHERE mem_key = ?`, memKey);
}

export function ftsRebuildAll(
  exec: (sql: string, ...bindings: unknown[]) => void,
  rows: Array<{
    id: string;
    mem_key: string;
    content: string;
    tags: string | null;
    updated_at: string;
  }>,
): void {
  exec(`DELETE FROM mem_fts`);
  for (const row of rows) {
    ftsIndexChunk(exec, {
      chunkId: row.id,
      memKey: row.mem_key,
      body: row.content,
      tags: row.tags,
      updatedAt: row.updated_at,
    });
  }
}

export type FtsHit = {
  chunk_id: string;
  mem_key: string;
  score: number;
};

export function ftsSearch(
  query: <T extends Record<string, unknown>>(sql: string, ...bindings: unknown[]) => T[],
  opts: FtsSearchOpts,
): FtsHit[] {
  const match = escapeFtsQuery(opts.query);
  if (!match) {
    return [];
  }
  const tagLike = opts.tag ? `%"${opts.tag.replace(/"/g, "")}"%` : null;
  const topK = Math.min(Math.max(opts.topK, 1), 20);

  return query<{
    chunk_id: string;
    mem_key: string;
    score: number;
  }>(
    `SELECT f.chunk_id, f.mem_key, bm25(mem_fts) AS score
     FROM mem_fts f
     INNER JOIN mem_chunks c ON c.id = f.chunk_id
     WHERE mem_fts MATCH ?
       AND (? IS NULL OR c.tags LIKE ?)
       AND (? IS NULL OR c.updated_at >= ?)
       AND (? IS NULL OR c.updated_at <= ?)
     ORDER BY score
     LIMIT ?`,
    match,
    tagLike,
    tagLike,
    opts.updated_after ?? null,
    opts.updated_after ?? null,
    opts.updated_before ?? null,
    opts.updated_before ?? null,
    topK * 3,
  );
}
