; Wave28 W1: build-slice-lisp 双架构（x86 min + aarch64 ir-exit）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-cg28-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cg28-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-cg28-ir-aarch64.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/v45-cg28-min-x86.elf"))
