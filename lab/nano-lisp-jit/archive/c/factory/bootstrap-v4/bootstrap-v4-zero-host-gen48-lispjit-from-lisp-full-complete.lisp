; gen48: lispjit-from-lisp full runner complete — full profile + terminal on full .com.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-full-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-full-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-compile.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-compile.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-compile.lbin")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-full-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen48-app.com"))
