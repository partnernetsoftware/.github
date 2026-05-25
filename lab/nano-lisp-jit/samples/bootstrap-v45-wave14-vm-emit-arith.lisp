; wave14 track-A: VM emit — arithmetic.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-w14-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w14-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w14-arith-exit.elf" 3)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w14-arith-exit.elf" 3))
