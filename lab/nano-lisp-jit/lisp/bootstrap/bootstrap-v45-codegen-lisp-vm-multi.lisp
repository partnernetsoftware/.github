; Wave27 W2: VM emit multi-func（runner codegen 探针）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
           "lab/nano-lisp-jit/.build/v45-cg27-multi.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg27-multi.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/core/multi-func.lisp"))
