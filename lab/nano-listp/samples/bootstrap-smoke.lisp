; Minimal bootstrap descriptor: let nano-listp drive a tiny compile/hash/run chain.
(bootstrap
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (resolve-quiet "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (hash "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (compile "lab/nano-listp/samples/libc-smoke.lisp" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (compare "lab/nano-listp/.build/bootstrap-smoke.lbin" "lab/nano-listp/.build/bootstrap-smoke-repeat.lbin")
  (pack-app "lab/nano-listp/.build/bootstrap-smoke.com" "lab/nano-listp/.build/nano-listp" "lab/nano-listp/.build/nano-listp" "lab/nano-listp/.build/bootstrap-smoke.lbin")
  (inspect-app "lab/nano-listp/.build/bootstrap-smoke.com")
  (run "lab/nano-listp/.build/bootstrap-smoke.lbin"))
