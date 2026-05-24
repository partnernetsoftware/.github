; S11 codegen: IR table v2 + add16 ELF (plan 无 .c)。
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-16.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice11-add16.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice11-add16.elf"))
