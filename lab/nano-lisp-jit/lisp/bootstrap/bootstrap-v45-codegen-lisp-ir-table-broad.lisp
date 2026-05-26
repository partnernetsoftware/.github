; Wave28 W2: ir-table v2-broad 全链 emit（runner codegen 探针）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-cg28-broad-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg28-broad-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cg28-broad-exit.elf" 11)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cg28-broad-exit.elf" 11)
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
