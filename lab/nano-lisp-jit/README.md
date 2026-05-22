# nano-lisp-jit

目标：生成跨架构可执行的 `nano-lisp-jit.com`，把极小 Lisp-like 源码编译为 portable `.lbin` blob，并在运行时只加载 `.lbin` 执行。

长期目标：推进到可自举的 `nano-jit.com`：用 Lisp/IR 驱动 FFI、JIT、AOT，最终自己编译自己并生成多架构可运行 APE；v3+ 继续作为 AI 友好、图灵完备、可验证的独立基石，逐步吸收 WASM/JVM/JS/SQL 等外部语义。
实现载体会分阶段迁移：v1.5 到 v2 前半仍主要改 `lispjit.c`，v2 后半开始 Lisp-first，v2.5 作为新能力默认走 Lisp/IR 的转折，v3 默认不改 C。
路线图、v1 反思、持续进化循环、v1.5/v2/v3+ 洋葱 TDD mindmap 见 `ROADMAP.md`。
`lab/tool-*` 消费者用法与已知摩擦见 `LAB-USAGE-FEEDBACK.md`。
内存安全借鉴与产品化命名见 `DESIGN-MEMORY-AND-PRODUCT.md`。

当前状态：self-bootstrap v1 已评估为 `100%`，v1.5 约 `88%`。`nano-jit.com` 已能 self-pack，不调用 `apelink`；纯 VM source 可进入 `.lbin`、解释执行、AOT ELF、ELF64 object、tiny-link executable；typed `i64/bool/ptr`、control-flow、multi-func、多 object、load/store-family 和跨 object 数据 smoke 均有 native/container 自举证据；APE manifest 已覆盖 per-slice arch/os/offset/size/fnv1a64、`inspect-ape` 校验和 manifest-aware `run-ape` 执行；含 data 的 ELF executable 已拆成 RX code / RO rodata / RW data load segment 组合，object 路径输出独立 `.data` / `.rodata` 与 `R_X86_64_PC32` relocation，并有 ptr mutability、section flags、layout policy、strict object parse policy、`.Ldata0` / `.Lrodata0` data symbol 命名与 inspect/link 负向 reason 覆盖。

下一会话建议从 `ROADMAP.md` 的 `v1.5 / v2 开工入口` 继续：先用持续反思/学习/进化循环确认 v1 基线，再从 v1.5 的 nano APE manifest fixture 开工；随后处理 pack/inspect/run、`.rodata/.data` section、数据 relocation、`lispjit.c` 分层、bootstrap DSL build graph，以及 v2 的自托管 slice compiler 路径。分层与 data section 属于 v2 前半 C 侧等价推进，build graph 与自托管 slice path 是 v2 后半 Lisp-first 起点；v3+ 不把 v2 当终点，而是继续扩大到外部 VM、语言和查询语义的导入/转译/自举验证。

## CLI

