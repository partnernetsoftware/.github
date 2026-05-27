; gen52: semantic-codegen track milestone — 9-link + terminal on full .com.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-semantic-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-semantic-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-compile.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-compile.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-compile.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/04-vm.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/06-elf.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen52-app.com"))
