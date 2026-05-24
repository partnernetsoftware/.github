# TUI 暂停功能（恢复指南）

源码中已移除大块注释；恢复时按块粘贴回 `tools/mux.ts` 对应位置，并取消 keybind / state 注释。

参考快照：`tools/archive/tui_v4.ts`（v0.4.1，含 g/c/a 启用版）。

---

## 1. DRIVE_SHORTCUTS — g 跳窗 / c 已读 / a 档位

**函数**（贴至 `renderDriveAnchor` 之后）：

```typescript
function gotoCurrentWindow(): void {
  const node = state.tree[state.cursor];
  if (node?.type !== "window") return;
  const idx = node.target.split(":")[1] ?? "";
  tmuxApi.selectWindow(buildWinTarget(node.sessionName, idx));
}

function markCurrentAgentRead(): void {
  const node = state.tree[state.cursor];
  if (node?.type !== "window" || !node.agent) return;
  agentMarkRead(node.agent);
  invalidateDriveView();
  render();
}

function cycleCurrentAuto(): void {
  if (state.uiMode !== "drive") return;
  const node = state.tree[state.cursor];
  if (node?.type !== "window") return;
  writeAuto(node, nextAutoLevel(readAuto(node)));
  refreshAll();
}
```

**TUI_KEYBINDS** 追加：

```typescript
{ help: "g:跳窗", match: (s) => s === "g", run: () => { gotoCurrentWindow(); render(); } },
{ help: "c:已读", match: (s) => s === "c", run: () => markCurrentAgentRead() },
{ help: "a:档位", match: (s) => s === "a", run: () => cycleCurrentAuto() },
```

**footer hint**：`Space折 · g跳 · c已读 · a档位 · Enter进舱`

---

## 2. MAIN_SELECT — 主界面 preview 终端选区

**TuiState** 恢复：`selectMode = false`

**函数**（贴至 `decodeMouseBtn` 之后）：

```typescript
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
  if (shift && btn <= 2) { enterSelectMode(); return true; }
  if (inPreview && btn === 0) { enterSelectMode(); return true; }
  return false;
}
```

**handleKey**：`s` 切换选区；`selectMode && Esc` 退出；`handleMouse` 开头调 `maybeEnterSelectMode`。

---

## 3. OBSERVER — v 消息栏 + bus.jsonl

**TUI_CONFIG** 恢复：`BUS_PATH: join(homedir(), ".tui", "bus.jsonl")`

**函数**（贴至 `summarizeMessage` 之后）：

```typescript
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
    try { out.push(JSON.parse(t) as AgentEnvelope); } catch { /* skip */ }
  }
  return out;
}
```

**agentSend** 内恢复 `appendBus(env)`。

**Layout**：`layoutMode: "preview" | "observer"`；`getLayout` 恢复 `inspectorW`；`toggleObserver()` + `v` keybind。

**渲染**（贴至 index render 区）：

```typescript
function formatBusLine(env: AgentEnvelope, cap: number): string { /* 见 archive tui_v4 */ }
function renderInspectorCell(...) { /* 见 archive tui_v4 */ }
```

**bootstrap**：`setInterval(() => { if (state.layoutMode === "observer") render(); }, 1000);`

---

## 恢复顺序建议

1. DRIVE_SHORTCUTS（最小、v4 已验）
2. MAIN_SELECT（独立 UX）
3. OBSERVER（布局 + bus 耦合最多）
