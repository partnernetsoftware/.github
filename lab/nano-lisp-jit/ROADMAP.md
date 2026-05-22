# nano-jit roadmap

目标：用 Lisp/IR 恢复可编程系统的锋利度，推进到 `nano-jit.com` 能自己编译自己，并生成多架构可运行 APE。

## 洋葱 TDD 层

每一层必须有可重复脚本证据，能跑通后才进入下一层。

### 持续反思 / 学习 / 进化循环

`nano-jit` 的发展方式不是一次性路线图，而是持续自我校正的洋葱循环：

```text
evolution loop
├─ 1. 目标复盘
│  ├─ 重新确认当前版本的完成定义
│  ├─ 区分“已经闭环”与“只是可运行”
│  └─ 防止把临时边界误判成能力上限
├─ 2. 证据回放
│  ├─ native runner
│  ├─ container bootstrap
│  ├─ self-packed nano-jit.com
│  └─ checked-in DSL / fixture / hash / exit status
├─ 3. 失败学习
│  ├─ 把失败样例转成负向 fixture
│  ├─ 把调试经验写回 ROADMAP / README / samples
│  └─ 把外部 oracle 逐步迁入 nano 自己的断言
├─ 4. 路线进化
│  ├─ v1.5 先吸收消费者反馈，再收紧格式与数据段
│  ├─ v2 扩大编译器与运行时能力
│  └─ v3+ 吸收 WASM/JVM/JS/SQL 等外部语义
└─ 5. 自信开工
   ├─ 每一圈只选最小可证明切片
   ├─ 样例 -> native -> bootstrap DSL -> self-packed -> commit/merge
   └─ 证据稳定后再扩大下一圈
```

信心来源不是乐观口号，而是可重复证据：每一层都有样例、负向样例、产物检查和自举复验；失败会进入学习材料，学习会改进路线，路线再推动下一圈实现。

### 洋葱 TDD mindmap

```text
nano-lisp-jit / nano-jit self-bootstrap v1
├─ 0. 证据基线
│  ├─ native: run.sh
│  ├─ container: build_nano_jit.sh
│  └─ 产物证据: bytes / hash / exit status / bootstrap-report
├─ 1. IR/VM 内核
│  ├─ deterministic .lbin
│  ├─ typed value: u64 / i64 / bool / ptr
│  └─ expect: number / bool / null / nonnull
├─ 2. FFI/JIT 核心
│  ├─ libc smoke: strlen / atoi / strcmp / abs / getpid
│  ├─ resolver-only 全量 libc manifest
│  └─ typed C call + micro JIT 快路径
├─ 3. AOT / x86_64 codegen
│  ├─ aot-elf64-exit
│  ├─ aot-elf64-code
│  ├─ compile-elf64-code
│  └─ control-flow / i64 / bool / ptr 子集
├─ 4. ELF64 object / tiny linker
│  ├─ emit-elf64-obj-ret / emit-elf64-obj-call
│  ├─ aot-elf64-obj-code / compile-elf64-obj-code
│  ├─ multi-object + R_X86_64_PLT32
│  └─ duplicate symbol / rel32 range negative smoke
├─ 5. ptr memory closure
│  ├─ const-ptr + RIP-relative embedded data
│  ├─ load-u8/u16/u32
│  ├─ store-u8/u16/u32
│  └─ cross-object data smoke: object A calls object B; B reads/writes own data
├─ 6. bootstrap DSL
│  ├─ compile / hash / compare / file-size / file-hash
│  ├─ pack-app / inspect-app / run-app
│  ├─ compile-expect-exit / link-expect-exit / run-expect-exit
│  └─ checked-in bootstrap-aot-smoke.lisp mirrors shell coverage
└─ 7. self-pack / handoff
   ├─ nano-jit.com self-pack without apelink
   ├─ APE v1: loader stub + x86_64/aarch64 payload container
   ├─ native + container evidence passes
   └─ v1 = 100%; v2 starts from APE format, data sections, decomposition, ABI, build graph
```

### v1.5 / v2 洋葱 TDD mindmap

