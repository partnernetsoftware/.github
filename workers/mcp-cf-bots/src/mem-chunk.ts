import { memChunkSize, memMaxChunkBytes } from "./mem-config";

export type ContentChunk = { index: number; text: string };

/** Split long text into chunks for embedding (paragraph-aware). */
export function splitMemoryContent(text: string, chunkSize: number): ContentChunk[] {
  const trimmed = text.trim();
  if (!trimmed) {
    return [];
  }
  if (trimmed.length <= chunkSize) {
    return [{ index: 0, text: trimmed }];
  }

  const parts = trimmed.split(/\n\n+/);
  const chunks: ContentChunk[] = [];
  let buf = "";

  const flush = () => {
    const t = buf.trim();
    if (t) {
      chunks.push({ index: chunks.length, text: t });
    }
    buf = "";
  };

  for (const part of parts) {
    if (!part) {
      continue;
    }
    if (part.length > chunkSize) {
      flush();
      for (let i = 0; i < part.length; i += chunkSize) {
        chunks.push({ index: chunks.length, text: part.slice(i, i + chunkSize) });
      }
      continue;
    }
    const next = buf ? `${buf}\n\n${part}` : part;
    if (next.length > chunkSize) {
      flush();
      buf = part;
    } else {
      buf = next;
    }
  }
  flush();

  return chunks.length > 0 ? chunks : [{ index: 0, text: trimmed.slice(0, chunkSize) }];
}

export function assertContentWithinLimit(content: string, env: Env): void {
  const max = memMaxChunkBytes(env);
  if (content.length > max) {
    throw new Error(`content exceeds MAX_MEM_CHUNK_BYTES (${max})`);
  }
}

export function splitForStorage(content: string, env: Env): ContentChunk[] {
  assertContentWithinLimit(content, env);
  return splitMemoryContent(content, memChunkSize(env));
}
