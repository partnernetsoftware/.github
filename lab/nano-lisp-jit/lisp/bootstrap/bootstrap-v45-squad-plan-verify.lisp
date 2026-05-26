; Wave40 W3: squad plan-only verify path — dispatch/assess + evidence gates (no .sh in plan).
(bootstrap
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-plan.lisp")
  (file-size "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.squad_plan" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.verify.matrix_plan" "1")
  (file-hash "lab/nano-lisp-jit/squad/catalog-v45.yaml"))
