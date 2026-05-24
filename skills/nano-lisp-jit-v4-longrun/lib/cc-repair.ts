import { writeFileSync } from "node:fs";
import { join } from "node:path";
import { $ } from "bun";
import { ccPath, labRoot, lispjitIr, repoRoot } from "./paths.ts";

export async function runCcRepair(lo: number, hi: number): Promise<number> {
  const cc = ccPath();
  const taskPath = join(labRoot, "tools", `cc-task-repair-wave${lo}-${hi}.txt`);
  const logPath = `/tmp/cc-repair-${lo}-${hi}.log`;
  const prompt = `Gate failed after v4 apply batch ${lo}-${hi}.
Fix lab/nano-lisp-jit until: export NANO_SLICE_COMPILER=native && bash build_nano_jit.sh && bash run.sh exits 0.
Do not commit. Final line: CC_DONE tests.pass=N
`;
  writeFileSync(taskPath, prompt);
  const proc = Bun.spawn(
    [cc, "-p", "--dangerously-skip-permissions", "--add-dir", labRoot, "--add-dir", lispjitIr],
    { stdin: new Blob([prompt]), stdout: "pipe", stderr: "pipe", cwd: repoRoot },
  );
  const out = await new Response(proc.stdout).text();
  writeFileSync(logPath, out);
  const code = await proc.exited;
  if (code !== 0) throw new Error(`cc repair exited ${code}`);
  const m = out.match(/CC_DONE tests\.pass=(\d+)/);
  if (!m) throw new Error("cc repair missing CC_DONE line");
  return parseInt(m[1]!, 10);
}
