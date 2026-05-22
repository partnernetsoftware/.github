# lispjit.c module map (v2 slice 2)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | CLI, VM, AOT, ELF link, bootstrap planner |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_manifest.c` | Payload markers, comment manifest parse/dump, `inspect-app`, `is_elf` |
| `nano_ape.c` | APE v1 manifest + pack/inspect/run-ape CLI |
| `nano_elf64.c` | ELF64 emit (exec/obj), tiny linker, `emit-elf64-*` / `link-elf64-exe` |

| `nano_blob_vm.c` | lbin/ljir parse bounds, VM `execute_blob`, dump/hash/resolve/run CLI |

Next extractions (fixture-locked): `nano_aot_x86.c` (AOT codegen), `nano_parse.c` (lisp/lispir parser).
