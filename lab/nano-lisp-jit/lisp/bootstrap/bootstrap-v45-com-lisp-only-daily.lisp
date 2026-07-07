; com-lisp-only daily — user path: release/nano-lisp.com + *.lisp plans only.
; Factory (.sh / cosmocc / host-cc) is out of scope for this plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-com-lisp-only-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-com-lisp-only-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-com-lisp-only-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-com-lisp-only-arith.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp"))
