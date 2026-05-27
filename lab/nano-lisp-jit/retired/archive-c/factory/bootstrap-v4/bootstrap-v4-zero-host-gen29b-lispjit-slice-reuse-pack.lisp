; gen29b: selfhost-reuse gen29a slice → pack chain .com (env: NANO_BUILD_SLICE_SELFHOST_REUSE).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-reuse-slice-x86.elf"
               "x86_64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-chain.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-reuse-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-chain.com"))
