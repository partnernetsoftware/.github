# nano-listp

目标：生成跨架构可执行的 `nano-listp.com`，把极小 Lisp-like 源码编译为 portable `.lbin` blob，并在运行时只加载 `.lbin` 执行。

长期目标：推进到可自举的 `nano-jit.com`：用 Lisp/IR 驱动 FFI、JIT、AOT，最终自己编译自己并生成多架构可运行 APE。
路线图见 `ROADMAP.md`。

## CLI

```bash
./nano-listp.com compile samples/strlen.lisp strlen.lbin
./nano-listp.com dump strlen.lbin
./nano-listp.com run strlen.lbin
./nano-listp.com run-embedded app.com blob_offset blob_size
./nano-listp.com inspect-app app.com
./nano-listp.com emit-elf64-exit exit42.elf 42
./nano-listp.com emit-elf64-obj-ret nano_ret42.o nano_ret 42
./nano-listp.com emit-elf64-obj-call nano_call42.o nano_call nano_ext
./nano-listp.com aot-elf64-exit arithmetic.lbin arithmetic.elf
./nano-listp.com aot-elf64-obj-ret arithmetic.lbin arithmetic.o nano_arith
./nano-listp.com aot-elf64-code arithmetic.lbin arithmetic-code.elf
./nano-listp.com aot-elf64-obj-code arithmetic.lbin arithmetic-code.o nano_arith_code
./nano-listp.com compile-elf64-code arithmetic.lisp arithmetic.elf
./nano-listp.com compile-elf64-obj-code arithmetic.lisp arithmetic.o nano_arith_direct
./nano-listp.com link-elf64-exe arithmetic.elf nano_arith_code arithmetic-code.o
./nano-listp.com hash strlen.lbin
./nano-listp.com resolve --quiet strlen.lbin
./nano-listp.com run-bootstrap-plan samples/bootstrap-smoke.lisp
./nano-listp.com pack-app app.com nano-jit.x86_64 nano-jit.aarch64 strlen.lbin
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
    (expect -42)
    (bool true)
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

多函数 source AOT 现在也支持最小 typed/control-flow 子集：

```lisp
(module
  (func helper
    (block
      (bool true)
      (branch typed-path)
      (label typed-path)
      (i64 -7)
      (expect -7)
      (u64 42)))
  (main
    (call helper)
    (add-u64 1)
    (expect 43)))
