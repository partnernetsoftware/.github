; S15: table-only encode log + add18.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-18.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice15-add18.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice15-add18.elf"))
