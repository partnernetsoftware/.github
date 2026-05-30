; v4.5 wave19: lisp-only 自举链 — plan 内零 lispjit.c，pack 二代 .com.
(bootstrap
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-w19-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-w19-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w19-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-w19-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w19-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-w19-lisp-gen2.com"
            "lab/nano-lisp-jit/.build/v45-w19-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-w19-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-w19-lisp-gen2.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-w19-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w19-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-w19-lisp-gen2.com"))
