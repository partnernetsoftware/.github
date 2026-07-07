; Wave91: goal-proc-io-release-promote — release COM 携带 read-file/spawn-wait
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 7 "/bin/sh" "-c" "exit 7")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_smoke" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.nano_jit_com.strict_done" "1"))
