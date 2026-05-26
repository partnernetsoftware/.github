; ABI import signature smoke: compile libc imports with all sig strings, dump sig names, resolve, run.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin")
  (dump "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin")
  (hash "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/libc-smoke.lisp" "lab/nano-lisp-jit/.build/bootstrap-abi-smoke-repeat.lbin")
  (compare "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin" "lab/nano-lisp-jit/.build/bootstrap-abi-smoke-repeat.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-abi-smoke.lbin"))
