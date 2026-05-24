; gen34: tier-3 multi-func AOT via lispjit.c proxy (exit 43, real func call codegen).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen34-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen34-slice-x86.elf" 43)
  (compile "lab/nano-lisp-jit/samples/multi-func.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen34-multi-func.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen34-multi-func.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen34-slice-x86.elf"))
