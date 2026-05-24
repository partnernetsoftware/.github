; gen56: semantic-full track — 15-link + terminal on full .com.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-semantic15-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-semantic15-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/lispjit-modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-parse.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-parse.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-parse.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen56-app.com"))
