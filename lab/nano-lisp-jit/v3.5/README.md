# v3.5 kickoff — nano-cc

**Status: 0%** — mindmap 已入账；待 slice 0 开工。

v3 **100%（scoped）** 签收后，v3.5 用 nano-jit 实现 **C-subset `cc` 编译器**（`nano-cc`），替换 `build-slice` 对 host `cc` 的依赖。这是「Lisp/.nano 编自己」从 **编排** 走向 **Codegen** 的第一座可证明桥梁。

## 与 v3 的关系

| v3 层 | v3 状态 | v3.5 承接 |
|-------|---------|-----------|
| Genesis | 一次性 host `cc` seed | slice 6 收缩为 pin，禁止日常重编 |
| Orchestration | gen1→gen2 bootstrap | slice 5 gen3：nano-cc 重建 slice |
| Codegen | **0%**（`build-slice` 仍 `cc`） | **v3.5 主战场** |

详见 [`../v3/BOOTSTRAP-THOROUGH.md`](../v3/BOOTSTRAP-THOROUGH.md)、[`../ROADMAP.md`](../ROADMAP.md) → **v3.5 洋葱 TDD mindmap**。

## 目标（scoped）

- **nano-cc**：`nano-cc compile foo.c -o foo.elf`（CLI 名可调整，语义对齐 `cc` 最小子集）
- **`(build-slice …)`**：`build-slice.role=nano-cc`，日志 `build-slice.compiler=nano-cc`
- **终局**：除 Genesis pin 外，CI 默认无 `cc lispjit.c`

## 洋葱顺序（每 slice）

```text
sample → native run.sh → bootstrap DSL plan → self-packed nano-jit.com → build 矩阵 → 反思 → commit
```

## 切片一览

| 切片 | 焦点 |
|------|------|
| 0 | 证据门禁：`nano-cc-hello.c` |
| 1 | C-subset 前端 → IR |
| 2 | x86_64 object + link |
| 3 | `build-slice` 切换 |
| 4 | aarch64 nano-cc + qemu |
| 5 | gen3 selfhost |
| 6 | Genesis pin |

进度表见 ROADMAP **v3.5 完成度** 节。

## 命令（slice 0 落地后）

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
# 未来：
# env NANO_CC=1 bash lab/nano-lisp-jit/build_nano_jit.sh
```

## 非目标（v3.5 不做）

- 完整 ANSI C / 全 `lispjit.c` 一次译完
- 替换 cosmocc 全功能（仅 slice compiler 子集）
- WASM/JS/SQL 外部语义（v4+）
