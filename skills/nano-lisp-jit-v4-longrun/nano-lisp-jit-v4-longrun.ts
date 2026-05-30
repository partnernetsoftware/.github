#!/usr/bin/env bun
/**
 * nano-lisp-jit v4 长程 skill — state SSOT → apply → gate → [cc repair] → bump → commit
 *
 * Usage:
 *   bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts show
 *   bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 92 94
 *   bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts gate
 *   bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop
 *   bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop --batches 2 --goal wave95 --no-commit
 */
import { applyBatch } from "./lib/apply.ts";
import { runGate, readTestsPass } from "./lib/gate.ts";
import { runLoop, type LoopOpts } from "./lib/loop.ts";
import { loadState, syncTodo, setStatus, bumpState } from "./lib/state.ts";

function usage(): never {
  console.log(`commands: show | sync | apply LO HI | gate | bump LO HI TP | loop [opts]
loop opts: --batches N --gate-every N --goal waveN|terminal --timeout SEC --retries N --no-commit`);
  process.exit(1);
}

function parseLoopArgs(args: string[]): LoopOpts {
  const opts: LoopOpts = {
    batches: parseInt(process.env.V4_LONGRUN_BATCHES ?? "3", 10),
    timeoutSec: parseInt(process.env.V4_LONGRUN_TIMEOUT_SEC ?? "7200", 10),
    goal: process.env.V4_LONGRUN_GOAL ?? "",
    retries: parseInt(process.env.V4_LONGRUN_RETRIES ?? "2", 10),
    autoCommit: process.env.V4_LONGRUN_COMMIT !== "0",
    gateEvery: parseInt(process.env.V4_LONGRUN_GATE_EVERY ?? "1", 10),
  };
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === "--batches") opts.batches = parseInt(args[++i]!, 10);
    else if (a === "--gate-every") opts.gateEvery = parseInt(args[++i]!, 10);
    else if (a === "--goal") opts.goal = args[++i] ?? "";
    else if (a === "--timeout") opts.timeoutSec = parseInt(args[++i]!, 10);
    else if (a === "--retries") opts.retries = parseInt(args[++i]!, 10);
    else if (a === "--no-commit") opts.autoCommit = false;
  }
  return opts;
}

const [cmd, ...rest] = process.argv.slice(2);
if (!cmd) usage();

switch (cmd) {
  case "show": {
    const st = loadState();
    console.log(JSON.stringify(st, null, 2));
    break;
  }
  case "sync":
    syncTodo(loadState());
    console.log("synced LONG-RUN-TODO.md");
    break;
  case "apply":
    await applyBatch(parseInt(rest[0]!, 10), parseInt(rest[1]!, 10));
    break;
  case "gate": {
    const tp = await runGate();
    console.log(`GATE_OK tests.pass=${tp}`);
    break;
  }
  case "bump":
    console.log(JSON.stringify(bumpState(parseInt(rest[0]!, 10), parseInt(rest[1]!, 10), parseInt(rest[2]!, 10))));
    break;
  case "set-status":
    setStatus(rest[0] as "idle" | "running" | "failed");
    break;
  case "loop":
    await runLoop(parseLoopArgs(rest));
    break;
  case "pointer":
    console.log(loadState().next_wave);
    break;
  default:
    usage();
}
