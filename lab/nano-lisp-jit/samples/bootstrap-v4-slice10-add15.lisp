; v4 slice-10: add15 + manifest-v1 ir surface smoke.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-15.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice10-add15.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice10-add15.elf"))
