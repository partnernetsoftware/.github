# nano-jit.com Rust 迁移

**目标**：`nano-jit.com` 多架构 compile + run `.lisp` / `.lbin`，逐步替换 C runner。

## 现状（2026-06）

| 组件 | C (`lispjit.c`) | Rust (`nano-jit-rs`) |
|------|-----------------|----------------------|
| `.lbin` VM run | ✅ | ✅ Phase 1 |
| `.lisp` compile | ✅ | ✅ Phase 2a (arithmetic/strlen) |
| x86_64 AOT | ✅ | ❌ Phase 3 |
| aarch64 codegen | stub | ❌ Phase 3 |
| APE pack/inspect | ✅ | inspect ✅ / pack ❌ |
| 6-face COM | Linux 2/2 | 待 Phase 4 |

## 仓库布局

```
lab/nano-jit-rs/          # Rust crate (SSOT for new runner)
lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit   # release binary
lab/lispjit-ir/nano_types.h  # wire format SSOT (shared)
```

## 停止 Wave 证据链

Rust 重构期间优先 **cargo test + smoke**，不再开 Wave106+ 记账卷。

## 验收（MVP → 产品）

1. `nano-jit run` 与 C COM 对同一 `.lbin` exit 0
2. `cargo build --target aarch64-unknown-linux-gnu` 产出可运行二进制
3. Rust `compile` 替代 legacy bridge
4. `pack-ape` + dual slice 无 C 种子
