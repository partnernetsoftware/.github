; gen55: full .com + compose-15link semantic-full.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen55-semantic15-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen55-semantic15-slice-x86.elf" 42)
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen55-semantic15-slice-x86.elf"))
