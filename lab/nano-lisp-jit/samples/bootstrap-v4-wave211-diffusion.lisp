; wave211 track-A: cli-irtable-211.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-206.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice211-add206.elf"
                    "aarch64")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (results-min "lab/nano-lisp-jit/.build/results.txt" "tests.pass" "270")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice211-add206.elf"))
