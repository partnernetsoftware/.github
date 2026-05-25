; v4.5 wave11 track-D (T5d): VM emit 矩阵 — tier4 扩面 smoke.
(bootstrap
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-tier4-vm-emit.lisp")
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/samples/arithmetic-i64.lisp"
           "lab/nano-lisp-jit/.build/v45-wave11-arith-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-wave11-arith-i64.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-wave11-exit7.elf" 7)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-wave11-exit7.elf" 7)
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp"))
