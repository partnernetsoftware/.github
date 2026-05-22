# nano-lisp-jit v2.5 — complete (scoped)

**Status: 100%（scoped）** on `main`. Reflection folded into v3 mindmap: `../ROADMAP.md` → `v2.5 反思 · 汇入 v3`.

## Delivered

| Slice | Evidence |
|-------|----------|
| 反思 mindmap | ROADMAP v2.5 节点 |
| 证据门禁 | `build-nano-jit-native-smoke` |
| x86-only self-pack | `self-pack=oracle-x86-duplicate` |
| `nano_util` / `nano_types.h` | include 卫生 |
| AOT 参数 | `(param i64)`×2、`save-top-i64`、负向 fixture |
| VM 参数 | `func-param-vm-parity.lisp`（语义等价；真 `call` → v3） |
| skip 注册表 | `skip_registry.sh` |
| pack 默认 | `NANO_PACK_APE_MODE=stub\|bare` |
| TU 探针 | `verify_tu.sh` |

## Next

**v3 kickoff** — see `../v3/README.md`.
