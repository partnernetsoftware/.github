; Minimal bootstrap descriptor: let nano-listp drive a tiny compile/hash/run chain.
(bootstrap
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-listp/.build/bootstrap-smoke.lbin" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (run "lab/nano-listp/.build/bootstrap-smoke.lbin"))
