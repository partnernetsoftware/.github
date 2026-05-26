# nano-lisp-jit

跨架构 Lisp-like JIT · 发行面 = **`nano-jit.com` + `lisp/` 下 `*.lisp`**。

## 目录（2026 梳理）

| 路径 | 用途 |
|------|------|
| [`lisp/`](lisp/README.md) | **完全自举发行面** — bootstrap / modules / core / boundary |
| [`v4.5/`](v4.5/README.md) | 洋葱 TDD · 活图 · 进度 SSOT |
| [`archive/c/`](archive/c/README.md) | 第一代含 **C** 工厂（runner · v4 plan · wave） |
| [`genesis/`](genesis/) | pinned genesis 二进制 |
| [`run.sh`](run.sh) | 维护者全量回归（工厂，非用户入口） |
| [`.build/nano-jit/nano-jit.com`](.build/nano-jit/nano-jit.com) | 种子可执行体（构建产物） |

## 日常（发行面）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
```

## 与 fasmgx

**fasmgx**（fasmg + `.fg`）为**独立仓库/产品线**，不在本目录维护。

## 详细

- 结构地图：[`STRUCTURE.md`](STRUCTURE.md)
- 自举阶梯：[`v4.5/SELFHOST.md`](v4.5/SELFHOST.md)
- 长路线图：[`ROADMAP.md`](ROADMAP.md)
