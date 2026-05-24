; S18 codegen: load plan IR table then emit add21 (svc0 from Lisp table).
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-21.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice18-add21.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice18-add21.elf"))
