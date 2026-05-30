# mux.ts — MUX-驾驶舱

多路复用器（rmux 默认，tmux 兼容回退）之上的车队驾驶舱：纯键盘 TUI + 同源 CLI + Agent 总线，单文件 Bun 脚本，零运行时依赖（除后端二进制本身）。

版本 0.6.0 起从 `tui.ts` 改名为 `mux.ts`，标题统一为 **MUX-驾驶舱**。

## 快速开始

```sh
bun tools/mux.ts install-rmux   # 自动从 GitHub Releases 装 rmux → ~/rmux/bin/rmux
bun tools/mux.ts doctor         # 诊断后端解析路径/版本
bun tools/mux.ts                # 无参 → 进入 TUI
bun tools/mux.ts help           # 同源 CLI 命令树
```

建议 `ln -s "$PWD/tools/mux.ts" ~/.local/bin/mux`，后续直接 `mux ...`。

## 后端：rmux 默认 + tmux 回退

| 项 | rmux（默认） | tmux（回退） |
| --- | --- | --- |
| 安装 | `mux install-rmux` → `~/rmux/bin/rmux` | `mux install-tmux` → `~/tmux/bin/tmux` |
| 系统装 | `mux install-rmux --system`（brew tap → cargo install） | `mux install-tmux --system`（brew/apt 提示） |
| 跨平台 | macOS / Linux / Windows | macOS / Linux |
| 来源 | `Helvesec/rmux` GitHub Releases（动态查最新版，SHA256 校验） | `tmux/tmux-builds` GitHub Releases（动态查最新版） |

### 解析优先级（`resolveTmuxPath`）

1. `TMUX_BIN`（显式覆盖路径）
2. **rmux**：`RMUX_BIN` → `~/rmux/bin/rmux` → `$PATH/rmux`
3. **tmux**：`~/tmux/bin/tmux` → `$PATH/tmux`

设 `TUI_USE_TMUX=1` 翻转为 tmux 优先。

### rmux 兼容性已知差异

- `=NAME` 精确匹配前缀：rmux 不支持。mux 已统一去掉 `=`，依赖自家 session 命名不歧义。
- grouped session（`new-session -t <src>`）：rmux 支持创建，但 `attach-session` 不识别同一前缀语法——直接走裸名即可。
- 其他 quirk 出现时：临时回退 `TUI_USE_TMUX=1`，并把现象记录到本节。

## 命令分层（CLI 树）

`mux help` 输出按 `CLI_ROOT_SECTIONS` 分组：

- **维护**：`dev` / `doctor` / `install-rmux` / `install-tmux`
- **Agent 总线**：`agent register|send|inbox|wait|list` — window 上的 `@agent` 纯名，inbox 文件 `~/.tui/inbox/<name>.jsonl`
- **车队视图**：`status` / `list`（结构化输出，默认表格；加 `--json` 给脚本/agent）
- **窗口工具**：`inspect` / `capture` / `send` / `paste`
- **Session / Window**：`new-session` / `new-window` / `kill-*` / `rename-*` 等
- **用户选项**：`@remark` / `@auto`（人类可读标签、自动巡航）

`<spec>` 语法：`@逻辑名 | sess | sess:idx`（`@` 仅 remark 反查）。

## 环境变量

| 变量 | 作用 |
| --- | --- |
| `TMUX_BIN` | 显式指定后端可执行文件路径，最高优先 |
| `RMUX_BIN` | rmux 可执行文件覆盖路径 |
| `TUI_USE_TMUX=1` | 翻转后端解析为 tmux 优先 |
| `GITHUB_TOKEN` | 安装时拉 release API 防限流 |
| `TUI_DEV=1` | `mux dev` 热重启模式标记 |

## Agent 总线（v0.3）

window 通过 `@agent` option 绑定纯名 id，消息 jsonl 落到 `~/.tui/inbox/<name>.jsonl`：

```sh
mux agent register sess:1 builder
mux agent send builder --from supervisor "go build now"
mux agent inbox builder --follow            # 跟随
mux agent wait builder --corr <id>          # 阻塞等回复
```

`@remark` 是给人看的别名，`@agent` 是给程序用的 id，互不干扰。

## TUI 操作（无参启动后）

`?` 看完整键位。常用：

- `↑↓` 选；`Enter` 进舱；`Ctrl-←` 退舱
- `n` 新 session / `w` 新 window / `r` rename / `x` kill
- `i` 注入文本到当前 window（末尾 `\` 不发 Enter）
- `P` paste-buffer，`f` 强制刷新

## 自动安装机制（rmux / tmux 同源）

两边都走 `ghFetchLatestRelease` → 按平台关键字挑 asset → 可选 SHA256SUMS 校验 → tar/zip 解包到 `~/<name>/.cache/` → 复制到 `~/<name>/bin/<name>`。无硬编码版本号，发新版自动跟上。

平台关键字：
- rmux：Rust target triple，如 `aarch64-apple-darwin` / `x86_64-unknown-linux-gnu`；glibc 缺失时偏向 musl
- tmux：tmux-builds 命名，如 `macos-arm64` / `linux-x86_64`

## 文件 / 路径

- `~/rmux/bin/rmux` — 便携 rmux
- `~/tmux/bin/tmux` — 便携 tmux
- `~/.tui/inbox/<agent>.jsonl` — agent 消息箱
- `~/.tui/read/<agent>.cursor` — 已读游标
- `~/<rmux|tmux>/.cache/` — 下载缓存

## 路线图

- [ ] `mux serve` — 本地 HTTP + WS，暴露 `syncTree / capturePane` 给前端，复用现有数据层
- [ ] GUI 直接走浏览器（不引入 Electron）；agent 视觉通过 computer-use MCP 截 Chrome 窗口或后端 capture-pane 文本
- [ ] rmux 兼容性回归集：跑一遍主要命令路径，文档化所有 quirk
