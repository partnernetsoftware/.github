# lab/nano-lisp-jit 目录结构

> 入口：[`nano-jit.md`](nano-jit.md) · v4.5：[`v4.5/CLEANUP.md`](v4.5/CLEANUP.md)

## 发行面（`*.lisp` 完全自举）

```text
lisp/
  bootstrap/          # bootstrap-v45-*.lisp — 洋葱 / verify / 自举 / DONE
  modules/            # lispjit-modules（13 TU）
  core/               # arithmetic、strlen、ir-table…
  boundary/           # 能力边界样例
.build/nano-jit/nano-jit.com
genesis/
v4.5/                 # ONION-TDD · mindmap · EVAL
```

验收：[`v4.5/ONION-TDD.md`](v4.5/ONION-TDD.md)

## 归档 · 含 C 工厂

```text
archive/c/
  runner/             # lispjit.c 等 C 真源（原 archive/runner）
  factory/
    bootstrap-v4/     # zero-host 自举链
    v4-waves/         # wave tick
    legacy/           # v3/v3.5 bootstrap
    misc/             # slice-add、历史 lisp 样例
archive/v4/slices/    # SLICE 记账
```

`lab/lispjit-ir/*.c` → symlink 至 `archive/c/runner/`。

## 维护工厂

```text
run.sh                # 全量回归（默认 scoped v4.5）
scripts/v45-*-converge.sh
squad/catalog-v45.yaml
```

## 已废弃

`samples/` — 见 [`samples/README.md`](samples/README.md) 迁移表。
