; v4 slice-12: add17 + plan-lisp ir_source smoke.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-17.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice12-add17.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice12-add17.elf"))
