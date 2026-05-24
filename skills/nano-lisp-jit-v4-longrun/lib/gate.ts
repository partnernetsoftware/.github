import { readFileSync, existsSync } from "node:fs";
import { $ } from "bun";
import { labRoot, resultsPath } from "./paths.ts";

export async function runGate(): Promise<number> {
  process.env.NANO_SLICE_COMPILER ??= "native";
  await $`bash build_nano_jit.sh`.cwd(labRoot);
  await $`bash run.sh`.cwd(labRoot);
  return readTestsPass();
}

export function readTestsPass(): number {
  if (!existsSync(resultsPath)) return 0;
  const lines = readFileSync(resultsPath, "utf8").split("\n");
  for (let i = lines.length - 1; i >= 0; i--) {
    const m = lines[i]?.match(/^tests\.pass=(\d+)/);
    if (m) return parseInt(m[1]!, 10);
  }
  return 0;
}
