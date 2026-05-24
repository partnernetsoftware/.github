; gen35: full gen30.com — tier-3 multi-func AOT lispjit-from-lisp.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen35-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen35-slice-x86.elf" 43)
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen30-full-nano-jit.com"))
