; S17 codegen: host reads v4-ir-words-v1.txt and logs verified=plan-words-v1.
(bootstrap
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-words-v1.txt")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-20.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice17-add20.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice17-add20.elf"))
