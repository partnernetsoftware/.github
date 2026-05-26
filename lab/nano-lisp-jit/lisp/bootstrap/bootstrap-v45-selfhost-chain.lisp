; v4.5 selfhost chain: genesis compare + lisp slice + modules + regenesis pack (plan 无 .sh).
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/SELFHOST.md")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-zero-host-gen60-lispjit-from-lisp-done.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-selfhost-genesis-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/v45-selfhost-genesis-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (build-slice "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
               "lab/nano-lisp-jit/.build/v45-selfhost-lisp-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-selfhost-lisp-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-selfhost-chain-parse.lbin")
  (run "lab/nano-lisp-jit/.build/v45-selfhost-chain-parse.lbin")
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-selfhost-regen-x86.elf"
               "x86_64")
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-selfhost-regen-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-selfhost-next.com"
            "lab/nano-lisp-jit/.build/v45-selfhost-regen-x86.elf"
            "lab/nano-lisp-jit/.build/v45-selfhost-regen-aarch64.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-selfhost-next.com"))