```text
nano-jit continuation after self-bootstrap v1
├─ v1.5: APE format stabilization
│  ├─ 目标
│  │  ├─ 从“能 self-pack 的 .com”推进到“nano 自主 APE container”
│  │  ├─ 明确 loader/header/payload table/arch selection/manifest/hash
│  │  └─ 保持现有 x86_64/aarch64 slice 产物继续可运行
│  ├─ 洋葱 TDD
│  │  ├─ sample: 最小 APE manifest fixture
│  │  ├─ CLI: inspect-ape 输出 header、payload table、arch/os、offset/size/hash
│  │  ├─ pack: pack-ape 写 nano APE manifest，不只是拼接 slices
│  │  ├─ run: 当前 host 选择匹配 payload；unsupported arch 有明确失败码
│  │  ├─ bootstrap DSL: pack/inspect/run/negative 全部进入 checked-in plan
│  │  └─ self-packed: build_nano_jit.sh 用 nano-jit.com 复验同一矩阵
│  └─ 验收
│     ├─ .com 同时含 x86_64/aarch64 payload metadata
│     ├─ manifest hash/offset/size deterministic
│     └─ Linux host 至少能选择并执行本机 slice
├─ v1.5: data/section correctness
│  ├─ 目标
│  │  ├─ 从 text-embedded data 迁移到 .rodata/.data
│  │  ├─ 移除 RWX text/data 混合策略
│  │  └─ 支持 section symbol + R_X86_64_PC32 data relocation
│  ├─ 洋葱 TDD
│  │  ├─ sample: const-ptr/load/store 等价旧路径
│  │  ├─ object: 单 object 数据 relocation
│  │  ├─ link: 多 object 数据 relocation
│  │  ├─ negative: unsupported relocation / bad section index
│  │  └─ bootstrap: native + self-packed 同步覆盖
│  └─ 验收
│     ├─ read-only const 与 writable data 权限分离
│     └─ 旧 text-embedded 数据路径可删除或降级为兼容层
├─ v2: compiler/runtime decomposition
│  ├─ 目标
│  │  ├─ 拆分 lispjit.c 单文件大内核
│  │  ├─ parser/blob/vm/aot_x86/elf/linker/ape/bootstrap 分层
│  │  └─ 错误码、错误消息、测试 fixture 体系化
│  ├─ 洋葱 TDD
│  │  ├─ 先锁定所有现有 fixture hash/exit
│  │  ├─ 小步移动模块，不做语义重写
│  │  ├─ 每次移动跑 native runner
│  │  └─ 阶段性跑 self-packed container bootstrap
│  └─ 验收
│     └─ 重构前后所有 v1/v1.5 证据等价
├─ v2: richer IR/function model
│  ├─ 目标
│  │  ├─ 函数参数、局部变量、显式 value stack 或 SSA-like slots
│  │  ├─ load/store 不再只依赖上一条值
│  │  └─ ABI call descriptor 替代硬编码签名路径
│  ├─ 洋葱 TDD
│  │  ├─ sample: 参数传递与局部变量
│  │  ├─ VM: 解释执行先闭环
│  │  ├─ AOT/codegen: x86_64 主路径
│  │  ├─ object/tiny-link: 多函数、多 object
│  │  └─ negative: 参数类型、局部未定义、ABI 不支持
│  └─ 验收
│     └─ 可表达小型编译器 pass 的核心控制/数据流
├─ v2: self-hosted slice compiler path
│  ├─ 目标
│  │  ├─ 不只生成 ELF，而是生成能进入 nano APE payload table 的架构 slice
│  │  ├─ 先 x86_64，后 aarch64
│  │  └─ 逐步把 cosmocc 从 slice compiler 降级为外部 oracle
│  ├─ 洋葱 TDD
│  │  ├─ emit minimal x86_64 slice
│  │  ├─ pack into nano APE manifest
│  │  ├─ run selected payload
│  │  ├─ compare against cosmocc-built slice behavior
│  │  └─ self-packed nano-jit.com 复验
│  └─ 验收
│     ├─ build_nano_jit.sh 可选择 nano-generated x86_64 payload
│     └─ 下一阶段再补 aarch64 payload generator
└─ v3+: AI-friendly universal substrate
   ├─ 目标
   │  ├─ nano-jit 不以 JVM/GCC 为能力上限，而是形成自己的可计算世界观
   │  ├─ 以图灵完备、可读、可验证、AI 友好为核心约束
   │  └─ 逐步吃下 WASM/JVM/JS/SQL 等外部语义，转译到自身 IR/VM/AOT/APE 体系
   ├─ 洋葱 TDD
   │  ├─ import: 先读最小外部格式 fixture
   │  ├─ lower: 转成 nano IR 或 typed DSL
   │  ├─ execute: VM 跑通行为等价
   │  ├─ compile: x86_64 AOT/object/tiny-link 跑通
   │  ├─ package: 进入 nano APE payload/manifest
   │  └─ self-host: 用 nano-jit.com 复验同一导入/编译矩阵
   └─ 验收
      ├─ 每吞下一种外部语义，都留下 fixture、负向样例、bootstrap DSL 证据
      └─ v3 之后继续按同一洋葱层扩张，而不是把 v2 当终局
```

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

