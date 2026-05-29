; Wave80 W1: compose15 expand pure link — modules-expand · 零 hybrid.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15me80-expand-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15me80-expand-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15me80-expand-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15me80-expand-pure.elf"))
