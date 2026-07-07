; Wave96: goal-semantic-64k — semantic 64K 轨签收 · 8K/32K/bulk 多轨保留
(bootstrap
  (read-file "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-64k.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-64k-pure.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-32k-pure.elf")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_32k_milestone" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_64k_milestone" "1"))
