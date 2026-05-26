# v4.5 签收决策

**前提**：v4 **lispjit-from-lisp 子轨 DONE**（gen60 · `semantic-terminal`）；v4 **scoped catalog** 已闭合。v4.5 开卷 **终局未做部分**（`v4/DECISION.md` 刻意排除项）。

## 发行面（用户路径）

```text
nano-lisp.com         # 对外名；仓内暂 .build/nano-jit/nano-jit.com
lisp/**/*.lisp        # bootstrap · modules · core · boundary
```

plan 内不出现 `.c` / `.sh` / `.py`；工厂在 `archive/c/`。  
扩散：[`MINDMAP-TDD-TREE.md`](MINDMAP-TDD-TREE.md) · Wave35 [`DIFFUSE-WAVE35.md`](DIFFUSE-WAVE35.md)。

## 与 v4 的分界

| 项 | v4 | v4.5 |
|----|-----|------|
| lispjit-from-lisp | ✅ DONE（pin + 15 TU 证明） | 不重复声称 |
| plan 无 `.c` | ~98% gate | 保持；扩 verify 矩阵 |
| 门禁载体 | `run.sh` 1212+ case | 迁入 `(bootstrap verify-*.lisp)` |
| runner 源码 | `lab/lispjit-ir/*.c` 在仓 | tier3 出仓，仅 `.com` 字节 |
| host `cc` | `stage0-bridge` 仍可能存在 | tier2 硬失败 |

## Tier 定义

| Tier | ID | 完成定义 | 验收键 |
|------|-----|----------|--------|
| **0** | `v45-tier0-entry` | `bootstrap-v45-entry.lisp` 绿；`.com` 可跑同 plan | `v45.entry.ok=1` |
| **1** | `v45-tier1-verify` | **`.com` only** 跑 verify 矩阵（smoke/core/handoff/all/entry） | `v45.verify.plan_only=1` |
| **2** | `v45-tier2-no-host-cc` | 日常 `build-slice` 禁 silent `stage0-bridge` | `v45.build.no_host_cc=1` |
| **3** | `v45-tier3-no-c-src` | repo 无 `lispjit.c` 源码 | `v45.runner.no_c_src=1` |
| **4** | `v45-tier4-vm-emit` | C 表驱动 emit → Lisp IR + VM/AOT | `v45.codegen.vm_emit=1` |

**当前签收（有口径）**：`v45.endgame.100=1`（DECISION tier0–4）· `v45.scoped.100` · `v45.release.100` · tier3/4 证据键。  
**物理终局（tier5 发行面）**：**100%** — `v45.tier5.100=1` · `v45.physical.zero_c=1` · 见 [`HONEST-REMAINING.md`](HONEST-REMAINING.md)

| 自举阶 | 状态 |
|--------|------|
| S2 lisp-slice | ✅ `v45.selfhost.lisp_slice=1` |
| S3 modules | ✅ `v45.selfhost.modules=1` |
| S4 regenesis | ✅ `v45.selfhost.regenesis=1` |
| S5 chain | ✅ `v45.selfhost.chain=1` |
| T3/T4 完全无 C codegen | 未开 |

## scoped 100% 签收（2026-05-24）

洋葱 TDD 真源：[`ONION-TDD.md`](ONION-TDD.md) · 评估：[`EVAL.md`](EVAL.md) · 反思：[`REFLECTION.md`](REFLECTION.md)

```bash
grep v45.scoped.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## tier1 交付（已签收）

| 产物 | 路径 |
|------|------|
| verify 核心 | `samples/bootstrap-v45-verify-core.lisp`（VM+ptr+multi-func+AOT/APE/pack-app） |
| v4 交接 | `samples/bootstrap-v45-v4-handoff.lisp`（gen60/genesis/.com 锚点） |
| verify 索引 | `samples/bootstrap-v45-verify-all.lisp` |
| com-only 门禁 | `run.sh` → `run-bootstrap-v45-com-only-verify-plan` |

### 发行面验收（tier1 · 仅 `.com` + `.lisp`）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
for p in verify-smoke verify-core v4-handoff verify-all entry; do
  $COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp
done
grep v45.verify.plan_only=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

### tier1 刻意未声称

- 仓库零 `.sh` / `.c` / `.py`
- `run.sh` 全量 1212 case 已退役
- 154KB runner Lisp 全量 codegen

## tier0 交付（已签收）

| 产物 | 路径 |
|------|------|
| 规格 | `v4.5/DECISION.md`、`v4.5/README.md` |
| 入口 plan | `samples/bootstrap-v45-entry.lisp` |
| verify 纵切片 | `samples/bootstrap-v45-verify-smoke.lisp` |
| 证据 | `.build/v45-entry.evidence` → `v45.entry.ok=1` |

## 规则

```text
v45.entry.ok=1           → tier0 ✅
v45.verify.plan_only=1   → tier1 ✅（本波目标）
v45.build.no_host_cc=1   → tier2（下一刀）
终局六维 100%            → tier4 + 工厂退役
```

## 下一刀（tier2 草图）

1. `build-slice` 遇 `stage0-bridge` → exit 1（除 genesis 刷新路径）
2. `bootstrap-v45-build-slice-genesis.lisp` 证明日常零 host cc
3. 证据键 `v45.build.no_host_cc=1`
