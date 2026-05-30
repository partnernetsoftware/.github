# nano-lisp-jit v2 — complete (scoped)

See `../ROADMAP.md` for the full onion plan. v2 scoped delivery is **100%** on `main`.

| Slice | Status | Evidence |
|-------|--------|----------|
| APE v2 header + inspect/run | **100%** | `APE-v2.md`, `ape_v2.{h,c}`, `pack-ape` / `pack-ape-bare`, bootstrap + `make_ape_fixtures.py` |
| Module decomposition | **100%** | 14× `lab/lispjit-ir/nano_*.c` + `nano_main.c`; `lispjit.c` ~720 lines |
| In-process loader | **100%** scoped | `run-ape.loader=memfd`; stub `NANO_JIT` → `run-ape` |
| ABI descriptors | **100%** scoped | `nano_abi.c`, `bootstrap-abi-smoke.lisp` |
| AOT function params | **100%** scoped | `(param i64)`, `load-arg-i64`, `func-param-i64.lisp` |
| Self-hosted x86 slice | **100%** scoped | `NANO_SLICE_COMPILER=native` in `build_nano_jit.sh` |

**v3+** (not v2): VM locals/SSA, aarch64 native slice compiler, WASM/JS/SQL lowering.
