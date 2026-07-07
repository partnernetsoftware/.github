; Wave89: goal-proc-smoke — dogfooding 子进程/I/O · 保持 strict_done 证据
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w89-goal-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w89-goal-exit42.elf" 42)
  (run-expect-exit "/bin/true" 0)
  (file-hash "lab/nano-lisp-jit/release/manifest.txt")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.nano_jit_com.strict_done" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_smoke" "1"))
