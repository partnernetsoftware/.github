; v4.5 wave14: IR 表 v2（与 v1 同基线；扩面矩阵挂多 plan）.
(ir-table add-exit-v2-broad
  (op movz_x0_base 0xd2800000)
  (op movz_x1_base 0xd2800001)
  (op add_x0_x1 0x8b010000)
  (op movz_x8 0xd2800ba8)
  (op svc0 0xd4000001)
  (op ret 0xd65f03c0))
