; v3 slice4: bootstrap build-slice (stage0 bridge — host/cross cc, not Lisp codegen yet).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/bootstrap-v3-slice-x86.elf" "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/bootstrap-v3-slice-aarch64.elf" "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-slice-aarch64.elf"))
