interface Env {
  SESSION_STORE: DurableObjectNamespace;
  REGISTRY: DurableObjectNamespace;
  /** Per-user API token index (hashed bearer → owner) */
  TOKENS?: KVNamespace;
  /** Secret — MCP + REST Bearer token */
  VAULT_TOKEN: string;
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
  MCP_SERVER_DESCRIPTION?: string;
  MCP_PROTOCOL_VERSION?: string;
  /** Comma-separated Origin allowlist; empty = https + cursor IDE + localhost */
  MCP_ALLOWED_ORIGINS?: string;
  /** Primary owner header (legacy X-Session-Vault-Owner always checked) */
  OWNER_HEADER?: string;
  /** Max request body bytes (Content-Length check); default 2_000_000 */
  MAX_BODY_BYTES?: string;
}
