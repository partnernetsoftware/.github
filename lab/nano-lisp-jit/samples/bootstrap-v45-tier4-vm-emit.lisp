; v4.5 tier4: VM/AOT IR 表由 Lisp 描述（ir-table-lisp，plan 无 .c 步骤）.
(bootstrap
  (file-size "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-tier4-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-tier4-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-tier4-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-tier4-exit42.elf" 42)
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp"))
