import { existsSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { $ } from "bun";
import { labRoot, resultsPath } from "./paths.ts";
import { repoRoot } from "./paths.ts";

const STAMP = join(labRoot, ".build/v4-last-build.stamp");

function bootstrapTouched(): boolean {
  const paths = [
    join(repoRoot, "lab/lispjit-ir/nano_bootstrap.c"),
    join(repoRoot, "lab/lispjit-ir/nano_elf64.c"),
  ];
  if (!existsSync(STAMP)) return true;
  const stamp = statSync(STAMP).mtimeMs;
  return paths.some((p) => existsSync(p) && statSync(p).mtimeMs > stamp);
}

export async function runGate(opts?: { forceBuild?: boolean }): Promise<number> {
  process.env.NANO_SLICE_COMPILER ??= "native";
  if (opts?.forceBuild || bootstrapTouched()) {
    await $`bash build_nano_jit.sh`.cwd(labRoot);
    await $`touch ${STAMP}`.cwd(labRoot);
  } else {
    console.log("[v4-gate] skip build (bootstrap unchanged)");
  }
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
