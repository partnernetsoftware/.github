; v4.5 codegen 探针卷：lisp slice 四轨 + 发行面 continue（非全量 C 替代）.
(bootstrap
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.release.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lisp_runner_probe" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lisp_slices" "3")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.codegen_probe.100" "1")
  (file-hash "lab/nano-lisp-jit/.build/v45-entry.evidence"))
