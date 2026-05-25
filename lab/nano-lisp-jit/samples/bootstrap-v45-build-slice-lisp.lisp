; v4.5 selfhost: runner slice from *.lisp only (build-slice-lisp, no lispjit.c in plan).
(bootstrap
  (build-slice "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
               "lab/nano-lisp-jit/.build/v45-selfhost-lisp-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-selfhost-lisp-slice-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-selfhost-lisp-slice-x86.elf"))
