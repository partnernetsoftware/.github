; Wave98: compose15 semantic-full — 15 槽 modules-semantic 真镜像 · 零 bulk-expand
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf"))
