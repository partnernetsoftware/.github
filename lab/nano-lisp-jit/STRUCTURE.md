# lab/nano-lisp-jit 目录结构

> 清理后地图 · 详见 [`v4.5/CLEANUP.md`](v4.5/CLEANUP.md)

## 发行面（用户 · v4.5）

```text
nano-jit.com                         # .build/nano-jit/nano-jit.com
samples/bootstrap-v45-*.lisp         # 洋葱 TDD / verify / DONE
samples/boundary/*.lisp              # 能力边界
samples/{arithmetic,strlen,...}.lisp # 核心 VM 样例
genesis/nano-jit.x86_64
v4.5/                                # ONION-TDD · PROGRESS · EVAL · REFLECTION
```

入口：[`v4.5/ONION-TDD.md`](v4.5/ONION-TDD.md)

## v4 活跃文档（14 个）

[`v4/INDEX.md`](v4/INDEX.md) — PROGRESS · DECISION · MINDMAP · TERMINAL-BFS · …

## 归档

| 路径 | 内容 |
|------|------|
| [`archive/v4/slices/`](archive/v4/slices/) | 244× `SLICE*.md` |
| [`archive/v4/factory-docs/`](archive/v4/factory-docs/) | LONG-RUN · DIFFUSE · DEV-AGENTS |
| [`archive/versions/`](archive/versions/) | v2–v3.5 |
| [`archive/specs/`](archive/specs/) | APE 规范 |

## 开发工厂

```text
run.sh                               # 全量回归（路径已指向 archive/v4/slices）
build_nano_jit.sh
lab/lispjit-ir/*.c
samples/bootstrap-v4-wave*           # ~660（仍 wired）
samples/bootstrap-v4-zero-host-*     # 自举链
tools/gen-v4-wave-batch.py
squad/catalog-v4.yaml · catalog-v45.yaml
```

## 子目录

| 路径 | 用途 |
|------|------|
| [`samples/README.md`](samples/README.md) | 样例命名梳理 |
| [`samples/lispjit-modules/`](samples/lispjit-modules/) | gen60 模块 TU |
| [`.build/`](.build/) | 产物 · evidence（gitignore） |
