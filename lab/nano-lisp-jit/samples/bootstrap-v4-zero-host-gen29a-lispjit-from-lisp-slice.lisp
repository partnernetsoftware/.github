; gen29a: single lispjit-from-lisp slice (feeds gen29b reuse).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-lisp-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-lisp-slice-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen29-lisp-slice-x86.elf"))
