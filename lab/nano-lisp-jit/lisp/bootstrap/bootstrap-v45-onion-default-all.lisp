; Wave36 W2: 默认洋葱 — 主路径 onion-lisp-only（plan 内零 lispjit.c build-slice）.
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/ONION-TDD.md")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave6-onion-primary.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave7-release-audit.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-oda-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-oda-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-oda-ir-aarch64.elf"
                    "aarch64")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-oda-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-oda-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-oda-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-oda-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-oda-ape.com"
            "lab/nano-lisp-jit/.build/v45-oda-x86.elf"
            "lab/nano-lisp-jit/.build/v45-oda-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-oda-ape.com" 42)
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp"))
