; Minimal bootstrap plan for APE v2 pack/inspect smoke under .build/.
; Same flow as bootstrap-ape-smoke.lisp for now (v1 pack-ape / inspect-ape DSL).
; After v2 implementation: pack-ape must emit a binary header (magic, payload table,
; arch/os fields) per ROADMAP v2 slice 1; inspect-ape must validate that header
; instead of (or in addition to) the v1 shell-stub + comment manifest layout.

(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-x86.elf" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com" 42))
