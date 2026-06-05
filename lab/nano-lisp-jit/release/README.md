# Release — 发行面 `.com`（进仓 SSOT）

**双轨说明（C vs Rust）**：[`../v4.5/PRODUCT-TRACKS.md`](../v4.5/PRODUCT-TRACKS.md)

## Pinned artifacts（`manifest.txt`）

| 文件 | 字节 | fnv1a64 | 引擎 |
|------|------|---------|------|
| `nano-lisp.com` | 867 097 | `5e0553e39544a245` | C runner · shell rodata · `run-stdin` · `build-slice-lisp-profile` |
| `v45-selfhost-next.com` | 867 097 | `5e0553e39544a245` | 同上（自举 / 矩阵广面） |
| `nanolisp.com` | 3 000 373 | `9d0e46a2f16c8a3a` | Rust · `nanolisp.com.engine=rust` |
| `nanolisp.ape` | 2 999 096 | `eced03845028df90` | Rust bare APE 容器 |
| `nanolisp-slim.com` | ~161 083 | (see manifest) | Rust genesis-pin APE pathfinder (~48% of C COM size) |

Verify locally: `wc -c release/*.com release/*.ape` · hashes in [`manifest.txt`](manifest.txt).

**Progress**: [`../v4.5/OVERALL-PROGRESS.md`](../v4.5/OVERALL-PROGRESS.md) · **Gates**: `nanolisp-dual-gate.sh` (C + Rust)

## C track — `nano-lisp.com`（Wave 6 pin · ~843 KiB · shell embed）

Shell ladder closure: [`../v4.5/SHELL-CLOSURE.md`](../v4.5/SHELL-CLOSURE.md) · probe: `bash lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh`

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp
```

Wave / factory gates and promote: see [PRODUCT-TRACKS — C gate](../v4.5/PRODUCT-TRACKS.md#c--nano-lispcom).

## Rust track — `nanolisp.com`（candidate ~2.9 MiB）

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
