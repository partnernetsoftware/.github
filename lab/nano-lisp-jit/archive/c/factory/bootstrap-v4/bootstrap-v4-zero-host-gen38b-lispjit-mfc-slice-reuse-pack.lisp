; gen38: gen36 slice → selfhost-reuse → chain .com (lispjit-from-lisp bytes propagation).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-reuse-slice-x86.elf"
               "x86_64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-chain.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-reuse-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-chain.com"))
