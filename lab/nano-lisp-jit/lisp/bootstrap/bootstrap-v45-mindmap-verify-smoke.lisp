; mindmap W1: 洋葱圈1 VM — smoke 矩阵（与 verify-smoke 同族）.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-mindmap-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-mindmap-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-mindmap-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-mindmap-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mindmap-smoke-exit.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-mindmap-smoke-exit.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.scoped.100" "1"))
