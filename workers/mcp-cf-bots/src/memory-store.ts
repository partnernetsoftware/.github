export function memoryDoId(owner: string): string {
  return `memory/${owner}`;
}

export function memoryStub(env: Env, owner: string): DurableObjectStub {
  if (!env.MEMORY_STORE) {
    throw new Error("MEMORY_STORE binding is not configured");
  }
  return env.MEMORY_STORE.get(
    env.MEMORY_STORE.idFromName(memoryDoId(owner)),
  );
}

const VECTOR_ID_SEP = "::";

/** Vectorize row id — unique per owner + memory uuid. */
export function memoryVectorId(owner: string, memId: string): string {
  return `${owner}${VECTOR_ID_SEP}${memId}`;
}

export function parseMemoryVectorId(
  vectorId: string,
): { owner: string; chunkId: string } | null {
  const i = vectorId.indexOf(VECTOR_ID_SEP);
  if (i <= 0) {
    return null;
  }
  return { owner: vectorId.slice(0, i), chunkId: vectorId.slice(i + VECTOR_ID_SEP.length) };
}
