; Wave27 W1: VM emit control-flow（runner codegen 探针）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-cg27-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg27-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cg27-ctrl-exit.elf" 11)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cg27-ctrl-exit.elf" 11))
