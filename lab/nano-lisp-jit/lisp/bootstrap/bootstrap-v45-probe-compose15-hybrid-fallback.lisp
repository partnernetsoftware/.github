; Wave77 W2: compose15 hybrid — link stub → compile fallback 158KB + smoke.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-rpc77-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpc77-strlen.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf"))
