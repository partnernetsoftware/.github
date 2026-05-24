; gen41: lispjit-modules/00-runtime-core via named profile (modular path kickoff).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen41-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen41-slice-x86.elf" 42)
  (file-size "lab/nano-lisp-jit/samples/lispjit-modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen41-slice-x86.elf"))
