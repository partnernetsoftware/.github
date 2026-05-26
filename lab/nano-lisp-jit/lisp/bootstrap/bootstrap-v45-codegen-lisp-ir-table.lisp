; Wave25 W3: ir-table-lisp + VM emit 链（runner codegen 探针）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cg-lo-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cg-lo-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cg-lo-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cg-lo-exit42.elf" 42)
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp"))
