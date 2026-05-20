# nano-jit roadmap

目标：用 Lisp/IR 恢复可编程系统的锋利度，推进到 `nano-jit.com` 能自己编译自己，并生成多架构可运行 APE。

## 洋葱 TDD 层

每一层必须有可重复脚本证据，能跑通后才进入下一层。

### 0. 证据基线

- `run.sh`：native 编译、`.lisp -> .lbin`、JIT/FFI 执行、全量 libc resolver。
- `build_nano_jit.sh`：生成 `nano-jit.com`，记录大小、hash、bootstrap 阶段。
- 目标：每次进展都能证明没有破坏旧 `.ljir`、`.lbin`、self-pack、AOT app。

### 1. IR/VM 内核

- 增加 typed value：`i64`、`ptr`、`str`、`bool`。
- 增加基本 op：`const`、`move`、`branch`、`call`、`ret`。
- 增加断言 op，用 `.lbin` 自测替代 shell 解析输出。
- 验收：同一个 `.lisp` 能编译为 deterministic `.lbin`，dump/hash 稳定。

### 2. FFI/JIT 核心

- 扩展签名表：整数、指针、双参数、多返回错误码。
- 引入 ABI call descriptor，逐步替换硬编码 typed C call。
- 保留 micro-JIT 快路径；复杂签名后续接 libffi-dl 或自研 tiny ABI bridge。
- 验收：safe libc suite 通过；resolver-only 全量 libc 继续通过。

### 3. AOT app

- `pack-app` 生成内嵌 `.lbin` 的 `.com` 应用。
- `run-embedded` 从自身容器 payload 直接读取 blob，不依赖外部 blob 文件。
- `run-app` 可按 manifest 自动定位 `.com` 内嵌 blob 并执行。
- 验收：`libc-smoke-app.com` 不带参数直接运行。

### 4. self-pack / APE linker

- 当前：`pack-ape` 已由刚编出的 `nano-jit` 自己执行，不调用 `apelink`。
- 下一步：从 shell stub stage0 进化为真 APE loader/container writer。
- 目标：完全替换 `cosmocc` 的 `apelink`。
- 验收：生成 x86_64/aarch64 `.com`，Linux/macOS 路径逐步验证。

### 5. 编译器自举

- 用 `.lisp` 描述足够多的 nano-jit 构建逻辑。
- 增加 C-subset 或 Lisp-to-IR 编译层，先生成 runtime object/slice 描述。
- 阶段目标：`nano-jit.com` 读取源码/IR，生成下一代 `.lbin` 或 app。
- 终局目标：`nano-jit.com` 生成自己的多架构 `nano-jit.com`。

### 6. 替换外部 slice compiler

- 当前 `cosmocc` 只保留为临时架构 slice compiler。
- 路线 A：接入 TinyCC/自研 C-subset 后端，生成 ELF slice。
- 路线 B：从 IR 直接 AOT 到 x86_64/aarch64 ELF。
- 验收：`build_nano_jit.sh` 不再需要 `cosmocc`。

## 当前下一刀

最新稳定基线：`nano-jit.com` 已能 self-pack，不调用 `apelink`；能从纯 VM `.lisp` 直接生成 ELF/object；能把 nano 生成的多个 ELF64 object 用自带 tiny linker 链成可运行 ELF。

下一步优先级：

1. 把最小 control flow 子集继续接到机器码 AOT/codegen 路径，逐步缩小静态求值-only 语义。
2. 继续扩大 bootstrap DSL：在已落地的 `compile/hash/compare/pack-app/inspect-app/run-app/run` 基础上，再接更丰富的可验证步骤。
3. 持续缩小临时依赖：`cosmocc` 只保留为 slice compiler，下一阶段目标是生成 x86_64 slice 的可运行子集。
4. 继续扩大 typed/AOT 交集：让 `i64`、`bool`、以及后续 `ptr` 子集逐步进入 object/codegen 路径；先补齐多函数 source AOT。

已完成：

