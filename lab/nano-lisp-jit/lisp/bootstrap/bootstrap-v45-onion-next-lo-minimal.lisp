; Wave26 W3: next-lisp-only.com 是 slice 探针（exit 42），非完整 onion runner.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-next-lisp-only.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-next-lisp-only.com" 42)
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-next-lisp-only.com"))
