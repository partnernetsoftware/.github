import { existsSync, mkdirSync, readFileSync, writeFileSync, unlinkSync } from "node:fs";
import { $ } from "bun";
import { applyBatch } from "./apply.ts";
import { runCcRepair } from "./cc-repair.ts";
import { readTestsPass, runGate } from "./gate.ts";
import { lockPath, labRoot, repoRoot } from "./paths.ts";
import { bumpState, loadState, setStatus } from "./state.ts";

export type LoopOpts = {
  batches: number;
  timeoutSec: number;
  goal: string;
  retries: number;
  autoCommit: boolean;
};

function log(msg: string): void {
  const t = new Date().toISOString().slice(11, 19);
  console.log(`[v4-longrun ${t}] ${msg}`);
}

function acquireLock(): void {
  mkdirSync(`${labRoot}/.build`, { recursive: true });
  if (existsSync(lockPath)) throw new Error(`lock held: ${lockPath}`);
  writeFileSync(lockPath, String(process.pid));
}

function releaseLock(): void {
  try {
    unlinkSync(lockPath);
  } catch {
    /* ignore */
  }
}

function goalMet(nextWave: number, goal: string): boolean {
  if (!goal) return false;
  if (goal.startsWith("terminal")) {
    const p = `${labRoot}/v4/PROGRESS.md`;
    return existsSync(p) && /100%|~100%/.test(readFileSync(p, "utf8"));
  }
  const m = goal.match(/^wave(\d+)$/);
  return m ? nextWave > parseInt(m[1]!, 10) : false;
}

async function tryBatch(lo: number, hi: number, retries: number): Promise<void> {
  for (let a = 1; a <= retries; a++) {
    try {
      await applyBatch(lo, hi);
    } catch (e) {
      log(`apply warn: ${e}`);
    }
    try {
      await runGate();
      return;
    } catch {
      log(`gate fail attempt ${a} — cc repair`);
      await runCcRepair(lo, hi);
      await runGate();
      return;
    }
  }
  throw new Error(`batch ${lo}-${hi} failed after ${retries} retries`);
}

async function commitBatch(lo: number, hi: number, tp: number): Promise<void> {
  await $`git add lab/nano-lisp-jit lab/lispjit-ir/nano_bootstrap.c`.cwd(repoRoot).nothrow();
  const diff = await $`git diff --cached --quiet`.cwd(repoRoot).nothrow();
  if (diff.exitCode === 0) {
    log("nothing to commit");
    return;
  }
  await $`git commit -m ${`v4 wave${lo}-${hi}: longrun skill (tests.pass=${tp})`}`.cwd(repoRoot);
  await $`git push -u origin ${await currentBranch()}`.cwd(repoRoot).nothrow();
}

async function currentBranch(): Promise<string> {
  return (await $`git branch --show-current`.cwd(repoRoot).text()).trim();
}

export async function runLoop(opts: LoopOpts): Promise<void> {
  acquireLock();
  setStatus("running");
  const start = Date.now();
  let done = 0;
  try {
    while (done < opts.batches) {
      if ((Date.now() - start) / 1000 >= opts.timeoutSec) {
        throw new Error(`timeout ${opts.timeoutSec}s`);
      }
      const lo = loadState().next_wave;
      const hi = lo + 2;
      if (goalMet(lo, opts.goal)) {
        log(`GOAL ${opts.goal} met`);
        return;
      }
      log(`batch ${done + 1}/${opts.batches} waves ${lo}-${hi}`);
      await tryBatch(lo, hi, opts.retries);
      const tp = readTestsPass();
      bumpState(lo, hi, tp);
      if (opts.autoCommit) await commitBatch(lo, hi, tp);
      log(`OK tests.pass=${tp} next_wave=${hi + 1}`);
      done++;
    }
    log(`LOOP_OK batches=${done} next=${loadState().next_wave}`);
  } catch (e) {
    setStatus("failed");
    throw e;
  } finally {
    setStatus("idle");
    releaseLock();
  }
}
