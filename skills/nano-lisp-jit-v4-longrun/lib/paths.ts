import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const skillDir = dirname(fileURLToPath(import.meta.url));
export const skillRoot = dirname(skillDir);
export const repoRoot = join(skillRoot, "../..");
export const labRoot = join(repoRoot, "lab/nano-lisp-jit");
export const statePath = join(labRoot, "v4/longrun-state.json");
export const todoPath = join(labRoot, "v4/LONG-RUN-TODO.md");
export const genScript = join(labRoot, "tools/gen-v4-wave-batch.py");
export const evalPath = join(labRoot, "v4/EVAL.md");
export const lockPath = join(labRoot, ".build/v4-longrun.lock");
export const resultsPath = join(labRoot, ".build/results.txt");
export const lispjitIr = join(repoRoot, "lab/lispjit-ir");

export function ccPath(): string {
  return process.env.V4_LONGRUN_CC ?? `${process.env.HOME}/.local/bin/cc-huoshan1-ds4pro`;
}
