; Wave74 W3: regenesis release 矩阵 — tier0 smoke on promoted COM.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-rp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-rp-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rp-smoke-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-rp-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rp-smoke-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.nano_jit_com.regenesis_slice_154kb" "1")
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
