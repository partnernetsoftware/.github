# lab/nano-lisp-jit 目录结构

## 发行面（用户路径 · v4.5）

```text
nano-jit.com / nano-lisp-jit.com     # 唯一二进制（.build/nano-jit/ 或 genesis seed）
samples/
  bootstrap-v45-*.lisp               # 洋葱 TDD + verify 矩阵
  boundary/*.lisp                    # 能力边界样例
  *.lisp                             # VM/AOT 模块样例
genesis/nano-jit.x86_64              # bootstrap pin（非日常 host cc）
v4.5/                                # 规格 · ONION-TDD · EVAL · REFLECTION
```

入口文档：[`v4.5/ONION-TDD.md`](v4.5/ONION-TDD.md)

## 开发工厂（维护者 · 逐步退役）

```text
run.sh                               # 全量回归 + 证据落盘（仍引用 v4 SLICE 文档）
build_nano_jit.sh                    # 构建 nano-jit.com
lab/lispjit-ir/*.c                   # runner 源码
tools/gen-v4-wave-batch.py           # 历史生波
v4/SLICE*.md                         # 波次文档（244）；run.sh 仍 grep
squad/catalog-v4.yaml                # v4 catalog
```

## 归档

[`archive/`](archive/) — v2/v3/v3.5 文档与 squad 快照；**勿**再增 bootstrap-v3* 波次。

## 子目录

| 路径 | 用途 |
|------|------|
| [`samples/lispjit-modules/`](samples/lispjit-modules/) | lispjit-from-lisp 模块 TU |
| [`samples/boundary/`](samples/boundary/) | v4.5 边界探测 |
| [`genesis/`](genesis/) | pinned runner slices |
| [`squad/`](squad/) | catalog-v4.yaml · catalog-v45.yaml |
| [`.build/`](.build/) | 产物与 `.evidence`（gitignore） |
