# Squad — 通用多角色编排 CLI

## 状态与锁

| 层 | 路径 | 用途 |
|----|------|------|
| **SQLite（真相源）** | `.squad/state.db` | 派单、claim、path 锁、`BEGIN IMMEDIATE` 事务 |
| **JSON（导出）** | `.squad/state.json` | 人读 / git diff；由 `export-json` 生成 |

锁机制：

- `PRAGMA journal_mode=WAL` + `busy_timeout=30000`
- 写事务 `BEGIN IMMEDIATE`（含 path_locks 唯一约束）
- 遇 `SQLITE_BUSY` **指数退避**重试（50ms → 2s，最多 10 次）

比纯 JSON 文件锁更稳：原子 claim、并发工程兵不会静默覆盖。

## 配置

项目根 `.squadrc.yaml`：

```yaml
catalog: lab/nano-lisp-jit/squad/catalog.yaml
```

`catalog.yaml`：

```yaml
apiVersion: squad/v2
project:
  root: ..
  state_db: .squad/state.db
  state_file: .squad/state.json
locking:
  backend: sqlite
roles:
  engineer-a: { kind: worker, workflow: worker }
dispatch:
  assign_to: [engineer-a, engineer-b]
```

## 命令

```bash
tools/squad/squad.sh init
tools/squad/squad.sh assess
tools/squad/squad.sh dispatch
tools/squad/squad.sh claim engineer-a my-task
tools/squad/squad.sh done engineer-a my-task --commit abc1234
tools/squad/squad.sh export-json
tools/squad/squad.sh supervise          # 指挥长 while：complete|failed|timeout
tools/squad/squad.sh supervise --once  # 单 tick
tools/squad/squad.sh worker-tick engineer-a
tools/squad/squad.sh signal engineer-a complete --task-id L2-companion
tools/squad/squad.sh fail engineer-a L2-companion --reason "verify failed"
```

## 监督循环（supervise）

每个并行角色应有 **while**，出口仅三种：

| 出口 | 含义 |
|------|------|
| `complete` | `assess.ready`（自动+人工门禁全过） |
| `failed` | 任务 `failed` / 角色信号 `failed` / `stuck_policy=fail` |
| `timeout` | 全局 `supervisor.timeout_sec` 或任务 `task_timeout_sec` |

`catalog.supervisor` 配置超时与 `poll_interval_sec`；`signals` 表记录 `supervisor` 与各 `engineer-*` 状态。

**禁止**：只跑一轮 `dispatch` 后在 manual 仍 pending 时停止 — 应 `supervise` 或 Cloud Agent 反复 `supervise --once`。

## 角色微工作流

见 `squad/workflows/*.yaml`；`squad workflow-run commander` 打印步骤。
