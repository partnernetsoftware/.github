# 证据键 GAP 审计（v4.5 诚实 SSOT）

> **用途**：区分「能声称什么」与「不能声称什么」。`*.continue.100=1` **≠ v4.5 DONE**。  
> **活图**：[`mindmap-frontier-v45-honest-cleanup.json`](mindmap-frontier-v45-honest-cleanup.json)

## 层级总表

| 层级 | 键族 | 能声称 | 不能声称 |
|------|------|--------|----------|
| L0 | `scoped.100` · `release.100` | 发行面 plan/com 绿 | 全仓零 C |
| L1 | `tier5.100` · `physical.zero_c=1` | 发行面树零 C | monorepo 零 C · 154KB runner DONE |
| L6 | `goal.onion_tdd_tree_mindmap.100` | /goal 26/26 | v4.5 物理 DONE |
| L7 | `v45.*.continue.100` | 扩展活图 Wave34–69 分卷 | 全仓零 c/sh/py · 6 面 APE |
| L8 | `v45.honest.*` · `v45.converge.daily_*` | 用户 COM+plan 可收敛 · 工厂分层 | run.sh 已删 · genesis 已消 |
| **L9** | **`v45.honest.cleanup_pool=1`** | **SSOT 已整理 · Wave70+ 冻结** | **v4.5 目标达成** |

## 易误读键（夸大 → 诚实口径）

| 键 | 听像 | 实际 | 诚实替代 |
|----|------|------|----------|
| `v45.v45.v45_terminal_complete.100=1` | v4.5 终局 | Wave34–51 扩展 rollup | `HONEST-REMAINING.md` 仍 ❌ |
| `v45.selfhost.100=1` | 完全自举 | S5+T3 代际卷 | `v45.honest.seed_com_retired=1` 仅种子退仓 |
| `v45.v45.lisp_com_bootstrap_terminal_continue.100=1` | COM 自举终局 | 活图 7/7 签收 | genesis promote 链仍在 |
| `v45.physical.zero_c=1` | 全仓零 C | 发行面树 | `v45.honest.lispjit_c_remains=1` |
| `v45.physical.zero_cpysh=1` | 零 c/sh/py | plan 面 scoped | `v45.honest.zero_cpysh_remaining=1` |
| `v45.v45.ci_plan_only_converge_continue.100=1` | CI 无 sh | 用户 daily plan-only | host `retired/scripts/*.sh` 仍在 |
| `v45.v45.run_sh_archive_honest_continue.100=1` | run.sh 已消 | 工厂面分层诚实 | `run.sh` 仍 host CI |

## 可保留键（诚实边界清晰）

| 键 | 含义 |
|----|------|
| `v45.honest.run_sh_factory_only=1` | run.sh = 工厂/CI，用户不依赖 |
| `v45.honest.archive_symlink_ci_only=1` | archive/c 经 symlink 仅 CI |
| `v45.honest.lispjit_c_retired=1` | 154KB C 已迁 retired |
| `v45.honest.host_sh_retired=1` | 活跃 scripts/ 零 sh |
| `v45.honest.seed_com_retired=1` | nano-jit.com 种子退 retired |
| `v45.converge.daily_v45_factory_honest_terminal=1` | 当前用户 daily 轨 |
| `v45.cleanup.reflect=1` · `v45.cleanup.canonical=1` | 清洗锚点 |

## 物理 GAP（与用户期望）

| 维度 | 用户期望 | 现状（release/nano-lisp.com） | GAP |
|------|----------|-------------------------------|-----|
| **6 面 APE** | 3 OS × 2 ISA（Cosmo Actually Portable） | APE v2：**2 slice · Linux only**（x86_64 154KB + aarch64 648KB genesis） | **4/6 面缺失**（无 macOS/Windows） |
| **纯 Lisp 自举** | plan 内零 genesis promote | promote 链 + genesis pin | 工厂种子逻辑仍在 |
| **零 host sh** | 用户 + CI 均 plan-only | 用户 ✅ · CI `retired/scripts/*.sh` + `run.sh` | 工厂 host 仍在 |
| **COM 瘦 slice** | 双架构瘦 runner | aarch64 = 完整 genesis EXEC (~81% 体积) | aarch64 未 codegen 瘦 slice |

## 停损线（清理后生效）

1. **禁止**新开 Wave70+ `*.continue.100` 功能波，直至 `v45.honest.cleanup_pool=1` 且用户确认下一 falsifiable 目标。
2. **禁止**把 L7 键写成「v4.5 完成」。
3. 下一活图须从 [`mindmap-frontier-v45-honest-cleanup.json`](mindmap-frontier-v45-honest-cleanup.json) DP `ready` 出槽，再四轨并行。
