; wave27 diffusion: ir-table full + emit + assess + build gate (one plan graph).
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-22.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice27-add22.elf"
                    "aarch64")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice27-add22.elf"))
