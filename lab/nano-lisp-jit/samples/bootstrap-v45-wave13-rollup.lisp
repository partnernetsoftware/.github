; wave13 rollup — ir 门面零真 .c；warehouse 仍非 physical 100%.
(bootstrap
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.wave13.parallel" "4")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.tier5.ir_facade_zero_real" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.lispjit_ir_c_files" "0")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_c" "0")
  (file-hash "lab/nano-lisp-jit/.build/v45-entry.evidence"))
