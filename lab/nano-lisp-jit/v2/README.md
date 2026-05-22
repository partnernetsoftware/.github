# nano-lisp-jit v2 kickoff

Minimal decomposition scaffold (slice 1 kickoff). See `../ROADMAP.md` for the full v2 onion plan.

- **APE v2 / nano-native loader** (slice 1): `\x7fNANOape` binary header per `APE-v2.md`; `pack-ape` / `inspect-ape` / `run-ape` in `lispjit.c` + `lab/lispjit-ir/ape_v2.{h,c}`; v1 `.com` still via manifest fallback.
- **`lispjit.c` module split** (slice 2): parser / blob / vm / aot_x86 / elf / linker / ape / bootstrap partitions without semantic change; lock v1/v1.5 fixture hash/exit first.
- **Function params, locals, ABI** (slice 3): VM first, then x86_64 AOT/object/tiny-link; ABI descriptors replace hard-coded import signatures.
