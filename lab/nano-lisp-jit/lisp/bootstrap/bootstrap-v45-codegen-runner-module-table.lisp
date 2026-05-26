; Wave34 W1: runner 模块表 + ir-table v1 链（广面探针）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-mod-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-mod-arith.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/02-compile.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp"))
