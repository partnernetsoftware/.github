# v4.5 — 发行面 = `nano-jit.com` + `*.lisp`

> **范围**：本仓库只维护 **nano-lisp-jit**；**fasmgx**（fasmg + `.fg`）为独立项目，勿在本仓建 `fasmgx/` 目录。

**前置**：v4 lispjit-from-lisp DONE · tier0 ✅

## 发行面验收（tier1 · 仅 `.com`）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
for p in verify-smoke verify-core v4-handoff verify-all entry; do
  $COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp
done
grep v45.verify.plan_only=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## verify 矩阵

| plan | 覆盖 |
|------|------|
| `bootstrap-v45-verify-smoke.lisp` | VM 前缀（strlen/arithmetic/ctrl/emit） |
| `bootstrap-v45-verify-core.lisp` | multi-func/ptr/AOT/APE/pack-app |
| `bootstrap-v45-v4-handoff.lisp` | v4 gen60/genesis/.com + lispjit-modules |
| `bootstrap-v45-verify-all.lisp` | 矩阵索引 + `.com` hash |
| `bootstrap-v45-entry.lisp` | tier0 入口 + 锚点 |

## Tier 进度

| Tier | 状态 |
|------|------|
| 0 entry | ✅ |
| 1 com-only verify | ✅ |
| 2 genesis build-slice | ✅ |
| **scoped 100%** | **✅** |
| **DECISION tier0–4** | **✅** `v45.endgame.100=1` |
| **合卷（非零 C）** | **✅** `v45.warehouse.100=1` |
| **物理零 C（发行面树）** | **✅** | `v45.physical.zero_c=1`（`lisp/` 无真 `.c`；**≠** 全 monorepo） |
| 3 `lispjit.c` 出仓 | **✅** `v45.runner.no_c_src=1` |
| 4 VM emit（IR Lisp） | **✅** `v45.codegen.vm_emit=1` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave10-honest-converge.sh
grep v45.physical.zero_c=0 lab/nano-lisp-jit/.build/v45-entry.evidence
```

口径：[`DECISION.md`](DECISION.md) · [`PROGRESS.md`](PROGRESS.md) · [`HONEST-REMAINING.md`](HONEST-REMAINING.md)

## 日常（Wave53 · v4.5 物理）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp
bash lab/nano-lisp-jit/scripts/v45-wave53-lispjit-154kb-codegen-expand-converge.sh
```

真目标与完成路径：[`HONEST-REMAINING.md`](HONEST-REMAINING.md)
