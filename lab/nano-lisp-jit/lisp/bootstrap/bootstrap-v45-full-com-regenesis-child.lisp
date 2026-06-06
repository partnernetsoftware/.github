; B′ regenesis child — minimal strlen compile+run (repo tree paths only).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-regenesis-child-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-regenesis-child-strlen.lbin"))
