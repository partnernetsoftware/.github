; v4.5 wave6: w3-lisp-only.com 是 slice 探针（exit 42），非完整 bootstrap runner.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com" 42)
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave3-lisp-only-regenesis.lisp")
  (file-hash "lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"))
