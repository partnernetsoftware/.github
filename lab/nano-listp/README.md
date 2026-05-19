# nano-listp

目标：生成跨架构可执行的 `nano-listp.com`，把极小 Lisp-like 源码编译为 portable `.lbin` blob，并在运行时只加载 `.lbin` 执行。

## CLI

```bash
./nano-listp.com compile samples/strlen.lisp strlen.lbin
./nano-listp.com dump strlen.lbin
./nano-listp.com run strlen.lbin
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
- `run`：解析 `.lbin`，通过 `dlopen`/`dlsym` 找系统符号，生成本机 JIT call stub 后执行。
- 目前支持 x86_64/aarch64 的 `u64(ptr)` 调用路径。

## 构建与验证

```bash
cd /workspace
bash lab/nano-listp/run.sh
bash lab/nano-listp/build_cosmo.sh
```

`build_cosmo.sh` 输出 `lab/nano-listp/.build/nano-listp.com`，包含 x86_64 和 aarch64 APE 切片。
