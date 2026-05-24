# v4 wave113 — emit-result-obs

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

## §emit observability

| 日志键 | 来源 | 含义 |
|--------|------|------|
| `aarch64.emit.add.result=N` | `nano_bootstrap.c` add emit | 操作数求和可观测 |
| `aarch64.emit.add.operands=A+B` | 同上 | 解析后的 add 操作数 |
| `nano_elf64.emit.add.bytes=20` | `nano_elf64.c` | lowering 输出 5×4 字节 |
