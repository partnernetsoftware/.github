import type { AuthContext } from "./auth";
import { ownerForTool } from "./owner-scope";
import {
  deleteMemoryVector,
  embedText,
  queryMemoryDoEmbed,
  queryMemoryVectors,
  ragBackend,
  semanticRagEnabled,
  upsertMemoryVector,
} from "./mem-embed";
import type { MemoryRecord } from "./memory-do";
import { memoryStub } from "./memory-store";
import { validateKey } from "./validate";

async function putRecord(
  env: Env,
  owner: string,
  key: string,
  content: string,
  tags?: string[],
): Promise<MemoryRecord> {
  const stub = memoryStub(env, owner);
  let embedding: number[] | undefined;
  if (semanticRagEnabled(env)) {
    try {
      embedding = await embedText(env, `${key}\n${content}`);
    } catch {
      embedding = undefined;
    }
  }
  const res = await stub.fetch(
    `https://memory.internal/entry/${encodeURIComponent(key)}`,
    {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ content, tags, embedding }),
    },
  );
  if (!res.ok) {
    throw new Error(await res.text());
  }
  const rec = (await res.json()) as MemoryRecord;
  if (env.MEM_VECTORS && embedding) {
    try {
      await upsertMemoryVector(env, owner, rec.id, rec.key, rec.content);
    } catch {
      /* DO embed still works */
    }
  }
  return rec;
}

/** MCP `mem_*` tool handlers. */
export async function memToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
  auth: AuthContext,
  requestOwner: string,
): Promise<string> {
  const owner = ownerForTool(auth, env, args, requestOwner);
  const stub = memoryStub(env, owner);
  const backend = ragBackend(env);

  if (name === "mem_list") {
    const url = new URL("https://memory.internal/entries");
    if (typeof args.tag === "string" && args.tag) {
      url.searchParams.set("tag", args.tag);
    }
    const res = await stub.fetch(url.toString());
    return res.text();
  }

  if (name === "mem_search") {
    const query = String(args.query ?? "").trim();
    if (!query) {
      throw new Error("query is required");
    }
    const topK = Math.min(Math.max(Number(args.top_k) || 5, 1), 20);

    if (backend === "vectorize") {
      try {
        const hits = await queryMemoryVectors(env, owner, query, topK);
        if (hits.length > 0) {
          const matches = [];
          for (const hit of hits) {
            const res = await stub.fetch(
              `https://memory.internal/entry/${encodeURIComponent(hit.key)}`,
            );
            if (!res.ok) {
              continue;
            }
            const rec = (await res.json()) as MemoryRecord;
            matches.push({
              id: rec.id,
              key: rec.key,
              score: hit.score,
              tags: rec.tags,
              content: rec.content,
              updated_at: rec.updated_at,
            });
          }
          return JSON.stringify({ matches, mode: "vectorize" }, null, 2);
        }
      } catch {
        /* fall through */
      }
    }

    if (backend === "vectorize" || backend === "do_embed") {
      try {
        const qEmbed = await embedText(env, query);
        const matches = await queryMemoryDoEmbed(stub, qEmbed, topK);
        if (matches.length > 0) {
          return JSON.stringify(
            { matches, mode: backend === "vectorize" ? "do_embed_fallback" : "do_embed" },
            null,
            2,
          );
        }
      } catch {
        /* keyword */
      }
    }

    const res = await stub.fetch("https://memory.internal/search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query, top_k: topK }),
    });
    return res.text();
  }

  const key = validateKey("key", String(args.key ?? ""));

  if (name === "mem_put") {
    const content = String(args.content ?? "").trim();
    if (!content) {
      throw new Error("content is required");
    }
    const tags = Array.isArray(args.tags) ? args.tags.map(String) : undefined;
    const rec = await putRecord(env, owner, key, content, tags);
    return JSON.stringify(
      {
        ok: true,
        id: rec.id,
        key: rec.key,
        rag_backend: ragBackend(env),
      },
      null,
      2,
    );
  }

  if (name === "mem_get") {
    const res = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
    );
    if (res.status === 404) {
      throw new Error(`memory not found: ${key}`);
    }
    return res.text();
  }

  if (name === "mem_delete") {
    const getRes = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
    );
    if (getRes.status === 404) {
      throw new Error(`memory not found: ${key}`);
    }
    const existing = (await getRes.json()) as MemoryRecord;
    const res = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
      { method: "DELETE" },
    );
    if (env.MEM_VECTORS) {
      try {
        await deleteMemoryVector(env, owner, existing.id);
      } catch {
        /* ignore */
      }
    }
    return res.text();
  }

  throw new Error(`Unknown mem tool: ${name}`);
}