当前完成度评估：`100%`（self-bootstrap v1）。已补齐最小 load/store 宽度，并用跨 object tiny-link 样例验证被调用 object 内嵌数据可读写；后续工作进入 v2 反思队列。

## v1.5 完成度评估

依据：回放 `run.sh`、`build_nano_jit.sh`、`lab/run-lab-tools.sh` 与 checked-in bootstrap DSL 证据；不含日历估算。

| 切片 | 完成度 | 已闭环证据 | 缺口 |
|------|--------|-----------|------|
| APE format | **100%**（scoped） | `APE-v1.md`；`pack-ape`/`inspect-ape`/hash；`run-ape` host + `[arch]`+QEMU（`nano-jit.com` aarch64 smoke）；`bootstrap-ape-*` 负向；`build_nano_jit.sh` self-pack 全矩阵 | nano 自主 loader → **v2 slice 1** |
| data/section | **100%**（验收） | rodata R / data RW ✓；PC32 `.rela.*` ✓；text-embedded 已删 ✓；`bootstrap-data-negative` native + self-pack（`build_nano_jit.sh`）✓ | — |
| v1.5 整体 | **100%**（scoped） | data 100%；APE 验收完成（manifest / inspect / run / 负向 fixture / 自举矩阵）；loader stub 约定可 inspect/run | nano 自主 loader → **v2 slice 1** |

### v1.5 反思确认（可进入 v2）

- **证据回放（本环境）**：`bash lab/nano-lisp-jit/run.sh` exit 0；`bootstrap-ape-smoke` / `bootstrap-ape-negative` / `bootstrap-data-negative` plan OK；`inspect-ape` 对现有 `nano-jit.com` OK。
- **data/section**：mindmap 验收项全部有 native 脚本 + DSL 对应；text-embedded 发射路径已删除。
- **APE scoped 边界**：v1.5 交付的是 `ape-v1` manifest + inspect/run CLI + shell stub loader，**不是** nano 内建 ELF loader；`emit-elf64-exit` 样例 ELF 均为 x86_64，跨 arch 执行证据靠 cosmocc slice + QEMU。
- **未要求项（不计入 v1.5 缺口）**：aarch64 真机 host `run-ape`；无 cosmocc 时完整 `build_nano_jit.sh`（README 已说明）。
- **结论**：v1.5 **100%（scoped）成立**，下一圈按 v2 kickoff 执行。

下一圈（v2 kickoff）：

1. **APE v2**（slice 1 **100% scoped**）+ **hybrid loader**（~50%）：`run-ape` 原生读 v2；`pack-ape` stub 优先 `NANO_JIT`/`nano-lisp-jit run-ape`。
2. **`lispjit.c` 模块边界**（slice 2 **~98%**）：+`nano_pack_app.c`；`parse_aot`/`emit-elf64` 已迁入 aot/elf64；`lispjit.c` 仅 CLI glue + `main`。

### v2 总完成度（工程向）

