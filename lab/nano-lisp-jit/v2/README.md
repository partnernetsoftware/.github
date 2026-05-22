# nano-lisp-jit v2 kickoff

Minimal decomposition scaffold (slice 1 kickoff). See `../ROADMAP.md` for the full v2 onion plan.

- **APE v2** (slice 1, done on `main`): `\x7fNANOape` header; `ape_v2.{h,c}`.
- **Module split** (slice 2, in progress): `nano_manifest.c` (markers + comment manifest parse), `nano_ape.c` (pack/inspect/run APE); still `#include`d into `lispjit.c` single TU — no link-line change yet.
- **`lispjit.c` module split** (slice 2): parser / blob / vm / aot_x86 / elf / linker / ape / bootstrap partitions without semantic change; lock v1/v1.5 fixture hash/exit first.
- **Function params, locals, ABI** (slice 3): VM first, then x86_64 AOT/object/tiny-link; ABI descriptors replace hard-coded import signatures.
