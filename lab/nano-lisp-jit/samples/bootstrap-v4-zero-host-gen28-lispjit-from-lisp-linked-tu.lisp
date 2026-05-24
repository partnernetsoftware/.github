; gen28: lispjit.c via NANO_LISPJIT_FROM_LISP_PROFILE=linked-tu (multi-TU link codegen).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen28-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen28-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen28-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen28-arithmetic.lbin"))
