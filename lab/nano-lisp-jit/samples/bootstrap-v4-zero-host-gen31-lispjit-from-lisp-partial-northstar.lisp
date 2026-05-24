; gen31: linked-tu slice via lispjit.c proxy (env: NANO_LISPJIT_FROM_LISP_PROFILE=linked-tu).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-linked-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-linked-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen31-app.com"))
