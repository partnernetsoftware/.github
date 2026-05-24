; gen46: regenesis .com + full profile — zero host cc, genesis-equivalent slice bytes.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen46-full-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen46-full-slice-x86.elf"
           "lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen46-full-slice-x86.elf"))
