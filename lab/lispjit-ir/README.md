# lispjit-ir

目标：验证“发布 portable IR blob，运行时解析 IR 并 JIT 执行”的方向。

## 现在实现了什么

- `samples/strlen.lispir`：极小 Lisp-like 源，只作为编译输入。
- `compile_blob.py`：把源编译为 `.ljir` portable IR blob。
- `irjit.c`：只加载 `.ljir`，解析 import table/常量池/IR 指令，然后生成本机 JIT call stub。
- `run.sh`：生成 blob、编译 runtime、执行 blob 并输出体积。

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

## 当前边界

- 已支持 x86_64/aarch64 的 `u64(ptr)` JIT call stub。
- 还不是完整 Lisp；这是 LispJIT 发布物形态的最小验证。
- AOT 可以在下一步加入：把 JIT 结果保存为 arch/OS 专用 native cache，并保留 import relocation table。