```bash
./nano-lisp-jit.com compile samples/strlen.lisp strlen.lbin
./nano-lisp-jit.com dump strlen.lbin
./nano-lisp-jit.com run strlen.lbin
./nano-lisp-jit.com run-embedded app.com blob_offset blob_size
./nano-lisp-jit.com inspect-ape nano-jit.com
./nano-lisp-jit.com run-ape nano-jit.com
./nano-lisp-jit.com run-ape-expect-exit nano-jit.com 42
./nano-lisp-jit.com inspect-app app.com
./nano-lisp-jit.com run-app app.com
./nano-lisp-jit.com emit-elf64-exit exit42.elf 42
./nano-lisp-jit.com emit-elf64-obj-ret nano_ret42.o nano_ret 42
./nano-lisp-jit.com emit-elf64-obj-call nano_call42.o nano_call nano_ext
./nano-lisp-jit.com aot-elf64-exit arithmetic.lbin arithmetic.elf
./nano-lisp-jit.com aot-elf64-obj-ret arithmetic.lbin arithmetic.o nano_arith
./nano-lisp-jit.com aot-elf64-code arithmetic.lbin arithmetic-code.elf
./nano-lisp-jit.com aot-elf64-obj-code arithmetic.lbin arithmetic-code.o nano_arith_code
./nano-lisp-jit.com compile-elf64-code arithmetic.lisp arithmetic.elf
./nano-lisp-jit.com compile-elf64-obj-code arithmetic.lisp arithmetic.o nano_arith_direct
./nano-lisp-jit.com compile-elf64-exe multi-func.lisp multi-func.elf nano_multi_entry
./nano-lisp-jit.com compile-expect-exit 2 compile-elf64-obj-code bad.lisp bad.o nano_bad
./nano-lisp-jit.com link-elf64-exe arithmetic.elf nano_arith_code arithmetic-code.o [more.o...]
./nano-lisp-jit.com link-expect-exit 2 dup.elf nano_call call.o ext.o dup.o
./nano-lisp-jit.com run-expect-exit arithmetic.elf 42
./nano-lisp-jit.com hash strlen.lbin
./nano-lisp-jit.com file-size strlen.lbin
./nano-lisp-jit.com file-hash strlen.lbin
./nano-lisp-jit.com inspect-elf64-exe const_ptr.elf
./nano-lisp-jit.com inspect-elf64-obj const_ptr.o
./nano-lisp-jit.com gen-libc-resolve libc-resolve.lisp
./nano-lisp-jit.com compare strlen.lbin strlen-repeat.lbin
./nano-lisp-jit.com resolve --quiet strlen.lbin
./nano-lisp-jit.com resolve-quiet strlen.lbin
./nano-lisp-jit.com run-bootstrap-plan samples/bootstrap-smoke.lisp
./nano-lisp-jit.com pack-ape nano-jit.com nano-jit.x86_64 nano-jit.aarch64
./nano-lisp-jit.com pack-app app.com nano-jit.x86_64 nano-jit.aarch64 strlen.lbin
```

### 消费者集成注意事项

- 外部工具优先通过 `NANO_JIT=/path/to/nano-lisp-jit` 指定 runner；`lab/_nano_common.sh` 会优先使用该环境变量，未设置时沿用仓库内 `lab/nano-lisp-jit/.build/nano-lisp-jit`。
- `resolve-quiet program.lbin` 已作为顶层 CLI alias 接入，等价于 `resolve --quiet program.lbin`；`(resolve-quiet ...)` 仍是 bootstrap DSL 步骤名。
- `pack-ape` 会按 `ape-v1` 写入各 slice 的 arch/os/offset/size/fnv1a64；外部工具应优先用 `inspect-ape` 读取 manifest，不要假设固定 stub 偏移。
- `inspect-ape file.com` 现在会拒绝非 `ape-v1` container、缺失 slice 字段、越界 payload、非 canonical slice layout、arch/os 不匹配和 slice hash 不一致；`inspect-app` 仍保持通用 manifest dump 行为。
- `run-ape file.com [host|x86_64|aarch64]` 会按 manifest 选择 slice 并执行；unsupported arch 返回 `126`，脚本可用 `run-ape-expect-exit` 固定断言。
- 含 data 的 ELF executable 不再假定单 RWX segment；外部工具如需看 segment 权限，应使用 `inspect-elf64-exe`，不要硬编码 data 紧跟 `.text` 的权限假设。
- `inspect-elf64-exe` 会输出 `elf64.exec.layout=split_rx_rw`、`split_rx_ro`、`split_rx_ro_rw` 或 `single_rwx_compat`；后者是无 data 旧执行段兼容层，后续满足删除条件后再收敛。
- 含 `const-ptr` 的 ELF object 现在通过 `.data` + `R_X86_64_PC32` 表达 code->data 引用；外部工具可用 `inspect-elf64-obj` 读取 section / relocation 证据。
- `inspect-elf64-obj` 会输出 `elf64.obj.layout=section_data`、`elf64.obj.data.policy=section_pc32` 与当前 local data symbol；writable `.data` 的本地基符号约定为 `.Ldata0`。
- `const-ptr` 是只读指针，`store-*` 会在 AOT/codegen 阶段以 `store-to-rodata` 拒绝；`mut-ptr` 是显式可写指针，即使没有 store 也进入 `.data` / RW segment。
- 对不含 store 的 const-ptr code/object，`aot-elf64-code` / `compile-elf64-code` 会输出 RO load segment，`aot-elf64-obj-code` 会输出 `.rodata`（flags `a`）和 `.Lrodata0`，tiny linker 会保留为 executable 的 `r_load_segment`。
- tiny linker 会拒绝 unsupported data relocation 与异常 local section index；调用方可用 `link-expect-exit 4 ...` 固定断言这类失败。
- tiny linker 会在 parse 阶段拒绝坏 `.text/.data` flags、坏 `.rela.text` link、重复关键 section 与乱序 local/global symtab；调用方可用 `inspect-elf64-obj` 的 reason（如 `bad_text_flags`、`bad_rela_symtab_link`、`bad_symtab_order`）或 `link-expect-exit 2 ...` 固定断言这类坏 object。
- `run-bootstrap-plan` 的 checked-in 样例默认从 repo root 执行；外部工具若从子目录调用，应传入 repo-root 相对路径或先切到 repo root。
- `run program.lbin` 的进程退出码等于 VM 最后一条返回值；脚本自测应优先写 `(expect ...)`，或用 `run-expect-exit` 固定断言。
- `compile-elf64-*` / `aot-elf64-*` 当前面向 x86_64 Linux；跨平台调用方应像 `run.sh` 一样在非 x86_64 host 上跳过。

