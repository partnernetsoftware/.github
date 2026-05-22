; VM .lbin parity for func-param-i64 semantics (41+1=42), single main only.
; User func + (param i64) + call on VM path deferred to v3; AOT: func-param-i64.lisp.
(module
  (main
    (i64 41)
    (add-i64 1)
    (expect 42)))