| 轨道 | 状态 | 说明 |
|------|------|------|
| APE v2 格式 + inspect/run | **100%** scoped | slice 1 签收 |
| 模块拆分 | **~98%** | +pack_app；aot parse + emit-elf64 CLI 归位 |
| 进程内 loader（无 shell） | **~65%** | Linux x86_64 `memfd`+`execv`；aarch64 仍 qemu/tmpfile |
| ABI / 参数 / 自托管 slice | **0%** | slice 3+ |

**v2 整体（全目标）**：约 **85%** — 五路并行合并（parse_aot / pack_app / emit_elf64 / memfd loader / run.sh smoke）。

**远程 `main`**：每次 merge 在 commit message 中标注上述整体完成度百分比。

### v2 slice 1 完成度（scoped）

| 项 | 状态 | 证据 |
|----|------|------|
| `APE-v2.md` + 28B 表项 | **100%** | spec 与 `ape_v2.{h,c}` 一致 |
| `pack-ape` 写 v2 头 | **100%** | `pack-ape.container=ape-v2` |
| `inspect-ape` v2 优先 + v1 回退 | **100%** | `ape-v1-legacy.com` fallback 测试 |
| `run-ape` 读 v2 表 | **100%** | `run-ape.container=ape-v2` |
| bootstrap smoke + 负向 | **100%** | `bootstrap-ape-v2-*` + `make_ape_fixtures.py`；`run.sh` `pack-ape-v2-fixture` / `inspect-ape-v2-container` / `run-ape-v2-native-exit42` / `run-ape-v2-memfd-loader-smoke`（Linux x86_64，否则 skip） |
| self-pack 矩阵（native 侧） | **100%** | `build_nano_jit.sh` 断言 `inspect-ape.container=ape-v2` |
| nano 进程内 loader（无 stub） | **~50%** | `run-ape` 原生；stub 优先 `run-ape-cli`；纯 ELF loader 未做 |

**v2 slice 1 整体**：**100%（scoped）** — 与 `APE-v2.md` slice 1 范围一致；无 stub loader 不算缺口。

**远程 `main`**：已合并 v2 系列提交（见 `git log origin/main`）；当前整体约 **79%**（`run.sh` APE v2 smoke 与上表同步）。

**v2 slice 2+**：`lispjit.c` 模块边界；函数参数/ABI；自托管 slice compiler。

下一步优先级：

1. 把最小 control flow 子集继续接到机器码 AOT/codegen 路径，逐步缩小静态求值-only 语义。
2. 继续扩大 bootstrap DSL：在已落地的 `compile/hash/compare/pack-app/inspect-app/run-app/run` 基础上，再接更丰富的可验证步骤。
3. 持续缩小临时依赖：`cosmocc` 只保留为 slice compiler，下一阶段目标是生成 x86_64 slice 的可运行子集。
4. 进入 v2 反思队列：实现类似 Cosmopolitan 的 APE 格式、明确独立数据段权限模型、更多内存布局、更完整 ABI 边界，以及减少 slice compiler 依赖。
5. 保留 v3+ 扩张方向：把 nano-jit 作为 AI 友好、图灵完备、可自举的独立基石，持续吸收 WASM/JVM/JS/SQL 等外部语义，而不是把 v2 当终点。
6. 将 lab 消费者反馈纳入 v1.5 slice 0：先收敛 CLI/DSL 命名、runner 定位、repo-root 路径、`run` 退出码语义和 x86_64 skip 说明，再开 APE manifest。

已完成：

