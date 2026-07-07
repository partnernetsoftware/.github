; Wave105: factory build lisp-only regenesis — plan 内零 lispjit.c.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-w105-lo-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-w105-lo-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w105-lo-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-w105-factory-lo.com"
            "lab/nano-lisp-jit/.build/v45-w105-lo-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-w105-lo-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-w105-factory-lo.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-w105-factory-lo.com"))
