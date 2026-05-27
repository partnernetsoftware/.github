; terminal BFS · AOT — build-slice-lisp aarch64.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/terminal-bfs-add7.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs-add7.elf"))
