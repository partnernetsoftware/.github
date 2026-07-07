; Wave93: semantic-rich TU main — multi-func chain · exit 42.
(module
  (func stage_a
    (u64 20)
    (add-u64 1))
  (func stage_b
    (call stage_a)
    (add-u64 10))
  (main
    (call stage_b)
    (add-u64 11)
    (expect 42)))
