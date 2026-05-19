#!/usr/bin/env bun
/**
 * CLI: `tui help`（可 ln -s ~/.local/bin/tui）
 * tmux: `tui install-tmux` → $HOME/tmux/bin/tmux
 * v0.3 agent: `tui agent register|send|inbox|wait|list` — window 的 @agent 为纯名 id；inbox ~/.tui/inbox/<name>.jsonl
 */
import {
  accessSync, appendFileSync, chmodSync, constants, copyFileSync, existsSync,
  mkdirSync, readFileSync, rmSync, writeFileSync,
} from "fs";
import { randomUUID } from "crypto";
import { homedir } from "os";
import { join } from "path";

const PREVIEW_DELAY = 1000;
const RETURN_FROM_ATTACH_DELAY = 120; // detach 后静默 sync tree / restore status
const PREVIEW_LINES = 80;

const TUI_CONFIG = {
  VERSION: '0.3.3',
  VIEWER_SESSION: `__tui_viewer__`,
  TUI_KEYTABLE: "tui_empty",
  REMARK_KEY: "@remark",
  AGENT_KEY: "@agent",
  TITLE: "TMUX 驾驶舱",
  TMUX_HOME: join(homedir(), "tmux"),
  TMUX_PORTABLE_BIN: join(homedir(), "tmux", "bin", "tmux"),
  DATA_DIR: join(homedir(), ".tui"),
  INBOX_DIR: join(homedir(), ".tui", "inbox"),
  READ_DIR: join(homedir(), ".tui", "read"),
  // BUS_PATH: join(homedir(), ".tui", "bus.jsonl"), // OBSERVER_PAUSED
} as const;

type AgentKind = "msg" | "reply";

interface AgentEnvelope {
  id?: string;
  ts: string;
  from: string;
  to: string;
  fromTarget?: string;
  toTarget?: string;
  corr: string;
  kind: AgentKind;
  status?: "sent" | "delivered" | "read" | "replied" | "error";
  summary?: string;
  body: string;
}

/** tmux/tmux-builds 官方 static（v3.6a） */
const TMUX_STATIC_RELEASE = {
  version: "3.6a",
  base: "https://github.com/tmux/tmux-builds/releases/download/v3.6a",
  assets: {
    "darwin-arm64": { file: "tmux-3.6a-macos-arm64.tar.gz", sha256: "12b5b9f8696e1286897d946649c0a80d0169dd76e018d34476a1fbd34de89a0f" },
    "darwin-x64": { file: "tmux-3.6a-macos-x86_64.tar.gz", sha256: "b9b12eaeba43acf5671acf3857d947525440b544185a8db34ea557199a090251" },
    "linux-arm64": { file: "tmux-3.6a-linux-arm64.tar.gz", sha256: "bb5afd9d646df54a7d7c66e198aa22c7d293c7453534f1670f7c540534db8b5e" },
    "linux-x64": { file: "tmux-3.6a-linux-x86_64.tar.gz", sha256: "c0a772a5e6ca8f129b0111d10029a52e02bcbc8352d5a8c0d3de8466a1e59c2e" },
  } as Record<string, { file: string; sha256: string }>,
} as const;

// ── AnsiScreen ──

class AnsiScreen {
  private ESC = "\x1b[";
  private RESET = `${this.ESC}0m`;
  private MOUSE_ON = "\x1b[?1006h\x1b[?1000h";
  private MOUSE_OFF = "\x1b[?1000l\x1b[?1006l";

  wrap(code: string) { return (s: string) => `${this.ESC}${code}m${s}${this.RESET}`; }
  dim = this.wrap("2");
  bold = this.wrap("1");
  inv = this.wrap("7");
  cyan = this.wrap("36");
  yellow = this.wrap("33");
  gold = this.wrap("40;93");
  /** ASU: gold #FFC627 bg, maroon #8C1D40 fg */
  asuLogo = this.wrap("48;5;220;38;5;88;1");
  gray = this.wrap("90");

  write(s: string) { process.stdout.write(s); }
  clear() { this.write(`${this.ESC}2J${this.ESC}H`); }
  cursorAt(r: number, c: number) { this.write(`${this.ESC}${r};${c}H`); }
  hideCursor() { this.write(`${this.ESC}?25l`); }
  showCursor() { this.write(`${this.ESC}?25h`); }
  enableMouse() { this.write(this.MOUSE_ON); }
  disableMouse() { this.write(this.MOUSE_OFF); }
  private altOn = false;
  enterAltScreen() {
    if (this.altOn) return;
    this.write("\x1b[?1049h\x1b[2J\x1b[H");
    this.altOn = true;
  }
  leaveAltScreen() {
    if (!this.altOn) return;
    this.write("\x1b[?1049l");
    this.altOn = false;
  }
  getSize(): [number, number] {
    return [process.stdout.columns || 80, process.stdout.rows || 24];
  }
}
const screen = new AnsiScreen();

let tmuxQuietDepth = 0;
let _resolvedTmuxBin: string | null = null;

