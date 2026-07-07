import type { SessionMeta } from "./kinds";

/** Build session metadata from MCP tool / REST args. */
export function metaFromArgs(args: Record<string, unknown>): Partial<SessionMeta> {
  const meta: Partial<SessionMeta> = {};
  if (typeof args.expires_at === "string" && args.expires_at) {
    meta.expires_at = args.expires_at;
  }
  if (typeof args.label === "string" && args.label) {
    meta.label = args.label;
  }
  if (typeof args.source === "string" && args.source) {
    meta.source = args.source;
  }
  if (typeof args.notes === "string" && args.notes) {
    meta.notes = args.notes;
  }
  if (Array.isArray(args.tags)) {
    meta.tags = args.tags.map(String);
  }
  return meta;
}
