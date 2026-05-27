; v4 slice-7: aarch64 add11 + emit profile marker (zero .c in plan body).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-11.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice7-add11.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v4-slice7-add11.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice7-add11.elf"))
