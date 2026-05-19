# lispjit-ir

目标：第一个可用的超迷你 LispJIT：发布 portable IR blob，运行时加载 blob 并 JIT 执行。

## 现在实现了什么

- `lispjit.c`：主程序，支持 `compile` / `run` / `dump`。
- `samples/strlen.lispir`：极小 Lisp-like 输入，编译后不需要随发布物分发。
- `compile_blob.py`、`irjit.c`：早期拆分原型，保留作格式参考。
- `run.sh`：native 自测。
- `build_cosmo.sh`：使用 cosmocc 构建 x86_64+aarch64 APE 多架构程序。

## CLI

```bash
# 编译 Lisp-like 源到 portable IR blob
./lispjit compile samples/strlen.lispir strlen.ljir

# 查看 blob
./lispjit dump strlen.ljir

# 加载 blob，解析 import，生成本机 JIT call stub 并执行
./lispjit run strlen.ljir
```

## Blob 格式

`.ljir` 是小端二进制：

1. header：magic、版本、表数量、字符串池大小。
2. import table：逻辑库名、符号名、签名。
3. const table：常量类型、字符串池偏移。
4. instruction table：当前最小支持 `CALL_IMPORT_CONST` + `RET_LAST`。
5. string pool：库名、符号、常量字符串。

样例 IR：

```lisp
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "ffi")
  (main (call strlen arg)))
```

执行时不需要 Lisp 源；runtime 只读 `.ljir`。

## Cosmopolitan 构建

```bash
cd /workspace
bash lab/lispjit-ir/build_cosmo.sh
```

脚本需要 `third_party/cosmocc/bin` 下存在：

- `x86_64-unknown-cosmo-cc`
- `aarch64-unknown-cosmo-cc`
- `apelink`

当前仓库未跟踪 `third_party/cosmocc/`，所以没有工具链时脚本会明确报 `cosmocc=missing`。

## 当前边界

- 已支持 x86_64/aarch64 的 `u64(ptr)` JIT call stub。
- 还不是完整 Lisp；当前可用集合是 import、string const、main call。
- AOT 可以在下一步加入：把 JIT 结果保存为 arch/OS 专用 native cache，并保留 import relocation table。
