; gen30c: full gen30.com runner executes lispjit-from-lisp (zero host cc for lispjit.c).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30c-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30c-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30c-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30c-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30-full-nano-jit.com"))
