; v4.5 wave5: onion acceptance — plan 内零 lispjit.c（build-slice-lisp + ape 洋葱）.
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/ONION-TDD.md")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-onion-lisp-only.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-onion-lo-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-onion-lo-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-onion-lo-ir-aarch64.elf"
                    "aarch64")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-onion-lo-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-onion-lo-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/samples/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-onion-lo-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-onion-lo-strlen.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-onion-lo-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-onion-lo-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-onion-lo-ape.com"
            "lab/nano-lisp-jit/.build/v45-onion-lo-x86.elf"
            "lab/nano-lisp-jit/.build/v45-onion-lo-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-onion-lo-ape.com" 42)
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"))
