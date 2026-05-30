#!/usr/bin/env bun
/** Agent 用紧凑 outline：PART 章节 + 段内顶层符号。替代通读大文件。 */
import { readFileSync } from "fs";
import { basename, resolve } from "path";

type Part = { name: string; line: number };
type Sym = { kind: string; name: string; line: number };

const SYM_RE =
  /^(?:(?:export\s+)?(?:async\s+)?function\s+(\w+)|(?:export\s+)?class\s+(\w+)|(?:export\s+)?(?:type|interface)\s+(\w+)|(?:export\s+)?const\s+(\w+)\s*=)/;

function usage(): void {
  process.stderr.write(`usage: outline.ts <file> [--part NAME] [--json] [--read N]

  outline.ts tools/tui.ts              # 全文件目录 (~22 段 + 符号摘要)
  outline.ts tools/tui.ts --part drive-bg
  outline.ts tools/tui.ts --part preview --read 80   # 附带 read 工具建议
`);
}

function parseArgs(argv: string[]) {
  let file = "";
  let part: string | null = null;
  let json = false;
  let readLines: number | null = null;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--json") json = true;
    else if (a === "--part" && argv[i + 1]) part = argv[++i];
    else if (a === "--read" && argv[i + 1]) readLines = parseInt(argv[++i], 10) || null;
    else if (a === "--help" || a === "-h") {
      usage();
      process.exit(0);
    } else if (!a.startsWith("-")) file = a;
  }
  return { file, part, json, readLines };
}

function scanParts(lines: string[]): Part[] {
  const out: Part[] = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^\/\/ PART:([^\s]+)/);
    if (m) out.push({ name: m[1], line: i + 1 });
  }
  return out;
}

function scanSymbols(lines: string[], start: number, end: number): Sym[] {
  const out: Sym[] = [];
  for (let i = start; i < end; i++) {
    const m = lines[i].match(SYM_RE);
    if (!m) continue;
    const name = m[1] ?? m[2] ?? m[3] ?? m[4];
    let kind = "fn";
    if (m[2]) kind = "class";
    else if (m[3]) kind = lines[i].includes("interface") ? "interface" : "type";
    else if (m[4]) kind = "const";
    out.push({ kind, name, line: i + 1 });
  }
  return out;
}

function partEnd(parts: Part[], idx: number, totalLines: number): number {
  return idx + 1 < parts.length ? parts[idx + 1].line - 1 : totalLines;
}

function symBrief(syms: Sym[], max = 8): string {
  if (syms.length === 0) return "(no top-level symbols)";
  const head = syms.slice(0, max).map((s) => `${s.kind} ${s.name}`);
  const tail = syms.length > max ? ` …+${syms.length - max}` : "";
  return head.join(", ") + tail;
}

function main(): void {
  const { file, part, json, readLines } = parseArgs(process.argv.slice(2));
  if (!file) {
    usage();
    process.exit(2);
  }
  const path = resolve(file);
  const lines = readFileSync(path, "utf8").split("\n");
  const parts = scanParts(lines);
  const total = lines.length;

  if (parts.length === 0) {
    process.stderr.write(`no // PART: markers in ${path}\n`);
    process.exit(1);
  }

  if (part) {
    const idx = parts.findIndex((p) => p.name === part || p.name.includes(part));
    if (idx < 0) {
      process.stderr.write(`unknown part: ${part}\navailable: ${parts.map((p) => p.name).join(", ")}\n`);
      process.exit(1);
    }
    const p = parts[idx];
    const end = partEnd(parts, idx, total);
    const syms = scanSymbols(lines, p.line - 1, end);
    const payload = {
      file: path,
      part: p.name,
      startLine: p.line,
      endLine: end,
      lineCount: end - p.line + 1,
      symbols: syms,
      readHint: readLines ? { offset: p.line, limit: readLines } : undefined,
    };
    if (json) {
      console.log(JSON.stringify(payload, null, 2));
      return;
    }
    console.log(`${basename(path)}  PART:${p.name}  L${p.line}–L${end} (${payload.lineCount} lines)`);
    for (const s of syms) console.log(`  L${s.line}  ${s.kind} ${s.name}`);
    if (readLines) console.log(`\nread: offset=${p.line} limit=${readLines}`);
    return;
  }

  const sections = parts.map((p, i) => {
    const end = partEnd(parts, i, total);
    const syms = scanSymbols(lines, p.line - 1, end);
    return { ...p, endLine: end, lineCount: end - p.line + 1, symbols: syms };
  });

  if (json) {
    console.log(JSON.stringify({ file: path, totalLines: total, parts: sections }, null, 2));
    return;
  }

  console.log(`# ${basename(path)} (${total} lines, ${parts.length} parts)\n`);
  for (const s of sections) {
    console.log(`L${String(s.line).padStart(4)}  PART:${s.name}  (${s.lineCount} lines)`);
    console.log(`       ${symBrief(s.symbols)}`);
  }
  console.log(`\n# drill: outline.ts ${file} --part <name> [--read 80]`);
}

main();
