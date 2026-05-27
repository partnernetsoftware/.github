; Wave75 W1: plan-only full runner — genesis-pin build-slice 158KB + smoke.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-fr75-genesis-pin-x86.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-fr75-genesis-pin-x86.elf")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-fr75-pin-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fr75-pin-strlen.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-fr75-genesis-pin-x86.elf"))
