; Wave73 W2: /goal nano-jit.com 矩阵 — release 产品 COM + tier0 smoke.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-njc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-njc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-njc-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-njc-smoke-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-njc-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-njc-smoke-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.terminal_done" "1")
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
