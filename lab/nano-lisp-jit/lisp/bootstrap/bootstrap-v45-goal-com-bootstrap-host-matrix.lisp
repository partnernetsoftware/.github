; Wave79 W3: bootstrap-host 矩阵 — 不用 run-ape exit42 验 release slice.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-core.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-all.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cis79-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cis79-smoke-strlen.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cis79-stub-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cis79-stub-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.com_bootstrap_host_matrix" "1"))
