/** Durable Object id helpers + stubs for encrypted session blobs. */

export function sessionStoreId(
  owner: string,
  site: string,
  profile: string,
): string {
  return `vault/${owner}/${site}/${profile}`;
}

export function registryId(owner: string): string {
  return `registry/${owner}`;
}

export function sessionStub(
  env: Env,
  owner: string,
  site: string,
  profile: string,
): DurableObjectStub {
  const id = env.SESSION_STORE.idFromName(sessionStoreId(owner, site, profile));
  return env.SESSION_STORE.get(id);
}
