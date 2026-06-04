; shell-readline-smoke — VM read-line via nano import (Phase 5 fgets path).
(module
  (import read-line "nano" "read-line" "i32(ptr,i32)")
  (const buf "                                                                                                                                ")
  (main
    (resolve read-line)
    (call read-line buf 128)
    (expect 1)))
