; v3.5 aarch64-codegen: build-slice-lisp add profile (exit-emit scoped; qemu smoke).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-aarch64-add.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-aarch64-add.elf"))
