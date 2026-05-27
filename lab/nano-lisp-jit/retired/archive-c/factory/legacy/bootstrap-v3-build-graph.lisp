; v3 slice4: Lisp-orchestrated stage0 build graph (build-slice x2 + hash evidence).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/bootstrap-v3-graph-x86.elf" "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/bootstrap-v3-graph-aarch64.elf" "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-graph-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-graph-aarch64.elf"))
