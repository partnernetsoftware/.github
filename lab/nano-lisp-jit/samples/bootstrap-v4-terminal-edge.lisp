; Terminal edge milestone: pack-ape + JIT .lbin run + pack-app + nano-jit.com (one plan).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/terminal-edge-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-edge-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-edge-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/terminal-edge.com"
            "lab/nano-lisp-jit/.build/terminal-edge-x86.elf"
            "lab/nano-lisp-jit/.build/terminal-edge-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/terminal-edge.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/terminal-edge.com" 42)
  (run "lab/nano-lisp-jit/.build/terminal-edge-arithmetic.lbin")
  (pack-app "lab/nano-lisp-jit/.build/terminal-edge-app.com"
            "lab/nano-lisp-jit/.build/terminal-edge-x86.elf"
            "lab/nano-lisp-jit/.build/terminal-edge-arm.elf"
            "lab/nano-lisp-jit/.build/terminal-edge-arithmetic.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/terminal-edge-app.com")
  (file-hash "lab/nano-lisp-jit/.build/terminal-edge-app.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v3-selfhost-gen1.lisp"))
