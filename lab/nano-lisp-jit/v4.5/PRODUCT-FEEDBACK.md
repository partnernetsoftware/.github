# nano-jit.com 能力边界 → 产品改进清单

> 由 `samples/boundary/*.lisp` + `bootstrap-v45-boundary-*.lisp` 探测归纳。  
> 验收仍走洋葱 TDD（`*.lisp` only）；本文档供 **产品/引擎** 排期，不阻塞 `v45.scoped.100`。

## 摘要

| 层 | 现状 | 建议 |
|----|------|------|
| **OS / proc（Wave89–90）** | `run-expect-exit`/`spawn-wait` + **`read-file`** 已入 bootstrap；release COM 待 promote | release cosmocc rebuild · bulk→语义 |
| VM `.lbin` | 算术/比较/ptr/u8/u16/多函数 call 稳定 | 补齐 func 内 CF |
| VM 类型检查 | 部分 ill-typed 源可 `compile` 通过 | 与 AOT 对齐拒错 |
| AOT `.elf` | 多函数 + func 内 block/branch OK | 保持 parity 目标 |
| 发行面 | scoped 100% 已签收 | tier3+ 再动 C/runner |

## 探测矩阵

| ID | 样例 | VM run | AOT exe | 现象 | 产品动作 |
|----|------|--------|---------|------|----------|
| B01 | `func-block-vm-gap.lisp` | ❌ `func.unsupported.op=11` | ✅ exit 42 | func 内 block/branch 无 VM | 实现 VM opcode 或文档「仅 AOT」 |
| B02 | `type-error-ptr-op-bad.lisp` | ⚠️ compile 过 | ❌ exe | VM 不拒 ptr 类型误用 | VM compile 应 exit 2 |
| B03 | `type-error-load-u8-bad.lisp` | ⚠️ compile 过 | ❌ exe | 同上 | 同上 |
| B04 | `store-load-u32`（未收录正向） | — | — | 曾测红 | 支持或明确拒绝并给错误码 |
| B05 | `func-param-missing-param-bad` | ✅ exit 2 | — | VM 拒错正确 | 保持 |
| B06 | `multi-func-call.lisp` | ✅ | ✅ 43 | 基准 | 保持 |
| B07 | `load-u16-rodata` / `store-u16-mutate` | ✅ | — | rodata 变宽读写 | 文档化 mutability |
| B08 | `NANO_SELFHOST_REUSE_*` 环境 | compare 漂移 | — | 非样例；运维 | 文档 + 默认 genesis |
| B09 | `v45-w3-lisp-only.com` | exit 42 only | — | **非**完整 runner；`run-bootstrap-plan` 不可用 | 产品区分 slice 探针 vs `nano-jit.com` |
| B10 | proc-smoke plan | ✅ fork 链 | — | 仅无 argv 的 `execv`；制品读靠 file-size/hash | `read-file` + `spawn-wait` |
| B11 | proc-io plan（Wave90） | ✅ read-file/spawn-wait | — | factory slice cc 验收；release COM 未 promote | cosmocc promote |

## 推荐引擎优先级

0. **P0（Wave91+）** — release COM cosmocc promote（携带 read-file/spawn-wait）

1. **P0** — VM 实现 func 内 `block`/`branch`（闭合 B01，与 AOT parity）  
2. **P1** — VM `compile` 类型检查对齐 AOT（B02/B03）  
3. **P2** — `load-u32` / `store-u32` 明确支持或统一 `unsupported`（B04）  
4. **P3** — tier3 runner 出仓（发行面已与工厂分离）

## 如何复现

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com

# B01 VM 红 / AOT 绿
$COM compile lab/nano-lisp-jit/lisp/boundary/func-block-vm-gap.lisp /tmp/gap.lbin
$COM run /tmp/gap.lbin   # → func.unsupported.op=11
$COM compile-elf64-exe lab/nano-lisp-jit/lisp/boundary/func-block-vm-gap.lisp /tmp/gap.elf nano_gap
$COM run-expect-exit /tmp/gap.elf 42

# 全矩阵
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-boundary-probe.lisp
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-boundary-negative.lisp
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-boundary-feedback.lisp
```

## 与签收关系

- **`v45.scoped.100=1`**：发行面洋葱 + plan 矩阵 ✅  
- **本文件**：能力上限与改进 backlog，≠ 阻塞 scoped DONE  
