; Wave93: semantic vs bulk 分化审计 — compare 应失败（ELF 不同）· 零 bulk-expand
(bootstrap
  (read-file "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-pure.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.lisp_codegen_resume" "1"))
