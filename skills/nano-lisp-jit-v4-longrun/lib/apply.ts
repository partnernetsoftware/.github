import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { $ } from "bun";
import { evalPath, genScript, labRoot } from "./paths.ts";

export function assertWavesInGen(lo: number, hi: number): void {
  const t = readFileSync(genScript, "utf8");
  const missing: number[] = [];
  for (let w = lo; w <= hi; w++) {
    if (!t.includes(`    ${w}: dict(`)) missing.push(w);
  }
  if (missing.length) {
    throw new Error(`WAVES missing in gen-v4-wave-batch.py: ${missing.join(", ")}`);
  }
}

export function appendEval(lo: number, hi: number): void {
  const sec = lo === hi ? `wave${lo}` : `wave${lo}–${hi}`;
  if (!existsSync(evalPath)) return;
  const cur = readFileSync(evalPath, "utf8");
  if (cur.includes(sec)) return;
  const block = `
## ${sec}（longrun apply · ≤4 轨/波）

| 维度 | wave${hi} 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | skill apply |

**方法**：\`bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply ${lo} ${hi}\`
`;
  writeFileSync(evalPath, cur.trimEnd() + "\n" + block);
}

export async function applyBatch(lo: number, hi: number): Promise<void> {
  assertWavesInGen(lo, hi);
  await $`python3 ${genScript} ${lo} ${hi}`.cwd(labRoot).quiet();
  appendEval(lo, hi);
  console.log(`APPLY_OK ${lo}-${hi}`);
}
