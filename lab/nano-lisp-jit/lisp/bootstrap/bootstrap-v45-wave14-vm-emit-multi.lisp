; wave14 track-D: VM emit — multi-func.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
           "lab/nano-lisp-jit/.build/v45-w14-multi.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w14-multi.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/core/multi-func.lisp"))
