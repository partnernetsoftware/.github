; v4 slice-0 kickoff: aarch64 add via x86 compile path smoke (plan marker; implementation follows).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf"))
