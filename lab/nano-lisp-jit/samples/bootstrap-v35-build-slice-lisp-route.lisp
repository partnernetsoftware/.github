; v3.5 Lisp-only: (build-slice "*.lisp" …) auto-routes to build-slice-lisp (no .c).
(bootstrap
  (build-slice "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
               "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-route.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-route.elf" 42))
