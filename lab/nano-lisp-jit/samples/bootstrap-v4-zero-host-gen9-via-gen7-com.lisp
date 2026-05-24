; gen9: gen7.com full JIT rebuild (alternate fat generation after gen8 thin pack).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-nano-jit.com"))
