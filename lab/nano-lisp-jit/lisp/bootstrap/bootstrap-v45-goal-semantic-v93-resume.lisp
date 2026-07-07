; Wave93: goal-semantic-v93 — semantic 真路径签收 · bulk 体积路径保留
(bootstrap
  (spawn-wait 0 "/bin/true")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_bulk_diverge" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io_release" "1"))
