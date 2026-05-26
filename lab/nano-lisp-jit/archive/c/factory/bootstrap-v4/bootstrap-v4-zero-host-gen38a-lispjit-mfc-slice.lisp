; gen38a: tier-4 slice only (feeds gen38 reuse pack).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-mfc-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-mfc-slice-x86.elf" 43)
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen38-mfc-slice-x86.elf"))
