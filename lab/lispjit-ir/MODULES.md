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
| `nano_aot_x86.c` | Pure-blob + AOT x86 codegen, `aot-elf64-*`, `eval_pure_blob` |

| `nano_lisp_parse.c` | lbin/ljir parser, `compile_module`, `compile` path helpers |

Next extractions (fixture-locked): `nano_bootstrap.c` (plan DSL + `run-bootstrap-plan`).
