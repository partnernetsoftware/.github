# v3.5 nano-cc error codes

Extends [`../v3/ERROR-CODES.md`](../v3/ERROR-CODES.md).

| Exit | When | stderr tag |
|------|------|------------|
| **0** | compile OK | `nano-cc.exit_code=*` |
| **1** | bad args / read fail / expect mismatch | `nano-cc-compile-expect-exit=bad_args`, `nano-cc=read_fail` |
| **2** | unsupported C-subset | `nano-cc=unsupported_source` |
| **3** | ELF emit fail | `nano-cc=emit_fail` |

Negative sample: `samples/nano-cc-bad.c` → **exit 2** via `nano-cc-compile-expect-exit`.
