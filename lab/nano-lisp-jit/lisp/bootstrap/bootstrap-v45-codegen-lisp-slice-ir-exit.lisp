; Wave25 W2: build-slice-lisp ir-exit profile.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-cg-lo-ir-aarch64.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/v45-cg-lo-ir-aarch64.elf"))
