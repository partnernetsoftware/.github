; mindmap W3: codegen ir-exit（ir-table-lisp + build-slice-lisp）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v2-broad.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-mindmap-ir-exit.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/v45-mindmap-ir-exit.elf"))
