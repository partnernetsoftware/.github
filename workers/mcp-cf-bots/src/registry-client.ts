import { registryId } from "./session-store";

export type RegistryFilters = {
  source?: string;
  tag?: string;
};

function entriesUrl(filters?: RegistryFilters): string {
  const url = new URL("https://registry.internal/entries");
  if (filters?.source) {
    url.searchParams.set("source", filters.source);
  }
  if (filters?.tag) {
    url.searchParams.set("tag", filters.tag);
  }
  return url.toString();
}

export function registryStub(env: Env, owner: string): DurableObjectStub {
  return env.REGISTRY.get(env.REGISTRY.idFromName(registryId(owner)));
}

export async function fetchRegistryEntries(
  env: Env,
  owner: string,
  filters?: RegistryFilters,
): Promise<Response> {
  return registryStub(env, owner).fetch(entriesUrl(filters));
}
