# Release — 发行面 `.com`（进仓 SSOT）

用户路径唯一 COM 真源：

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp
```

| 文件 | 用途 |
|------|------|
| `nano-lisp.com` | 产品 COM（Wave68+ 自举链 promote 签收面） |
| `v45-selfhost-next.com` | 自举代际 COM（矩阵 / next 广面） |
| `manifest.txt` | fnv1a64 + 字节数 pin |

`.build/` 仍为本地 runtime 缓存（gitignore）；收敛 promote 后应同步写入本目录并更新 `manifest.txt`。
