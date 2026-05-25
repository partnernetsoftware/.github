; v4.5 fine concurrent · track A1: i64 domain (plan 无 .sh).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/boundary/add-i64-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-i64-add.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-i64-add.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-i64-ops.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-i64-cmp.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-i64-cmp.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/i64-mul-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-i64-mul.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-i64-mul.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-le-ge.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-i64-le-ge.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-i64-le-ge.lbin"))
