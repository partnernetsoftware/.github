# lisp/ — 发行面 `*.lisp`

验收载体：`nano-jit.com`（对外 **nano-lisp.com**）+ 本目录 plan。

## 子目录

| 目录 | 内容 |
|------|------|
| `bootstrap/` | `bootstrap-v45-*.lisp` |
| `modules/` | lispjit-modules |
| `core/` | VM/AOT 样例 |
| `boundary/` | 边界样例 |

## 洋葱 TDD（plan 内零 `.c` 示例）

- `bootstrap-v45-onion-lisp-only.lisp`
- `bootstrap-v45-selfhost-regenesis-lisp-only.lisp`
- `bootstrap-v45-selfhost-chain-lisp-only.lisp`

## 扩散下一卷

活图：[`v4.5/mindmap-frontier-v45-lisp-com-only.json`](../v4.5/mindmap-frontier-v45-lisp-com-only.json) · [`v4.5/DIFFUSE-WAVE35.md`](../v4.5/DIFFUSE-WAVE35.md)

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-lisp-com-only.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```
