; v4 slice-1: aarch64 add-emit with parsed operands 3+4 (not hardcoded 40+2).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"))
