; Wave76 W1: plan-only build-slice-compile — 零 genesis-pin · 158KB.
(bootstrap
  (build-slice-compile "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
                       "lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf"
                       "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-zgp76-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-zgp76-strlen.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf"))
