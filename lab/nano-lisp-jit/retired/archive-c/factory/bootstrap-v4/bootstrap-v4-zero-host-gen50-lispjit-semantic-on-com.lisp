; gen50: regenesis .com + semantic-codegen (pure Lisp 9-link, no pin).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen50-semantic-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen50-semantic-slice-x86.elf" 42)
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen50-semantic-slice-x86.elf"))
