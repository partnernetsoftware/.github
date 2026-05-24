; gen21: gen20.com terminal-edge (full north-star smoke on regenesis-propagated runner).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21.com" 42)
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arithmetic.lbin")
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen21-app.com"))
