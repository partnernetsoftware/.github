# Release — 发行面 `.com`（进仓 SSOT）

## _legacy（C runner 154KB slice）_

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp
```

| 文件 | 用途 |
|------|------|
| `nano-lisp.com` | C 产品 COM（Wave68+ 自举链 promote 签收面） |
| `v45-selfhost-next.com` | 自举代际 COM（矩阵 / next 广面） |

## Rust 候选（nanolisp.com v0.1.0）_

```bash
COM=lab/nano-lisp-jit/release/nanolisp.com
$COM version   # 经 run-ape / NANO_JIT 转发
NANO_JIT=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp $COM version
```

| 文件 | 用途 |
|------|------|
| `nanolisp.com` | Rust 双架构 APE stub（x86_64 + aarch64 `nanolisp` CLI） |
| `nanolisp.ape` | 同上 bare 容器 |
| `manifest.txt` | 全部 artifact 的 fnv1a64 + 字节数 pin |

Promote：

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote.sh
```

`.build/` 仍为本地 runtime 缓存（gitignore）；promote 后同步写入本目录并更新 `manifest.txt`。
