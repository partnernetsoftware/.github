; Negative source AOT smoke: recursive local call has no finite return kind.
(module
  (func loop
    (call loop))
  (main
    (call loop)
    (expect 0)))
