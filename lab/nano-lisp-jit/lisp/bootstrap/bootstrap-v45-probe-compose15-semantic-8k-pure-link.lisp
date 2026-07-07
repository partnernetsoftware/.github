; Wave94: compose15 semantic 8K — modules-semantic · 零 bulk-expand
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15-semantic-8k-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15-semantic-8k-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15-semantic-8k-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-8k-pure.elf"))
