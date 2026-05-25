; wave168 track-A: onion-codegen-a.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-163.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice168-add163.elf"
                    "aarch64")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (results-min "lab/nano-lisp-jit/.build/results.txt" "tests.pass" "270")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice168-add163.elf"))
