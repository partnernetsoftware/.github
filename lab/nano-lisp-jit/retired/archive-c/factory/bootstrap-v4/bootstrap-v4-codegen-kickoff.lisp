; S6: codegen kickoff — inventory emit path + add7 regression (zero .c in plan).
(bootstrap
  (file-hash "lab/lispjit-ir/nano_elf64.c")
  (file-size "lab/lispjit-ir/nano_bootstrap.c")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"))
