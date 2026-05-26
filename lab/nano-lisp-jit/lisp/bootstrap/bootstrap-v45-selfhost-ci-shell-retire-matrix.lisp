; Wave60 W4: selfhost × ci-shell-retire 矩阵.
; Prefix v45-scsr- · no build-slice lispjit.c · no .sh · no .py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/scripts/v45-wave59-tools-py-retire-converge.sh")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-scsr-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-scsr-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-scsr-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-scsr-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.tools_py_retire_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.ci.shell_plan_only_replacement" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical-zero-cpysh.lisp"))
