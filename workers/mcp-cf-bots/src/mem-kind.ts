/** Memory entry kind tags (v1.0 compatible extension via kind:* tags). */

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