function isExecutable(p: string): boolean {
  try {
    accessSync(p, constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

function tmuxPlatformKey(): string | null {
  const os = process.platform === "darwin" ? "darwin" : process.platform === "linux" ? "linux" : null;
  const arch = process.arch === "arm64" ? "arm64" : process.arch === "x64" ? "x64" : null;
  if (!os || !arch) return null;
  return `${os}-${arch}`;
}

function resolveTmuxPath(): string | null {
  if (process.env.TMUX_BIN) {
    const p = process.env.TMUX_BIN;
    if (isExecutable(p)) return p;
  }
  if (isExecutable(TUI_CONFIG.TMUX_PORTABLE_BIN)) return TUI_CONFIG.TMUX_PORTABLE_BIN;
  const onPath = Bun.which("tmux");
  if (onPath) return onPath;
  return null;
}

function tmuxBin(): string {
  if (!_resolvedTmuxBin) {
    const p = resolveTmuxPath();
    if (!p) throw new Error("tmux not found");
    _resolvedTmuxBin = p;
  }
  return _resolvedTmuxBin;
}

function resetTmuxBinCache() {
  _resolvedTmuxBin = null;
}

function sha256File(path: string): string {
  if (Bun.which("shasum")) {
    const r = Bun.spawnSync(["shasum", "-a", "256", path], { stdout: "pipe" });
    return r.stdout?.toString().trim().split(/\s+/)[0] ?? "";
  }
  const r = Bun.spawnSync(["sha256sum", path], { stdout: "pipe" });
  return r.stdout?.toString().trim().split(/\s+/)[0] ?? "";
}

function installTmuxPortable(force = false): number {
  const key = tmuxPlatformKey();
  const asset = key ? TMUX_STATIC_RELEASE.assets[key] : undefined;
  if (!asset) {
    process.stderr.write(`不支持的平台 ${process.platform}/${process.arch}\n`);
    return 1;
  }
  if (!force && isExecutable(TUI_CONFIG.TMUX_PORTABLE_BIN)) {
    process.stdout.write(`已存在: ${TUI_CONFIG.TMUX_PORTABLE_BIN}\n`);
    return 0;
  }
  const binDir = join(TUI_CONFIG.TMUX_HOME, "bin");
  const cacheDir = join(TUI_CONFIG.TMUX_HOME, ".cache");
  mkdirSync(binDir, { recursive: true });
  mkdirSync(cacheDir, { recursive: true });
  const archive = join(cacheDir, asset.file);
  const url = `${TMUX_STATIC_RELEASE.base}/${asset.file}`;
  process.stderr.write(`下载 ${url}\n`);
  const dl = Bun.spawnSync(["curl", "-fsSL", "-o", archive, url], { stdout: "pipe", stderr: "pipe" });
  if (dl.exitCode !== 0) {
    process.stderr.write(`下载失败: ${dl.stderr?.toString() || "curl error"}\n`);
    return 1;
  }
  const got = sha256File(archive);
  if (got !== asset.sha256) {
    process.stderr.write(`校验失败: expected ${asset.sha256} got ${got}\n`);
    return 1;
  }
  const extractDir = join(cacheDir, asset.file.replace(/\.tar\.gz$/, ""));
  rmSync(extractDir, { recursive: true, force: true });
  mkdirSync(extractDir, { recursive: true });
  const untar = Bun.spawnSync(["tar", "-xzf", archive, "-C", extractDir], { stdout: "pipe", stderr: "pipe" });
  if (untar.exitCode !== 0) {
    process.stderr.write(`解包失败: ${untar.stderr?.toString()}\n`);
    return 1;
  }
  const extracted = join(extractDir, "tmux");
  if (!isExecutable(extracted)) {
    process.stderr.write(`解包后未找到可执行文件: ${extracted}\n`);
    return 1;
  }
  copyFileSync(extracted, TUI_CONFIG.TMUX_PORTABLE_BIN);
  chmodSync(TUI_CONFIG.TMUX_PORTABLE_BIN, 0o755);
  if (process.platform === "darwin") {
    Bun.spawnSync(["xattr", "-dr", "com.apple.quarantine", TUI_CONFIG.TMUX_HOME], { stdout: "pipe", stderr: "pipe" });
  }
  resetTmuxBinCache();
  const ver = Bun.spawnSync([TUI_CONFIG.TMUX_PORTABLE_BIN, "-V"], { stdout: "pipe" }).stdout?.toString().trim();
  process.stdout.write(`已安装 → ${TUI_CONFIG.TMUX_PORTABLE_BIN}  (${ver})\n`);
  return 0;
}

function installTmuxSystem(): number {
  if (process.platform === "darwin") {
    const brew = Bun.which("brew");
    if (!brew) {
      process.stderr.write("未找到 brew，请用: tui install-tmux（便携版）\n");
      return 1;
    }
    process.stderr.write("brew install tmux …\n");
    const r = Bun.spawnSync([brew, "install", "tmux"], { stdin: "inherit", stdout: "inherit", stderr: "inherit" });
    resetTmuxBinCache();
    return r.exitCode ?? 1;
  }
  if (process.platform === "linux") {
    if (Bun.which("apt-get")) {
      process.stderr.write("请运行: sudo apt-get update && sudo apt-get install -y tmux\n");
    } else if (Bun.which("dnf")) {
      process.stderr.write("请运行: sudo dnf install -y tmux\n");
    } else {
      process.stderr.write("请用: tui install-tmux（便携版，无需 root）\n");
    }
    return 1;
  }
  process.stderr.write(`不支持的平台 ${process.platform}\n`);
  return 1;
}

function withTmuxQuiet<T>(fn: () => T): T {
  tmuxQuietDepth++;
  try {
    return fn();
  } finally {
    tmuxQuietDepth--;
  }
}

// ── 纯工具函数 ──

const ANSI_RE = /\x1b\[[0-9;]*[a-zA-Z]/g;
function stripAnsi(s: string): string {
  return s.replace(ANSI_RE, "");
}
function charW(cp: number): number {
  if (
    (cp >= 0x1100 && cp <= 0x115f) ||
    (cp >= 0x2e80 && cp <= 0x303e) ||
    (cp >= 0x3041 && cp <= 0x33ff) ||
    (cp >= 0x3400 && cp <= 0x4dbf) ||
    (cp >= 0x4e00 && cp <= 0x9fff) ||
    (cp >= 0xa000 && cp <= 0xa4cf) ||
    (cp >= 0xac00 && cp <= 0xd7a3) ||
    (cp >= 0xf900 && cp <= 0xfaff) ||
    (cp >= 0xfe30 && cp <= 0xfe4f) ||
    (cp >= 0xff00 && cp <= 0xff60) ||
    (cp >= 0xffe0 && cp <= 0xffe6)
  )
    return 2;
  return 1;
}
function visW(s: string): number {
  const t = stripAnsi(s);
  let w = 0;
  for (const ch of t) w += charW(ch.codePointAt(0)!);
  return w;
}
function truncVis(s: string, max: number): string {
  const t = stripAnsi(s);
  let w = 0;
  let out = "";
  for (const ch of t) {
    const cw = charW(ch.codePointAt(0)!);
    if (w + cw > max) break;
    out += ch;
    w += cw;
  }
  return out;
}
function padVis(s: string, target: number): string {
  const w = visW(s);
  if (w >= target) return s;
  return s + " ".repeat(target - w);
}

// tmux 调用统一走 backend 抽象（保留接口与单例，回到单文件实现）
// IMultiplexerBackend — 多路复用器后端抽象
// 第一版接口直接以 tmux 语义命名，目的是把"调 tmux CLI 的动作"集中起来。
// 后续可接入 zellij / screen / 自研 backend。保持同步 spawnSync 风格，不异步化。
interface IMultiplexerBackend {
  // ── 会话 / 窗口 ──
  listSessions(fmt?: string): string[];
  listWindows(sess: string, fmt: string): string[];
  newSession(name: string): unknown;
  newGroupedSession(name: string, srcSess: string): unknown;
  killSession(name: string): unknown;
  killWindow(target: string): unknown;
  renameSession(oldName: string, newName: string): unknown;
  renameWindow(target: string, newName: string): unknown;
  newWindow(sess: string, name: string): unknown;
  selectWindow(target: string): unknown;
  attach(name: string): unknown;
  capturePane(target: string, startN: number, endArg: string): unknown;
  /** TUI preview 异步；CLI 用 capturePaneText */
  capturePaneText(target: string, startN: number, endArg?: string): string;
  sendKeys(target: string, text: string): unknown;
  loadBuffer(target: string, file: string): unknown;
  pasteBuffer(target: string): unknown;

  // ── 选项 ──
  getGlobalOption(key: string): string;
  setGlobalOption(key: string, val: string): unknown;
  setSessionOption(target: string, key: string, val: string): unknown;
  unsetSessionOption(target: string, key: string): unknown;
  showSessionRaw(sessTarget: string, key: string): string;
  showWindowRaw(winTarget: string, key: string): string;
  setSessUserOption(sessTarget: string, key: string, val: string): unknown;
  unsetSessUserOption(sessTarget: string, key: string): unknown;
  setWinUserOption(winTarget: string, key: string, val: string): unknown;
  unsetWinUserOption(winTarget: string, key: string): unknown;

  // ── 键绑定 ──
  bindKey(table: string | null, key: string, cmd: string): unknown;
  unbindKeyRoot(key: string): unknown;

  // ── raw fallback ──
  rawSpawnSync(args: string[]): unknown;

  // ── 运行时探测 ──
  /** 当前进程是否运行在 multiplexer session 内（用于外层鼠标穿透处理）。 */
  isInsideSession(): boolean;
  /** 后端不可用时抛错或打印诊断并退出。 */
  assertAvailable(): void;
}

// TmuxBackend — IMultiplexerBackend 的 tmux 实现。target 一律用 `=NAME[:IDX]` 精确语法。
function tmux(args: string[], opts?: { missingOk?: boolean; unsetOk?: boolean }): string {
  const bin = tmuxBin();
  const out = Bun.spawnSync([bin, ...args], { stdout: "pipe", stderr: "pipe" });
  if (out.exitCode !== 0) {
    const stderr = out.stderr.toString();
    // 幂等清理命令（kill/has/rename-session 等）目标不存在时静默吞掉
    if (opts?.missingOk && /can't find session|no such session|session not found/i.test(stderr)) {
      return out.stdout.toString();
    }
    // 用户自定义 @option 未设置时 show-options 报 invalid option，视为空值
    if (opts?.unsetOk && /invalid option|unknown option|option not found/i.test(stderr)) {
      return "";
    }
    if (!tmuxQuietDepth) {
      process.stderr.write(`[tmux ${args.join(" ")}] exit=${out.exitCode} ${stderr}`);
    }
  }
  return out.stdout.toString();
}

const tmuxApi: IMultiplexerBackend = {
  // sessions / windows
  listSessions: (fmt = "#{session_name}"): string[] =>
    tmux(["list-sessions", "-F", fmt]).trim().split("\n").filter(Boolean),
  listWindows: (sess: string, fmt: string): string[] =>
    tmux(["list-windows", "-t", buildSessTarget(sess), "-F", fmt]).trim().split("\n").filter(Boolean),
  newSession: (name: string) => tmux(["new-session", "-d", "-s", name]),
  newGroupedSession: (name: string, srcSess: string) =>
    tmux(["new-session", "-d", "-s", name, "-t", buildSessOnlyTarget(srcSess)]),
  killSession: (name: string) => tmux(["kill-session", "-t", buildSessOnlyTarget(name)], { missingOk: true }),
  killWindow: (target: string) => tmux(["kill-window", "-t", target], { missingOk: true }),
  renameSession: (oldName: string, newName: string) =>
    tmux(["rename-session", "-t", buildSessOnlyTarget(oldName), newName], { missingOk: true }),
  renameWindow: (target: string, newName: string) =>
    tmux(["rename-window", "-t", target, newName]),
  newWindow: (sess: string, name: string) =>
    tmux(["new-window", "-d", "-t", buildSessTarget(sess), "-n", name]),
  selectWindow: (target: string) => tmux(["select-window", "-t", target]),
  attach: (name: string) =>
    Bun.spawnSync([tmuxBin(), "attach-session", "-t", buildSessOnlyTarget(name)], {
      stdin: "inherit", stdout: "inherit", stderr: "inherit",
    }),
  capturePane: (target: string, startN: number, endArg: string) =>
    Bun.spawn([tmuxBin(), "capture-pane", "-p", "-t", target, "-S", `-${startN}`, "-E", endArg]),
  capturePaneText: (target: string, startN: number, endArg = "-") => {
    const r = Bun.spawnSync(
      [tmuxBin(), "capture-pane", "-p", "-t", target, "-S", `-${startN}`, "-E", endArg],
      { stdout: "pipe", stderr: "pipe" },
    );
    if (r.exitCode !== 0 && !tmuxQuietDepth) {
      process.stderr.write(
        `[tmux capture-pane -t ${target}] exit=${r.exitCode} ${r.stderr?.toString() || ""}`,
      );
    }
    return r.stdout?.toString() || "";
  },
  sendKeys: (target: string, text: string) =>
    Bun.spawnSync([tmuxBin(), "send-keys", "-t", target, text, "Enter"]),
  loadBuffer: (target: string, file: string) =>
    Bun.spawnSync([tmuxBin(), "load-buffer", "-b", `tui_v2_${process.pid}`, file]),
  pasteBuffer: (target: string) =>
    Bun.spawnSync([tmuxBin(), "paste-buffer", "-d", "-b", `tui_v2_${process.pid}`, "-t", target]),
  // options
  getGlobalOption: (key: string): string =>
    tmux(["show-options", "-gv", key]).trim(),
  setGlobalOption: (key: string, val: string) =>
    tmux(["set-option", "-g", key, val]),
  // tmux 3.5a quirk: `set-option -t '=NAME' ...` 静默失败（kill/has/attach-session 支持 `=` 精确匹配，
  // 唯独 set-option 不支持，stderr 报 "no such session: =NAME" 被 tmux() 吞掉）。
  // 统一剥掉 `=` 前缀，否则 viewer 的 6 个 session 选项全部 no-op，沉浸式底栏永远不显示。
  setSessionOption: (target: string, key: string, val: string) =>
    tmux(["set-option", "-t", target.replace(/^=/, ""), key, val]),
  unsetSessionOption: (target: string, key: string) =>
    tmux(["set-option", "-u", "-t", target.replace(/^=/, ""), key]),
  showSessionRaw: (sessTarget: string, key: string): string =>
    tmux(["show-options", "-v", "-t", sessTarget, key], { unsetOk: true }).trim(),
  showWindowRaw: (winTarget: string, key: string): string =>
    tmux(["show-options", "-vw", "-t", winTarget, key], { unsetOk: true }).trim(),
  setSessUserOption: (sessTarget: string, key: string, val: string) =>
    tmux(["set-option", "-t", sessTarget, key, val]),
  unsetSessUserOption: (sessTarget: string, key: string) =>
    tmux(["set-option", "-u", "-t", sessTarget, key]),
  setWinUserOption: (winTarget: string, key: string, val: string) =>
    tmux(["set-option", "-w", "-t", winTarget, key, val]),
  unsetWinUserOption: (winTarget: string, key: string) =>
    tmux(["set-option", "-u", "-w", "-t", winTarget, key]),
  // key bindings
  bindKey: (table: string | null, key: string, cmd: string) =>
    table ? tmux(["bind-key", "-T", table, key, cmd]) : tmux(["bind-key", "-n", key, cmd]),
  unbindKeyRoot: (key: string) => tmux(["unbind-key", "-n", key]),
  // raw fallback for special list cases
  rawSpawnSync: (args: string[]) =>
    Bun.spawnSync([tmuxBin(), ...args], { stdout: "pipe", stderr: "pipe" }),

  // 运行时探测
  isInsideSession: (): boolean => !!process.env.TMUX,
  assertAvailable: (): void => {
    const p = resolveTmuxPath();
    if (!p) {
      const bin = (process.argv[1] || "tui").replace(/^.*\//, "");
      console.log(`tmux 未找到。运行: ${bin} install-tmux`);
      console.log(`  系统包管理: ${bin} install-tmux --system`);
      process.exit(1);
    }
    _resolvedTmuxBin = p;
  },
};


// ── target helpers ──
// tmux target 语法陷阱：`=NAME` 在 NAME 同时为 session 名和某 window 名时会歧义匹配到 window。
// 强制 session 维度一律带尾冒号 `=NAME:`；window 维度 `=NAME:IDX`。所有 target 拼接走这里。
function buildSessTarget(sessionName: string): string {
  return `=${sessionName}:`;
}
// session-only 命令（kill-session/has-session/rename-session/attach-session）专用：
// 这些命令把 `-t` 当 session target 解析，尾冒号会被当成 `session:window` 而把整体降级为 window target，
// 导致 tmux 报 "can't find session: NAME"（实际是把 `NAME:`<空 window> 当 window 找不到）。
function buildSessOnlyTarget(sessionName: string): string {
  return `=${sessionName}`;
}
function buildWinTarget(sessionName: string, idx: string | number): string {
  return `=${sessionName}:${idx}`;
}

// 统一 set/unset option 入口：val=null → unset；isWindow 控制 -w/-t 维度
function setUserOption(target: string, isWindow: boolean, key: string, val: string | null): void {
  if (isWindow) {
    if (val === null) tmuxApi.unsetWinUserOption(target, key);
    else tmuxApi.setWinUserOption(target, key, val);
  } else {
    if (val === null) tmuxApi.unsetSessUserOption(target, key);
    else tmuxApi.setSessUserOption(target, key, val);
  }
}

// ── 数据层 ──

interface TreeNode {
  label: string;
  target: string;
  indent: number;
  type: "session" | "window";
  sessionName: string;
  remark?: string;
  agent?: string;
}

function parseUserOptionValue(raw: string, key: string): string {
  if (!raw) return "";
  const esc = key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const m = raw.match(new RegExp(`^${esc}\\s+(?:"((?:[^"\\\\]|\\\\.)*)"|(\\S.*))$`));
  if (m) {
    const v = m[1] !== undefined ? m[1].replace(/\\(.)/g, "$1") : m[2];
    return v.trim();
  }
  return raw.trim();
}

function readUserOption(
  node: { type: "session" | "window"; target: string; sessionName: string },
  key: string,
): string {
  const sessTarget = buildSessTarget(node.sessionName);
  const winTarget = node.type === "window"
    ? buildWinTarget(node.sessionName, node.target.split(":")[1] ?? "")
    : sessTarget;
  const raw = node.type === "session"
    ? tmuxApi.showSessionRaw(sessTarget, key)
    : tmuxApi.showWindowRaw(winTarget, key);
  return parseUserOptionValue(raw, key);
}

function readRemark(node: { type: "session" | "window"; target: string; sessionName: string }): string {
  return readUserOption(node, TUI_CONFIG.REMARK_KEY);
}

function readAgent(node: { type: "session" | "window"; target: string; sessionName: string }): string {
  return readUserOption(node, TUI_CONFIG.AGENT_KEY);
}

function writeRemark(node: TreeNode, value: string) {
  // 关键：用 `=NAME:` / `=NAME:IDX` 精确目标，避免 tmux 对 "1"、短名 做模糊匹配导致跨 session 污染
  if (node.type === "session") {
    const sessTarget = buildSessTarget(node.sessionName);
    setUserOption(sessTarget, false, TUI_CONFIG.REMARK_KEY, value || null);
  } else {
    const idx = node.target.split(":")[1] ?? "";
    const winTarget = buildWinTarget(node.sessionName, idx);
    setUserOption(winTarget, true, TUI_CONFIG.REMARK_KEY, value || null);
  }
}

function writeAgent(node: TreeNode, value: string) {
  if (node.type !== "window") throw new Error("agent 仅可绑定 window");
  const idx = node.target.split(":")[1] ?? "";
  const winTarget = buildWinTarget(node.sessionName, idx);
  setUserOption(winTarget, true, TUI_CONFIG.AGENT_KEY, value || null);
}

/** spec → tmux target + TreeNode（TUI / CLI 共用） */
function nodeFromTarget(target: string): TreeNode {
  const bare = target.replace(/^=/, "").replace(/:$/, "");
  const colon = bare.indexOf(":");
  if (colon >= 0) {
    const sess = bare.slice(0, colon);
    const idx = bare.slice(colon + 1);
    return { label: "", target: `${sess}:${idx}`, indent: 1, type: "window", sessionName: sess };
  }
  return { label: "", target: bare, indent: 0, type: "session", sessionName: bare };
}

function findNodeByRemark(wanted: string): TreeNode | null {
  for (const n of getTree()) {
    if (n.remark === wanted) return n;
  }
  return null;
}

function parseTargetSpec(spec: string): { target: string; node: TreeNode } {
  if (!spec) throw new Error("target spec 为空");
  if (spec.startsWith("=")) {
    const target = spec;
    return { target, node: nodeFromTarget(target) };
  }
  if (!spec.startsWith("@")) {
    if (spec.includes(":")) {
      const [sess, idx] = spec.split(":");
      const target = buildWinTarget(sess, idx ?? "");
      return {
        target,
        node: { label: "", target: `${sess}:${idx}`, indent: 1, type: "window", sessionName: sess },
      };
    }
    const target = buildSessTarget(spec);
    return {
      target,
      node: { label: "", target: spec, indent: 0, type: "session", sessionName: spec },
    };
  }
  const node = findNodeByRemark(spec);
  if (!node) throw new Error(`找不到逻辑名 ${spec}`);
  const target =
    node.type === "window"
      ? buildWinTarget(node.sessionName, node.target.split(":")[1] ?? "")
      : buildSessTarget(node.sessionName);
  return { target, node };
}

function resolveTarget(spec: string): string {
  return parseTargetSpec(spec).target;
}

// ── 领域操作（TUI 快捷键 + CLI 子命令共用，避免双份业务逻辑）──

function normName(raw: string, what: string): string {
  const n = raw.trim().replace(/\s+/g, "-");
  if (!n) throw new Error(`${what} 名称为空`);
  return n;
}

function opNewSession(name: string): string {
  const n = normName(name, "session");
  tmuxApi.newSession(n);
  return n;
}

function opNewWindow(sessionSpec: string, winName: string): string {
  const { node } = parseTargetSpec(sessionSpec);
  if (node.type !== "session") throw new Error("new-window 需要 session 级 spec（sess 或 @remark→session）");
  const n = normName(winName, "window");
  tmuxApi.newWindow(node.sessionName, n);
  return n;
}

function opRename(spec: string, newName: string): string {
  const { node } = parseTargetSpec(spec);
  const n = normName(newName, node.type);
  if (node.type === "session") tmuxApi.renameSession(node.sessionName, n);
  else tmuxApi.renameWindow(buildWinTarget(node.sessionName, node.target.split(":")[1] ?? ""), n);
  return n;
}

function opKillWindow(spec: string): void {
  const { node, target } = parseTargetSpec(spec);
  if (node.type === "session") throw new Error("kill-window 仅支持 window（sess:idx 或 @remark→window）");
  tmuxApi.killWindow(target);
}

// ── agentBus：window @agent 为纯名 id；与 @remark / 各 CLI 的 @ 语义分离 ──

function normalizeAgentName(name: string): string {
  let t = name.trim();
  if (!t) throw new Error("agent 名为空");
  if (t.startsWith("@")) {
    t = t.slice(1).trim();
    if (!t) throw new Error("agent 名不能仅为 @");
  }
  if (t.includes("@")) {
    throw new Error("agent 名勿含 @（@ 保留给 remark 寻址与各 agent CLI）");
  }
  return t;
}

function agentIdFileKey(name: string): string {
  return normalizeAgentName(name).replace(/[^a-zA-Z0-9._-]/g, "_");
}

function inboxPath(name: string): string {
  const key = agentIdFileKey(name);
  const primary = join(TUI_CONFIG.INBOX_DIR, `${key}.jsonl`);
  if (existsSync(primary)) return primary;
  const legacy = join(TUI_CONFIG.INBOX_DIR, `@${key}.jsonl`);
  if (existsSync(legacy)) return legacy;
  return primary;
}

function readCursorPath(name: string): string {
  const key = agentIdFileKey(name);
  const primary = join(TUI_CONFIG.READ_DIR, `${key}.cursor`);
  if (existsSync(primary)) return primary;
  const legacy = join(TUI_CONFIG.READ_DIR, `@${key}.cursor`);
  if (existsSync(legacy)) return legacy;
  return primary;
}

function findNodeByAgent(name: string): TreeNode | null {
  const wanted = normalizeAgentName(name);
  for (const n of getTree()) {
    if (n.type === "window" && n.agent === wanted) return n;
  }
  return null;
}

/** agent 寻址：纯名 | sess:idx | =sess:idx（勿用 @，@ 仅 remark） */
function resolveAgentName(spec: string): string {
  if (!spec) throw new Error("agent spec 为空");
  if (spec.startsWith("@")) {
    throw new Error("agent 用纯名或 window spec；@ 仅用于 remark 寻址（如 send @逻辑名）");
  }
  if (spec.startsWith("=") || spec.includes(":")) {
    const { node } = parseTargetSpec(spec);
    if (node.type !== "window") throw new Error("agent 仅绑定 window");
    const id = readAgent(node);
    if (!id) {
      throw new Error(`window ${node.target} 未注册 agent（tui agent register ${spec} <name>）`);
    }
    return id;
  }
  return normalizeAgentName(spec);
}

function requireAgentWindow(spec: string): TreeNode {
  const name = resolveAgentName(spec);
  const node = findNodeByAgent(name);
  if (!node) {
    throw new Error(`未找到 agent「${name}」（tui agent register <spec> ${name}）`);
  }
  return node;
}

function parseInboxFile(path: string): AgentEnvelope[] {
  if (!existsSync(path)) return [];
  const out: AgentEnvelope[] = [];
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const t = line.trim();
    if (!t) continue;
    try {
      out.push(JSON.parse(t) as AgentEnvelope);
    } catch {
      /* 跳过坏行 */
    }
  }
  return out;
}

function summarizeMessage(body: string): string {
  return stripAnsi(body).replace(/\s+/g, " ").trim().slice(0, 120);
}

// ═══ OBSERVER_PAUSED：v 消息栏 + bus.jsonl 镜像（恢复时取消注释）═══
/*
function appendBus(env: AgentEnvelope): void {
  try {
    mkdirSync(TUI_CONFIG.DATA_DIR, { recursive: true });
    appendFileSync(TUI_CONFIG.BUS_PATH, JSON.stringify(env) + "\n");
  } catch (e: unknown) {
    if (!tmuxQuietDepth) {
      process.stderr.write(`warn: 写入 bus 失败: ${e instanceof Error ? e.message : String(e)}\n`);
    }
  }
}

function readBusTail(limit = 500): AgentEnvelope[] {
  if (!existsSync(TUI_CONFIG.BUS_PATH)) return [];
  const lines = readFileSync(TUI_CONFIG.BUS_PATH, "utf8").trimEnd().split("\n").slice(-limit);
  const out: AgentEnvelope[] = [];
  for (const line of lines) {
    const t = line.trim();
    if (!t) continue;
    try {
      out.push(JSON.parse(t) as AgentEnvelope);
    } catch {
    }
  }
  return out;
}
*/

function agentSend(opts: {
  to: string;
  from: string;
  body: string;
  corr?: string;
  kind?: AgentKind;
}): AgentEnvelope {
  const toNode = requireAgentWindow(opts.to);
  const toName = resolveAgentName(opts.to);
  const fromName = normalizeAgentName(opts.from);
  const fromNode = findNodeByAgent(fromName);
  const env: AgentEnvelope = {
    id: randomUUID(),
    ts: new Date().toISOString(),
    from: fromName,
    to: toName,
    fromTarget: fromNode?.target,
    toTarget: toNode.target,
    corr: opts.corr ?? `c-${Date.now()}`,
    kind: opts.kind ?? "msg",
    status: "sent",
    summary: summarizeMessage(opts.body),
    body: opts.body,
  };
  mkdirSync(TUI_CONFIG.INBOX_DIR, { recursive: true });
  appendFileSync(inboxPath(toName), JSON.stringify(env) + "\n");
  // OBSERVER_PAUSED: appendBus(env);
  return env;
}

function agentInboxCount(agentId: string): number {
  return parseInboxFile(inboxPath(agentId)).length;
}

function agentUnreadCount(agentId: string): number {
  const total = agentInboxCount(agentId);
  const cp = readCursorPath(agentId);
  if (!existsSync(cp)) return total;
  const seen = parseInt(readFileSync(cp, "utf8"), 10) || 0;
  return Math.max(0, total - seen);
}

function agentMarkRead(agentId: string, throughLine?: number): void {
  mkdirSync(TUI_CONFIG.READ_DIR, { recursive: true });
  const n = throughLine ?? agentInboxCount(agentId);
  writeFileSync(readCursorPath(agentId), String(n));
}

function listRegisteredAgents(): Array<{ id: string; target: string; unread: number }> {
  const out: Array<{ id: string; target: string; unread: number }> = [];
  for (const n of getTree()) {
    if (n.type === "window" && n.agent) {
      out.push({ id: n.agent, target: n.target, unread: agentUnreadCount(n.agent) });
    }
  }
  return out;
}

function getTree(): TreeNode[] {
  const nodes: TreeNode[] = [];
  const sessions = tmuxApi.listSessions();
  for (const sess of sessions) {
    const sessNode: TreeNode = {
      label: `# ${sess}`,//sess,
      target: sess,
      indent: 0,
      type: "session",
      sessionName: sess,
    };
    sessNode.remark = readRemark(sessNode);
    nodes.push(sessNode);
    const wins = tmuxApi.listWindows(sess, "#{window_index}|#{window_name}|#{window_active}");
    for (let i = 0; i < wins.length; i++) {
      const [idx, name, active] = wins[i].split("|");
      const marker = "" //active === "1" ? "●" : "○";
      const branch = i === wins.length - 1 ? "└" : "├";
      const winNode: TreeNode = {
        label: `${branch} ${name}`,//`${branch} ${marker} ${idx}: ${name}`,
        target: `${sess}:${idx}`,
        indent: 1,
        type: "window",
        sessionName: sess,
      };
      winNode.remark = readRemark(winNode);
      winNode.agent = readAgent(winNode);
      nodes.push(winNode);
    }
  }
  return nodes;
}

async function getPreview(target: string): Promise<string> {
  const previewH = getPreviewH();
  const startN = previewH + state.scrollOffset;
  const endArg = state.scrollOffset === 0 ? "-" : `-${state.scrollOffset}`;
  const proc = tmuxApi.capturePane(target, startN, endArg);
  const text = await new Response(proc.stdout).text();
  await proc.exited;
  return text;
}

// ── 状态 ──

interface InputMode {
  prompt: string;
  value: string;
  callback: (v: string | null) => void;
}

// 布局常量：header 1 行（row 1），body 从 row 2 起，footer 1 行（row = rows）
const HEADER_H = 1;
const FOOTER_H = 1;
const BODY_START_ROW = HEADER_H + 1; // 2
const DRIVE_TREE_FRAC = 0.42; // 驾驶模式：上区 tree-table 约占 body

type UiMode = "index" | "drive";

type LayoutInfo =
  | { mode: "index"; bodyH: number; leftW: number; rightW: number; inspectorW: number }
  | { mode: "drive"; bodyH: number; fullW: number; treeHeaderH: number; treeDataH: number; paneH: number };

class TuiState {
  tree: TreeNode[] = getTree();
  cursor = 0;
  viewOffset = 0;
  /** 索引（左右）| 驾驶（上下 tree-table） */
  uiMode: UiMode = "index";
  // layoutMode: "preview" | "observer" = "preview"; // OBSERVER_PAUSED
  preview = "";
  previewTimer: ReturnType<typeof setTimeout> | null = null;
  previewFetchId = 0;
  previewDoneId = 0;
  previewTarget = "";
  inputMode: InputMode | null = null;
  scrollOffset = 0;
  seenMax = 0;
  // selectMode = false; // 主界面选区暂停，见下方 MAIN_SELECT_PAUSED 块
  /** 从沉浸式返回后：右侧 preview 不自动 capture（避免把刚看过的输出再刷一遍） */
  suppressPreviewAfterAttach = false;

  clampView(bodyH: number) {
    if (this.cursor < this.viewOffset) this.viewOffset = this.cursor;
    else if (this.cursor >= this.viewOffset + bodyH) this.viewOffset = this.cursor - bodyH + 1;
    if (this.viewOffset < 0) this.viewOffset = 0;
  }
}
const state = new TuiState();

function getPreviewH(): number {
  const [, rows] = screen.getSize();
  const bodyH = Math.max(1, rows - HEADER_H - FOOTER_H);
  if (state.uiMode === "index") return bodyH;
  const treeHeaderH = 1;
  const treeDataH = Math.max(3, Math.floor(bodyH * DRIVE_TREE_FRAC) - treeHeaderH);
  const paneDividerH = 1;
  return Math.max(1, bodyH - treeHeaderH - treeDataH - paneDividerH);
}

function getLayout(cols: number, rows: number): LayoutInfo {
  const bodyH = rows - HEADER_H - FOOTER_H;
  if (state.uiMode === "drive") {
    const treeHeaderH = 1;
    const treeDataH = Math.max(3, Math.floor(bodyH * DRIVE_TREE_FRAC) - treeHeaderH);
    const paneDividerH = 1;
    const paneH = Math.max(1, bodyH - treeHeaderH - treeDataH - paneDividerH);
    return { mode: "drive", bodyH, fullW: cols, treeHeaderH, treeDataH, paneH };
  }
  const leftW = Math.min(Math.max(Math.floor(cols * 0.2), 12), 30);
  const inspectorW = 0; // OBSERVER_PAUSED
  const rightW = cols - leftW - 1;
  return { mode: "index", bodyH, leftW, rightW, inspectorW };
}

function uiModeTag(): string {
  return state.uiMode === "drive" ? "[驾驶]" : "[索引]";
}

function treeVisibleRows(layout: LayoutInfo): number {
  return layout.mode === "drive" ? layout.treeDataH : layout.bodyH;
}

function toggleUiMode() {
  state.uiMode = state.uiMode === "index" ? "drive" : "index";
  state.viewOffset = 0;
  state.scrollOffset = 0;
  const [, rows] = screen.getSize();
  state.clampView(treeVisibleRows(getLayout(screen.getSize()[0], rows)));
  render();
  schedulePreview();
}

type DriveColWidths = { stat: number; sess: number; win: number; agent: number; unread: number; auto: number; age: number; task: number };

function driveColWidths(cols: number): DriveColWidths {
  const stat = 1;
  const unread = 4;
  const auto = 3;
  const age = 4;
  const sess = Math.min(14, Math.max(8, Math.floor(cols * 0.14)));
  const win = Math.min(10, Math.max(6, Math.floor(cols * 0.1)));
  const agent = Math.min(12, Math.max(8, Math.floor(cols * 0.12)));
  const fixed = stat + 1 + sess + 1 + win + 1 + agent + 1 + unread + 1 + auto + 1 + age;
  const task = Math.max(8, cols - fixed);
  return { stat, sess, win, agent, unread, auto, age, task };
}

function renderDriveCell(text: string, w: number, selected: boolean, dim = false): void {
  const vis = padVis(truncVis(text, w), w);
  if (selected) screen.write(screen.inv(dim ? screen.dim(vis) : vis));
  else if (dim) screen.write(screen.dim(vis));
  else screen.write(vis);
}

function renderDriveTableHeader(row: number, cols: number, cw: DriveColWidths): void {
  let col = 1;
  const hdr = (t: string, w: number) => {
    screen.cursorAt(row, col);
    screen.write(screen.inv(screen.bold(padVis(truncVis(t, w), w))));
    col += w + 1;
  };
  hdr("●", cw.stat);
  hdr("Session", cw.sess);
  hdr("Win", cw.win);
  hdr("Agent", cw.agent);
  hdr("Task", cw.task);
  hdr("Rd", cw.unread);
  hdr("A", cw.auto);
  hdr("Age", cw.age);
  if (col <= cols) {
    screen.cursorAt(row, col);
    screen.write(screen.dim("─".repeat(Math.max(0, cols - col + 1))));
  }
}

function renderDriveTableRow(row: number, node: TreeNode, selected: boolean, cols: number, cw: DriveColWidths): void {
  const [, winIdx] = node.type === "window" ? node.target.split(":") : ["", ""];
  const ag = node.agent || "";
  const unread = ag && node.type === "window" ? agentUnreadCount(ag) : 0;
  const stat = node.type === "session" ? "▣" : (unread > 0 ? "●" : "○");
  const sess = node.type === "session" ? node.sessionName : node.sessionName;
  const win = node.type === "window" ? winIdx : "—";
  const agent = ag || "—";
  const task = node.remark || truncVis(node.label.replace(/^[├└]\s*/, ""), cw.task);
  const auto = "0";
  const age = "—";
  let col = 1;
  const cell = (t: string, w: number, dim = false) => {
    screen.cursorAt(row, col);
    renderDriveCell(t, w, selected, dim);
    col += w + 1;
  };
  cell(stat, cw.stat);
  cell(sess, cw.sess, node.type === "session");
  cell(win, cw.win);
  cell(agent, cw.agent);
  cell(task, cw.task);
  cell(unread > 0 ? String(unread) : "", cw.unread);
  cell(auto, cw.auto, true);
  cell(age, cw.age, true);
}

// ── 渲染 ──

function renderLeftCell(node: TreeNode, isSelected: boolean, cap: number): void {
  const rk = node.remark;
  const pending =
    isSelected &&
    node.type === "window" &&
    state.previewDoneId < state.previewFetchId;
  const base = node.label;
  const baseVis = truncVis(base, cap);
  const baseW = visW(baseVis);
  const ag = node.agent;
  const unread = ag && node.type === "window" ? agentUnreadCount(ag) : 0;
  const agentPart = ag ? ` [${ag}${unread > 0 ? `·${unread}` : ""}]` : "";
  const remarkPart = rk ? ` *${rk}` : "";
  const pendPart = pending ? " **" : "";
  const tail = truncVis(agentPart + remarkPart + pendPart, Math.max(0, cap - baseW));
  const tailW = visW(tail);
  const padN = Math.max(0, cap - baseW - tailW);
  const padStr = " ".repeat(padN);
  if (isSelected) {
    screen.write(screen.inv(screen.cyan(baseVis)));
    if (tail) screen.write(screen.inv(screen.cyan(tail)));
    if (padN) screen.write(screen.inv(padStr));
  } else {
    if (node.type === "session") screen.write(screen.bold(baseVis));
    else screen.write(baseVis);
    if (tail) screen.write(screen.cyan(tail));
    if (padN) screen.write(padStr);
  }
}

/*
function formatBusLine(env: AgentEnvelope, cap: number): string {
  const time = env.ts ? new Date(env.ts).toTimeString().slice(0, 8) : "--:--:--";
  const status = env.status ? ` ${env.status}` : "";
  const summary = env.summary || summarizeMessage(env.body || "");
  const from = env.fromTarget ? `${env.from}@${env.fromTarget}` : env.from;
  const to = env.toTarget ? `${env.to}@${env.toTarget}` : env.to;
  return truncVis(`${time} ${from}->${to} ${env.kind}${status} ${summary}`, cap);
}

function renderInspectorCell(row: number, col: number, width: number, lineIdx: number, rows: AgentEnvelope[]): void {
  const cap = Math.max(0, width - 1);
  screen.cursorAt(row, col);
  if (lineIdx === 0) {
    screen.write(screen.inv(screen.bold(padVis(truncVis(" messages · bus.jsonl ", cap), cap))));
    return;
  }
  if (rows.length === 0) {
    if (lineIdx === 1) screen.write(screen.dim(padVis(truncVis("暂无消息", cap), cap)));
    else screen.write(" ".repeat(cap));
    return;
  }
  const env = rows[rows.length - lineIdx];
  if (!env) {
    screen.write(" ".repeat(cap));
    return;
  }
  screen.write(padVis(formatBusLine(env, cap), cap));
}
*/

function renderHeader(cols: number): void {
  screen.cursorAt(1, 1);
  const scrollInd = state.scrollOffset > 0 ? ` ↕${state.scrollOffset}` : "";
  const helpRest = `${uiModeTag()} ${tuiHeaderHelp()}${scrollInd}`;
  const maxW = cols - 1;
  const logoVis = truncVis(TUI_CONFIG.TITLE + " " + TUI_CONFIG.VERSION, maxW);
  const logoW = visW(logoVis);
  screen.write(screen.asuLogo(padVis(logoVis, logoW)));
  const helpCap = Math.max(0, maxW - logoW);
  if (helpCap > 0) {
    const helpVis = " " + truncVis(helpRest, helpCap);
    screen.write(screen.inv(screen.bold(padVis(helpVis, helpCap))));
  }
}

function renderFooter(cols: number, rows: number): void {
  screen.cursorAt(rows, 1);
  if (state.inputMode) {
    const line = ` ${state.inputMode.prompt}: ${state.inputMode.value}█ `;
    screen.write(screen.gold(padVis(truncVis(line, cols - 1), cols - 1)));
    screen.showCursor();
  } else {
    screen.write(screen.gold(" ".repeat(cols - 1)));
  }
}

function previewScrollMetrics(previewH: number) {
  const curDepth = state.scrollOffset + previewH;
  if (curDepth > state.seenMax) state.seenMax = curDepth;
  const total = Math.max(state.seenMax, previewH);
  const thumbH = Math.max(1, Math.round((previewH * previewH) / total));
  const thumbStart = total <= previewH
    ? 0
    : Math.max(0, Math.min(previewH - thumbH,
        Math.round((previewH * (total - state.scrollOffset - previewH)) / total)));
  return { thumbH, thumbStart };
}

function renderPreviewLine(
  row: number, col: number, textW: number, lineIdx: number, pLines: string[], thumb?: { thumbH: number; thumbStart: number },
): void {
  screen.cursorAt(row, col);
  if (state.previewTarget && lineIdx === 0) {
    screen.write(screen.dim(`⏳ ${state.previewTarget} ...`).slice(0, textW));
  } else if (state.suppressPreviewAfterAttach && lineIdx === 0) {
    screen.write(screen.dim("  已从分舱返回 · 按 f 刷新预览").slice(0, textW));
  } else if (state.suppressPreviewAfterAttach) {
    screen.write(" ".repeat(textW));
  } else {
    screen.write((pLines[lineIdx] || "").slice(0, textW));
  }
  if (thumb) {
    screen.cursorAt(row, col + textW);
    const inThumb = lineIdx >= thumb.thumbStart && lineIdx < thumb.thumbStart + thumb.thumbH;
    screen.write(`\x1b[90m${inThumb ? "▓" : "░"}\x1b[0m`);
  }
}

function renderIndexBody(cols: number, rows: number, layout: Extract<LayoutInfo, { mode: "index" }>) {
  const { leftW, rightW, bodyH } = layout;
  const allPLines = state.preview.split("\n");
  const pLines = allPLines.length > bodyH ? allPLines.slice(allPLines.length - bodyH) : allPLines;
  const blankLeft = " ".repeat(leftW - 1);
  const textW = Math.max(0, rightW - 1);
  const { thumbH, thumbStart } = previewScrollMetrics(bodyH);

  for (let i = 0; i < bodyH; i++) {
    const row = i + BODY_START_ROW;
    const treeIdx = i + state.viewOffset;
    screen.cursorAt(row, 1);
    const cap = leftW - 1;
    if (treeIdx < state.tree.length) {
      renderLeftCell(state.tree[treeIdx], treeIdx === state.cursor, cap);
    } else {
      screen.write(blankLeft);
    }
    screen.cursorAt(row, leftW);
    screen.write(screen.dim("│"));
    renderPreviewLine(row, leftW + 1, textW, i, pLines, { thumbH, thumbStart });
  }
}

function renderDriveBody(cols: number, layout: Extract<LayoutInfo, { mode: "drive" }>) {
  const { bodyH, treeHeaderH, treeDataH, paneH } = layout;
  const cw = driveColWidths(cols);
  const treeZoneH = treeHeaderH + treeDataH;
  const allPLines = state.preview.split("\n");
  const pLines = allPLines.length > paneH ? allPLines.slice(allPLines.length - paneH) : allPLines;
  const textW = Math.max(0, cols - 2);
  const { thumbH, thumbStart } = previewScrollMetrics(paneH);
  for (let i = 0; i < bodyH; i++) {
    const row = i + BODY_START_ROW;
    if (i < treeZoneH) {
      if (i === 0) {
        renderDriveTableHeader(row, cols, cw);
      } else {
        const treeIdx = (i - treeHeaderH) + state.viewOffset;
        if (treeIdx < state.tree.length) {
          renderDriveTableRow(row, state.tree[treeIdx], treeIdx === state.cursor, cols, cw);
        } else {
          screen.cursorAt(row, 1);
          screen.write(" ".repeat(cols - 1));
        }
      }
      continue;
    }
    if (i === treeZoneH) {
      screen.cursorAt(row, 1);
      screen.write(screen.dim("─".repeat(cols - 1)));
      continue;
    }
    const paneLine = i - treeZoneH - 1;
    if (paneLine < paneH) {
      renderPreviewLine(row, 1, textW, paneLine, pLines, { thumbH, thumbStart });
    }
  }
}

function render() {
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  state.clampView(treeVisibleRows(layout));

  screen.clear();
  screen.hideCursor();
  renderHeader(cols);
  if (layout.mode === "drive") renderDriveBody(cols, layout);
  else renderIndexBody(cols, rows, layout);
  renderFooter(cols, rows);
}

// ── Ctrl-Left 支持：detach 返回 tree mode ──

const installCtrlQ = () => {
  tmuxApi.bindKey(TUI_CONFIG.TUI_KEYTABLE, "C-Left", "detach-client");
  tmuxApi.bindKey(TUI_CONFIG.TUI_KEYTABLE, "M-Left", "detach-client");
  tmuxApi.bindKey(null, "C-Left", "detach-client");
  tmuxApi.bindKey(null, "M-Left", "detach-client");
};
const uninstallCtrlQ = () => {
  tmuxApi.unbindKeyRoot("C-Left");
  tmuxApi.unbindKeyRoot("M-Left");
};

// ── 外层 tmux mouse（主界面 SGR on；沉浸式 viewer session mouse on，见 createViewer）──
const insideTmux = tmuxApi.isInsideSession();
let savedOuterMouse: string | null = null;

/** xterm SGR 1006：Cb 低 3 位为按键，+4 Shift +8 Meta +16 Ctrl */
function decodeMouseBtn(raw: number) {
  return {
    btn: raw & ~28,
    shift: (raw & 4) !== 0,
    meta: (raw & 8) !== 0,
    ctrl: (raw & 16) !== 0,
  };
}

// ═══ MAIN_SELECT_PAUSED：主界面 preview 终端选区（s / Shift+点 / 点 preview）暂停 ═══
// 沉浸式 attach() 仍 screen.disableMouse()（关 TUI SGR）；滚轮由 viewer tmux mouse 接管。恢复时取消本块注释。
/*
function enterSelectMode() {
  if (state.selectMode) return;
  screen.disableMouse();
  restoreOuterMouse();
  state.selectMode = true;
  render();
}
function exitSelectMode() {
  if (!state.selectMode) return;
  state.selectMode = false;
  disableOuterMouse();
  screen.enableMouse();
  render();
}
function maybeEnterSelectMode(rawBtn: number, x: number, y: number, press: boolean): boolean {
  if (!press || state.selectMode || state.inputMode) return false;
  const [cols, rows] = screen.getSize();
  const { leftW } = getLayout(cols, rows);
  if (y > rows - FOOTER_H || y < BODY_START_ROW) return false;
  const { btn, shift } = decodeMouseBtn(rawBtn);
  const inPreview = x >= leftW;
  if (shift && btn <= 2) {
    enterSelectMode();
    return true;
  }
  if (inPreview && btn === 0) {
    enterSelectMode();
    return true;
  }
  return false;
}
*/

function disableOuterMouse() {
  if (!insideTmux) return;
  savedOuterMouse = tmuxApi.getGlobalOption("mouse") || "off";
  if (savedOuterMouse === "on") tmuxApi.setGlobalOption("mouse", "off");
}
function restoreOuterMouse() {
  if (!insideTmux || savedOuterMouse === null) return;
  tmuxApi.setGlobalOption("mouse", savedOuterMouse);
}

// ── 输入框 ──

function startInput(prompt: string, callback: (v: string | null) => void) {
  state.inputMode = { prompt, value: "", callback };
  render();
}

function handleInputKey(s: string): void {
  if (!state.inputMode) return;
  const mode = state.inputMode;

  // Escape / Ctrl-c → 取消
  if (s === "\x1b" || s === "\x03") {
    state.inputMode = null;
    mode.callback(null);
    render();
    return;
  }

  // Enter → 确认（部分终端 raw 模式发 \n 或 \r\n）
  if (s === "\r" || s === "\n" || s === "\r\n") {
    state.inputMode = null;
    mode.callback(mode.value);
    render();
    return;
  }

  // Backspace
  if (s === "\x7f" || s === "\b") {
    mode.value = mode.value.slice(0, -1);
    render();
    return;
  }

  // 可打印字符
  if (s.length === 1 && s >= " ") {
    mode.value += s;
    render();
  }
}

// ── TUI 按键（help 文案与 handler 同源）──

function cursorUp() {
  if (state.cursor > 0) {
    state.cursor--;
    schedulePreview();
  }
}

function cursorDown() {
  if (state.cursor < state.tree.length - 1) {
    state.cursor++;
    schedulePreview();
  }
}

function enterAttach() {
  if (state.tree.length === 0) return;
  if (state.tree[state.cursor]?.type !== "window") return;
  // MAIN_SELECT_PAUSED: if (wasSelectMode) enterSelectMode();
  attach(state.tree[state.cursor].target);
}

/*
function toggleObserver() {
  state.layoutMode = state.layoutMode === "observer" ? "preview" : "observer";
  render();
}
*/

const TUI_KEYBINDS: { help: string; match: (s: string) => boolean; run: () => void }[] = [
  { help: "↑/k", match: (s) => s === "\x1b[A" || s === "k", run: cursorUp },
  { help: "↓/j", match: (s) => s === "\x1b[B" || s === "j", run: cursorDown },
  { help: "n:Session", match: (s) => s === "n", run: () => newSession() },
  { help: "w:Win", match: (s) => s === "w", run: () => newWindow() },
  { help: "d:删", match: (s) => s === "d", run: () => deleteCurrent() },
  { help: "r:改名", match: (s) => s === "r", run: () => renameCurrent() },
  { help: "m:备注", match: (s) => s === "m", run: () => remarkCurrent() },
  { help: "f:刷", match: (s) => s === "f", run: () => refreshAll() },
  { help: "o:模式", match: (s) => s === "o", run: () => toggleUiMode() },
  // OBSERVER_PAUSED: { help: "v:消息", match: (s) => s === "v", run: () => toggleObserver() },
];

function tuiHeaderHelp(): string {
  return ["Enter进", "C-←回", ...TUI_KEYBINDS.map((b) => b.help), "q:退"].join(" ");
}

const TUI_ENTER_KEYS = new Set([
  "\r", "\x1b[1;5C", "\x1b[1;3C", "\x1b[1;9C", "\x1b\x1b[C", "\x1bOC",
]);

// ── 操作（调 op*，与 CLI 共用）──

function newSession() {
  startInput("新 Session 名称", (raw) => {
    if (raw?.trim()) {
      const name = opNewSession(raw);
      refreshAll();
      const idx = state.tree.findIndex((n) => n.type === "session" && n.target === name);
      if (idx >= 0) state.cursor = idx;
    }
    refreshPreview();
  });
}

function newWindow() {
  if (state.tree.length === 0) return;
  const sess = state.tree[state.cursor].sessionName;
  startInput(`在 [${sess}] 新建 Window 名称`, (raw) => {
    if (raw?.trim()) {
      opNewWindow(sess, raw);
      refreshAll();
    }
    refreshPreview();
  });
}

function deleteCurrent() {
  if (state.tree.length === 0) return;
  const node = state.tree[state.cursor];
  const what =
    node.type === "session"
      ? `session [${node.target}]`
      : `window [${node.target}]`;

  startInput(`删除 ${node.type} ${what}? (y/n)`, (ans) => {
    if (ans?.toLowerCase() === "y") {
      if (node.type === "session") {
        // too danger, not enabled yet
      } else {
        opKillWindow(node.target);
      }
    }
    refreshAll();
  });
}

function renameCurrent() {
  if (state.tree.length === 0) return;
  const node = state.tree[state.cursor];
  const spec = node.type === "session" ? node.sessionName : node.target;
  startInput(`rename ${node.type} [${node.target}]`, (raw) => {
    if (raw?.trim()) opRename(spec, raw);
    refreshAll();
  });
}

function remarkCurrent() {
  if (state.tree.length === 0) return;
  const node = state.tree[state.cursor];
  startInput(`修改备注 [${node.target}]`, (raw) => {
    if (raw === null) {
      render();
      return;
    }
    writeRemark(node, raw.trim());
    refreshAll();
  });
}

/** 单次 shell 批量 tmux 配置，避免逐个 spawn 刷屏 */
function tmuxShBatch(script: string): void {
  Bun.spawnSync(["sh", "-c", script], { stdout: "pipe", stderr: "pipe" });
}

// === viewer session helper：创建/销毁屏蔽 byobu 的 grouped viewer ===
function createViewer(sess: string, idx?: string) {
  const v = TUI_CONFIG.VIEWER_SESSION;
  const cabin = (idx || "").replace(/'/g, "'\\''");
  tmuxApi.killSession(v);
  tmuxApi.newGroupedSession(v, sess);
  const tb = tmuxBin().replace(/'/g, "'\\''");
  const opts = [
    // 用 root 键表才有默认 WheelUp/Down；tui_empty 无滚轮绑定
    `'${tb}' set-option -t '${v}' key-table root`,
    `'${tb}' set-option -t '${v}' prefix None`,
    `'${tb}' set-option -t '${v}' prefix2 None`,
    // mouse on：滚 pane 历史；mouse off 时终端 scrollback 会连 status 一起滚
    `'${tb}' set-option -t '${v}' mouse on`,
    `'${tb}' set-option -t '${v}' status-position top`,
    `'${tb}' set-option -t '${v}' status on`,
    `'${tb}' set-option -t '${v}' status-left ' #[bold]ctrl-左: 返回 '`,
    `'${tb}' set-option -t '${v}' status-left-length 30`,
    `'${tb}' set-option -t '${v}' status-right '驾驶分舱:${cabin} '`,
    `'${tb}' set-option -t '${v}' window-status-format ''`,
    `'${tb}' set-option -t '${v}' window-status-current-format ''`,
    `'${tb}' set-option -t '${v}' window-status-separator ''`,
    `'${tb}' set-option -t '${v}' status-justify centre`,
    `'${tb}' set-option -t '${v}' status-style 'bg=white,fg=black'`,
  ].join(" && ");
  const win = idx ? ` && '${tb}' select-window -t '=${v}:${idx}'` : "";
  tmuxShBatch(opts + win);
  tmuxApi.setSessionOption(v, "mouse", "on");
}

function attach(target: string) {
  // target = "<sess>:<idx>"
  const [sess, idx] = target.split(":");

  state.previewFetchId++;
  if (state.previewTimer) clearTimeout(state.previewTimer);
  state.previewTimer = null;

  screen.showCursor();
  screen.disableMouse();
  process.stdin.setRawMode(false);
  // 主界面 disableOuterMouse 可能关了全局 mouse；沉浸式须开回，否则 server 收不到滚轮
  tmuxApi.setGlobalOption("mouse", "on");
  withTmuxQuiet(() => {
    installCtrlQ();
    createViewer(sess, idx);
  });

  screen.leaveAltScreen();
  try {
    tmuxApi.attach(TUI_CONFIG.VIEWER_SESSION);
  } finally {
    withTmuxQuiet(() => tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION));
  }

  resumeTreeAfterAttach();
}

/** detach 后立刻回 tree；不自动 capture-pane（用户按 f 再刷新） */
function resumeTreeAfterAttach() {
  withTmuxQuiet(uninstallCtrlQ);
  process.stdin.setRawMode(true);
  disableOuterMouse();
  screen.enableMouse();
  screen.enterAltScreen();

  if (state.previewTimer) clearTimeout(state.previewTimer);
  state.previewTimer = null;
  state.previewTarget = "";
  state.preview = "";
  state.scrollOffset = 0;
  state.seenMax = 0;
  state.suppressPreviewAfterAttach = true;
  render();

  setTimeout(() => {
    withTmuxQuiet(() => {
      state.tree = getTree();
      if (state.cursor >= state.tree.length) {
        state.cursor = Math.max(0, state.tree.length - 1);
      }
    });
    render();
  }, RETURN_FROM_ATTACH_DELAY);
}

// ── preview 调度 ──

function refreshAll() {
  state.suppressPreviewAfterAttach = false;
  state.tree = getTree();
  if (state.cursor >= state.tree.length) state.cursor = Math.max(0, state.tree.length - 1);
  refreshPreview();
}

function clearPreview(): void {
  state.preview = "";
  state.previewTarget = "";
  state.previewDoneId = state.previewFetchId;
}

async function refreshPreview() {
  if (
    state.tree.length > 0 &&
    state.cursor < state.tree.length &&
    state.tree[state.cursor].type === "window"
  ) {
    const id = state.previewFetchId;
    const target = state.tree[state.cursor].target;
    if (!state.preview) {
      state.previewTarget = target;
      render(); // 无缓存时才显示 ⏳
    }
    const text = await getPreview(target);
    if (id !== state.previewFetchId) return; // discard stale
    state.preview = text;
    state.previewTarget = "";
    state.previewDoneId = id;
  } else {
    clearPreview();
  }
  render();
}

function schedulePreview(opts?: {
  keepScroll?: boolean;
  delay?: number;
  /** false：不立刻标 pending / 不重绘（用于 attach 返回，避免闪 ⏳） */
  pending?: boolean;
}) {
  state.suppressPreviewAfterAttach = false;
  if (state.previewTimer) clearTimeout(state.previewTimer);
  if (!opts?.keepScroll) {
    state.scrollOffset = 0;
    state.seenMax = 0;
  }
  // session 节点无 pane，直接清空、不标 pending
  if (
    state.tree.length === 0 ||
    state.cursor >= state.tree.length ||
    state.tree[state.cursor].type !== "window"
  ) {
    clearPreview();
    render();
    return;
  }
  const delay = opts?.delay ?? PREVIEW_DELAY;
  const showPending = opts?.pending !== false;
  if (showPending) {
    state.previewFetchId++;
    render();
  }
  state.previewTimer = setTimeout(refreshPreview, delay);
}

// ── 按键 ──

let lastClickY = -1;
let lastClickT = 0;

function handleMouse(rawBtn: number, x: number, y: number, press: boolean) {
  // MAIN_SELECT_PAUSED: maybeEnterSelectMode / if (state.selectMode) return;

  const { btn } = decodeMouseBtn(rawBtn);
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  const bodyY = y - BODY_START_ROW;
  const treeZoneH = layout.mode === "drive" ? layout.treeHeaderH + layout.treeDataH : layout.bodyH;
  const paneStartY = layout.mode === "drive" ? treeZoneH + 1 : layout.bodyH;
  const inPreviewZone = layout.mode === "index"
    ? x >= layout.leftW
    : bodyY >= paneStartY;
  // 滚轮
  if (btn === 64 || btn === 65) {
    if (!press) return;
    if (inPreviewZone) {
      const previewH = getPreviewH();
      if (btn === 64) state.scrollOffset += 3;
      else state.scrollOffset = Math.max(0, state.scrollOffset - 3);
      const maxScroll = Math.max(0, 5000 - previewH);
      if (state.scrollOffset > maxScroll) state.scrollOffset = maxScroll;
      refreshPreview();
    } else {
      if (btn === 64 && state.cursor > 0) { state.cursor--; schedulePreview(); }
      else if (btn === 65 && state.cursor < state.tree.length - 1) { state.cursor++; schedulePreview(); }
    }
    return;
  }
  if (btn !== 0 || !press) return;
  if (y > rows - FOOTER_H) return;
  if (y < BODY_START_ROW) return;
  if (layout.mode === "index" && x >= layout.leftW) return;
  if (layout.mode === "drive" && bodyY >= paneStartY) return;
  const idx = layout.mode === "drive"
    ? Math.max(0, bodyY - layout.treeHeaderH) + state.viewOffset
    : bodyY + state.viewOffset;
  if (idx < 0 || idx >= state.tree.length) return;
  const now = Date.now();
  const dbl = lastClickY === idx && now - lastClickT < 500;
  lastClickY = idx;
  lastClickT = now;
  state.cursor = idx;
  if (dbl) {
    if (state.tree[state.cursor]?.type !== "window") return;
    attach(state.tree[state.cursor].target);
    return;
  }
  render();
  schedulePreview();
}

function handleKey(data: Buffer) {
  let s = data.toString();

  if (s.indexOf("\x1b[<") >= 0) {
    const re = /\x1b\[<(\d+);(\d+);(\d+)([Mm])/g;
    let m: RegExpExecArray | null;
    while ((m = re.exec(s)) !== null) {
      handleMouse(parseInt(m[1]), parseInt(m[2]), parseInt(m[3]), m[4] === "M");
    }
    s = s.replace(re, "");
    if (!s) return;
  }

  if (state.inputMode) {
    handleInputKey(s);
    return;
  }

  /*
  if (s === "s") {
    if (state.selectMode) exitSelectMode();
    else enterSelectMode();
    return;
  }
  if (state.selectMode && s === "\x1b") {
    exitSelectMode();
    return;
  }
  */

  if (s === "\x03" || s === "q") {
    // MAIN_SELECT_PAUSED: if (state.selectMode) exitSelectMode();
    screen.showCursor();
    screen.clear();
    process.exit(0);
  }
  if (TUI_ENTER_KEYS.has(s)) {
    enterAttach();
    return;
  }
  for (const bind of TUI_KEYBINDS) {
    if (bind.match(s)) {
      bind.run();
      return;
    }
  }
  if (process.env.DEBUG_KEYS && s.length > 0 && (s.length > 1 || s < " " || s === "\x1b")) {
    const hex = [...s].map(c => "\\x" + c.charCodeAt(0).toString(16).padStart(2, "0")).join("");
    require("fs").appendFileSync("/tmp/tui_debug_keys.log", `[${new Date().toISOString()}] unhandled seq (len=${s.length}): ${hex}\n`);
  }
}

// ── CLI 模式（声明式命令树，与 TUI 共用 parseTargetSpec / capturePaneSync）──

const CLI_BIN = (process.argv[1] || "tui").replace(/^.*\//, "");

type CliCtx = { bin: string; rest: string[] };
type CliHandler = (ctx: CliCtx) => number;

interface CliCommand {
  name: string;
  aliases?: string[];
  summary: string;
  usage?: string;
  children?: CliCommand[];
  run: CliHandler;
}

function cliUsage(cmd: CliCommand, sub?: CliCommand): string {
  const leaf = sub ?? cmd;
  const head = sub ? `${cmd.name} ${leaf.name}` : cmd.name;
  return leaf.usage ? `${head} ${leaf.usage}` : head;
}

function matchCliName(cmd: CliCommand, name: string): boolean {
  return cmd.name === name || (cmd.aliases?.includes(name) ?? false);
}

function isCliInvocation(argv: string[]): boolean {
  const head = argv[2];
  if (!head) return false;
  return CLI_ROOT.some((c) => matchCliName(c, head));
}

function cliList(_ctx: CliCtx): number {
  for (const n of getTree()) {
    if (n.type === "session") {
      const rk = n.remark ? `  ${n.remark}` : "";
      process.stdout.write(`${n.target}${rk}\n`);
    } else {
      const rk = n.remark ? `  ${n.remark}` : "";
      const ag = n.agent ? `  agent:${n.agent}` : "";
      const winIdx = n.target.split(":")[1] ?? "";
      const last = tmuxApi.capturePaneText(buildWinTarget(n.sessionName, winIdx), 1)
        .split("\n")
        .map((s) => s.trim())
        .filter(Boolean)
        .pop() || "";
      process.stdout.write(`  ${n.target}${ag}${rk}  | ${stripAnsi(last).slice(0, 80)}\n`);
    }
  }
  return 0;
}

function cliCapture(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.capture)}\n`);
    return 2;
  }
  const lines = ctx.rest[1] ? parseInt(ctx.rest[1], 10) : PREVIEW_LINES;
  const target = resolveTarget(ctx.rest[0]);
  process.stdout.write(tmuxApi.capturePaneText(target, isNaN(lines) ? PREVIEW_LINES : lines));
  return 0;
}

function cliSend(ctx: CliCtx): number {
  if (ctx.rest.length < 2) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.send)}\n`);
    return 2;
  }
  const target = resolveTarget(ctx.rest[0]);
  tmuxApi.sendKeys(target, ctx.rest.slice(1).join(" "));
  process.stdout.write(`sent → ${target}: ${ctx.rest.slice(1).join(" ").length} chars\n`);
  return 0;
}

function cliPaste(ctx: CliCtx): number {
  if (ctx.rest.length < 2) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.paste)}\n`);
    return 2;
  }
  const target = resolveTarget(ctx.rest[0]);
  const file = ctx.rest[1];
  tmuxApi.loadBuffer(target, file);
  tmuxApi.pasteBuffer(target);
  process.stdout.write(`pasted ${file} → ${target}\n`);
  return 0;
}

function cliRemarkSet(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.remark, CLI_CMD.remarkSet)}\n`);
    return 2;
  }
  const { target, node } = parseTargetSpec(ctx.rest[0]);
  const text = ctx.rest.slice(1).join(" ");
  writeRemark(node, text);
  process.stdout.write(`remark ${target} = ${text || "(cleared)"}\n`);
  return 0;
}

