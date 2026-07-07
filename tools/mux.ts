#!/usr/bin/env bun
/**
 * MUX-驾驶舱 — 多路复用器（rmux 默认 / tmux 兼容）之上的车队驾驶舱
 * CLI: `mux help`（可 ln -s ~/.local/bin/mux）
 * 默认后端 rmux: `mux install-rmux` → $HOME/rmux/bin/rmux
 * 兼容回退 tmux: `mux install-tmux` → $HOME/tmux/bin/tmux
 * v0.3 agent: `mux agent register|send|inbox|wait|list` — window 的 @agent 为纯名 id；inbox ~/.tui/inbox/<name>.jsonl
 * CLI 增强: `status` / `inspect` / 全局 `--json` — 供脚本与 agent 拉取结构化车队信息
 * 开发: `mux dev` — bun --watch 热重启（TUI_DEV=1，复用器会话不中断）
 * 暂停功能恢复: docs/paused-features.md
 *
 * PARTS（章节自索引，改章节时只维护下方 `// PART:` 行）:
 *   rg '^// PART:' tools/mux.ts
 *   rg -n 'PART:drive' tools/mux.ts
 *   bun ~/.cursor/skills/code-outline/scripts/outline.ts tools/mux.ts
 *   bun ~/.cursor/skills/code-outline/scripts/outline.ts tools/mux.ts --part cli-registry
 */
import {
  accessSync, appendFileSync, chmodSync, constants, copyFileSync, existsSync,
  mkdirSync, readFileSync, rmSync, writeFileSync,
} from "fs";
import { execFileSync } from "child_process";
import { randomUUID } from "crypto";
import { StringDecoder } from "string_decoder";
import { homedir, tmpdir } from "os";
import { dirname, join } from "path";
import {
  captureFrame, getPaneInfo, listAgentTargets, looksLikeCursor,
  inputBandHas, inputResidue as _inputResidue, analyzeFrame, formatDigestRow,
} from "./fleet-analyzer";
import { runOsCli } from "./os/cli.ts";
import { taskLabelForTarget, ensureOsInit, osPanelLines } from "./os/tui-bridge.ts";
import { createOsTuiActions, type OsTuiActions } from "./os/tui-handlers.ts";

const PREVIEW_DELAY = 1000;        // preview debounce（驾驶 ↑↓ 停稳后再抓）
const DRIVE_NAV_QUIET_MS = 1500;   // ↑↓ 期间暂停后台 snap/proc（覆盖 PREVIEW_DELAY）
const DRIVE_SNAP_TTL_MS = 2000;
const DRIVE_PROC_TTL_MS = 3000;
const DRIVE_SNAP_CONCURRENCY = 6;
const DRIVE_RENDER_DEBOUNCE_MS = 150;
const DRIVE_NAV_FLUSH_SLACK_MS = 30;
const PREVIEW_SCROLL_MAX = 5000;
const MOUSE_DBLCLICK_MS = 500;
const MSG_SUMMARY_MAX = 120;
const RETURN_FROM_ATTACH_DELAY = 120; // detach 后静默 sync tree / restore status
const PREVIEW_LINES = 80;

const SHELL_COMMS = new Set(["bash", "zsh", "sh", "fish", "dash", "tmux", "-bash", "-zsh"]);
const AGENT_COMMS = new Set(["claude", "node", "python", "python3", "bun"]);

