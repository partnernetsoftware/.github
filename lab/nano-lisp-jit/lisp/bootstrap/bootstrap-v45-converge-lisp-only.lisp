; Wave35 W1: 收敛迁入 plan — lisp-only 四轨子集（无 .sh 步骤）.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-regenesis-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-chain-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-com-only.json"))