function cliRemarkGet(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.remark, CLI_CMD.remarkGet)}\n`);
    return 2;
  }
  const { node } = parseTargetSpec(ctx.rest[0]);
  const v = readRemark(node);
  process.stdout.write(v ? `${v}\n` : "\n");
  return 0;
}

/** 兼容：remark <spec> [text]；remark get <spec> */
function cliRemarkLegacy(ctx: CliCtx): number {
  const sub = ctx.rest[0];
  if (sub === "get" || sub === "show" || sub === "read") return cliRemarkGet({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "set" || sub === "write") return cliRemarkSet({ ...ctx, rest: ctx.rest.slice(1) });
  return cliRemarkSet(ctx);
}

function cliHelp(): number {
  const lines = [
    `${CLI_BIN} — TMUX 驾驶舱 v${TUI_CONFIG.VERSION} (CLI)`,
    "无子命令 → 进入 TUI",
    "",
    "命令树:",
  ];
  for (const cmd of CLI_ROOT) {
    if (cmd.name === "help") continue;
    const alias = cmd.aliases?.length ? ` (${cmd.aliases.join(", ")})` : "";
    lines.push(`  ${cmd.name}${alias}`);
    lines.push(`    ${cmd.summary}`);
    if (cmd.children) {
      for (const sub of cmd.children) {
        const sa = sub.aliases?.length ? ` (${sub.aliases.join(", ")})` : "";
        lines.push(`    ├─ ${sub.name}${sa}  — ${sub.summary}`);
        lines.push(`    │    usage: ${CLI_BIN} ${cliUsage(cmd, sub)}`);
      }
      lines.push(`    └─ (省略子命令) ${cliUsage(cmd)}  [兼容]`);
    } else if (cmd.usage) {
      lines.push(`    usage: ${CLI_BIN} ${cliUsage(cmd)}`);
    }
  }
  lines.push(
    "",
    "<spec>: @逻辑名 | sess | sess:idx | =sess:idx（@ 仅 remark 反查）",
    "agent: 纯名 + window @agent；register 后 inbox → ~/.tui/inbox/<name>.jsonl",
    // OBSERVER_PAUSED: 消息流镜像 → ~/.tui/bus.jsonl；TUI 按 v 查看
  );
  process.stdout.write(lines.join("\n") + "\n");
  return 0;
}

/** 解析 agent 子命令 flags：--from orch --corr id --timeout 30 */
function parseCliFlags(rest: string[]): { positional: string[]; flags: Record<string, string> } {
  const positional: string[] = [];
  const flags: Record<string, string> = {};
  for (let i = 0; i < rest.length; i++) {
    const a = rest[i];
    if (a === "--from" && rest[i + 1]) { flags.from = rest[++i]; continue; }
    if (a === "--corr" && rest[i + 1]) { flags.corr = rest[++i]; continue; }
    if (a === "--kind" && rest[i + 1]) { flags.kind = rest[++i]; continue; }
    if (a === "--timeout" && rest[i + 1]) { flags.timeout = rest[++i]; continue; }
    if (a === "--since" && rest[i + 1]) { flags.since = rest[++i]; continue; }
    if (a.startsWith("--from=")) { flags.from = a.slice(7); continue; }
    if (a.startsWith("--corr=")) { flags.corr = a.slice(7); continue; }
    if (a.startsWith("--kind=")) { flags.kind = a.slice(7); continue; }
    if (a.startsWith("--timeout=")) { flags.timeout = a.slice(10); continue; }
    if (a === "--follow" || a === "-f") { flags.follow = "1"; continue; }
    if (a === "--mark-read") { flags["mark-read"] = "1"; continue; }
    if (a === "--reply") { flags.kind = "reply"; continue; }
    positional.push(a);
  }
  return { positional, flags };
}

function cliAgentSend(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0] || !flags.from) {
    process.stderr.write(
      `usage: ${CLI_BIN} ${cliUsage(CLI_CMD.agent, CLI_CMD.agentSend)}\n`,
    );
    return 2;
  }
  const body = positional.slice(1).join(" ");
  if (!body) {
    process.stderr.write("error: 消息正文为空\n");
    return 2;
  }
  const kind = (flags.kind === "reply" ? "reply" : "msg") as AgentKind;
  const env = agentSend({
    to: positional[0],
    from: flags.from,
    body,
    corr: flags.corr,
    kind,
  });
  process.stdout.write(`${env.corr}\n`);
  return 0;
}

function cliAgentInbox(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) {
    process.stderr.write(
      `usage: ${CLI_BIN} ${cliUsage(CLI_CMD.agent, CLI_CMD.agentInbox)}\n`,
    );
    return 2;
  }
  const id = resolveAgentName(positional[0]);
  const path = inboxPath(id);
  const since = flags.since ? Date.parse(flags.since) : 0;
  const follow = !!flags.follow;

  const printNew = (fromLine = 0) => {
    const rows = parseInboxFile(path);
    let n = 0;
    for (let i = fromLine; i < rows.length; i++) {
      const e = rows[i];
      if (since && Date.parse(e.ts) < since) continue;
      process.stdout.write(JSON.stringify(e) + "\n");
      n = i + 1;
    }
    return n;
  };

  if (follow) {
    let cursor = printNew(0);
    agentMarkRead(id, cursor);
    process.stderr.write(`following ${path} (Ctrl-C 退出)…\n`);
    while (true) {
      Bun.sleepSync(400);
      const n = agentInboxCount(id);
      if (n > cursor) {
        cursor = printNew(cursor);
        agentMarkRead(id, cursor);
      }
    }
  }

  const end = printNew(0);
  if (flags["mark-read"]) agentMarkRead(id, end);
  return 0;
}

function cliAgentWait(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0] || !flags.corr) {
    process.stderr.write(
      `usage: ${CLI_BIN} ${cliUsage(CLI_CMD.agent, CLI_CMD.agentWait)}\n`,
    );
    return 2;
  }
  const id = resolveAgentName(positional[0]);
  const corr = flags.corr;
  const timeoutMs = Math.max(1000, (parseInt(flags.timeout || "60", 10) || 60) * 1000);
  const deadline = Date.now() + timeoutMs;
  const path = inboxPath(id);
  let scanned = 0;

  while (Date.now() < deadline) {
    const rows = parseInboxFile(path);
    for (let i = scanned; i < rows.length; i++) {
      const e = rows[i];
      if (e.corr === corr && e.kind === "reply") {
        process.stdout.write(JSON.stringify(e) + "\n");
        agentMarkRead(id, i + 1);
        return 0;
      }
    }
    scanned = rows.length;
    Bun.sleepSync(300);
  }
  process.stderr.write(`timeout: 未收到 corr=${corr}\n`);
  return 1;
}

function cliAgentList(_ctx: CliCtx): number {
  const agents = listRegisteredAgents();
  if (agents.length === 0) {
    process.stderr.write("无已注册 agent（tui agent register <spec> <name>）\n");
    return 0;
  }
  for (const a of agents) {
    const unread = a.unread > 0 ? `  unread:${a.unread}` : "";
    process.stdout.write(`${a.id}  ${a.target}${unread}\n`);
  }
  return 0;
}

function cliAgentRegister(ctx: CliCtx): number {
  if (ctx.rest.length < 2) {
    process.stderr.write(
      `usage: ${CLI_BIN} ${cliUsage(CLI_CMD.agent, CLI_CMD.agentRegister)}\n`,
    );
    return 2;
  }
  const { target, node } = parseTargetSpec(ctx.rest[0]);
  if (node.type !== "window") {
    process.stderr.write("error: register 需要 window spec\n");
    return 2;
  }
  const name = normalizeAgentName(ctx.rest[1]);
  writeAgent(node, name);
  process.stdout.write(`agent ${name} → ${target}\n`);
  return 0;
}

function cliAgentUnregister(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(
      `usage: ${CLI_BIN} ${cliUsage(CLI_CMD.agent, CLI_CMD.agentUnregister)}\n`,
    );
    return 2;
  }
  const { target, node } = parseTargetSpec(ctx.rest[0]);
  if (node.type !== "window") {
    process.stderr.write("error: unregister 需要 window spec\n");
    return 2;
  }
  writeAgent(node, "");
  process.stdout.write(`agent cleared on ${target}\n`);
  return 0;
}

function cliAgentLegacy(ctx: CliCtx): number {
  const sub = ctx.rest[0];
  if (sub === "register" || sub === "bind") return cliAgentRegister({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "unregister" || sub === "unbind") return cliAgentUnregister({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "send") return cliAgentSend({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "inbox") return cliAgentInbox({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "wait") return cliAgentWait({ ...ctx, rest: ctx.rest.slice(1) });
  if (sub === "list" || sub === "ls") return cliAgentList(ctx);
  process.stderr.write(`未知 agent 子命令: ${sub}\n`);
  return 2;
}

function cliNewSession(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.newSession)}\n`);
    return 2;
  }
  const name = opNewSession(ctx.rest[0]);
  process.stdout.write(`session ${name}\n`);
  return 0;
}

