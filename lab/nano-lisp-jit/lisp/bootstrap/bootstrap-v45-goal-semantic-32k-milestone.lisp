; Wave95: goal-semantic-32k — semantic 32K 轨签收 · 8K/ bulk 双轨保留
(bootstrap
  (read-file "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-32k.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-32k-pure.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-8k-pure.elf")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_8k_milestone" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_32k_milestone" "1"))
