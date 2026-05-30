; Wave37 W1: plan 面 squad 编排 — dispatch/assess，零 plan 内 .sh 步骤.
(bootstrap
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-default-all.lisp")
  (file-size "lab/nano-lisp-jit/v4.5/DIFFUSE-WAVE36.md")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.plan_all" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.plan_converge_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-sh.json"))
