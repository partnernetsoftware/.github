# 跨架构可执行方案矩阵

| 方案 | 动态执行 | 跨架构形态 | 体积倾向 | 系统库 FFI | 判断 |
| --- | --- | --- | --- | --- | --- |
| micro-JIT + FFI resolver | 直接生成机器码 | 每架构 stub | 最小；x86_64 payload 实测 23B | 强；直接跳 FFI 地址 | 最小核心 |
| libffi-dl + resolver | 通用 call interface | 每架构 libffi 二进制 | 小到中；仓库已有 50KB~150KB 级二进制 | 强；签名更通用 | 候选通用 FFI 层 |
| TinyCC per-arch | 动态编译 C | 每架构 TCC | 小；TCC 二进制数百 KB | 强；C ABI 直达系统库 | 动态 C 层 |
| CosmoRun + TinyCC | 动态编译 C + REPL | 单 APE 可带 x86_64/aarch64 | 中等；当前 runtime 约 1.5MB | 强；`__dlopen`/`__dlsym` | 功能最大的一体化路线 |
| 原生 C + 动态链接 | 无内建动态执行 | 每架构 ELF/Mach-O/PE | 很小；当前 probe 约 14KB | 强 | 体积基线 |
| Lua 5.4 | 脚本解释 | 每架构解释器/动态库 | 小到中 | 弱；标准 Lua 无内建 FFI | 只能做脚本层 |
| LuaJIT | JIT + FFI | 每架构解释器 | 小到中 | 强 | 候选，但 ARM64/macOS 风险较高 |
| Wasm/WASI | 字节码解释/JIT | wasm + runtime | 字节码小，runtime 另算 | 弱；需 host import | 沙箱路线，不是直接 FFI |

结论：以 micro-JIT + FFI resolver 做最小核心，以 TCC/CosmoRun 做动态执行放大层；Lua 仅在补 C bridge 或改 LuaJIT 后纳入 FFI 主线。

字节预算补充：`byte_budget.c` 把 FFI 符号地址写入 JIT 机器码；在 x86_64 上，JIT payload 只需要 23 字节即可调用系统 `strlen`。
