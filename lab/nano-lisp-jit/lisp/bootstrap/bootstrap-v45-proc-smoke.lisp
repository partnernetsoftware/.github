; Wave89 W1: proc-smoke — plan 级 fork/exec/wait（run-expect-exit）+ 制品 file-size/hash 探测
(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w89-proc-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w89-proc-exit42.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w89-proc-exit0.elf" 0)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w89-proc-exit0.elf" 0)
  (run-expect-exit "/bin/true" 0)
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-hash "lab/nano-lisp-jit/release/manifest.txt")
  (file-size "lab/nano-lisp-jit/.build/v45-entry.evidence")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-w89-proc-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w89-proc-arith.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
                     "lab/nano-lisp-jit/.build/v45-w89-proc-arith.elf" "nano_w89_arith")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w89-proc-arith.elf" 42))