```

bootstrap 子流程现在也可以先用 `.lisp` 描述，再由 nano 自己执行：

```lisp
(bootstrap
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-listp/.build/bootstrap-smoke.lbin" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (run "lab/nano-listp/.build/bootstrap-smoke.lbin"))
```

bootstrap DSL 也能描述一条最小 AOT/codegen/tiny-link 构建图，不需要外部 `cc/ld`：

```lisp
(bootstrap
  (compile "lab/nano-listp/samples/arithmetic.lisp" "lab/nano-listp/.build/bootstrap-aot-arithmetic.lbin")
  (aot-elf64-code "lab/nano-listp/.build/bootstrap-aot-arithmetic.lbin" "lab/nano-listp/.build/bootstrap-aot-arithmetic-code.elf")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-arithmetic-code.elf" 42)
  (compile-elf64-obj-code "lab/nano-listp/samples/multi-func-control-flow.lisp" "lab/nano-listp/.build/bootstrap-aot-multi-ctrl.o" "nano_bootstrap_multi_ctrl")
  (link-elf64-exe "lab/nano-listp/.build/bootstrap-aot-multi-ctrl-linked" "nano_bootstrap_multi_ctrl" "lab/nano-listp/.build/bootstrap-aot-multi-ctrl.o")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-multi-ctrl-linked" 43))
```

## 当前能力

- `compile`：解析 `.lisp`，输出 `.lbin` portable blob。
- `dump`：查看 blob header、import、const、instruction 数量。
- `resolve`：验证 `.lbin` import table 的动态库和符号可解析；运行时会把解析到的函数地址放进当前 `ptr` typed value，适合全量 libc 导入测试或指针断言。
- `run-bootstrap-plan`：读取最小 bootstrap DSL，顺序执行 `compile` / `hash` / `compare` / `pack-app` / `inspect-app` / `run` / `emit-elf64-exit` / `aot-elf64-exit` / `aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code` / `compile-elf64-obj-code` / `link-elf64-exe` / `run-expect-exit` 子流程，开始把 shell 片段迁到 `.lisp` 描述。
- `run`：解析 `.lbin`，通过 `dlopen`/`dlsym` 找系统符号，执行 main 指令流。
- `run-embedded`：从 `.com` 容器内按 payload 偏移直接读取并执行内嵌 blob。
- `inspect-app`：读取 AOT app manifest，输出 runtime slice 和 blob 的 offset/size。
- `emit-elf64-exit`：直接写最小 x86_64 Linux ELF，可作为替换 slice compiler 的第一块。
- `emit-elf64-obj-ret`：直接写带 `.text/.symtab/.strtab` 的 ELF64 relocatable object。
- `emit-elf64-obj-call`：直接写带 `.rela.text` 的 ELF64 relocatable object，验证外部符号重定位。
- `aot-elf64-exit`：静态求值纯 VM `.lbin`，直接生成对应 exit code 的 ELF。
- `aot-elf64-obj-ret`：静态求值纯 VM `.lbin`，生成可链接的 ELF64 function object。
- `aot-elf64-code`：把纯 VM typed/control-flow 子集编译成 x86_64 机器码 ELF。
- `aot-elf64-obj-code`：把纯 VM typed/control-flow 子集编译成可链接的 ELF64 function object。
- `compile-elf64-code` / `compile-elf64-obj-code`：直接从 `.lisp` 生成 ELF 或 object，减少外部脚本胶水。
- `compile-elf64-obj-code` 当前已支持多函数 pure VM source、内部 `call`、基础 relocation，以及 `i64` / `bool` / `branch` / `label` typed/control-flow 子集。
- `link-elf64-exe`：链接当前 nano object 子集，输出可运行 x86_64 ELF。
- `hash`：输出 `.lbin` 的内建 FNV-1a 64-bit hash，用于 deterministic 编译测试。
- `(expect N)` / `(expect -N)` / `(expect true|false)` / `(expect null|nonnull)`：在 `.lbin` 内断言上一条结果，失败时 runtime 返回非零。
- `(u64 N)` / `(add-u64 N)` / `(i64 N)` / `(bool true|false)`：最小 typed VM 内核，不依赖 FFI。
- `block` / `branch label` / `label`：最小控制流；静态求值 AOT（`aot-elf64-exit` / `aot-elf64-obj-ret`）和机器码 codegen（`aot-elf64-code` / `aot-elf64-obj-code` / `compile-elf64-code`）现在都支持该纯 VM 子集。
- `func` + `main`：当前仅在 `compile-elf64-obj-code` 的纯 VM AOT source 路径支持；helper 函数默认生成为 object 内部 local symbol。
- `bootstrap`：当前最小 DSL 支持 `.lbin` 编译/哈希/比较/运行、AOT ELF/codegen/object 生成、tiny-link、app 打包/检查，以及 `run-expect-exit` 可执行文件退出码断言，作为 shell bootstrap 的第一块可执行描述。
- `pack-app`：把 runtime slices 和 `.lbin` 打进一个多架构 `.com` 应用，运行时直接从自身容器执行内嵌 blob。
- 当前签名：`addr`、`u64(ptr)`、`i32(ptr)`、`i32(ptr,ptr)`、`i32()`、`i32(i32)`。
- `u64(ptr)` 仍走 x86_64/aarch64 JIT call stub；其他安全 smoke 签名先用 typed C call。
- `gen_libc_resolve.py` 可从 libc 动态符号表生成 resolver-only `.lisp` manifest。

## 构建与验证

```bash
cd /workspace
bash lab/nano-listp/run.sh
bash lab/nano-listp/build_cosmo.sh
bash lab/nano-listp/build_nano_ape.sh
bash lab/nano-listp/build_nano_jit.sh
```

`build_cosmo.sh` 输出 `lab/nano-listp/.build/nano-listp.com`，包含 x86_64 和 aarch64 APE 切片。
默认构建使用 `-mtiny`、section GC 和禁用 unwind/stack protector 的 size profile；当前实测 `nano-listp.com` 约 462KB。
`build_nano_ape.sh` 使用刚编出的 `nano-listp` 自身执行 `pack-ape`，打包 x86_64/aarch64 ELF，不调用 `cosmocc` 的 `apelink`；`nano_apelink.py` 仅保留作参考实现。
`build_nano_jit.sh` 生成 `nano-jit.com` 并写出 `bootstrap-report.txt`；当前仍临时使用 `cosmocc` 编译架构切片，但 `.com` 打包、AOT app 打包和 blob 自测由 `nano-jit` 自己完成。
