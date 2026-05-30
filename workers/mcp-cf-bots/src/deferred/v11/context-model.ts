/**
 * LLM-centric model: Brain = compose multi-dimensional context for conditioning;
 * Code = deterministic operations on external state (tools).
 */

export const CONTEXT_DIMENSIONS = [
  "semantic",
  "lexical",
  "episodic",
  "procedural",
  "preference",
  "state",
  "registry",
  "task_frame",
  "meta",
] as const;

export type ContextDimensionId = (typeof CONTEXT_DIMENSIONS)[number];

/** One slice fed into the model after Brain compose (not raw store rows). */
export type ContextBlock = {
  dimension: ContextDimensionId;
  source: string;
  key?: string;
  content: string;
  score?: number;
  updated_at?: string;
  tags?: string[];
};

export type BrainComposeResult = {
  task: string;
  composed_at: string;
  blocks: ContextBlock[];
  token_estimate: number;
};

export const CODE_OP_KINDS = [
  "read",
  "search",
  "write",
  "delete",
  "session",
  "admin",
  "compose",
] as const;

export type CodeOpKind = (typeof CODE_OP_KINDS)[number];

const TOOL_TO_CODE: Record<string, CodeOpKind> = {
  mem_get: "read",
  mem_list: "read",
  mem_search: "search",
  mem_put: "write",
  mem_import: "write",
  mem_delete: "delete",
  sess_save: "session",
  sess_load: "session",
  sess_put: "session",
  sess_get: "session",
  sess_meta: "read",
  sess_list: "read",
  sess_delete: "session",
  brain_compose_context: "compose",
  mem_reindex: "admin",
  mem_stats: "admin",
  mem_vector_gc: "admin",
  auth_token_create: "admin",
  auth_token_list: "admin",
  auth_token_revoke: "admin",
  auth_audit_list: "admin",
};

export function codeOpKind(toolName: string): CodeOpKind | undefined {
  return TOOL_TO_CODE[toolName];
}

/** Map mem hit + key prefix/tags → context dimension. */
export function inferDimension(
  key: string,
  tags?: string[],
  source: "vector" | "keyword" = "keyword",
): ContextDimensionId {
  const tagList = tags ?? [];
  const kindTag = tagList.find((t) => t.startsWith("kind:"));
  if (kindTag === "kind:procedure") {
    return "procedural";
  }
  if (kindTag === "kind:preference") {
    return "preference";
  }
  if (kindTag === "kind:episodic") {
    return "episodic";
  }
  if (key.startsWith("task/") || key.startsWith("decision/")) {
    return "task_frame";
  }
  return source === "vector" ? "semantic" : "lexical";
}

export function parseMemKind(tags?: string[]): string | undefined {
  const t = tags?.find((x) => x.startsWith("kind:"));
  return t?.slice("kind:".length);
}

export function normalizeMemTags(
  tags: string[] | undefined,
  kind?: string,
): string[] | undefined {
  const base = (tags ?? []).filter((t) => !t.startsWith("kind:"));
  if (kind?.trim()) {
    base.push(`kind:${kind.trim()}`);
  }
  return base.length > 0 ? base : undefined;
}
