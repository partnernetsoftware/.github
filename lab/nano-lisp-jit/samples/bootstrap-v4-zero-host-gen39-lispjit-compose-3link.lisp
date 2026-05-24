; gen39: tier-5 compose-3link (TU + lispjit-modules extra TU).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen39-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen39-slice-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/01-runtime-extra.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen39-slice-x86.elf"))
