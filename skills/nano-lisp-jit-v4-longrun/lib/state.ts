import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { statePath, todoPath } from "./paths.ts";

export type LongrunState = {
  next_wave: number;
  next_add: number;
  last_tests_pass: number;
  last_batch?: { lo: number; hi: number };
  status: "idle" | "running" | "failed";
  updated_at?: string;
};

export function loadState(): LongrunState {
  if (!existsSync(statePath)) {
    return { next_wave: 86, next_add: 81, last_tests_pass: 0, status: "idle" };
  }
  return JSON.parse(readFileSync(statePath, "utf8")) as LongrunState;
}

export function saveState(st: LongrunState): void {
  st.updated_at = new Date().toISOString();
  writeFileSync(statePath, JSON.stringify(st, null, 2) + "\n");
}

export function syncTodo(st: LongrunState): void {
  if (!existsSync(todoPath)) return;
  let t = readFileSync(todoPath, "utf8");
  t = t.replace(/下一波 \| \*\*\d+\*\*/, `下一波 | **${st.next_wave}**`);
  t = t.replace(/下一 add \| \*\*\d+\*\*/, `下一 add | **${st.next_add}**`);
  t = t.replace(/tests\.pass=\d+/, `tests.pass=${st.last_tests_pass}`);
  writeFileSync(todoPath, t);
}

export function bumpState(lo: number, hi: number, testsPass: number): LongrunState {
  const st = loadState();
  st.next_wave = hi + 1;
  st.next_add = st.next_add + (hi - lo + 1);
  st.last_tests_pass = testsPass;
  st.last_batch = { lo, hi };
  st.status = "idle";
  saveState(st);
  syncTodo(st);
  return st;
}

export function setStatus(status: LongrunState["status"]): void {
  const st = loadState();
  st.status = status;
  saveState(st);
}
