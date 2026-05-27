; terminal BFS · LDR — universal loader / payload load (ape-v2).
(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/terminal-bfs.com"
            "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf"
            "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/terminal-bfs.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/terminal-bfs.com" 42))
