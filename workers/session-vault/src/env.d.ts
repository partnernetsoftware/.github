interface Env {
  SESSION_VAULT: DurableObjectNamespace;
  REGISTRY: DurableObjectNamespace;
  VAULT_TOKEN: string;
  ENCRYPTION_KEY?: string;
}
