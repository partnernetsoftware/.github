; Wave34 W3: ir-facade 发行面复核 + VM emit 短链.
(bootstrap
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_c" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.tier5.ir_facade_zero_real" "1")
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/samples/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-facade-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-facade-strlen.lbin"))
