; v4.5 wave3: lisp-only .com regenesis — plan 内零 lispjit.c（仿 gen22）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-w3-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-w3-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w3-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-w3-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w3-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"
            "lab/nano-lisp-jit/.build/v45-w3-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-w3-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-w3-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w3-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"))
