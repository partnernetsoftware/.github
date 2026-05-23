; v4 slice-11 evidence: manifest encode + add16 + slice-10 anchor.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-16.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice11-add16.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice11-add16.elf")
  (file-hash "lab/nano-lisp-jit/samples/v4-aarch64-add-exit-ops.manifest")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice10-add15.elf"))