function cliNewWindow(ctx: CliCtx): number {
  if (ctx.rest.length < 2) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.newWindow)}\n`);
    return 2;
  }
  const name = opNewWindow(ctx.rest[0], ctx.rest[1]);
  process.stdout.write(`window ${ctx.rest[0]}:${name}\n`);
  return 0;
}

function cliRename(ctx: CliCtx): number {
  if (ctx.rest.length < 2) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.rename)}\n`);
    return 2;
  }
  const name = opRename(ctx.rest[0], ctx.rest[1]);
  process.stdout.write(`renamed → ${name}\n`);
  return 0;
}

function cliKillWindow(ctx: CliCtx): number {
  if (!ctx.rest[0]) {
    process.stderr.write(`usage: ${CLI_BIN} ${cliUsage(CLI_CMD.killWindow)}\n`);
    return 2;
  }
  opKillWindow(ctx.rest[0]);
  process.stdout.write(`killed ${resolveTarget(ctx.rest[0])}\n`);
  return 0;
}

function cliDoctor(_ctx: CliCtx): number {
  const key = tmuxPlatformKey();
  const lines = [
    `platform: ${process.platform}/${process.arch} → ${key ?? "不支持便携安装"}`,
    `TMUX_BIN: ${process.env.TMUX_BIN ?? "(未设置)"}`,
    `portable: ${TUI_CONFIG.TMUX_PORTABLE_BIN} (${existsSync(TUI_CONFIG.TMUX_PORTABLE_BIN) ? "有" : "无"})`,
    `resolved: ${resolveTmuxPath() ?? "(未找到)"}`,
    `inside tmux: ${!!process.env.TMUX}`,
  ];
  const p = resolveTmuxPath();
  if (p) {
    const v = Bun.spawnSync([p, "-V"], { stdout: "pipe" }).stdout?.toString().trim();
    lines.push(`version: ${v}`);
  } else {
    lines.push(`hint: ${CLI_BIN} install-tmux`);
  }
  if (process.platform === "darwin" && existsSync(TUI_CONFIG.TMUX_HOME)) {
    const x = Bun.spawnSync(["xattr", "-lr", TUI_CONFIG.TMUX_HOME], { stdout: "pipe" }).stdout?.toString() || "";
    lines.push(x.includes("quarantine") ? "quarantine: 有（执行 xattr -dr com.apple.quarantine ~/tmux）" : "quarantine: 无");
  }
  process.stdout.write(lines.join("\n") + "\n");
  return p ? 0 : 1;
}