当前 `.lisp` 语法沿用最小 module DSL：

```lisp
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "ffi")
  (main
    (call strlen arg)
    (expect 3)))
```

纯 VM 算术也可以不经 FFI：

```lisp
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
```

typed value 现在支持最小 `i64 / bool / ptr`：

```lisp
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const word "ffi")
  (main
    (i64 -42)
    (add-i64 0)
    (sub-i64 0)
    (mul-i64 1)
    (eq-i64 -42)
    (expect true)
    (i64 -43)
    (lt-i64 -42)
    (expect true)
    (i64 -41)
    (gt-i64 -42)
    (expect true)
    (i64 -41)
    (ne-i64 -42)
    (expect true)
    (i64 -42)
    (le-i64 -42)
    (expect true)
    (i64 -41)
    (ge-i64 -42)
    (expect true)
    (i64 -42)
    (expect -42)
    (bool false)
    (not-bool)
    (expect true)
    (and-bool false)
    (expect false)
    (or-bool true)
    (expect true)
    (null-ptr)
    (expect null)
    (is-null-ptr)
    (expect true)
    (null-ptr)
    (add-ptr 8)
    (ptr-to-u64)
    (expect 8)
    (u64-to-ptr)
    (expect nonnull)
    (null-ptr)
    (add-ptr 8)
    (sub-ptr 8)
    (expect null)
    (null-ptr)
    (add-ptr 8)
    (expect nonnull)
    (is-nonnull-ptr)
    (expect true)
    (const-ptr word)
    (load-u8)
    (expect 102)
    (const-ptr word)
    (load-u16)
    (expect 26214)
    (const-ptr word)
    (load-u32)
    (expect 6907494)
    (mut-ptr word)
    (store-u8 103)
    (load-u8)
    (expect 103)
    (mut-ptr word)
    (store-u16 26729)
    (load-u16)
    (expect 26729)
    (mut-ptr word)
    (store-u32 1819043176)
    (load-u32)
    (expect 1819043176)
    (resolve strlen)
    (expect nonnull)
    (is-nonnull-ptr)
    (expect true)))
```

控制流当前支持最小 `block / branch / label`，`branch` 读取上一条 `bool`：

