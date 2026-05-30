import {
  decryptJson,
  deriveAesKey,
  encryptJson,
  encryptionSecret,
} from "./crypto";
import {
  isExpired,
  mergeMeta,
  SESSION_KINDS,
  type SessionKind,
  type SessionMeta,
} from "./kinds";

interface StoredSession {
  oauth?: string;
  cookies?: string;
  storage_state?: string;
  config?: string;
  meta?: SessionMeta;
}

export class SessionVaultDO implements DurableObject {
  private keyPromise: Promise<CryptoKey> | null = null;

  constructor(
    private readonly state: DurableObjectState,
    private readonly env: Env,
  ) {}

  private async aesKey(): Promise<CryptoKey> {
    if (!this.keyPromise) {
      this.keyPromise = deriveAesKey(encryptionSecret(this.env));
    }
    return this.keyPromise;
  }

  private async load(): Promise<StoredSession> {
    return (await this.state.storage.get<StoredSession>("session")) ?? {};
  }

  private async save(record: StoredSession): Promise<void> {
    await this.state.storage.put("session", record);
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const kindParam = url.searchParams.get("kind");
    const metaOnly = url.searchParams.get("meta_only") === "1";

    if (request.method === "GET") {
      const record = await this.load();
      if (isExpired(record.meta)) {
        return Response.json(
          { error: "Session expired", meta: record.meta },
          { status: 410 },
        );
      }
      if (metaOnly) {
        if (!record.meta) {
          return new Response("Not found", { status: 404 });
        }
        return Response.json({ meta: record.meta });
      }

      const key = await this.aesKey();
      const out: Record<string, unknown> = {};
      const kinds =
        kindParam && SESSION_KINDS.includes(kindParam as SessionKind)
          ? [kindParam as SessionKind]
          : [...SESSION_KINDS];

      for (const k of kinds) {
        const enc = record[k];
        if (enc) {
          out[k] = await decryptJson(key, enc);
        }
      }
      if (record.meta) {
        out.meta = record.meta;
      }
      if (Object.keys(out).length === 0) {
        return new Response("Not found", { status: 404 });
      }
      return Response.json(out);
    }

    if (request.method === "PUT") {
      let body: Record<string, unknown>;
      try {
        body = (await request.json()) as Record<string, unknown>;
      } catch {
        return new Response("Invalid JSON body", { status: 400 });
      }

      const record = await this.load();
      const key = await this.aesKey();
      const now = new Date().toISOString();

      for (const k of SESSION_KINDS) {
        if (k in body && body[k] !== undefined) {
          record[k] = await encryptJson(key, body[k]);
        }
      }

      const incomingMeta: Partial<SessionMeta> =
        typeof body.meta === "object" && body.meta !== null
          ? (body.meta as Partial<SessionMeta>)
          : {};
      record.meta = mergeMeta(record.meta, incomingMeta, now);

      await this.save(record);
      return Response.json({ ok: true, meta: record.meta });
    }

    if (request.method === "DELETE") {
      await this.state.storage.delete("session");
      return Response.json({ ok: true });
    }

    return new Response("Method not allowed", { status: 405 });
  }
}
