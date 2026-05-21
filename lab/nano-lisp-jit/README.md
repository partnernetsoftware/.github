# nano-lisp-jit

目标：生成跨架构可执行的 `nano-lisp-jit.com`，把极小 Lisp-like 源码编译为 portable `.lbin` blob，并在运行时只加载 `.lbin` 执行。

长期目标：推进到可自举的 `nano-jit.com`：用 Lisp/IR 驱动 FFI、JIT、AOT，最终自己编译自己并生成多架构可运行 APE。
路线图见 `ROADMAP.md`。

## CLI

```bash
./nano-lisp-jit.com compile samples/strlen.lisp strlen.lbin
./nano-lisp-jit.com dump strlen.lbin
./nano-lisp-jit.com run strlen.lbin
./nano-lisp-jit.com run-embedded app.com blob_offset blob_size
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
./nano-lisp-jit.com link-elf64-exe arithmetic.elf nano_arith_code arithmetic-code.o [more.o...]
./nano-lisp-jit.com link-expect-exit 2 dup.elf nano_call call.o ext.o dup.o
./nano-lisp-jit.com run-expect-exit arithmetic.elf 42
./nano-lisp-jit.com hash strlen.lbin
./nano-lisp-jit.com file-size strlen.lbin
./nano-lisp-jit.com file-hash strlen.lbin
./nano-lisp-jit.com gen-libc-resolve libc-resolve.lisp
./nano-lisp-jit.com compare strlen.lbin strlen-repeat.lbin
./nano-lisp-jit.com resolve --quiet strlen.lbin
./nano-lisp-jit.com run-bootstrap-plan samples/bootstrap-smoke.lisp
./nano-lisp-jit.com pack-app app.com nano-jit.x86_64 nano-jit.aarch64 strlen.lbin
```

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
    (resolve strlen)
    (expect nonnull)))
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
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (gen-libc-resolve "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lisp")
  (compile "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lisp" "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/bootstrap-libc-resolve.lbin")
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
  (emit-elf64-obj-call "lab/nano-lisp-jit/.build/bootstrap-aot-call42.o" "nano_bootstrap_call" "nano_bootstrap_ext")
  (emit-elf64-obj-ret "lab/nano-lisp-jit/.build/bootstrap-aot-ext42.o" "nano_bootstrap_ext" 42)
  (link-elf64-exe "lab/nano-lisp-jit/.build/bootstrap-aot-call42-linked" "nano_bootstrap_call" "lab/nano-lisp-jit/.build/bootstrap-aot-call42.o" "lab/nano-lisp-jit/.build/bootstrap-aot-ext42.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-aot-call42-linked" 42)
  (emit-elf64-obj-ret "lab/nano-lisp-jit/.build/bootstrap-aot-dup42.o" "nano_bootstrap_ext" 7)
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
- `resolve`：验证 `.lbin` import table 的动态库和符号可解析；运行时会把解析到的函数地址放进当前 `ptr` typed value，适合全量 libc 导入测试或指针断言。
- `run-bootstrap-plan`：读取最小 bootstrap DSL，顺序执行 `compile` / `gen-libc-resolve` / `dump` / `file-size` / `file-hash` / `hash` / `compare` / `resolve-quiet` / `pack-app` / `inspect-app` / `run-app` / `run` / `emit-elf64-exit` / `emit-elf64-obj-ret` / `emit-elf64-obj-call` / `aot-elf64-exit` / `aot-elf64-obj-ret` / `aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code` / `compile-elf64-obj-code` / `compile-elf64-exe` / `link-elf64-exe` / `link-expect-exit` / `run-expect-exit` 子流程，开始把 shell 片段迁到 `.lisp` 描述。
- `run`：解析 `.lbin`，通过 `dlopen`/`dlsym` 找系统符号，执行 main 指令流。
- `run-embedded`：从 `.com` 容器内按 payload 偏移直接读取并执行内嵌 blob。
- `inspect-app`：读取 AOT app manifest，输出 runtime slice 和 blob 的 offset/size。
- `run-app`：读取 AOT app manifest，自动定位并执行 `.com` 内嵌 blob。
- `emit-elf64-exit`：直接写最小 x86_64 Linux ELF，可作为替换 slice compiler 的第一块。
- `emit-elf64-obj-ret`：直接写带 `.text/.symtab/.strtab` 的 ELF64 relocatable object。
- `emit-elf64-obj-call`：直接写带 `.rela.text` 的 ELF64 relocatable object，验证外部符号重定位。
- `aot-elf64-exit`：静态求值纯 VM `.lbin`，直接生成对应 exit code 的 ELF。
- `aot-elf64-obj-ret`：静态求值纯 VM `.lbin`，生成可链接的 ELF64 function object。
- `aot-elf64-code`：把纯 VM typed/control-flow 子集编译成 x86_64 机器码 ELF。
- `aot-elf64-obj-code`：把纯 VM typed/control-flow 子集编译成可链接的 ELF64 function object。
- `compile-elf64-code` / `compile-elf64-obj-code`：直接从 `.lisp` 生成 ELF 或 object，减少外部脚本胶水。
- `compile-elf64-obj-code` 当前已支持多函数 pure VM source、内部 `call`、基础 relocation，以及 `i64` / `bool` / `branch` / `label` typed/control-flow 子集。
- `compile-elf64-exe`：直接从多函数 pure VM source 生成可运行 ELF，内部复用 object backend 和 tiny linker。
- `link-elf64-exe`：链接当前 nano object 子集，支持 `input.o...` 多 object，输出可运行 x86_64 ELF。
- `hash`：输出 `.lbin` 的内建 FNV-1a 64-bit hash，用于 deterministic 编译测试。
- `(expect N)` / `(expect -N)` / `(expect true|false)` / `(expect null|nonnull)`：在 `.lbin` 内断言上一条结果，失败时 runtime 返回非零。
- `(u64 N)` / `(add-u64 N)` / `(i64 N)` / `(add-i64 N)` / `(sub-i64 N)` / `(mul-i64 N)` / `(eq-i64 N)` / `(ne-i64 N)` / `(lt-i64 N)` / `(gt-i64 N)` / `(le-i64 N)` / `(ge-i64 N)` / `(bool true|false)` / `(not-bool)` / `(and-bool true|false)` / `(or-bool true|false)`：最小 typed VM 内核，不依赖 FFI。
- `block` / `branch label` / `label`：最小控制流；静态求值 AOT（`aot-elf64-exit` / `aot-elf64-obj-ret`）和机器码 codegen（`aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code`）现在都支持该纯 VM 子集。
- `func` + `main`：当前仅在 `compile-elf64-obj-code` 的纯 VM AOT source 路径支持；helper 函数默认生成为 object 内部 local symbol。
- `bootstrap`：当前最小 DSL 支持 `.lbin` 编译/哈希/比较/运行、AOT ELF/codegen/object 生成、tiny-link、app 打包/检查/运行，以及 `run-expect-exit` 可执行文件退出码断言，作为 shell bootstrap 的第一块可执行描述。
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