```lisp
(module
  (main
    (block
      (bool true)
      (branch taken)
      (u64 1)
      (expect 999)
      (label taken)
      (i64 -7)
      (expect -7))))
```

多函数 object backend 当前支持最小内部 call relocation：

```lisp
(module
  (func helper
    (u64 40)
    (add-u64 2))
  (main
    (call helper)
    (add-u64 1)
    (expect 43)))
```

多函数 source AOT 现在也支持跨内部 `call` 保留 `i64` / `bool` / `u64` 返回类型：

```lisp
(module
  (func neg-base
    (i64 -7))
  (func ready
    (call neg-base)
    (lt-i64 0))
  (main
    (call neg-base)
    (add-i64 -35)
    (expect -42)
    (call ready)
    (branch ready-path)
    (label ready-path)
    (u64 43)
    (expect 43)))
```

bootstrap 子流程现在也可以先用 `.lisp` 描述，再由 nano 自己执行：

```lisp
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-arithmetic.lbin")
  (hash "lab/nano-lisp-jit/.build/bootstrap-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/samples/typed-values.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-typed-values.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/bootstrap-smoke-typed-values.lbin")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-smoke-typed-values.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-smoke-typed-values.lbin")
  (compile "lab/nano-lisp-jit/samples/ptr-values.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-ptr-values.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-smoke-ptr-values.lbin")
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (gen-libc-resolve "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lisp")
  (compile "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lisp" "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lbin")
  (pack-ape "lab/nano-lisp-jit/.build/bootstrap-ape.com" "lab/nano-lisp-jit/.build/nano-lisp-jit" "lab/nano-lisp-jit/.build/nano-lisp-jit")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-ape.com")
  (pack-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com" "lab/nano-lisp-jit/.build/nano-lisp-jit" "lab/nano-lisp-jit/.build/nano-lisp-jit" "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com")
  (run-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com")
  (run "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin"))
```

bootstrap DSL 也能描述一条最小 AOT/codegen/tiny-link 构建图，不需要外部 `cc/ld`：

