; Probe: helper returns bool, main treats as u64 add
(module
  (func flag
    (bool true))
  (main
    (call flag)
    (add-u64 1)
    (expect 2)))
