; v3.5 slice 6: daily lispjit.c build-slice must use genesis-pin (zero host cc).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-aarch64.elf"
               "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-aarch64.elf"))
