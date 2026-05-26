; gen14-fat: repack gen13 lisp-route x86 + gen9-class slice from genesis-pin build (no lispjit.c in plan).
(bootstrap
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-fat-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-lisp-route-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-fat-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-fat-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-fat-arithmetic.lbin"))
