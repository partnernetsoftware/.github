; Boundary: bool + not-bool.
(module
  (main
    (bool true)
    (not-bool)
    (expect false)
    (bool false)
    (not-bool)
    (expect true)))
