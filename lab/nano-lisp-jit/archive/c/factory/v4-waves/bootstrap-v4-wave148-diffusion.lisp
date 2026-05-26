; wave148 track-A: onion-milestone.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-143.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice148-add143.elf"
                    "aarch64")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (results-min "lab/nano-lisp-jit/.build/results.txt" "tests.pass" "270")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice148-add143.elf"))
