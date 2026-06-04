# Release — 发行面 `.com`（进仓 SSOT）

**双轨说明（C vs Rust）**：[`../v4.5/PRODUCT-TRACKS.md`](../v4.5/PRODUCT-TRACKS.md)

## Pinned artifacts（`manifest.txt`）

| 文件 | 字节 | fnv1a64 | 引擎 |
|------|------|---------|------|
| `nano-lisp.com` | 334 537 | `a1904c09aebbf58d` | C runner · APE v2 · 2×166 592 B |
| `v45-selfhost-next.com` | 334 537 | `a1904c09aebbf58d` | 同上（自举 / 矩阵广面） |
| `nanolisp.com` | 2 959 413 | `9ce3029047ffe784` | Rust · `nanolisp.com.engine=rust` |
| `nanolisp.ape` | 2 958 136 | `90761f6dea4915ae` | Rust bare APE 容器 |

Verify locally: `wc -c release/*.com release/*.ape` · hashes in [`manifest.txt`](manifest.txt).

## C track — `nano-lisp.com`（legacy ~327 KiB）

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp
```

Wave / factory gates and promote: see [PRODUCT-TRACKS — C gate](../v4.5/PRODUCT-TRACKS.md#c--nano-lispcom).

## Rust track — `nanolisp.com`（candidate ~2.8 MiB）

```bash
COM=lab/nano-lisp-jit/release/nanolisp.com
$COM version   # 经 run-ape / NANO_JIT 转发
NANO_JIT=lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp $COM version
```

Promote after `nano-jit-rs-gate.sh`:

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote.sh
```

`.build/` 仍为本地 runtime 缓存（gitignore）；promote 后同步写入本目录并更新 `manifest.txt`。
