; v4 slice-8: add13 via table-driven add-exit-v1 lowering.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-13.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice8-add13.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice8-add13.elf"))
