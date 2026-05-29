; Wave82 W1: compose15 bulk-scale pure link — modules-expand 14-16 · 零 hybrid.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf"))
