; S18 orchestration: real squad-assess + build.pass from plan (减 run.sh 面).
(bootstrap
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")
  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")
  (file-size "lab/nano-lisp-jit/v4/MINDMAP.md"))
