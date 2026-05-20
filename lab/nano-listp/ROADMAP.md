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
- 下一步：结构化 manifest，记录 slice/blob offset、size、hash、target arch。
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

1. 扩展 AOT object backend：从单函数推进到多函数、内部 call、基础 relocation 生成。
2. 把最小 control flow 子集继续接到 AOT/静态求值路径，逐步缩小 runtime-only 语义。
3. 开始 tiny self-host 描述：用 `.lisp` 描述 bootstrap pipeline 的一部分，逐步替代 shell。
4. 持续缩小临时依赖：`cosmocc` 只保留为 slice compiler，下一阶段目标是生成 x86_64 slice 的可运行子集。

已完成：

- AOT app 直接从 `.com` payload 读取内嵌 blob 执行。
- AOT app 结构化 manifest 和 `inspect-app`。
- deterministic `.lbin` hash/byte compare 测试。
- `(expect N)` 断言 op，smoke `.lbin` 可自证关键 FFI/JIT 结果。
- `(u64 N)` / `(add-u64 N)` 纯 VM 算术 smoke，不依赖 FFI/libc。
- `i32(i32)` FFI 签名，smoke 覆盖 `abs(-42) -> 42`。
- `emit-elf64-exit` tiny ELF writer，直接生成可运行 x86_64 Linux ELF。
- `aot-elf64-exit` 可把纯 VM `.lbin` 静态求值并生成 ELF。
- `aot-elf64-code` 可把纯 VM 算术 op 编译为 x86_64 机器码 ELF。
- `emit-elf64-obj-ret` 可生成带 section/symbol table 的 ELF64 relocatable object。
- `emit-elf64-obj-call` 可生成带 `.rela.text` 的 ELF64 object，验证外部符号 relocation。
- `aot-elf64-obj-ret` 可把纯 VM `.lbin` 编译为可链接 ELF64 function object。
- `aot-elf64-obj-code` 可把纯 VM `.lbin` 编译为包含真实机器码的可链接 function object。
- `link-elf64-exe` 可链接当前 nano object 子集，初步替代系统 linker。
- `compile-elf64-code` / `compile-elf64-obj-code` 可直接从 `.lisp` 生成 ELF/object。
- tiny linker 支持多 object、`R_X86_64_PLT32` relocation、重复符号拒绝和 rel32 范围检查。
- ELF/object/linker 内部 API 已抽象成可复用 helper，减少 section/symbol/rela 写入与解析重复。
- typed value 已覆盖 `i64`、`bool`、`ptr` 基础值；`resolve` 会产出 `ptr` 值。
- `expect` 已支持负数、布尔值和 `null` / `nonnull` 指针断言。
- `block` / `branch` / `label` 已可编译进 `.lbin` 并由解释执行路径运行。
- control-flow 程序在当前 AOT 子集上会显式报 `unsupported_blob`，避免 silent wrong code。
