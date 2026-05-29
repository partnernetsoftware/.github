interface Env {
  SESSION_VAULT: DurableObjectNamespace;
  REGISTRY: DurableObjectNamespace;
  VAULT_TOKEN: string;
  ENCRYPTION_KEY?: string;
  /** Default owner namespace when ?owner= / tool owner omitted */
  DEFAULT_OWNER?: string;
}
