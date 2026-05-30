import { isAdmin, type AuthContext } from "./auth";
import { SESSION_KINDS } from "./kinds";

export type ToolDef = {
  name: string;
  description: string;
  required: readonly string[];
  properties: Record<string, unknown>;
};

const ADMIN_TOOL_DEFS: ToolDef[] = [
  {
    name: "auth_token_create",
    description: "Admin: issue a per-user Bearer token scoped to one owner namespace",
    required: ["owner"],
    properties: {
      owner: { type: "string", description: "Tenant / user id" },
      label: { type: "string", description: "Optional note (e.g. alice-cursor)" },
    },
  },
  {
    name: "auth_token_list",
    description: "Admin: list issued user tokens (metadata only, not secret values)",
    required: [],
    properties: {
      owner: { type: "string", description: "Filter by owner" },
    },
  },
  {
    name: "auth_token_revoke",
    description: "Admin: revoke a user token by id",
    required: ["token_id"],
    properties: {
      token_id: { type: "string" },
    },
  },
  {
    name: "auth_audit_list",
    description: "Admin: list recent auth audit log entries (metadata only)",
    required: [],
    properties: {
      limit: { type: "number", description: "Max entries to return, default 50" },
    },
  },
];

const SESS_TOOL_DEFS: ToolDef[] = [
  {
    name: "sess_save",
    description:
      "Save browser-use / Playwright session for reuse across Cloud Agents (storage_state + optional oauth/cookies/config)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string", description: "Site key (e.g. github.com)" },
      profile: { type: "string", description: "Profile name (e.g. default)" },
      storage_state: {
        description: "Playwright storageState JSON (cookies + origins)",
      },
      oauth: { description: "OAuth token bundle JSON" },
      cookies: { description: "Raw cookie list JSON" },
      config: {
        description: "browser-use or agent config JSON (API URLs, selectors, etc.)",
      },
      label: { type: "string", description: "Human label in sess_list" },
      source: { type: "string", description: "Source tag (default browser-use)" },
      tags: {
        type: "array",
        items: { type: "string" },
        description: "Tags for filtering sess_list",
      },
      notes: { type: "string" },
      expires_at: { type: "string", description: "ISO8601 expiry" },
      owner: { type: "string", description: "Owner namespace (admin only)" },
    },
  },
  {
    name: "sess_load",
    description:
      "Load saved browser session for browser-use (storage_state; optional oauth/cookies/config)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      include_oauth: { type: "boolean" },
      include_cookies: { type: "boolean" },
      include_config: { type: "boolean" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_meta",
    description: "Read label/tags/source/expiry metadata without decrypting payloads",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_put",
    description: "Store a single kind: oauth, cookies, storage_state, or config",
    required: ["site", "profile", "kind", "data"],
    properties: {
      site: { type: "string", description: "Site key (e.g. claude.ai)" },
      profile: { type: "string", description: "Profile name" },
      kind: { type: "string", enum: [...SESSION_KINDS] },
      data: { description: "JSON-serializable session payload" },
      owner: { type: "string" },
      label: { type: "string" },
      source: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
      notes: { type: "string" },
      expires_at: { type: "string" },
    },
  },
  {
    name: "sess_get",
    description: "Read stored session fields (optional single kind)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      kind: { type: "string", enum: [...SESSION_KINDS] },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_delete",
    description: "Delete all encrypted session data for site/profile",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_list",
    description: "List site/profile entries with label/source/tags",
    required: [] as string[],
    properties: {
      owner: { type: "string" },
      source: { type: "string", description: "Filter by meta.source" },
      tag: { type: "string", description: "Filter entries containing tag" },
    },
  },
];

const MEM_TOOL_DEFS: ToolDef[] = [
  {
    name: "mem_put",
    description:
      "Store a memory entry (auto-chunked for RAG); optional tags and ISO8601 expires_at",
    required: ["key", "content"],
    properties: {
      key: { type: "string", description: "Unique key within owner namespace" },
      content: { type: "string", description: "Text to remember" },
      tags: { type: "array", items: { type: "string" } },
      expires_at: { type: "string", description: "ISO8601 expiry" },
      owner: { type: "string" },
    },
  },
  {
    name: "mem_get",
    description: "Load a memory entry by key",
    required: ["key"],
    properties: {
      key: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "mem_delete",
    description: "Delete a memory entry by key",
    required: ["key"],
    properties: {
      key: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "mem_list",
    description: "List memory keys with short previews",
    required: [] as string[],
    properties: {
      tag: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "mem_search",
    description:
      "Hybrid RRF search (Vectorize + FTS keyword; do_embed fallback); optional tag / updated_after / updated_before filters; ranked snippets",
    required: ["query"],
    properties: {
      query: { type: "string" },
      top_k: { type: "number", description: "Max results 1-20, default 5" },
      tag: { type: "string", description: "Filter entries containing tag" },
      updated_after: { type: "string", description: "ISO8601 lower bound on updated_at" },
      updated_before: { type: "string", description: "ISO8601 upper bound on updated_at" },
      owner: { type: "string" },
    },
  },
  {
    name: "mem_import",
    description: "Batch import memory entries [{ key, content, tags?, expires_at? }]",
    required: ["entries"],
    properties: {
      entries: {
        type: "array",
        description: "Array of { key, content, tags?, expires_at? }",
      },
      owner: { type: "string" },
    },
  },
];

const MEM_ADMIN_TOOL_DEFS: ToolDef[] = [
  {
    name: "mem_migrate_legacy",
    description:
      "Admin: import memories from legacy MemoryDO blob into MemorySqliteDO (skip if sqlite non-empty unless force)",
    required: [] as string[],
    properties: {
      owner: { type: "string" },
      force: { type: "boolean", description: "Overwrite even when sqlite already has keys" },
    },
  },
  {
    name: "mem_reindex",
    description: "Admin: rebuild Vectorize vectors from DO chunks for an owner",
    required: [] as string[],
    properties: {
      owner: { type: "string", description: "Target owner (default: caller scope)" },
    },
  },
  {
    name: "mem_stats",
    description: "Admin: memory DO stats (keys, chunks, bytes) for an owner",
    required: [] as string[],
    properties: {
      owner: { type: "string" },
    },
  },
  {
    name: "mem_vector_gc",
    description:
      "Admin: delete Vectorize vectors with no matching DO chunk (needs CF API token)",
    required: [] as string[],
    properties: {
      owner: { type: "string" },
      dry_run: { type: "boolean", description: "Report orphans only, do not delete" },
    },
  },
];

function stripOwnerArg(tools: ToolDef[]): ToolDef[] {
  return tools.map((t) => {
    const { owner: _o, ...properties } = t.properties as Record<string, unknown> & {
      owner?: unknown;
    };
    const required = t.required.filter((r) => r !== "owner");
    return { ...t, properties, required };
  });
}

/** MCP tools visible for this auth role (user tokens omit `owner` arg). */
export function toolsForAuth(auth: AuthContext): ToolDef[] {
  const sess =
    auth.role === "user" ? stripOwnerArg(SESS_TOOL_DEFS) : SESS_TOOL_DEFS;
  const mem =
    auth.role === "user" ? stripOwnerArg(MEM_TOOL_DEFS) : MEM_TOOL_DEFS;
  if (isAdmin(auth)) {
    return [...sess, ...mem, ...MEM_ADMIN_TOOL_DEFS, ...ADMIN_TOOL_DEFS];
  }
  return [...sess, ...mem];
}
