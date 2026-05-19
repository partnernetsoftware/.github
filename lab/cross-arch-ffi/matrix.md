# 跨架构可执行方案矩阵

| 方案 | 跨架构形态 | 体积倾向 | 系统库 FFI | 适合度 |
| --- | --- | --- | --- | --- |
| CosmoRun + TinyCC | 单 APE 可带 x86_64/aarch64，运行时编译 C | 中等；运行时较大，脚本/源码很小 | 强；`__dlopen`/`__dlsym` 可直接调系统库 | 首选实验方向 |
| 原生 C + 动态链接 | 每架构一个小 ELF/Mach-O/PE | 很小 | 强；`dlopen`/`dlsym`/平台 API | 最小基线 |
| TinyCC per-arch | 每架构一个 TCC + C 源/对象 | 小 | 强；C ABI 直达系统库 | 适合插件和热更新 |
| Lua 5.4 | 每架构解释器/动态库 | 小到中 | 弱；标准 Lua 无内建 FFI | 需 C bridge 才合格 |
| LuaJIT | 每架构解释器 | 小 | 强；内建 FFI | ARM64/macOS 与新架构风险较高 |
| Wasm/WASI | 单 wasm 字节码 + 每平台 runtime | 小字节码，runtime 另算 | 弱；系统库需 host import | 适合沙箱，不适合直接 FFI |
| Zig/Rust/Go 单文件 | 每架构交叉编译 | 中到大 | 中到强；看链接策略 | 适合产品化，不是最小实验 |

结论：以 CosmoRun 做“功能大”的主线，以原生 C/TCC 做“小体积”基线；Lua 仅在补 C bridge 或改 LuaJIT 后纳入 FFI 主线。
