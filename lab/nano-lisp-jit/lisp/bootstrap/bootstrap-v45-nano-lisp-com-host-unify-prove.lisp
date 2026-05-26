; Wave62 W1: nano-lisp.com host 统一证明 — 产品 + bootstrap 宿主均在 nano-lisp/ 树.
; Prefix v45-nlchup- · no .sh/.py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-nlchup-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-nlchup-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-nlchup-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-nlchup-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.bootstrap_sprint" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com"))