function cliInstallTmux(ctx: CliCtx): number {
  const system = ctx.rest.some((a) => a === "--system" || a === "-s");
  const force = ctx.rest.some((a) => a === "--force" || a === "-f");
  if (system) return installTmuxSystem();
  return installTmuxPortable(force);
}

const CLI_CMD = {
  help: { name: "help", aliases: ["-h", "--help"], summary: "显示帮助", run: () => cliHelp() },
  doctor: { name: "doctor", summary: "诊断 tmux 路径/版本/quarantine", run: cliDoctor },
  installTmux: {
    name: "install-tmux",
    aliases: ["install"],
    summary: "安装 tmux（默认便携版→~/tmux）",
    usage: "[--force] [--system]",
    run: cliInstallTmux,
  },
  list: { name: "list", aliases: ["tree", "ls"], summary: "列出 session/window、@remark、末行预览", run: cliList },
  capture: { name: "capture", summary: "capture-pane → stdout", usage: "<spec> [lines]", run: cliCapture },
  send: { name: "send", aliases: ["msg"], summary: "send-keys 注入", usage: "<spec> <text...>", run: cliSend },
  paste: { name: "paste", summary: "load-buffer + paste-buffer", usage: "<spec> <file>", run: cliPaste },
  newSession: {
    name: "new-session",
    aliases: ["ns"],
    summary: "新建 session（-d）",
    usage: "<name>",
    run: cliNewSession,
  },
  newWindow: {
    name: "new-window",
    aliases: ["nw"],
    summary: "在 session 下新建 window",
    usage: "<sess-spec> <name>",
    run: cliNewWindow,
  },
  rename: { name: "rename", summary: "重命名 session/window", usage: "<spec> <name>", run: cliRename },
  killWindow: {
    name: "kill-window",
    aliases: ["delete", "rm"],
    summary: "关闭 window（不含 session）",
    usage: "<spec>",
    run: cliKillWindow,
  },
  remarkSet: { name: "set", aliases: ["write"], summary: "设置 @remark", usage: "<spec> [text...]", run: cliRemarkSet },
  remarkGet: { name: "get", aliases: ["show", "read"], summary: "读取 @remark", usage: "<spec>", run: cliRemarkGet },
  remark: {
    name: "remark",
    summary: "读写 @remark 逻辑名",
    run: cliRemarkLegacy,
    children: [] as CliCommand[],
  },
  agentRegister: {
    name: "register",
    aliases: ["bind"],
    summary: "为 window 设置 @agent 纯名",
    usage: "<window-spec> <name>",
    run: cliAgentRegister,
  },
  agentUnregister: {
    name: "unregister",
    aliases: ["unbind"],
    summary: "清除 window 的 @agent",
    usage: "<window-spec>",
    run: cliAgentUnregister,
  },
  agentSend: {
    name: "send",
    summary: "投递消息到对方 ~/.tui/inbox",
    usage: "<to> --from <me> [--corr id] [--reply] <body>",
    run: cliAgentSend,
  },
  agentInbox: {
    name: "inbox",
    summary: "读取 inbox（jsonl）",
    usage: "<me> [--follow] [--mark-read] [--since iso]",
    run: cliAgentInbox,
  },
  agentWait: {
    name: "wait",
    summary: "阻塞等待 kind=reply 且 corr 匹配",
    usage: "<me> --corr id [--timeout 60]",
    run: cliAgentWait,
  },
  agentList: {
    name: "list",
    aliases: ["ls"],
    summary: "已注册 agent（@agent）与未读",
    run: cliAgentList,
  },
  agent: {
    name: "agent",
    summary: "v0.3 — window @agent 纯名；与 @remark 分离",
    run: cliAgentLegacy,
    children: [] as CliCommand[],
  },
};
CLI_CMD.remark.children = [CLI_CMD.remarkSet, CLI_CMD.remarkGet];
CLI_CMD.agent.children = [
  CLI_CMD.agentRegister,
  CLI_CMD.agentUnregister,
  CLI_CMD.agentSend,
  CLI_CMD.agentInbox,
  CLI_CMD.agentWait,
  CLI_CMD.agentList,
];

