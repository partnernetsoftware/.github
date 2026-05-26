; gen53: tier-9 compose-15link — all nano subsystem modules (pure Lisp codegen).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen53-semantic15-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen53-semantic15-slice-x86.elf" 42)
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen53-semantic15-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/lisp/modules/07-abi.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
