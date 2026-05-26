# nano-lisp-jit

`*.lisp` 自举 **`nano-lisp.com`**（用户路径无 `.c` / `.sh` / `.py`）。  
方法：**洋葱 TDD × mindmap 活图** — 广度设计 → 四轨并发 → 收敛 → 循环（见 [`v4.5/MINDMAP-TDD-TREE.md`](v4.5/MINDMAP-TDD-TREE.md)）。

## 目录

| 路径 | 用途 |
|------|------|
| [`lisp/`](lisp/README.md) | 发行面 `*.lisp` |
| [`v4.5/`](v4.5/README.md) | 洋葱 TDD · 活图 · 扩散 wave |
| [`archive/c/`](archive/c/README.md) | 含 C 工厂（维护回归，非发行面） |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-terminal.lisp
bash lab/nano-lisp-jit/scripts/v45-wave44-nano-lisp-com-terminal-converge.sh
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

## 详细

[`STRUCTURE.md`](STRUCTURE.md) · [`v4.5/ONION-TDD.md`](v4.5/ONION-TDD.md) · [`v4.5/HONEST-REMAINING.md`](v4.5/HONEST-REMAINING.md)
