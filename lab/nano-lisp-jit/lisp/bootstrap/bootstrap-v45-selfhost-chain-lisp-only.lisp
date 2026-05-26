; v4.5 factory: selfhost chain 零 plan 内 lispjit.c（lisp slice + lisp-only regenesis）.
(bootstrap
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-chain-lo-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-chain-lo-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-chain-lo-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-chain-lo-add-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-chain-lo-parse.lbin")
  (run "lab/nano-lisp-jit/.build/v45-chain-lo-parse.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-chain-lo-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-chain-lo-next.com"
            "lab/nano-lisp-jit/.build/v45-chain-lo-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-chain-lo-ir-aarch64.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-chain-lo-next.com"))
