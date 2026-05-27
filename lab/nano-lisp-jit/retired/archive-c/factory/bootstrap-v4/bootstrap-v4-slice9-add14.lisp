; v4 slice-9: add14 + lowering.ops=5 smoke.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-14.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice9-add14.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice9-add14.elf"))