```lisp
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic.lbin")
  (aot-elf64-code "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-code.elf")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-code.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-code.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-bad.lbin")
  (aot-elf64-code "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-bad.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-bad-code.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-arithmetic-bad-code.elf" 125)
  (compile "lab/nano-lisp-jit/samples/ptr-values.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-ptr-values.lbin")
  (compile "lab/nano-lisp-jit/samples/const-ptr-load-u8.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8.lbin")
  (aot-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-exit.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-exit.elf" 1)
  (aot-elf64-code "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-code.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-code.elf" 1)
  (aot-elf64-obj-code "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-code.o" "nano_bootstrap_const_ptr_code")
  (link-elf64-exe "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-linked" "nano_bootstrap_const_ptr_code" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-code.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8-linked" 1)
  (emit-elf64-obj-call "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-call.o" "nano_bootstrap_const_ptr_call" "nano_bootstrap_const_ptr_callee")
  (aot-elf64-obj-code "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-load-u8.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-callee.o" "nano_bootstrap_const_ptr_callee")
  (link-elf64-exe "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-cross-linked" "nano_bootstrap_const_ptr_call" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-call.o" "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-callee.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-const-ptr-cross-linked" 1)
  (aot-elf64-code "lab/nano-lisp-jit/.build/bootstrap-aot-ptr-values.lbin" "lab/nano-lisp-jit/.build/bootstrap-aot-ptr-values-code.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-ptr-values-code.elf" 1)
  (compile-elf64-exe "lab/nano-lisp-jit/samples/multi-func-ptr.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-multi-ptr-direct.elf" "nano_bootstrap_multi_ptr_direct")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-multi-ptr-direct.elf" 1)
  (emit-elf64-obj-call "lab/nano-lisp-jit/.build/bootstrap-aot-call42.o" "nano_bootstrap_call" "nano_bootstrap_ext")
  (emit-elf64-obj-ret "lab/nano-lisp-jit/.build/bootstrap-aot-ext42.o" "nano_bootstrap_ext" 42)
  (link-elf64-exe "lab/nano-lisp-jit/.build/bootstrap-aot-call42-linked" "nano_bootstrap_call" "lab/nano-lisp-jit/.build/bootstrap-aot-call42.o" "lab/nano-lisp-jit/.build/bootstrap-aot-ext42.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-call42-linked" 42)
  (emit-elf64-obj-ret "lab/nano-lisp-jit/.build/bootstrap-aot-dup42.o" "nano_bootstrap_ext" 7)
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/multi-func-recursive-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-recursive-bad.o" "nano_bootstrap_recursive_bad")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/multi-func-recursive-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-recursive-bad.elf" "nano_bootstrap_recursive_bad")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-ptr-op-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-ptr-op.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-expect-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-expect-ptr.o" "nano_bootstrap_type_bad_expect_ptr")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-add-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-add-ptr.o" "nano_bootstrap_type_bad_add_ptr")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-sub-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-sub-ptr.o" "nano_bootstrap_type_bad_sub_ptr")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-ptr-to-u64-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-ptr-to-u64.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-ptr-to-u64-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-ptr-to-u64.o" "nano_bootstrap_type_bad_ptr_to_u64")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-ptr-to-u64-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-ptr-to-u64-exe.elf" "nano_bootstrap_type_bad_ptr_to_u64")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-u64-to-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-u64-to-ptr.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-u64-to-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-u64-to-ptr.o" "nano_bootstrap_type_bad_u64_to_ptr")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-u64-to-ptr-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-u64-to-ptr-exe.elf" "nano_bootstrap_type_bad_u64_to_ptr")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-load-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u8.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-load-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u8.o" "nano_bootstrap_type_bad_load_u8")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-load-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u8-exe.elf" "nano_bootstrap_type_bad_load_u8")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-load-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u16.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-load-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u16.o" "nano_bootstrap_type_bad_load_u16")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-load-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u16-exe.elf" "nano_bootstrap_type_bad_load_u16")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-load-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u32.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-load-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u32.o" "nano_bootstrap_type_bad_load_u32")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-load-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-load-u32-exe.elf" "nano_bootstrap_type_bad_load_u32")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8.o" "nano_bootstrap_type_bad_store_u8")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u8-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8-exe.elf" "nano_bootstrap_type_bad_store_u8")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u8-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u8-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8-range.o" "nano_bootstrap_type_bad_store_u8_range")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u8-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u8-range-exe.elf" "nano_bootstrap_type_bad_store_u8_range")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16.o" "nano_bootstrap_type_bad_store_u16")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u16-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16-exe.elf" "nano_bootstrap_type_bad_store_u16")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u16-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u16-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16-range.o" "nano_bootstrap_type_bad_store_u16_range")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u16-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u16-range-exe.elf" "nano_bootstrap_type_bad_store_u16_range")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32.o" "nano_bootstrap_type_bad_store_u32")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u32-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32-exe.elf" "nano_bootstrap_type_bad_store_u32")
  (compile-expect-exit 2 compile-elf64-code "lab/nano-lisp-jit/samples/type-error-store-u32-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "lab/nano-lisp-jit/samples/type-error-store-u32-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32-range.o" "nano_bootstrap_type_bad_store_u32_range")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-store-u32-range-bad.lisp" "lab/nano-lisp-jit/.build/bootstrap-aot-type-bad-store-u32-range-exe.elf" "nano_bootstrap_type_bad_store_u32_range")
  (link-expect-exit 2 "lab/nano-lisp-jit/.build/bootstrap-aot-dup-should-fail" "nano_bootstrap_call" "lab/nano-lisp-jit/.build/bootstrap-aot-call42.o" "lab/nano-lisp-jit/.build/bootstrap-aot-ext42.o" "lab/nano-lisp-jit/.build/bootstrap-aot-dup42.o"))
```

