; v4.5 wave5: scoped CI — tests.pass 仅 terminal + converge（非全量 run.sh）.
(bootstrap
  (file-size "lab/nano-lisp-jit/scripts/v45-scoped-ci.sh")
  (file-size "lab/nano-lisp-jit/scripts/v45-wave5-converge.sh")
  (results-min "lab/nano-lisp-jit/.build/v45-scoped-results.txt" "tests.pass" "2")
  (results-min "lab/nano-lisp-jit/.build/v45-scoped-results.txt" "v45.scoped.ci" "1")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp"))
