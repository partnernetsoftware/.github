; Wave97: compose15 semantic 154K — modules-semantic tu-main-154k · 对齐 bulk SSOT
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15-semantic-154k-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15-semantic-154k-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15-semantic-154k-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-154k-pure.elf"))