const TUI_CONFIG = {
  VERSION: '0.6.0',
  VIEWER_SESSION: `__tui_viewer__`,
  TUI_KEYTABLE: "tui_empty",
  REMARK_KEY: "@remark",
  AGENT_KEY: "@agent",
  AUTO_KEY: "@auto",
  TITLE: "MUX-驾驶舱",
  TMUX_HOME: join(homedir(), "tmux"),
  TMUX_PORTABLE_BIN: join(homedir(), "tmux", "bin", "tmux"),
  RMUX_HOME: join(homedir(), "rmux"),
  RMUX_PORTABLE_BIN: join(homedir(), "rmux", "bin", "rmux"),
  DATA_DIR: join(homedir(), ".tui"),
  INBOX_DIR: join(homedir(), ".tui", "inbox"),
  READ_DIR: join(homedir(), ".tui", "read"),
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

/** tmux/tmux-builds 官方 static 包，安装时从 GitHub Releases 动态解析 */
const TMUX_REPO = "tmux/tmux-builds";

/** tmux-builds asset 命名的 os/arch keyword（macos-arm64 / linux-x86_64 等） */
function tmuxAssetKeyword(): string | null {
  const os = process.platform === "darwin" ? "macos" : process.platform === "linux" ? "linux" : null;
  const arch = process.arch === "arm64" ? "arm64" : process.arch === "x64" ? "x86_64" : null;
  if (!os || !arch) return null;
  return `${os}-${arch}`;
}

/** rmux（Helvesec/rmux） — Rust 写的 tmux 兼容多路复用器，安装信息从 GitHub Releases 动态解析 */
const RMUX_REPO = "Helvesec/rmux";

/** 返回当前主机的 Rust target triple，用于匹配 release asset 名称 */
function rmuxRustTarget(): string | null {
  const arch = process.arch === "arm64" ? "aarch64" : process.arch === "x64" ? "x86_64" : null;
  if (!arch) return null;
  if (process.platform === "darwin") return `${arch}-apple-darwin`;
  if (process.platform === "linux") return `${arch}-unknown-linux-gnu`;
  if (process.platform === "win32") return `${arch}-pc-windows-msvc`;
  return null;
}

// PART:ansi-screen

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
  eraseDown() { this.write(`${this.ESC}J`); }
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

/** pipe/head 关读端时 EPIPE 立即退出，TTY 才等 drain */
function cliInstallPipeGuard(stream: NodeJS.WriteStream): void {
  stream.on("error", (err: NodeJS.ErrnoException) => {
    if (err.code === "EPIPE") process.exit(0);
  });
}

function cliWriteStdout(text: string): void {
  if (process.stdout.destroyed) return;
  try {
    const needDrain = !process.stdout.write(text);
    if (needDrain && process.stdout.isTTY) {
      process.stdout.once("drain", () => {});
    }
  } catch (e: unknown) {
    if ((e as NodeJS.ErrnoException).code === "EPIPE") process.exit(0);
  }
}

function cliWriteStderr(text: string): void {
  if (process.stderr.destroyed) return;
  try {
    const needDrain = !process.stderr.write(text);
    if (needDrain && process.stderr.isTTY) {
      process.stderr.once("drain", () => {});
    }
  } catch (e: unknown) {
    if ((e as NodeJS.ErrnoException).code === "EPIPE") process.exit(0);
  }
}

function cliError(message: string, code = 2): number {
  cliWriteStderr(`error: ${message}\n`);
  return code;
}

/** catch(e){return cliError(e instanceof Error?e.message:String(e))} 样板收敛,catch块直接 return cliCatch(e) */
function cliCatch(e: unknown, code = 2): number {
  return cliError(e instanceof Error ? e.message : String(e), code);
}

// PART:tmux-bootstrap

function isExecutable(p: string): boolean {
  try {
    accessSync(p, constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

function tmuxPlatformKey(): string | null {
  // 仅用于 doctor 输出展示
  return tmuxAssetKeyword();
}

/**
 * 后端解析顺序：TMUX_BIN（显式覆盖） → rmux（默认，跨平台/Rust） → tmux（兼容回退）。
 * 设 TUI_USE_TMUX=1 强制走 tmux 优先。
 */
function resolveTmuxPath(): string | null {
  if (process.env.TMUX_BIN) {
    const p = process.env.TMUX_BIN;
    if (isExecutable(p)) return p;
  }
  const tmuxFirst = process.env.TUI_USE_TMUX !== "0"; // 默认 tmux 优先
  const tryTmux = (): string | null => {
    if (isExecutable(TUI_CONFIG.TMUX_PORTABLE_BIN)) return TUI_CONFIG.TMUX_PORTABLE_BIN;
    return Bun.which("tmux") ?? null;
  };
  if (tmuxFirst) return tryTmux() ?? resolveRmuxPath();
  return resolveRmuxPath() ?? tryTmux();
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
  if (!force && isExecutable(TUI_CONFIG.TMUX_PORTABLE_BIN)) {
    cliWriteStdout(`已存在: ${TUI_CONFIG.TMUX_PORTABLE_BIN}\n`);
    return 0;
  }
  const kw = tmuxAssetKeyword();
  if (!kw) {
    cliWriteStderr(`不支持的平台 ${process.platform}/${process.arch}\n`);
    return 1;
  }
  cliWriteStderr(`查询 ${TMUX_REPO} 最新 release …\n`);
  const release = ghFetchLatestRelease(TMUX_REPO);
  if (!release) {
    cliWriteStderr(`GitHub API 拉取失败；可设 GITHUB_TOKEN 或用 --system\n`);
    return 1;
  }
  const asset = release.assets.find((a) => a.name.endsWith(".tar.gz") && a.name.includes(kw) && !/^LICENSES/i.test(a.name));
  if (!asset) {
    cliWriteStderr(`${release.tag_name} 无 ${kw} 预编译包\n`);
    return 1;
  }
  const binDir = join(TUI_CONFIG.TMUX_HOME, "bin");
  const cacheDir = join(TUI_CONFIG.TMUX_HOME, ".cache");
  mkdirSync(binDir, { recursive: true });
  mkdirSync(cacheDir, { recursive: true });
  const archive = join(cacheDir, asset.name);
  cliWriteStderr(`下载 ${asset.browser_download_url}\n`);
  const dl = Bun.spawnSync(["curl", "-fsSL", "-o", archive, asset.browser_download_url], { stdout: "pipe", stderr: "pipe" });
  if (dl.exitCode !== 0) {
    cliWriteStderr(`下载失败: ${dl.stderr?.toString() || "curl error"}\n`);
    return 1;
  }
  const wantSha = ghFetchSha256(release, asset.name);
  if (wantSha) {
    const got = sha256File(archive);
    if (got !== wantSha) {
      cliWriteStderr(`校验失败: expected ${wantSha} got ${got}\n`);
      return 1;
    }
  } else {
    cliWriteStderr(`(无 SHA256SUMS，跳过校验)\n`);
  }
  const extractDir = join(cacheDir, asset.name.replace(/\.tar\.gz$/, ""));
  rmSync(extractDir, { recursive: true, force: true });
  mkdirSync(extractDir, { recursive: true });
  const untar = Bun.spawnSync(["tar", "-xzf", archive, "-C", extractDir], { stdout: "pipe", stderr: "pipe" });
  if (untar.exitCode !== 0) {
    cliWriteStderr(`解包失败: ${untar.stderr?.toString()}\n`);
    return 1;
  }
  const found = Bun.spawnSync(["find", extractDir, "-type", "f", "-name", "tmux"], { stdout: "pipe" }).stdout?.toString().split("\n").filter(Boolean) ?? [];
  const extracted = found.find(isExecutable) ?? found[0];
  if (!extracted) {
    cliWriteStderr(`解包后未找到可执行文件 tmux\n`);
    return 1;
  }
  copyFileSync(extracted, TUI_CONFIG.TMUX_PORTABLE_BIN);
  chmodSync(TUI_CONFIG.TMUX_PORTABLE_BIN, 0o755);
  if (process.platform === "darwin") {
    Bun.spawnSync(["xattr", "-dr", "com.apple.quarantine", TUI_CONFIG.TMUX_HOME], { stdout: "pipe", stderr: "pipe" });
  }
  resetTmuxBinCache();
  const ver = Bun.spawnSync([TUI_CONFIG.TMUX_PORTABLE_BIN, "-V"], { stdout: "pipe" }).stdout?.toString().trim();
  cliWriteStdout(`已安装 → ${TUI_CONFIG.TMUX_PORTABLE_BIN}  (${ver})\n`);
  return 0;
}

function installTmuxSystem(): number {
  if (process.platform === "darwin") {
    const brew = Bun.which("brew");
    if (!brew) {
      cliWriteStderr("未找到 brew，请用: tui install-tmux（便携版）\n");
      return 1;
    }
    cliWriteStderr("brew install tmux …\n");
    const r = Bun.spawnSync([brew, "install", "tmux"], { stdin: "inherit", stdout: "inherit", stderr: "inherit" });
    resetTmuxBinCache();
    return r.exitCode ?? 1;
  }
  if (process.platform === "linux") {
    if (Bun.which("apt-get")) {
      cliWriteStderr("请运行: sudo apt-get update && sudo apt-get install -y tmux\n");
    } else if (Bun.which("dnf")) {
      cliWriteStderr("请运行: sudo dnf install -y tmux\n");
    } else {
      cliWriteStderr("请用: tui install-tmux（便携版，无需 root）\n");
    }
    return 1;
  }
  cliWriteStderr(`不支持的平台 ${process.platform}\n`);
  return 1;
}

function resolveRmuxPath(): string | null {
  if (process.env.RMUX_BIN) {
    const p = process.env.RMUX_BIN;
    if (isExecutable(p)) return p;
  }
  if (isExecutable(TUI_CONFIG.RMUX_PORTABLE_BIN)) return TUI_CONFIG.RMUX_PORTABLE_BIN;
  const onPath = Bun.which("rmux");
  if (onPath) return onPath;
  return null;
}

interface GhReleaseAsset { name: string; browser_download_url: string; }
interface GhRelease { tag_name: string; assets: GhReleaseAsset[]; }

function ghFetchLatestRelease(repo: string): GhRelease | null {
  const url = `https://api.github.com/repos/${repo}/releases/latest`;
  const args = ["-fsSL", "-H", "Accept: application/vnd.github+json"];
  if (process.env.GITHUB_TOKEN) args.push("-H", `Authorization: Bearer ${process.env.GITHUB_TOKEN}`);
  args.push(url);
  const r = Bun.spawnSync(["curl", ...args], { stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0) return null;
  try { return JSON.parse(r.stdout!.toString()) as GhRelease; } catch { return null; }
}

/** 选最合适的 asset：优先 target triple，再退到 os/arch 关键词，过滤 musl/sha 等 */
function pickRmuxAsset(release: GhRelease, target: string): GhReleaseAsset | null {
  const exts = process.platform === "win32" ? [".zip"] : [".tar.gz", ".tgz"];
  const matchesExt = (n: string) => exts.some((e) => n.endsWith(e));
  const isMusl = (n: string) => /musl/i.test(n);
  const preferMusl = process.platform === "linux" && !existsSync("/lib/x86_64-linux-gnu/libc.so.6") && !existsSync("/lib64/libc.so.6");
  const wantTriple = preferMusl && process.platform === "linux"
    ? target.replace("-unknown-linux-gnu", "-unknown-linux-musl")
    : target;
  const candidates = release.assets.filter((a) => matchesExt(a.name) && !/\.(sha256|sig|asc)$/i.test(a.name));
  const exact = candidates.find((a) => a.name.includes(wantTriple));
  if (exact) return exact;
  const loose = candidates.find((a) => a.name.includes(target));
  if (loose) return loose;
  return candidates.find((a) => !isMusl(a.name) && a.name.includes(process.arch === "x64" ? "x86_64" : process.arch)) || null;
}

/** 从 SHA256SUMS 文件查指定 asset 的 hash；找不到返回 null（不致命，但会警告） */
function ghFetchSha256(release: GhRelease, assetName: string): string | null {
  const sums = release.assets.find((a) => /sha256sums?/i.test(a.name));
  if (!sums) return null;
  const r = Bun.spawnSync(["curl", "-fsSL", sums.browser_download_url], { stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0) return null;
  for (const line of r.stdout!.toString().split(/\r?\n/)) {
    const m = line.match(/^([0-9a-f]{64})\s+\*?(.+)$/i);
    if (m && m[2].trim().endsWith(assetName)) return m[1].toLowerCase();
  }
  return null;
}

function installRmuxPortable(force = false): number {
  if (!force && isExecutable(TUI_CONFIG.RMUX_PORTABLE_BIN)) {
    cliWriteStdout(`已存在: ${TUI_CONFIG.RMUX_PORTABLE_BIN}\n`);
    return 0;
  }
  const target = rmuxRustTarget();
  if (!target) {
    cliWriteStderr(`不支持的平台 ${process.platform}/${process.arch}\n`);
    return 1;
  }
  cliWriteStderr(`查询 ${RMUX_REPO} 最新 release …\n`);
  const release = ghFetchLatestRelease(RMUX_REPO);
  if (!release) {
    cliWriteStderr(`GitHub API 拉取失败；可设 GITHUB_TOKEN 或试 --system\n`);
    return 1;
  }
  const asset = pickRmuxAsset(release, target);
  if (!asset) {
    cliWriteStderr(`${release.tag_name} 无 ${target} 预编译包；试: tui install-rmux --system（cargo）\n`);
    return 1;
  }
  const binDir = join(TUI_CONFIG.RMUX_HOME, "bin");
  const cacheDir = join(TUI_CONFIG.RMUX_HOME, ".cache");
  mkdirSync(binDir, { recursive: true });
  mkdirSync(cacheDir, { recursive: true });
  const archive = join(cacheDir, asset.name);
  cliWriteStderr(`下载 ${asset.browser_download_url}\n`);
  const dl = Bun.spawnSync(["curl", "-fsSL", "-o", archive, asset.browser_download_url], { stdout: "pipe", stderr: "pipe" });
  if (dl.exitCode !== 0) {
    cliWriteStderr(`下载失败: ${dl.stderr?.toString() || "curl error"}\n`);
    return 1;
  }
  const wantSha = ghFetchSha256(release, asset.name);
  if (wantSha) {
    const got = sha256File(archive);
    if (got !== wantSha) {
      cliWriteStderr(`校验失败: expected ${wantSha} got ${got}\n`);
      return 1;
    }
  } else {
    cliWriteStderr(`(无 SHA256SUMS，跳过校验)\n`);
  }
  const extractDir = join(cacheDir, asset.name.replace(/\.(tar\.gz|tgz|zip)$/i, ""));
  rmSync(extractDir, { recursive: true, force: true });
  mkdirSync(extractDir, { recursive: true });
  const isZip = /\.zip$/i.test(asset.name);
  const unpack = isZip
    ? Bun.spawnSync(["unzip", "-q", archive, "-d", extractDir], { stdout: "pipe", stderr: "pipe" })
    : Bun.spawnSync(["tar", "-xzf", archive, "-C", extractDir], { stdout: "pipe", stderr: "pipe" });
  if (unpack.exitCode !== 0) {
    cliWriteStderr(`解包失败: ${unpack.stderr?.toString()}\n`);
    return 1;
  }
  const binName = process.platform === "win32" ? "rmux.exe" : "rmux";
  const found = Bun.spawnSync(["find", extractDir, "-type", "f", "-name", binName], { stdout: "pipe" }).stdout?.toString().split("\n").filter(Boolean) ?? [];
  const extracted = found.find(isExecutable) ?? found[0];
  if (!extracted) {
    cliWriteStderr(`解包后未找到可执行文件 ${binName}\n`);
    return 1;
  }
  copyFileSync(extracted, TUI_CONFIG.RMUX_PORTABLE_BIN);
  chmodSync(TUI_CONFIG.RMUX_PORTABLE_BIN, 0o755);
  // 拷贝 libexec/ 目录（rmux 二进制运行时需要找到 libexec/rmux/rmux helper）
  const extractedDir = dirname(extracted);
  const libexecSrc = join(extractedDir, "..", "libexec");
  const libexecDst = join(TUI_CONFIG.RMUX_HOME, "libexec");
  if (existsSync(libexecSrc)) {
    rmSync(libexecDst, { recursive: true, force: true });
    Bun.spawnSync(["cp", "-r", libexecSrc, libexecDst], { stdout: "pipe", stderr: "pipe" });
  }
  if (process.platform === "darwin") {
    Bun.spawnSync(["xattr", "-dr", "com.apple.quarantine", TUI_CONFIG.RMUX_HOME], { stdout: "pipe", stderr: "pipe" });
  }
  const ver = Bun.spawnSync([TUI_CONFIG.RMUX_PORTABLE_BIN, "-V"], { stdout: "pipe" }).stdout?.toString().trim();
  cliWriteStdout(`已安装 ${release.tag_name} → ${TUI_CONFIG.RMUX_PORTABLE_BIN}  (${ver})\n`);
  return 0;
}

function installRmuxSystem(): number {
  if (process.platform === "darwin") {
    const brew = Bun.which("brew");
    if (brew) {
      cliWriteStderr("brew install Helvesec/tap/rmux …\n");
      const r = Bun.spawnSync([brew, "install", "Helvesec/tap/rmux"], { stdin: "inherit", stdout: "inherit", stderr: "inherit" });
      if (r.exitCode === 0) return 0;
    }
  }
  const cargo = Bun.which("cargo");
  if (cargo) {
    cliWriteStderr("cargo install rmux --locked …\n");
    const r = Bun.spawnSync([cargo, "install", "rmux", "--locked"], { stdin: "inherit", stdout: "inherit", stderr: "inherit" });
    return r.exitCode ?? 1;
  }
  cliWriteStderr("未找到 brew/cargo；请用: tui install-rmux（便携版）\n");
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

// PART:text-utils

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

// PART:tmux-backend
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
  sendKeysLiteral(target: string, text: string): unknown;
  loadBufferFromText(text: string): unknown;
  loadBuffer(target: string, file: string): unknown;
  pasteBuffer(target: string): unknown;
  sendKeysEnter(target: string): unknown;
  listPanes(target: string, fmt: string): string[];

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
  unbindKey(table: string | null, key: string): unknown;
  unbindKeyRoot(key: string): unknown;

  // ── raw fallback ──
  rawSpawnSync(args: string[]): unknown;

  // ── 运行时探测 ──
  /** 当前进程是否运行在 multiplexer session 内（用于外层鼠标穿透处理）。 */
  isInsideSession(): boolean;
  /** 后端不可用时抛错或打印诊断并退出。 */
  assertAvailable(): void;
}

/**
 * 本地 tmuxApi 与 -L 独立 socket 的 super 共用的 spawnSync+错误处理核心：
 * mode="print" 静默吞掉后 stderr 打印+照常返回 stdout(本地 tmux() / capturePaneText 用)；
 * mode="throw" 未命中 missingRe 时直接抛错(super 需要调用方能感知失败,不能悄悄吞掉)；
 * mode="silent" 只用 exitCode 判断,不打印不抛(superTmuxHasSession 这类纯探活场景)。
 */
function runTmuxCmd(
  bin: string,
  label: string,
  args: string[],
  opts?: { missingOk?: boolean; missingRe?: RegExp; mode?: "print" | "throw" | "silent" },
): { stdout: string; exitCode: number } {
  const out = Bun.spawnSync([bin, ...args], { stdout: "pipe", stderr: "pipe" });
  if (out.exitCode !== 0) {
    const stderr = out.stderr.toString();
    const missingRe = opts?.missingRe ?? /can't find session|no such session|session not found/i;
    if (opts?.missingOk && missingRe.test(stderr)) {
      return { stdout: out.stdout.toString(), exitCode: 0 };
    }
    const mode = opts?.mode ?? "print";
    if (mode === "throw") {
      throw new Error(`[${label} ${args.join(" ")}] exit=${out.exitCode} ${stderr.trim()}`);
    }
    if (mode === "print" && !tmuxQuietDepth) {
      cliWriteStderr(`[${label} ${args.join(" ")}] exit=${out.exitCode} ${stderr}`);
    }
  }
  return { stdout: out.stdout.toString(), exitCode: out.exitCode };
}

// TmuxBackend — IMultiplexerBackend 的 tmux 实现。target 一律用 `=NAME[:IDX]` 精确语法。
function tmux(args: string[], opts?: { missingOk?: boolean; unsetOk?: boolean }): string {
  // 用户自定义 @option 未设置时 show-options 报 invalid option，视为空值——这个特判先于
  // 通用错误上报(不打印/不抛,直接判空),故不下沉进 runTmuxCmd。
  if (opts?.unsetOk) {
    const probe = Bun.spawnSync([tmuxBin(), ...args], { stdout: "pipe", stderr: "pipe" });
    if (probe.exitCode !== 0 && /invalid option|unknown option|option not found/i.test(probe.stderr.toString())) {
      return "";
    }
    return probe.stdout.toString();
  }
  return runTmuxCmd(tmuxBin(), "tmux", args, { missingOk: opts?.missingOk, mode: "print" }).stdout;
}

const TMUX_PASTE_BUF = `tui_v2_${process.pid}`;

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
  capturePaneText: (target: string, startN: number, endArg = "-") =>
    runTmuxCmd(
      tmuxBin(),
      "tmux capture-pane",
      ["capture-pane", "-p", "-t", target, "-S", `-${startN}`, "-E", endArg],
      { mode: "print" },
    ).stdout,
  sendKeys: (target: string, text: string) => {
    tmuxApi.loadBufferFromText(text);
    tmuxApi.pasteBuffer(target);
    tmuxApi.sendKeysEnter(target);
  },
  sendKeysLiteral: (target: string, text: string) => {
    tmuxApi.loadBufferFromText(text);
    tmuxApi.pasteBuffer(target);
  },
  loadBufferFromText: (text: string) =>
    Bun.spawnSync([tmuxBin(), "load-buffer", "-b", TMUX_PASTE_BUF, "-"], {
      stdin: Buffer.from(text, "utf8"),
    }),
  loadBuffer: (target: string, file: string) =>
    Bun.spawnSync([tmuxBin(), "load-buffer", "-b", TMUX_PASTE_BUF, file]),
  // -p：发 bracketed-paste 控制码(应用请求时)。无此则多行正文里的 \n 被当 Enter 逐行提交→
  // claude TUI 把 @file 拆成多条 queued 消息且末行(无尾 \n)滞留输入框=「落框未提交」根因。
  // 对未启用 bracketed-paste 的应用(bash)是 no-op,安全通用。
  pasteBuffer: (target: string) =>
    Bun.spawnSync([tmuxBin(), "paste-buffer", "-p", "-d", "-b", TMUX_PASTE_BUF, "-t", target]),
  sendKeysEnter: (target: string) =>
    Bun.spawnSync([tmuxBin(), "send-keys", "-t", target, "Enter"]),
  listPanes: (target: string, fmt: string): string[] =>
    tmux(["list-panes", "-t", target, "-F", fmt]).trim().split("\n").filter(Boolean),
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
  unbindKey: (table: string | null, key: string) =>
    table ? tmux(["unbind-key", "-T", table, key]) : tmux(["unbind-key", "-n", key]),
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
      console.log(`复用器未找到。默认安装 rmux: ${bin} install-rmux`);
      console.log(`  或 tmux（兼容回退）: ${bin} install-tmux`);
      process.exit(1);
    }
    _resolvedTmuxBin = p;
  },
};


// PART:target
// 不使用 tmux `=NAME` 精确匹配前缀（rmux 不支持，且 tmux 各子命令支持不一致）。
// 我们自己生成的 session 名无前缀歧义；尾冒号区分 session vs window target。
function buildSessTarget(sessionName: string): string {
  return `${sessionName}:`;
}
function buildSessOnlyTarget(sessionName: string): string {
  return sessionName;
}
function buildWinTarget(sessionName: string, idx: string | number): string {
  // window 名含 `.` 时（如 buddy-glm5.2）tmux 会把 `.` 解析为 pane 分隔符
  // → 必须先查 list-windows 把 name 翻译成 window_index 再拼，否则 sendKeys / capture-pane 全报 can't find pane
  if (typeof idx === "string") {
    return `${sessionName}:${resolveWindowIndex(sessionName, idx)}`;
  }
  return `${sessionName}:${idx}`;
}

function buildWinIndexTarget(sessionName: string, idx: string | number): string {
  return `${sessionName}:${idx}`;
}

/** name → window_index：先按 window_name 精确匹配（抗窗口索引漂移）。纯数字拒绝回退为索引，强制使用窗口名称。*/
function resolveWindowIndex(sessionName: string, nameOrIdx: string): string {
  // name-first: 先按 window_name 精确匹配当前 index(抗窗口索引漂移;用户铁律:target 用 name 找 idx)
  try {
    for (const row of tmuxApi.listWindows(sessionName, "#{window_index}|#{window_name}")) {
      const [wi, wn] = row.split("|");
      if (wn === nameOrIdx) return wi;
    }
  } catch { /* fallthrough */ }
  if (/^\d+$/.test(nameOrIdx))
    throw new Error(`拒绝数字 "${nameOrIdx}" 作为窗口标识——mux 要求使用窗口名称, 不使用窗口索引。用 "session:窗口名" 格式。`);
  return nameOrIdx; // 非数字且无同名→交给 tmux 报错
}

function currentTmuxSessionName(): string {
  if (!process.env.TMUX_PANE) return "";
  const r = Bun.spawnSync([tmuxBin(), "display-message", "-p", "-t", process.env.TMUX_PANE, "#S"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  return (r.stdout?.toString() ?? "").trim();
}

function hasWindowName(sessionName: string, windowName: string): boolean {
  try {
    for (const wn of tmuxApi.listWindows(sessionName, "#{window_name}")) {
      if (wn === windowName) return true;
    }
  } catch { /* fallthrough */ }
  return false;
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

// PART:tree-data

interface TreeNode {
  label: string;
  target: string;
  indent: number;
  type: "session" | "window";
  sessionName: string;
  remark?: string;
  agent?: string;
  /** tmux #{window_activity} epoch seconds */
  windowActivity?: number;
  /** tmux #{window_active} */
  windowActive?: boolean;
  /** syncTree 时批量读取 #{@auto}，render 路径不再 spawn tmux */
  autoLevel?: AutoLevel;
  /** syncTree / f 刷新时缓存，render 路径不读 inbox */
  cachedUnread?: number;
  /** f 刷新时在 drive 模式预计算，排序不再重复 windowMeta */
  driveSortScore?: number;
}

const AUTO_LEVELS = ["0", "50", "100"] as const;
type AutoLevel = (typeof AUTO_LEVELS)[number];

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
    ? buildWinIndexTarget(node.sessionName, node.target.split(":")[1] ?? "")
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

function normalizeAutoLevel(raw: string): AutoLevel {
  return raw === "50" || raw === "100" ? raw : "0";
}

function readAuto(node: { type: "session" | "window"; target: string; sessionName: string }): AutoLevel {
  return normalizeAutoLevel(readUserOption(node, TUI_CONFIG.AUTO_KEY));
}

function nextAutoLevel(cur: AutoLevel): AutoLevel {
  const i = AUTO_LEVELS.indexOf(cur);
  return AUTO_LEVELS[(i + 1) % AUTO_LEVELS.length];
}

function writeNodeOpt(node: TreeNode, key: string, raw: string | null): void {
  if (key === TUI_CONFIG.AGENT_KEY || key === TUI_CONFIG.AUTO_KEY) {
    if (node.type !== "window") throw new Error(`${key} 仅可绑定 window`);
  }
  let val: string | null = raw;
  if (key === TUI_CONFIG.AUTO_KEY) {
    const lvl = normalizeAutoLevel(raw ?? "0");
    val = lvl === "0" ? null : lvl;
  } else if (val === "") {
    val = null;
  }
  if (node.type === "session") {
    setUserOption(buildSessTarget(node.sessionName), false, key, val);
  } else {
    const idx = node.target.split(":")[1] ?? "";
    setUserOption(buildWinIndexTarget(node.sessionName, idx), true, key, val);
  }
}

function writeRemark(node: TreeNode, value: string) {
  writeNodeOpt(node, TUI_CONFIG.REMARK_KEY, value || null);
}

function writeAgent(node: TreeNode, value: string) {
  writeNodeOpt(node, TUI_CONFIG.AGENT_KEY, value || null);
}

function writeAuto(node: TreeNode, value: string) {
  writeNodeOpt(node, TUI_CONFIG.AUTO_KEY, value);
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

function findNodeByRemark(wanted: string, source?: TreeNode[]): TreeNode | null {
  const tree = source ?? (state.tree.length > 0 ? state.tree : syncTree());
  for (const n of tree) {
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
    const currentSession = currentTmuxSessionName();
    if (currentSession && hasWindowName(currentSession, spec)) {
      const target = buildWinTarget(currentSession, spec);
      return {
        target,
        node: { label: "", target: `${currentSession}:${spec}`, indent: 1, type: "window", sessionName: currentSession },
      };
    }
    // 当前 session 无此窗口 → 搜所有 session 的 window name
    for (const sess of tmuxApi.listSessions()) {
      if (sess === currentSession) continue; // 已查过
      if (hasWindowName(sess, spec)) {
        const target = buildWinTarget(sess, spec);
        return {
          target,
          node: { label: "", target: `${sess}:${spec}`, indent: 1, type: "window", sessionName: sess },
        };
      }
    }
    // 全 session 找不到 → 当 session 名处理
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
      ? buildWinIndexTarget(node.sessionName, node.target.split(":")[1] ?? "")
      : buildSessTarget(node.sessionName);
  return { target, node };
}

function resolveTarget(spec: string): string {
  return parseTargetSpec(spec).target;
}

// PART:domain-ops

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
  const { node, target } = parseTargetSpec(spec);
  const n = normName(newName, node.type);
  if (node.type === "session") tmuxApi.renameSession(node.sessionName, n);
  else tmuxApi.renameWindow(target, n);
  return n;
}

function opKillWindow(spec: string): void {
  const { node, target } = parseTargetSpec(spec);
  if (node.type === "session") throw new Error("kill-window 仅支持 window（sess:idx 或 @remark→window）");
  tmuxApi.killWindow(target);
}

function paneCount(target: string): number {
  try {
    return tmuxApi.listPanes(target, "#{pane_index}").length;
  } catch {
    return 0;
  }
}

function resolveInputPaneTarget(target: string): string {
  return paneCount(target) > 1 ? `${target}.0` : target;
}

function splitScriptPath(target: string): string {
  const safe = target.replace(/[^a-zA-Z0-9._-]/g, "_");
  return join(TUI_CONFIG.DATA_DIR, "split-buffer", `${safe}.sh`);
}

function writeSplitBufferScript(target: string): string {
  const pane0 = `${target}.0`;
  const path = splitScriptPath(target);
  mkdirSync(dirname(path), { recursive: true });
  // 用 mux send（paste-buffer + Enter 已验证可靠），不用 fd write
  const muxBin = join(process.cwd(), "bin", "mux");
  const script = `#!/usr/bin/env bash
set -euo pipefail
target=${JSON.stringify(pane0)}
while IFS= read -r -e -p '> ' line; do
  [[ -n "$line" ]] && ${JSON.stringify(muxBin)} send "$target" "$line"
done
`;
  writeFileSync(path, script);
  chmodSync(path, 0o755);
  return path;
}

function opSplit(spec: string): { target: string; paneCount: number; created: boolean } {
  const { node, target } = parseTargetSpec(spec);
  if (node.type !== "window") throw new Error("split 仅支持 window（sess:idx / sess:name / @remark→window）");
  const before = paneCount(target);
  if (before > 1) return { target, paneCount: before, created: false };
  const script = writeSplitBufferScript(target);
  const r = tmuxApi.rawSpawnSync(["split-window", "-v", "-l", "3", "-t", target, `bash ${script}`]) as { exitCode?: number; stderr?: Uint8Array };
  if ((r.exitCode ?? 0) !== 0) {
    throw new Error(`split-window failed: ${Buffer.from(r.stderr ?? new Uint8Array()).toString().trim()}`);
  }
  return { target, paneCount: paneCount(target), created: true };
}

function opUnsplit(spec: string): { target: string; paneCount: number; killed: boolean } {
  const { node, target } = parseTargetSpec(spec);
  if (node.type !== "window") throw new Error("unsplit 仅支持 window（sess:idx / sess:name / @remark→window）");
  const before = paneCount(target);
  if (before <= 1) return { target, paneCount: before, killed: false };
  const r = tmuxApi.rawSpawnSync(["kill-pane", "-t", `${target}.1`]) as { exitCode?: number; stderr?: Uint8Array };
  if ((r.exitCode ?? 0) !== 0) {
    throw new Error(`kill-pane failed: ${Buffer.from(r.stderr ?? new Uint8Array()).toString().trim()}`);
  }
  return { target, paneCount: paneCount(target), killed: true };
}

// PART:super — byobu-super 外壳（独立 tmux socket + 下方输入框）
const SUPER_DEFAULT_SOCK = "byobu-super";
const SUPER_DEFAULT_SESSION = "main";
const SUPER_DEFAULT_INPUT_LINES = 6;
const SUPER_INPUT_TITLE = "byobu-super-input";

/** super 模式强制用真 tmux（byobu / -L / -f /dev/null 均依赖 tmux 语义） */
function superTmuxBin(): string {
  if (process.env.TMUX_BIN && isExecutable(process.env.TMUX_BIN)) return process.env.TMUX_BIN;
  if (isExecutable(TUI_CONFIG.TMUX_PORTABLE_BIN)) return TUI_CONFIG.TMUX_PORTABLE_BIN;
  const p = Bun.which("tmux");
  if (!p) throw new Error("super 需要 tmux（byobu 基于 tmux）；运行: mux install-tmux");
  return p;
}

function superTmuxArgs(sock: string, args: string[], opts?: { newServer?: boolean }): string[] {
  const prefix: string[] = ["-L", sock];
  if (opts?.newServer) prefix.push("-f", "/dev/null");
  return prefix.concat(args);
}

const SUPER_MISSING_RE = /can't find session|no such session|session not found|can't find pane|unknown command|not bound|no key bindings/i;

function superTmux(sock: string, args: string[], opts?: { newServer?: boolean; missingOk?: boolean }): string {
  return runTmuxCmd(superTmuxBin(), `tmux -L ${sock}`, superTmuxArgs(sock, args, opts), {
    missingOk: opts?.missingOk,
    missingRe: SUPER_MISSING_RE,
    mode: "throw",
  }).stdout;
}

function superTmuxHasSession(sock: string, session: string): boolean {
  return runTmuxCmd(superTmuxBin(), `tmux -L ${sock}`, ["-L", sock, "has-session", "-t", session], { mode: "silent" }).exitCode === 0;
}

function shSingleQuote(s: string): string {
  return `'${s.replace(/'/g, "'\\''")}'`;
}

function buildSuperInputInvoke(selfScript: string, target: string, sock: string, session: string): string {
  const args = `super-input ${shSingleQuote(target)} ${shSingleQuote(sock)} ${shSingleQuote(session)}`;
  if (selfScript.endsWith(".ts")) {
    const bun = Bun.which("bun") ?? "bun";
    return `${bun} ${shSingleQuote(selfScript)} ${args}`;
  }
  return `${shSingleQuote(selfScript)} ${args}`;
}

function validateSuperSock(sock: string): string | null {
  if (!/^[A-Za-z0-9_.-]+$/.test(sock)) return `invalid socket name: ${sock}`;
  // 防呆：拒绝 tmux/byobu 系统保留 socket 名，避免 super 绑定污染用户主会话（F-key 劫持事故根因）
  if (/^(default|byobu)$/i.test(sock)) return `refused reserved socket "${sock}": 会污染 byobu/tmux 主会话，请用隔离名（默认 byobu-super）`;
  return null;
}

function validateSuperSession(session: string): string | null {
  return /^[A-Za-z0-9_-]+$/.test(session) ? null : `invalid session name: ${session}`;
}

function validateSuperInputLines(lines: number): string | null {
  return Number.isInteger(lines) && lines >= 1 ? null : `invalid --lines: ${lines}`;
}

/** 多个 validate* 依次判,返回第一个非空错误(样板收敛:一次guard替代逐条check+return) */
function firstValidationError(...errs: (string | null)[]): string | null {
  for (const e of errs) if (e) return e;
  return null;
}

/** session级自定义option,记录input pane真实pane_id,免疫用户手改pane title致title扫描失联 */
const SUPER_INPUT_PANE_OPT = "@super_input_pane";

function findSuperInputPane(sock: string, mainWin: string): string {
  // 优先信缓存的 pane_id(双保险第一层):title 可被用户手改,pane_id 不会变。
  // option 未设置或指向的 pane 已不存在(respawn/kill 后)一律静默回退 title 扫描,零风险。
  try {
    const cached = superTmux(sock, ["show-options", "-v", "-t", mainWin, SUPER_INPUT_PANE_OPT]).trim();
    if (cached) {
      const alivePanes = superTmux(sock, ["list-panes", "-t", mainWin, "-F", "#{pane_id}"]).trim().split("\n");
      if (alivePanes.includes(cached)) return cached;
    }
  } catch { /* 未设置/pane已消失 → 回退 title 扫描 */ }
  const raw = superTmux(sock, ["list-panes", "-t", mainWin, "-F", "#{pane_id} #{pane_title}"]).trim();
  for (const line of raw.split("\n").filter(Boolean)) {
    const sp = line.indexOf(" ");
    if (sp < 0) continue;
    const id = line.slice(0, sp);
    const title = line.slice(sp + 1);
    if (title === SUPER_INPUT_TITLE) return id;
  }
  return "";
}

/** bracketed-paste 载荷：内嵌 LF→CR；剥尾部 CR/LF 防 TUI 把 paste 尾当隐式 Enter（双发根因） */
function superTrimPastePayload(raw: string): string {
  return raw.replace(/\n/g, "\r").replace(/[\r\n]+$/, "");
}

function superCapturePane(sock: string, target: string, lines = 60): string {
  try {
    return superTmux(sock, ["capture-pane", "-p", "-t", target, "-S", `-${lines}`]);
  } catch {
    return "";
  }
}

function superPaneComm(sock: string, target: string): string {
  try {
    return superTmux(sock, ["list-panes", "-t", target, "-F", "#{pane_current_command}"]).trim().split("\n")[0] || "?";
  } catch {
    return "?";
  }
}

/** 上方 pane comm 常为 byobu；靠帧特征判 node TUI（composer 提示符 / cursor 帧） */
function superFrameLooksNodeTui(frame: string): boolean {
  if (looksLikeCursor(frame)) return true;
  const tail = frame.replace(/\s+$/g, "").split("\n").slice(-12);
  if (tail.some((l) => DRV_COMPOSER_PROMPT.test(l))) return true;
  return /Add a follow-up|Type your message/i.test(frame);
}

/**
 * 组装走 -L 独立socket 的 DrvIo 后端(P0-1 commit#2):capture/comm 直接复用既有
 * super原子操作;paste/enter 走 load-buffer/paste-buffer/send-keys 同款 super 原语。
 * 有了这层,原 superDrvAnalyze/superWaitRender/superVerifyNodeSubmit 三个重复实现
 * 全部改为直接调用 drvAnalyze/drvWaitRender/drvVerifyNodeSubmit(..., io) 复用,
 * SAMPLES/GAP_MS/NEED 采样常量与 kimi 特判也随之合一到 drvVerifyNodeSubmit 一处。
 */
function makeSuperIo(sock: string): DrvIo {
  return {
    capture: (target, lines = 60) => superCapturePane(sock, target, lines),
    comm: (target) => superPaneComm(sock, target),
    paste: (target, text) => {
      const buf = `byobu-super-${process.pid}-${Date.now()}`;
      superLoadPasteBuffer(sock, buf, text);
      superPasteBuffer(sock, buf, target);
    },
    enter: (target) => superSendEnter(sock, target),
  };
}

function superLoadPasteBuffer(sock: string, buf: string, text: string): void {
  const bin = superTmuxBin();
  const out = Bun.spawnSync([bin, ...superTmuxArgs(sock, ["load-buffer", "-b", buf, "-"])], {
    stdin: Buffer.from(text, "utf8"),
    stdout: "pipe",
    stderr: "pipe",
  });
  if (out.exitCode !== 0) {
    throw new Error(`super load-buffer: ${out.stderr.toString().trim()}`);
  }
}

function superPasteBuffer(sock: string, buf: string, target: string): void {
  superTmux(sock, ["paste-buffer", "-p", "-d", "-b", buf, "-t", target]);
}

function superSendEnter(sock: string, target: string): void {
  superTmux(sock, ["send-keys", "-t", target, "Enter"]);
}

/**
 * super 输入框 → 上方 pane 投递（load-buffer→paste-buffer -p→Enter）。
 * node TUI：paste 后不立刻 Enter（防 bracketed-paste 尾换行/慢渲染双发），等渲染后单次 Enter+验证。
 */
function superDeliverPayload(sock: string, target: string, raw: string): void {
  const text = superTrimPastePayload(raw);
  if (!text) return;
  const io = makeSuperIo(sock);
  const preFrame = superCapturePane(sock, target, 60);
  const comm = superPaneComm(sock, target);
  // isNodeTui 判据刻意保留 superFrameLooksNodeTui(比 drvLooksCursor 多 composer-prompt 尾行 +
  // "Add a follow-up"/"Type your message" 文案两条启发式),不与 driveSubmitVerify 的判据合并,
  // 避免静默改变 super 路径既有行为(P0-1 commit#2 范围收窄:只并采样/验证逻辑,不动判据)。
  const isNodeTui = DRV_NODE_TUI.test(comm) || superFrameLooksNodeTui(preFrame);

  io.paste(target, text);

  if (!isNodeTui) {
    io.enter(target);
    return;
  }

  const probe = text.trim().split(/\r|\n/)[0]!.slice(0, 24);
  const rendered = drvWaitRender(target, probe, 1800, io);
  const frame = superCapturePane(sock, target, 60);
  const preHadProbe = rendered || (!!probe && drvComposerHasProbe(frame, probe));
  io.enter(target);
  let why = drvVerifyNodeSubmit(target, probe, preHadProbe, comm, io);
  for (let i = 0; i < 3 && !why; i++) {
    Bun.sleepSync(800);
    io.enter(target);
    why = drvVerifyNodeSubmit(target, probe, preHadProbe, comm, io);
  }
}

/** super-input worker：zsh vared 多行编辑；无 zsh 时 bash read -e 单行降级 */
function runSuperInputLoop(target: string, sock: string, session: string): number {
  const zshBin = Bun.which("zsh") ?? "";
  const tmuxB = superTmuxBin();
  const hist = join(tmpdir(), `byobu-super-history-${process.env.USER ?? "user"}`);
  const muxScript = resolveSelfScript();
  const muxBun = Bun.which("bun") ?? "bun";
  const deliverCmd = `${shSingleQuote(muxBun)} ${shSingleQuote(muxScript)} super-deliver ${shSingleQuote(target)} ${shSingleQuote(sock)} -`;

  if (!zshBin) {
    const script = `set -euo pipefail
BS_TARGET=${JSON.stringify(target)}
BS_SOCK=${JSON.stringify(sock)}
BS_SESSION=${JSON.stringify(session)}
BS_HIST=${JSON.stringify(hist)}
BS_TMUX=${JSON.stringify(tmuxB)}
BS_DELIVER=${JSON.stringify(deliverCmd)}
T=("$BS_TMUX" -L "$BS_SOCK")
trap '"$BS_TMUX" -L "$BS_SOCK" kill-session -t "$BS_SESSION" 2>/dev/null; exit 0' INT
history -r "$BS_HIST" 2>/dev/null || true
while IFS= read -e -r -p "> " line; do
  [ -z "$line" ] && continue
  history -s -- "$line"; history -w "$BS_HIST" 2>/dev/null || true
  printf '%s' "$line" | eval "$BS_DELIVER"
done
"$BS_TMUX" -L "$BS_SOCK" kill-session -t "$BS_SESSION" 2>/dev/null
`;
    const r = Bun.spawnSync(["bash", "-c", script], { stdin: "inherit", stdout: "inherit", stderr: "inherit" });
    return r.exitCode ?? 0;
  }

  const zshScript = `
T=("$BS_TMUX_BIN" -L "$BS_SOCK")
HISTFILE="$BS_HIST"; HISTSIZE=1000; SAVEHIST=1000
fc -R "$BS_HIST" 2>/dev/null
byequit() { "\${T[@]}" kill-session -t "$BS_SESSION" 2>/dev/null; exit 0; }
trap byequit INT
bindkey -e
bindkey "^J" self-insert-unmeta
bindkey "^D" undefined-key
# 上下键翻历史：zsh -c 非交互态 ZLE 历史导航被禁，改用自维护数组 + 自定义 widget
_H=(); [[ -r "$BS_HIST" ]] && while IFS= read -r _l; do [[ -n "$_l" ]] && _H+="$_l"; done < "$BS_HIST"
_hidx=0
_hup(){ (( \${#_H} == 0 )) && return; (( _hidx < \${#_H} )) && (( _hidx++ )); BUFFER="\${_H[-_hidx]}"; CURSOR=\${#BUFFER}; }
_hdown(){ (( _hidx <= 1 )) && { _hidx=0; BUFFER=""; CURSOR=0; return }; (( _hidx-- )); BUFFER="\${_H[-_hidx]}"; CURSOR=\${#BUFFER}; }
zle -N _hup; zle -N _hdown
bindkey "^[[A" _hup; bindkey "^[OA" _hup
bindkey "^[[B" _hdown; bindkey "^[OB" _hdown
while :; do
  line=""; _hidx=0
  vared -p "> " line || continue
  [[ -z "$line" ]] && continue
  print -s -- "$line"; fc -W "$BS_HIST" 2>/dev/null
  _H+="$line"
  print -rn -- "$line" | eval "$BS_DELIVER"
done
`;
  const r = Bun.spawnSync([zshBin, "-f", "-c", zshScript], {
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
    env: {
      ...process.env,
      BS_TARGET: target,
      BS_SOCK: sock,
      BS_SESSION: session,
      BS_TMUX_BIN: tmuxB,
      BS_HIST: hist,
      BS_DELIVER: deliverCmd,
    },
  });
  return r.exitCode ?? 0;
}

/** super 焦点切换：相对 -U/-D（不绑 pane_id，抗 respawn 漂移）；先 unbind 再绑 */
function superBindPaneFocusKeys(sock: string): void {
  for (const key of ["C-Up", "C-Down", "M-Up", "M-Down"]) {
    superTmux(sock, ["unbind-key", "-n", key], { missingOk: true });
  }
  superTmux(sock, ["bind-key", "-n", "C-Up", "select-pane", "-U"]);
  superTmux(sock, ["bind-key", "-n", "C-Down", "select-pane", "-D"]);
  superTmux(sock, ["bind-key", "-n", "M-Up", "select-pane", "-U"]);
  superTmux(sock, ["bind-key", "-n", "M-Down", "select-pane", "-D"]);
}

/** 上方 pane 直接跑 byobu；显式剥 tmux 环境，避免 byobu 报 nested session。 */
function buildSuperByobuPaneCmd(): string {
  return "exec env -u TMUX -u TMUX_PANE -u TMUX_TMPDIR byobu";
}

function superExecAttach(sock: string, session: string): never {
  const bin = superTmuxBin();
  const env = { ...process.env } as Record<string, string | undefined>;
  delete env.TMUX;
  delete env.TMUX_PANE;
  delete env.TMUX_TMPDIR;
  execFileSync(bin, ["-L", sock, "attach", "-t", session], {
    stdio: "inherit",
    env: env as NodeJS.ProcessEnv,
  });
  process.exit(0);
}

function opSuperStart(opts: {
  session: string;
  sock: string;
  inputLines: number;
}): { session: string; sock: string; inputPane: string } {
  const { session, sock, inputLines } = opts;
  if (!Bun.which("byobu")) throw new Error("super 需要 byobu: apt/yum/brew install byobu");

  const mainWin = `${session}:main`;
  const mainPane = `${session}:main.0`;
  const self = resolveSelfScript();
  const inputCmd = buildSuperInputInvoke(self, mainPane, sock, session);

  if (!superTmuxHasSession(sock, session)) {
    superTmux(sock, ["new-session", "-d", "-s", session, "-n", "main", buildSuperByobuPaneCmd()], { newServer: true });
    Bun.sleepSync(400);
  } else {
    superTmux(sock, ["respawn-pane", "-k", "-t", mainPane, buildSuperByobuPaneCmd()]);
    Bun.sleepSync(400);
  }

  let inputPane = findSuperInputPane(sock, mainWin);
  if (!inputPane) {
    inputPane = superTmux(sock, [
      "split-window", "-P", "-F", "#{pane_id}", "-t", mainWin, "-v", "-l", String(inputLines), inputCmd,
    ]).trim();
  } else {
    superTmux(sock, ["respawn-pane", "-k", "-t", inputPane, inputCmd]);
    superTmux(sock, ["resize-pane", "-t", inputPane, "-y", String(inputLines)]);
  }

  superTmux(sock, ["select-pane", "-t", inputPane, "-T", SUPER_INPUT_TITLE]);
  // 双保险第二层:把真实 pane_id 记进 session option,供下次 findSuperInputPane 优先命中(title 免疫)
  superTmux(sock, ["set-option", "-t", mainWin, SUPER_INPUT_PANE_OPT, inputPane]);
  superTmux(sock, ["set-hook", "-g", "client-resized", `resize-pane -t ${inputPane} -y ${inputLines}`]);

  const sessOpts: [string, string][] = [
    ["prefix", "None"],
    ["status", "off"],
    ["pane-border-status", "off"],
    ["mouse", "on"],
    ["pane-border-style", "fg=colour238"],
    ["pane-active-border-style", "fg=colour46,bold"],
  ];
  for (const [opt, val] of sessOpts) {
    superTmux(sock, ["set-option", "-t", session, opt, val]);
  }

  superBindPaneFocusKeys(sock);
  // F 键转发到 byobu pane：显式 mainPane 目标（{up-of} 在焦点位于上方 pane 时无解析目标会报错）；
  // 先 unbind 清掉旧版/残留 run-shell 类绑定，保证重入幂等
  for (let i = 1; i <= 12; i++) {
    superTmux(sock, ["unbind-key", "-n", `F${i}`], { missingOk: true });
    superTmux(sock, ["bind-key", "-n", `F${i}`, "send-keys", "-t", mainPane, `F${i}`]);
  }

  superTmux(sock, ["select-pane", "-t", inputPane]);
  return { session, sock, inputPane };
}

/** 向 window 注入文本（默认带 Enter）；CLI send / 驾驶 i 共用。paste-buffer 发正文，Enter 单独 send-keys（同 smux） */
function injectToWindow(specOrTarget: string, text: string, opts?: { enter?: boolean }): void {
  const target = resolveInputPaneTarget(resolveTarget(specOrTarget));
  if (!text) throw new Error("消息为空");
  tmuxApi.loadBufferFromText(text);
  tmuxApi.pasteBuffer(target);
  if (opts?.enter !== false) tmuxApi.sendKeysEnter(target);
}

/** load-buffer + paste-buffer；CLI paste / 驾驶 P 共用 */
function pasteFileToWindow(specOrTarget: string, file: string): void {
  const target = resolveInputPaneTarget(resolveTarget(specOrTarget));
  const path = file.startsWith("~") ? join(homedir(), file.slice(1)) : file;
  if (!existsSync(path)) throw new Error(`文件不存在: ${file}`);
  tmuxApi.loadBuffer(target, path);
  tmuxApi.pasteBuffer(target);
}

// PART:agent-bus

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

function findNodeByAgent(name: string, source?: TreeNode[]): TreeNode | null {
  const wanted = normalizeAgentName(name);
  const tree = source ?? (state.tree.length > 0 ? state.tree : syncTree());
  for (const n of tree) {
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
  return stripAnsi(body).replace(/\s+/g, " ").trim().slice(0, MSG_SUMMARY_MAX);
}

function inboxLastSummary(agentId: string): string {
  const path = inboxPath(agentId);
  if (!existsSync(path)) return "";
  const raw = readFileSync(path, "utf8").trimEnd();
  if (!raw) return "";
  const last = raw.split("\n").pop()?.trim();
  if (!last) return "";
  try {
    const e = JSON.parse(last) as AgentEnvelope;
    return e.summary || summarizeMessage(e.body);
  } catch {
    return "";
  }
}

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

function agentLastInboxTs(agentId: string): number | null {
  const rows = parseInboxFile(inboxPath(agentId));
  if (rows.length === 0) return null;
  const ts = Date.parse(rows[rows.length - 1].ts);
  return Number.isNaN(ts) ? null : ts;
}

function listRegisteredAgents(source?: TreeNode[]): Array<{ id: string; target: string; unread: number }> {
  const out: Array<{ id: string; target: string; unread: number }> = [];
  const tree = source ?? syncTree();
  for (const n of tree) {
    if (n.type === "window" && n.agent) {
      out.push({
        id: n.agent,
        target: n.target,
        unread: n.cachedUnread ?? agentUnreadCount(n.agent),
      });
    }
  }
  return out;
}

// PART:hook-registry
//
// ===== hook 事件契约（event → handler JSON 契约，Phase 2a 锁定）=====
//
// registry event 串格式: `<kind>:<target...>`
//   - kind   : 固定枚举（首段，冒号前第一段），见 HOOK_EVENT_KINDS。
//   - target : 其余全部段（可再含冒号，如 `naos:lane-c`）。
//   - 拆分规则: 以「第一个冒号」切一刀 → 左=kind，右=target。
//     例: `window-pane-changed:naos:lane-c` → kind=`window-pane-changed`, target=`naos:lane-c`
//     无冒号(如 `agent-inbox-arrived` 直配 kind)时 target="".
//
// kind 枚举（HOOK_EVENT_KINDS）:
//   - window-pane-changed   : 某 window 当前 pane 内容/最后一行变化（lastLine 携带尾行）。
//   - agent-inbox-arrived   : 某 agent 收到新 inbox 消息（payload.unread 携带条数）。
//   - window-activity       : 某 window 出现活动（tmux activity flag）。
//   - cabin-state-changed   : 某 window 的「驾驶舱状态」(CabinState.kind) 发生迁移。
//         cabin = 每窗口状态机，枚举见 CABIN_TTL_MS：
//         error/agent/focus/running/waiting/stuck/idle（详见 PART:drive-bg detectCabinState）。
//         此事件在 St 列状态码切换时触发，payload 可带 {from,to} 状态码。
//   - agent-exit            : 进程/agent 进入终态（跑完/退出），显式触发「agent 跑完→PM 审计」，
//         替代用 window-pane-changed 当完成代理。payload 可带 {pid,code}。
//
// dispatcher 注入 handler 的 stdin JSON schema（dispatchHook 组装）:
//   {
//     "kind":     <string>,        // event 串首段
//     "target":   <string>,        // event 串拆 kind 后剩余段（可空串）
//     "lastLine"?:<string>,        // payload.lastLine 提升（便于 handler 直读）
//     "payload"?: <object>,        // 派发方传入的原始 payload（透传）
//     "ts":       <number>         // 派发时刻 Date.now()
//   }
// handler 须「一次性读 stdin」(IN=$(cat))，再 echo "$IN" | jq —— stdin 只能消费一次。
// =====================================================================

/** hook event kind 固定枚举（registry event 串首段）。 */
const HOOK_EVENT_KINDS = [
  "window-pane-changed",
  "agent-inbox-arrived",
  "window-activity",
  "cabin-state-changed",
  "agent-exit",
] as const;
type HookEventKind = (typeof HOOK_EVENT_KINDS)[number];

/** event 串 `<kind>:<target...>` → {kind,target}（以首个冒号切分）。 */
function parseHookEvent(event: string): { kind: string; target: string } {
  const i = event.indexOf(":");
  if (i < 0) return { kind: event, target: "" };
  return { kind: event.slice(0, i), target: event.slice(i + 1) };
}

interface HookEntry {
  event: string;
  handler: string;
  timestamp?: number;
}

const HOOKS_FILE = join(homedir(), ".tmuxloop", "hooks.jsonl");

function loadHooks(): HookEntry[] {
  if (!existsSync(HOOKS_FILE)) return [];
  const out: HookEntry[] = [];
  for (const line of readFileSync(HOOKS_FILE, "utf8").split("\n")) {
    const t = line.trim();
    if (!t) continue;
    try {
      out.push(JSON.parse(t) as HookEntry);
    } catch {
      /* skip bad lines */
    }
  }
  return out;
}

function saveHooks(entries: HookEntry[]): void {
  mkdirSync(dirname(HOOKS_FILE), { recursive: true });
  writeFileSync(HOOKS_FILE, entries.map(e => JSON.stringify(e)).join("\n") + "\n");
}

function hookOn(eventPattern: string, handlerScript: string): void {
  const handler = handlerScript.startsWith("~") ? join(homedir(), handlerScript.slice(1)) : handlerScript;
  if (!existsSync(handler)) throw new Error(`handler script not found: ${handler}`);
  const hooks = loadHooks();
  const dup = hooks.find(h => h.event === eventPattern && h.handler === handler);
  if (!dup) {
    hooks.push({ event: eventPattern, handler, timestamp: Date.now() });
    saveHooks(hooks);
  }
}

function hookOff(eventPattern: string, handlerScript?: string): void {
  const hooks = loadHooks();
  const filtered = handlerScript
    ? hooks.filter(h => !(h.event === eventPattern && h.handler === handlerScript))
    : hooks.filter(h => h.event !== eventPattern);
  saveHooks(filtered);
}

function listHooks(): HookEntry[] {
  return loadHooks();
}

type HookFireResult = { handler: string; rc: number; stdout: string; stderr: string };

/**
 * 派发一个 event：读 registry 找 event 完全匹配的 handler，按契约 schema 组装 stdin JSON
 * 后逐个执行。payload 为派发方原始对象（可含 lastLine/unread 等）。
 */
function dispatchHook(event: string, payload: Record<string, unknown>): HookFireResult[] {
  const { kind, target } = parseHookEvent(event);
  const stdinObj: Record<string, unknown> = {
    kind,
    target,
    ts: Date.now(),
  };
  if (typeof payload.lastLine === "string") stdinObj.lastLine = payload.lastLine;
  if (Object.keys(payload).length > 0) stdinObj.payload = payload;
  const stdinJson = JSON.stringify(stdinObj);

  const matched = loadHooks().filter(h => h.event === event);
  const results: HookFireResult[] = [];
  for (const h of matched) {
    const handler = h.handler.startsWith("~") ? join(homedir(), h.handler.slice(1)) : h.handler;
    const r = Bun.spawnSync(["bash", handler], {
      stdin: Buffer.from(stdinJson),
      stdout: "pipe",
      stderr: "pipe",
    });
    results.push({
      handler,
      rc: r.exitCode ?? -1,
      stdout: r.stdout?.toString() ?? "",
      stderr: r.stderr?.toString() ?? "",
    });
  }
  return results;
}

// PART:cli-fleet

type CliCtx = { bin: string; rest: string[]; json?: boolean };

interface CliFleetSession {
  type: "session";
  target: string;
  session: string;
  remark?: string;
  windowCount: number;
}

interface CliFleetWindow {
  type: "window";
  target: string;
  session: string;
  windowIndex: string;
  windowName: string;
  label: string;
  remark?: string;
  agent?: string;
  unread: number;
  inboxPath?: string;
  previewLastLine?: string;
  placeholders: { lvl: string; age: string; st: string; act: string };
  proc?: CliProcInfo;
}

interface CliProcInfo {
  pid: number;
  cmd: string;
  cpu: number;
  rssMB: number;
  shellPid?: number;
}

type CliFleetRow = CliFleetSession | CliFleetWindow;

interface CliFleetSnapshot {
  version: string;
  generatedAt: string;
  tree: CliFleetRow[];
  agents: Array<{ id: string; target: string; unread: number; inboxPath: string }>;
}

interface CliInspectResult {
  version: string;
  generatedAt: string;
  spec: string;
  type: "session" | "window";
  target: string;
  session: string;
  windowIndex?: string;
  windowName?: string;
  label?: string;
  remark?: string;
  agent?: string;
  unread?: number;
  inboxPath?: string;
  windowCount?: number;
  preview?: { lines: number; text: string; lastLine: string };
  placeholders: { lvl: string; age: string; st: string; act: string };
  proc?: CliProcInfo;
}

function peelJsonFlag(rest: string[]): { rest: string[]; json: boolean } {
  let json = false;
  const out: string[] = [];
  for (const a of rest) {
    if (a === "--json" || a === "-j") json = true;
    else out.push(a);
  }
  return { rest: out, json };
}

function cliWriteJson(data: unknown): void {
  cliWriteStdout(JSON.stringify(data, null, 2) + "\n");
}

function sessionWindowCount(tree: TreeNode[], sessIdxOrName: number | string): number {
  if (typeof sessIdxOrName === "number") {
    let wc = 0;
    for (let j = sessIdxOrName + 1; j < tree.length && tree[j].type === "window"; j++) wc++;
    return wc;
  }
  let wc = 0;
  for (const n of tree) {
    if (n.type === "window" && n.sessionName === sessIdxOrName) wc++;
  }
  return wc;
}

type WindowFleetDetail = {
  winIdx: string;
  winTarget: string;
  cap: PaneSnapResult;
  meta: WindowMeta;
  proc: ProcInfo | null;
};

/** status / inspect / 驾驶 meta 同源：一次 paneSnap + windowMeta + proc */
function windowFleetDetail(n: TreeNode, previewLines: number): WindowFleetDetail {
  const winIdx = n.target.split(":")[1] ?? "";
  const winTarget = buildWinIndexTarget(n.sessionName, winIdx);
  const cap = paneSnap(winTarget, { sync: true, lines: previewLines });
  const meta = windowMeta(n, undefined, { sync: true, cap });
  return { winIdx, winTarget, cap, meta, proc: readDriveProc(winTarget) };
}

function windowNameFromNode(node: TreeNode): string {
  return node.label.replace(/^[├└]\s*/, "").trim();
}

function winTargetFromNode(node: TreeNode): string {
  const winIdx = node.target.split(":")[1] ?? "";
  return buildWinIndexTarget(node.sessionName, winIdx);
}

const DRIVE_PH = "—";
const DRIVE_CAPTURE_TAIL_LINES = 12;
const DRIVE_ALERT_RE = /\b(error|fail|panic|exception|fatal)\b/i;
const DRIVE_ALERT_NEG_RE = /\b(0 errors?|no errors?|without errors?)\b/i;
/** 末行 shell/agent 等待输入 */
const CABIN_PROMPT_RE = /(?:[#\$>%]|❯|➜|>>>|\?\s*|\:\s*)\s*$/;
const CABIN_STUCK_MS = 180_000;
const CABIN_CPU_RUN = 2;
const CABIN_CPU_IDLE = 0.8;

/** 驾驶表单窗口状态机：St 列单字 code + 该状态下缓存快照的 TTL,一处维护免两表漂移 */
const CABIN_STATE: Record<string, { code: string; ttlMs: number }> = {
  error: { code: "E", ttlMs: 1000 },
  agent: { code: "A", ttlMs: 1500 },
  focus: { code: "F", ttlMs: 2000 },
  running: { code: "R", ttlMs: 1500 },
  waiting: { code: "W", ttlMs: 2500 },
  stuck: { code: "S", ttlMs: 6000 },
  idle: { code: "\u00b7", ttlMs: 8000 },
};

type CabinStateKind = keyof typeof CABIN_STATE;

type CabinSnapCtx = {
  lastLine: string;
  alert: boolean;
  lineStillSince?: number;
};

type CabinState = {
  kind: CabinStateKind;
  /** 驾驶表 St 列单字 */
  code: string;
  snapTtlMs: number;
};

function cabinState(kind: CabinStateKind): CabinState {
  const s = CABIN_STATE[kind];
  return { kind, code: s.code, snapTtlMs: s.ttlMs };
}

function detectCabinState(node: TreeNode, snap: CabinSnapCtx, proc: ProcInfo | null): CabinState {
  const unread = node.agent ? (node.cachedUnread ?? 0) : 0;
  if (snap.alert) return cabinState("error");
  if (unread > 0) return cabinState("agent");
  if (node.windowActive) return cabinState("focus");

  const line = stripAnsi(snap.lastLine).trim();
  const cpu = proc?.cpu ?? 0;
  if (line && CABIN_PROMPT_RE.test(line) && cpu < CABIN_CPU_IDLE) {
    return cabinState("waiting");
  }
  if (cpu >= CABIN_CPU_RUN) {
    return cabinState("running");
  }
  if (snap.lineStillSince !== undefined && Date.now() - snap.lineStillSince >= CABIN_STUCK_MS) {
    const ageSec = windowAgeSec(node);
    if (ageSec >= 120 && cpu < CABIN_CPU_IDLE) {
      return cabinState("stuck");
    }
  }
  if (line && snap.lineStillSince !== undefined && Date.now() - snap.lineStillSince < 8000 && cpu > 0.2) {
    return cabinState("running");
  }
  return cabinState("idle");
}

function driveSnapTtlForTarget(target: string, nodeByTarget: Map<string, TreeNode>, now = Date.now()): number {
  const snap = driveSnap.get(target);
  const node = nodeByTarget.get(target);
  if (!snap || !node) return DRIVE_SNAP_TTL_MS;
  const proc = driveProc.get(target) ?? null;
  return detectCabinState(node, snap, proc).snapTtlMs;
}

function driveAlertFromLine(line: string): boolean {
  const s = stripAnsi(line);
  if (!s || DRIVE_ALERT_NEG_RE.test(s)) return false;
  return DRIVE_ALERT_RE.test(s);
}

function captureLines(text: string): string[] {
  return text.split("\n").map((s) => stripAnsi(s).trim()).filter(Boolean);
}

function driveAlertFromTailDiff(prevTail: string, newTail: string): boolean {
  const prev = captureLines(prevTail);
  const cur = captureLines(newTail);
  if (cur.length === 0) return false;
  if (prev.length === 0) return driveAlertFromLine(cur[cur.length - 1]);
  for (let overlap = Math.min(prev.length, cur.length); overlap >= 0; overlap--) {
    const prevSuffix = prev.slice(-overlap);
    const curPrefix = cur.slice(0, overlap);
    if (overlap === 0 || prevSuffix.every((l, i) => l === curPrefix[i])) {
      return cur.slice(overlap).some(driveAlertFromLine);
    }
  }
  return driveAlertFromLine(cur[cur.length - 1]);
}

function lastLineFromCaptureText(text: string): string {
  return text.split("\n").map((s) => stripAnsi(s).trim()).filter(Boolean).pop() || "";
}

type PaneSnapResult = { lastLine: string; alert: boolean; text: string };
let paneSnapBatch: Map<string, PaneSnapResult> | null = null;

function beginPaneSnapBatch(): void { paneSnapBatch = new Map(); }
function endPaneSnapBatch(): void { paneSnapBatch = null; }

/** live：drive 内存 snap；sync / batch：tmux capture（CLI、f 刷新） */
function paneSnap(target: string, opts?: { lines?: number; sync?: boolean }): PaneSnapResult {
  const lines = opts?.lines ?? 1;
  if (opts?.sync || paneSnapBatch !== null) {
    const hit = paneSnapBatch?.get(target);
    if (hit) return hit;
    const text = tmuxApi.capturePaneText(target, lines);
    const lastLine = lastLineFromCaptureText(text);
    const entry = { lastLine, alert: driveAlertFromLine(lastLine), text };
    paneSnapBatch?.set(target, entry);
    return entry;
  }
  const live = driveSnap.get(target);
  return live
    ? { lastLine: live.lastLine, alert: live.alert, text: "" }
    : { lastLine: "", alert: false, text: "" };
}

// PART:drive-bg

type WindowMeta = {
  unread: number; alert: boolean; lastLine: string; task: string;
  lvl: AutoLevel; age: string; ageSec: number; act: string;
  cabin: CabinState;
};

type WinSnap = {
  lastLine: string;
  tail: string;
  alert: boolean;
  ts: number;
  lineStillSince: number;
};
type ProcInfo = { pid: number; cmd: string; cpu: number; rssMB: number; shellPid: number; ts: number };

const driveSnap = new Map<string, WinSnap>();
const driveProc = new Map<string, ProcInfo>();
const drivePrevLineHash = new Map<string, string>();
const lastCabinKind = new Map<string, string>();
/** 去抖：target → 待确认的 cabin 状态（同 kind 连续 snaps 计数） */
const cabinPendingSince = new Map<string, { kind: CabinStateKind; since: number; snaps: number }>();
const AGENT_EVENTS_FILE = join(homedir(), ".tmuxloop", "agent-events.jsonl");

let driveSnapTimer: ReturnType<typeof setInterval> | null = null;
let driveProcTimer: ReturnType<typeof setInterval> | null = null;
let driveSnapRefreshing = false;
let driveProcRefreshing = false;
let driveRenderTimer: ReturnType<typeof setTimeout> | null = null;
let driveMetaCache: Map<number, WindowMeta> | null = null;
let driveNavQuietUntil = 0;
let driveViewDirty = false;
let driveNavFlushTimer: ReturnType<typeof setTimeout> | null = null;

function driveNavQuiet(): boolean {
  return Date.now() < driveNavQuietUntil;
}

/** ↑↓ 时标记：暂停后台刷新，preview 走 PREVIEW_DELAY debounce */
function markDriveNav(): void {
  driveNavQuietUntil = Date.now() + DRIVE_NAV_QUIET_MS;
  if (driveNavFlushTimer) clearTimeout(driveNavFlushTimer);
  driveNavFlushTimer = setTimeout(() => {
    driveNavFlushTimer = null;
    if (driveViewDirty) {
      driveViewDirty = false;
      state.driveViewIndices = null;
      if (state.uiMode === "drive") scheduleDriveRender();
    }
  }, DRIVE_NAV_QUIET_MS + DRIVE_NAV_FLUSH_SLACK_MS);
}

function beginDriveMetaCache(): void {
  driveMetaCache = new Map();
}

function endDriveMetaCache(): void {
  driveMetaCache = null;
}

function withDriveMetaCache(fn: () => void): void {
  beginDriveMetaCache();
  try { fn(); } finally { endDriveMetaCache(); }
}

/** 后台 snap/proc 更新：只重绘表区，不碰 preview */
function scheduleDriveRender(): void {
  if (driveNavQuiet()) return;
  if (driveRenderTimer) return;
  driveRenderTimer = setTimeout(() => {
    driveRenderTimer = null;
    if (driveNavQuiet()) return;
    const [cols, rows] = screen.getSize();
    const layout = getLayout(cols, rows);
    if (layout.mode === "drive") {
      withDriveMetaCache(() => renderDriveRows(cols, layout));
    } else if (layout.mode === "smart") {
      // 智能模式背景刷新：完整重绘
      render();
    }
  }, DRIVE_RENDER_DEBOUNCE_MS);
}

async function mapPoolLimit<T>(items: T[], limit: number, fn: (item: T) => Promise<void>): Promise<void> {
  const queue = [...items];
  const n = Math.max(1, Math.min(limit, queue.length));
  await Promise.all(Array.from({ length: n }, async () => {
    while (queue.length) {
      const item = queue.shift()!;
      await fn(item);
    }
  }));
}

async function capturePaneTailAsync(target: string): Promise<string> {
  try {
    const proc = Bun.spawn(
      [tmuxBin(), "capture-pane", "-p", "-t", target, "-S", `-${DRIVE_CAPTURE_TAIL_LINES}`, "-E", "-"],
      { stdout: "pipe", stderr: "pipe" },
    );
    const text = await new Response(proc.stdout).text();
    await proc.exited;
    if (proc.exitCode !== 0) return driveSnap.get(target)?.tail ?? "";
    return text;
  } catch {
    return driveSnap.get(target)?.tail ?? "";
  }
}

async function refreshDriveSnapshots(force = false): Promise<void> {
  if (driveSnapRefreshing) return;
  if (!force && driveNavQuiet()) return;
  driveSnapRefreshing = true;
  try {
    const now = Date.now();
    const nodeByTarget = new Map<string, TreeNode>();
    const targets = state.tree
      .filter((n) => {
        if (n.type !== "window") return false;
        nodeByTarget.set(winTargetFromNode(n), n);
        return true;
      })
      .map((n) => winTargetFromNode(n));
    const stale = force
      ? targets
      : targets.filter((t) => now - (driveSnap.get(t)?.ts ?? 0) > driveSnapTtlForTarget(t, nodeByTarget, now));
    if (stale.length === 0) return;

    let sortDirty = false;
    await mapPoolLimit(stale, DRIVE_SNAP_CONCURRENCY, async (target) => {
      const prevEntry = driveSnap.get(target);
      const prevLine = prevEntry?.lastLine ?? "";
      const prevAlert = prevEntry?.alert ?? false;
      const prevTail = prevEntry?.tail ?? "";
      const newTail = await capturePaneTailAsync(target);
      const lastLine = lastLineFromCaptureText(newTail);
      const alert = prevTail
        ? driveAlertFromTailDiff(prevTail, newTail)
        : driveAlertFromLine(lastLine);
      if (lastLine !== prevLine) drivePrevLineHash.set(target, prevLine);
      const lineStillSince = lastLine !== prevLine ? now : (prevEntry?.lineStillSince ?? now);
      const prevCabin = prevEntry && nodeByTarget.has(target)
        ? detectCabinState(nodeByTarget.get(target)!, prevEntry, driveProc.get(target) ?? null).kind
        : null;
      if (alert !== prevAlert) sortDirty = true;
      driveSnap.set(target, { lastLine, tail: newTail, alert, ts: now, lineStillSince });
      const node = nodeByTarget.get(target);
      if (node) {
        const cabin = detectCabinState(node, driveSnap.get(target)!, driveProc.get(target) ?? null);
        if (cabin.kind !== prevCabin) {
          sortDirty = true;
          // 去抖：error 需连续 2 次 snap 确认，其他 kind 即时（≥1 已足）。
          const needSnaps = cabin.kind === "error" ? 2 : 1;
          const pend = cabinPendingSince.get(target);
          const snaps = pend && pend.kind === cabin.kind ? pend.snaps + 1 : 1;
          if (snaps >= needSnaps) {
            const emitted = lastCabinKind.get(target) ?? prevCabin ?? "unknown";
            if (emitted !== cabin.kind) {
              const sess = node.sessionName;
              const project = sess.startsWith("tmux-") ? sess.slice(5) : sess;
              const role = windowNameFromNode(node) || node.agent || target;
              emitCabinStateChanged(target, emitted, cabin.kind, project, role);
            }
            lastCabinKind.set(target, cabin.kind);
            cabinPendingSince.delete(target);
          } else {
            // 未达确认阈值：记/累计 pending，不更新 lastCabinKind
            cabinPendingSince.set(target, { kind: cabin.kind, since: pend && pend.kind === cabin.kind ? pend.since : now, snaps });
          }
        } else {
          // 稳定回到已确认状态：清 pending
          if (cabinPendingSince.has(target)) cabinPendingSince.delete(target);
          lastCabinKind.set(target, cabin.kind);
        }
      }
    });

    if (sortDirty) invalidateDriveView();
    else if (driveNavQuiet()) driveViewDirty = true;
    scheduleDriveRender();
  } finally {
    driveSnapRefreshing = false;
  }
}

type PsRow = { pid: number; ppid: number; pcpu: number; rss: number; comm: string };

function parsePsDump(raw: string): PsRow[] {
  const out: PsRow[] = [];
  for (const line of raw.split("\n")) {
    const t = line.trim();
    if (!t) continue;
    const m = t.match(/^(\d+)\s+(\d+)\s+([\d.]+)\s+(\d+)\s+(\S+)/);
    if (!m) continue;
    out.push({
      pid: parseInt(m[1], 10),
      ppid: parseInt(m[2], 10),
      pcpu: parseFloat(m[3]),
      rss: parseInt(m[4], 10),
      comm: m[5],
    });
  }
  return out;
}

function findMainProcess(shellPid: number, rows: PsRow[]): { pid: number; cmd: string; cpu: number; rssMB: number } {
  const byPpid = new Map<number, PsRow[]>();
  const byPid = new Map<number, PsRow>();
  for (const r of rows) {
    byPid.set(r.pid, r);
    if (!byPpid.has(r.ppid)) byPpid.set(r.ppid, []);
    byPpid.get(r.ppid)!.push(r);
  }
  const queue = [...(byPpid.get(shellPid) ?? [])];
  const visited = new Set<number>();
  let best: PsRow | null = null;
  while (queue.length) {
    const cur = queue.shift()!;
    if (visited.has(cur.pid)) continue;
    visited.add(cur.pid);
    if (!SHELL_COMMS.has(cur.comm)) {
      if (!best || cur.pcpu > best.pcpu || (cur.pcpu === best.pcpu && cur.rss > best.rss)) best = cur;
    }
    for (const child of byPpid.get(cur.pid) ?? []) queue.push(child);
  }
  const pick = best ?? byPid.get(shellPid);
  if (!pick) return { pid: shellPid, cmd: "?", cpu: 0, rssMB: 0 };
  return { pid: pick.pid, cmd: pick.comm, cpu: pick.pcpu, rssMB: Math.round(pick.rss / 1024) };
}

function emitCabinStateChanged(
  target: string,
  prev: string,
  next: CabinStateKind,
  project: string,
  role: string,
): void {
  const payload = JSON.stringify({
    kind: "cabin-state-changed",
    target,
    project,
    role,
    cabin_state_prev: prev,
    cabin_state_next: next,
    ts: Date.now(),
  });
  try {
    mkdirSync(dirname(AGENT_EVENTS_FILE), { recursive: true });
    appendFileSync(AGENT_EVENTS_FILE, payload + "\n");
  } catch { /* best-effort */ }
}

function emitAgentExit(target: string, prevPid: number, project: string, role: string): void {
  const cabinPrev = lastCabinKind.get(target) ?? "unknown";
  const payload = JSON.stringify({
    kind: "agent-exit",
    target,
    pid: prevPid,
    project,
    role,
    cabin_state_prev: cabinPrev,
    cabin_state_final: "idle",
    ts: Date.now(),
  });
  try {
    mkdirSync(dirname(AGENT_EVENTS_FILE), { recursive: true });
    appendFileSync(AGENT_EVENTS_FILE, payload + "\n");
  } catch { /* best-effort */ }
}

function applyPaneProcMap(paneRaw: string, psRows: PsRow[]): void {
  for (const line of paneRaw.split("\n").filter(Boolean)) {
    const [loc, active, pidStr] = line.split("|");
    if (active !== "1") continue;
    const parts = (loc ?? "").split(":");
    const sess = parts[0] ?? "";
    const winIdx = parts[1] ?? "";
    const winName = parts[2] ?? winIdx;
    const shellPid = parseInt(pidStr ?? "", 10);
    if (!sess || !winIdx || !shellPid) continue;
    const target = buildWinIndexTarget(sess, winIdx);
    const prev = driveProc.get(target);
    const main = findMainProcess(shellPid, psRows);

    // agent-exit: prev was agent process, now degraded to shell
    if (prev && AGENT_COMMS.has(prev.cmd) && SHELL_COMMS.has(main.cmd)) {
      // second confirmation via /proc/<pid>/comm (Linux only, no-op elsewhere)
      let confirmed = false;
      try {
        const comm = readFileSync(`/proc/${prev.pid}/comm`, "utf8").trim();
        confirmed = !AGENT_COMMS.has(comm);
      } catch {
        confirmed = true; // ENOENT → process dead
      }
      if (confirmed) {
        const project = sess.startsWith("tmux-") ? sess.slice(5) : sess;
        const role = winName;
        emitAgentExit(target, prev.pid, project, role);
      }
    }

    driveProc.set(target, { ...main, shellPid, ts: Date.now() });
  }
}

function updateDriveProcMapSync(): void {
  const paneRaw = tmux([
    "list-panes", "-a",
    "-F", "#{session_name}:#{window_index}:#{window_name}|#{pane_active}|#{pane_pid}",
  ]).trim();
  const psRaw = Bun.spawnSync(["ps", "-A", "-o", "pid=,ppid=,pcpu=,rss=,comm="], { stdout: "pipe" }).stdout?.toString() ?? "";
  applyPaneProcMap(paneRaw, parsePsDump(psRaw));
}

async function updateDriveProcMap(): Promise<void> {
  if (driveNavQuiet()) return;
  const paneRaw = tmux([
    "list-panes", "-a",
    "-F", "#{session_name}:#{window_index}:#{window_name}|#{pane_active}|#{pane_pid}",
  ]).trim();
  const proc = Bun.spawn(["ps", "-A", "-o", "pid=,ppid=,pcpu=,rss=,comm="], { stdout: "pipe", stderr: "pipe" });
  const psRaw = await new Response(proc.stdout).text();
  await proc.exited;
  if (driveNavQuiet()) return;
  applyPaneProcMap(paneRaw, parsePsDump(psRaw));
}

async function refreshDriveProc(force = false): Promise<void> {
  if (driveProcRefreshing) return;
  if (!force && driveNavQuiet()) return;
  const now = Date.now();
  if (!force && driveProc.size > 0) {
    const anyStale = [...driveProc.values()].some((p) => now - p.ts > DRIVE_PROC_TTL_MS);
    if (!anyStale) return;
  }
  driveProcRefreshing = true;
  try {
    await updateDriveProcMap();
    scheduleDriveRender();
  } finally {
    driveProcRefreshing = false;
  }
}

function readDriveProc(target: string): ProcInfo | null {
  return driveProc.get(target) ?? null;
}

/** 表列：主进程短名 + PID */
function procBasename(cmd: string): string {
  const s = cmd.trim();
  if (!s) return "?";
  const leaf = s.includes("/") ? s.split("/").pop()! : s;
  return (leaf.split(/\s+/)[0] ?? leaf).slice(0, 12);
}

function formatProcCells(proc: ProcInfo | null): { pname: string; pid: string } {
  if (!proc) return { pname: DRIVE_PH, pid: DRIVE_PH };
  return { pname: procBasename(proc.cmd), pid: String(proc.pid) };
}

function startDriveLoops(): void {
  stopDriveLoops();
  // 不在进入驾驶时全量 snap/proc（会与 ↑↓ 抢 tmux）；靠 f 刷新 + 空闲定时
  driveSnapTimer = setInterval(() => {
    if (driveNavQuiet()) return;
    void refreshDriveSnapshots(false);
  }, DRIVE_SNAP_TTL_MS);
  driveProcTimer = setInterval(() => {
    if (driveNavQuiet()) return;
    void refreshDriveProc(false);
  }, DRIVE_PROC_TTL_MS);
}

function stopDriveLoops(): void {
  if (driveSnapTimer) clearInterval(driveSnapTimer);
  if (driveProcTimer) clearInterval(driveProcTimer);
  if (driveRenderTimer) clearTimeout(driveRenderTimer);
  if (driveNavFlushTimer) clearTimeout(driveNavFlushTimer);
  driveSnapTimer = null;
  driveProcTimer = null;
  driveRenderTimer = null;
  driveNavFlushTimer = null;
}

function windowAgeEpochSec(node: TreeNode): number {
  let epochSec = node.windowActivity ?? 0;
  if (node.agent) {
    const inboxTs = agentLastInboxTs(node.agent);
    if (inboxTs !== null) epochSec = Math.max(epochSec, Math.floor(inboxTs / 1000));
  }
  return epochSec;
}

function windowAgeSec(node: TreeNode): number {
  const epochSec = windowAgeEpochSec(node);
  if (!epochSec) return 0;
  return Math.max(0, Math.floor(Date.now() / 1000 - epochSec));
}

function formatRelativeAge(epochSec: number): string {
  const sec = Math.max(0, Math.floor(Date.now() / 1000 - epochSec));
  if (sec < 60) return "now";
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h`;
  return `${Math.floor(hr / 24)}d`;
}

function driveTaskLabel(node: TreeNode, lastLine: string): string {
  if (state.osMode && node.type === "window") {
    const osLabel = taskLabelForTarget(node.target);
    if (osLabel) return osLabel;
  }
  if (node.remark) return node.remark;
  if (node.agent) {
    const summary = inboxLastSummary(node.agent);
    if (summary) return summary;
  }
  if (lastLine) return lastLine;
  return windowNameFromNode(node);
}

function driveRowScore(m: WindowMeta): number {
  let score = 0;
  if (m.unread > 0) score += m.unread * 5;
  if (m.alert) score += 20;
  if (m.ageSec > 600) score += 8;
  score += (parseInt(m.lvl, 10) || 0) / 10;
  switch (m.cabin.kind) {
    case "error": score += 25; break;
    case "agent": score += 15; break;
    case "waiting": score += 10; break;
    case "running": score += 6; break;
    case "stuck": score += 12; break;
    case "focus": score += 4; break;
    default: break;
  }
  return score;
}

function deriveActChar(node: TreeNode, lastLine: string): string {
  if (node.windowActive) return "●";
  const target = winTargetFromNode(node);
  const prev = drivePrevLineHash.get(target);
  if (prev !== undefined && prev !== lastLine && lastLine) return "…";
  return "○";
}

function windowMeta(
  node: TreeNode,
  treeIdx?: number,
  opts?: { sync?: boolean; cap?: PaneSnapResult },
): WindowMeta {
  if (treeIdx !== undefined && driveMetaCache?.has(treeIdx)) return driveMetaCache.get(treeIdx)!;
  const target = winTargetFromNode(node);
  const inDrive = !opts?.sync;
  const unread = inDrive
    ? (node.cachedUnread ?? 0)
    : (node.cachedUnread ?? (node.agent ? agentUnreadCount(node.agent) : 0));
  const cap = opts?.cap ?? paneSnap(target, inDrive ? undefined : { sync: opts?.sync ?? true, lines: 1 });
  const lvl = inDrive ? (node.autoLevel ?? "0") : (node.autoLevel ?? readAuto(node));
  const ageSec = windowAgeSec(node);
  const liveSnap = driveSnap.get(target);
  const proc = readDriveProc(target);
  const cabinCtx: CabinSnapCtx = liveSnap ?? {
    lastLine: cap.lastLine,
    alert: cap.alert,
    lineStillSince: Date.now(),
  };
  const cabin = detectCabinState(node, cabinCtx, proc);
  const meta: WindowMeta = {
    unread,
    alert: cap.alert,
    lastLine: cap.lastLine,
    task: driveTaskLabel(node, cap.lastLine),
    lvl,
    age: ageSec ? formatRelativeAge(windowAgeEpochSec(node)) : DRIVE_PH,
    ageSec,
    act: deriveActChar(node, cap.lastLine),
    cabin,
  };
  if (treeIdx !== undefined) driveMetaCache?.set(treeIdx, meta);
  return meta;
}

function procToCli(proc: ProcInfo | null): CliProcInfo | undefined {
  return proc
    ? { pid: proc.pid, cmd: proc.cmd, cpu: proc.cpu, rssMB: proc.rssMB, shellPid: proc.shellPid }
    : undefined;
}

function fleetWindowRow(n: TreeNode, previewLines: number): CliFleetRow {
  const d = windowFleetDetail(n, previewLines);
  const ag = n.agent;
  return {
    type: "window",
    target: n.target,
    session: n.sessionName,
    windowIndex: d.winIdx,
    windowName: windowNameFromNode(n),
    label: n.label,
    remark: n.remark || undefined,
    agent: ag || undefined,
    unread: d.meta.unread,
    inboxPath: ag ? inboxPath(ag) : undefined,
    previewLastLine: d.cap.lastLine || undefined,
    placeholders: { lvl: d.meta.lvl, age: d.meta.age, st: d.meta.cabin.code, act: d.meta.act },
    proc: procToCli(d.proc),
  };
}

function buildFleetSnapshot(previewLines = 1, sourceTree?: TreeNode[]): CliFleetSnapshot {
  beginPaneSnapBatch();
  try {
    updateDriveProcMapSync();
  } catch {
    /* tmux/ps 不可用时跳过 proc */
  }
  const tree = sourceTree ?? syncTree();
  const rows: CliFleetRow[] = [];
  for (let i = 0; i < tree.length; i++) {
    const n = tree[i];
    if (n.type === "session") {
      rows.push({
        type: "session",
        target: n.target,
        session: n.sessionName,
        remark: n.remark || undefined,
        windowCount: sessionWindowCount(tree, i),
      });
      continue;
    }
    rows.push(fleetWindowRow(n, previewLines));
  }
  const agents = listRegisteredAgents(tree).map((a) => ({
    id: a.id,
    target: a.target,
    unread: a.unread,
    inboxPath: inboxPath(a.id),
  }));
  endPaneSnapBatch();
  return {
    version: TUI_CONFIG.VERSION,
    generatedAt: new Date().toISOString(),
    tree: rows,
    agents,
  };
}

function buildInspectResult(spec: string, previewLines: number, sourceTree?: TreeNode[]): CliInspectResult {
  const { target, node } = parseTargetSpec(spec);
  const base: CliInspectResult = {
    version: TUI_CONFIG.VERSION,
    generatedAt: new Date().toISOString(),
    spec,
    type: node.type,
    target,
    session: node.sessionName,
    remark: node.remark || undefined,
    placeholders: { lvl: "0", age: "—", st: "—", act: "—" },
  };
  if (node.type === "session") {
    const tree = sourceTree ?? syncTree();
    return { ...base, windowCount: sessionWindowCount(tree, node.sessionName) };
  }
  beginPaneSnapBatch();
  const tree = sourceTree ?? syncTree();
  const full = tree.find((n) => n.type === "window" && n.target === node.target) ?? node;
  const d = windowFleetDetail(full, previewLines);
  endPaneSnapBatch();
  const ag = full.agent;
  return {
    ...base,
    windowIndex: d.winIdx,
    windowName: windowNameFromNode(full),
    label: full.label,
    agent: ag || undefined,
    unread: d.meta.unread,
    inboxPath: ag ? inboxPath(ag) : undefined,
    preview: { lines: previewLines, text: d.cap.text, lastLine: d.cap.lastLine },
    placeholders: { lvl: d.meta.lvl, age: d.meta.age, st: d.meta.cabin.code, act: d.meta.act },
    proc: procToCli(d.proc),
  };
}

// PART:tree-sync

const TREE_SESS_FMT = "#{session_name}|#{@remark}";
const TREE_WIN_FMT = "#{window_index}|#{window_name}|#{window_active}|#{window_activity}|#{@auto}|#{@remark}|#{@agent}";

function parseWinSyncFields(raw: string): {
  idx: string; name: string; active: boolean; activity?: number; auto: AutoLevel; remark: string; agent: string;
} {
  const [idx, name, active, activity, autoRaw, remark, agent] = raw.split("|");
  return {
    idx: idx ?? "",
    name: name ?? "",
    active: active === "1",
    activity: activity ? parseInt(activity, 10) || undefined : undefined,
    auto: normalizeAutoLevel(autoRaw ?? "0"),
    remark: (remark ?? "").trim(),
    agent: (agent ?? "").trim(),
  };
}

function syncTree(): TreeNode[] {
  const nodes: TreeNode[] = [];
  for (const row of tmuxApi.listSessions(TREE_SESS_FMT)) {
    const [sess, sessRemark = ""] = row.split("|");
    // 内部沉浸式 viewer session：上次进程被强杀时可能残留，永不在索引区显示
    if (sess === TUI_CONFIG.VIEWER_SESSION) continue;
    nodes.push({
      label: `# ${sess}`,
      target: sess,
      indent: 0,
      type: "session",
      sessionName: sess,
      remark: sessRemark.trim() || undefined,
    });
    const wins = tmuxApi.listWindows(sess, TREE_WIN_FMT);
    for (let i = 0; i < wins.length; i++) {
      const w = parseWinSyncFields(wins[i]);
      const branch = i === wins.length - 1 ? "└" : "├";
      nodes.push({
        label: `${branch} ${w.name}`,
        target: `${sess}:${w.idx}`,
        indent: 1,
        type: "window",
        sessionName: sess,
        windowActive: w.active,
        windowActivity: w.activity,
        autoLevel: w.auto,
        remark: w.remark || undefined,
        agent: w.agent || undefined,
        cachedUnread: w.agent ? agentUnreadCount(w.agent) : 0,
      });
    }
  }
  return nodes;
}

function hydrateDriveSortScores(tree: TreeNode[]): void {
  withDriveMetaCache(() => {
    for (let i = 0; i < tree.length; i++) {
      const n = tree[i];
      if (n.type === "window") {
        n.driveSortScore = driveRowScore(windowMeta(n, i));
      }
    }
  });
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

// PART:state

interface InputMode {
  prompt: string;
  value: string;
  callback: (v: string | null) => void;
}

// 布局常量：header 1 行（row 1），body 从 row 2 起，footer 1 行（row = rows）
const HEADER_H = 1;
const FOOTER_H = 1;
const BODY_START_ROW = HEADER_H + 1; // 2
type UiMode = "index" | "smart";

type LayoutInfo =
  | { mode: "index"; bodyH: number; leftW: number; rightW: number }
  | { mode: "smart"; bodyH: number; leftW: number; rightW: number; chatW: number; treeHeaderH: number; treeDataH: number; operW: number; paneH: number };

class TuiState {
  tree: TreeNode[] = [];
  cursor = 0;
  viewOffset = 0;
  /** 索引（左右）| 驾驶（上下 tree-table）| 智能（树+oper双行+chatroom） */
  uiMode: UiMode = "smart";
  preview = "";
  previewTimer: ReturnType<typeof setTimeout> | null = null;
  previewFetchId = 0;
  previewDoneId = 0;
  previewTarget = "";
  inputMode: InputMode | null = null;
  scrollOffset = 0;
  seenMax = 0;
  /** 从沉浸式返回后：右侧 preview 不自动 capture（避免把刚看过的输出再刷一遍） */
  suppressPreviewAfterAttach = false;
  /** 驾驶模式：折叠的 session 名 */
  collapsedSessions = new Set<string>();
  /** 驾驶表可见行 → state.tree 下标（排序+折叠后） */
  driveViewIndices: number[] | null = null;
  /** 驾驶模式增量绘：false 时 render 不清屏 */
  needsFullClear = true;
  /** 智能模式：右区内容（preview 或 team chatroom） */
  smartRightMode: "preview" | "chat" = "preview";
  /** Agents OS 驾驶舱模式（mux os 进入） */
  osMode = false;
  osBusy = "";
  osFlash = "";
  private _osActions: OsTuiActions | null = null;

  osActions(): OsTuiActions {
    if (!this._osActions) {
      this._osActions = createOsTuiActions({
        cursorTarget: () => {
          const n = state.tree[state.cursor];
          return n?.type === "window" ? n.target : null;
        },
        startInput,
        setBusy: (msg) => { state.osBusy = msg; },
        setFlash: (msg) => { state.osFlash = msg; },
        refresh: refreshAll,
        render,
      });
    }
    return this._osActions;
  }

  resetOsActions(): void {
    this._osActions = null;
  }

  clampView(bodyH: number) {
    if (state.uiMode === "smart") { clampSmartView(bodyH); return; }
    if (this.cursor < this.viewOffset) this.viewOffset = this.cursor;
    else if (this.cursor >= this.viewOffset + bodyH) this.viewOffset = this.cursor - bodyH + 1;
    if (this.viewOffset < 0) this.viewOffset = 0;
  }
}
const state = new TuiState();

function getPreviewH(): number {
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  return layout.bodyH;
}

function getLayout(cols: number, rows: number): LayoutInfo {
  const bodyH = rows - HEADER_H - FOOTER_H;
  if (state.uiMode === "index") {
    const leftW = Math.min(Math.max(Math.floor(cols * 0.2), 12), 30);
    const rightW = cols - leftW - 1;
    return { mode: "index", bodyH, leftW, rightW };
  }
  const previewW = Math.max(30, Math.floor(cols * 0.48));
  const treeW = cols - previewW - 1;
  return { mode: "smart", bodyH, leftW: previewW, rightW: treeW, treeHeaderH: 0, treeDataH: bodyH, paneH: 0, operW: 0, chatW: 15 };
}

function uiModeTag(): string {
  if (state.osMode) return process.env.TUI_DEV ? "[OS·dev]" : "[OS]";
  const mode = state.uiMode === "smart" ? "[智能]" : "[索引]";
  return process.env.TUI_DEV ? `${mode}·dev` : mode;
}

function treeVisibleRows(layout: LayoutInfo): number {
  return layout.bodyH;
}

function invalidateDriveView() {
  if (driveNavQuiet()) {
    driveViewDirty = true;
    return;
  }
  state.driveViewIndices = null;
  driveViewDirty = false;
}

function cycleUiMode(): void {
  state.uiMode = state.uiMode === "index" ? "smart" : "index";
  state.viewOffset = 0;
  state.scrollOffset = 0;
  state.needsFullClear = true;
  const [cols, rows] = screen.getSize();
  state.clampView(treeVisibleRows(getLayout(cols, rows)));
  render();
  if (state.uiMode === "smart") schedulePreview();
}

// === DEAD CODE: 驾驶模式渲染（保留参考） ===
type DriveColWidths = {
  stat: number; sess: number; win: number; wname: number; pname: number; pid: number; task: number;
  unread: number; lvl: number; age: number; st: number; act: number;
};

type DriveRowCells = {
  stat: string; sess: string; win: string; wname: string; pname: string; pid: string; task: string;
  unread: string; lvl: string; age: string; st: string; act: string;
};

/** Session / Win 固定下限；窄屏先缩 wname/pname，再缩 task */
function driveColWidths(cols: number): DriveColWidths {
  const scroll = 1;
  const stat = 1;
  const win = 4;
  const unread = 2;
  const lvl = 2;
  const age = 4;
  const st = 1;
  const act = 3;
  const pid = 6;
  let sess = 16;
  let wname = 12;
  let pname = 7;
  const sumFixed = () => stat + sess + win + wname + pname + pid + unread + lvl + age + st + act;
  let task = cols - sumFixed() - scroll;
  if (task < 5) {
    wname = Math.max(7, wname - 2);
    pname = Math.max(5, pname - 1);
    task = cols - sumFixed() - scroll;
  }
  if (task < 5) {
    sess = Math.max(12, sess - 2);
    task = cols - sumFixed() - scroll;
  }
  task = Math.max(4, task);
  return { stat, sess, win, wname, pname, pid, task, unread, lvl, age, st, act };
}

function driveFmtCol(text: string, w: number): string {
  return padVis(truncVis(text, w), w);
}

function driveRowLine(cw: DriveColWidths, parts: DriveRowCells): string {
  return driveFmtCol(parts.stat, cw.stat)
    + driveFmtCol(parts.sess, cw.sess)
    + driveFmtCol(parts.win, cw.win)
    + driveFmtCol(parts.wname, cw.wname)
    + driveFmtCol(parts.pname, cw.pname)
    + driveFmtCol(parts.pid, cw.pid)
    + driveFmtCol(parts.task, cw.task)
    + driveFmtCol(parts.unread, cw.unread)
    + driveFmtCol(parts.lvl, cw.lvl)
    + driveFmtCol(parts.age, cw.age)
    + driveFmtCol(parts.st, cw.st)
    + driveFmtCol(parts.act, cw.act);
}

function drivePlaceholderCells(extra?: Partial<DriveRowCells>): DriveRowCells {
  return {
    stat: DRIVE_PH, sess: DRIVE_PH, win: DRIVE_PH, wname: DRIVE_PH, pname: DRIVE_PH, pid: DRIVE_PH, task: DRIVE_PH,
    unread: DRIVE_PH, lvl: DRIVE_PH, age: DRIVE_PH, st: DRIVE_PH, act: DRIVE_PH,
    ...extra,
  };
}

function driveRowScoreForNode(node: TreeNode, treeIdx: number): number {
  if (node.driveSortScore !== undefined) return node.driveSortScore;
  return driveRowScore(windowMeta(node, treeIdx));
}

function buildDriveViewIndices(): number[] {
  const tree = state.tree;
  const scoreCache = new Map<number, number>();
  withDriveMetaCache(() => {
    for (let i = 0; i < tree.length; i++) {
      if (tree[i].type === "window") {
        scoreCache.set(i, tree[i].driveSortScore ?? driveRowScore(windowMeta(tree[i], i)));
      }
    }
  });
  const groups: Array<{ sessIdx: number; winIdxs: number[] }> = [];
  let i = 0;
  while (i < tree.length) {
    if (tree[i].type !== "session") {
      i++;
      continue;
    }
    const sessIdx = i;
    const sess = tree[i].sessionName;
    const winIdxs: number[] = [];
    i++;
    while (i < tree.length && tree[i].type === "window") {
      if (!state.collapsedSessions.has(sess)) winIdxs.push(i);
      i++;
    }
    winIdxs.sort((a, b) => {
      const sa = scoreCache.get(a) ?? 0;
      const sb = scoreCache.get(b) ?? 0;
      if (sb !== sa) return sb - sa;
      const wa = tree[a].target.split(":")[1] ?? "";
      const wb = tree[b].target.split(":")[1] ?? "";
      return parseInt(wa, 10) - parseInt(wb, 10);
    });
    groups.push({ sessIdx, winIdxs });
  }
  const out: number[] = [];
  for (const g of groups) {
    out.push(g.sessIdx);
    out.push(...g.winIdxs);
  }
  return out;
}

function getDriveViewIndices(): number[] {
  if (!state.driveViewIndices) state.driveViewIndices = buildDriveViewIndices();
  return state.driveViewIndices;
}

function clampDriveView(treeDataH: number): void {
  const view = getDriveViewIndices();
  if (view.length === 0) return;
  let pos = view.indexOf(state.cursor);
  if (pos < 0) {
    state.cursor = view[0];
    pos = 0;
  }
  if (pos < state.viewOffset) state.viewOffset = pos;
  else if (pos >= state.viewOffset + treeDataH) state.viewOffset = pos - treeDataH + 1;
  const maxOff = Math.max(0, view.length - treeDataH);
  if (state.viewOffset > maxOff) state.viewOffset = maxOff;
  if (state.viewOffset < 0) state.viewOffset = 0;
}

function clampSmartView(treeDataH: number): void {
  // 智能模式使用索引风格：viewOffset 是 tree-index 单位
  if (state.cursor < state.viewOffset) state.viewOffset = state.cursor;
  else if (state.cursor >= state.viewOffset + treeDataH) state.viewOffset = state.cursor - treeDataH + 1;
  const maxOff = Math.max(0, state.tree.length - treeDataH);
  if (state.viewOffset > maxOff) state.viewOffset = maxOff;
  if (state.viewOffset < 0) state.viewOffset = 0;
}

function driveTreeScrollMax(treeDataH: number): number {
  return Math.max(0, state.tree.length - treeDataH);
}

function scrollDriveTree(delta: number, treeDataH: number): void {
  const maxOff = driveTreeScrollMax(treeDataH);
  state.viewOffset = Math.max(0, Math.min(maxOff, state.viewOffset + delta));
  state.clampView(treeDataH);
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  if (layout.mode === "drive") {
    withDriveMetaCache(() => renderDriveRows(cols, layout));
  } else if (layout.mode === "smart") {
    render();
  } else render();
}

function treeScrollThumb(treeDataH: number): { thumbH: number; thumbStart: number } {
  const view = state.uiMode === "smart" ? getSmartViewIndices() : getDriveViewIndices();
  const total = Math.max(view.length, treeDataH);
  const thumbH = Math.max(1, Math.round((treeDataH * treeDataH) / total));
  const maxOff = driveTreeScrollMax(treeDataH);
  const thumbStart = maxOff <= 0
    ? 0
    : Math.max(0, Math.min(treeDataH - thumbH, Math.round((treeDataH * state.viewOffset) / maxOff)));
  return { thumbH, thumbStart };
}

function toggleSessionCollapse(sess: string): void {
  if (state.collapsedSessions.has(sess)) state.collapsedSessions.delete(sess);
  else state.collapsedSessions.add(sess);
  invalidateDriveView();
  const [cols, rows] = screen.getSize();
  state.clampView(treeVisibleRows(getLayout(cols, rows)));
  render();
}

function cursorWindow(): TreeNode | null {
  const node = state.tree[state.cursor];
  return node?.type === "window" ? node : null;
}

/** i：向当前 window 注入文本（默认 Enter；末尾 \\ 仅字面不发送 Enter） */
function sendPrompt(): void {
  const node = cursorWindow();
  if (!node) return;
  const spec = node.target;
  startInput(`send → ${spec} (\\ 结尾不 Enter)`, (raw) => {
    if (raw === null) {
      render();
      return;
    }
    const noEnter = raw.endsWith("\\");
    const body = noEnter ? raw.slice(0, -1) : raw;
    if (!body.trim()) {
      render();
      return;
    }
    try {
      injectToWindow(spec, body, { enter: !noEnter });
      refreshAll();
    } catch {
      /* tmux 不可达时静默 */
    }
    render();
  });
}

/** P：paste-buffer 粘贴文件到当前 window */
function pastePrompt(): void {
  const node = cursorWindow();
  if (!node) return;
  const spec = node.target;
  startInput(`paste → ${spec}  文件路径`, (raw) => {
    if (raw === null) {
      render();
      return;
    }
    const path = raw.trim();
    if (!path) {
      render();
      return;
    }
    try {
      pasteFileToWindow(spec, path);
      refreshAll();
    } catch {
      /* 文件不存在等 */
    }
    render();
  });
}

function driveCursorStep(dir: -1 | 1): void {
  const view = getSmartViewIndices();
  const pos = view.indexOf(state.cursor);
  const next = pos < 0 ? 0 : pos + dir;
  if (next < 0 || next >= view.length) return;

  markDriveNav();
  const prevCursor = state.cursor;
  const prevOffset = state.viewOffset;
  state.cursor = view[next];

  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  state.clampView(treeVisibleRows(layout));

  if (layout.mode === "drive" && !state.needsFullClear) {
    withDriveMetaCache(() => {
      screen.hideCursor();
      if (state.viewOffset !== prevOffset) {
        renderDriveRows(cols, layout);
      } else {
        renderDriveRows(cols, layout, { treeIndices: [prevCursor, state.cursor] });
      }
    });
    renderFooter(cols, rows);
  } else if (layout.mode === "smart") {
    withDriveMetaCache(() => {
      screen.hideCursor();
      renderSmartLeft(cols, layout);
      renderSmartRight(cols, layout);
    });
    renderFooter(cols, rows);
  } else {
    render();
  }
  schedulePreview({ driveOnly: true });
}

function writeDriveScrollGlyph(
  row: number, scrollCol: number, dataRow: number,
  thumb: { thumbStart: number; thumbH: number },
): void {
  screen.cursorAt(row, scrollCol);
  const inThumb = dataRow >= thumb.thumbStart && dataRow < thumb.thumbStart + thumb.thumbH;
  screen.write(`\x1b[90m${inThumb ? "▓" : "░"}\x1b[0m`);
}

function renderDriveTableDataRow(
  row: number, dataRow: number, treeIdx: number, cols: number, cw: DriveColWidths,
  thumb: { thumbStart: number; thumbH: number }, scrollCol: number,
): void {
  if (treeIdx >= 0 && treeIdx < state.tree.length) {
    renderDriveTableRow(row, state.tree[treeIdx], treeIdx, treeIdx === state.cursor, cols, cw);
  } else {
    screen.cursorAt(row, 1);
    screen.write(" ".repeat(Math.max(0, cols - 2)));
  }
  writeDriveScrollGlyph(row, scrollCol, dataRow, thumb);
}

function renderDriveRows(
  cols: number,
  layout: Extract<LayoutInfo, { mode: "drive" }>,
  opts?: { treeIndices?: number[] },
): void {
  const cw = driveColWidths(cols);
  const view = getDriveViewIndices();
  const thumb = treeScrollThumb(layout.treeDataH);
  const scrollCol = cols;
  const treeZoneH = layout.treeHeaderH + layout.treeDataH;

  if (!opts?.treeIndices) {
    renderDriveTableHeader(BODY_START_ROW, cols, cw);
    for (let dataRow = 0; dataRow < layout.treeDataH; dataRow++) {
      const row = layout.treeHeaderH + dataRow + BODY_START_ROW;
      renderDriveTableDataRow(row, dataRow, view[dataRow + state.viewOffset] ?? -1, cols, cw, thumb, scrollCol);
    }
  } else {
    for (const treeIdx of opts.treeIndices) {
      if (treeIdx < 0 || treeIdx >= state.tree.length) continue;
      const viewPos = view.indexOf(treeIdx);
      if (viewPos < 0) continue;
      const dataRow = viewPos - state.viewOffset;
      if (dataRow < 0 || dataRow >= layout.treeDataH) continue;
      renderDriveTableDataRow(
        layout.treeHeaderH + dataRow + BODY_START_ROW, dataRow, treeIdx, cols, cw, thumb, scrollCol,
      );
    }
  }
  renderDriveAnchor(treeZoneH + BODY_START_ROW, Math.max(0, cols - 2));
}

/** 仅重绘 preview 区 */
function renderDrivePreviewPane(cols: number, layout: Extract<LayoutInfo, { mode: "drive" }>): void {
  const { paneH, treeHeaderH, treeDataH } = layout;
  const treeZoneH = treeHeaderH + treeDataH;
  const previewRows = Math.max(0, paneH - 1);
  const allPLines = state.preview.split("\n");
  const pLines = allPLines.length > previewRows
    ? allPLines.slice(allPLines.length - previewRows)
    : allPLines;
  const textW = Math.max(0, cols - 2);
  const { thumbH, thumbStart } = previewScrollMetrics(previewRows);
  for (let paneLine = 1; paneLine < paneH; paneLine++) {
    if (paneLine - 1 >= previewRows) continue;
    const row = treeZoneH + paneLine + BODY_START_ROW;
    renderPreviewLine(row, 1, textW, paneLine - 1, pLines, { thumbH, thumbStart });
  }
}

function renderDriveAnchor(row: number, textW: number): void {
  const node = state.tree[state.cursor];
  if (!node) return;
  let line = "";
  if (node.type === "session") {
    const folded = state.collapsedSessions.has(node.sessionName) ? " ▾" : " ▴";
    line = `▣ ${node.sessionName}${folded} · Space 折/展`;//toogle 树的这个分支的 “展开/折上”
  } else {
    const m = windowMeta(node, state.cursor);
    const ag = node.agent;
    const proc = readDriveProc(winTargetFromNode(node));
    line = `${node.sessionName}:${node.target.split(":")[1]} ${windowNameFromNode(node)}`
      + ` ·${m.cabin.code}${m.cabin.kind}`
      + (ag ? ` @${ag}` : "")
      + (m.unread > 0 ? ` ·未读${m.unread}` : "")
      + (proc ? ` ·${proc.rssMB}M ${proc.cpu < 10 ? proc.cpu.toFixed(1) : Math.round(proc.cpu)}%` : "");
  }
  screen.cursorAt(row, 1);
  screen.write(screen.dim(padVis(truncVis(line, textW), textW)));
}

function writeDriveRow(row: number, cols: number, line: string, selected: boolean, dim = false): void {
  const cap = cols - 2; // 末列滚动条
  screen.cursorAt(row, 1);
  const vis = padVis(truncVis(line, cap), cap);
  if (selected) screen.write(screen.inv(dim ? screen.dim(vis) : vis));
  else if (dim) screen.write(screen.dim(vis));
  else screen.write(vis);
}

function renderDriveTableHeader(row: number, cols: number, cw: DriveColWidths): void {
  const line = driveRowLine(cw, {
    stat: "●",
    sess: "Session",
    win: "Win",
    wname: "Name",
    pname: "Cmd",
    pid: "PID",
    task: "Task",
    unread: "Rd",
    lvl: "Lv",
    age: "Age",
    st: "St",
    act: "Act",
  });
  screen.cursorAt(row, 1);
  screen.write(screen.inv(screen.bold(padVis(truncVis(line, cols - 2), cols - 2))));
}

function renderDriveTableRow(
  row: number, node: TreeNode, treeIdx: number, selected: boolean, cols: number, cw: DriveColWidths,
): void {
  if (node.type === "session") {
    const n = sessionWindowCount(state.tree, treeIdx);
    const line = driveRowLine(cw, drivePlaceholderCells({
      stat: "▣",
      sess: node.sessionName,
      win: "",
      wname: `(${n})`,
      pname: "",
      pid: "",
      task: "",
    }));
    writeDriveRow(row, cols, line, selected, true);
    return;
  }
  const [, winIdx] = node.target.split(":");
  const m = windowMeta(node, treeIdx);
  const winName = node.label.replace(/^[├└]\s*/, "");
  const proc = formatProcCells(readDriveProc(winTargetFromNode(node)));
  const line = driveRowLine(cw, {
    stat: m.alert ? "!" : m.unread > 0 ? "●" : "○",
    sess: node.sessionName,
    win: winIdx,
    wname: winName,
    pname: proc.pname,
    pid: proc.pid,
    task: truncVis(m.task, cw.task),
    unread: m.unread > 0 ? String(m.unread) : "",
    lvl: m.lvl,
    age: m.age,
    st: m.cabin.code,
    act: m.act,
  });
  writeDriveRow(row, cols, line, selected);
}
// === END DEAD CODE ===

// SMART: 智能模式 — 左区 team子树+chat-preview列 / 右区 preview↔chatroom toggle

/** 计算 session 下的 oper 数量 */
function countOpers(sessIdx: number): number {
  let n = 0;
  for (let i = sessIdx + 1; i < state.tree.length && state.tree[i]?.type === "window"; i++) n++;
  return n;
}

/** 每个 team 的 chat 消息缓存 */
const teamChats = new Map<string, string[]>();

function ensureTeamChat(name: string): string[] {
  if (!teamChats.has(name)) teamChats.set(name, ["bot: 准备就绪 ·", "等待指令 ─", "───", "", ""]);
  return teamChats.get(name)!;
}

function getSmartViewIndices(): number[] {
  const out: number[] = [];
  for (let i = 0; i < state.tree.length; i++) out.push(i);
  return out;
}

/** 从 treeIdx 向上找到所属 session */
function findTeamIdx(treeIdx: number): number {
  for (let i = treeIdx; i >= 0; i--) if (state.tree[i]?.type === "session") return i;
  return 0;
}

/** 跳到前/后一个 team */
function jumpTeam(dir: -1 | 1): void {
  if (state.tree.length === 0) return;
  let i = state.cursor + dir;
  while (i >= 0 && i < state.tree.length) {
    if (state.tree[i]?.type === "session") { state.cursor = i; schedulePreview(); return; }
    i += dir;
  }
}

/** 切换右区模式 preview ↔ chat */
function toggleSmartRightMode(): void {
  state.smartRightMode = state.smartRightMode === "preview" ? "chat" : "preview";
  if (state.smartRightMode === "preview") schedulePreview();
  else render();
}

/** 渲染右区顶栏 */
function renderSmartRightHeader(col: number, textW: number): void {
  const tag = state.smartRightMode === "preview" ? "Preview" : "Chat";
  let line: string;
  if (state.osMode) {
    const target = state.tree[state.cursor]?.type === "window" ? state.tree[state.cursor].target : null;
    const panel = osPanelLines(target).join(" · ");
    line = ` OS ${panel}`;
    if (state.osBusy) line = ` ${state.osBusy}`;
    else if (state.osFlash) line = ` ${state.osFlash}`;
  } else if (state.smartRightMode === "preview" && state.tree[state.cursor]?.type === "window") {
    line = ` ${screen.dim(tag)} ${state.tree[state.cursor].target}  c切换`;
  } else if (state.smartRightMode === "chat") {
    const teamName = state.tree[findTeamIdx(state.cursor)]?.sessionName ?? "?";
    line = ` ${screen.dim(tag)} ${teamName}  c切换`;
  } else {
    line = ` ${screen.dim(tag)}  c切换`;
  }
  screen.cursorAt(BODY_START_ROW, col);
  screen.write(screen.inv(padVis(truncVis(line, textW), textW)));
}

/** 左区：preview */
function renderRightPreview(col: number, textW: number, bodyH: number): void {
  const allPLines = state.preview.split("\n");
  const rows = bodyH - 1;
  const pLines = allPLines.length > rows ? allPLines.slice(allPLines.length - rows) : allPLines;
  for (let i = 0; i < rows; i++) {
    const r = i + BODY_START_ROW + 1;
    const snippet = (pLines[i] ?? "").slice(0, textW);
    screen.cursorAt(r, col);
    screen.write(snippet + " ".repeat(Math.max(0, textW - snippet.length)));
  }
}

/** 右区：chatroom */
function renderRightChat(col: number, textW: number, bodyH: number): void {
  const teamIdx = findTeamIdx(state.cursor);
  const teamName = state.tree[teamIdx]?.sessionName ?? "?";
  const msgs = ensureTeamChat(teamName);
  const rows = bodyH - 1;
  const start = Math.max(0, msgs.length - rows);
  for (let i = 0; i < rows; i++) {
    const r = i + BODY_START_ROW + 1;
    const msg = i + start < msgs.length ? msgs[i + start]! : "";
    screen.cursorAt(r, col);
    screen.write(padVis(truncVis(msg, textW), textW));
  }
}

/** 渲染一个 team 子树 + chat-preview 列 */
function renderTeamBlock(
  startRow: number, sessIdx: number, chatW: number, treeW: number, bodyH: number, baseCol = 1,
): number {
  const sess = state.tree[sessIdx]!;
  const nOpers = countOpers(sessIdx);
  const blockH = Math.max(5, 1 + nOpers);
  const chat = ensureTeamChat(sess.sessionName);
  const maxRow = BODY_START_ROW + bodyH;
  const chatCol = baseCol;
  const treeCol = baseCol + chatW + 1;
  let row = startRow;
  if (row >= maxRow) return row;

  // chat-preview 列（显示最近 blockH 条消息，底部对齐）
  const chatStart = Math.max(0, chat.length - blockH);
  for (let ci = 0; ci < blockH; ci++) {
    const r = row + ci;
    if (r >= maxRow) break;
    screen.cursorAt(r, chatCol);
    const msgIdx = chatStart + ci;
    const msg = msgIdx < chat.length ? chat[msgIdx]! : "";
    screen.write(screen.dim(padVis(truncVis(msg, chatW), chatW)));
    screen.cursorAt(r, treeCol - 1);
    screen.write(screen.dim("│"));
  }

  // Team header
  const isTeamSelected = state.cursor === sessIdx;
  const unread = sess.cachedUnread ?? 0;
  const stats = `op:${nOpers}` + (unread > 0 ? ` rd:${unread}` : "");
  const header = `▣ ${sess.sessionName}  ${screen.dim(stats)}`;
  screen.cursorAt(row, treeCol);
  screen.write(isTeamSelected ? screen.inv(screen.bold(padVis(truncVis(header, treeW), treeW))) : screen.bold(padVis(truncVis(header, treeW), treeW)));
  row++;

  // Oper 行
  for (let i = sessIdx + 1; i < state.tree.length && state.tree[i]?.type === "window"; i++) {
    if (row >= maxRow) break;
    screen.cursorAt(row, treeCol);
    renderLeftCell(state.tree[i]!, state.cursor === i, treeW);
    row++;
  }

  // 不足 blockH 补空
  while (row < startRow + blockH && row < maxRow) {
    screen.cursorAt(row, treeCol);
    screen.write(" ".repeat(treeW));
    row++;
  }
  return startRow + blockH;
}

/** 左区（40%）：preview / chatroom */
function renderSmartLeft(cols: number, layout: Extract<LayoutInfo, { mode: "smart" }>): void {
  const col = 1;
  const textW = Math.max(8, layout.leftW - 1);
  const bodyH = layout.treeDataH;

  // 左右分隔线
  for (let r = BODY_START_ROW; r < BODY_START_ROW + bodyH; r++) {
    screen.cursorAt(r, layout.leftW);
    screen.write(screen.dim("│"));
  }

  renderSmartRightHeader(col, textW);
  if (state.smartRightMode === "chat") renderRightChat(col, textW, bodyH);
  else renderRightPreview(col, textW, bodyH);
}

/** 右区（60%）：team 子树 + chat-preview 列 */
function renderSmartRight(cols: number, layout: Extract<LayoutInfo, { mode: "smart" }>): void {
  const col = layout.leftW + 1;
  const chatW = layout.chatW;
  const treeW = layout.rightW - chatW - 1;
  const maxRow = BODY_START_ROW + layout.treeDataH;
  let row = BODY_START_ROW;

  for (let i = state.viewOffset; i < state.tree.length && row < maxRow; ) {
    if (state.tree[i]?.type !== "session") { i++; continue; }
    const nextRow = renderTeamBlock(row, i, chatW, treeW, layout.treeDataH, col);
    if (nextRow >= maxRow) break;
    row = nextRow;
    if (row < maxRow) {
      screen.cursorAt(row, col);
      screen.write(screen.dim(padVis("─".repeat(layout.rightW), layout.rightW)));
      row++;
    }
    i++;
    while (i < state.tree.length && state.tree[i]?.type !== "session") i++;
  }
}

function renderSmartBody(cols: number, rows: number, layout: Extract<LayoutInfo, { mode: "smart" }>) {
  renderSmartLeft(cols, layout);
  renderSmartRight(cols, layout);
}

// PART:render

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
  const unread = node.type === "window" ? (node.cachedUnread ?? 0) : 0;
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

function renderHeader(cols: number): void {
  screen.cursorAt(1, 1);
  const previewScrollInd = state.scrollOffset > 0 ? ` ↕${state.scrollOffset}` : "";
  const treeScrollInd = state.viewOffset > 0 ? ` ↑${state.viewOffset}` : "";
  const helpRest = `${uiModeTag()} ${tuiHeaderHelp()}${treeScrollInd}${previewScrollInd}`;
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
  } else if (state.uiMode === "smart") {
    const hint = state.osMode
      ? ` D派工 O并行 V验 A全验 Y重试 · ${state.osActions().statusLine()}`
      : ` c:${state.smartRightMode === "preview" ? "preview" : "chat"} · [ ]跳组 · i发 · P贴 · Enter进舱`;
    screen.write(screen.gold(padVis(truncVis(hint, cols - 1), cols - 1)));
  } else {
    const hint = " i发 · P贴 · Enter进舱";
    screen.write(screen.gold(padVis(truncVis(hint, cols - 1), cols - 1)));
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
  const pending = state.previewDoneId < state.previewFetchId;
  const indexMode = state.uiMode === "index";
  if (state.previewTarget && lineIdx === 0 && pending && !indexMode) {
    screen.write(screen.dim(`⏳ ${state.previewTarget} ...`).slice(0, textW));
  } else if (state.suppressPreviewAfterAttach && lineIdx === 0) {
    screen.write(screen.dim("  已从分舱返回 · 按 f 刷新预览").slice(0, textW));
  } else if (state.suppressPreviewAfterAttach) {
    screen.write(" ".repeat(textW));
  } else {
    const raw = (pLines[lineIdx] || "").slice(0, textW);
    screen.write(raw);
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

// 驾驶模式（已弃用，保留参考）

function render() {
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  state.clampView(treeVisibleRows(layout));

  if (!state.needsFullClear) state.needsFullClear = false;
  screen.clear();

  screen.hideCursor();
  renderHeader(cols);
  if (layout.mode === "smart") renderSmartBody(cols, rows, layout);
  else renderIndexBody(cols, rows, layout);
  renderFooter(cols, rows);
}

// PART:detach-keys

const installDetachKeys = () => {
  tmuxApi.bindKey(TUI_CONFIG.TUI_KEYTABLE, "C-Left", "detach-client");
  tmuxApi.bindKey(TUI_CONFIG.TUI_KEYTABLE, "M-Left", "detach-client");
  tmuxApi.bindKey(null, "C-Left", "detach-client");
  tmuxApi.bindKey(null, "M-Left", "detach-client");
  // 沉浸式顶栏 status-left「返回」区：鼠标左键同 detach
  tmuxApi.bindKey("root", "MouseDown1StatusLeft", "detach-client");
};
const uninstallDetachKeys = () => {
  tmuxApi.unbindKeyRoot("C-Left");
  tmuxApi.unbindKeyRoot("M-Left");
  tmuxApi.unbindKey("root", "MouseDown1StatusLeft");
};

// PART:outer-mouse
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

function disableOuterMouse() {
  if (!insideTmux) return;
  savedOuterMouse = tmuxApi.getGlobalOption("mouse") || "off";
  if (savedOuterMouse === "on") tmuxApi.setGlobalOption("mouse", "off");
}
function restoreOuterMouse() {
  if (!insideTmux || savedOuterMouse === null) return;
  tmuxApi.setGlobalOption("mouse", savedOuterMouse);
}

// PART:input

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

// PART:tui-keys

function matchKeyUp(s: string): boolean {
  if (s === "k") return true;
  if (s === "\x1b[A" || s === "\x1bOA") return true;
  return /^\x1b\[(?:\d+(?:;\d+)*)?A$/.test(s);
}

function matchKeyDown(s: string): boolean {
  if (s === "j") return true;
  if (s === "\x1b[B" || s === "\x1bOB") return true;
  return /^\x1b\[(?:\d+(?:;\d+)*)?B$/.test(s);
}

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
  attach(state.tree[state.cursor].target);
}

// PART:tui-registry — buildTuiPrompts(TUI_CLI_MIRROR) @ CLI_OPS 之后 init

type TuiPromptSpec = {
  key: string;
  help: string;
  mirror: string;
  needsTree?: boolean;
  prompt: () => string;
  submit: (answer: string | null) => void;
};

type TuiInstantSpec = {
  key: string;
  help: string;
  run: () => void;
};

function runTuiPrompt(spec: TuiPromptSpec): void {
  if (spec.needsTree && state.tree.length === 0) return;
  startInput(spec.prompt(), spec.submit);
}

const TUI_NAV: { help: string; match: (s: string) => boolean; run: () => void }[] = [
  { help: "↑/k", match: matchKeyUp, run: cursorUp },
  { help: "↓/j", match: matchKeyDown, run: cursorDown },
];

const TUI_INSTANT: TuiInstantSpec[] = [
  { key: "f", help: "f:刷", run: refreshAll },
  { key: "o", help: "o:模式", run: cycleUiMode },
  { key: "i", help: "i:发", run: sendPrompt },
  { key: "P", help: "P:贴", run: pastePrompt },
  { key: "c", help: "c:右区", run: toggleSmartRightMode },
  { key: "[", help: "[:跳组", run: () => jumpTeam(-1) },
  { key: "]", help: "]:跳组", run: () => jumpTeam(1) },
];

let TUI_PROMPTS: TuiPromptSpec[] = [];
let TUI_KEYBINDS: { help: string; match: (s: string) => boolean; run: () => void }[] = [];

const TUI_OS_INSTANT: TuiInstantSpec[] = [
  { key: "D", help: "D:派工", run: () => state.osActions().dispatchPrompt() },
  { key: "O", help: "O:并行", run: () => state.osActions().orchestratePrompt() },
  { key: "V", help: "V:验", run: () => state.osActions().verify() },
  { key: "A", help: "A:全验", run: () => state.osActions().verifyAll() },
  { key: "Y", help: "Y:重试", run: () => state.osActions().retry() },
];

function buildTuiKeybinds(): { help: string; match: (s: string) => boolean; run: () => void }[] {
  const instant = state.osMode ? [...TUI_OS_INSTANT, ...TUI_INSTANT] : TUI_INSTANT;
  return [
    ...TUI_NAV,
    ...TUI_PROMPTS.map((p) => ({
      help: p.help,
      match: (s: string) => s === p.key,
      run: () => runTuiPrompt(p),
    })),
    ...instant.map((i) => ({
      help: i.help,
      match: (s: string) => s === i.key,
      run: i.run,
    })),
  ];
}

function initTuiRegistry(force = false): void {
  if (TUI_KEYBINDS.length > 0 && !force) return;
  assertTuiCliMirror();
  TUI_PROMPTS = buildTuiPrompts();
  TUI_KEYBINDS = buildTuiKeybinds();
}

function tuiHeaderHelp(): string {
  initTuiRegistry();
  return ["Enter进", "C-←回", ...TUI_KEYBINDS.map((b) => b.help), "q:退"].join(" ");
}

const TUI_ENTER_KEYS = new Set([
  "\r", "\x1b[1;5C", "\x1b[1;3C", "\x1b[1;9C", "\x1b\x1b[C", "\x1bOC",
]);

// PART:tui-ops

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
    `'${tb}' set-option -t '${v}' status-left ' #[bold]← '`,
    `'${tb}' set-option -t '${v}' status-left-length 5`,
    `'${tb}' set-option -t '${v}' status-right 'ctrl-左返回 · 驾驶:${cabin} '`,
    `'${tb}' set-option -t '${v}' window-status-format ''`,
    `'${tb}' set-option -t '${v}' window-status-current-format ''`,
    `'${tb}' set-option -t '${v}' window-status-separator ''`,
    `'${tb}' set-option -t '${v}' status-justify centre`,
    `'${tb}' set-option -t '${v}' status-style 'bg=white,fg=black'`,
  ].join(" && ");
  const win = idx ? ` && '${tb}' select-window -t '${v}:${idx}'` : "";
  tmuxShBatch(opts + win);
  tmuxApi.setSessionOption(v, "mouse", "on");
}

/** 进舱前：停 loop、清 preview、切终端/鼠标、建 viewer + detach 键 */
function enterImmersiveAttach(sess: string, idx?: string): void {
  stopDriveLoops();
  state.previewFetchId++;
  if (state.previewTimer) clearTimeout(state.previewTimer);
  state.previewTimer = null;

  screen.showCursor();
  screen.disableMouse();
  // 进舱期把整条 TTY 输入让给 tmux 子进程：摘掉 Node 的 data 监听并暂停 stdin，
  // 否则 Node(flowing) 与 tmux attach 争抢同一 tty 字节流，会把 Ctrl-Left 等
  // 转义序列切碎——tmux 收到残缺/裸 ESC 并透传给 grouped 的 claude pane，误中断其工作。
  process.stdin.off("data", handleKey);
  process.stdin.pause();
  process.stdin.setRawMode(false);
  // 主界面 disableOuterMouse 可能关了全局 mouse；沉浸式须开回，否则 server 收不到滚轮
  tmuxApi.setGlobalOption("mouse", "on");
  withTmuxQuiet(() => {
    installDetachKeys();
    createViewer(sess, idx);
  });
}

/** 出舱后：恢复 TUI 态 + 延迟 sync tree（detach 后静默） */
function exitImmersiveAttach(): void {
  withTmuxQuiet(uninstallDetachKeys);
  // 复原 stdin 消费；丢弃 attach 期间可能残留的半条转义序列，避免被误解析成 TUI 按键
  keyInputBuf = "";
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.on("data", handleKey);
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
  state.needsFullClear = true;
  render();

  setTimeout(() => {
    withTmuxQuiet(() => {
      state.tree = syncTree();
      hydrateDriveSortScores(state.tree);
      if (state.cursor >= state.tree.length) {
        state.cursor = Math.max(0, state.tree.length - 1);
      }
    });
    startDriveLoops();
    render();
  }, RETURN_FROM_ATTACH_DELAY);
}

/** 沉浸式 attach 生命周期：enter → run(attach) → kill viewer → exit */
function withImmersiveAttach(target: string, attachFn: () => void): void {
  const [sess, idx] = target.split(":");
  enterImmersiveAttach(sess, idx);
  try {
    screen.leaveAltScreen();
    try {
      attachFn();
    } finally {
      withTmuxQuiet(() => tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION));
    }
  } finally {
    exitImmersiveAttach();
  }
}

function attach(target: string) {
  withImmersiveAttach(target, () => {
    tmuxApi.attach(TUI_CONFIG.VIEWER_SESSION);
  });
}

// PART:preview

function refreshAll() {
  endPaneSnapBatch(); // 清掉可能未闭合的 paneSnap 批处理
  state.suppressPreviewAfterAttach = false;
  state.needsFullClear = true;
  invalidateDriveView();
  state.tree = syncTree();
  hydrateDriveSortScores(state.tree);
  if (state.cursor >= state.tree.length) state.cursor = Math.max(0, state.tree.length - 1);
  void refreshDriveSnapshots(true);
  void refreshDriveProc(true);
  schedulePreview({ delay: 0 });
}

function clearPreview(): void {
  state.preview = "";
  state.previewTarget = "";
  state.previewDoneId = state.previewFetchId;
}

async function refreshPreview() {
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);

  if (
    state.tree.length > 0 &&
    state.cursor < state.tree.length &&
    state.tree[state.cursor].type === "window"
  ) {
    const id = state.previewFetchId;
    const target = state.tree[state.cursor].target;
    if (!state.preview) {
      state.previewTarget = target;
      render();
    }
    const text = await getPreview(target);
    if (id !== state.previewFetchId) return;
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
  /** false：attach 返回等场景，不调度 debounced preview */
  pending?: boolean;
  /** 驾驶 ↑↓：不 render，仅 debounce preview fetch */
  driveOnly?: boolean;
}) {
  state.suppressPreviewAfterAttach = false;
  if (state.previewTimer) clearTimeout(state.previewTimer);
  if (opts?.pending === false) return;

  if (!opts?.keepScroll) {
    state.scrollOffset = 0;
    state.seenMax = 0;
  }
  if (
    state.tree.length === 0 ||
    state.cursor >= state.tree.length ||
    state.tree[state.cursor].type !== "window"
  ) {
    clearPreview();
    if (!opts?.driveOnly) render();
    return;
  }

  const delay = opts?.delay ?? PREVIEW_DELAY;
  if (!opts?.driveOnly) {
    state.previewFetchId++;
    render();
  }

  state.previewTimer = setTimeout(() => {
    state.previewTimer = null;
    if (opts?.driveOnly) state.previewFetchId++;
    void refreshPreview();
  }, delay);
}

// PART:key-handler

let lastClickY = -1;
let lastClickT = 0;
/** raw stdin 分片 ESC 缓冲 */
let keyInputBuf = "";
/** stdin 原始字节→UTF-8 流式解码器：跨 chunk 保留未完成的多字节序列尾部，防止中文等多字节输入在 chunk 边界被错误切断解码成乱码 */
const keyStdinDecoder = new StringDecoder("utf8");

function isEscapeComplete(s: string): boolean {
  if (!s.startsWith("\x1b")) return true;
  if (s.length === 1) return false;
  if (s.startsWith("\x1b[<")) return /^\x1b\[<\d+;\d+;\d+[Mm]/.test(s);
  if (s.startsWith("\x1bO")) return s.length >= 3;
  if (s.startsWith("\x1b[")) return /^\x1b\[[\d;]*[\x40-\x7E]$/.test(s);
  return s.length >= 2;
}

export function pullKeySequences(data: Buffer): string[] {
  keyInputBuf += keyStdinDecoder.write(data);
  const out: string[] = [];
  while (keyInputBuf.length > 0) {
    const mouse = keyInputBuf.match(/^\x1b\[<(\d+);(\d+);(\d+)([Mm])/);
    if (mouse) {
      handleMouse(parseInt(mouse[1], 10), parseInt(mouse[2], 10), parseInt(mouse[3], 10), mouse[4] === "M");
      keyInputBuf = keyInputBuf.slice(mouse[0].length);
      continue;
    }
    if (keyInputBuf.startsWith("\x1b")) {
      if (!isEscapeComplete(keyInputBuf)) {
        if (keyInputBuf.length > 24) {
          out.push(keyInputBuf[0]!);
          keyInputBuf = keyInputBuf.slice(1);
          continue;
        }
        break;
      }
      const ss3 = keyInputBuf.match(/^\x1bO[\x40-\x7E]/)?.[0];
      const csi = keyInputBuf.match(/^\x1b\[[\d;]*[\x40-\x7E]/)?.[0];
      const seq = ss3 || csi || keyInputBuf.slice(0, 1);
      out.push(seq);
      keyInputBuf = keyInputBuf.slice(seq.length);
      continue;
    }
    out.push(keyInputBuf[0]!);
    keyInputBuf = keyInputBuf.slice(1);
  }
  return out;
}

function handleMouse(rawBtn: number, x: number, y: number, press: boolean) {
  const { btn } = decodeMouseBtn(rawBtn);
  const [cols, rows] = screen.getSize();
  const layout = getLayout(cols, rows);
  const bodyY = y - BODY_START_ROW;
  const inPreviewZone = layout.mode === "index" ? x >= layout.leftW : x < layout.leftW;
  // 滚轮
  if (btn === 64 || btn === 65) {
    if (!press) return;
    if (inPreviewZone) {
      const previewH = getPreviewH();
      if (btn === 64) state.scrollOffset += 3;
      else state.scrollOffset = Math.max(0, state.scrollOffset - 3);
      const maxScroll = Math.max(0, PREVIEW_SCROLL_MAX - previewH);
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
  if (layout.mode === "smart" && x < layout.leftW) return;
  let idx: number;
  idx = bodyY + state.viewOffset;
  if (idx < 0 || idx >= state.tree.length) return;
  const now = Date.now();
  const dbl = lastClickY === idx && now - lastClickT < MOUSE_DBLCLICK_MS;
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

function handleKeySeq(s: string) {
  if (state.inputMode) {
    handleInputKey(s);
    return;
  }

  if (s === "\x03" || s === "q") {
    screen.showCursor();
    screen.clear();
    process.exit(0);
  }
  if (TUI_ENTER_KEYS.has(s)) {
    enterAttach();
    return;
  }
  // Ctrl+↑/↓ / [/] → 跳 team
  if (s === "\x1b[1;5A") { jumpTeam(-1); return; }
  if (s === "\x1b[1;5B") { jumpTeam(1); return; }
  if (s === " ") {
    const node = state.tree[state.cursor];
    if (node?.type === "session") toggleSessionCollapse(node.sessionName);
    return;
  }
  initTuiRegistry();
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

function handleKey(data: Buffer) {
  for (const s of pullKeySequences(data)) handleKeySeq(s);
}

// PART:cli

const CLI_BIN = (process.argv[1] || "mux").replace(/^.*\//, "");

type CliHandler = (ctx: CliCtx) => number;

interface CliCommand {
  name: string;
  aliases?: string[];
  summary: string;
  usage?: string;
  children?: CliCommand[];
  run: CliHandler;
  needsTmux?: boolean;
  /** true: cliHelp 跳过（如 help 自身） */
  helpHidden?: boolean;
}

// PART:cli-registry — 能力声明（CLI 树由此推导）
//
// 分层（CLI_ROOT_SECTIONS → buildCliRoot / cliHelp 同源投影）:
//   CLI_META_CMDS    — help
//   CLI_MAINT_CMDS   — dev / doctor / install-tmux（无需 tmux）
//   CLI_FLEET_VIEWS  — status / list
//   CLI_TOOL_CMDS    — inspect / capture / send / paste
//   CLI_AGENT_CMDS   — agent bus
//   CLI_OPS          — session/window 变更
//   CLI_USER_OPTS    — @remark / @auto

type LeafCmdSpec = {
  summary: string;
  usage?: string;
  aliases?: string[];
  run: CliHandler;
  /** false = runCli 跳过 tmux 探测；默认 true */
  needsTmux?: boolean;
  helpHidden?: boolean;
};

const CLI_HELP_NOTES = [
  "<spec>: @逻辑名 | sess | sess:idx | =sess:idx（@ 仅 remark 反查）",
  "agent: 纯名 + window @agent；register 后 inbox → ~/.tui/inbox/<name>.jsonl",
  "结构化: 任意子命令可加 --json；status/inspect 供 agent 拉车队快照",
  "开发: tui dev [args…] — 保存源码自动重启（TUI_DEV=1）",
] as const;

type UserOptSpec = {
  summary: string;
  scope: "any" | "window";
  read: (node: TreeNode) => string;
  write: (node: TreeNode, v: string) => void;
  setUsage: string;
  getUsage: string;
  /** true: set 时 positional[1..] 拼成文本；false: 单值 positional[1] */
  setJoinRest?: boolean;
  validate?: (raw: string) => string | null;
};

const CLI_USER_OPTS: Record<string, UserOptSpec> = {
  remark: {
    summary: "读写 @remark 逻辑名",
    scope: "any",
    read: readRemark,
    write: writeRemark,
    setUsage: "<spec> [text...]",
    getUsage: "<spec>",
    setJoinRest: true,
  },
  auto: {
    summary: "读写 window @auto 档位（0/50/100）",
    scope: "window",
    read: (n) => readAuto(n),
    write: writeAuto,
    setUsage: "<window-spec> <0|50|100>",
    getUsage: "<window-spec>",
    validate: (raw) => {
      const lvl = normalizeAutoLevel(raw);
      return AUTO_LEVELS.includes(lvl) ? lvl : null;
    },
    /** @reserved drive 自动波/档未设计；仅 metadata + CLI，不参与采样策略 */
  },
};

type OpSpec = {
  summary: string;
  usage: string;
  aliases?: string[];
  arity: number;
  run: (args: string[]) => string;
};

const CLI_OPS: Record<string, OpSpec> = {
  "new-session": {
    summary: "新建 session（-d）",
    usage: "<name>",
    aliases: ["ns"],
    arity: 1,
    run: (a) => { const n = opNewSession(a[0]); return `session ${n}`; },
  },
  "new-window": {
    summary: "在 session 下新建 window",
    usage: "<sess-spec> <name>",
    aliases: ["nw"],
    arity: 2,
    run: (a) => { const n = opNewWindow(a[0], a[1]); return `window ${a[0]}:${n}`; },
  },
  rename: {
    summary: "重命名 session/window",
    usage: "<spec> <name>",
    arity: 2,
    run: (a) => { const n = opRename(a[0], a[1]); return `renamed → ${n}`; },
  },
  "kill-window": {
    summary: "关闭 window（不含 session）",
    usage: "<spec>",
    aliases: ["delete", "rm"],
    arity: 1,
    run: (a) => { opKillWindow(a[0]); return `killed ${resolveTarget(a[0])}`; },
  },
};

/** CLI user-opt set 与 TUI remark 共用 */
function applyUserOptSet(optName: string, targetSpec: string, rawValue: string): string {
  const spec = CLI_USER_OPTS[optName];
  const { target, node } = parseTargetSpec(targetSpec);
  if (spec.scope === "window" && node.type !== "window") {
    throw new Error(`${optName} 需要 window spec`);
  }
  let value = rawValue;
  if (spec.validate) {
    const ok = spec.validate(rawValue);
    if (ok === null) throw new Error(`${optName} 档位须为 0 | 50 | 100`);
    value = ok;
  }
  spec.write(node, value);
  return `${optName} ${target} = ${value || "(cleared)"}`;
}

/** CLI_OPS + CLI_USER_OPTS set 单一执行入口（TUI runTuiOp / cliOp / cliUserOptSet 共用） */
function runRegistryOp(name: string, args: string[]): string {
  if (name in CLI_OPS) {
    const spec = CLI_OPS[name]!;
    if (args.length < spec.arity) throw new Error(`${name} 需要 ${spec.arity} 个参数`);
    return spec.run(args);
  }
  if (name in CLI_USER_OPTS) {
    if (!args[0]) throw new Error(`${name} 需要 target spec`);
    return applyUserOptSet(name, args[0], args.slice(1).join(" "));
  }
  throw new Error(`未知 registry 命令: ${name}`);
}

type TuiMirrorEntry = { key: string; help: string; needsTree?: boolean };

/** TUI 快捷键 ↔ CLI 镜像（buildTuiPrompts 单一投影源） */
const TUI_CLI_MIRROR: {
  ops: Record<keyof typeof CLI_OPS, TuiMirrorEntry>;
  userOpts: Partial<Record<keyof typeof CLI_USER_OPTS, TuiMirrorEntry>>;
} = {
  ops: {
    "new-session": { key: "n", help: "n:Session" },
    "new-window": { key: "w", help: "w:Win", needsTree: true },
    "kill-window": { key: "d", help: "d:删", needsTree: true },
    rename: { key: "r", help: "r:改名", needsTree: true },
  },
  userOpts: {
    remark: { key: "m", help: "m:备注", needsTree: true },
  },
};

function tuiCursorNode(): TreeNode {
  return state.tree[state.cursor]!;
}

const TUI_PROMPT_HANDLERS: Record<string, { prompt: () => string; args: (answer: string | null) => string[] | null }> = {
  "new-session": {
    prompt: () => "新 Session 名称",
    args: (a) => { const name = a?.trim(); return name ? [name] : null; },
  },
  "new-window": {
    prompt: () => `在 [${tuiCursorNode().sessionName}] 新建 Window 名称`,
    args: (a) => { const name = a?.trim(); return name ? [tuiCursorNode().sessionName, name] : null; },
  },
  "kill-window": {
    prompt: () => {
      const node = tuiCursorNode();
      if (node.type !== "window") return "不可删 session；请将光标移到 window";
      return `删除 window [${node.target}]? (d/Enter 确认)`;
    },
    args: (a) => {
      if (a === null) return null;
      const node = tuiCursorNode();
      if (node.type !== "window") return null;
      // 空 Enter 或 d/y 都视为确认
      if (a === "" || a.toLowerCase() === "d" || a.toLowerCase() === "y") return [node.target];
      return null;
    },
  },
  rename: {
    prompt: () => {
      const node = tuiCursorNode();
      return `rename ${node.type} [${node.target}]`;
    },
    args: (a) => {
      const name = a?.trim();
      if (!name) return null;
      const node = tuiCursorNode();
      const spec = node.type === "session" ? node.sessionName : node.target;
      return [spec, name];
    },
  },
  remark: {
    prompt: () => `修改备注 [${tuiCursorNode().target}]`,
    args: (a) => (a === null ? null : [tuiCursorNode().target, a.trim()]),
  },
};

type TuiOpOutcome = { applied: false } | { applied: true; focusSession?: string };

/** TUI submit → runRegistryOp 同源执行 */
function runTuiOp(mirror: string, answer: string | null): TuiOpOutcome {
  const h = TUI_PROMPT_HANDLERS[mirror];
  const args = h?.args(answer) ?? null;
  if (!args) return { applied: false };
  try {
    const msg = runRegistryOp(mirror, args);
    if (mirror === "new-session") {
      const m = msg.match(/^session (\S+)/);
      return { applied: true, focusSession: m?.[1] };
    }
    return { applied: true };
  } catch {
    return { applied: false };
  }
}

function tuiOpSubmit(mirror: string, answer: string | null): void {
  if (mirror === "remark" && answer === null) {
    render();
    return;
  }
  const outcome = runTuiOp(mirror, answer);
  if (outcome.applied) {
    refreshAll();
    if (outcome.focusSession) {
      const idx = state.tree.findIndex((n) => n.type === "session" && n.target === outcome.focusSession);
      if (idx >= 0) state.cursor = idx;
    }
    refreshPreview();
    return;
  }
  if (mirror === "new-session" || mirror === "new-window") refreshPreview();
}

/** buildTuiPrompts 的公共单元:一条 mirror entry → 一条 TuiPromptSpec,ops/userOpts 两张表同形复用 */
function pushPrompts(prompts: TuiPromptSpec[], mirrorMap: Record<string, TuiMirrorEntry>): void {
  for (const [mirror, meta] of Object.entries(mirrorMap)) {
    const h = TUI_PROMPT_HANDLERS[mirror];
    if (!h) throw new Error(`TUI_PROMPT_HANDLERS 缺少 ${mirror}`);
    prompts.push({
      key: meta.key,
      help: meta.help,
      mirror,
      needsTree: meta.needsTree,
      prompt: h.prompt,
      submit: (answer) => tuiOpSubmit(mirror, answer),
    });
  }
}

function buildTuiPrompts(): TuiPromptSpec[] {
  const prompts: TuiPromptSpec[] = [];
  pushPrompts(prompts, TUI_CLI_MIRROR.ops);
  pushPrompts(prompts, TUI_CLI_MIRROR.userOpts);
  return prompts;
}

/** assertTuiCliMirror 的公共单元:一张 mirror 表 → 校验其 key 均在 knownKeys 里且有对应 handler */
function assertMirrorTableComplete(
  mirrorLabel: string, mirrorMap: Record<string, unknown>,
  knownLabel: string, knownKeys: Record<string, unknown>,
): void {
  for (const key of Object.keys(mirrorMap)) {
    if (!(key in knownKeys)) throw new Error(`${mirrorLabel} 引用未知 ${knownLabel}: ${key}`);
    const h = TUI_PROMPT_HANDLERS[key];
    if (!h?.prompt || !h.args) throw new Error(`TUI_PROMPT_HANDLERS 缺少 ${key}`);
  }
}

function assertTuiCliMirror(): void {
  assertMirrorTableComplete("TUI_CLI_MIRROR.ops", TUI_CLI_MIRROR.ops, "CLI_OPS", CLI_OPS);
  assertMirrorTableComplete("TUI_CLI_MIRROR.userOpts", TUI_CLI_MIRROR.userOpts, "CLI_USER_OPTS", CLI_USER_OPTS);
}

type FleetViewSpec = {
  summary: string;
  usage: string;
  aliases?: string[];
  print: (snap: CliFleetSnapshot) => void;
};

function printFleetList(snap: CliFleetSnapshot): void {
  for (const row of snap.tree) {
    if (row.type === "session") {
      const rk = row.remark ? `  ${row.remark}` : "";
      cliWriteStdout(`${row.target}${rk}  (${row.windowCount} windows)\n`);
    } else {
      const rk = row.remark ? `  ${row.remark}` : "";
      const ag = row.agent ? `  agent:${row.agent}` : "";
      const ur = row.unread > 0 ? `  unread:${row.unread}` : "";
      const tail = row.previewLastLine ? `  | ${row.previewLastLine.slice(0, 80)}` : "";
      cliWriteStdout(`  ${row.target}${ag}${rk}${ur}${tail}\n`);
    }
  }
}

function printFleetStatus(snap: CliFleetSnapshot): void {
  for (const row of snap.tree) {
    if (row.type === "session") {
      cliWriteStdout(`▣ ${row.session}  (${row.windowCount})\n`);
    } else {
      const dot = row.unread > 0 ? "●" : "○";
      const ur = row.unread > 0 ? ` rd:${row.unread}` : "";
      const ph = row.placeholders;
      cliWriteStdout(
        `  ${dot} ${row.session}:${row.windowIndex} ${row.windowName}${row.agent ? ` @${row.agent}` : ""}${ur}`
        + ` lv:${ph.lvl} age:${ph.age} act:${ph.act}\n`,
      );
    }
  }
}

const CLI_FLEET_VIEWS: Record<string, FleetViewSpec> = {
  list: {
    summary: "列出 session/window、agent、未读、末行预览",
    usage: "[--lines N] [--json]",
    aliases: ["tree", "ls"],
    print: printFleetList,
  },
  status: {
    summary: "车队快照（驾驶表同源字段，默认文本）",
    usage: "[--lines N] [--json]",
    aliases: ["fleet", "snap"],
    print: printFleetStatus,
  },
};

// PART:cli-router

function cliUsage(cmd: CliCommand, sub?: CliCommand): string {
  const leaf = sub ?? cmd;
  const head = sub ? `${cmd.name} ${leaf.name}` : cmd.name;
  return leaf.usage ? `${head} ${leaf.usage}` : head;
}

function formatCliAlias(cmd: CliCommand): string {
  return cmd.aliases?.length ? ` (${cmd.aliases.join(", ")})` : "";
}

/** 单条命令 help 行（含子命令树） */
function formatCliHelpEntry(cmd: CliCommand, indent = "  "): string[] {
  const lines = [`${indent}${cmd.name}${formatCliAlias(cmd)}`, `${indent}  ${cmd.summary}`];
  if (cmd.children?.length) {
    const kids = cmd.children;
    for (let i = 0; i < kids.length; i++) {
      const sub = kids[i]!;
      const last = i === kids.length - 1;
      const branch = last ? "└─" : "├─";
      const cont = last ? " " : "│";
      lines.push(`${indent}  ${branch} ${sub.name}${formatCliAlias(sub)}  — ${sub.summary}`);
      lines.push(`${indent}  ${cont}   usage: ${CLI_BIN} ${cliUsage(cmd, sub)}`);
    }
    lines.push(`${indent}  note: 省略子命令 → ${cliUsage(cmd)}  [兼容]`);
  } else if (cmd.usage) {
    lines.push(`${indent}  usage: ${CLI_BIN} ${cliUsage(cmd)}`);
  }
  return lines;
}

function matchCliName(cmd: CliCommand, name: string): boolean {
  return cmd.name === name || (cmd.aliases?.includes(name) ?? false);
}

function cliFailUsage(usage: string): number {
  cliWriteStderr(`usage: ${CLI_BIN} ${usage}\n`);
  return 2;
}

function cliRespond(ctx: CliCtx, data: unknown, text: () => void): number {
  if (ctx.json) {
    cliWriteJson(data);
    return 0;
  }
  text();
  return 0;
}

function cliRequireWindow(node: TreeNode, label: string): number | null {
  if (node.type !== "window") return cliError(`${label} 需要 window spec`);
  return null;
}

function cliUserOptGet(optName: string, ctx: CliCtx): number {
  const spec = CLI_USER_OPTS[optName];
  if (!ctx.rest[0]) return cliFailUsage(`${optName} get ${spec.getUsage}`);
  const { node } = parseTargetSpec(ctx.rest[0]);
  if (spec.scope === "window") {
    const err = cliRequireWindow(node, optName);
    if (err !== null) return err;
  }
  const v = spec.read(node);
  cliWriteStdout(v ? `${v}\n` : "\n");
  return 0;
}

function cliUserOptSet(optName: string, ctx: CliCtx): number {
  const spec = CLI_USER_OPTS[optName];
  const minArgs = spec.setJoinRest ? 1 : 2;
  if (ctx.rest.length < minArgs) return cliFailUsage(`${optName} set ${spec.setUsage}`);
  const args = spec.setJoinRest ? [ctx.rest[0], ctx.rest.slice(1).join(" ")] : ctx.rest;
  try {
    cliWriteStdout(runRegistryOp(optName, args) + "\n");
  } catch (e: unknown) {
    return cliCatch(e);
  }
  return 0;
}

function cliUserOptLegacy(optName: string, ctx: CliCtx): number {
  const sub = ctx.rest[0];
  if (sub === "get" || sub === "show" || sub === "read") {
    return cliUserOptGet(optName, { ...ctx, rest: ctx.rest.slice(1) });
  }
  if (sub === "set" || sub === "write") {
    return cliUserOptSet(optName, { ...ctx, rest: ctx.rest.slice(1) });
  }
  if (optName === "remark") return cliUserOptSet(optName, ctx);
  return cliFailUsage(`${optName} set|get …`);
}

function cliOp(opName: string, ctx: CliCtx): number {
  const spec = CLI_OPS[opName];
  const { positional } = parseCliFlags(ctx.rest);
  if (positional.length < spec.arity) return cliFailUsage(`${opName} ${spec.usage}`);
  try {
    cliWriteStdout(runRegistryOp(opName, positional) + "\n");
  } catch (e: unknown) {
    return cliCatch(e);
  }
  return 0;
}

function cliFleet(viewName: string, ctx: CliCtx): number {
  const spec = CLI_FLEET_VIEWS[viewName];
  const { flags } = parseCliFlags(ctx.rest);
  const previewLines = parseInt(flags.lines || "1", 10) || 1;
  const snap = buildFleetSnapshot(previewLines);
  return cliRespond(ctx, snap, () => spec.print(snap));
}

function buildLeafCmd(name: string, spec: LeafCmdSpec): CliCommand {
  return {
    name,
    aliases: spec.aliases,
    summary: spec.summary,
    usage: spec.usage,
    run: spec.run,
    needsTmux: spec.needsTmux,
    helpHidden: spec.helpHidden,
  };
}

function cliOs(ctx: CliCtx): number {
  const sub = ctx.rest[0];
  if (!sub || sub === "watch") {
    startTui({ osMode: true });
    return 0;
  }
  const args = ctx.json ? ["--json", ...ctx.rest] : ctx.rest;
  const out = runOsCli(args);
  if (out.json !== undefined) cliWriteJson(out.json);
  else if (out.text) {
    if (out.code === 0) cliWriteStdout(out.text);
    else cliWriteStderr(out.text);
  }
  return out.code;
}

function buildUserOptGroup(name: string, spec: UserOptSpec): CliCommand {
  return {
    name,
    summary: spec.summary,
    run: (ctx) => cliUserOptLegacy(name, ctx),
    needsTmux: true,
    children: [
      {
        name: "set",
        aliases: ["write"],
        summary: `设置 @${name}`,
        usage: spec.setUsage,
        run: (ctx) => cliUserOptSet(name, ctx),
      },
      {
        name: "get",
        aliases: ["show", "read"],
        summary: `读取 @${name}`,
        usage: spec.getUsage,
        run: (ctx) => cliUserOptGet(name, ctx),
      },
    ],
  };
}

function buildOpCommand(name: string, spec: OpSpec): CliCommand {
  return {
    name,
    aliases: spec.aliases,
    summary: spec.summary,
    usage: spec.usage,
    run: (ctx) => cliOp(name, ctx),
    needsTmux: true,
  };
}

function buildFleetCommand(name: string, spec: FleetViewSpec): CliCommand {
  return {
    name,
    aliases: spec.aliases,
    summary: spec.summary,
    usage: spec.usage,
    run: (ctx) => cliFleet(name, ctx),
    needsTmux: true,
  };
}

function isCliInvocation(argv: string[]): boolean {
  const head = argv[2];
  if (!head) return false;
  return CLI_ROOT.some((c) => matchCliName(c, head));
}

function printInspectText(info: CliInspectResult): void {
  cliWriteStdout(`${info.type} ${info.target}\n`);
  if (info.remark) cliWriteStdout(`remark: ${info.remark}\n`);
  if (info.agent) cliWriteStdout(`agent: ${info.agent}  unread:${info.unread ?? 0}\n`);
  if (info.windowCount !== undefined) cliWriteStdout(`windows: ${info.windowCount}\n`);
  if (info.placeholders && info.type === "window") {
    const ph = info.placeholders;
    cliWriteStdout(`cabin: ${ph.st}  auto: ${ph.lvl}  age: ${ph.age}  act: ${ph.act}\n`);
  }
  if (info.preview?.lastLine) cliWriteStdout(`last: ${info.preview.lastLine}\n`);
}

// ════════════════════════════════════════════════════════════════════
// PART:driving — 主动驾驶动词（帧分析委托 fleet-analyzer.ts）
//
// 帧忙闲判定 / agent 检测 / 格式化 → fleet-analyzer.ts（单一真源）。
// 本 section 保留：DriveStatus 接口、drvComposer*、drvSend、drvWaitIdle、drvRecover 等操控逻辑。
// 全部经 tmuxApi 后端（rmux 默认 / tmux 回退）。

interface DriveStatus {
  target: string; comm: string; state: "busy" | "idle" | "unknown";
  verb?: string; elapsed?: string; tokens?: string; model?: string; ctxPct?: number;
  lastResult?: string; tailLine?: string;
}

// 仅本地引用的常量（fleet-analyzer 不涵盖的操控逻辑）
const DRV_HR_LINE = /^[\s─━╌╍┄┅]+$/;
const DRV_STATUS_LINE = /(bypass permissions|shift\+tab|已跳过工具批准|YOLO|ctx\s*\(?\d+%|to compact|context used|⏵⏵|effort\s+auto|本次命中)/i;
const DRV_NODE_TUI = /^(claude|node|cursor|codex|kimi)$/i;

// ── bridge：委托 fleet-analyzer ──

/**
 * drv族(本地tmux)与super族(-L独立socket)的唯一差异是"走哪个tmux句柄"。
 * 抽出这四个原子操作作为可替换后端,drv族与driveSubmitVerify 默认走 DEFAULT_IO(本地tmuxApi),
 * super 侧后续(P0-1 commit#2)组装同形的 SUPER_IO 传入,复用同一套 capture/analyze/等待/验证逻辑,
 * 不必维护两份几乎相同的函数族。
 */
type DrvIo = {
  capture(target: string, lines?: number): string;
  comm(target: string): string;
  /** load-buffer+paste-buffer,不发 Enter(是否/何时 Enter 由调用方决定) */
  paste(target: string, text: string): void;
  enter(target: string): void;
};

const DEFAULT_IO: DrvIo = {
  capture: (target, lines = 60) => captureFrame(tmuxApi, target, lines),
  comm: (target) => getPaneInfo(tmuxApi, target).comm,
  paste: (target, text) => injectToWindow(target, text, { enter: false }),
  enter: (target) => tmuxApi.sendKeysEnter(target),
};

function drvCapture(target: string, lines = 60, io: DrvIo = DEFAULT_IO): string {
  return io.capture(target, lines);
}
function drvPaneComm(target: string, io: DrvIo = DEFAULT_IO): string {
  return io.comm(target);
}
function drvAgentTargets(): string[] {
  return listAgentTargets(tmuxApi);
}
function drvLooksCursor(frame: string): boolean {
  return looksLikeCursor(frame);
}
function drvInputBandHas(frame: string, probe: string, botN = 6): boolean {
  return inputBandHas(frame, probe, botN);
}
function drvFrameIsBusy(all: string[]): boolean {
  const frame = all.join("\n");
  const r = analyzeFrame("bridge", "?", frame, 18);
  return r.ok && r.value.state === "busy";
}
function drvAnalyze(target: string, lines = 18, io: DrvIo = DEFAULT_IO): DriveStatus {
  const comm = drvPaneComm(target, io);
  let frame = "";
  try { frame = drvCapture(target, 60, io); } catch { return { target, comm, state: "unknown" }; }
  if (!frame) return { target, comm, state: "unknown" };
  const r = analyzeFrame(target, comm, frame, lines);
  if (!r.ok) return { target, comm, state: "unknown" };
  return { target, comm, ...r.value };
}
function drvFmtStatus(s: DriveStatus): string {
  return formatDigestRow(s as any);
}
function drvSendKey(target: string, key: string): void {
  tmuxApi.rawSpawnSync(["send-keys", "-t", target, key]);
}

// composer 输入行前缀：codex=`›` / cursor=`→` / claude=`❯`/`>` / reasonix=`»`。
const DRV_COMPOSER_PROMPT = /^\s*[›→❯»>]\s/;

// 定位 composer 输入行(末 ~10 行内最后一条带 prompt 前缀的行)。提交后该行回到占位/空。
function drvComposerLine(frame: string): string | null {
  const lines = frame.replace(/\s+$/g, "").split("\n");
  for (let i = lines.length - 1; i >= 0 && i >= lines.length - 10; i--) {
    if (DRV_COMPOSER_PROMPT.test(lines[i])) return lines[i];
  }
  return null;
}

// probe 是否仍**在 composer 输入行内**(权威:区分"仍卡输入框"vs"已提交进历史气泡")。
// 找不到 composer prompt 行 → 退化到底带含 probe。
function drvComposerHasProbe(frame: string, probe: string): boolean {
  if (!probe) return false;
  const cl = drvComposerLine(frame);
  if (cl !== null) return cl.includes(probe);
  return drvInputBandHas(frame, probe);
}

// 等 paste 渲染进 composer(慢 TUI 如 cursor/codex：立刻发 Enter 会被吞)：轮询 composer 含 probe,最多 waitMs。
function drvWaitRender(target: string, probe: string, waitMs = 1800, io: DrvIo = DEFAULT_IO): boolean {
  if (!probe) return true;
  const t0 = Date.now();
  while (Date.now() - t0 < waitMs) {
    if (drvComposerHasProbe(drvCapture(target, 60, io), probe)) return true;
    Bun.sleepSync(200);
  }
  return false;
}

// codex/cursor send：Enter 后 busy 常瞬抖→须连续多采样确认真提交（纯采样，零前景输出）
function drvVerifyNodeSubmit(target: string, probe: string, preHadProbe: boolean, comm = "", io: DrvIo = DEFAULT_IO): "busy" | "cleared" | "" {
  const SAMPLES = 4, GAP_MS = 500, NEED = 2;
  let busyStreak = 0;
  for (let i = 0; i < SAMPLES; i++) {
    if (drvAnalyze(target, 18, io).state === "busy") { busyStreak++; if (busyStreak >= NEED) return "busy"; }
    else busyStreak = 0;
    if (i < SAMPLES - 1) Bun.sleepSync(GAP_MS);
  }
  if (preHadProbe) {
    let clearStreak = 0;
    for (let i = 0; i < SAMPLES; i++) {
      if (!drvInputBandHas(drvCapture(target, 60, io), probe)) { clearStreak++; if (clearStreak >= NEED) return "cleared"; }
      else clearStreak = 0;
      if (i < SAMPLES - 1) Bun.sleepSync(GAP_MS);
    }
  }
  // task#19: kimi composer 是输入边框盒(非 DRV_COMPOSER_PROMPT 单行提示符), preHadProbe 常测不到
  // 导致上面 preHadProbe 段整段被跳过, 即便消息已真送达处理完也误判失败。
  // 仅对 kimi 加一条独立兜底(范围收窄到本 TUI, 不影响 claude/cursor/codex 既有判据):
  // 连续 NEED 次采样都非 busy 且探针不在底部输入带 -> 判定已提交清空。
  if (/^kimi$/i.test(comm)) {
    let idleStreak = 0;
    for (let i = 0; i < SAMPLES; i++) {
      const st = drvAnalyze(target, 18, io).state;
      if (st !== "busy" && !drvInputBandHas(drvCapture(target, 60, io), probe)) {
        idleStreak++;
        if (idleStreak >= NEED) return "cleared";
      } else idleStreak = 0;
      if (i < SAMPLES - 1) Bun.sleepSync(GAP_MS);
    }
  }
  return "";
}

type DriveSubmitVerifyResult = { submitNote: string; submitFailed: boolean };

/**
 * send/envelope 共用的"慢渲染稳提交"注入+验证:
 * nodeTui(codex/cursor/kimi等) 走 paste 不立即 Enter(会被吞)→等渲染→Enter→连续采样验证提交，
 * 未提交则拉到 ~800ms 间隔重试 Enter；非 nodeTui(claude等) 直接注入立即 Enter(不回归)。
 * target 为 injectToWindow 用的原始 spec，resolved 为已解析的 pane target(用于 capture/verify)。
 */
function driveSubmitVerify(target: string, resolved: string, payload: string, io: DrvIo = DEFAULT_IO): DriveSubmitVerifyResult {
  const comm = drvPaneComm(resolved, io);
  let preFrame = "";
  try { preFrame = drvCapture(resolved, 60, io); } catch { /* 抓不到帧→按非 nodeTui 处理 */ }
  const isNodeTui = DRV_NODE_TUI.test(comm) || drvLooksCursor(preFrame);
  io.paste(target, payload);
  let submitNote = ""; let submitFailed = false;
  if (!isNodeTui) {
    // injectToWindow 原实现内部会自行 resolveInputPaneTarget(resolveTarget(...)) 再发 Enter，
    // 等价于调用方已算好的 resolved——用 resolved 而非原始 target，保持行为不变。
    io.enter(resolved);
  } else {
    const probe = payload.trim().split("\n")[0].slice(0, 24);
    const rendered = drvWaitRender(resolved, probe, 1800, io);
    const preHadProbe = rendered || (!!probe && drvComposerHasProbe(drvCapture(resolved, 60, io), probe));
    io.enter(resolved);
    let why = drvVerifyNodeSubmit(resolved, probe, preHadProbe, comm, io);
    for (let i = 0; i < 3 && !why; i++) {
      io.enter(resolved);
      Bun.sleepSync(800);
      why = drvVerifyNodeSubmit(resolved, probe, preHadProbe, comm, io);
    }
    const how = DRV_NODE_TUI.test(comm) ? "" : ":cursor帧判";
    if (why) submitNote = ` [submitted✓:${why === "busy" ? "BUSY" : "composer清空"}${how}]`;
    else { submitNote = " [submit-failed✗:未验证到 BUSY/composer 仍滞留]"; submitFailed = true; }
  }
  return { submitNote, submitFailed };
}

// 输入：paste-buffer 法（零转义 + pre-check IDLE + BUSY上升沿确认 + 单独 Enter）
// v2: 不再逐 TUI 适配文本渲染差异。统一用 BUSY 上升沿做提交确认。
function drvSend(target: string, text: string, noEnter = false): { ok: boolean; preIdle: boolean; delivered: boolean } {
  // Phase A: pre-check — agent must be IDLE before we paste
  const preStatus = drvAnalyze(target, 18);
  const preIdle = preStatus.state === "idle";
  if (!preIdle) {
    return { ok: false, preIdle: false, delivered: false };
  }

  // Phase B: deliver — paste-buffer + Enter, no text-probe verification
  tmuxApi.loadBufferFromText(text);
  tmuxApi.pasteBuffer(target);
  if (noEnter) {
    return { ok: true, preIdle: true, delivered: true };
  }
  Bun.sleepSync(400);
  tmuxApi.sendKeysEnter(target);

  // Phase C: confirm — BUSY 上升沿(IDLE→BUSY) 或 composer 清空
  // 等最多 4s，轮询 BUSY 或 composer 清空。没看到就重发一次 Enter。
  let delivered = false;
  for (let attempt = 0; attempt < 2 && !delivered; attempt++) {
    if (attempt > 0) {
      tmuxApi.sendKeysEnter(target);
      Bun.sleepSync(800);
    }
    const t0 = Date.now();
    while (Date.now() - t0 < 4000) {
      Bun.sleepSync(500);
      const frame = drvCapture(target);
      const lines = frame.replace(/\s+$/g, "").split("\n").filter(l => l.trim());
      // Signal 1: BUSY (unified across all 4 agent types)
      if (drvFrameIsBusy(lines)) { delivered = true; break; }
      // Signal 2: composer cleared (text consumed from input area into history)
      const cl = drvComposerLine(frame);
      if (cl !== null) {
        const content = cl.replace(/^\s*[›→❯»>]\s?/, "").trim();
        if (!content || content === "Add a follow-up" || content === "Type your message") {
          delivered = true; break;
        }
      }
      // Signal 3: transcript show new user turn (agent started processing)
      if (frame.includes("⎿  Read") || frame.includes("● Thinking") || frame.includes("✻ Determining")) {
        delivered = true; break;
      }
    }
  }

  return { ok: true, preIdle: true, delivered };
}

// 输入框残留检测：TUI 输入框被框线(───/━━━)夹住，框内非空且非状态/框线行即残留。
function drvInputResidue(frame: string, botN = 12): string {
  const all = frame.replace(/\s+$/g, "").split("\n");
  const lines = all.slice(-botN);
  let lastHr = -1;
  for (let i = lines.length - 1; i >= 0; i--) if (DRV_HR_LINE.test(lines[i]) && lines[i].trim().length >= 4) { lastHr = i; break; }
  let prevHr = -1;
  for (let i = lastHr - 1; i >= 0; i--) if (DRV_HR_LINE.test(lines[i]) && lines[i].trim().length >= 4) { prevHr = i; break; }
  const band = lastHr >= 0 ? lines.slice(prevHr + 1, lastHr) : lines;
  for (const l of band) {
    if (DRV_HR_LINE.test(l) || DRV_STATUS_LINE.test(l)) continue;
    const stripped = l.replace(/^\s*[❯›>]\s?/, "").trim();
    if (stripped.length > 0) return stripped;
  }
  return "";
}

// interrupt：发 Esc 让正在跑的 agent 停下，验证转 idle(仅 busy 时发)。
function drvInterrupt(target: string, timeoutS = 30): { wasBusy: boolean; nowIdle: boolean; before?: string; after: DriveStatus } {
  const before = drvAnalyze(target);
  if (before.state !== "busy") return { wasBusy: false, nowIdle: before.state === "idle", before: before.verb, after: before };
  for (let i = 0; i < 2; i++) { drvSendKey(target, "Escape"); Bun.sleepSync(500); }
  const t0 = Date.now();
  while ((Date.now() - t0) / 1000 < timeoutS) {
    const s = drvAnalyze(target);
    if (s.state !== "busy") return { wasBusy: true, nowIdle: s.state === "idle", before: before.verb, after: s };
    Bun.sleepSync(1500);
  }
  return { wasBusy: true, nowIdle: false, before: before.verb, after: drvAnalyze(target) };
}

// clear：清空输入框残留文本(Ctrl-U 删到行首；多行须多发)，验证空。
function drvClearInput(target: string, maxRounds = 6): { before: string; after: string; cleared: boolean } {
  const before = drvInputResidue(drvCapture(target));
  if (!before) return { before: "", after: "", cleared: true };
  for (let i = 0; i < maxRounds; i++) {
    drvSendKey(target, "C-u");
    Bun.sleepSync(350);
    if (!drvInputResidue(drvCapture(target))) break;
  }
  const after = drvInputResidue(drvCapture(target));
  return { before, after, cleared: after.length === 0 };
}

// recover：interrupt + clear + 验证 idle(长跑卡住/残留输入的标准恢复流)。
function drvRecover(target: string): { interrupt: ReturnType<typeof drvInterrupt>; clear: ReturnType<typeof drvClearInput>; idle: boolean } {
  const i = drvInterrupt(target);
  const c = drvClearInput(target);
  const s = drvAnalyze(target);
  return { interrupt: i, clear: c, idle: s.state === "idle" && c.cleared };
}

// 主动等待：内部轮询到 idle 再返回(一次调用替 N 次抓帧)。
// graceMs: dispatch 后 agent 尚未 spin-up 时的瞬时 idle 是"还没开始"非"已完成"——
// 在见到首次 busy 之前的 grace 窗口内不认 idle，避免 wait/drive 秒返假 idle。
function drvWaitIdle(target: string, timeoutS = 600, quietRounds = 2, intervalMs = 4000, graceMs = 8000): DriveStatus & { waitedSec: number; timedOut: boolean; sawBusy: boolean } {
  const comm = drvPaneComm(target);
  const nodeTui = DRV_NODE_TUI.test(comm);
  const pollMs = nodeTui ? 500 : intervalMs;
  const idleNeed = nodeTui ? Math.max(quietRounds, 4) : quietRounds;
  const t0 = Date.now(); let prevTail = ""; let quiet = 0; let idleStreak = 0; let sawBusy = false;
  while ((Date.now() - t0) / 1000 < timeoutS) {
    const s = drvAnalyze(target);
    const tail = s.tailLine || "";
    if (s.state === "busy") { sawBusy = true; idleStreak = 0; quiet = 0; }
    const inGrace = !sawBusy && (Date.now() - t0) < graceMs;
    if (s.state === "idle" && !inGrace) {
      if (nodeTui) {
        idleStreak++;
        if (idleStreak >= idleNeed) return { ...s, waitedSec: Math.round((Date.now() - t0) / 1000), timedOut: false, sawBusy };
      } else {
        if (tail === prevTail) quiet++; else quiet = 1;
        if (quiet >= quietRounds) return { ...s, waitedSec: Math.round((Date.now() - t0) / 1000), timedOut: false, sawBusy };
      }
    } else if (s.state !== "idle" || inGrace) { idleStreak = 0; quiet = 0; }
    prevTail = tail;
    Bun.sleepSync(pollMs);
  }
  return { ...drvAnalyze(target), waitedSec: Math.round((Date.now() - t0) / 1000), timedOut: true, sawBusy };
}

function drvResolveText(raw: string): string {
  // 三种取文本方式复用同一发送路：内联文本 / @文件 / - (stdin/heredoc)
  if (raw === "-") {
    // fd 0 读全部 stdin（heredoc/管道）；内容字面，不经 shell 展开
    const s = readFileSync(0, "utf8");
    if (s.trim() === "") throw new Error("stdin 为空：- 取文本但无输入(别静默发空)");
    return s;
  }
  if (!raw?.startsWith("@")) return raw;
  let p = raw.slice(1);
  if (p.startsWith("~")) p = join(homedir(), p.slice(1));
  if (!existsSync(p)) throw new Error(`@文件不存在: ${raw.slice(1)}`);
  return readFileSync(p, "utf8");
}

// ── 驾驶动词 CLI 处理器 ──────────────────────────────────────────────

function cliDriveFleet(ctx: CliCtx): number {
  const stats = drvAgentTargets().map((t) => drvAnalyze(t));
  return cliRespond(ctx, stats, () => cliWriteStdout((stats.map(drvFmtStatus).join("\n") || "(无 agent 窗口)") + "\n"));
}

function cliDriveStatus(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("dstatus <spec> [--lines N] [--json]");
  const s = drvAnalyze(resolveTarget(positional[0]), Number(flags.lines || 18));
  return cliRespond(ctx, s, () => cliWriteStdout(drvFmtStatus(s) + "\n"));
}

function cliRead(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("read <spec> [--tail N] [--head N]");
  let out = drvCapture(resolveTarget(positional[0]), 200).replace(/\s+$/g, "");
  const ls = out.split("\n");
  if (flags.head) out = ls.slice(0, Number(flags.head)).join("\n");
  else if (flags.tail) out = ls.slice(-Number(flags.tail)).join("\n");
  cliWriteStdout(out + "\n");
  return 0;
}

function cliInterrupt(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("interrupt <spec> [--timeout S]");
  const r = drvInterrupt(resolveTarget(positional[0]), Number(flags.timeout || 30));
  if (ctx.json) cliWriteJson(r);
  else cliWriteStdout((r.wasBusy ? `interrupted (was BUSY ${r.before || ""}) → ${r.nowIdle ? "IDLE ✓" : "still BUSY ✗"}  «${r.after.tailLine || ""}»` : `noop (已 ${r.after.state}, 无需中断)`) + "\n");
  return r.wasBusy && !r.nowIdle ? 2 : 0;
}

function cliClear(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("clear <spec>");
  const r = drvClearInput(resolveTarget(positional[0]));
  if (ctx.json) cliWriteJson(r);
  else cliWriteStdout((r.before ? `cleared: «${r.before.slice(0, 60)}» → ${r.cleared ? "空 ✓" : "仍残留«" + r.after.slice(0, 40) + "» ✗"}` : `noop (输入框已空)`) + "\n");
  return r.cleared ? 0 : 4;
}

function cliRecover(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("recover <spec>");
  const r = drvRecover(resolveTarget(positional[0]));
  if (ctx.json) cliWriteJson(r);
  else cliWriteStdout(`recover: interrupt=${r.interrupt.wasBusy ? (r.interrupt.nowIdle ? "stopped✓" : "FAIL✗") : "noop"} clear=${r.clear.cleared ? "空✓" : "FAIL✗"} → ${r.idle ? "READY(idle+空)✓" : "未就绪✗"}\n`);
  return r.idle ? 0 : 2;
}

function cliWait(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("wait <spec> [--timeout S] [--quiet-rounds N]");
  const s = drvWaitIdle(resolveTarget(positional[0]), Number(flags.timeout || 600), Number(flags["quiet-rounds"] || 2));
  if (ctx.json) cliWriteJson(s);
  else cliWriteStdout(`${s.timedOut ? "TIMEOUT" : "IDLE"} after ${s.waitedSec}s — ${drvFmtStatus(s)}\n`);
  return s.timedOut ? 2 : 0;
}

function cliDrive(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (positional.length < 2) return cliFailUsage("drive <spec> <task|@file> [--timeout S]");
  const target = resolveTarget(positional[0]);
  const r = drvSend(target, drvResolveText(positional.slice(1).join(" ")), false);
  if (!r.preIdle) { cliWriteStderr("目标非 IDLE,拒绝发送(避免对 BUSY agent 盲注)\n"); return 3; }
  if (!r.delivered) { cliWriteStderr("paste+Enter 后未检测到 BUSY/composer清空,可能未提交\n"); return 4; }
  Bun.sleepSync(2000);
  const s = drvWaitIdle(target, Number(flags.timeout || 600), 2);
  if (ctx.json) cliWriteJson(s);
  else cliWriteStdout(`${s.timedOut ? "TIMEOUT" : "DONE"} after ${s.waitedSec}s\n${drvFmtStatus(s)}\n`);
  return s.timedOut ? 2 : 0;
}

const CLI_DRIVE_CMDS: Record<string, LeafCmdSpec> = {
  drive: { summary: "send+wait+结果 digest(一次调用驱动一轮)", usage: "<spec> <task|@file> [--timeout S] [--json]", run: cliDrive },
  wait: { summary: "内部轮询到 idle 再返回(替反复抓帧)", usage: "<spec> [--timeout S] [--quiet-rounds N] [--json]", run: cliWait },
  interrupt: { summary: "中断正在跑的 agent(Esc)+验证转 idle", usage: "<spec> [--timeout S] [--json]", aliases: ["int"], run: cliInterrupt },
  clear: { summary: "清空输入框残留(Ctrl-U)+验证空", usage: "<spec> [--json]", run: cliClear },
  recover: { summary: "interrupt+clear+验证 idle(卡住/残留标准恢复)", usage: "<spec> [--json]", run: cliRecover },
  read: { summary: "抓帧→stdout(--tail N/--head N)", usage: "<spec> [--tail N] [--head N]", run: cliRead },
  dfleet: { summary: "全 agent 窗口驾驶 digest(busy/idle+verb+model+ctx)", usage: "[--json]", aliases: ["fl"], run: cliDriveFleet },
  dstatus: { summary: "单窗口驾驶 digest(busy/idle+verb+elapsed+model+ctx+lastResult)", usage: "<spec> [--lines N] [--json]", aliases: ["ds"], run: cliDriveStatus },
};

function cliInspect(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("inspect <spec> [--lines N] [--json]");
  const previewLines = parseInt(flags.lines || String(PREVIEW_LINES), 10) || PREVIEW_LINES;
  const info = buildInspectResult(positional[0], previewLines);
  return cliRespond(ctx, info, () => printInspectText(info));
}

function cliCapture(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("capture <spec> [lines] [--json]");
  const lines = positional[1] ? parseInt(positional[1], 10) : PREVIEW_LINES;
  const n = isNaN(lines) ? PREVIEW_LINES : lines;
  const spec = positional[0];
  const target = resolveTarget(spec);
  const text = tmuxApi.capturePaneText(target, n);
  if (ctx.json) {
    cliWriteJson({
      version: TUI_CONFIG.VERSION,
      spec,
      target,
      lines: n,
      text,
      lastLine: lastLineFromCaptureText(text),
    });
    return 0;
  }
  cliWriteStdout(text);
  return 0;
}

function cliSend(ctx: CliCtx): number {
  if (ctx.rest.length < 2) return cliFailUsage("send <spec> <text...|@file|->");
  const target = ctx.rest[0];
  const raw = ctx.rest.slice(1).join(" ");
  let body: string;
  try {
    body = drvResolveText(raw);
  } catch (e: unknown) {
    return cliCatch(e);
  }
  // codex(node)/cursor 类 TUI 检测：comm(node/cursor/codex) 或帧特征(cursor composer `→ ` 前缀,
  // cursor comm 常显示为 bash 判不到)。命中则走"慢渲染稳提交"路:先 paste 不立刻 Enter(会被吞)→等渲染→Enter→验证。
  const resolved = resolveInputPaneTarget(resolveTarget(target));
  let submitNote = ""; let submitFailed = false;
  try {
    ({ submitNote, submitFailed } = driveSubmitVerify(target, resolved, body));
  } catch (e: unknown) {
    return cliCatch(e);
  }
  const src = raw === "-" ? " (from stdin)" : raw.startsWith("@") ? ` (from ${raw})` : "";
  cliWriteStdout(`sent → ${resolved}: ${body.length} chars${src}${submitNote}\n`);
  return submitFailed ? 3 : 0;
}

type EnvelopeFromIdentity = {
  ancestorWindowName?: string;
};

/**
 * envelope sender 身份链:
 *
 * | 优先级 | 来源 | 安全语义 |
 * | --- | --- | --- |
 * | 1 | 实时 `tmux list-panes -a` pane pid 表 + `/proc` PPid 祖先链 | 唯一可信来源；每次调用现场活算，零缓存 |
 * | reject | env/cache/fallback/user supplied names | 任何声明式 sender 都可能 stale 或冒名，全部忽略 |
 */
export function resolveEnvelopeFromIdentity(input: EnvelopeFromIdentity): string {
  return (input.ancestorWindowName || "").trim();
}

function parseProcParentPid(statusText: string): number | null {
  const m = statusText.match(/^PPid:\s+(\d+)$/m);
  if (!m) return null;
  const ppid = Number(m[1]);
  return Number.isFinite(ppid) && ppid > 0 ? ppid : null;
}

export function findTmuxAncestorWindowName(
  startPid: number,
  panePidToWindow: Map<number, string>,
  readStatus: (pid: number) => string | null = (pid) => {
    try { return readFileSync(`/proc/${pid}/status`, "utf8"); } catch { return null; }
  },
  maxDepth = 50,
): string {
  const seen = new Set<number>();
  let pid = startPid;
  for (let depth = 0; depth < maxDepth && pid > 1 && !seen.has(pid); depth++) {
    const win = panePidToWindow.get(pid);
    if (win) return win;
    seen.add(pid);
    const status = readStatus(pid);
    if (!status) break;
    const ppid = parseProcParentPid(status);
    if (!ppid) break;
    pid = ppid;
  }
  return "";
}

function listPanePidWindowMap(): Map<number, string> {
  const map = new Map<number, string>();
  const r = tmuxApi.rawSpawnSync(["list-panes", "-a", "-F", "#{pane_pid}|#{session_name}|#{window_name}"]) as {
    exitCode?: number;
    stdout?: Uint8Array;
  };
  if ((r.exitCode ?? 0) !== 0) return map;
  const out = Buffer.from(r.stdout ?? new Uint8Array()).toString("utf8");
  for (const line of out.split("\n")) {
    if (!line.trim()) continue;
    const [pidRaw, sess, ...nameParts] = line.split("|");
    const pid = Number(pidRaw);
    const winName = nameParts.join("|").trim();
    if (Number.isFinite(pid) && pid > 0 && sess && winName) map.set(pid, winName);
  }
  return map;
}

/**
 * 祖先链起点 pid：默认 process.pid（tmux pane 内直接调用）；
 * 若上游(如 mapp-http.ts 反查 HTTP 真实调用者)通过 MUX_CALLER_PID 声明了别的起点，
 * 仍须活算校验（存活 + /proc/<pid>/stat starttime 匹配，防 pid 复用冒名）才采信，
 * 校验失败一律回退 process.pid（daemon 自身脱离 tmux 会再降级 external，不伪造窗口）。
 */
function resolveAncestryStartPid(): number {
  const raw = process.env.MUX_CALLER_PID;
  if (!raw) return process.pid;
  const pid = Number.parseInt(raw, 10);
  if (!Number.isFinite(pid) || pid <= 0) return process.pid;
  try {
    process.kill(pid, 0);
  } catch {
    return process.pid;
  }
  const expectedStarttime = process.env.MUX_CALLER_PID_STARTTIME;
  if (expectedStarttime) {
    try {
      const stat = readFileSync(`/proc/${pid}/stat`, "utf8");
      const afterComm = stat.slice(stat.lastIndexOf(")") + 2);
      const actualStarttime = afterComm.split(" ")[19];
      if (actualStarttime !== expectedStarttime) return process.pid;
    } catch {
      return process.pid;
    }
  }
  return pid;
}

function resolveFromWindowName(): string {
  return resolveEnvelopeFromIdentity({
    ancestorWindowName: findTmuxAncestorWindowName(resolveAncestryStartPid(), listPanePidWindowMap()),
  });
}

function targetWindowName(target: string): string {
  const r = Bun.spawnSync([tmuxBin(), "display-message", "-p", "-t", target, "#W"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (r.exitCode !== 0) return "";
  return (r.stdout?.toString() ?? "").trim();
}

export function assertEnvelopeNotSelf(from: string, to: string): void {
  if (from && to && from === to) {
    throw new Error(
      `envelope: sender 与 receiver 不能是同一个窗口 '${from}'; ` +
      "自发消息请改用 drive 或 send",
    );
  }
}

function cliEnvelope(ctx: CliCtx): number {
  // mux envelope <spec> <title> <body...|@file|->
  // From 每次由实时 tmux pane 祖先链活算；不接受任何声明式 sender。
  const USAGE = "envelope <spec> <title> <body...|@file|->";
  if (ctx.rest.length < 3) return cliFailUsage(USAGE);
  const target = ctx.rest[0];
  const rest = ctx.rest.slice(1);
  let from = "";
  let title: string, bodyRaw: string;
  try {
    from = resolveFromWindowName();
  } catch (e) {
    return cliCatch(e);
  }
  if (!from) {
    // 调用者脱离 tmux 进程树(如守护化的 MCP shell 后端 PPid=1)：无可信 PID→pane 链。
    // 不再死胡同硬失败；也绝不伪造具体窗口名(防冒名铁律)——降级为非特定发送者 "external"
    // + stderr 告警，消息照常投递。要真实落款请在 tmux pane 内发送，或改用 `mux send`。
    from = "external";
    cliWriteStderr(
      "envelope: 无法从实时 tmux pane 祖先链推断发送窗口(调用者脱离 tmux 进程树); " +
      "以 from=external 降级投递(不伪造具体窗口)。真实落款请在 tmux pane 内发送或用 mux send。\n",
    );
  }
  title = rest[0];
  bodyRaw = rest.slice(1).join(" ");
  if (!bodyRaw) return cliFailUsage(USAGE);
  let body: string;
  try {
    body = drvResolveText(bodyRaw);
  } catch (e: unknown) {
    return cliCatch(e);
  }
  // To 从 spec 自动提取 window 名
  const to = target.includes(":") ? target.split(":").pop()! : target;
  const resolved = resolveInputPaneTarget(resolveTarget(target));
  const resolvedTo = targetWindowName(resolved) || to;
  try {
    assertEnvelopeNotSelf(from, resolvedTo);
  } catch (e: unknown) {
    return cliCatch(e);
  }
  // 提取目标会话 (1: 形式) 用于 ReplyCmd
  const sess = target.includes(":") ? target.split(":")[0] : "";
  const replySpec = sess ? `${sess}:${from}` : from;
  const replyCmd = `bin/mux envelope ${replySpec} "<title>" "<body>"`;
  const envelope = `${to}，你有新消息来自 ${from}, 标题：${title || "无主题"};内容：
${body}
[ReplyCmd] ${replyCmd}`;
  let submitNote = ""; let submitFailed = false;
  try {
    ({ submitNote, submitFailed } = driveSubmitVerify(target, resolved, envelope));
  } catch (e: unknown) {
    return cliCatch(e);
  }
  const src = bodyRaw.startsWith("@") ? ` (from ${bodyRaw})` : "";
  cliWriteStdout(`envelope → ${resolved}: ${envelope.length} chars${src}${submitNote}\n`);
  return submitFailed ? 3 : 0;
}

function cliPaste(ctx: CliCtx): number {
  if (ctx.rest.length < 2) return cliFailUsage("paste <spec> <file>");
  const target = ctx.rest[0];
  const file = ctx.rest[1];
  try {
    pasteFileToWindow(target, file);
  } catch (e: unknown) {
    return cliCatch(e);
  }
  cliWriteStdout(`pasted ${file} → ${resolveInputPaneTarget(resolveTarget(target))}\n`);
  return 0;
}

function cliSplit(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("split <spec>");
  try {
    const r = opSplit(positional[0]);
    if (ctx.json) cliWriteJson(r);
    else cliWriteStdout(`${r.created ? "split" : "already split"} → ${r.target} (${r.paneCount} panes)\n`);
    return 0;
  } catch (e: unknown) {
    return cliCatch(e);
  }
}

function cliUnsplit(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("unsplit <spec>");
  try {
    const r = opUnsplit(positional[0]);
    if (ctx.json) cliWriteJson(r);
    else cliWriteStdout(`${r.killed ? "unsplit" : "already single"} → ${r.target} (${r.paneCount} panes)\n`);
    return 0;
  } catch (e: unknown) {
    return cliCatch(e);
  }
}

function cliSuperInput(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  const target = positional[0];
  const sock = positional[1];
  const session = positional[2];
  if (!target || !sock || !session) {
    return cliFailUsage("super-input <target> <sock> <session>");
  }
  try {
    superTmuxBin();
    return runSuperInputLoop(target, sock, session);
  } catch (e: unknown) {
    return cliCatch(e);
  }
}

function cliSuperDeliver(ctx: CliCtx): number {
  const { positional } = parseCliFlags(ctx.rest);
  const target = positional[0];
  const sock = positional[1];
  const raw = positional[2];
  if (!target || !sock || !raw) {
    return cliFailUsage("super-deliver <target> <sock> <text...|@file|->");
  }
  let body: string;
  try {
    body = drvResolveText(raw);
  } catch (e: unknown) {
    return cliCatch(e);
  }
  try {
    superTmuxBin();
    superDeliverPayload(sock, target, body);
    return 0;
  } catch (e: unknown) {
    return cliCatch(e);
  }
}

function cliSuper(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (positional[0] === "--help" || positional[0] === "-h") return cliHelp();
  const session = positional[0] ?? SUPER_DEFAULT_SESSION;
  const sock = flags.sock ?? SUPER_DEFAULT_SOCK;
  const inputLines = flags.lines ? parseInt(flags.lines, 10) : SUPER_DEFAULT_INPUT_LINES;

  const validationErr = firstValidationError(
    validateSuperSock(sock),
    validateSuperSession(session),
    validateSuperInputLines(inputLines),
  );
  if (validationErr) return cliError(validationErr);

  try {
    const r = opSuperStart({ session, sock, inputLines });
    if (ctx.json) {
      cliWriteJson(r);
      return 0;
    }
    superExecAttach(sock, session);
  } catch (e: unknown) {
    return cliCatch(e);
  }
}

function cliHelp(): number {
  const lines = [
    `${CLI_BIN} — MUX-驾驶舱 v${TUI_CONFIG.VERSION} (CLI; rmux 默认 / tmux 回退)`,
    "无子命令 → 进入 TUI",
    "",
    "命令树:",
  ];
  for (const section of CLI_HELP_SECTIONS) {
    const cmds = section.cmds.filter((c) => !c.helpHidden);
    if (!cmds.length) continue;
    if (section.title) lines.push("", `${section.title}:`);
    for (const cmd of cmds) lines.push(...formatCliHelpEntry(cmd));
  }
  lines.push("", ...CLI_HELP_NOTES);
  cliWriteStdout(lines.join("\n") + "\n");
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
    if (a === "--lines" && rest[i + 1]) { flags.lines = rest[++i]; continue; }
    if (a.startsWith("--lines=")) { flags.lines = a.slice(8); continue; }
    if (a === "--sock" && rest[i + 1]) { flags.sock = rest[++i]; continue; }
    if (a.startsWith("--sock=")) { flags.sock = a.slice(7); continue; }
    if (a === "--tail" && rest[i + 1]) { flags.tail = rest[++i]; continue; }
    if (a.startsWith("--tail=")) { flags.tail = a.slice(7); continue; }
    if (a === "--head" && rest[i + 1]) { flags.head = rest[++i]; continue; }
    if (a.startsWith("--head=")) { flags.head = a.slice(7); continue; }
    if (a === "--quiet-rounds" && rest[i + 1]) { flags["quiet-rounds"] = rest[++i]; continue; }
    if (a.startsWith("--quiet-rounds=")) { flags["quiet-rounds"] = a.slice(15); continue; }
    if (a === "--no-enter") { flags["no-enter"] = "1"; continue; }
    if (a === "--json" || a === "-j") continue; // 由 peelJsonFlag / ctx.json 处理
    positional.push(a);
  }
  return { positional, flags };
}

function cliAgentSend(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0] || !flags.from) {
    return cliFailUsage("agent send <to> --from <me> [--corr id] [--reply] <body>");
  }
  const body = positional.slice(1).join(" ");
  if (!body) return cliError("消息正文为空");
  const kind = (flags.kind === "reply" ? "reply" : "msg") as AgentKind;
  const env = agentSend({
    to: positional[0],
    from: flags.from,
    body,
    corr: flags.corr,
    kind,
  });
  if (ctx.json) {
    cliWriteJson(env);
    return 0;
  }
  cliWriteStdout(`${env.corr}\n`);
  return 0;
}

function cliAgentInbox(ctx: CliCtx): number {
  const { positional, flags } = parseCliFlags(ctx.rest);
  if (!positional[0]) return cliFailUsage("agent inbox <me> [--follow] [--mark-read] [--since iso]");
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
      cliWriteStdout(JSON.stringify(e) + "\n");
      n = i + 1;
    }
    return n;
  };

  if (follow) {
    let cursor = printNew(0);
    agentMarkRead(id, cursor);
    cliWriteStderr(`following ${path} (Ctrl-C 退出)…\n`);
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
    return cliFailUsage("agent wait <me> --corr id [--timeout 60]");
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
        cliWriteStdout(JSON.stringify(e) + "\n");
        agentMarkRead(id, i + 1);
        return 0;
      }
    }
    scanned = rows.length;
    Bun.sleepSync(300);
  }
  cliWriteStderr(`timeout: 未收到 corr=${corr}\n`);
  return 1;
}

function cliAgentList(ctx: CliCtx): number {
  const agents = listRegisteredAgents();
  if (agents.length === 0) {
    if (ctx.json) {
      cliWriteJson({ version: TUI_CONFIG.VERSION, agents: [] });
      return 0;
    }
    cliWriteStderr("无已注册 agent（tui agent register <spec> <name>）\n");
    return 0;
  }
  if (ctx.json) {
    cliWriteJson({
      version: TUI_CONFIG.VERSION,
      generatedAt: new Date().toISOString(),
      agents: agents.map((a) => ({
        ...a,
        inboxPath: inboxPath(a.id),
        remark: findNodeByAgent(a.id)?.remark,
        previewLastLine: (() => {
          const n = findNodeByAgent(a.id);
          if (!n) return undefined;
          const idx = n.target.split(":")[1] ?? "";
          return paneSnap(buildWinIndexTarget(n.sessionName, idx), { lines: 1, sync: true }).lastLine;
        })(),
      })),
    });
    return 0;
  }
  for (const a of agents) {
    const unread = a.unread > 0 ? `  unread:${a.unread}` : "";
    cliWriteStdout(`${a.id}  ${a.target}${unread}\n`);
  }
  return 0;
}

function cliAgentRegister(ctx: CliCtx): number {
  if (ctx.rest.length < 2) return cliFailUsage("agent register <window-spec> <name>");
  const { target, node } = parseTargetSpec(ctx.rest[0]);
  if (node.type !== "window") {
    return cliError("register 需要 window spec");
  }
  const name = normalizeAgentName(ctx.rest[1]);
  writeAgent(node, name);
  cliWriteStdout(`agent ${name} → ${target}\n`);
  return 0;
}

function cliAgentUnregister(ctx: CliCtx): number {
  if (!ctx.rest[0]) return cliFailUsage("agent unregister <window-spec>");
  const { target, node } = parseTargetSpec(ctx.rest[0]);
  if (node.type !== "window") {
    return cliError("unregister 需要 window spec");
  }
  writeAgent(node, "");
  cliWriteStdout(`agent cleared on ${target}\n`);
  return 0;
}

type AgentCmdSpec = {
  summary: string;
  usage: string;
  aliases?: string[];
  run: (ctx: CliCtx) => number;
};

const CLI_AGENT_CMDS: Record<string, AgentCmdSpec> = {
  register: {
    summary: "为 window 设置 @agent 纯名",
    usage: "<window-spec> <name>",
    aliases: ["bind"],
    run: cliAgentRegister,
  },
  unregister: {
    summary: "清除 window 的 @agent",
    usage: "<window-spec>",
    aliases: ["unbind"],
    run: cliAgentUnregister,
  },
  send: {
    summary: "投递消息到对方 ~/.tui/inbox",
    usage: "<to> --from <me> [--corr id] [--reply] <body>",
    run: cliAgentSend,
  },
  inbox: {
    summary: "读取 inbox（jsonl）",
    usage: "<me> [--follow] [--mark-read] [--since iso]",
    run: cliAgentInbox,
  },
  wait: {
    summary: "阻塞等待 kind=reply 且 corr 匹配",
    usage: "<me> --corr id [--timeout 60]",
    run: cliAgentWait,
  },
  list: {
    summary: "已注册 agent、未读、inbox 路径",
    usage: "[--json]",
    aliases: ["ls"],
    run: cliAgentList,
  },
};

function matchAgentCmd(name: string): [string, AgentCmdSpec] | null {
  for (const [n, spec] of Object.entries(CLI_AGENT_CMDS)) {
    if (n === name || (spec.aliases?.includes(name) ?? false)) return [n, spec];
  }
  return null;
}

function cliAgentLegacy(ctx: CliCtx): number {
  const sub = ctx.rest[0];
  const hit = sub ? matchAgentCmd(sub) : null;
  if (!hit) {
    return cliError(`未知 agent 子命令: ${sub ?? "(none)"}`);
  }
  return hit[1].run({ ...ctx, rest: ctx.rest.slice(1) });
}

function buildAgentCmd(name: string, spec: AgentCmdSpec): CliCommand {
  return {
    name,
    aliases: spec.aliases,
    summary: spec.summary,
    usage: spec.usage,
    run: spec.run,
  };
}

function buildAgentGroup(): CliCommand {
  return {
    name: "agent",
    summary: "v0.3 — window @agent 纯名；与 @remark 分离",
    run: cliAgentLegacy,
    needsTmux: true,
    children: Object.entries(CLI_AGENT_CMDS).map(([n, s]) => buildAgentCmd(n, s)),
  };
}

type HookCmdSpec = {
  summary: string;
  usage?: string;
  run: CliHandler;
};

const CLI_HOOK_CMDS: Record<string, HookCmdSpec> = {
  "on": {
    summary: "绑定事件 hook（event-pattern → handler script）",
    usage: "<event-pattern> <handler-path>",
    run: cliHookOn,
  },
  "off": {
    summary: "解绑 hook",
    usage: "<event-pattern> [handler-path]",
    run: cliHookOff,
  },
  "list": {
    summary: "列出所有已绑定 hook",
    usage: "[--json]",
    run: cliHookList,
  },
  "fire": {
    summary: "手工派发事件：找匹配 event 的 handler，按契约喂 stdin JSON 执行",
    usage: "<event> [payload-json]   例: hook fire window-pane-changed:naos:lane-c '{\"lastLine\":\"PASS ✓\"}'",
    run: cliHookFire,
  },
};

function cliHookOn(ctx: CliCtx): number {
  const [pattern, handler, ...extra] = ctx.rest;
  if (!pattern || !handler) {
    return cliError("用法: mux hook on <event-pattern> <handler-path>");
  }
  try {
    hookOn(pattern, handler);
    cliWriteStdout(`✓ hook 已绑定: ${pattern} → ${handler}\n`);
    return 0;
  } catch (e) {
    return cliError(String(e));
  }
}

function cliHookOff(ctx: CliCtx): number {
  const [pattern, handler] = ctx.rest;
  if (!pattern) {
    return cliError("用法: mux hook off <event-pattern> [handler-path]");
  }
  try {
    hookOff(pattern, handler);
    cliWriteStdout(`✓ hook 已解绑: ${pattern}\n`);
    return 0;
  } catch (e) {
    return cliError(String(e));
  }
}

function cliHookList(ctx: CliCtx): number {
  const hooks = listHooks();
  if (ctx.json) {
    cliWriteJson(hooks);
  } else {
    if (hooks.length === 0) {
      cliWriteStdout("(no hooks registered)\n");
    } else {
      for (const h of hooks) {
        cliWriteStdout(`${h.event} → ${h.handler}\n`);
      }
    }
  }
  return 0;
}

function cliHookFire(ctx: CliCtx): number {
  const [event, payloadStr] = ctx.rest;
  if (!event) {
    return cliError("用法: mux hook fire <event> [payload-json]");
  }
  let payload: Record<string, unknown> = {};
  if (payloadStr) {
    try {
      const parsed = JSON.parse(payloadStr);
      if (parsed && typeof parsed === "object") payload = parsed as Record<string, unknown>;
      else return cliError("payload-json 必须是 JSON 对象");
    } catch (e) {
      return cliError(`payload-json 解析失败: ${String(e)}`);
    }
  }
  const results = dispatchHook(event, payload);
  if (ctx.json) {
    cliWriteJson({ event, matched: results.length, results });
    return results.every(r => r.rc === 0) ? 0 : 1;
  }
  if (results.length === 0) {
    cliWriteStdout(`(no handler matched event: ${event})\n`);
    return 0;
  }
  let worst = 0;
  for (const r of results) {
    cliWriteStdout(`── handler: ${r.handler} (rc=${r.rc}) ──\n`);
    if (r.stdout) cliWriteStdout(r.stdout.endsWith("\n") ? r.stdout : r.stdout + "\n");
    if (r.stderr) cliWriteStdout(`[stderr] ${r.stderr}`);
    if (r.rc !== 0) worst = r.rc;
  }
  return worst;
}

function buildHookCmd(name: string, spec: HookCmdSpec): CliCommand {
  return {
    name,
    summary: spec.summary,
    usage: spec.usage,
    run: spec.run,
  };
}

function buildHookGroup(): CliCommand {
  return {
    name: "hook",
    summary: "事件驱动 hook 机制（Monitor daemon 触发回调脚本）",
    run: (ctx: CliCtx) => {
      const sub = ctx.rest[0];
      const spec = CLI_HOOK_CMDS[sub];
      if (!spec) {
        return cliError(`未知 hook 子命令: ${sub ?? "(none)"}`);
      }
      return spec.run({ ...ctx, rest: ctx.rest.slice(1) });
    },
    needsTmux: false,
    children: Object.entries(CLI_HOOK_CMDS).map(([n, s]) => buildHookCmd(n, s)),
  };
}

const CLI_META_CMDS: Record<string, LeafCmdSpec> = {
  help: {
    summary: "显示帮助",
    aliases: ["-h", "--help"],
    run: () => cliHelp(),
    needsTmux: false,
    helpHidden: true,
  },
};

const CLI_MAINT_CMDS: Record<string, LeafCmdSpec> = {
  dev: {
    summary: "bun --watch 热重启（加速改 CLI/TUI）",
    usage: "[子命令参数…]  例: dev | dev status --json",
    aliases: ["watch"],
    run: cliDev,
    needsTmux: false,
  },
  doctor: {
    summary: "诊断后端路径/版本/quarantine",
    run: cliDoctor,
    needsTmux: false,
  },
  "install-rmux": {
    summary: "安装 rmux（默认后端，Rust 版多路复用器→~/rmux）",
    usage: "[--force] [--system]",
    aliases: ["install"],
    run: cliInstallRmux,
    needsTmux: false,
  },
  "install-tmux": {
    summary: "安装 tmux（兼容回退，便携版→~/tmux）",
    usage: "[--force] [--system]",
    run: cliInstallTmux,
    needsTmux: false,
  },
  serve: {
    summary: "本地 HTTP+WS 服务（给 mux-gui / 浏览器）",
    usage: "[--port=N]",
    run: cliServe,
    needsTmux: true,
  },
};

const CLI_TOOL_CMDS: Record<string, LeafCmdSpec> = {
  inspect: {
    summary: "单个 session/window/agent 详情 + capture",
    usage: "<spec> [--lines N] [--json]",
    aliases: ["show", "get"],
    run: cliInspect,
  },
  capture: {
    summary: "capture-pane → stdout 或 JSON",
    usage: "<spec> [lines] [--json]",
    run: cliCapture,
  },
  send: {
    summary: "paste-buffer 注入(零转义);@file 灌文件;- 从 stdin/heredoc 读正文",
    usage: "<spec> <text...|@file|->",
    aliases: ["msg"],
    run: cliSend,
  },
  envelope: {
    summary: "send + 信封头 (To/From/Title/Body + ReplyCmd 行);From 每次由实时 tmux pane 祖先链活算",
    usage: "<spec> <title> <body...|@file|->",
    run: cliEnvelope,
  },
  paste: {
    summary: "load-buffer + paste-buffer",
    usage: "<spec> <file>",
    run: cliPaste,
  },
  split: {
    summary: "给 agent 窗 split 一个 3 行输入 buffer，实现人机输入分离",
    usage: "<spec> [--json]",
    run: cliSplit,
  },
  unsplit: {
    summary: "移除 split 输入 buffer pane，恢复单窗",
    usage: "<spec> [--json]",
    run: cliUnsplit,
  },
  super: {
    summary: "byobu 全屏 + 下方固定行数输入框（独立 tmux socket，F 键转发上方）",
    usage: "[session] [--lines N] [--sock NAME]",
    aliases: ["byobu"],
    run: cliSuper,
    needsTmux: false,
  },
  "super-input": {
    summary: "super 输入框 worker（split-window 回调，勿手动调用）",
    usage: "<target> <sock> <session>",
    run: cliSuperInput,
    needsTmux: false,
    helpHidden: true,
  },
  "super-deliver": {
    summary: "super 输入框投递 worker（super-input 回调，勿手动调用）",
    usage: "<target> <sock> <text...|@file|->",
    run: cliSuperDeliver,
    needsTmux: false,
    helpHidden: true,
  },
};

type CliRootSection = {
  title?: string;
  build: () => CliCommand[];
};

const CLI_OS_CMD: LeafCmdSpec = {
  summary: "Agents OS（无子命令=驾驶舱 TUI；watch 同）",
  usage: "[watch] | init | goal | task | dispatch | verify | …",
  run: cliOs,
  needsTmux: false,
};

const CLI_ROOT_SECTIONS: CliRootSection[] = [
  { build: () => Object.entries(CLI_META_CMDS).map(([n, s]) => buildLeafCmd(n, s)) },
  {
    title: "Agents OS",
    build: () => [buildLeafCmd("os", CLI_OS_CMD)],
  },
  {
    title: "维护",
    build: () => Object.entries(CLI_MAINT_CMDS).map(([n, s]) => buildLeafCmd(n, s)),
  },
  { title: "Agent 总线", build: () => [buildAgentGroup()] },
  { title: "事件 Hook", build: () => [buildHookGroup()] },
  {
    title: "车队视图",
    build: () => [
      buildFleetCommand("status", CLI_FLEET_VIEWS.status),
      buildFleetCommand("list", CLI_FLEET_VIEWS.list),
    ],
  },
  {
    title: "窗口工具",
    build: () => Object.entries(CLI_TOOL_CMDS).map(([n, s]) => buildLeafCmd(n, s)),
  },
  {
    title: "主动驾驶",
    build: () => Object.entries(CLI_DRIVE_CMDS).map(([n, s]) => buildLeafCmd(n, s)),
  },
  {
    title: "Session / Window",
    build: () => Object.entries(CLI_OPS).map(([n, s]) => buildOpCommand(n, s)),
  },
  {
    title: "用户选项",
    build: () => Object.entries(CLI_USER_OPTS).map(([n, s]) => buildUserOptGroup(n, s)),
  },
];

const CLI_HELP_SECTIONS: { title?: string; cmds: CliCommand[] }[] = [];
const CLI_ROOT: CliCommand[] = [];
for (const s of CLI_ROOT_SECTIONS) {
  const cmds = s.build();
  CLI_HELP_SECTIONS.push({ title: s.title, cmds });
  CLI_ROOT.push(...cmds);
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
    lines.push(`hint: ${CLI_BIN} install-rmux  # 默认后端；或 install-tmux 回退`);
  }
  if (process.platform === "darwin" && existsSync(TUI_CONFIG.TMUX_HOME)) {
    const x = Bun.spawnSync(["xattr", "-lr", TUI_CONFIG.TMUX_HOME], { stdout: "pipe" }).stdout?.toString() || "";
    lines.push(x.includes("quarantine") ? "quarantine: 有（执行 xattr -dr com.apple.quarantine ~/tmux）" : "quarantine: 无");
  }
  cliWriteStdout(lines.join("\n") + "\n");
  return p ? 0 : 1;
}

function cliInstallTmux(ctx: CliCtx): number {
  const system = ctx.rest.some((a) => a === "--system" || a === "-s");
  const force = ctx.rest.some((a) => a === "--force" || a === "-f");
  if (system) return installTmuxSystem();
  return installTmuxPortable(force);
}

function cliInstallRmux(ctx: CliCtx): number {
  const system = ctx.rest.some((a) => a === "--system" || a === "-s");
  const force = ctx.rest.some((a) => a === "--force" || a === "-f");
  if (system) return installRmuxSystem();
  return installRmuxPortable(force);
}

// PART:serve — 本地 HTTP+WS 后端，给 mux-gui / 浏览器 用
//
// 路由（所有路由都校验 token，token 是启动时生成的随机串）:
//   GET  /                            → 重定向到 /index.html
//   GET  /index.html|/app.js|...      → 静态文件，从 tools/mux-gui/ 取
//   GET  /api/tree?token=             → JSON 树
//   GET  /api/capture?target=&lines=  → text/plain pane 快照（含 ANSI）
//   WS   /api/stream?target=&token=   → 推 base64 增量；客户端发 {data:"..."} 走 send-keys
//   POST /api/send  {target,data,enter} → send-keys
//   POST /api/op    {op,target?,name?}   → new-window/kill-session/kill-window

const SERVE_INFO_PATH = join(homedir(), ".tui", "serve.json");
const GUI_DIR = join(import.meta.dir, "mux-gui");

function serveAuthOk(req: Request, token: string): boolean {
  const url = new URL(req.url);
  if (url.searchParams.get("token") === token) return true;
  const h = req.headers.get("authorization");
  return h === `Bearer ${token}`;
}

function serveStatic(pathname: string): Response {
  const rel = pathname === "/" ? "/index.html" : pathname;
  const filePath = join(GUI_DIR, rel.replace(/^\/+/, ""));
  if (!existsSync(filePath)) return new Response("not found", { status: 404 });
  const type = rel.endsWith(".html") ? "text/html; charset=utf-8"
    : rel.endsWith(".js") || rel.endsWith(".mjs") ? "application/javascript; charset=utf-8"
    : rel.endsWith(".ts") ? "application/javascript; charset=utf-8"
    : rel.endsWith(".css") ? "text/css; charset=utf-8"
    : rel.endsWith(".json") ? "application/json; charset=utf-8"
    : "application/octet-stream";
  return new Response(Bun.file(filePath), { headers: { "content-type": type } });
}

function serveTreeJson(): unknown[] {
  return syncTree().map((n) => {
    const [, idx] = n.target.split(":");
    return {
      type: n.type,
      sessionName: n.sessionName,
      idx: idx || undefined,
      target: n.target,
      title: n.label.replace(/^\s+/, ""),
      remark: n.remark,
      agent: n.agent,
      windowActive: n.windowActive,
      windowActivity: n.windowActivity,
    };
  });
}

interface StreamSub { target: string; ws: import("bun").ServerWebSocket<{ token: string; target: string; last: string }>; timer: ReturnType<typeof setInterval> | null; }

function cliServe(ctx: CliCtx): number {
  const portArg = ctx.rest.find((a) => a.startsWith("--port="));
  const port = portArg ? Number(portArg.split("=")[1]) : 0;
  const token = randomUUID().replace(/-/g, "");
  const subs = new Map<unknown, StreamSub>();

  const server = Bun.serve<{ token: string; target: string; last: string }>({
    port,
    fetch(req, srv) {
      const url = new URL(req.url);
      const p = url.pathname;
      if (p === "/api/stream") {
        if (!serveAuthOk(req, token)) return new Response("unauthorized", { status: 401 });
        const target = url.searchParams.get("target") || "";
        if (!target) return new Response("missing target", { status: 400 });
        if (srv.upgrade(req, { data: { token, target, last: "" } })) return undefined as unknown as Response;
        return new Response("upgrade failed", { status: 500 });
      }
      if (p.startsWith("/api/")) {
        if (!serveAuthOk(req, token)) return new Response("unauthorized", { status: 401 });
        try {
          if (p === "/api/tree" && req.method === "GET") {
            return Response.json(serveTreeJson());
          }
          if (p === "/api/capture" && req.method === "GET") {
            const target = url.searchParams.get("target") || "";
            const lines = Number(url.searchParams.get("lines") || "200");
            if (!target) return new Response("missing target", { status: 400 });
            const text = tmuxApi.capturePaneText(target, lines);
            return new Response(text, { headers: { "content-type": "text/plain; charset=utf-8" } });
          }
          if (p === "/api/send" && req.method === "POST") {
            return req.json().then((body: { target: string; data: string; enter?: boolean }) => {
              if (!body.target || typeof body.data !== "string") return new Response("bad request", { status: 400 });
              tmuxApi.sendKeysLiteral(body.target, body.data);
              if (body.enter) tmuxApi.sendKeysEnter(body.target);
              return Response.json({ ok: true });
            });
          }
          if (p === "/api/op" && req.method === "POST") {
            return req.json().then((body: { op: string; target?: string; name?: string }) => {
              switch (body.op) {
                case "new-window":
                  if (!body.target || !body.name) return new Response("missing target/name", { status: 400 });
                  tmuxApi.newWindow(body.target.split(":")[0], body.name);
                  return Response.json({ ok: true });
                case "kill-window":
                  if (!body.target) return new Response("missing target", { status: 400 });
                  tmuxApi.killWindow(body.target);
                  return Response.json({ ok: true });
                case "kill-session":
                  if (!body.target) return new Response("missing target", { status: 400 });
                  tmuxApi.killSession(body.target.split(":")[0]);
                  return Response.json({ ok: true });
                default:
                  return new Response("unknown op", { status: 400 });
              }
            });
          }
          return new Response("not found", { status: 404 });
        } catch (e: unknown) {
          return new Response(e instanceof Error ? e.message : String(e), { status: 500 });
        }
      }
      return serveStatic(p);
    },
    websocket: {
      open(ws) {
        const target = ws.data.target;
        // 轮询版增量推送：每 250ms capture 一次，发 base64 增量
        const tick = () => {
          try {
            const cur = tmuxApi.capturePaneText(target, 200);
            if (cur !== ws.data.last) {
              ws.data.last = cur;
              // v0 轮询版：每次发完整快照，前置 clear+home，让 xterm 重画
              // 后续可换成 pipe-pane 真增量
              const frame = "\x1b[2J\x1b[H" + cur;
              ws.send(Buffer.from(frame, "utf-8").toString("base64"));
            }
          } catch { /* swallow capture errors during transition */ }
        };
        tick();
        const timer = setInterval(tick, 250);
        subs.set(ws, { target, ws, timer });
      },
      message(ws, msg) {
        try {
          const body = JSON.parse(typeof msg === "string" ? msg : new TextDecoder().decode(msg)) as { data?: string; enter?: boolean };
          if (typeof body.data === "string") {
            tmuxApi.sendKeysLiteral(ws.data.target, body.data);
            if (body.enter) tmuxApi.sendKeysEnter(ws.data.target);
          }
        } catch { /* ignore */ }
      },
      close(ws) {
        const s = subs.get(ws);
        if (s?.timer) clearInterval(s.timer);
        subs.delete(ws);
      },
    },
  });

  mkdirSync(join(homedir(), ".tui"), { recursive: true });
  const info = { port: server.port, token, pid: process.pid, url: `http://127.0.0.1:${server.port}/?token=${token}` };
  writeFileSync(SERVE_INFO_PATH, JSON.stringify(info, null, 2));
  cliWriteStdout(JSON.stringify(info) + "\n");
  cliWriteStderr(`mux serve: ${info.url}\n  (info → ${SERVE_INFO_PATH}; Ctrl-C 退出)\n`);
  // Bun.serve 持有事件循环，调用方在 entry 检测到 serve 子命令时跳过 process.exit
  return 0;
}

function resolveSelfScript(): string {
  const fromArgv = process.argv[1];
  if (fromArgv && existsSync(fromArgv)) return fromArgv;
  return join(import.meta.dir, "mux.ts");
}

function cliDev(ctx: CliCtx): number {
  const script = resolveSelfScript();
  const bunArgs = ["--watch", script, ...ctx.rest];
  const label = ctx.rest.length > 0 ? ctx.rest.join(" ") : "(TUI)";
  cliWriteStderr(
    `[mux dev] ${label}\n` +
    `  watch: bun ${bunArgs.join(" ")}\n` +
    `  保存 mux.ts 自动重启；Ctrl-C 结束；复用器内 agent/window 不受影响\n`,
  );
  const env = { ...process.env, TUI_DEV: "1" };
  const r = Bun.spawnSync(["bun", ...bunArgs], {
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
    env,
  });
  return r.exitCode ?? 0;
}

function dispatchCliCommand(cmd: CliCommand, rest: string[], json = false): number {
  const peeled = peelJsonFlag(rest);
  const ctx: CliCtx = { bin: CLI_BIN, rest: peeled.rest, json: json || peeled.json };
  if (cmd.children?.length) {
    const sub = ctx.rest[0] ? cmd.children.find((c) => matchCliName(c, ctx.rest[0])) : undefined;
    if (sub) return dispatchCliCommand(sub, ctx.rest.slice(1), ctx.json);
    return cmd.run(ctx);
  }
  return cmd.run(ctx);
}

function cliNeedsTmux(head: string): boolean {
  if (!head) return false;
  const cmd = CLI_ROOT.find((c) => matchCliName(c, head));
  if (!cmd) return true;
  return cmd.needsTmux !== false;
}

function runCli(argv: string[]): number {
  const head = argv[2];
  const peeled = peelJsonFlag(argv.slice(3));
  const cmd = CLI_ROOT.find((c) => matchCliName(c, head || ""));
  if (!cmd) {
    cliWriteStderr(`未知子命令: ${head}\n`);
    return cliHelp() === 0 ? 2 : 2;
  }
  if (cliNeedsTmux(head || "")) {
    const p = resolveTmuxPath();
    if (!p) {
      cliWriteStderr(`复用器后端未找到。运行: ${CLI_BIN} install-rmux  (或 install-tmux)\n`);
      return 1;
    }
    _resolvedTmuxBin = p;
  }
  try {
    return dispatchCliCommand(cmd, peeled.rest, peeled.json);
  } catch (e: unknown) {
    if (peeled.json) {
      cliWriteJson({ error: e instanceof Error ? e.message : String(e) });
    } else {
      cliError(e instanceof Error ? e.message : String(e), 1);
    }
    return 1;
  }
}

// PART:entry

if (import.meta.main) {
  cliInstallPipeGuard(process.stdout);
  cliInstallPipeGuard(process.stderr);
  if (isCliInvocation(process.argv)) {
    const isServe = process.argv.includes("serve");
    const code = runCli(process.argv);
    if (isServe) {
      // cliServe 已经起了 Bun.serve；不 exit，事件循环留给 server
    } else {
      process.exit(code);
    }
  } else if (process.stdin.isTTY) {
    startTui();
  } else {
    // 非 TTY 下无 CLI 子命令时，走非交互分支，避免 startTui 调 setRawMode 崩。
    process.exit(cliHelp());
  }
}

function startTui(opts?: { osMode?: boolean }): void {
  const _tmuxAtStart = resolveTmuxPath();
  if (!_tmuxAtStart) {
    cliWriteStderr(`复用器后端未找到。默认安装 rmux: ${CLI_BIN} install-rmux\n`);
    cliWriteStderr(`  或 tmux（兼容回退）: ${CLI_BIN} install-tmux\n`);
    process.exit(1);
  }
  _resolvedTmuxBin = _tmuxAtStart;
  state.osMode = opts?.osMode ?? false;
  if (state.osMode) ensureOsInit();
  state.resetOsActions();
  TUI_KEYBINDS = [];
  TUI_PROMPTS = [];
  initTuiRegistry(true);

  state.tree = syncTree();
  if (state.tree.length === 0) {
    tmuxApi.newSession("main");
    state.tree = syncTree();
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

  process.on("SIGWINCH", () => {
    state.needsFullClear = true;
    schedulePreview({ delay: 0, keepScroll: true });
  });
  process.on("exit", () => {
    stopDriveLoops();
    tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION);
    screen.disableMouse();
    restoreOuterMouse();
    screen.showCursor();
    screen.leaveAltScreen();
    screen.write("\x1b[0m");
    console.log("驾驶舱已经离开，用 tui 重新进入");
  });
  process.on("SIGINT", () => process.exit(0));
  process.on("SIGTERM", () => process.exit(0));

  schedulePreview({ delay: 0 });
}
