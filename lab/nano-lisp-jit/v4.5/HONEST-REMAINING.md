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

## 当前阶段：honest-cleanup（Wave70+ 冻结）

**不是新 Wave 功能波**。先整理 SSOT + mindmap 工作池，再开下一 falsifiable 目标。

| 活图 | 说明 |
|------|------|
| [`mindmap-frontier-v45-honest-cleanup.json`](mindmap-frontier-v45-honest-cleanup.json) | 7 节点 · 四轨 · `v45.honest.cleanup_pool=1` |
| [`DIFFUSE-WAVE-CLEANUP.md`](DIFFUSE-WAVE-CLEANUP.md) | 清理环 SSOT |

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-honest-cleanup.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready
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
| `v45.honest.cleanup_pool=1` | SSOT 整理 · Wave70+ 冻结 |
| `v45.v45.run_sh_archive_honest_continue.100=1` | Wave69 分卷（**≠ v4.5 DONE**） |
| `v45.honest.run_sh_factory_only=1` | run.sh 仅 CI/工厂 |
| `v45.converge.daily_v45_honest_cleanup=1` | 当前用户 daily |

## 日常

```bash
# 清理轨（默认 · Wave70+ 冻结）
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-honest-cleanup.lisp

# 收敛
bash lab/nano-lisp-jit/retired/scripts/v45-honest-cleanup-converge.sh
```

## 下一物理轨（冻结中 · 需用户确认）

| 候选 | 说明 |
|------|------|
| daily 零 archive 审计 | 活跃 plan 无 `archive/c` 路径 |
| APE 6 面规格 | Cosmo apelink vs Nano 6 行表 — **须选定 SSOT** |
| 纯 Lisp 自举 COM | 无 genesis promote |

**停损线**：`v45.honest.cleanup_pool=1` 且用户确认前，禁止新开 `*.continue.100` 波。
