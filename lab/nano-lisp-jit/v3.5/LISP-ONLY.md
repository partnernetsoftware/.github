# v3.5 Lisp-only 进化线

## North star：AI 协同自主进化

**动机**：C/LLVM/cosmocc 等工具链对 AI 不友好——体量大、反馈慢、语义分散在宏/头文件/链接规则里，难以形成「改一处 → 可验证闭环 → 代际自举」的加速通道。

**本仓库的赌注**：把 **可编辑表面** 收敛到：

- **`.lisp`** — 模块 DSL、VM/AOT、bootstrap 编排（人类与 AI 同一语言）
- **`.lbin` / golden** — 确定性证据（hash、exit、plan 日志）
- **bootstrap 计划** — 可审计构建图，替代 shell/Makefile 泥团

**C 的角色**：从「日常实现语言」降级为 **一次性 genesis seed**（`NANO_REGENESIS=1`）或 **legacy 对照**；不再作为每一代进化的默认输入。

**进入加速通道的判据**（工程向，非口号）：

| 档位 | 含义 | 当前 |
|------|------|------|
| **A** 用户态全 Lisp | 实验/产品逻辑只写 `.lisp` | **已达** |
| **B** slice 增量全 Lisp | 新能力用 `build-slice-lisp` / `.lisp` 路由 | **L0–L3 已达** |
| **C** 日常零 host `cc` | 重建 runner 不碰 `cc`/`lispjit.c` | **genesis-pin**（复制，非生成） |
| **D** 自举闭环无 C 输入 | gen{N+1} bootstrap **计划内无 `.c`**，且 **无 pin 复制** | **gen4 计划无 C**；pack 仍部分 genesis |
| **E** 自主进化加速 | AI 只改 Lisp 面 + 门禁自动红；每轮 `run.sh`+build 分钟级证据 | **进行中** |

**目标**：尽快从 **D−**（计划无 C、产物仍 pin）推进到 **D+**（Lisp 生成 x86+aarch64 slice），再冲 **E**。

---

**目标（工程）**：新增能力默认只写 `.lisp`；`.c` 逐步变为 legacy 对照，便于 AI 在单一 DSL/IR 上协同演进。

## 当前已签收（本线 milestone L1）

| 能力 | 机制 | 零 `.c` |
|------|------|---------|
| 用户程序 | `.lisp` → `.lbin` / AOT / pack-app | 是 |
| 极小 slice | `build-slice-lisp` + `nano-jit-slice-min.lisp` | 是 |
| 多函数 slice | `nano-jit-slice-add.lisp`（同原 `nano-cc-add.lisp` 语义） | 是 |
| 统一 DSL | `(build-slice "*.lisp" …)` → 自动 `build-slice-lisp`（`build-slice.route=lisp-by-extension`） | 是 |
| 证据 | `bootstrap-v35-lisp-only-matrix.lisp`、`bootstrap-v35-build-slice-lisp-route.lisp` | 计划内零 `.c` |
| pack x86 Lisp | `bootstrap-v35-pack-lisp-x86.lisp` — Lisp slice + genesis aarch64 | 是 |
| gen4 自举 | `bootstrap-v35-selfhost-gen4.lisp` — Lisp slice + pack x86 来自 `v35-gen4-slice-min-x86.elf` | 是（aarch64 仍 genesis pin） |

```bash
bash lab/nano-lisp-jit/run.sh   # pack-lisp-x86, lisp-only-matrix, build-slice-lisp-route, gen4 plan
```

## 洋葱里程碑（向「全 Lisp、无 C」）

```text
L0  slice 样例全 Lisp（min/add）+ build-slice 自动路由 .lisp     ← 已签收
L1  pack-ape 的 x86 slice 来自 Lisp 产物；aarch64 仍 genesis           ← 已签收
L2  用 Lisp 模块描述「编译器子集」替代 nano-cc-add.c（DSL 生成 IR，非 companion 文件）
L3  build-slice-lisp aarch64 exit emit（min/add profile）            ← 已签收
L4  lispjit 功能剖面拆为多个 .lisp TU → link-elf64-exe 链（仍零 host cc）
L5  genesis 缩到 bootstrap 极小包；日常无 pin 复制
L6  AI 协同：仅改 .lisp + bootstrap + golden；禁止新增 .c 除非 NANO_ALLOW_C_LEGACY=1
```

## 与 nano-cc / C 的关系

| 路径 | 状态 |
|------|------|
| `nano-cc-hello.c` / `nano-cc-add.c` | **legacy 对照** — 保留门禁，新功能不增 C |
| `nano-cc parse` | 仍可测 C-subset 前端；Lisp 真相源为 `.lisp` |
| `lispjit.c` 全量 slice | 仍 genesis-pin（至 L5） |

## AI 协同约定

1. **新 slice / 实验**：只加 `samples/*.lisp` + `bootstrap-v35-*.lisp` + `run.sh` case。
2. **改编译器行为**：优先 `module`/`func`/op 与 `compile-elf64-code` 路径。
3. **需要 C 语义时**：先写等价 `.lisp` + `run-expect-exit`，C 仅作 optional 对照（deprecated）。
4. **反思入账**：[`REFLECTION.md`](REFLECTION.md) §1 增债/还债；ROADMAP mindmap「Lisp-only 线」同步。

## 自主进化加速通道（优先于「再实现一点 C」）

```text
加速 1  缩小 AI 编辑面
        仅 samples/*.lisp + bootstrap-v35-*.lisp + golden
        禁止新增 .c（NANO_ALLOW_C_LEGACY=1 才例外）← 门禁待加强

加速 2  缩短反馈环
        每次改动必过 run.sh（~250 case）+ 可选 build 矩阵
        plan 日志关键字比「读 C 编译错误」更适合 AI

加速 3  去掉双轨真相源
        L2：废弃 companion .lisp 文件名耦合；IR 只认 .lisp 模块
        nano-cc 仅保留 parse 实验轨，不作为 slice 主路径

加速 4  全架构 slice 由 Lisp 生成
        L4：多 .lisp TU → link-elf64-exe → 替代 genesis x86
        L3+：aarch64 build-slice-lisp 从 exit-stub 扩到真实 codegen

加速 5  genesis 极小化
        L5：pin 只保留「若全 Lisp 链断了」的救生艇；日常 gen5+ 无 cc

加速 6  代际自举证据
        gen5：gen4 runner 只跑 Lisp slice + pack 双架构 Lisp 产物
        hash 矩阵入库 → AI 可断言「进化未退化」
```

**与 C 工具链对比（为何 Lisp 线更快）**

| 维度 | C/cosmocc 路线 | Lisp 自举路线 |
|------|----------------|---------------|
| AI 可读性 | 低（预处理/链接/UB） | 高（S 表达式 + 显式 op） |
| 增量验证 | 重编译 TU / 链接 | `.lbin` hash、exit 42、plan grep |
| 自举叙事 | 必须用外部 cc | bootstrap DSL 可版本化 |
| 风险 | 工具链升级破坏 | VM/IR 契约破坏（可 golden） |

## 下一刀（建议并行 · 冲档位 D/E）

- **L2 / 加速 3**：单一真相源 `.lisp`；弱化 `nano-cc-add.c` companion
- **L4 / 加速 4**：Lisp 编多 TU → link → pack（x86 先签收）
- **gen5 / 加速 6**：下一代 bootstrap **零 `.c`、零 genesis x86 复制**（允许 genesis 仅作灾备）
