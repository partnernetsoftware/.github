; B′ chain probe: regenesis.com → extract x86 → repack with fresh aarch64 lisp slice.
(bootstrap
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-probe.lisp")
  (extract-ape-slice "lab/nano-lisp-jit/.build/v45-full-regenesis.com"
                     "lab/nano-lisp-jit/.build/v45-full-regenesis-chain-x86.elf"
                     "x86_64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-full-regenesis-chain-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-full-regenesis-chain.com"
            "lab/nano-lisp-jit/.build/v45-full-regenesis-chain-x86.elf"
            "lab/nano-lisp-jit/.build/v45-full-regenesis-chain-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-full-regenesis-chain.com")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/v45-full-regenesis-chain.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp")
  (file-size "lab/nano-lisp-jit/.build/v45-full-regenesis-chain.com"))
