# v3.5 — Lisp-only 自主进化（主轨）+ nano-cc 实验轨

**Status: ~85%（gen5 scoped）** — L0–L3 + **gen5 双架构 Lisp pack**（零 genesis pin、计划内零 `.c`）已证据化。并行见 [`PARALLEL.md`](PARALLEL.md)；反思见 [`REFLECTION.md`](REFLECTION.md)。

| 切片 / 线 | 状态 | 说明 |
|-----------|------|------|
| Lisp-only L0–L3 | **签收** | [`LISP-ONLY.md`](LISP-ONLY.md) |
| gen5 双架构 pack | **scoped** | `bootstrap-v35-selfhost-gen5.lisp` |
| gen4 | **scoped** | 计划无 `.c`；aarch64 pack 曾用 genesis |
| nano-cc slice 0–3 | **scoped/100%** | 实验轨 |
| slice 6 Genesis 收缩 | **scoped** | [`GENESIS-SHRINK.md`](GENESIS-SHRINK.md) |
| L4 全功能 Lisp slice | **未签收** | 多 TU link；gen5 编排仍 native runner |

**v3.5 整体**：**~85%** — 签收尚缺：L4 全功能 runner、aarch64 非 stub。

## gen5 证据

```bash
bash lab/nano-lisp-jit/run.sh   # run-bootstrap-v35-selfhost-gen5-plan, qemu-aarch64-v35-gen5-*
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

样例：`samples/bootstrap-v35-selfhost-gen5.lisp` — x86 min/add + aarch64 min/add → `pack-ape`（无 `genesis/nano-jit.*`）。

## 其它证据

- gen4：`bootstrap-v35-selfhost-gen4.lisp`
- Lisp-only 矩阵：`bootstrap-v35-lisp-only-matrix.lisp`
- nano-cc：[`ERROR-CODES.md`](ERROR-CODES.md)

## 下一刀

1. L4：多 `.lisp` TU → 全功能 runner slice
2. L2：去 `nano-cc-add.c` companion
3. aarch64 真实 codegen

Mindmap：[`../ROADMAP.md`](../ROADMAP.md)
