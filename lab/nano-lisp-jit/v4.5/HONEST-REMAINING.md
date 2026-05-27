# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| wave sh 终局 | 67 | ✅ `daily_v45_com_plan_only_terminal` | scripts/ 零 active sh |
| **Lisp 自举链退种子** | **68** | ✅ `daily_v45_lisp_selfhost_chain` | **CI run.sh 工厂面仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.lisp_selfhost_bootstrap_chain_continue.100=1` | Wave68 四轨 + 种子 COM 迁 retired |
| `v45.honest.seed_com_retired=1` | `nano-jit.com` → `retired/com/` |
| `v45.converge.daily_v45_lisp_selfhost_chain=1` | 用户 daily Lisp 自举链 |
| `v45.selfhost.bootstrap_chain_promoted=1` | 产品 COM 来自自举链 promote |

## 日常

```bash
# 用户路径（Lisp 自举链 · Wave68）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp

# CI 收敛（retired 壳 · 诚实仍 host bash）
bash lab/nano-lisp-jit/retired/scripts/v45-wave68-lisp-selfhost-bootstrap-chain-converge.sh
```

## 下一物理轨

Wave69：CI `run.sh` 工厂面 symlink 诚实收口 · v4.5 终局冲刺
