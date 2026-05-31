; Wave92: semantic-codegen honest audit — semantic vs bulk 探针 · read-file 制品 · 零 host cc
(bootstrap
  (read-file "lab/nano-lisp-jit/v4.5/REFLECTION.md")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-pure.elf")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf")
  (compare "lab/nano-lisp-jit/.build/v45-c15-semantic-pure.elf"
           "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf")
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io_release" "1"))
