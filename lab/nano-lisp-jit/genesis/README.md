# Genesis slice pin

One-time host `cc` / cross-gcc artifacts used when `(build-slice "…/lispjit.c" …)` runs with **zero host cc** (`build-slice.role=genesis-pin`).

Refresh (requires intentional host compiler):

```bash
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

Hashes: see `manifest.txt`.
