; Minimal bootstrap descriptor: let nano-lisp-jit drive a tiny compile/hash/run chain.
(bootstrap
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-lisp-jit/samples/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin" "lab/nano-lisp-jit/.build/bootstrap-smoke-repeat.lbin")
  (pack-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com" "lab/nano-lisp-jit/.build/nano-lisp-jit" "lab/nano-lisp-jit/.build/nano-lisp-jit" "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com")
  (run-app "lab/nano-lisp-jit/.build/bootstrap-smoke.com")
  (run "lab/nano-lisp-jit/.build/bootstrap-smoke.lbin"))
