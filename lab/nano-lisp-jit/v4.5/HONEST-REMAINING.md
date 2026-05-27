# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 物理 GAP（与用户期望 · 2026-05-27）

| 维度 | 用户期望 | 现状（`release/nano-lisp.com`） | GAP |
|------|----------|--------------------------------|-----|
| **6 面 APE** | 3 OS × 2 ISA | APE v2：**2 slice · Linux only** | **4/6 面缺失** |
| **纯 Lisp 自举** | 无 genesis promote | promote + genesis pin 链仍在 | 工厂种子逻辑未消 |
| **零 host sh** | 用户 + CI plan-only | 用户 ✅ · CI `retired/scripts/*.sh` + `run.sh` | 工厂 host 仍在 |
| **COM 瘦 slice** | 双架构瘦 runner | aarch64 ≈648KB genesis EXEC（~81% 体积） | aarch64 未 codegen |

详见 [`EVIDENCE-GAP-AUDIT.md`](EVIDENCE-GAP-AUDIT.md) · [`archive/specs/APE-v2.md`](../archive/specs/APE-v2.md)

## 当前阶段：Wave70 daily-zero-archive-audit

| 活图 | 说明 |
|------|------|
| [`mindmap-frontier-v45-daily-zero-archive-audit.json`](mindmap-frontier-v45-daily-zero-archive-audit.json) | 7 节点 · 活跃 plan 零 archive/c |
| [`ARCHIVE-PATH-AUDIT.md`](ARCHIVE-PATH-AUDIT.md) | 活跃 vs 历史 plan 审计 |
| [`DIFFUSE-WAVE70.md`](DIFFUSE-WAVE70.md) | Wave70 SSOT |

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-daily-zero-archive-audit.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py stats
```

## 完成路径（Wave62–69 · 已签收 ≠ DONE）

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| COM 进仓 | release | — | `release/nano-lisp.com` git 跟踪 |
| wave sh 终局 | 67 | ✅ plan-only daily | scripts/ 零 active sh |
| Lisp 自举链退种子 | 68 | ✅ selfhost chain | genesis promote 仍在 |
| run.sh 工厂面分层 | 69 | ✅ factory honest | **run.sh 仍在 · 用户不依赖** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.daily_zero_archive_audit_continue.100=1` | Wave70 分卷（**≠ v4.5 DONE**） |
| `v45.honest.active_daily_zero_archive_steps=1` | 活跃 daily/prove 零 archive/c 步骤 |
| `v45.converge.daily_v45_zero_archive_audit_terminal=1` | 当前用户 daily |

## 日常

```bash
# Wave70 daily（默认）
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-audit-terminal.lisp

# 收敛
bash lab/nano-lisp-jit/retired/scripts/v45-wave70-daily-zero-archive-audit-converge.sh
```

## 下一物理轨

| 候选 | 说明 |
|------|------|
| 纯 Lisp 自举 COM promote | 零 genesis promote · 代际 COM |
| APE 6 面规格 | Cosmo apelink vs Nano 6 行表 |
| aarch64 瘦 slice | 替代 genesis 648KB EXEC |
