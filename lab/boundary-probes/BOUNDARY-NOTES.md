# 能力边界归纳（人工）

配合 `probes/*.lisp` 与 `run-probes.sh` 自动表 `RESULTS.md`。用于 v1.5 期间观察，**不阻塞**主 agent 的 manifest 工作。

## 已确认边界

### 语言 / 解析

| 边界 | 证据 |
|------|------|
| `func` 体必须多行 s-exp，不能 `(func f (u64 1))` 单行 | `multi-func-chain` 初版 parse=fail；改为与 `samples/multi-func.lisp` 同形后通过 |
| 无 `main` → compile 失败 | `missing-main-bad` |
| 重复 `label` → compile 失败 | `duplicate-label-bad` |
| **`(func …)` 不能进 `.lbin`**：`compile` 仅接受单 `main` 模块；多函数须 `compile-elf64-obj-code` / `compile-elf64-exe` | `multi-func-lbin` fail；`multi-func-chain-aot` ok |
| 递归 internal `call` → compile-elf64 失败 | 已有 `multi-func-recursive-bad.lisp` |

### 控制流

| 边界 | 证据 |
|------|------|
| `branch` 为 false 时**顺序执行**下一指令，不跳到 label | `branch-label-not-barrier` 前半 |
| **`label` 不是屏障**：落到 label 后会继续执行 label 后面的指令 | `branch-label-not-barrier`（expect 42 通过后仍执行 `u64 1`） |
| `branch` 必须消费上一条 `bool`；非 bool 已在 type-error 覆盖 | `type-error-branch-bad.lisp` |

### 类型 / 路径分裂（VM vs AOT）

| 边界 | 证据 |
|------|------|
| **`i64` 常规模立即数（如 42）**：VM + `compile-elf64-code` 可工作 | `i64-aot-unsupported` |
| **`i64` INT64_MIN 立即数**：VM `run` 可；`compile-elf64-code` → `unsupported_source`；`aot-elf64-code` → `unsupported_blob` | `aot-i64-extremes` |
| **纯 `u64` 主路径**：VM + `compile-elf64-code` + `aot-elf64-code` 对齐 | `many-ops-u64`、`arithmetic.lisp` |
| internal `call` 返回类型与后续 op 不匹配 → compile 失败或 miscompile | `call-wrong-ret-bad` compile fail |

### 数值

| 边界 | 证据 |
|------|------|
| VM 可表示/执行 `i64` 全范围立即数（含 INT64_MIN/MAX） | `i64-extremes` |
| `add-ptr` 大偏移对 null 基址按 u64 算术 | `ptr-arith-large-offset` |
| `store-u8/u16/u32` 立即数范围在 compile 期检查 | 已有 type-error-store-*-range |

### FFI

| 边界 | 证据 |
|------|------|
| 不存在符号 `resolve` 失败 | `unknown-import-bad` |
| 多 import + resolve + call 可工作 | `many-imports-resolve`（需 strcmp 字符串一致） |
| `run` 退出码 = 最后返回值（如 getpid），不适合 `set -e` 成功判定 | 见 `LAB-USAGE-FEEDBACK.md` |

### 规模（当前探测上限，非硬上限）

| 探测 | 结果 |
|------|------|
| 控制流嵌套 depth≈4 | `deep-branch-chain` 通过 |
| 内部函数链 depth=4 | `multi-func-chain` 通过 |
| 单函数 ~30 条 `add-u64` | `many-ops-u64` 通过（见 RESULTS） |

未探测：指令数上限、func 个数上限、const 字符串长度上限、`.lbin` 文件大小上限。

### 平台

| 边界 | 证据 |
|------|------|
| `compile-elf64-*` / `link-elf64-*` / `aot-elf64-code` 仅 x86_64 Linux | `run.sh` skip 分支 |
| APE / pack 依赖 cosmocc slice（v1） | `build_nano_jit.sh` |

## 与 v1.5 的关联

- **text 内嵌数据 + RWX**：const-ptr/load/store 已可用；边界探测未改权限模型。
- **APE manifest**：本目录不覆盖；由主 agent v1.5 slice 验证。

## 建议后续探测（待加 probe）

1. 自动生成 500/5000 条 op 的 `.lisp`，看 compile/run 时间与是否 OOM。
2. `const` 字符串 4KB/64KB 是否限制。
3. `compile-elf64-obj-code` 函数数量 32+ 与 rel32 溢出（已有 linker rel32 range negative smoke）。
4. `bootstrap` DSL 步骤数上限。

## 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-21 | 初版：12 个 probe + RESULTS 自动生成 |
