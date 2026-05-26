; v4.5 selfhost: seed .com builds next .com via build-slice + pack-ape (plan 无 .c/.sh).
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-selfhost-regen-x86.elf"
               "x86_64")
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-selfhost-regen-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-selfhost-next.com"
            "lab/nano-lisp-jit/.build/v45-selfhost-regen-x86.elf"
            "lab/nano-lisp-jit/.build/v45-selfhost-regen-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-selfhost-next-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-selfhost-next-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-selfhost-next.com"))
