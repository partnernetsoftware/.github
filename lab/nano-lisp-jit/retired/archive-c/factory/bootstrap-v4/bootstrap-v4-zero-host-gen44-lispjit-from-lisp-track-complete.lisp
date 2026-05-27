; gen44: lispjit-from-lisp track complete — compose-5link + terminal on full .com runner.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-compile.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-compile.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-compile.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/02-compile.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen44-app.com"))