const CLI_ROOT: CliCommand[] = [
  CLI_CMD.help,
  CLI_CMD.doctor,
  CLI_CMD.installTmux,
  CLI_CMD.agent,
  CLI_CMD.list,
  CLI_CMD.capture,
  CLI_CMD.send,
  CLI_CMD.paste,
  CLI_CMD.newSession,
  CLI_CMD.newWindow,
  CLI_CMD.rename,
  CLI_CMD.killWindow,
  CLI_CMD.remark,
];

function dispatchCliCommand(cmd: CliCommand, rest: string[]): number {
  if (cmd.children?.length) {
    const sub = rest[0] ? cmd.children.find((c) => matchCliName(c, rest[0])) : undefined;
    if (sub) return sub.run({ bin: CLI_BIN, rest: rest.slice(1) });
    return cmd.run({ bin: CLI_BIN, rest });
  }
  return cmd.run({ bin: CLI_BIN, rest });
}

function cliNeedsTmux(head: string): boolean {
  if (!head) return false;
  if (matchCliName(CLI_CMD.help, head)) return false;
  if (matchCliName(CLI_CMD.doctor, head)) return false;
  if (matchCliName(CLI_CMD.installTmux, head)) return false;
  return true;
}

function runCli(argv: string[]): number {
  const head = argv[2];
  const rest = argv.slice(3);
  const cmd = CLI_ROOT.find((c) => matchCliName(c, head || ""));
  if (!cmd) {
    process.stderr.write(`未知子命令: ${head}\n`);
    return cliHelp() === 0 ? 2 : 2;
  }
  if (cliNeedsTmux(head || "")) {
    const p = resolveTmuxPath();
    if (!p) {
      process.stderr.write(`tmux 未找到。运行: ${CLI_BIN} install-tmux\n`);
      return 1;
    }
    _resolvedTmuxBin = p;
  }
  try {
    return dispatchCliCommand(cmd, rest);
  } catch (e: unknown) {
    process.stderr.write(`error: ${e instanceof Error ? e.message : String(e)}\n`);
    return 1;
  }
}

