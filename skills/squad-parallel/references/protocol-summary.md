# Squad 协议摘要（并行小队）

## 三层

| 层 | 文件 | 变更频率 |
|----|------|----------|
| 契约 | `catalog.yaml` | 低（任务图、signoff gates） |
| 运行时 | `.squad/state*.db` | CLI 独占写 |
| 叙事 | `v4/SQUAD.md` 等 | `sync-md` 生成 |

## Leader 信号（`supervisor`）

| 信号 | Follower |
|------|----------|
| `running` | 继续 claim/work |
| `standby` | 仍有任务；禁止自行 complete |
| `complete` / `failed` / `timeout` | `stand_down`，退出 `run-loop` |

## CLI 入口（统一）

- 所有角色：`squad run-loop --role <id>`
- 并发：`squad agent-team`（tmux 四会话）
- 仅指挥长：`supervise` / `supervise --once`

## team_mode

`supervisor.team_mode: true`（默认）：signoff ready 不会立刻解散；须 `team_ready_to_release`（全任务 terminal + 无 inflight 指派）。
