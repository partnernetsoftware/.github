# lispjit.c module map (v2 slice 2)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | CLI glue, `main` |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_manifest.c` | Payload markers, comment manifest parse/dump, `inspect-app`, `is_elf` |
| `nano_run_cli.c` | `run-embedded`, `run-app`, `run-expect-exit`, `file-size`, `file-hash` |
| `nano_pack_app.c` | `pack-app` shell stub + multi-arch ELF + blob payload |
| `nano_ape.c` | APE v1/v2 pack/inspect/run-ape CLI |
| `nano_elf64.c` | ELF64 emit (exec/obj), `emit-elf64-*` CLI, tiny linker, `link-elf64-exe` |
| `nano_blob_vm.c` | VM `execute_blob`, dump/hash/resolve/run CLI |
| `nano_compile_cli.c` | `compile_source_path_to_blob`, `compile` CLI |
| `nano_aot_x86.c` | AOT module parse (`parse_aot_module`), pure-blob + AOT x86 codegen, `aot-elf64-*`, `compile-elf64-code`, `eval_pure_blob` |
| `nano_compile_elf64_cli.c` | Source-path `compile-elf64-obj-code`, `compile-elf64-exe` (AOT module → ELF64 obj/exe) |
| `nano_lisp_parse.c` | lbin/ljir parser, `compile_module` |
| `nano_bootstrap.c` | Bootstrap plan DSL parse, expect-exit helpers, `run-bootstrap-plan` |

Next extractions (fixture-locked): in-process ELF loader Mode B; ABI / slice 3.
