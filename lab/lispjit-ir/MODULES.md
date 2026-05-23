# lispjit.c module map (v2 complete)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | Blob layout defines, shared helpers, include chain |
| `nano_types.h` | `Module`, `AotModule`, `Bootstrap*`, `Value`/`ValueKind`, `OP_*` / `SRC_FORM_*` / `AOT_STMT_*` / `BOOTSTRAP_STEP_*` |
| `nano_main.c` | `usage`, `main` (CLI dispatch) |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_types.h` | Shared opcodes, `Module` / `AotModule` / `Bootstrap*` / `Value` types |
| `nano_abi.c` | FFI import `SIG_*` IDs, `sig_parse` / `sig_name` |
| `nano_util.c` | `parse_size_arg` (decimal size CLI args) |
| `nano_manifest.c` | Payload markers, comment manifest parse/dump, `inspect-app`, `is_elf` |
| `nano_compile_cli.c` | `compile` CLI |
| `nano_libc_resolve.c` | `gen-libc-resolve` (ELF dynsym scrape) |
| `nano_run_cli.c` | `run-embedded`, `run-app`, `run-expect-exit`, `file-size`, `file-hash` |
| `nano_pack_app.c` | `pack-app` / `pack-ape-bare` payloads |
| `nano_ape.c` | APE v1/v2 pack/inspect/run-ape CLI |
| `nano_elf64.c` | ELF64 emit (exec/obj), `emit-elf64-*` CLI, tiny linker |
| `nano_cc.c` | Minimal `nano-cc` C-subset (`int main` + `return imm`) → ELF |
| `nano_blob_vm.c` | VM `execute_blob`, dump/hash/resolve/run CLI |
| `nano_aot_x86.c` | `parse_aot_module`, AOT x86 codegen, `aot-elf64-*`, `(param i64)` |
| `nano_compile_elf64_cli.c` | `compile-elf64-obj-code`, `compile-elf64-exe` |
| `nano_lisp_parse.c` | lbin/ljir parser, `compile_module` |
| `nano_bootstrap.c` | Bootstrap plan DSL, `run-bootstrap-plan` |

v2 module split: **100%**. v2.5: `nano_types.h`, `nano_util.c`, native self-pack oracle — see `lab/nano-lisp-jit/v2.5/README.md`. v3+: VM params, aarch64 native slice.
