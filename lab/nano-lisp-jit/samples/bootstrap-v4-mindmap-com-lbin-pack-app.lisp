; Mindmap DP com-lbin-in-ape: JIT .lbin + pack-app multi-arch .com (app-v1 blob payload).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/mindmap-com-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/mindmap-com-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/mindmap-com-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/mindmap-com-app.com"
            "lab/nano-lisp-jit/.build/mindmap-com-x86.elf"
            "lab/nano-lisp-jit/.build/mindmap-com-arm.elf"
            "lab/nano-lisp-jit/.build/mindmap-com-arithmetic.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/mindmap-com-app.com")
  (file-hash "lab/nano-lisp-jit/.build/mindmap-com-app.com"))
