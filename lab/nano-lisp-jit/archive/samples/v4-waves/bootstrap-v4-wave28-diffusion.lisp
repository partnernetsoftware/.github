; wave28 diffusion: table + words cross-contract + emit + assess + build gate.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-words-v2.txt")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-23.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice28-add23.elf"
                    "aarch64")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice28-add23.elf"))
