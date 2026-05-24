; v3 slice 4b: build slice ELF from .lisp via nano-jit (no host cc).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v3-slice-lisp-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v3-slice-lisp-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-slice-lisp-x86.elf"))
