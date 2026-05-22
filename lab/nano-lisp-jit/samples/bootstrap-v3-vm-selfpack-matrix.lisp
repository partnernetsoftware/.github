; v3 self-packed matrix: VM func-call + param i64 + arity negatives (exit 2).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/func-call-vm-smoke.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v3-func-call-vm.lbin")
  (compile "lab/nano-lisp-jit/samples/func-param-vm-i64.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v3-func-param-vm-i64.lbin")
  (compile-expect-exit 2 compile "lab/nano-lisp-jit/samples/func-param-missing-param-bad.lisp"
    "lab/nano-lisp-jit/.build/bootstrap-v3-func-param-missing-param-bad.lbin")
  (compile-expect-exit 2 compile "lab/nano-lisp-jit/samples/func-param-call-no-arg-bad.lisp"
    "lab/nano-lisp-jit/.build/bootstrap-v3-func-param-call-no-arg-bad.lbin")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-func-call-vm.lbin"))
