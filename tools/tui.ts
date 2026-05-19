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
  getSize(): [number, number] {
    return [process.stdout.columns || 80, process.stdout.rows || 24];
  }
}
const screen = new AnsiScreen();

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
function tmux(args: string[], opts?: { missingOk?: boolean }): string {
  const out = Bun.spawnSync(["tmux", ...args]);
  if (out.exitCode !== 0) {
    const stderr = out.stderr.toString();
    // 幂等清理命令（kill/has/rename-session 等）目标不存在时静默吞掉
    if (opts?.missingOk && /can't find session|no such session|session not found/i.test(stderr)) {
      return out.stdout.toString();
    }
    process.stderr.write(`[tmux ${args.join(" ")}] exit=${out.exitCode} ${stderr}`);
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
    tmux(["show-options", "-t", sessTarget, key]).trim(),
  showWindowRaw: (winTarget: string, key: string): string =>
    tmux(["show-options", "-wt", winTarget, key]).trim(),
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
  // 仅取本 scope 的值，避免 global @remark 泄漏到所有 session/window
  // show-options 不带 -v 时，未设置则输出空；设置则输出 `@remark "value"`
  // 关键：target 必须用 `=NAME:` 精确匹配，否则 tmux 对短名/数字名做模糊匹配，
  // 会把所有 session 的写入都打到同一目标，造成"全局污染"假象。
  const sessTarget = buildSessTarget(node.sessionName);
  const winTarget = node.type === "window" ? buildWinTarget(node.sessionName, node.target.split(":")[1] ?? "") : sessTarget;
  const raw = node.type === "session"
    ? tmuxApi.showSessionRaw(sessTarget, TUI_CONFIG.REMARK_KEY)
    : tmuxApi.showWindowRaw(winTarget, TUI_CONFIG.REMARK_KEY);
  if (!raw) return "";
  const m = raw.match(new RegExp(`^${TUI_CONFIG.REMARK_KEY}\\s+(?:"((?:[^"\\\\]|\\\\.)*)"|(\\S.*))$`));
  if (!m) return "";
  const v = m[1] !== undefined ? m[1].replace(/\\(.)/g, "$1") : m[2];
  return v.trim();
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
  const helpRest =
    "j/k:移动 Enter:进 C-左:回 n:新Session w:新Win d:删 r:改名 m:备注 f:刷新 q:退出" + scrollInd;
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

// === status guard：强制所有 session status off（留 viewer 显示提示栏），退出后恢复 ===
interface StatusSnapshot {
  sessions: Array<{ id: string; name: string; val: string }>;
}
function snapshotAndDisableStatus(): StatusSnapshot {
  // 只关 session-level status，不碰 global status。
  // session-level status-left/right/style 会覆盖全局 setting，
  // 所以 viewer 的 session 自定义提示栏不受其他 session/global 影响。
  // 注意：必须按 session_name 跳过 viewer（旧代码拿 session_id 比字面名永远不等，
  // 反而把刚 createViewer 设好的 status=on 又改回 off，沉浸式底栏因此消失）。
  //const r = tmuxApi.rawSpawnSync(["list-sessions", "-F", "#{session_id}\t#{session_name}\t#{status}"]);
  const r = tmuxApi.listSessions("#{session_id}\t#{session_name}\t#{status}")
  const sessions = (r.stdout?.toString() || "")
    .split("\n").map((l) => l.trim()).filter(Boolean)
    .map((l) => { const [id, name, val] = l.split("\t"); return { id, name, val: val || "" }; });
  for (const s of sessions) {
    if (s.id && s.name !== TUI_CONFIG.VIEWER_SESSION) {
      tmuxApi.setSessionOption(s.id, "status", "off");
    }
  }
  return { sessions };
}
function restoreStatus(snap: StatusSnapshot) {
  for (const s of snap.sessions) {
    if (!s.id || s.name === TUI_CONFIG.VIEWER_SESSION) continue;
    if (s.val === "") tmuxApi.unsetSessionOption(s.id, "status");   // 恢复默认（unset）
    else tmuxApi.setSessionOption(s.id, "status", s.val);
  }
}

// === viewer session helper：创建/销毁屏蔽 byobu 的 grouped viewer ===
function createViewer(sess: string, idx?: string) {
  tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION);
  tmuxApi.newGroupedSession(TUI_CONFIG.VIEWER_SESSION, sess);
  const vTarget = buildSessTarget(TUI_CONFIG.VIEWER_SESSION);
  // 屏蔽 byobu 全局快捷键：切到自定义空 key-table + 关掉 prefix
  tmuxApi.setSessionOption(vTarget, "key-table", TUI_CONFIG.TUI_KEYTABLE);
  tmuxApi.setSessionOption(vTarget, "prefix", "None");
  tmuxApi.setSessionOption(vTarget, "prefix2", "None");
  // byobu 风格底部只读提示栏：ctrl-← 返回 tree mode
  // session-level status-left/right/style 覆盖全局设置，其他 session 已设 status=off
  tmuxApi.setSessionOption(vTarget, "mouse", "off");       // viewer 内鼠标不被 tmux 捕获，允许原生文本选择

  if (idx) tmuxApi.selectWindow(buildWinTarget(TUI_CONFIG.VIEWER_SESSION, idx));

  tmuxApi.setSessionOption(vTarget, "status-position", "top");
  tmuxApi.setSessionOption(vTarget, "status", "on");
  tmuxApi.setSessionOption(vTarget, "status-left", " #[bold]ctrl-左: 返回 ");
  tmuxApi.setSessionOption(vTarget, "status-left-length", "30");
  tmuxApi.setSessionOption(vTarget, "status-right", `驾驶分舱:${idx||''} `);
  tmuxApi.setSessionOption(vTarget, "window-status-format", "");//for windows list in middle
  tmuxApi.setSessionOption(vTarget, "window-status-current-format", "");//for active win in middle
  tmuxApi.setSessionOption(vTarget, "window-status-separator", "");
  tmuxApi.setSessionOption(vTarget, "status-justify", "centre");
  tmuxApi.setSessionOption(vTarget, "status-style", "bg=white,fg=black");

}

function attach(target: string) {
  // target = "<sess>:<idx>"
  const [sess, idx] = target.split(":");

  screen.showCursor();
  screen.disableMouse();
  process.stdin.setRawMode(false);
  // 不调 restoreOuterMouse — viewer 内需要鼠标不被 tmux 捕获才能原生 select
  installCtrlQ();

  createViewer(sess, idx);
  const statusSnap = snapshotAndDisableStatus();

  try {
    tmuxApi.attach(TUI_CONFIG.VIEWER_SESSION);
  } finally {
    tmuxApi.killSession(TUI_CONFIG.VIEWER_SESSION);
    restoreStatus(statusSnap);
  }

  uninstallCtrlQ();
  process.stdin.setRawMode(true);
  disableOuterMouse();
  screen.enableMouse();
  refreshAll();
}

// ── preview 调度 ──

function refreshAll() {
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
    state.previewTarget = target;
    render(); // loading indicator
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

function schedulePreview() {
  if (state.previewTimer) clearTimeout(state.previewTimer);
  state.scrollOffset = 0;
  state.seenMax = 0;
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
  state.previewFetchId++; // 立即标记 pending
  render(); // 光标立即响应
  state.previewTimer = setTimeout(refreshPreview, PREVIEW_DELAY);
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

// ── CLI 模式 ──

const CLI_COMMANDS = new Set([
  "list", "capture", "send", "paste", "remark", "msg", "help", "--help", "-h",
]);

function resolveTarget(spec: string): string {
  if (!spec) throw new Error("target spec 为空");
  // 裸 tmux target：以 `=` 开头或形如 sess:idx
  if (spec.startsWith("=")) return spec;
  if (!spec.startsWith("@")) {
    // sess:idx → window target；sess → session target（必须带尾冒号消歧义）
    if (spec.includes(":")) {
      const [sess, idx] = spec.split(":");
      return buildWinTarget(sess, idx ?? "");
    }
    return buildSessTarget(spec);
  }
  // 逻辑名：遍历查 remark
  const wanted = spec; // 含 `@` 前缀
  const sessions = tmuxApi.listSessions();
  for (const sess of sessions) {
    const sessNode = { type: "session" as const, target: sess, sessionName: sess };
    if (readRemark(sessNode) === wanted) return buildSessTarget(sess);
    const wins = tmuxApi.listWindows(sess, "#{window_index}|#{window_name}");
    for (const w of wins) {
      const [idx] = w.split("|");
      const winNode = { type: "window" as const, target: `${sess}:${idx}`, sessionName: sess };
      if (readRemark(winNode) === wanted) return buildWinTarget(sess, idx);
    }
  }
  throw new Error(`找不到逻辑名 ${spec}`);
}

function cliHelp(): void {
  process.stdout.write(
`tui_v2 — TMUX 驾驶舱 (CLI 模式)
不带子命令时进入 TUI；以下子命令用于跨窗口通讯：

  list                       列出所有 session/window，含 @remark 与当前行预览
  capture <spec> [lines]     capture-pane 输出到 stdout（默认 80 行）
  send <spec> <text...>      send-keys 注入文本 + Enter（短文本）
  paste <spec> <file>        load-buffer + paste-buffer（大块内容）
  remark <spec> <text>       设 @remark（以 @ 开头即逻辑名）
  msg <@name> <text...>      send 同义词，强调逻辑名寻址
  help                       本帮助

<spec> 可为 @logic-name（按 @remark 反查），或 tmux target（sess / sess:idx / =sess:idx）
`);
}

function cliList(): number {
  const tree = getTree();
  for (const n of tree) {
    if (n.type === "session") {
      const rk = n.remark ? `  ${n.remark}` : "";
      process.stdout.write(`${n.target}${rk}\n`);
    } else {
      const rk = n.remark ? `  ${n.remark}` : "";
      // 当前行预览：capture 最后一行
      let last = "";
      try {
        // n.target 形如 `sess:idx`（window 分支）；用精确 target 消歧义
        const winIdx = n.target.split(":")[1] ?? "";
        const r = Bun.spawnSync(["tmux", "capture-pane", "-p", "-t", buildWinTarget(n.sessionName, winIdx), "-S", "-1", "-E", "-"]);
        last = (r.stdout?.toString() || "").split("\n").map(s => s.trim()).filter(Boolean).pop() || "";
      } catch {}
      process.stdout.write(`  ${n.target}${rk}  | ${stripAnsi(last).slice(0, 80)}\n`);
    }
  }
  return 0;
}

function cliCapture(spec: string, lines: number): number {
  const target = resolveTarget(spec);
  const r = Bun.spawnSync(["tmux", "capture-pane", "-p", "-t", target, "-S", `-${lines}`, "-E", "-"]);
  process.stdout.write(r.stdout?.toString() || "");
  return r.exitCode ?? 0;
}

function cliSend(spec: string, text: string): number {
  const target = resolveTarget(spec);
  const r = Bun.spawnSync(["tmux", "send-keys", "-t", target, text, "Enter"]);
  if (r.exitCode !== 0) {
    process.stderr.write((r.stderr?.toString() || "send-keys failed") + "\n");
    return r.exitCode ?? 1;
  }
  process.stdout.write(`sent → ${target}: ${text.length} chars\n`);
  return 0;
}

function cliPaste(spec: string, file: string): number {
  const target = resolveTarget(spec);
  const buf = `tui_v2_${process.pid}`;
  const r1 = Bun.spawnSync(["tmux", "load-buffer", "-b", buf, file]);
  if (r1.exitCode !== 0) {
    process.stderr.write((r1.stderr?.toString() || `load-buffer failed: ${file}`) + "\n");
    return r1.exitCode ?? 1;
  }
  const r2 = Bun.spawnSync(["tmux", "paste-buffer", "-d", "-b", buf, "-t", target]);
  if (r2.exitCode !== 0) {
    process.stderr.write((r2.stderr?.toString() || "paste-buffer failed") + "\n");
    return r2.exitCode ?? 1;
  }
  process.stdout.write(`pasted ${file} → ${target}\n`);
  return 0;
}

function cliRemark(spec: string, text: string): number {
  const target = resolveTarget(spec);
  // target 形如 =sess 或 =sess:idx，构造 TreeNode 用于 writeRemark
  const bare = target.replace(/^=/, "");
  const [sess, idx] = bare.split(":");
  const node: TreeNode = idx !== undefined
    ? { label: "", target: `${sess}:${idx}`, indent: 1, type: "window", sessionName: sess }
    : { label: "", target: sess, indent: 0, type: "session", sessionName: sess };
  writeRemark(node, text);
  process.stdout.write(`remark ${target} = ${text || "(cleared)"}\n`);
  return 0;
}

function runCli(argv: string[]): number {
  const cmd = argv[2];
  const rest = argv.slice(3);
  try {
    switch (cmd) {
      case "help": case "--help": case "-h":
        cliHelp(); return 0;
      case "list":
        return cliList();
      case "capture": {
        if (!rest[0]) { process.stderr.write("usage: tui_v2 capture <spec> [lines]\n"); return 2; }
        const lines = rest[1] ? parseInt(rest[1], 10) : 80;
        return cliCapture(rest[0], isNaN(lines) ? 80 : lines);
      }
      case "send": case "msg": {
        if (rest.length < 2) { process.stderr.write(`usage: tui_v2 ${cmd} <spec> <text...>\n`); return 2; }
        return cliSend(rest[0], rest.slice(1).join(" "));
      }
      case "paste": {
        if (rest.length < 2) { process.stderr.write("usage: tui_v2 paste <spec> <file>\n"); return 2; }
        return cliPaste(rest[0], rest[1]);
      }
      case "remark": {
        if (rest.length < 1) { process.stderr.write("usage: tui_v2 remark <spec> <text>\n"); return 2; }
        return cliRemark(rest[0], rest.slice(1).join(" "));
      }
      default:
        process.stderr.write(`未知子命令: ${cmd}\n`);
        cliHelp();
        return 2;
    }
  } catch (e: any) {
    process.stderr.write(`error: ${e?.message || e}\n`);
    return 1;
  }
}

if (process.argv[2] && CLI_COMMANDS.has(process.argv[2])) {
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
  screen.write("\x1b[0m");
  console.log("TMUX 驾驶舱已经离开，用 tui 重新进入");
});
process.on("SIGINT", () => process.exit(0));
process.on("SIGTERM", () => process.exit(0));

refreshPreview();
