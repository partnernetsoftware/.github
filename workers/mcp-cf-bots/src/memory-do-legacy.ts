/** Pre-v0.8.0 MemoryDO (non-SQLite). Read-only export for migration. */
export class MemoryDO implements DurableObject {
  constructor(private readonly state: DurableObjectState) {}

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/export") {
      const legacy = await this.state.storage.get<{
        byKey: Record<
          string,
          {
            id: string;
            key: string;
            content: string;
            tags?: string[];
            created_at: string;
            updated_at: string;
          }
        >;
      }>("memories");
      const entries = legacy?.byKey
        ? Object.values(legacy.byKey).map((rec) => ({
            key: rec.key,
            content: rec.content,
            tags: rec.tags,
            created_at: rec.created_at,
            updated_at: rec.updated_at,
          }))
        : [];
      return Response.json({ entries, source: "legacy_memory_do" });
    }

    if (request.method === "GET" && url.pathname === "/stats") {
      const legacy = await this.state.storage.get<{
        byKey: Record<string, unknown>;
      }>("memories");
      const keys = legacy?.byKey ? Object.keys(legacy.byKey).length : 0;
      return Response.json({ keys, legacy: true });
    }

    return Response.json(
      {
        error: "MemoryDO retired",
        hint: "Use mem_migrate_legacy or MEMORY_LEGACY export; active store is MemorySqliteDO",
      },
      { status: 410 },
    );
  }
}
