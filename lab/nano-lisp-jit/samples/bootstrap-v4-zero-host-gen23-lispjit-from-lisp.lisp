; gen23: lispjit.c satisfied via NANO_LISPJIT_FROM_LISP → nano-jit-runner-core.lisp codegen.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-lispjit-lisp.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-lispjit-lisp.com")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen23-arithmetic.lbin"))
