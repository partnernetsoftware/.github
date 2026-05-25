; wave14 track-C: VM emit — control-flow.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-w14-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w14-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w14-ctrl-exit.elf" 11)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w14-ctrl-exit.elf" 11))
