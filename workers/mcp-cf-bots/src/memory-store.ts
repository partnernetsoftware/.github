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

/** Vectorize row id — unique per owner + memory uuid. */
export function memoryVectorId(owner: string, memId: string): string {
  return `${owner}::${memId}`;
}
