/** Pre-v0.8.0 MemoryDO (non-SQLite). Kept exported until CF deletes idle instances. */
export class MemoryDO implements DurableObject {
  async fetch(): Promise<Response> {
    return Response.json(
      {
        error: "MemoryDO retired",
        hint: "Use MemorySqliteDO binding; re-import memories via mem_put / mem_import",
      },
      { status: 410 },
    );
  }
}