- v1.5 slice 0 首轮：顶层 CLI 新增 `resolve-quiet program.lbin` alias，lab 消费者 helper 支持 `NANO_JIT` runner 覆盖，继续用 `bash lab/run-lab-tools.sh` 做消费者回归。
- v1.5 slice 1 首轮：`pack-ape` 写出 `ape-v1` manifest，新增 `inspect-ape` CLI，bootstrap DSL 支持 `pack-ape` / `inspect-ape`，并加入 checked-in `bootstrap-ape-smoke.lisp`。
- v1.5 slice 1–3 二轮（约 50%）：`pack-ape` manifest 写入 slice fnv1a64 hash；`inspect-ape` 校验 container/offset/hash；新增 `inspect-expect-exit`、`run-ape`、`run-ape-expect-exit`；`bootstrap-ape-negative.lisp` + `make_ape_fixtures.py` 覆盖 bad manifest/container/offset/hash；`run-ape` 按 host arch 抽取 payload 执行。
- v1.5 slice 1–3 三轮（约 70%）：`build_nano_jit.sh` self-pack 后对 `nano-jit.com` 跑 `inspect-ape`、`run-ape`（x86_64）并用 self-packed runner 复验 `bootstrap-ape-negative.lisp`；`run.sh` 在 APE 块补 `compile-elf64-code` const-ptr 证据。
- v1.5 slice 1–3 四轮（约 90%）：dev 容器 cosmocc 下 `build_nano_jit.sh` 全绿；`make_ape_fixtures` 同长 hash 负向；self-pack 复验 `bootstrap-data-negative`；`run-ape` 改为 slice 提取 smoke（不要求 compiler exit 0）。
- v1.5 slice 1–3 五轮（**APE 验收 100%**）：`run-ape … aarch64` + QEMU（`run.sh` 对 cosmocc `nano-jit.com`）；`APE-v1.md` 最小 spec（loader 边界写明 v2）。
- v1.5 data/section 三轮（约 65%）：const 字符串按 `store` 分 `.rodata`/`.data`；`emit_elf64_obj_text_data_section` + `link-elf64-exe` 解析 `.rela.rodata`/`.rela.data` 并打 PC32；可执行文件多 PT_LOAD（text RX、rodata R、data RW）且段间页对齐；`compile-elf64-code`/`aot-elf64-code` 统一经 object+link；样例 `rodata-readonly.lisp`、`const-ptr-load-u8.lisp` 在 `run.sh` 通过。
- v1.5 data/section 四轮（约 85%）：`make_data_reloc_fixtures.py` + `bootstrap-data-negative.lisp` 覆盖 unsupported data reloc；`bootstrap-aot-smoke` / `build_nano_jit.sh` 增加 rodata-readonly；self-packed `nano-jit.com` 复验 `compile-elf64-code` rodata 路径。
- v1.5 data/section 五轮（约 95%）：`data-bad-symbol-shndx.o` 触发 `bad_data_symbol`；删除未使用的 `emit_elf64_exec_rx_data_file` / `emit_elf64_code_data_file`（text-embedded 直连已弃用，统一 object+link+`emit_elf64_exec_sections_file`）。
- v1.5 data/section **验收 100%**：`build_nano_jit.sh` self-pack 复验 `bootstrap-data-negative` + rodata；见上文「v1.5 完成度评估」表。
- AOT app 直接从 `.com` payload 读取内嵌 blob 执行。
- AOT app 结构化 manifest、`inspect-app` 和 `run-app`。
- `pack-ape` 已能组合 x86_64/aarch64 slice 与 container metadata，形成当前最小 `.com`；但 loader/多架构执行选择仍主要依赖现有 slice/stub 约定，尚未形成 nano 自主的完整 APE loader 格式。
- deterministic `.lbin` hash/byte compare 测试。
- `compare` CLI 已替代系统 `cmp` 执行 deterministic blob 对比。
- `file-size` CLI 已替代 nano-lisp-jit smoke 报告中的 `wc -c` 字节统计。
- `file-hash` CLI 已替代 `nano-jit.com` 报告中的 `sha256sum` 外部 hash。
- `gen-libc-resolve` CLI 已替代 libc resolver manifest 的 Python/`nm` 生成链路。
- `run-expect-exit` CLI 已替代 native AOT smoke 中的 shell 退出码包装。
- `link-expect-exit` CLI 已替代 duplicate-symbol linker 负向 smoke 的 shell 包装。
- `compile-expect-exit` CLI/DSL 已替代递归 local call、typed ptr/bool 误用等负向 source AOT smoke 的 shell 包装。
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
- typed 算术/比较已覆盖 `add-i64` / `sub-i64` / `mul-i64` / `eq-i64` / `ne-i64` / `lt-i64` / `gt-i64` / `le-i64` / `ge-i64`，typed bool 逻辑已覆盖 `not-bool` / `and-bool` / `or-bool`，进入解释执行、静态求值 AOT 和 x86_64 codegen/object 路径。
- 最小 ptr 纯值子集已覆盖 `null-ptr` / `const-ptr` / `add-ptr` / `sub-ptr` / `ptr-to-u64` / `u64-to-ptr` / `load-u8` / `load-u16` / `load-u32` / `store-u8` / `store-u16` / `store-u32` / `is-null-ptr` / `is-nonnull-ptr`；`const-ptr`、load-family 与 store-family 已进入解释执行、静态 AOT、standalone ELF x86_64 codegen、ELF64 object 与 tiny-link 可执行路径。
- typed 负向编译 smoke 已覆盖 ptr predicate 误用、branch 非 bool、ptr expect 非 ptr、ptr/u64 cast 误用、load-family 非 ptr、store-family 非 ptr 与越界立即数，且同一 DSL 会断言 `compile-elf64-code` / `compile-elf64-obj-code` / `compile-elf64-exe` 返回失败码。
- 跨 object 数据 smoke 已覆盖：object A 通过 `R_X86_64_PLT32` 调用 object B，object B 内部通过 `const-ptr` 访问并写读自身内嵌数据，再由 tiny linker 生成可运行 ELF。
- `expect` 已支持负数、布尔值和 `null` / `nonnull` 指针断言。
- `block` / `branch` / `label` 已可编译进 `.lbin` 并由解释执行路径运行。
- control-flow pure blob 已能走机器码 codegen AOT 路径，覆盖 `aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code`。
- `compile-elf64-obj-code` 已支持多函数 pure VM source、内部 `call`、基础 relocation，以及 `i64` / `bool` / `ptr` / `branch` / `label` typed/control-flow 子集；内部 `call` 会保留 helper 的 `u64` / `i64` / `bool` / `ptr` 返回类型。
- 多函数 object 可同时被系统 `cc` 与 nano 自带 tiny linker 链接并运行。
- `compile-elf64-exe` 已可把多函数 pure VM source 直接生成可运行 ELF，内部走 object backend + tiny linker。
- `bootstrap` 最小 DSL 已落地，可用 `.lisp` 顺序描述并执行核心 `.lbin` 样例矩阵、`compile` / `gen-libc-resolve` / `dump` / `file-size` / `file-hash` / `hash` / `compare` / `pack-app` / `inspect-app` / `run-app` / `run` 子流程。
- `bootstrap` DSL 已可驱动 AOT/codegen/tiny-link executable smoke，覆盖 `emit-elf64-exit`、`emit-elf64-obj-*`、`aot-elf64-*`、`compile-elf64-*`、`file-size` / `file-hash` 产物检查、`resolve-quiet`、多 object `link-elf64-exe`、直接 executable 编译、`compile-expect-exit` / `link-expect-exit` / `run-expect-exit` 失败状态断言，开始把更多 build graph 从 shell 迁入 nano 描述。
- control-flow pure blob 已能走静态求值 AOT 路径，生成 `aot-elf64-exit` / `aot-elf64-obj-ret` 产物。

