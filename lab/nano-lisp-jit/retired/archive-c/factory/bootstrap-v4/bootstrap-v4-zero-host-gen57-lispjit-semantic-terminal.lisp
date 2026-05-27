; gen57: tier-10 semantic-terminal — 15link proof + genesis-equivalent runner slice.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen57-terminal-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen57-terminal-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen57-terminal-slice-x86.elf"))
