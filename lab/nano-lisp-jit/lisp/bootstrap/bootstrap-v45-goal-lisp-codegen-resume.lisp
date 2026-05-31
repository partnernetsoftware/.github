; Wave92: goal-lisp-codegen-resume — 签收 semantic 探针 · 声明零新增 C 波次
(bootstrap
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io_release" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_codegen_probe" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.lisp_codegen_resume" "1"))
