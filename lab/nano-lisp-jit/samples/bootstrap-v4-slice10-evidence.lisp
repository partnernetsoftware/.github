; v4 slice-10 evidence: manifest IR surface + add15 + slice-9 anchor.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-15.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice10-add15.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice10-add15.elf")
  (file-hash "lab/nano-lisp-jit/samples/v4-aarch64-add-exit-ops.manifest")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice9-add14.elf"))
