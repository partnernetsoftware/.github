; Wave34 W2: runner emit 宽表（v2-broad 全链）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-broad-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-broad-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-rc-broad-exit.elf" 11)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rc-broad-exit.elf" 11)
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp"))
