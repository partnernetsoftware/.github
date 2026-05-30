; Wave73 W3: lisp-only regenesis pack — plan 内零 lispjit.c（wave3 模式）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-njc-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-njc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-njc-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-njc-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-njc-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-njc-lisp-only.com"
            "lab/nano-lisp-jit/.build/v45-njc-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-njc-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-njc-lisp-only.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-njc-lisp-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-njc-lisp-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-njc-lisp-only.com"))
