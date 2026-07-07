interface Env {
  SESSION_STORE: DurableObjectNamespace;
  REGISTRY: DurableObjectNamespace;
  MEMORY_STORE?: DurableObjectNamespace;
  AI?: Ai;
  MEM_VECTORS?: VectorizeIndex;
  /** Per-user API token index (hashed bearer → owner) */
  TOKENS?: KVNamespace;
  /** Secret — admin Bearer + REST (not MCP session HMAC when MCP_SESSION_SECRET set) */
  VAULT_TOKEN: string;
  /** Optional — HMAC for MCP-Session-Id only (recommended in production) */
  MCP_SESSION_SECRET?: string;
  /** Secret — optional AES key; defaults to VAULT_TOKEN when unset */
  ENCRYPTION_KEY?: string;

  /** Default owner when header / query / tool arg omitted (wrangler var) */
  DEFAULT_OWNER?: string;
  /** Default meta.source for sess_save when source arg omitted */
  DEFAULT_SESSION_SOURCE?: string;

  /** MCP Streamable HTTP path (e.g. /mcp) */
  MCP_HTTP_PATH?: string;
  MCP_SERVER_NAME?: string;
  MCP_SERVER_VERSION?: string;
  /** Frozen REST/MCP tool surface (semver major for API, independent of deploy version). */
  MCP_API_VERSION?: string;
  MCP_SERVER_DESCRIPTION?: string;
  MCP_PROTOCOL_VERSION?: string;
  /** Optional override for MCP initialize `instructions` (agent tool-use guide). */
  MCP_SERVER_INSTRUCTIONS?: string;
  /** Comma-separated Origin allowlist; empty = https + cursor IDE + localhost */
  MCP_ALLOWED_ORIGINS?: string;
  MCP_PUBLIC_HOST?: string;
  /** Primary owner header (legacy X-Session-Vault-Owner always checked) */
  OWNER_HEADER?: string;
  /** Max request body bytes (Content-Length check); default 2_000_000 */
  MAX_BODY_BYTES?: string;

  /** Optional — Cloudflare account id for public / usage stats (GraphQL) */
  CF_ACCOUNT_ID?: string;
  /** Optional — API token with Account Analytics Read */
  CF_API_TOKEN?: string;

  /** Memory chunk size in chars (default 1500) */
  MEM_CHUNK_CHARS?: string;
  /** Max distinct memory keys per owner DO (default 2000) */
  MAX_MEM_KEYS?: string;
  /** Max total stored bytes per owner DO (default 8_000_000) */
  MAX_MEM_BYTES?: string;
  /** Max single put body chars (default 32_000) */
  MAX_MEM_CHUNK_BYTES?: string;
  /** Memory API requests per owner per minute (default 120) */
  MEM_RATE_LIMIT_PER_MIN?: string;
  /** Encrypt memory content at rest in DO (1/true/yes) */
  MEM_ENCRYPT?: string;
  /** Vectorize index name for REST list/GC (default mcp-cf-bots-mem) */
  MEM_VECTORIZE_INDEX?: string;
  /** Cron: nightly mem_reindex per owner (1/true/yes) */
  MEM_CRON_REINDEX?: string;
  /** Cron: orphan Vectorize GC (needs CF_ACCOUNT_ID + CF_API_TOKEN) */
  MEM_CRON_VECTOR_GC?: string;
  /** Extra owners for cron (comma-separated) */
  MEM_CRON_OWNERS?: string;
  /** Max owners processed per cron tick (default 32) */
  MEM_CRON_OWNER_LIMIT?: string;
  /** Vectorize list pages per cron tick (default 5) */
  MEM_CRON_GC_PAGES_PER_RUN?: string;
  /** Optional POST target for cron report JSON */
  MEM_CRON_WEBHOOK_URL?: string;
}
