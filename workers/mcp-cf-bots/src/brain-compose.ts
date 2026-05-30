import type { ContextBlock, BrainComposeResult, ContextDimensionId } from "./context-model";
import { inferDimension } from "./context-model";
import { runHybridSearch } from "./mem-hybrid-search";
import { memoryStub } from "./memory-store";
import { sessionStub } from "./session-store";
import type { SearchHit } from "./mem-hybrid";

export type BrainComposeOpts = {
  task: string;
  top_k?: number;
  dimensions?: ContextDimensionId[];
  tag?: string;
  session?: { site: string; profile: string };
};

function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

function hitToBlock(hit: SearchHit): ContextBlock {
  const dimension = inferDimension(hit.key, hit.tags, hit.source === "vector" ? "vector" : "keyword");
  return {
    dimension,
    source: `mem:${hit.source}`,
    key: hit.key,
    content: hit.content,
    score: hit.score,
    updated_at: hit.updated_at,
    tags: hit.tags,
  };
}

/** Brain operator: select + project memory/session into labeled context blocks for the LLM. */
export async function brainComposeContext(
  env: Env,
  owner: string,
  opts: BrainComposeOpts,
): Promise<BrainComposeResult> {
  const task = opts.task.trim();
  if (!task) {
    throw new Error("task is required");
  }
  const topK = Math.min(Math.max(opts.top_k ?? 8, 1), 20);
  const allow = new Set<ContextDimensionId>(
    opts.dimensions?.length ? opts.dimensions : ["semantic", "lexical", "episodic", "procedural", "preference", "task_frame"],
  );

  const blocks: ContextBlock[] = [];
  const stub = env.MEMORY_STORE ? memoryStub(env, owner) : null;

  if (stub && allow.size > 0) {
    const { matches } = await runHybridSearch(env, stub, owner, task, topK, {
      tag: opts.tag,
    });
    for (const hit of matches) {
      const block = hitToBlock(hit);
      if (allow.has(block.dimension)) {
        blocks.push(block);
      }
    }
  }

  if (opts.session?.site && opts.session?.profile && allow.has("state")) {
    const sessStub = sessionStub(env, owner, opts.session.site, opts.session.profile);
    const metaRes = await sessStub.fetch(
      `https://session.internal/?meta_only=1`,
    );
    if (metaRes.ok) {
      const meta = (await metaRes.json()) as { meta?: Record<string, unknown> };
      blocks.push({
        dimension: "state",
        source: "sess:meta",
        key: `${opts.session.site}/${opts.session.profile}`,
        content: JSON.stringify(meta.meta ?? {}, null, 2),
      });
    }
  }

  blocks.push({
    dimension: "meta",
    source: "tenant",
    content: JSON.stringify({ owner, task }, null, 2),
  });

  const token_estimate = blocks.reduce((n, b) => n + estimateTokens(b.content), 0);

  return {
    task,
    composed_at: new Date().toISOString(),
    blocks,
    token_estimate,
  };
}
