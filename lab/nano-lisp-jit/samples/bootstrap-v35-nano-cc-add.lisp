; v3.5 slice 2: nano-cc add sample via companion .lisp + compile-elf64-exe (zero host cc).
(bootstrap
  (nano-cc-compile "lab/nano-lisp-jit/samples/nano-cc-add.c"
                   "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-add.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-add.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-add.elf"))
