# v3.5 Lisp-only 进化线

**目标**：新增能力默认只写 `.lisp`；`.c` 逐步变为 legacy 对照，便于 AI 在单一 DSL/IR 上协同演进。

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
L1  pack-ape 的 x86 slice 来自 Lisp 产物；aarch64 仍 genesis 或 duplicate 文档化  ← 本提交
L2  用 Lisp 模块描述「编译器子集」替代 nano-cc-add.c（DSL 生成 IR，非 companion 文件）
L3  build-slice-lisp aarch64（与 v3 cross 同门槛）
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

## 下一刀（建议并行）

- L2：内联 `nano-jit-slice-add` 为 bootstrap 宏，去掉对 `nano-cc-add.lisp` 文件名依赖
- L3：`build-slice-lisp` aarch64 smoke
