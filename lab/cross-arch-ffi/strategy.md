# 综合方案探索

## 目标拆解

要同时满足四件事：

1. **体积小**：区分 runtime 体积、用户代码体积、JIT payload 体积。
2. **跨架构可执行**：同一入口或同一包覆盖 x86_64/aarch64，最好兼顾 Windows/macOS/Linux。
3. **动态执行**：不仅能编译源码，也能生成和执行机器码。
4. **FFI 调系统库**：能 `dlopen`/`dlsym` 并按目标 ABI 调用系统函数。

## 三层架构

### L0：最小 FFI + JIT 核心

组成：

- 动态库解析：`dlopen`/`dlsym`/Windows `LoadLibrary`。
- 可执行内存：`mmap(PROT_EXEC)`/`VirtualAlloc(PAGE_EXECUTE_READWRITE)`/macOS `MAP_JIT`。
- 每架构 call stub：把参数放入 ABI 指定寄存器，再跳到 FFI 函数地址。

意义：

- 这是“动态编译可执行字节”和“FFI 调系统库”的交汇点。
- 不需要完整编译器；适合表达固定签名或少量签名的高频调用。
- 当前 `byte_budget.c` 证明：x86_64 调 `strlen("ffi")` 的 JIT payload 是 23 字节。

限制：

- 每种函数签名都要知道 ABI。
- 复杂类型、变参、结构体返回需要 trampoline 或 libffi。

### L1：动态执行层

两条路线并存：

- **micro-JIT**：体积最小，生成字节直接执行；适合调用桩、表达式、热路径。
- **TCC/libtcc**：体积更大，但能动态编译 C；适合把复杂逻辑下放给 C 源码。

判断：

- “最小字节”应该优先走 micro-JIT。
- “功能大”需要 TCC，否则会把 ABI 和语义都手写到 runtime 里。

### L2：跨架构分发层

候选：

- **Cosmopolitan APE + TCC**：单入口、跨 OS/arch 能力强，runtime 约 MB 级。
- **per-arch bundle**：每架构一个小 runtime 或 TCC，包管理简单但入口不统一。
- **mini launcher**：小入口按架构派发 payload，折中。

判断：

- 追求“一个文件跑多平台”：用 CosmoRun/APE。
- 追求“每个平台最小体积”：用 per-arch native/TCC。

## 仓库现有资产

| 资产 | 可用性 | 作用 |
| --- | --- | --- |
| `cosmorun/cosmorun.exe` | 可运行 | APE + TCC，源码动态执行，支持系统库 FFI |
| `cosmorun/cosmo_trampoline.c` | 可参考 | Windows x64/ARM64 trampoline 和 JIT 内存处理 |
| `third_party/tcc*` | 部分可用 | per-arch TCC；当前缺 CRT 时链接失败，可 compile-only |
| `third_party/libffi-dl/*.so/.dylib/.dll` | 二进制存在 | 可作为未来通用 FFI 层候选 |
| `third_party/lua-5.4.7` | 源码存在 | 脚本层；标准 Lua 本身不是 FFI/JIT 核心 |
| `third_party/wasm3` | 空目录 | 目前不能作为实测路线 |
| `lab/lispjit-ir` | 可用 CLI 原型 | `compile/run/dump`，portable IR blob + 本机 JIT call stub |

## 推荐路线

### A. 最小核心路线

做一个很小的 `xjitffi` runtime：

- 内置动态库加载和符号解析。
- 内置 x86_64/aarch64 call stub 生成器。
- 支持少量基础签名：`i64(ptr)`、`i32(ptr)`、`ptr(ptr)`、`double(double)`。
- 用 schema 描述调用：库名、符号、签名、参数。

优点：体积极小，和“动态编译可执行字节”最贴近。

风险：签名覆盖和 ABI 细节会快速膨胀。

`lab/lispjit-ir` 已按这个方向落地一个可用 CLI：`lispjit compile` 生成 `.ljir` portable blob，`lispjit run` 只加载 blob，然后解析 IR 并 JIT 到本机 call stub。`build_cosmo.sh` 在 cosmocc 存在时可构建 x86_64+aarch64 APE。

### B. 功能扩展路线

在 A 之上挂 TCC：

- 简单/高频调用走 micro-JIT。
- 复杂逻辑动态生成 C，由 TCC 编译到内存。
- TCC 输出再通过同一套 FFI resolver 找系统符号。

优点：小核心不牺牲复杂表达能力。

风险：runtime 从 KB 级上升到几百 KB/MB 级。

### C. 分发路线

两种包形态都保留：

- 开发/实验：`cosmorun.exe` 单入口。
- 极小发布：per-arch runtime + 同一份 bytecode/schema/C 源。

## 当前阶段结论

- 真正的最小结合点是 **FFI-resolved pointer + JIT call stub**。
- TCC/CosmoRun 是动态执行能力的放大器，不是最小字节答案。
- 后续应继续量化：通用签名表、libffi-dl 接入成本、aarch64 实测 payload、mini launcher 体积。
