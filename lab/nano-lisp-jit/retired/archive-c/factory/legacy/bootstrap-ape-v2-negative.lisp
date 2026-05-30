(bootstrap
  (inspect-expect-exit 2 inspect-ape "lab/nano-lisp-jit/.build/ape-v2-no-manifest.com")
  (inspect-expect-exit 3 inspect-ape "lab/nano-lisp-jit/.build/ape-v2-bad-container.com")
  (inspect-expect-exit 4 inspect-ape "lab/nano-lisp-jit/.build/ape-v2-bad-offset.com")
  (inspect-expect-exit 5 inspect-ape "lab/nano-lisp-jit/.build/ape-v2-bad-hash.com"))
