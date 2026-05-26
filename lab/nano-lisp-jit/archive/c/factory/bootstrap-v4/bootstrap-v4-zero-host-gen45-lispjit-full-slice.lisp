; gen45: tier-7 full profile — ~146KB runner slice (genesis/reuse pin via lispjit-from-lisp).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen45-full-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen45-full-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen45-full-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen45-full-slice-x86.elf"))
