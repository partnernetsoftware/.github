; Wave99: compose15 semantic-unified — tu-main-154k + sem-* ×14 真模块
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf"))
