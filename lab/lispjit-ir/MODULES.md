# lispjit.c module map (v2 slice 2)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | CLI glue, emit-elf64 stubs, `pack-app`, `main` |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_manifest.c` | Payload markers, comment manifest parse/dump, `inspect-app`, `is_elf` |
| `nano_ape.c` | APE v1/v2 pack/inspect/run-ape CLI |
| `nano_elf64.c` | ELF64 emit (exec/obj), tiny linker, `link-elf64-exe` |
| `nano_blob_vm.c` | VM `execute_blob`, dump/hash/resolve/run CLI |
| `nano_aot_x86.c` | AOT module parse (`parse_aot_module`), pure-blob + AOT x86 codegen, `aot-elf64-*`, `eval_pure_blob` |
| `nano_lisp_parse.c` | lbin/ljir parser, `compile_module`, `compile` path helpers |
| `nano_bootstrap.c` | Bootstrap plan DSL parse, expect-exit helpers, `run-bootstrap-plan` |

Next extractions (fixture-locked): move `pack-app` out of `lispjit.c`; in-process ELF loader (Mode B).
