#!/usr/bin/env bun
/**
 * CLI usage: see `tui_v2 help`
 * tmux 获取方式（绿色/便携优先）：
 *   macOS  : `brew install tmux` 或 MacPorts `port install tmux`；
 *            无 brew 时可下载 Homebrew bottle 解包，临时 `DYLD_LIBRARY_PATH=... ./tmux` 运行。
 *   Linux  : 包管理器 `apt/dnf/pacman/apk install tmux`；
 *            无 root 时用 conda-forge (`conda install -c conda-forge tmux`)、tmux-appimage 或静态构建。
 *   Windows: 首选 MSYS2 `pacman -S tmux`（原生）；备选 WSL；或 Cygwin。
 *   通用   : 未检测到 tmux 时，tmuxApi.assertAvailable() 会报错提示。
 */
const PREVIEW_DELAY = 1000;
const RETURN_FROM_ATTACH_DELAY = 120; // detach 后静默 sync tree / restore status
const PREVIEW_LINES = 80;

const TUI_CONFIG = {
  VERSION: '0.2',
  VIEWER_SESSION: `__tui_viewer__`,
  TUI_KEYTABLE: "tui_empty",
  REMARK_KEY: "@remark",
  TITLE: "TMUX 驾驶舱",
  TMUX_MISSING_MSG: "tmux 不可用，请先安装 tmux。",
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
  const out = Bun.spawnSync(["tmux", ...args], { stdout: "pipe", stderr: "pipe" });
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
    Bun.spawnSync(["tmux", "attach-session", "-t", buildSessOnlyTarget(name)], {
      stdin: "inherit", stdout: "inherit", stderr: "inherit",
    }),
  capturePane: (target: string, startN: number, endArg: string) =>
    Bun.spawn(["tmux", "capture-pane", "-p", "-t", target, "-S", `-${startN}`, "-E", endArg]),
  sendKeys: (target: string, text: string) =>
    Bun.spawnSync(["tmux", "send-keys", "-t", target, text, "Enter"]),
  loadBuffer: (target: string, file: string) =>
    Bun.spawnSync(["tmux", "load-buffer", "-b", `tui_v2_${process.pid}`, file]),
  pasteBuffer: (target: string) =>
    Bun.spawnSync(["tmux", "paste-buffer", "-d", "-b", `tui_v2_${process.pid}`, "-t", target]),
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
    Bun.spawnSync(["tmux", ...args], { stdout: "pipe", stderr: "pipe" }),

  // 运行时探测
  isInsideSession: (): boolean => !!process.env.TMUX,
  assertAvailable: (): void => {
    console.log("tmux 不可用，请先安装 tmux。");
    process.exit(1);
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
}

function readRemark(node: { type: "session" | "window"; target: string; sessionName: string }): string {
  const sessTarget = buildSessTarget(node.sessionName);
  const winTarget = node.type === "window" ? buildWinTarget(node.sessionName, node.target.split(":")[1] ?? "") : sessTarget;
  const raw = node.type === "session"
    ? tmuxApi.showSessionRaw(sessTarget, TUI_CONFIG.REMARK_KEY)
    : tmuxApi.showWindowRaw(winTarget, TUI_CONFIG.REMARK_KEY);
  if (!raw) return "";
  // -v 直接返回值；兼容旧格式 `@remark "value"`
  const m = raw.match(/^@remark\s+(?:"((?:[^"\\]|\\.)*)"|(\S.*))$/);
  if (m) {
    const v = m[1] !== undefined ? m[1].replace(/\\(.)/g, "$1") : m[2];
    return v.trim();
  }
  return raw.trim();
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

function capturePaneSync(target: string, startN: number, endArg = "-"): string {
  const r = Bun.spawnSync(
    ["tmux", "capture-pane", "-p", "-t", target, "-S", `-${startN}`, "-E", endArg],
    { stdout: "pipe", stderr: "pipe" },
  );
  if (r.exitCode !== 0 && !tmuxQuietDepth) {
    process.stderr.write(
      `[tmux capture-pane -t ${target}] exit=${r.exitCode} ${r.stderr?.toString() || ""}`,
    );
  }
  return r.stdout?.toString() || "";
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

class TuiState {
  tree: TreeNode[] = getTree();
  cursor = 0;
  viewOffset = 0;
  preview = "";
  previewTimer: ReturnType<typeof setTimeout> | null = null;
  previewFetchId = 0;
  previewDoneId = 0;
  previewTarget = "";
  inputMode: InputMode | null = null;
  scrollOffset = 0;
  seenMax = 0;
  selectMode = false;
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
  return Math.max(1, rows - HEADER_H - FOOTER_H);
}
function getLayout(cols: number, rows: number) {
  const leftW = Math.min(Math.max(Math.floor(cols * 0.2), 12), 30);
  const rightW = cols - leftW - 1;
  const bodyH = rows - HEADER_H - FOOTER_H;
  return { leftW, rightW, bodyH };
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
  const remarkPart = rk ? ` ${rk}` : "";
  const pendPart = pending ? " **" : "";
  const tail = truncVis(remarkPart + pendPart, Math.max(0, cap - baseW));
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

function render() {
  const [cols, rows] = screen.getSize();
  const { leftW, rightW, bodyH } = getLayout(cols, rows);

  state.clampView(bodyH);

  screen.clear();
  screen.hideCursor();

  // header：左上 LOGO（ASU 金底栗色字）+ 帮助快捷键
  screen.cursorAt(1, 1);
  const scrollInd = state.scrollOffset > 0 ? ` ↕${state.scrollOffset}` : "";
  const helpRest = " 上下移动 Enter:进 C-左:回 n:新Session w:新Win d:删 r:改名 m:备注 f:刷新 q:退出" + scrollInd;
  const maxW = cols - 1;
  const logoVis = truncVis(TUI_CONFIG.TITLE, maxW);
  const logoW = visW(logoVis);
  screen.write(screen.asuLogo(padVis(logoVis, logoW)));
  const helpCap = Math.max(0, maxW - logoW);
  if (helpCap > 0) {
    const helpVis = truncVis(helpRest, helpCap);
    screen.write(screen.inv(screen.bold(padVis(helpVis, helpCap))));
  }

  // body
  const allPLines = state.preview.split("\n");
  // 取最后 bodyH 行（capture 末尾即最新输出）
  const pLines = allPLines.length > bodyH ? allPLines.slice(allPLines.length - bodyH) : allPLines;
  const blankLeft = " ".repeat(leftW - 1);

  // 滚动条计算：右侧让出 1 列绘制
  const textW = Math.max(0, rightW - 1);
  const previewH = bodyH;
  const curDepth = state.scrollOffset + previewH;
  if (curDepth > state.seenMax) state.seenMax = curDepth;
  const total = Math.max(state.seenMax, previewH);
  const thumbH = Math.max(1, Math.round((previewH * previewH) / total));
  const thumbStart = total <= previewH
    ? 0
    : Math.max(0, Math.min(previewH - thumbH,
        Math.round((previewH * (total - state.scrollOffset - previewH)) / total)));
  for (let i = 0; i < bodyH; i++) {
    const row = i + BODY_START_ROW;
    const treeIdx = i + state.viewOffset;

    // left: tree
    screen.cursorAt(row, 1);
    const cap = leftW - 1;
    if (treeIdx < state.tree.length) {
      renderLeftCell(state.tree[treeIdx], treeIdx === state.cursor, cap);
    } else {
      screen.write(blankLeft);
    }

    // divider (固定列 leftW)
    screen.cursorAt(row, leftW);
    screen.write(screen.dim("│"));

    // right: preview (let out 1 col for scrollbar)
    screen.cursorAt(row, leftW + 1);
    if (state.previewTarget && i === 0) {
      screen.write(screen.dim(`⏳ ${state.previewTarget} ...`).slice(0, textW));
    } else if (state.suppressPreviewAfterAttach && i === 0) {
      screen.write(screen.dim("  已从分舱返回 · 按 f 刷新预览").slice(0, textW));
    } else if (state.suppressPreviewAfterAttach) {
      screen.write(" ".repeat(Math.min(textW, leftW + rightW)));
    } else {
      screen.write((pLines[i] || "").slice(0, textW));
    }

    // scrollbar (最右一列)
    if (rightW >= 1) {
      screen.cursorAt(row, leftW + 1 + textW);
      const inThumb = i >= thumbStart && i < thumbStart + thumbH;
      screen.write(`\x1b[90m${inThumb ? "▓" : "░"}\x1b[0m`);
    }
  }

  // footer
  screen.cursorAt(rows, 1);
  if (state.inputMode) {
    const line = ` ${state.inputMode.prompt}: ${state.inputMode.value}█ `;
    screen.write(screen.gold(padVis(truncVis(line, cols - 1), cols - 1)));
    screen.showCursor();
  } else {
    if (state.selectMode) {
      const line = " [选择模式 s:退出]  鼠标可在 preview 框选复制；键盘 j/k/Enter 仍可用 ";
      screen.write(screen.inv(screen.wrap("93")(padVis(truncVis(line, cols - 1), cols - 1))));
    } else {
      // 帮助已移到 header，footer 仅占位保持布局一致
      screen.write(screen.gold(" ".repeat(cols - 1)));
    }
  }
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

// ── 外层 tmux 鼠标穿透 ──
// 若 tui 在 tmux 内运行，外层 tmux 的 mouse on 会先吃掉 SGR 序列，
// 导致内层 tui 收不到点击。启动时关掉，退出/attach 时恢复。
const insideTmux = tmuxApi.isInsideSession();
let savedOuterMouse: string | null = null;

function enterSelectMode() {
  // 关闭 SGR 鼠标，让终端原生选择接管
  screen.disableMouse();
  restoreOuterMouse();
  state.selectMode = true;
  render();
}
function exitSelectMode() {
  state.selectMode = false;
  disableOuterMouse();
  screen.enableMouse();
  render();
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

// ── 操作 ──

function newSession() {
  startInput("新 Session 名称", (raw) => {
    const name = raw?.trim().replace(/\s+/g, "-");
    if (name) {
      tmuxApi.newSession(name);
      refreshAll();
      const idx = state.tree.findIndex(
        (n) => n.type === "session" && n.target === name,
      );
      if (idx >= 0) state.cursor = idx;
    }
    refreshPreview();
  });
}

function newWindow() {
  if (state.tree.length === 0) return;
  const sess = state.tree[state.cursor].sessionName;
  startInput(`在 [${sess}] 新建 Window 名称`, (raw) => {
    const name = raw?.trim();
    if (name) {
      tmuxApi.newWindow(sess, name);
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
        //too danger, not able yet.
        //tmuxApi.killSession(node.target);
      }
      else tmuxApi.killWindow(node.target);

    }
    refreshAll();
  });
}

function renameCurrent() {
  if (state.tree.length === 0) return;
  const node = state.tree[state.cursor];
  startInput(`rename ${node.type} [${node.target}]`, (raw) => {
    const name = raw?.trim().replace(/\s+/g, "-");
    if (name) {
      if (node.type === "session") {
        tmuxApi.renameSession(node.sessionName, name);
      } else {
        tmuxApi.renameWindow(node.target, name);
      }
    }
    refreshAll();
  });
}

function remarkCurrent() {
  if (state.tree.length === 0) return;
  const node = state.tree[state.cursor];
  startInput(`remark [${node.target}] (空=删除)`, (raw) => {
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
  const opts = [
    `tmux set-option -t '${v}' key-table '${TUI_CONFIG.TUI_KEYTABLE}'`,
    `tmux set-option -t '${v}' prefix None`,
    `tmux set-option -t '${v}' prefix2 None`,
    `tmux set-option -t '${v}' mouse off`,
    `tmux set-option -t '${v}' status-position top`,
    `tmux set-option -t '${v}' status on`,
    `tmux set-option -t '${v}' status-left ' #[bold]ctrl-左: 返回 '`,
    `tmux set-option -t '${v}' status-left-length 30`,
    `tmux set-option -t '${v}' status-right '驾驶分舱:${cabin} '`,
    `tmux set-option -t '${v}' window-status-format ''`,
    `tmux set-option -t '${v}' window-status-current-format ''`,
    `tmux set-option -t '${v}' window-status-separator ''`,
    `tmux set-option -t '${v}' status-justify centre`,
    `tmux set-option -t '${v}' status-style 'bg=white,fg=black'`,
  ].join(" && ");
  const win = idx ? ` && tmux select-window -t '=${v}:${idx}'` : "";
  tmuxShBatch(opts + win);
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

function handleMouse(btn: number, x: number, y: number, press: boolean) {
  const [cols, rows] = screen.getSize();
  const { leftW } = getLayout(cols, rows);
  // 滚轮
  if (btn === 64 || btn === 65) {
    if (!press) return;
    if (x >= leftW) {
      // 右栏 preview 滚动
      const previewH = getPreviewH();
      if (btn === 64) state.scrollOffset += 3;
      else state.scrollOffset = Math.max(0, state.scrollOffset - 3);
      // 上限：tmux history-limit 通常 2000；放宽到一个合理值
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
  if (y > rows - FOOTER_H) return;     // footer 占 FOOTER_H 行
  if (y < BODY_START_ROW) return;       // header
  if (x >= leftW) return;               // 右栏忽略
  const idx = (y - BODY_START_ROW) + state.viewOffset;
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

  // 抽取 SGR 鼠标序列（选择模式下应该收不到，但安全起见仍过滤掉）
  if (s.indexOf("\x1b[<") >= 0) {
    const re = /\x1b\[<(\d+);(\d+);(\d+)([Mm])/g;
    if (!state.selectMode) {
      let m: RegExpExecArray | null;
      while ((m = re.exec(s)) !== null) {
        handleMouse(parseInt(m[1]), parseInt(m[2]), parseInt(m[3]), m[4] === "M");
      }
    }
    s = s.replace(re, "");
    if (!s) return;
  }

  if (state.inputMode) {
    handleInputKey(s);
    return;
  }

  if (s === "s") {
    if (state.selectMode) exitSelectMode();
    else enterSelectMode();
    return;
  }

  if (s === "\x03" || s === "q") {
    if (state.selectMode) exitSelectMode();
    screen.showCursor();
    screen.clear();
    process.exit(0);
  } else if (s === "\x1b[A" || s === "k") {
    if (state.cursor > 0) {
      state.cursor--;
      schedulePreview();
    }
  } else if (s === "\x1b[B" || s === "j") {
    if (state.cursor < state.tree.length - 1) {
      state.cursor++;
      schedulePreview();
    }
  } else if (s === "\r" || s === "\x1b[1;5C" || s === "\x1b[1;3C" || s === "\x1b[1;9C" || s === "\x1b\x1b[C" || s === "\x1bOC") {
    if (state.tree.length > 0) {
      if (state.tree[state.cursor]?.type !== "window") return;
      const wasSelectMode = state.selectMode;
      attach(state.tree[state.cursor].target);
      // attach 返回后 screen.enableMouse + disableOuterMouse 破坏了 selectMode，重新进入
      if (wasSelectMode) enterSelectMode();
    }
  } else if (s === "n") {
    newSession();
  } else if (s === "w") {
    newWindow();
  } else if (s === "d") {
    deleteCurrent();
  } else if (s === "r") {
    renameCurrent();
  } else if (s === "m") {
    remarkCurrent();
  } else if (s === "f") {
    //refreshPreview();
    refreshAll();
  } else if (process.env.DEBUG_KEYS && s.length > 0 && (s.length > 1 || s < " " || s === "\x1b")) {
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
      const winIdx = n.target.split(":")[1] ?? "";
      const last = capturePaneSync(buildWinTarget(n.sessionName, winIdx), 1)
        .split("\n")
        .map((s) => s.trim())
        .filter(Boolean)
        .pop() || "";
      process.stdout.write(`  ${n.target}${rk}  | ${stripAnsi(last).slice(0, 80)}\n`);
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
  process.stdout.write(capturePaneSync(target, isNaN(lines) ? PREVIEW_LINES : lines));
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
  lines.push("", "<spec>: @逻辑名 | sess | sess:idx | =sess:idx");
  process.stdout.write(lines.join("\n") + "\n");
  return 0;
}

const CLI_CMD = {
  help: { name: "help", aliases: ["-h", "--help"], summary: "显示帮助", run: () => cliHelp() },
  list: { name: "list", aliases: ["tree", "ls"], summary: "列出 session/window、@remark、末行预览", run: cliList },
  capture: { name: "capture", summary: "capture-pane → stdout", usage: "<spec> [lines]", run: cliCapture },
  send: { name: "send", aliases: ["msg"], summary: "send-keys 注入", usage: "<spec> <text...>", run: cliSend },
  paste: { name: "paste", summary: "load-buffer + paste-buffer", usage: "<spec> <file>", run: cliPaste },
  remarkSet: { name: "set", aliases: ["write"], summary: "设置 @remark", usage: "<spec> [text...]", run: cliRemarkSet },
  remarkGet: { name: "get", aliases: ["show", "read"], summary: "读取 @remark", usage: "<spec>", run: cliRemarkGet },
  remark: {
    name: "remark",
    summary: "读写 @remark 逻辑名",
    run: cliRemarkLegacy,
    children: [] as CliCommand[],
  },
};
CLI_CMD.remark.children = [CLI_CMD.remarkSet, CLI_CMD.remarkGet];

const CLI_ROOT: CliCommand[] = [
  CLI_CMD.help,
  CLI_CMD.list,
  CLI_CMD.capture,
  CLI_CMD.send,
  CLI_CMD.paste,
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

function runCli(argv: string[]): number {
  const head = argv[2];
  const rest = argv.slice(3);
  const cmd = CLI_ROOT.find((c) => matchCliName(c, head || ""));
  if (!cmd) {
    process.stderr.write(`未知子命令: ${head}\n`);
    return cliHelp() === 0 ? 2 : 2;
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

// ── 启动 ──

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

refreshPreview();
