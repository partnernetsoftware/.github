# v4.5 签收决策

**前提**：v4 **lispjit-from-lisp 子轨 DONE**（gen60 · `semantic-terminal`）；v4 **scoped catalog** 已闭合。v4.5 开卷 **终局未做部分**（`v4/DECISION.md` 刻意排除项）。

## 北极星（发行面）

用户路径上只保留：

```text
nano-jit.com          # 唯一二进制入口（seed；对外可称 nano-lisp.com）
**/*.lisp             # 源码、模块、bootstrap plan、verify 矩阵
genesis/*.x86_64      # 可选 bootstrap pin（非日常 host cc）
```

**开发工厂**（`run.sh`、`lispjit.c`、`gen-*.py`）可与发行面分离；tier0 不要求立刻删除。

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
| **0** | `v45-tier0-entry` | `bootstrap-v45-entry.lisp` 绿；`.com` 可跑同 plan（有 `.com` 时） | `v45.entry.ok=1` |
| **1** | `v45-tier1-verify` | CI/开发者主路径：`nano-jit.com run-bootstrap-plan verify/*.lisp`；无 shell 纵切片 | `v45.verify.plan_only=1` |
| **2** | `v45-tier2-no-host-cc` | 日常 `build-slice` 禁 silent `stage0-bridge`；仅 genesis-pin / nano-cc / Lisp codegen | `v45.build.no_host_cc=1` |
| **3** | `v45-tier3-no-c-src` | repo 无 `lispjit.c` 源码；runner 仅 seed + 自举 `.com` | `v45.runner.no_c_src=1` |
| **4** | `v45-tier4-vm-emit` | C 表驱动 emit → Lisp IR + VM/AOT（对齐 `TERMINAL-BFS` AOT 轨） | `v45.codegen.vm_emit=1` |

**当前开卷**：**tier0**（本 PR）。

## tier0 交付（本波）

| 产物 | 路径 |
|------|------|
| 规格 | `v4.5/DECISION.md`（本文件）、`v4.5/README.md` |
| 入口 plan | `samples/bootstrap-v45-entry.lisp` |
| verify 纵切片 | `samples/bootstrap-v45-verify-smoke.lisp`（~run.sh 前段 VM 子集） |
| 证据 rollup | `samples/bootstrap-v45-entry-evidence.lisp` |
| 门禁 | `run.sh` + `squad/catalog-v45.yaml` |

### tier0 验收

```bash
# host runner（开发工厂仍可用）
lab/nano-lisp-jit/.build/nano-lisp-jit run-bootstrap-plan \
  lab/nano-lisp-jit/samples/bootstrap-v45-entry.lisp

# 发行面路径（需已 build nano-jit.com）
lab/nano-lisp-jit/.build/nano-jit/nano-jit.com run-bootstrap-plan \
  lab/nano-lisp-jit/samples/bootstrap-v45-entry.lisp

grep v45.entry.ok=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

### tier0 刻意未声称

- 仓库零 `.sh` / `.c` / `.py`
- 154KB runner 由 Lisp 全量 codegen（仍可用 genesis pin）
- 替换 `run.sh` 全部 1212 case

## 规则

```text
v45.entry.ok=1           → tier0 可签收
v45.verify.plan_only=1   → tier1（未开卷）
终局六维 100%            → tier4 全部 + 工厂退役策略（另文）
```

## 下一刀（tier1 草图）

1. 从 `run.sh` 再抽 50 case → `bootstrap-v45-verify-core.lisp`
2. CI job 仅：`./nano-jit.com run-bootstrap-plan samples/bootstrap-v45-verify-smoke.lisp`
3. `catalog-v45.yaml` gate `min_pass` 随 verify 矩阵上调
