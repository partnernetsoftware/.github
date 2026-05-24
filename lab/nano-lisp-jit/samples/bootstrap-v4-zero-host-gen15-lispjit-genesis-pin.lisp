; gen15: lispjit.c via genesis-pin (zero host cc) — documents NANO_REGENESIS=0 path.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-arithmetic.lbin"))
