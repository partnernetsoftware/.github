; wave14 track-B: VM emit — strlen.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-w14-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-w14-strlen.lbin")
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp"))
