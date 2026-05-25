; v4.5 fine concurrent · track A2: ptr domain (plan 无 .sh).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/boundary/ptr-null-arith.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-ptr-null.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-ptr-null.lbin")
  (file-hash "lab/nano-lisp-jit/samples/boundary/ptr-null-arith.lisp"))
