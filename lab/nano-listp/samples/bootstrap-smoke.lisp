; Minimal bootstrap descriptor: let nano-listp drive a tiny compile/hash/run chain.
(bootstrap
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (run "lab/nano-listp/.build/bootstrap-smoke.lbin"))
