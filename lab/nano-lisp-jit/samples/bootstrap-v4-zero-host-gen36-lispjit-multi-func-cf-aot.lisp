; gen36: tier-4 multi-func-cf AOT (control-flow + i64) via lispjit.c proxy.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen36-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen36-slice-x86.elf" 43)
  (compile "lab/nano-lisp-jit/samples/multi-func-control-flow.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen36-mfc.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen36-mfc.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen36-slice-x86.elf"))
