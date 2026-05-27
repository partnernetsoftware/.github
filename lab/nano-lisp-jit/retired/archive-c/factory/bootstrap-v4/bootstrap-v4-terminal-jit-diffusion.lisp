; terminal BFS · JIT — .lisp -> .lbin.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin")
  (file-size "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin"))
