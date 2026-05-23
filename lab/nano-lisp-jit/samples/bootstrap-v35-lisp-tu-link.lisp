; v3.5 L4 kickoff: two .lisp TU sources → compile-elf64-obj-code → link-elf64-exe (exit 42).
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/samples/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/samples/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-main.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-main.o"
                  "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-callee.o")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked" 42))
