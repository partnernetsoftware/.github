# archive/c — 第一代含 C 工厂（只读回归）

> 发行面 **不** 依赖本目录。用户路径：`lisp/` + `nano-jit.com`。

| 路径 | 内容 |
|------|------|
| [`runner/`](runner/) | `lispjit.c` 等 C TU 真源 |
| [`factory/bootstrap-v4/`](factory/bootstrap-v4/) | `bootstrap-v4-zero-host-*` 自举链 |
| [`factory/legacy/`](factory/legacy/) | v3/v3.5 等历史 bootstrap |
| [`factory/misc/`](factory/misc/) | slice-add、证据 rollup 等工厂 lisp |
| [`factory/v4-waves/`](factory/v4-waves/) | ~660 wave tick（自 `archive/samples/` 迁入） |

维护：`NANO_V45_FULL_FACTORY=1 bash lab/nano-lisp-jit/run.sh`（工厂全量，非发行面）。
