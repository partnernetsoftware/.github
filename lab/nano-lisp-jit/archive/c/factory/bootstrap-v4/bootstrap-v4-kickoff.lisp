; v4 kickoff: regression anchor + plan marker (zero .c).
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/results.txt")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp-jit")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v4-kickoff-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-v4-kickoff-arithmetic.lbin"))
