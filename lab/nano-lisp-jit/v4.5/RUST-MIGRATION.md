# nano-jit.com Rust 迁移

**目标**：商用级 `nano-jit.com` — 多架构 compile + run `.lisp` / `.lbin`，最终替换 C runner。

## 产物模型

```
.lisp  ──compile──▶  .lbin  ──run──▶  exit code
 源（S-expr）         字节码（LBIN01）    VM 执行

ELF slices ──pack-ape──▶  .com  ──run-ape──▶  native exec
```

类比 Java：`.lisp` ≈ `.java`，`.lbin` ≈ `.class`。

## 现状（2026-06）

| 组件 | C | Rust | 进度 |
|------|---|------|------|
| `.lbin` VM run | ✅ | ✅ | 100% |
| `.lisp` → `.lbin` compile | ✅ | ✅ 21/21 `lisp/core` module | 95%（ir-table 另 DSL） |
| `pack-ape` / `pack-ape-bare` | ✅ | ✅ 与 C 字节一致 | 90% |
| `inspect-ape` | ✅ | ✅ | 100% |
| `run-ape` | ✅ | ✅ v2 memfd（bare+stub） | 85% |
| x86_64 / aarch64 CLI 二进制 | ✅ | ✅ cross-build | 90% |
| x86_64 AOT codegen | ✅ | ✅ pure blob exit/code + emit | 70%（obj+link 待补） |
| `run-expect-exit` | ✅ | ✅ | 100% |
| 6-face COM 替换 release | ✅ | ❌ | 0% |

## 验收脚本（产品门禁）

```bash
bash lab/nano-lisp-jit/build_nano_jit_rs.sh
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-smoke.sh          # bootstrap 8 + run
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compile-parity.sh # 21 module hash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-ape-smoke.sh      # pack-ape parity
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-aot-smoke.sh      # AOT ELF + run-expect-exit
cd lab/nano-jit-rs && cargo test
```

## 下一里程碑（商用 SOTA）

1. **run-ape** — memfd + slice 选择 ✅ · v1 manifest 待补
2. **AOT** — x86_64 pure blob ✅ · obj+link + aarch64 codegen 待补
3. **release 替换** — Rust COM 自举 bootstrap-smoke 全链
4. **类型检查** — VM compile 拒 ill-typed（对齐 AOT，见 PRODUCT-FEEDBACK B02/B03）
