; gen27: lispjit-from-lisp slices → pack-ape + pack-app terminal smoke (regenesis runner).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-lispjit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-aarch64.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-arithmetic.lbin")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-lispjit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen27-app.com"))
