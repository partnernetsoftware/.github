; gen60: lispjit-from-lisp DONE — semantic-terminal + pack-app terminal on full .com.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-terminal-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-terminal-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-parse.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-parse.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app-arm.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-parse.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen60-app.com"))
