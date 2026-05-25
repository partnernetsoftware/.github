; Wave26 W2: VM emit strlen（runner codegen 探针扩面）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/samples/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cg26-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg26-strlen.lbin")
  (file-hash "lab/nano-lisp-jit/samples/strlen.lisp"))
