; gen59: full .com + semantic-terminal slice.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen59-terminal-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen59-terminal-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen59-terminal-slice-x86.elf"))
