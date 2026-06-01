; Wave98: goal-semantic-full-15slot — 15 槽真语义签收 · hash 分化 bulk
(bootstrap
  (read-file "lab/nano-lisp-jit/lisp/modules-semantic/sem-main.lisp")
  (read-file "lab/nano-lisp-jit/lisp/modules-semantic/sem-vm.lisp")
  (read-file "lab/nano-lisp-jit/lisp/modules-semantic/sem-mf.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_154k_milestone" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.semantic_15slot_real_modules" "1"))
