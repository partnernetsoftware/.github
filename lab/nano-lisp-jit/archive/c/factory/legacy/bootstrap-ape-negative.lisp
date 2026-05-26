(bootstrap
  (inspect-expect-exit 2 inspect-ape "lab/nano-lisp-jit/.build/ape-no-manifest.com")
  (inspect-expect-exit 3 inspect-ape "lab/nano-lisp-jit/.build/ape-bad-container.com")
  (inspect-expect-exit 4 inspect-ape "lab/nano-lisp-jit/.build/ape-bad-offset.com")
  (inspect-expect-exit 5 inspect-ape "lab/nano-lisp-jit/.build/ape-bad-hash.com"))