## self-bootstrap v1 反思

v1 达成标准：`nano-jit.com` 可 self-pack；核心 `.lisp -> .lbin -> VM/AOT/codegen/object/tiny-link/exe` 路径可由 native 与容器脚本重复验证；typed `i64/bool/ptr`、control-flow、multi-func、多 object、load/store-family、负向编译与链接失败均有自举证据。

目标复盘：

- 原目标不是“做一个完整 Lisp”，而是证明极小 Lisp/IR 能持续替代外部脚本、外部 linker oracle 和部分 shell glue。
- v1 的 100% 定义限定在 self-bootstrap 证据闭环：native/container 都能重复生成、链接、运行并断言核心产物。
- 另一个长期目标是生成类似 Cosmopolitan APE 的跨架构 `.com`：同一个文件内含 loader/识别头、架构选择逻辑、多个架构 payload 与元数据，而不只是生成单架构 ELF。
- 还没有完成“最终自编译编译器”：`cosmocc` 仍负责架构 slice，v2 才继续缩小这个边界。
- 现实边界应按 AI 时代重新评估：nano-jit 可以成为独立发展的基石；只要 IR/DSL 保持图灵完备、可读、可验证、AI 友好，就能长期吸收 WASM/JVM/JS/SQL 等外部语义并形成自己的世界观。

