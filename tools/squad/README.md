# Squad — 通用多角色编排 CLI

> **演进**：现为 host 层（Python + shell）。nano lisp 工具成熟后，用 Lisp/bootstrap 实现同等 `catalog` + `run-loop` + `signals`，替代对 Python/shell 的依赖；见 `lab/nano-lisp-jit/squad/PROTOCOL.md` §演进笔记。

**一个工具、一个循环**：所有角色都用 `squad run-loop --role <id>`；指挥长（leader）在循环里更新 `signals.supervisor`，队员 **只等 leader 信号**，不因自己看到 100% 就退出。

## 状态与锁

| 层 | 路径 | 用途 |
|----|------|------|
| **SQLite（真相源）** | `.squad/state.db` | 派单、claim、path 锁、**signals** |
| **JSON（导出）** | `.squad/state.json` | 人读 / diff；`export-json` 生成 |

## 唯一入口（所有角色）

```bash
# 指挥长 = leader：assess → dispatch → 发 supervisor 信号
tools/squad/squad.sh run-loop --role commander

# 工程兵 / 审查员 = follower：while 等 leader，再 member_tick
tools/squad/squad.sh run-loop --role engineer-a
tools/squad/squad.sh run-loop --role engineer-b
tools/squad/squad.sh run-loop --role reviewer

# 并发小队（tmux 里跑 4 条相同的 run-loop，仅 --role 不同）
tools/squad/squad.sh agent-team --auto-exec

# 队员自动 claim + verify（verify 持 flock，避免与 run.sh 竞写 evidence）
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml run-loop --role engineer-a --auto-exec
```

### Leader 信号（`signals` 表 subject=`supervisor`）

| 信号 | 含义 |
|------|------|
| `running` | 波次进行中，队员继续等 |
| `standby` | 签收门禁已过，仍有任务/指派未完成 |
| `complete` | 指挥长放行，队员可 `stand_down` 退出 |
| `failed` / `timeout` | 全队退出 |

队员 **禁止** 调用 `supervise`；**禁止** 根据 `assess.ready` 自行退出。

## 辅助命令

```bash
tools/squad/squad.sh resume              # 新 wave，leader=running
tools/squad/squad.sh dispatch --force --include-meta
tools/squad/squad.sh worker-tick engineer-a   # 单步调试（等同 run-loop --once 一拍）
tools/squad/squad.sh supervise --once    # 仅 leader 调试
```

## 配置

项目根 `.squadrc.yaml` → `catalog.yaml`；`supervisor.team_mode: true`（默认）启用 leader/follower 分离。`supervisor.auto_exec: true` 时 follower 在 tick 内自动 `claim`/`verify`（成功时 stderr 打印建议的 `done` 命令）；`verify` 使用 `.squad/verify.lock` 串行化。

## Cloud Agent 并行

开 4 个 Agent，**同一条命令、不同 `--role`**：

```
tools/squad/squad.sh run-loop --role commander
tools/squad/squad.sh run-loop --role engineer-a
...
```

不要各写一套 shell；不要每人一个 Python 文件。
