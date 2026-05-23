# Squad 并行 — 排障

| 现象 | 处理 |
|------|------|
| wave 飙到 50+ | 每波 `resume`（重置 wave=1） |
| signoff 100% 空转 | 已修复：`team_ready` → `complete` |
| follower 签收后空等 | `team_ready` 即 `stand_down` |
| `agent-team` FileNotFoundError | tmux 须 `["tmux","-f",…]` argv（已修 `spawn_agent_team`） |
| `auto-exec` 超时 | 先本地 `run.sh`；或用 `SQUAD_VERIFY=1`；避免 verify 内再 `auto-exec` |
| dispatch「100% — no dispatch」 | 任务已 `assigned` 时正常；靠 `run-loop` 推进 |
| assess 暂时 96% | `tests.pass` 未写入；smoke 放在 `run_end_summary` 后 |
| 并行 claim 冲突 | `wait_lock` 轮询 |
| 一直慢、CPU 空转 | tmux 无 LLM：停 agent-team，单 Agent 快路径；或等 `touch_paths` 再 verify |
| 每几秒跑一次 run.sh | `auto-exec` + `in_progress`；已 defer_verify / 失败冷却 45s |
| `max-iter` 很快 timeout | `run-wave.sh` 须 ≥500，勿用 40 |