设计上做对的部分：

- 把 shell oracle 逐步迁入 bootstrap DSL，测试从“脚本观察输出”变成“工具自己断言状态码和产物”。
- 优先收紧 x86_64 object/tiny-link 主链路，让 `compile-elf64-exe` 可复用 object backend，而不是另起一条不可验证路径。
- typed value 只扩展最小可证明闭环，每个 op 同时进入解释、静态 AOT、机器码和负向样例。
- 始终采用洋葱式推进：样例先行，进入 native runner，再进入 bootstrap DSL，最后进入 self-packed `nano-jit.com` 容器自举。

实现上暴露的问题：

- `lispjit.c` 仍是单文件大内核，解析、IR、解释、AOT、ELF writer、linker 和 CLI 分层不足。
- APE 反思不足：v1 只是 self-pack 和不调用 `apelink`，还没有把 loader/header/payload table/架构选择规则提升为 nano 自主格式。
- const/data 当前仍附着在 `.text`，靠可写 load segment 支持 store；v2 应拆出 `.rodata/.data` 与明确段权限。
- object 数据布局依赖“数据跟随 text”的局部 RIP 相对寻址；v2 应支持数据 section、section symbol 和数据 relocation。
- source AOT 与 blob AOT 仍有细小边界差异，新增语义时必须同时补 checked-in DSL、native runner 与 self-packed runner。
- bootstrap DSL 仍是线性执行模型，缺少命名产物、依赖图和条件化能力。
- typed op 当前是栈顶/上一值风格，缺少局部变量、参数传递和可组合表达式模型。
- 错误码和错误消息可用但未体系化，后续调试复杂 source 时会拖慢定位。

v2 建议入口：

1. 先定义 nano APE v2 格式：loader/header magic、payload table、arch/os 选择字段、offset/size/hash、fallback 行为，以及 inspect/run 验证输出。
2. 让 `pack-ape` 不只是拼 slice，而是写出 nano 自主的 APE manifest；`inspect-app`/`run-app` 应能解释该 manifest。
3. 引入 `.rodata/.data` object section，支持 `R_X86_64_PC32` 数据 relocation，再移除 RWX text/data 混合策略。
4. 拆分 `lispjit.c`：先按 parser/blob/vm/aot_x86/elf/linker/ape/bootstrap 分区或分文件。
5. 扩展函数参数与局部值模型，让 `store/load` 不再只依赖“上一条值”。
6. 把 bootstrap DSL 从顺序脚本推进到小型 build graph，减少 `run.sh` / `build_nano_jit.sh` 的变量胶水。
7. 继续缩小 `cosmocc` 角色：先生成更完整 x86_64 slice，再评估 aarch64 slice 的最小 backend。

v3+ 扩张原则：

1. 不把 JVM、GCC、WASM、JS runtime 或 SQL engine 当作能力天花板；它们更适合作为可导入、可转译、可验证的外部语义来源。
2. 每扩张一个世界，都先做最小 fixture：读取格式、lower 到 nano IR/typed DSL、VM 行为等价、AOT/codegen 等价、APE 打包、自举复验。
3. 保持“AI 友好”作为架构约束：文本格式清晰、错误可解释、测试可局部运行、产物可 inspect，方便未来分身持续扩大能力。

## 内存契约与产品化（设计参考）

不替代上文 v1.5/v2 切片，详见 `DESIGN-MEMORY-AND-PRODUCT.md`。

- **Rust 借鉴（轻量）**：不可变默认 + `ptr-ro`/`ptr-mut`、region 边界、slot/移动语义、别名 def-use、`run-borrow-check` 调试模式；**不做**完整 borrow checker。
- **与 v1.5 对齐**：`.rodata/.data` 即 Rust 式 const/mut 段分离的第一落点。
- **与 v2 对齐**：局部变量/SSA 后再收紧 load/store 与「上一条值」语义。
- **产品化命名**：对外总品牌 **NanoJIT**；产物 **Lbin**（`.lbin`）、发行 **Nano APE**（`.com`）；`nano-lisp-jit` 保留为仓库路径名。

