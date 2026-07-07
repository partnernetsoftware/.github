/** Encrypted payload kinds stored per site/profile. */
export const SESSION_KINDS = [
  "oauth",
  "cookies",
  "storage_state",
  "config",
] as const;

export type SessionKind = (typeof SESSION_KINDS)[number];

export interface SessionMeta {
  updated_at: string;
  created_at?: string;
  expires_at?: string;
  label?: string;
  /** e.g. browser-use | oauth | manual */
  source?: string;
  tags?: string[];
  notes?: string;
}

export function isExpired(meta?: SessionMeta): boolean {
  if (!meta?.expires_at) {
    return false;
  }
  const exp = Date.parse(meta.expires_at);
  return Number.isFinite(exp) && exp < Date.now();
}

export function mergeMeta(
  prev: SessionMeta | undefined,
  incoming: Partial<SessionMeta>,
  now: string,
): SessionMeta {
  return {
    created_at: prev?.created_at ?? incoming.created_at ?? now,
    updated_at: now,
    expires_at: incoming.expires_at ?? prev?.expires_at,
    label: incoming.label ?? prev?.label,
    source: incoming.source ?? prev?.source,
    tags: incoming.tags ?? prev?.tags,
    notes: incoming.notes ?? prev?.notes,
  };
}
