; v3.5 Lisp-only line: slice matrix with zero .c inputs (build-slice-lisp only).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-min.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-min.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-add.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-add.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-add.elf"))