if (isCliInvocation(process.argv)) {
  process.exit(runCli(process.argv));
}

// ── 启动（TUI 需 tmux；install-tmux / doctor 已在上方 CLI 分支退出）──

const _tmuxAtStart = resolveTmuxPath();
if (!_tmuxAtStart) {
  process.stderr.write(`tmux 未找到。运行: ${CLI_BIN} install-tmux\n`);
  process.stderr.write(`  或系统安装: ${CLI_BIN} install-tmux --system\n`);
  process.exit(1);
}
_resolvedTmuxBin = _tmuxAtStart;

if (state.tree.length === 0) {
  tmuxApi.newSession("main");
  state.tree = getTree();
  if (state.tree.length === 0) {
    tmuxApi.assertAvailable();
  }
}

screen.enterAltScreen();
process.stdin.setRawMode(true);
process.stdin.resume();
disableOuterMouse();
screen.enableMouse(); // SGR 鼠标
process.stdin.on("data", handleKey);

process.on("SIGWINCH", () => refreshPreview());
process.on("exit", () => {
  tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION);
  screen.disableMouse();
  restoreOuterMouse();
  screen.showCursor();
  screen.leaveAltScreen();
  screen.write("\x1b[0m");
  console.log("TMUX 驾驶舱已经离开，用 tui 重新进入");
});
process.on("SIGINT", () => process.exit(0));
process.on("SIGTERM", () => process.exit(0));

// OBSERVER_PAUSED: setInterval(() => { if (state.layoutMode === "observer") render(); }, 1000);

refreshPreview();
