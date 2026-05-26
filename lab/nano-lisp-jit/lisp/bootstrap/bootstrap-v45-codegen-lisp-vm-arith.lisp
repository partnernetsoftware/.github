; Wave26 W1: VM emit arith（runner codegen 探针扩面）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cg26-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg26-arith.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
