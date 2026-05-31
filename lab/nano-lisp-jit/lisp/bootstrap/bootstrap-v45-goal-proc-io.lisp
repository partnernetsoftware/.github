; Wave90: goal-proc-io — 新原语 + proc_smoke 门禁
(bootstrap
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_smoke" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io" "1"))
