; Wave78 W1: compose15 pure link — NANO_COMPOSE15_NO_HYBRID=1 · 零 host cc 回退.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf"))
