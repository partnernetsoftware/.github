# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| wave sh 终局 | 67 | ✅ `daily_v45_com_plan_only_terminal` | scripts/ 零 active sh |
| Lisp 自举链退种子 | 68 | ✅ `daily_v45_lisp_selfhost_chain` | CI run.sh 工厂面仍在 |
| **run.sh 工厂面分层** | **69** | ✅ `daily_v45_factory_honest_terminal` | **run.sh 仍在 · 用户不依赖** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.run_sh_archive_honest_continue.100=1` | Wave69 四轨 + run.sh 工厂面诚实分层 |
| `v45.honest.run_sh_factory_only=1` | `run.sh` 仅 CI/工厂面 |
| `v45.honest.archive_symlink_ci_only=1` | `archive/c/` 经 symlink 仅 CI 读 |
| `v45.converge.daily_v45_factory_honest_terminal=1` | 用户 daily 工厂诚实终局 |
| `v45.selfhost.run_sh_archive_honest_matrix=1` | 代际 run.sh 诚实矩阵 |

## 日常

```bash
# 用户路径（工厂诚实终局 · Wave69）
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp

# CI 收敛（retired 壳 · run.sh 工厂面仍 host bash）
bash lab/nano-lisp-jit/retired/scripts/v45-wave69-run-sh-archive-honest-converge.sh
```

## 下一物理轨

Wave70：活跃 daily/prove plan 零 archive/c 路径审计 · v4.5 终局冲刺
