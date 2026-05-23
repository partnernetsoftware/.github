# v3.5 parallel slices 1–6

Slice **0** 已 **100%** 签收。并行分支 **2/3/4/5** 已合并到 `cursor/nano-jit-v35-parallel-f186`；**1/6** 仍待办。见 [`../ROADMAP.md`](../ROADMAP.md) v3.5 mindmap。

## 并行轨道

| Track | Slice | 焦点 | 硬依赖 | 状态 |
|-------|-------|------|--------|------|
| A | 1 C-subset 前端 | `add-parse`、token→IR | slice 0 | **0%** |
| B | 2 x86_64 add | companion lisp + compile-elf64-exe | slice 0 | **100%** scoped |
| C | 3 `build-slice` 切换 | `NANO_BUILD_SLICE_CODEGEN=1` | slice 2 add 路径 | **100%** scoped |
| D | 4 aarch64 nano-cc | `NANO_CC_ARCH` + qemu | slice 0 hello | **scoped** |
| E | 5 gen3 自举 | `bootstrap-v35-selfhost-gen3` | slice 3 | **100%** scoped |
| F | 6 Genesis 收缩 | pin + `NANO_REGENESIS` | slice 5 | **0%** |

## 洋葱顺序（每条轨道内）

1. **样例** — checked-in `.c` / `.lisp` + 负向 fixture（对齐 [`ERROR-CODES.md`](ERROR-CODES.md)）
2. **native runner** — `run.sh` `run_case` 或 CLI smoke
3. **bootstrap DSL** — `run-bootstrap-plan` + 日志关键字断言
4. **build 矩阵** — `build_nano_jit.sh` self-host / self-pack（轨道需要时）
5. **ROADMAP bump** — 完成度表 + 本文件状态列

## 合并洋葱（跨轨道）

```text
after slice 0 (100%)
├─ wave 1（可并行）: slice 1 add-parse  ∥  slice 4 aarch64 脚手架 / 路线 B 文档
├─ wave 2: slice 2 x86 emit（需 slice 1 parse dump / IR 契约）
├─ wave 3: slice 3 build-slice-codegen（需 1+2 可编 nano-cc TU）
├─ wave 4: slice 5 gen3（需 3 签收或显式 genesis-pin 过渡样例）
└─ wave 5: slice 6 genesis shrink（需 5 CI 默认无 `cc lispjit.c`）
```

**冲突热点**：`lab/lispjit-ir/nano_cc.c`、`nano_bootstrap.c`、`run.sh`、`build_nano_jit.sh`。各轨道优先改独立 sample 名、stderr tag、bootstrap 文件，减少同段逻辑争抢。

## 下一命令（按轨道）

基线（任何轨道开工前）：

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

### slice 1 — add-parse

```bash
# 对照 slice 0
bash lab/nano-lisp-jit/run.sh   # nano-cc-compile-hello-cli, nano-cc-compile-bad-expect2
# 开发：samples/nano-cc-add.c；负向 samples/nano-cc-add-bad.c
# 计划 gate：nano-cc-parse-add-dump / nano-cc-compile-add-exit
```

### slice 2 — x86 emit

```bash
bash lab/nano-lisp-jit/run.sh   # compile-elf64-obj-code / link-elf64-exe 基线不退化
# 开发：nano-cc 产 relocatable .o → link-elf64-exe；对齐 host cc 符号表与 exit
```

### slice 3 — build-slice-codegen

```bash
bash lab/nano-lisp-jit/run.sh   # run-bootstrap-v3-codegen-smoke-plan（4b-2 对照）
# 开发：samples/bootstrap-v35-build-slice.lisp
# 目标日志：build-slice.role=nano-cc；无 compiler=cc（除非 NANO_CC_FALLBACK=1）
env NANO_CC=1 bash lab/nano-lisp-jit/run.sh   # 切换验收
```

### slice 4 — aarch64

```bash
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh   # qemu aarch64 smoke 基线
# 路线 A：独立 aarch64 发射；路线 B：x86-only nano-cc + genesis cross（文档化缺口）
```

### slice 5 — gen3

```bash
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
# 开发：samples/bootstrap-v35-selfhost-gen3.lisp；gen2 runner 链
```

### slice 6 — genesis shrink

```bash
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh   # 仅有意刷新 pin
# 开发：genesis/manifest.txt + CI 默认无 cc lispjit.c
```

## 错误码索引

| 轨道 | 章节 |
|------|------|
| slice 1 | [`ERROR-CODES.md`](ERROR-CODES.md#add-parse-slice-1) |
| slice 3 | [`ERROR-CODES.md`](ERROR-CODES.md#build-slice-codegen-slice-3) |
