; Mindmap DP codegen-ir-emit: ir-table-lisp + non-add exit emit profile.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/mindmap-ir-exit-v1.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/mindmap-ir-exit-v1.elf"))
