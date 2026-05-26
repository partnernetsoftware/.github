; v4.5 tier2: daily lispjit.c build-slice via genesis-pin (zero host cc).
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-genesis-shrink-x86.elf"
               "x86_64")
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-genesis-shrink-aarch64.elf"
               "aarch64")
  (compare "lab/nano-lisp-jit/.build/v45-genesis-shrink-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/v45-genesis-shrink-x86.elf")
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64"))
