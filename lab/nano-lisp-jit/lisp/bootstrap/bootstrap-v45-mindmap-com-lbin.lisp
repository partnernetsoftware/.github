; mindmap W2: com-lbin-in-ape（v4 DP 节点 v45 化）.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-mindmap-com-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mindmap-com-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mindmap-com-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/v45-mindmap-com-app.com"
            "lab/nano-lisp-jit/.build/v45-mindmap-com-x86.elf"
            "lab/nano-lisp-jit/.build/v45-mindmap-com-arm.elf"
            "lab/nano-lisp-jit/.build/v45-mindmap-com-arithmetic.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/v45-mindmap-com-app.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-mindmap-com-app.com"))
