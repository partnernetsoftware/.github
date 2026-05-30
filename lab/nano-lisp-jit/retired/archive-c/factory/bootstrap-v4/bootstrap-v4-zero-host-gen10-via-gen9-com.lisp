; gen10: gen9.com runs terminal-edge graph (pack-ape + JIT + pack-app) on selfhost outputs.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10.com" 42)
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arithmetic.lbin")
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-arithmetic.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-app.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen9-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen10-app.com"))
