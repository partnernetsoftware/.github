# v3.5 parallel slices 1–6

Slice **0** 已 **100%** 签收。wave4 已合并 `main`（L1 pack / L3 lisp aarch64 / codegen default）。开发最多 3 轨 + **反思轨 R**。见 [`../ROADMAP.md`](../ROADMAP.md)、[`LISP-ONLY.md`](LISP-ONLY.md)、[`REFLECTION.md`](REFLECTION.md)。

## 并行轨道

| Track | 类型 | 焦点 | 状态 |
|-------|------|------|------|
| **R** | **反思**（不占开发名额） | 技术债 / 缺陷 / 底层实验 / P0–P3 | **持续** → [`REFLECTION.md`](REFLECTION.md) |
| A | 开发 | slice 1 parse golden + 负向 | wave3 `slice1-golden` |
| B | 开发 | slice 2 `compile-obj` + link | wave3 `slice2-emit` |
| F | 开发 | slice 6 `audit_genesis_shrink.sh` | wave3 `slice6-ci` |
| — | 已签收 | slice 0/3/5、add、build-slice、aarch64、genesis-shrink plan | **100%** / **scoped** |

### 小组模式轨道（[`SQUAD.md`](SQUAD.md) · wave-squad-R1）

| Track | 任务 ID | 洋葱切片 | 状态 |
|-------|---------|----------|------|
| **A** | `L2-companion` | P0：去 `nano-cc-add.lisp` companion；`nano-jit-slice-add.lisp` 为 add 真相源 | **派单中** |
| **B** | `L4-tu-kickoff` | P1：多 `.lisp` → `link-elf64-exe` bootstrap smoke（2 object） | **派单中** |
| **R** | `wave-squad-R1` | gen5 ~85% 评估；ROADMAP mindmap + REFLECTION §6 汇入 | **本 wave** |

（开发轨同时最多 **3** 路；D/E/C 已合并 main，wave3 不再占槽。小组模式 A/B 占当前开发槽。）

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
bash lab/nano-lisp-jit/run.sh   # run-bootstrap-v35-genesis-shrink-plan
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh   # 仅有意刷新 pin
# 开发：genesis/manifest.txt + CI 默认无 cc lispjit.c — GENESIS-SHRINK.md
```

## 错误码索引

| 轨道 | 章节 |
|------|------|
| slice 1 | [`ERROR-CODES.md`](ERROR-CODES.md#add-parse-slice-1) |
| slice 3 | [`ERROR-CODES.md`](ERROR-CODES.md#build-slice-codegen-slice-3) |
