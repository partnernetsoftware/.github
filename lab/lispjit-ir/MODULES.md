# lispjit.c module map (v2 slice 2)

Build remains one translation unit: `cc lispjit.c` includes submodules below.

| File | Role |
|------|------|
| `lispjit.c` | CLI, VM, AOT, ELF link, bootstrap planner |
| `ape_v2.{h,c}` | APE v2 binary header parse/validate/emit |
| `nano_manifest.c` | Payload markers, comment `# nano.manifest.*` lookup, `is_elf` |
| `nano_ape.c` | APE v1 manifest + pack/inspect/run-ape CLI |

Next extractions (fixture-locked): `nano_elf*.c`, `nano_aot_x86.c`, `nano_blob.c`.
