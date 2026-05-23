; v4 slice-13: add18 + lisp encode smoke.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-18.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice13-add18.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice13-add18.elf"))
