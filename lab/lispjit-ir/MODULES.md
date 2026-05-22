# lispjit.c module map (v2 slice 2)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | CLI glue, `parse_size_arg`, `main` |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_manifest.c` | Payload markers, comment manifest parse/dump, `inspect-app`, `is_elf` |
| `nano_compile_cli.c` | `compile` CLI |
| `nano_libc_resolve.c` | `gen-libc-resolve` (ELF dynsym scrape) |
| `nano_run_cli.c` | `run-embedded`, `run-app`, `run-expect-exit`, `file-size`, `file-hash` |
| `nano_pack_app.c` | `pack-app` shell stub + multi-arch ELF + blob payload |
| `nano_ape.c` | APE v1/v2 pack/inspect/run-ape CLI |
| `nano_elf64.c` | ELF64 emit (exec/obj), `emit-elf64-*` CLI, tiny linker |
| `nano_blob_vm.c` | VM `execute_blob`, dump/hash/resolve/run CLI |
| `nano_aot_x86.c` | `parse_aot_module`, AOT x86 codegen, `aot-elf64-*` |
| `nano_compile_elf64_cli.c` | `compile-elf64-obj-code`, `compile-elf64-exe` |
| `nano_lisp_parse.c` | lbin/ljir parser, `compile_module` |
| `nano_bootstrap.c` | Bootstrap plan DSL, `run-bootstrap-plan` |

Next: ABI / slice 3; optional `pack-ape-bare` polish.
