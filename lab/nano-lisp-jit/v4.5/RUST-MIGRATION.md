# nanolisp.com Rust 迁移

**目标**：商用级 **nanolisp.com** Lisp 运行时 — 多架构 compile + run `.lisp` / `.lbin`，最终替换 C runner。内部 JIT / FFI / AOT 不进产品名。

## 品牌 rename（进行中）

| 对外 | 内部 crate / 路径 |
|------|------------------|
| 产品 `nanolisp.com` | `lab/nano-jit-rs/`（crate 名暂保留 `nano-jit-rs`） |
| CLI 二进制 `nanolisp` | `src/brand.rs` |
| 兼容 symlink `nano-jit` | build 脚本自动创建 |

`version` 输出主行：`nanolisp.com=0.1.0`；保留 `nano-jit-rs=` 供 CI 过渡。

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
| x86_64 AOT codegen | ✅ | ✅ obj+link + rodata/data + multi-func CF | 90% |
| `link-elf64-exe` | ✅ | ✅ | 100% |
| `compile-elf64-exe` | ✅ | ✅ multi-func + control-flow exit 43 | 85% |
| `compile-elf64-obj-code` / `aot-elf64-obj-code` | ✅ | ✅ obj+link 分步 | 90% |
| lisp-tu 两 TU link | ✅ | ✅ exit 42 + 92B parity | 90% |
| `run-expect-exit` | ✅ | ✅ | 100% |
| 6-face COM 替换 release | ✅ | ❌ | 0% |

## 验收脚本（产品门禁）

```bash
bash lab/nano-lisp-jit/build_nano_jit_rs.sh
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-smoke.sh          # bootstrap 8 + run
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compile-parity.sh # 21 module hash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-ape-smoke.sh      # pack-ape parity
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-aot-smoke.sh      # AOT ELF + run-expect-exit
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-lisp-tu-link-smoke.sh  # two-TU link exit 42
bash lab/nano-lisp-jit/retired/scripts/nano-jit-rs-gate.sh          # all of the above + cargo test
cd lab/nano-jit-rs && cargo test
```

## 下一里程碑（商用 SOTA）

1. **run-ape** — memfd + slice 选择 ✅ · v1 manifest 待补
2. **AOT** — x86_64 obj+link ✅ · multi-func CF ✅ · obj-only CLI ✅ · aarch64 待补
3. **release 替换** — Rust COM 自举 bootstrap-smoke 全链（下一步：compose-15 模块链）
4. **类型检查** — VM compile 拒 ill-typed（对齐 AOT，见 PRODUCT-FEEDBACK B02/B03）
