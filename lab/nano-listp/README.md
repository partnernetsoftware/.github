# nano-listp

目标：生成跨架构可执行的 `nano-listp.com`，把极小 Lisp-like 源码编译为 portable `.lbin` blob，并在运行时只加载 `.lbin` 执行。

## CLI

```bash
./nano-listp.com compile samples/strlen.lisp strlen.lbin
./nano-listp.com dump strlen.lbin
./nano-listp.com run strlen.lbin
./nano-listp.com resolve --quiet strlen.lbin
```

当前 `.lisp` 语法沿用最小 module DSL：

```lisp
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "ffi")
  (main (call strlen arg)))
```

## 当前能力

- `compile`：解析 `.lisp`，输出 `.lbin` portable blob。
- `dump`：查看 blob header、import、const、instruction 数量。
- `resolve`：只验证 `.lbin` import table 的动态库和符号可解析，不调用函数；适合全量 libc 导入测试。
- `run`：解析 `.lbin`，通过 `dlopen`/`dlsym` 找系统符号，执行 main 指令流。
- 当前签名：`addr`、`u64(ptr)`、`i32(ptr)`、`i32(ptr,ptr)`、`i32()`。
- `u64(ptr)` 仍走 x86_64/aarch64 JIT call stub；其他安全 smoke 签名先用 typed C call。
- `gen_libc_resolve.py` 可从 libc 动态符号表生成 resolver-only `.lisp` manifest。

## 构建与验证

```bash
cd /workspace
bash lab/nano-listp/run.sh
bash lab/nano-listp/build_cosmo.sh
bash lab/nano-listp/build_nano_ape.sh
```

`build_cosmo.sh` 输出 `lab/nano-listp/.build/nano-listp.com`，包含 x86_64 和 aarch64 APE 切片。
默认构建使用 `-mtiny`、section GC 和禁用 unwind/stack protector 的 size profile；当前实测 `nano-listp.com` 约 462KB。
`build_nano_ape.sh` 使用仓库内 `nano_apelink.py` 打包 x86_64/aarch64 ELF，不调用 `cosmocc` 的 `apelink`；这是后续替换完整 APE loader 的 stage0。
