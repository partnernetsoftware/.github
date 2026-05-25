; v4.5 wave4: squad via bootstrap only — dispatch smoke + assess catalog smoke (no .sh in plan).
(bootstrap
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/scripts/v45-wave4-converge.sh"))
