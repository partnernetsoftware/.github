; Wave25 W1: build-slice-lisp min profile.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-cg-lo-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cg-lo-min-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-cg-lo-min-x86.elf"))
