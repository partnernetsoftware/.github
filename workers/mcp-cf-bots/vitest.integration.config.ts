import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

/** DO + FTS integration tests (Miniflare). Run: npm run test:integration */
export default defineWorkersConfig({
  test: {
    include: ["test/integration/**/*.test.ts"],
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.toml" },
        /** SQLite DO + FTS leaves WAL files; disable per-test storage pop (see CF known issues). */
        isolatedStorage: false,
        singleWorker: true,
        miniflare: {
          bindings: {
            VAULT_TOKEN: "test-vault-token-for-integration",
          },
        },
      },
    },
  },
});