## v1.5 / v2 开工入口

开工原则：

1. 先跑 v1 基线，不在不稳定地基上扩大能力。
2. v1.5 先做消费者可用性收敛，再做格式和证据层收紧：nano APE manifest、inspect/run、数据 section。
3. v2 再做结构性扩张：模块分层、函数模型、ABI、self-hosted slice path。
4. 每个切片都必须留下：sample、negative sample、native runner、bootstrap DSL、自举证据、反思记录。

第一批 v1.5 切片：

```text
v1.5 kickoff
├─ slice 0: consumer feedback closure
│  ├─ 明确 CLI 与 bootstrap DSL 的命名差异: resolve --quiet vs resolve-quiet
│  ├─ 文档化 NANO_JIT runner 约定和 repo-root 路径约定
│  ├─ 明确 run 退出码等于 VM 返回值，脚本自测优先使用 expect/run-expect-exit
│  ├─ 非 x86_64 host 对 compile-elf64-* 给出可理解 skip/限制说明
│  ├─ 跑 bash lab/run-lab-tools.sh 作为消费者回归
│  └─ 目标: 先让外部工具稳定消费 nano-jit，再扩大格式能力
├─ slice 1: nano APE manifest spec
│  ├─ 写最小 header/payload table fixture（首轮已落地为 ape-v1 manifest）
│  ├─ 增加 inspect 输出格式的 golden expectation（首轮已落地 inspect-ape）
│  ├─ 负向样例: bad magic / bad offset / bad hash
│  └─ 目标: 先锁格式，不急着重写 loader
├─ slice 2: pack-ape writes nano manifest
│  ├─ 保留现有 x86_64/aarch64 slice
│  ├─ manifest 记录 arch/os/offset/size/hash
│  ├─ inspect-app 或 inspect-ape 能解释新 manifest
│  └─ bootstrap DSL 覆盖 pack/inspect/hash
└─ slice 3: run selected payload
   ├─ Linux host 先选择 x86_64 payload
   ├─ unsupported arch 有稳定失败码
   ├─ self-packed nano-jit.com 复验
   └─ 反思 loader 与 manifest 的下一圈缺口
```

第一批 v2 切片：

```text
v2 kickoff
├─ slice 1: .rodata/.data section fixture
│  ├─ const-ptr/load/store 与旧 text-embedded data 行为等价
│  ├─ object 支持 section symbol
│  ├─ tiny linker 支持数据 relocation
│  └─ 目标: 逐步移除 RWX text/data 混合策略
├─ slice 2: module boundary without semantic rewrite
│  ├─ 先固定全部 v1/v1.5 fixture hash/exit
│  ├─ 按 parser/blob/vm/aot_x86/elf/linker/ape/bootstrap 分区
│  └─ 每次移动只做等价验证
└─ slice 3: richer function/value model
   ├─ 参数和局部变量先进入 VM
   ├─ 再进入 x86_64 AOT/object/tiny-link
   ├─ ABI descriptor 替代硬编码签名
   └─ 目标: 支持更复杂编译器 pass
```

下一分身接续顺序：

1. 先跑 `bash lab/nano-lisp-jit/run.sh` 和 `sudo docker compose -f docker-compose.dev.yml run --rm dev bash lab/nano-lisp-jit/build_nano_jit.sh`，确认 v1 基线仍绿。
2. 先跑 `bash lab/run-lab-tools.sh`，把 `LAB-USAGE-FEEDBACK.md` 中的问题转成 v1.5 slice 0 的修复或文档约定。
3. 再从 v1.5 slice 1 开始：把 APE manifest/header/payload table 写成最小 spec 和 fixture，再用 inspect 测试锁定格式。
4. 完成 v1.5 pack/inspect/run 三圈后，再进入 v2 `.rodata/.data` section 和数据 relocation。
5. 数据 section 稳定后再拆 `lispjit.c`，避免格式、权限和大规模移动同时发生。
6. 每次推进继续保持“目标复盘 -> 样例 -> native runner -> checked-in bootstrap DSL -> self-packed runner -> lab consumer regression -> 反思 -> commit/merge”的洋葱顺序。