- AOT app 直接从 `.com` payload 读取内嵌 blob 执行。
- AOT app 结构化 manifest、`inspect-app` 和 `run-app`。
- deterministic `.lbin` hash/byte compare 测试。
- `compare` CLI 已替代系统 `cmp` 执行 deterministic blob 对比。
- `file-size` CLI 已替代 nano-lisp-jit smoke 报告中的 `wc -c` 字节统计。
- `file-hash` CLI 已替代 `nano-jit.com` 报告中的 `sha256sum` 外部 hash。
- `gen-libc-resolve` CLI 已替代 libc resolver manifest 的 Python/`nm` 生成链路。
- `run-expect-exit` CLI 已替代 native AOT smoke 中的 shell 退出码包装。
- `link-expect-exit` CLI 已替代 duplicate-symbol linker 负向 smoke 的 shell 包装。
- `(expect N)` 断言 op，smoke `.lbin` 可自证关键 FFI/JIT 结果。
- `(u64 N)` / `(add-u64 N)` 纯 VM 算术 smoke，不依赖 FFI/libc。
- `i32(i32)` FFI 签名，smoke 覆盖 `abs(-42) -> 42`。
- `emit-elf64-exit` tiny ELF writer，直接生成可运行 x86_64 Linux ELF。
- `aot-elf64-exit` 可把纯 VM `.lbin` 静态求值并生成 ELF。
- `aot-elf64-code` 可把纯 VM typed/control-flow 子集编译为 x86_64 机器码 ELF。
- `emit-elf64-obj-ret` 可生成带 section/symbol table 的 ELF64 relocatable object。
- `emit-elf64-obj-call` 可生成带 `.rela.text` 的 ELF64 object，验证外部符号 relocation。
- `aot-elf64-obj-ret` 可把纯 VM `.lbin` 编译为可链接 ELF64 function object。
- `aot-elf64-obj-code` 可把纯 VM `.lbin` 编译为包含真实机器码的可链接 function object。
- `link-elf64-exe` 可链接当前 nano object 子集，初步替代系统 linker。
- `compile-elf64-code` / `compile-elf64-obj-code` 可直接从 `.lisp` 生成 ELF/object。
- tiny linker 支持多 object、`R_X86_64_PLT32` relocation、重复符号拒绝和 rel32 范围检查。
- native/container AOT object 验证已从系统 `cc` linker oracle 迁到 nano `link-elf64-exe`。
- ELF/object/linker 内部 API 已抽象成可复用 helper，减少 section/symbol/rela 写入与解析重复。
- typed value 已覆盖 `i64`、`bool`、`ptr` 基础值；`resolve` 会产出 `ptr` 值。
- typed 算术/比较已覆盖 `add-i64` / `sub-i64` / `mul-i64` / `eq-i64` / `ne-i64` / `lt-i64` / `gt-i64`，进入解释执行、静态求值 AOT 和 x86_64 codegen/object 路径。
- `expect` 已支持负数、布尔值和 `null` / `nonnull` 指针断言。
- `block` / `branch` / `label` 已可编译进 `.lbin` 并由解释执行路径运行。
- control-flow pure blob 已能走机器码 codegen AOT 路径，覆盖 `aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code`。
- `compile-elf64-obj-code` 已支持多函数 pure VM source、内部 `call`、基础 relocation，以及 `i64` / `bool` / `branch` / `label` typed/control-flow 子集。
- 多函数 object 可同时被系统 `cc` 与 nano 自带 tiny linker 链接并运行。
- `compile-elf64-exe` 已可把多函数 pure VM source 直接生成可运行 ELF，内部走 object backend + tiny linker。
- `bootstrap` 最小 DSL 已落地，可用 `.lisp` 顺序描述并执行核心 `.lbin` 样例矩阵、`compile` / `gen-libc-resolve` / `dump` / `file-size` / `file-hash` / `hash` / `compare` / `pack-app` / `inspect-app` / `run-app` / `run` 子流程。
- `bootstrap` DSL 已可驱动 AOT/codegen/tiny-link executable smoke，覆盖 `emit-elf64-exit`、`emit-elf64-obj-*`、`aot-elf64-*`、`compile-elf64-*`、`file-size` / `file-hash` 产物检查、`resolve-quiet`、多 object `link-elf64-exe`、直接 executable 编译、失败状态断言和 `run-expect-exit`，开始把更多 build graph 从 shell 迁入 nano 描述。
- control-flow pure blob 已能走静态求值 AOT 路径，生成 `aot-elf64-exit` / `aot-elf64-obj-ret` 产物。