## 当前能力

- `compile`：解析 `.lisp`，输出 `.lbin` portable blob。
- `dump`：查看 blob header、import、const、instruction 数量。
- `compare`：比较两个 blob 字节是否完全一致，用于 deterministic 编译测试。
- `file-size`：输出任意文件字节数，脚本报告不再依赖 `wc -c`。
- `file-hash`：输出任意文件的 FNV-1a64 hash，`nano-jit.com` 报告不再依赖 `sha256sum`。
- `gen-libc-resolve`：直接读取 libc ELF `.dynsym` 并生成 resolver manifest，不再依赖 Python/`nm`。
- `run-expect-exit`：运行 ELF 并断言退出码，供 native smoke 和 bootstrap DSL 复用。
- `link-expect-exit`：执行 tiny linker 并断言失败码，用于 duplicate-symbol 等负向 linker smoke。
- `compile-expect-exit`：执行编译类子命令并断言失败码，用于递归 local call、typed ptr/bool 误用等负向 source AOT smoke。
- `resolve`：验证 `.lbin` import table 的动态库和符号可解析；运行时会把解析到的函数地址放进当前 `ptr` typed value，适合全量 libc 导入测试或指针断言。
- `run-bootstrap-plan`：读取最小 bootstrap DSL，顺序执行 `compile` / `gen-libc-resolve` / `dump` / `file-size` / `file-hash` / `hash` / `compare` / `resolve-quiet` / `pack-ape` / `inspect-ape` / `pack-app` / `inspect-app` / `run-app` / `run` / `emit-elf64-exit` / `emit-elf64-obj-ret` / `emit-elf64-obj-call` / `aot-elf64-exit` / `aot-elf64-obj-ret` / `aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code` / `compile-elf64-obj-code` / `compile-elf64-exe` / `compile-expect-exit` / `link-elf64-exe` / `link-expect-exit` / `run-expect-exit` 子流程，开始把 shell 片段迁到 `.lisp` 描述。
- `run`：解析 `.lbin`，通过 `dlopen`/`dlsym` 找系统符号，执行 main 指令流。
- `run-embedded`：从 `.com` 容器内按 payload 偏移直接读取并执行内嵌 blob。
- `inspect-ape`：读取 nano APE manifest，输出 `ape-v1` container、slice offset 和 size。
- `inspect-app`：读取 AOT app manifest，输出 runtime slice 和 blob 的 offset/size。
- `run-app`：读取 AOT app manifest，自动定位并执行 `.com` 内嵌 blob。
- `emit-elf64-exit`：直接写最小 x86_64 Linux ELF，可作为替换 slice compiler 的第一块。
- `emit-elf64-obj-ret`：直接写带 `.text/.symtab/.strtab` 的 ELF64 relocatable object。
- `emit-elf64-obj-call`：直接写带 `.rela.text` 的 ELF64 relocatable object，验证外部符号重定位。
- `aot-elf64-exit`：静态求值纯 VM `.lbin`，直接生成对应 exit code 的 ELF。
- `aot-elf64-obj-ret`：静态求值纯 VM `.lbin`，生成可链接的 ELF64 function object。
- `aot-elf64-code`：把纯 VM typed/control-flow/ptr-null 子集编译成 x86_64 机器码 ELF。
- `aot-elf64-obj-code`：把纯 VM typed/control-flow/ptr-null 子集编译成可链接的 ELF64 function object。
- `compile-elf64-code` / `compile-elf64-obj-code`：直接从 `.lisp` 生成 ELF 或 object，减少外部脚本胶水。
- `compile-elf64-obj-code` 当前已支持多函数 pure VM source、内部 `call`、基础 relocation，以及 `i64` / `bool` / `ptr` / `branch` / `label` typed/control-flow 子集。
- `compile-elf64-exe`：直接从多函数 pure VM source 生成可运行 ELF，内部复用 object backend 和 tiny linker。
- `link-elf64-exe`：链接当前 nano object 子集，支持 `input.o...` 多 object，输出可运行 x86_64 ELF。
- `hash`：输出 `.lbin` 的内建 FNV-1a 64-bit hash，用于 deterministic 编译测试。
- `(expect N)` / `(expect -N)` / `(expect true|false)` / `(expect null|nonnull)`：在 `.lbin` 内断言上一条结果，失败时 runtime 返回非零。
- `(u64 N)` / `(add-u64 N)` / `(i64 N)` / `(add-i64 N)` / `(sub-i64 N)` / `(mul-i64 N)` / `(eq-i64 N)` / `(ne-i64 N)` / `(lt-i64 N)` / `(gt-i64 N)` / `(le-i64 N)` / `(ge-i64 N)` / `(bool true|false)` / `(not-bool)` / `(and-bool true|false)` / `(or-bool true|false)` / `(null-ptr)` / `(const-ptr name)` / `(add-ptr N)` / `(sub-ptr N)` / `(ptr-to-u64)` / `(u64-to-ptr)` / `(load-u8)` / `(load-u16)` / `(load-u32)` / `(store-u8 N)` / `(store-u16 N)` / `(store-u32 N)` / `(is-null-ptr)` / `(is-nonnull-ptr)`：最小 typed VM 内核，不依赖 FFI。
- `block` / `branch label` / `label`：最小控制流；静态求值 AOT（`aot-elf64-exit` / `aot-elf64-obj-ret`）和机器码 codegen（`aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code`）现在都支持该纯 VM 子集。
- `func` + `main`：当前在 `compile-elf64-obj-code` / `compile-elf64-exe` 的纯 VM AOT source 路径支持；helper 函数默认生成为 object 内部 local symbol。
- `bootstrap`：当前最小 DSL 支持 `.lbin` 编译/哈希/比较/运行、AOT ELF/codegen/object 生成、tiny-link、app 打包/检查/运行，以及 typed compile failure / linker failure / runtime failure 退出码断言，作为 shell bootstrap 的第一块可执行描述。
- `pack-ape`：把 x86_64/aarch64 ELF slice 打进一个 `.com`，写出 `ape-v1` manifest，运行时按 host arch 选择 payload。
- `pack-app`：把 runtime slices 和 `.lbin` 打进一个多架构 `.com` 应用，运行时直接从自身容器执行内嵌 blob。
- 当前签名：`addr`、`u64(ptr)`、`i32(ptr)`、`i32(ptr,ptr)`、`i32()`、`i32(i32)`。
- `u64(ptr)` 仍走 x86_64/aarch64 JIT call stub；其他安全 smoke 签名先用 typed C call。
- `gen-libc-resolve` 可从 libc 动态符号表生成 resolver-only `.lisp` manifest。

## 构建与验证

```bash
cd /workspace
bash lab/nano-lisp-jit/run.sh
bash lab/nano-lisp-jit/build_cosmo.sh
bash lab/nano-lisp-jit/build_nano_ape.sh
bash lab/nano-lisp-jit/build_nano_jit.sh
```

`build_cosmo.sh` 输出 `lab/nano-lisp-jit/.build/nano-lisp-jit.com`，包含 x86_64 和 aarch64 APE 切片。
默认构建使用 `-mtiny`、section GC 和禁用 unwind/stack protector 的 size profile；当前实测 `nano-lisp-jit.com` 约 462KB。
`build_nano_ape.sh` 使用刚编出的 `nano-lisp-jit` 自身执行 `pack-ape`，打包 x86_64/aarch64 ELF，不调用 `cosmocc` 的 `apelink`；`nano_apelink.py` 仅保留作参考实现。
`build_nano_jit.sh` 生成 `nano-jit.com` 并写出 `bootstrap-report.txt`；当前仍临时使用 `cosmocc` 编译架构切片，但 `.com` 打包、AOT app 打包和 blob 自测由 `nano-jit` 自己完成。
