/* Included from lispjit.c — blob/AOT x86 codegen and aot-elf64 CLI. */
static int value_to_exit_code(Value v, uint8_t *out) {
  if (v.kind == VAL_U64 || v.kind == VAL_BOOL) {
    *out = (uint8_t)(v.bits & 0xffu);
    return 1;
  }
  if (v.kind == VAL_I64) {
    *out = (uint8_t)((int64_t)v.bits & 0xff);
    return 1;
  }
  return 0;
}

static int value_to_obj_ret_u32(Value v, uint32_t *out) {
  if (v.kind == VAL_BOOL) {
    *out = (uint32_t)v.bits;
    return 1;
  }
  if (v.kind == VAL_U64 && v.bits <= UINT32_MAX) {
    *out = (uint32_t)v.bits;
    return 1;
  }
  if (v.kind == VAL_I64) {
    int64_t signed_v = (int64_t)v.bits;
    if (signed_v < INT32_MIN || signed_v > INT32_MAX) return 0;
    *out = (uint32_t)(int32_t)signed_v;
    return 1;
  }
  return 0;
}

static int eval_pure_blob(const Blob *b, Value *out) {
  Value last = value_u64(0);
  uint32_t pc = 0;
  while (pc < b->instr_count) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 0;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    if (op == OP_CONST_U64) {
      last = value_u64((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      pc++;
    } else if (op == OP_CONST_I64) {
      last = value_i64((int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32)));
      pc++;
    } else if (op == OP_CONST_BOOL) {
      last = value_bool((int)arg0);
      pc++;
    } else if (op == OP_NULL_PTR) {
      last = value_ptr(NULL);
      pc++;
    } else if (op == OP_ADD_PTR) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_ptr(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_SUB_PTR) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_sub_ptr(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_PTR_TO_U64) {
      if (!value_ptr_to_u64(&last)) return 0;
      pc++;
    } else if (op == OP_U64_TO_PTR) {
      if (!value_u64_to_ptr(&last)) return 0;
      pc++;
    } else if (op == OP_CONST_PTR) {
      const char *s = const_string_ref(b, arg0);
      if (!s) return 0;
      last = value_ptr(s);
      pc++;
    } else if (op == OP_LOAD_U8) {
      if (!value_load_u8(&last)) return 0;
      pc++;
    } else if (op == OP_LOAD_U16) {
      if (!value_load_u16(&last)) return 0;
      pc++;
    } else if (op == OP_LOAD_U32) {
      if (!value_load_u32(&last)) return 0;
      pc++;
    } else if (op == OP_STORE_U8) {
      uint64_t byte = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u8(&last, byte)) return 0;
      pc++;
    } else if (op == OP_STORE_U16) {
      uint64_t word = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u16(&last, word)) return 0;
      pc++;
    } else if (op == OP_STORE_U32) {
      uint64_t dword = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u32(&last, dword)) return 0;
      pc++;
    } else if (op == OP_IS_NULL_PTR) {
      if (!value_is_null_ptr(&last)) return 0;
      pc++;
    } else if (op == OP_IS_NONNULL_PTR) {
      if (!value_is_nonnull_ptr(&last)) return 0;
      pc++;
    } else if (op == OP_NOT_BOOL) {
      if (!value_not_bool(&last)) return 0;
      pc++;
    } else if (op == OP_AND_BOOL) {
      if (!value_and_bool(&last, (int)arg0)) return 0;
      pc++;
    } else if (op == OP_OR_BOOL) {
      if (!value_or_bool(&last, (int)arg0)) return 0;
      pc++;
    } else if (op == OP_ADD_U64) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_u64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_ADD_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_add_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_SUB_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_sub_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_MUL_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_mul_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_EQ_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_eq_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_LT_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_lt_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_GT_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_gt_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_NE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_ne_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_LE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_le_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_GE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_ge_i64(&last, rhs)) return 0;
      pc++;
    } else if (op == OP_EXPECT_U64) {
      uint64_t expected = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_expect_u64(last, expected)) return 0;
      pc++;
    } else if (op == OP_EXPECT_I64) {
      int64_t expected = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_expect_i64(last, expected)) return 0;
      pc++;
    } else if (op == OP_EXPECT_BOOL) {
      if (!value_expect_bool(last, (int)arg0)) return 0;
      pc++;
    } else if (op == OP_EXPECT_PTR) {
      if (!value_expect_ptr(last, (int)arg0)) return 0;
      pc++;
    } else if (op == OP_BRANCH_BOOL) {
      if (last.kind != VAL_BOOL || arg0 >= b->instr_count) return 0;
      pc = last.bits ? arg0 : pc + 1;
    } else if (op == OP_RET_LAST) {
      *out = last;
      return 1;
    } else {
      return 0;
    }
  }
  return 0;
}

static int cmd_aot_elf64_exit(const char *blob_path, const char *out_path) {
  Blob b;
  unsigned char *owned = NULL;
  Value result = value_u64(0);
  uint8_t exit_code = 0;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!eval_pure_blob(&b, &result) || !value_to_exit_code(result, &exit_code)) {
    fprintf(stderr, "aot-elf64-exit=unsupported_blob\n");
    free(owned);
    return 2;
  }
  free(owned);
  if (!emit_elf64_exit_file(out_path, exit_code)) {
    fprintf(stderr, "aot-elf64-exit=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.elf64.output=%s\n", out_path);
  printf("aot.elf64.bytes=%d\n", 132);
  printf("aot.elf64.exit=%u\n", (unsigned)exit_code);
  return 0;
}

static int cmd_aot_elf64_obj_ret(const char *blob_path, const char *out_path, const char *symbol) {
  Blob b;
  unsigned char *owned = NULL;
  Value result = value_u64(0);
  uint32_t ret_value = 0;
  if (!symbol[0]) {
    fprintf(stderr, "aot-elf64-obj-ret=bad_symbol\n");
    return 1;
  }
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!eval_pure_blob(&b, &result) || !value_to_obj_ret_u32(result, &ret_value)) {
    fprintf(stderr, "aot-elf64-obj-ret=unsupported_blob\n");
    free(owned);
    return 2;
  }
  free(owned);
  if (!emit_elf64_obj_ret_file(out_path, symbol, ret_value)) {
    fprintf(stderr, "aot-elf64-obj-ret=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.obj.output=%s\n", out_path);
  printf("aot.obj.symbol=%s\n", symbol);
  printf("aot.obj.ret=%u\n", ret_value);
  return 0;
}

typedef struct {
  uint32_t patch_off;
  uint32_t target_pc;
} PcPatch;

typedef struct {
  uint32_t patch_off;
  uint32_t sec_off;
  uint8_t sec; /* 1=.rodata 2=.data */
} DataPatch;

static int blob_has_store_ops(const Blob *b) {
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) continue;
    uint8_t op = ins[0];
    if (op == OP_STORE_U8 || op == OP_STORE_U16 || op == OP_STORE_U32) return 1;
  }
  return 0;
}

static int compile_pure_blob_to_x86(const Blob *b, Buf *code, int exit_style, Buf *rodata,
                                    Buf *data_sec, Buf *data_relas) {
  int saw_ret = 0;
  int last_kind = 0;
  Buf expect_patches = {0};
  Buf branch_patches = {0};
  Buf data_patches = {0};
  uint32_t *const_sec_off = NULL;
  uint32_t *pc_offs = (uint32_t *)calloc(b->instr_count ? b->instr_count : 1, sizeof(*pc_offs));
  if (!pc_offs) return 0;
  if (b->const_count) {
    const_sec_off = (uint32_t *)malloc(b->const_count * sizeof(*const_sec_off));
    if (!const_sec_off) {
      free(pc_offs);
      return 0;
    }
    for (size_t i = 0; i < b->const_count; ++i) const_sec_off[i] = UINT32_MAX;
  }
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    uint8_t op = 0;
    uint32_t arg0 = 0;
    uint32_t arg1 = 0;
    int64_t imm_i64 = 0;
    uint64_t imm_u64 = 0;
    if (!ins) goto fail;
    pc_offs[pc] = (uint32_t)code->len;
    op = ins[0];
    arg0 = rd32(ins + 4);
    arg1 = rd32(ins + 8);
    imm_u64 = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
    imm_i64 = (int64_t)imm_u64;
    if (op == OP_CONST_U64) {
      if (imm_u64 > UINT32_MAX) goto fail;
      if (exit_style) {
        unsigned char mov_edi[5] = {0xbf, 0, 0, 0, 0};
        wr32(mov_edi + 1, (uint32_t)imm_u64);
        buf_put(code, mov_edi, sizeof(mov_edi));
      } else {
        unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
        wr32(mov_eax + 1, (uint32_t)imm_u64);
        buf_put(code, mov_eax, sizeof(mov_eax));
      }
      last_kind = VAL_U64;
    } else if (op == OP_CONST_I64) {
      if (imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char mov_edi[5] = {0xbf, 0, 0, 0, 0};
        wr32(mov_edi + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, mov_edi, sizeof(mov_edi));
      } else {
        unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
        wr32(mov_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, mov_eax, sizeof(mov_eax));
      }
      last_kind = VAL_I64;
    } else if (op == OP_CONST_BOOL) {
      if (exit_style) {
        unsigned char mov_edi[5] = {0xbf, 0, 0, 0, 0};
        wr32(mov_edi + 1, arg0 ? 1u : 0u);
        buf_put(code, mov_edi, sizeof(mov_edi));
      } else {
        unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
        wr32(mov_eax + 1, arg0 ? 1u : 0u);
        buf_put(code, mov_eax, sizeof(mov_eax));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_NULL_PTR) {
      if (exit_style) {
        unsigned char mov_edi[5] = {0xbf, 0, 0, 0, 0};
        buf_put(code, mov_edi, sizeof(mov_edi));
      } else {
        unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
        buf_put(code, mov_eax, sizeof(mov_eax));
      }
      last_kind = VAL_PTR;
    } else if (op == OP_ADD_PTR) {
      if (last_kind != VAL_PTR || imm_u64 > UINT32_MAX) goto fail;
      if (exit_style) {
        unsigned char add_edi[6] = {0x81, 0xc7, 0, 0, 0, 0};
        wr32(add_edi + 2, (uint32_t)imm_u64);
        buf_put(code, add_edi, sizeof(add_edi));
      } else {
        unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
        wr32(add_eax + 1, (uint32_t)imm_u64);
        buf_put(code, add_eax, sizeof(add_eax));
      }
    } else if (op == OP_SUB_PTR) {
      if (last_kind != VAL_PTR || imm_u64 > UINT32_MAX) goto fail;
      if (exit_style) {
        unsigned char sub_edi[6] = {0x81, 0xef, 0, 0, 0, 0};
        wr32(sub_edi + 2, (uint32_t)imm_u64);
        buf_put(code, sub_edi, sizeof(sub_edi));
      } else {
        unsigned char sub_eax[5] = {0x2d, 0, 0, 0, 0};
        wr32(sub_eax + 1, (uint32_t)imm_u64);
        buf_put(code, sub_eax, sizeof(sub_eax));
      }
    } else if (op == OP_PTR_TO_U64) {
      if (last_kind != VAL_PTR) goto fail;
      last_kind = VAL_U64;
    } else if (op == OP_U64_TO_PTR) {
      if (last_kind != VAL_U64) goto fail;
      last_kind = VAL_PTR;
    } else if (op == OP_CONST_PTR) {
      const char *s = (rodata || data_sec) ? const_string_ref(b, arg0) : NULL;
      Buf *sec = NULL;
      uint8_t sec_id = 0;
      if (!s) goto fail;
      if (blob_has_store_ops(b)) {
        sec = data_sec;
        sec_id = 2;
      } else {
        sec = rodata;
        sec_id = 1;
      }
      if (!sec) goto fail;
      if (arg0 >= b->const_count) goto fail;
      {
        unsigned char lea[7] = {0x48, 0x8d, exit_style ? 0x3d : 0x05, 0, 0, 0, 0};
        uint32_t sec_off = const_sec_off[arg0];
        if (sec_off == UINT32_MAX) {
          sec_off = (uint32_t)sec->len;
          const_sec_off[arg0] = sec_off;
          buf_put(sec, s, strlen(s) + 1);
        }
        DataPatch patch = {(uint32_t)(code->len + 3), sec_off, sec_id};
        buf_put(code, lea, sizeof(lea));
        buf_put(&data_patches, &patch, sizeof(patch));
      }
      last_kind = VAL_PTR;
    } else if (op == OP_LOAD_U8) {
      if (last_kind != VAL_PTR) goto fail;
      if (exit_style) {
        unsigned char movzx_edi_ptr_rdi[3] = {0x0f, 0xb6, 0x3f};
        buf_put(code, movzx_edi_ptr_rdi, sizeof(movzx_edi_ptr_rdi));
      } else {
        unsigned char movzx_eax_ptr_rax[3] = {0x0f, 0xb6, 0x00};
        buf_put(code, movzx_eax_ptr_rax, sizeof(movzx_eax_ptr_rax));
      }
      last_kind = VAL_U64;
    } else if (op == OP_LOAD_U16) {
      if (last_kind != VAL_PTR) goto fail;
      if (exit_style) {
        unsigned char movzx_edi_word_ptr_rdi[3] = {0x0f, 0xb7, 0x3f};
        buf_put(code, movzx_edi_word_ptr_rdi, sizeof(movzx_edi_word_ptr_rdi));
      } else {
        unsigned char movzx_eax_word_ptr_rax[3] = {0x0f, 0xb7, 0x00};
        buf_put(code, movzx_eax_word_ptr_rax, sizeof(movzx_eax_word_ptr_rax));
      }
      last_kind = VAL_U64;
    } else if (op == OP_LOAD_U32) {
      if (last_kind != VAL_PTR) goto fail;
      if (exit_style) {
        unsigned char mov_edi_dword_ptr_rdi[2] = {0x8b, 0x3f};
        buf_put(code, mov_edi_dword_ptr_rdi, sizeof(mov_edi_dword_ptr_rdi));
      } else {
        unsigned char mov_eax_dword_ptr_rax[2] = {0x8b, 0x00};
        buf_put(code, mov_eax_dword_ptr_rax, sizeof(mov_eax_dword_ptr_rax));
      }
      last_kind = VAL_U64;
    } else if (op == OP_STORE_U8) {
      if (last_kind != VAL_PTR || imm_u64 > 255u) goto fail;
      if (exit_style) {
        unsigned char mov_byte_ptr_rdi_imm[3] = {0xc6, 0x07, (unsigned char)imm_u64};
        buf_put(code, mov_byte_ptr_rdi_imm, sizeof(mov_byte_ptr_rdi_imm));
      } else {
        unsigned char mov_byte_ptr_rax_imm[3] = {0xc6, 0x00, (unsigned char)imm_u64};
        buf_put(code, mov_byte_ptr_rax_imm, sizeof(mov_byte_ptr_rax_imm));
      }
    } else if (op == OP_STORE_U16) {
      if (last_kind != VAL_PTR || imm_u64 > 65535u) goto fail;
      if (exit_style) {
        unsigned char mov_word_ptr_rdi_imm[5] = {0x66, 0xc7, 0x07, 0, 0};
        wr16(mov_word_ptr_rdi_imm + 3, (uint16_t)imm_u64);
        buf_put(code, mov_word_ptr_rdi_imm, sizeof(mov_word_ptr_rdi_imm));
      } else {
        unsigned char mov_word_ptr_rax_imm[5] = {0x66, 0xc7, 0x00, 0, 0};
        wr16(mov_word_ptr_rax_imm + 3, (uint16_t)imm_u64);
        buf_put(code, mov_word_ptr_rax_imm, sizeof(mov_word_ptr_rax_imm));
      }
    } else if (op == OP_STORE_U32) {
      if (last_kind != VAL_PTR || imm_u64 > UINT32_MAX) goto fail;
      if (exit_style) {
        unsigned char mov_dword_ptr_rdi_imm[6] = {0xc7, 0x07, 0, 0, 0, 0};
        wr32(mov_dword_ptr_rdi_imm + 2, (uint32_t)imm_u64);
        buf_put(code, mov_dword_ptr_rdi_imm, sizeof(mov_dword_ptr_rdi_imm));
      } else {
        unsigned char mov_dword_ptr_rax_imm[6] = {0xc7, 0x00, 0, 0, 0, 0};
        wr32(mov_dword_ptr_rax_imm + 2, (uint32_t)imm_u64);
        buf_put(code, mov_dword_ptr_rax_imm, sizeof(mov_dword_ptr_rax_imm));
      }
    } else if (op == OP_IS_NULL_PTR || op == OP_IS_NONNULL_PTR) {
      if (last_kind != VAL_PTR) goto fail;
      if (exit_style) {
        unsigned char test_edi_edi[2] = {0x85, 0xff};
        unsigned char setcc_al[3] = {0x0f, op == OP_IS_NULL_PTR ? 0x94 : 0x95, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        buf_put(code, test_edi_edi, sizeof(test_edi_edi));
        buf_put(code, setcc_al, sizeof(setcc_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char test_eax_eax[2] = {0x85, 0xc0};
        unsigned char setcc_al[3] = {0x0f, op == OP_IS_NULL_PTR ? 0x94 : 0x95, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        buf_put(code, test_eax_eax, sizeof(test_eax_eax));
        buf_put(code, setcc_al, sizeof(setcc_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_NOT_BOOL) {
      if (last_kind != VAL_BOOL) goto fail;
      if (exit_style) {
        unsigned char xor_edi_1[3] = {0x83, 0xf7, 0x01};
        buf_put(code, xor_edi_1, sizeof(xor_edi_1));
      } else {
        unsigned char xor_eax_1[3] = {0x83, 0xf0, 0x01};
        buf_put(code, xor_eax_1, sizeof(xor_eax_1));
      }
    } else if (op == OP_AND_BOOL) {
      if (last_kind != VAL_BOOL || arg0 > 1u) goto fail;
      if (exit_style) {
        unsigned char and_edi_imm[3] = {0x83, 0xe7, (unsigned char)arg0};
        buf_put(code, and_edi_imm, sizeof(and_edi_imm));
      } else {
        unsigned char and_eax_imm[3] = {0x83, 0xe0, (unsigned char)arg0};
        buf_put(code, and_eax_imm, sizeof(and_eax_imm));
      }
    } else if (op == OP_OR_BOOL) {
      if (last_kind != VAL_BOOL || arg0 > 1u) goto fail;
      if (exit_style) {
        unsigned char or_edi_imm[3] = {0x83, 0xcf, (unsigned char)arg0};
        buf_put(code, or_edi_imm, sizeof(or_edi_imm));
      } else {
        unsigned char or_eax_imm[3] = {0x83, 0xc8, (unsigned char)arg0};
        buf_put(code, or_eax_imm, sizeof(or_eax_imm));
      }
    } else if (op == OP_ADD_U64) {
      if (last_kind != VAL_U64 || imm_u64 > UINT32_MAX) goto fail;
      if (exit_style) {
        unsigned char add_edi[6] = {0x81, 0xc7, 0, 0, 0, 0};
        wr32(add_edi + 2, (uint32_t)imm_u64);
        buf_put(code, add_edi, sizeof(add_edi));
      } else {
        unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
        wr32(add_eax + 1, (uint32_t)imm_u64);
        buf_put(code, add_eax, sizeof(add_eax));
      }
    } else if (op == OP_ADD_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char add_edi[6] = {0x81, 0xc7, 0, 0, 0, 0};
        wr32(add_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, add_edi, sizeof(add_edi));
      } else {
        unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
        wr32(add_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, add_eax, sizeof(add_eax));
      }
    } else if (op == OP_SUB_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char sub_edi[6] = {0x81, 0xef, 0, 0, 0, 0};
        wr32(sub_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, sub_edi, sizeof(sub_edi));
      } else {
        unsigned char sub_eax[5] = {0x2d, 0, 0, 0, 0};
        wr32(sub_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, sub_eax, sizeof(sub_eax));
      }
    } else if (op == OP_MUL_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char imul_edi[6] = {0x69, 0xff, 0, 0, 0, 0};
        wr32(imul_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, imul_edi, sizeof(imul_edi));
      } else {
        unsigned char imul_eax[6] = {0x69, 0xc0, 0, 0, 0, 0};
        wr32(imul_eax + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, imul_eax, sizeof(imul_eax));
      }
    } else if (op == OP_EQ_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char sete_al[3] = {0x0f, 0x94, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, sete_al, sizeof(sete_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char sete_al[3] = {0x0f, 0x94, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, sete_al, sizeof(sete_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_LT_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char setl_al[3] = {0x0f, 0x9c, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, setl_al, sizeof(setl_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char setl_al[3] = {0x0f, 0x9c, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, setl_al, sizeof(setl_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_GT_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char setg_al[3] = {0x0f, 0x9f, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, setg_al, sizeof(setg_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char setg_al[3] = {0x0f, 0x9f, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, setg_al, sizeof(setg_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_NE_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char setne_al[3] = {0x0f, 0x95, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, setne_al, sizeof(setne_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char setne_al[3] = {0x0f, 0x95, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, setne_al, sizeof(setne_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_LE_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char setle_al[3] = {0x0f, 0x9e, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, setle_al, sizeof(setle_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char setle_al[3] = {0x0f, 0x9e, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, setle_al, sizeof(setle_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_GE_I64) {
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      if (exit_style) {
        unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
        unsigned char setge_al[3] = {0x0f, 0x9d, 0xc0};
        unsigned char movzx_edi_al[3] = {0x0f, 0xb6, 0xf8};
        wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_edi, sizeof(cmp_edi));
        buf_put(code, setge_al, sizeof(setge_al));
        buf_put(code, movzx_edi_al, sizeof(movzx_edi_al));
      } else {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char setge_al[3] = {0x0f, 0x9d, 0xc0};
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, setge_al, sizeof(setge_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (op == OP_EXPECT_U64 || op == OP_EXPECT_I64 ||
               op == OP_EXPECT_BOOL || op == OP_EXPECT_PTR) {
      uint32_t patch_off = 0;
      if (op == OP_EXPECT_U64) {
        if (last_kind != VAL_U64 && last_kind != VAL_I64) goto fail;
        if (imm_u64 > UINT32_MAX) goto fail;
        if (last_kind == VAL_I64 && imm_u64 > INT32_MAX) goto fail;
        if (exit_style) {
          unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
          wr32(cmp_edi + 2, (uint32_t)imm_u64);
          patch_off = (uint32_t)(code->len + sizeof(cmp_edi) + 2);
          buf_put(code, cmp_edi, sizeof(cmp_edi));
        } else {
          unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
          wr32(cmp_eax + 1, (uint32_t)imm_u64);
          patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
          buf_put(code, cmp_eax, sizeof(cmp_eax));
        }
      } else if (op == OP_EXPECT_I64) {
        if (last_kind != VAL_I64) goto fail;
        if (imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
        if (exit_style) {
          unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
          wr32(cmp_edi + 2, (uint32_t)(int32_t)imm_i64);
          patch_off = (uint32_t)(code->len + sizeof(cmp_edi) + 2);
          buf_put(code, cmp_edi, sizeof(cmp_edi));
        } else {
          unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
          wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
          patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
          buf_put(code, cmp_eax, sizeof(cmp_eax));
        }
      } else if (op == OP_EXPECT_BOOL) {
        if (last_kind != VAL_BOOL) goto fail;
        if (exit_style) {
          unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
          wr32(cmp_edi + 2, arg0 ? 1u : 0u);
          patch_off = (uint32_t)(code->len + sizeof(cmp_edi) + 2);
          buf_put(code, cmp_edi, sizeof(cmp_edi));
        } else {
          unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
          wr32(cmp_eax + 1, arg0 ? 1u : 0u);
          patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
          buf_put(code, cmp_eax, sizeof(cmp_eax));
        }
      } else {
        if (last_kind != VAL_PTR || arg0 > 1u) goto fail;
        if (exit_style) {
          unsigned char cmp_edi_zero[3] = {0x83, 0xff, 0};
          patch_off = (uint32_t)(code->len + sizeof(cmp_edi_zero) + 2);
          buf_put(code, cmp_edi_zero, sizeof(cmp_edi_zero));
        } else {
          unsigned char cmp_eax_zero[3] = {0x83, 0xf8, 0};
          patch_off = (uint32_t)(code->len + sizeof(cmp_eax_zero) + 2);
          buf_put(code, cmp_eax_zero, sizeof(cmp_eax_zero));
        }
      }
      {
        unsigned char fail_jump[6] = {0x0f, 0x85, 0, 0, 0, 0};
        if (op == OP_EXPECT_PTR && arg0) fail_jump[1] = 0x84;
        buf_put(code, fail_jump, sizeof(fail_jump));
        buf_put32(&expect_patches, patch_off);
      }
    } else if (op == OP_BRANCH_BOOL) {
      PcPatch patch = {0};
      if (last_kind != VAL_BOOL || arg0 >= b->instr_count) goto fail;
      if (exit_style) {
        unsigned char test_edi[2] = {0x85, 0xff};
        buf_put(code, test_edi, sizeof(test_edi));
      } else {
        unsigned char test_eax[2] = {0x85, 0xc0};
        buf_put(code, test_eax, sizeof(test_eax));
      }
      {
        unsigned char jne_target[6] = {0x0f, 0x85, 0, 0, 0, 0};
        patch.patch_off = (uint32_t)(code->len + 2);
        patch.target_pc = arg0;
        buf_put(code, jne_target, sizeof(jne_target));
        buf_put(&branch_patches, &patch, sizeof(patch));
      }
    } else if (op == OP_RET_LAST) {
      if (exit_style) {
        unsigned char exit_syscall[7] = {0xb8, 0x3c, 0, 0, 0, 0x0f, 0x05};
        buf_put(code, exit_syscall, sizeof(exit_syscall));
      } else {
        unsigned char ret = 0xc3;
        buf_put(code, &ret, 1);
      }
      saw_ret = 1;
      break;
    } else {
      goto fail;
    }
  }
  if (!saw_ret) goto fail;
  for (size_t i = 0; i < branch_patches.len; i += sizeof(PcPatch)) {
    const PcPatch *patch = (const PcPatch *)(branch_patches.data + i);
    int64_t rel = (int64_t)pc_offs[patch->target_pc] - (int64_t)(patch->patch_off + 4);
    wr32(code->data + patch->patch_off, (uint32_t)(int32_t)rel);
  }
  if (expect_patches.len) {
    size_t fail_off = code->len;
    if (exit_style) {
      unsigned char fail_exit[12] = {
        0xbf, 125, 0, 0, 0,
        0xb8, 0x3c, 0, 0, 0,
        0x0f, 0x05
      };
      buf_put(code, fail_exit, sizeof(fail_exit));
    } else {
      unsigned char fail_ret[6] = {0xb8, 125, 0, 0, 0, 0xc3};
      buf_put(code, fail_ret, sizeof(fail_ret));
    }
    for (size_t i = 0; i < expect_patches.len; i += 4) {
      uint32_t patch_off = rd32(expect_patches.data + i);
      int64_t rel = (int64_t)fail_off - (int64_t)(patch_off + 4);
      wr32(code->data + patch_off, (uint32_t)(int32_t)rel);
    }
  }
  if (data_patches.len) {
    for (size_t i = 0; i < data_patches.len; i += sizeof(DataPatch)) {
      const DataPatch *patch = (const DataPatch *)(data_patches.data + i);
      if (data_relas) {
        Elf64ObjRela rel = {patch->patch_off, 1u, 1u, (int64_t)patch->sec_off};
        buf_put(data_relas, &rel, sizeof(rel));
      } else {
        ExecSectionLayout layout = {0};
        size_t file_n = 0;
        exec_section_layout_fill(&layout, code->len, rodata ? rodata->len : 0,
                                 data_sec ? data_sec->len : 0, &file_n);
        (void)file_n;
        uint64_t target = patch->sec == 2 ? layout.data_va + patch->sec_off :
                          layout.rodata_va + patch->sec_off;
        uint64_t rip_next = layout.text_va + patch->patch_off + 4;
        int64_t rel = (int64_t)target - (int64_t)rip_next;
        if (rel < INT32_MIN || rel > INT32_MAX) goto fail;
        wr32(code->data + patch->patch_off, (uint32_t)(int32_t)rel);
      }
    }
  }
  free(const_sec_off);
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  free(data_patches.data);
  return 1;

fail:
  free(const_sec_off);
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  free(data_patches.data);
  return 0;
}

static int compile_pure_u64_blob_to_x86_exit(const Blob *b, Buf *code, Buf *rodata, Buf *data_sec) {
  return compile_pure_blob_to_x86(b, code, 1, rodata, data_sec, NULL);
}

static int compile_pure_u64_blob_to_x86_ret(const Blob *b, Buf *code, Buf *rodata, Buf *data_sec) {
  return compile_pure_blob_to_x86(b, code, 0, rodata, data_sec, NULL);
}

static int compile_pure_u64_blob_to_x86_ret_obj(const Blob *b, Buf *code, Buf *rodata, Buf *data_sec,
                                                Buf *data_relas) {
  return compile_pure_blob_to_x86(b, code, 0, rodata, data_sec, data_relas);
}

static int aot_build_label_table(const AotFunc *func, LabelDef **out_labels,
                                 size_t *out_label_count, uint32_t *out_emitted_stmts) {
  LabelDef *labels = (LabelDef *)calloc(func->stmt_count ? func->stmt_count : 1, sizeof(*labels));
  size_t label_count = 0;
  uint32_t emitted = 0;
  if (!labels) return 0;
  for (size_t i = 0; i < func->stmt_count; ++i) {
    const AotStmt *stmt = &func->stmts[i];
    if (stmt->kind == AOT_STMT_LABEL) {
      if (find_label(labels, label_count, stmt->target_name) >= 0) {
        fprintf(stderr, "duplicate.label=%s\n", stmt->target_name);
        free(labels);
        return 0;
      }
      labels[label_count++] = (LabelDef){stmt->target_name, emitted};
    } else {
      emitted++;
    }
  }
  *out_labels = labels;
  *out_label_count = label_count;
  *out_emitted_stmts = emitted;
  return 1;
}

static void free_buf_array(Buf *bufs, size_t count) {
  if (!bufs) return;
  for (size_t i = 0; i < count; ++i) free(bufs[i].data);
  free(bufs);
}

static int infer_aot_func_return_kind(const AotModule *m, size_t func_idx,
                                      int *return_kinds, uint8_t *states) {
  const AotFunc *func = &m->funcs[func_idx];
  int last_kind = 0;
  if (states[func_idx] == 2) return return_kinds[func_idx] != 0;
  if (states[func_idx] == 1) return 0;
  states[func_idx] = 1;
  for (size_t i = 0; i < func->stmt_count; ++i) {
    const AotStmt *stmt = &func->stmts[i];
    if (stmt->kind == AOT_STMT_LABEL) {
      continue;
    } else if (stmt->kind == AOT_STMT_CONST_U64) {
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_CONST_I64) {
      last_kind = VAL_I64;
    } else if (stmt->kind == AOT_STMT_CONST_BOOL) {
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_NULL_PTR) {
      last_kind = VAL_PTR;
    } else if (stmt->kind == AOT_STMT_ADD_PTR || stmt->kind == AOT_STMT_SUB_PTR) {
      if (last_kind != VAL_PTR) return 0;
    } else if (stmt->kind == AOT_STMT_PTR_TO_U64) {
      if (last_kind != VAL_PTR) return 0;
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_U64_TO_PTR) {
      if (last_kind != VAL_U64) return 0;
      last_kind = VAL_PTR;
    } else if (stmt->kind == AOT_STMT_LOAD_U8 || stmt->kind == AOT_STMT_LOAD_U16 ||
               stmt->kind == AOT_STMT_LOAD_U32) {
      if (last_kind != VAL_PTR) return 0;
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_STORE_U8 ||
               stmt->kind == AOT_STMT_STORE_U16 ||
               stmt->kind == AOT_STMT_STORE_U32) {
      if (last_kind != VAL_PTR) return 0;
      if (stmt->kind == AOT_STMT_STORE_U8 && stmt->imm > 255u) return 0;
      if (stmt->kind == AOT_STMT_STORE_U16 && stmt->imm > 65535u) return 0;
      if (stmt->kind == AOT_STMT_STORE_U32 && stmt->imm > UINT32_MAX) return 0;
    } else if (stmt->kind == AOT_STMT_IS_NULL_PTR ||
               stmt->kind == AOT_STMT_IS_NONNULL_PTR) {
      if (last_kind != VAL_PTR) return 0;
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_ADD_U64) {
      if (last_kind != VAL_U64) return 0;
    } else if (stmt->kind == AOT_STMT_ADD_I64 || stmt->kind == AOT_STMT_SUB_I64 ||
               stmt->kind == AOT_STMT_MUL_I64) {
      if (last_kind != VAL_I64) return 0;
    } else if (stmt->kind == AOT_STMT_EQ_I64 || stmt->kind == AOT_STMT_LT_I64 ||
               stmt->kind == AOT_STMT_GT_I64 || stmt->kind == AOT_STMT_NE_I64 ||
               stmt->kind == AOT_STMT_LE_I64 || stmt->kind == AOT_STMT_GE_I64) {
      if (last_kind != VAL_I64) return 0;
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_NOT_BOOL || stmt->kind == AOT_STMT_AND_BOOL ||
               stmt->kind == AOT_STMT_OR_BOOL) {
      if (last_kind != VAL_BOOL) return 0;
    } else if (stmt->kind == AOT_STMT_EXPECT_U64) {
      if (last_kind != VAL_U64 && last_kind != VAL_I64) return 0;
    } else if (stmt->kind == AOT_STMT_EXPECT_I64) {
      if (last_kind != VAL_I64) return 0;
    } else if (stmt->kind == AOT_STMT_EXPECT_BOOL || stmt->kind == AOT_STMT_BRANCH_BOOL) {
      if (last_kind != VAL_BOOL) return 0;
    } else if (stmt->kind == AOT_STMT_EXPECT_PTR) {
      if (last_kind != VAL_PTR) return 0;
    } else if (stmt->kind == AOT_STMT_CALL_FUNC) {
      int target_idx = aot_find_func(m, stmt->target_name);
      if (target_idx < 0) return 0;
      if (!infer_aot_func_return_kind(m, (size_t)target_idx, return_kinds, states)) return 0;
      last_kind = return_kinds[target_idx];
    } else {
      return 0;
    }
  }
  if (!last_kind) return 0;
  return_kinds[func_idx] = last_kind;
  states[func_idx] = 2;
  return 1;
}

static int infer_aot_module_return_kinds(const AotModule *m, int **out_return_kinds) {
  int *return_kinds = (int *)calloc(m->func_count ? m->func_count : 1, sizeof(*return_kinds));
  uint8_t *states = (uint8_t *)calloc(m->func_count ? m->func_count : 1, sizeof(*states));
  if (!return_kinds || !states) {
    free(return_kinds);
    free(states);
    return 0;
  }
  for (size_t i = 0; i < m->func_count; ++i) {
    if (!infer_aot_func_return_kind(m, i, return_kinds, states)) {
      free(return_kinds);
      free(states);
      return 0;
    }
  }
  free(states);
  *out_return_kinds = return_kinds;
  return 1;
}

static int compile_aot_func_to_x86_ret(const AotModule *m, const AotFunc *func,
                                       const int *return_kinds, Buf *code, Buf *call_patches) {
  int saw_ret = 0;
  int last_kind = 0;
  Buf expect_patches = {0};
  Buf branch_patches = {0};
  LabelDef *labels = NULL;
  size_t label_count = 0;
  uint32_t emitted_stmts = 0;
  uint32_t emitted_pc = 0;
  uint32_t *pc_offs = NULL;
  if (!aot_build_label_table(func, &labels, &label_count, &emitted_stmts)) return 0;
  pc_offs = (uint32_t *)calloc((size_t)emitted_stmts + 1, sizeof(*pc_offs));
  if (!pc_offs) goto fail;
  for (size_t i = 0; i < func->stmt_count; ++i) {
    const AotStmt *stmt = &func->stmts[i];
    uint32_t patch_off = 0;
    if (stmt->kind == AOT_STMT_LABEL) continue;
    pc_offs[emitted_pc++] = (uint32_t)code->len;
    if (stmt->kind == AOT_STMT_CONST_U64 || stmt->kind == AOT_STMT_ADD_U64 ||
        stmt->kind == AOT_STMT_EXPECT_U64 || stmt->kind == AOT_STMT_ADD_PTR ||
        stmt->kind == AOT_STMT_SUB_PTR) {
      if (stmt->imm > UINT32_MAX) goto fail;
    }
    if (stmt->kind == AOT_STMT_ADD_I64 || stmt->kind == AOT_STMT_SUB_I64 ||
        stmt->kind == AOT_STMT_MUL_I64 || stmt->kind == AOT_STMT_EQ_I64 ||
        stmt->kind == AOT_STMT_LT_I64 || stmt->kind == AOT_STMT_GT_I64 ||
        stmt->kind == AOT_STMT_NE_I64 || stmt->kind == AOT_STMT_LE_I64 ||
        stmt->kind == AOT_STMT_GE_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
    }
    if (stmt->kind == AOT_STMT_CONST_U64) {
      unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
      wr32(mov_eax + 1, (uint32_t)stmt->imm);
      buf_put(code, mov_eax, sizeof(mov_eax));
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_CONST_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      {
        unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
        wr32(mov_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, mov_eax, sizeof(mov_eax));
      }
      last_kind = VAL_I64;
    } else if (stmt->kind == AOT_STMT_CONST_BOOL) {
      unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
      wr32(mov_eax + 1, stmt->imm ? 1u : 0u);
      buf_put(code, mov_eax, sizeof(mov_eax));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_NULL_PTR) {
      unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
      buf_put(code, mov_eax, sizeof(mov_eax));
      last_kind = VAL_PTR;
    } else if (stmt->kind == AOT_STMT_ADD_PTR) {
      if (last_kind != VAL_PTR) goto fail;
      {
        unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
        wr32(add_eax + 1, (uint32_t)stmt->imm);
        buf_put(code, add_eax, sizeof(add_eax));
      }
    } else if (stmt->kind == AOT_STMT_SUB_PTR) {
      if (last_kind != VAL_PTR) goto fail;
      {
        unsigned char sub_eax[5] = {0x2d, 0, 0, 0, 0};
        wr32(sub_eax + 1, (uint32_t)stmt->imm);
        buf_put(code, sub_eax, sizeof(sub_eax));
      }
    } else if (stmt->kind == AOT_STMT_PTR_TO_U64) {
      if (last_kind != VAL_PTR) goto fail;
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_U64_TO_PTR) {
      if (last_kind != VAL_U64) goto fail;
      last_kind = VAL_PTR;
    } else if (stmt->kind == AOT_STMT_LOAD_U8 || stmt->kind == AOT_STMT_LOAD_U16 ||
               stmt->kind == AOT_STMT_LOAD_U32) {
      if (last_kind != VAL_PTR) goto fail;
      if (stmt->kind == AOT_STMT_LOAD_U8) {
        unsigned char movzx_eax_ptr_rax[3] = {0x0f, 0xb6, 0x00};
        buf_put(code, movzx_eax_ptr_rax, sizeof(movzx_eax_ptr_rax));
      } else if (stmt->kind == AOT_STMT_LOAD_U16) {
        unsigned char movzx_eax_word_ptr_rax[3] = {0x0f, 0xb7, 0x00};
        buf_put(code, movzx_eax_word_ptr_rax, sizeof(movzx_eax_word_ptr_rax));
      } else {
        unsigned char mov_eax_dword_ptr_rax[2] = {0x8b, 0x00};
        buf_put(code, mov_eax_dword_ptr_rax, sizeof(mov_eax_dword_ptr_rax));
      }
      last_kind = VAL_U64;
    } else if (stmt->kind == AOT_STMT_STORE_U8 ||
               stmt->kind == AOT_STMT_STORE_U16 ||
               stmt->kind == AOT_STMT_STORE_U32) {
      if (last_kind != VAL_PTR) goto fail;
      if (stmt->kind == AOT_STMT_STORE_U8 && stmt->imm > 255u) goto fail;
      if (stmt->kind == AOT_STMT_STORE_U16 && stmt->imm > 65535u) goto fail;
      if (stmt->kind == AOT_STMT_STORE_U32 && stmt->imm > UINT32_MAX) goto fail;
      if (stmt->kind == AOT_STMT_STORE_U8) {
        unsigned char mov_byte_ptr_rax_imm[3] = {0xc6, 0x00, (unsigned char)stmt->imm};
        buf_put(code, mov_byte_ptr_rax_imm, sizeof(mov_byte_ptr_rax_imm));
      } else if (stmt->kind == AOT_STMT_STORE_U16) {
        unsigned char mov_word_ptr_rax_imm[5] = {0x66, 0xc7, 0x00, 0, 0};
        wr16(mov_word_ptr_rax_imm + 3, (uint16_t)stmt->imm);
        buf_put(code, mov_word_ptr_rax_imm, sizeof(mov_word_ptr_rax_imm));
      } else {
        unsigned char mov_dword_ptr_rax_imm[6] = {0xc7, 0x00, 0, 0, 0, 0};
        wr32(mov_dword_ptr_rax_imm + 2, (uint32_t)stmt->imm);
        buf_put(code, mov_dword_ptr_rax_imm, sizeof(mov_dword_ptr_rax_imm));
      }
    } else if (stmt->kind == AOT_STMT_IS_NULL_PTR ||
               stmt->kind == AOT_STMT_IS_NONNULL_PTR) {
      if (last_kind != VAL_PTR) goto fail;
      {
        unsigned char test_eax_eax[2] = {0x85, 0xc0};
        unsigned char setcc_al[3] = {
          0x0f,
          stmt->kind == AOT_STMT_IS_NULL_PTR ? 0x94 : 0x95,
          0xc0
        };
        unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
        buf_put(code, test_eax_eax, sizeof(test_eax_eax));
        buf_put(code, setcc_al, sizeof(setcc_al));
        buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      }
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_NOT_BOOL) {
      if (last_kind != VAL_BOOL) goto fail;
      unsigned char xor_eax_1[3] = {0x83, 0xf0, 0x01};
      buf_put(code, xor_eax_1, sizeof(xor_eax_1));
    } else if (stmt->kind == AOT_STMT_AND_BOOL) {
      if (last_kind != VAL_BOOL || stmt->imm > 1u) goto fail;
      unsigned char and_eax_imm[3] = {0x83, 0xe0, (unsigned char)stmt->imm};
      buf_put(code, and_eax_imm, sizeof(and_eax_imm));
    } else if (stmt->kind == AOT_STMT_OR_BOOL) {
      if (last_kind != VAL_BOOL || stmt->imm > 1u) goto fail;
      unsigned char or_eax_imm[3] = {0x83, 0xc8, (unsigned char)stmt->imm};
      buf_put(code, or_eax_imm, sizeof(or_eax_imm));
    } else if (stmt->kind == AOT_STMT_ADD_U64) {
      if (last_kind != VAL_U64) goto fail;
      unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
      wr32(add_eax + 1, (uint32_t)stmt->imm);
      buf_put(code, add_eax, sizeof(add_eax));
    } else if (stmt->kind == AOT_STMT_ADD_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
      wr32(add_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, add_eax, sizeof(add_eax));
    } else if (stmt->kind == AOT_STMT_SUB_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char sub_eax[5] = {0x2d, 0, 0, 0, 0};
      wr32(sub_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, sub_eax, sizeof(sub_eax));
    } else if (stmt->kind == AOT_STMT_MUL_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char imul_eax[6] = {0x69, 0xc0, 0, 0, 0, 0};
      wr32(imul_eax + 2, (uint32_t)(int32_t)imm_i64);
      buf_put(code, imul_eax, sizeof(imul_eax));
    } else if (stmt->kind == AOT_STMT_EQ_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char sete_al[3] = {0x0f, 0x94, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, sete_al, sizeof(sete_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_LT_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char setl_al[3] = {0x0f, 0x9c, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, setl_al, sizeof(setl_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_GT_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char setg_al[3] = {0x0f, 0x9f, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, setg_al, sizeof(setg_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_NE_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char setne_al[3] = {0x0f, 0x95, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, setne_al, sizeof(setne_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_LE_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char setle_al[3] = {0x0f, 0x9e, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, setle_al, sizeof(setle_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_GE_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char setge_al[3] = {0x0f, 0x9d, 0xc0};
      unsigned char movzx_eax_al[3] = {0x0f, 0xb6, 0xc0};
      wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, setge_al, sizeof(setge_al));
      buf_put(code, movzx_eax_al, sizeof(movzx_eax_al));
      last_kind = VAL_BOOL;
    } else if (stmt->kind == AOT_STMT_EXPECT_U64) {
      if (last_kind != VAL_U64 && last_kind != VAL_I64) goto fail;
      if (last_kind == VAL_I64 && stmt->imm > INT32_MAX) goto fail;
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
      patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
      wr32(cmp_eax + 1, (uint32_t)stmt->imm);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, jne_fail, sizeof(jne_fail));
      buf_put32(&expect_patches, patch_off);
    } else if (stmt->kind == AOT_STMT_EXPECT_I64) {
      int64_t imm_i64 = (int64_t)stmt->imm;
      if (last_kind != VAL_I64 || imm_i64 < INT32_MIN || imm_i64 > INT32_MAX) goto fail;
      {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
        patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
        wr32(cmp_eax + 1, (uint32_t)(int32_t)imm_i64);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, jne_fail, sizeof(jne_fail));
        buf_put32(&expect_patches, patch_off);
      }
    } else if (stmt->kind == AOT_STMT_EXPECT_BOOL) {
      if (last_kind != VAL_BOOL) goto fail;
      {
        unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
        unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
        patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
        wr32(cmp_eax + 1, stmt->imm ? 1u : 0u);
        buf_put(code, cmp_eax, sizeof(cmp_eax));
        buf_put(code, jne_fail, sizeof(jne_fail));
        buf_put32(&expect_patches, patch_off);
      }
    } else if (stmt->kind == AOT_STMT_EXPECT_PTR) {
      if (last_kind != VAL_PTR || stmt->imm > 1u) goto fail;
      {
        unsigned char cmp_eax_zero[3] = {0x83, 0xf8, 0};
        unsigned char fail_jump[6] = {0x0f, stmt->imm ? 0x84 : 0x85, 0, 0, 0, 0};
        patch_off = (uint32_t)(code->len + sizeof(cmp_eax_zero) + 2);
        buf_put(code, cmp_eax_zero, sizeof(cmp_eax_zero));
        buf_put(code, fail_jump, sizeof(fail_jump));
        buf_put32(&expect_patches, patch_off);
      }
    } else if (stmt->kind == AOT_STMT_BRANCH_BOOL) {
      int label_idx = -1;
      PcPatch patch = {0};
      if (last_kind != VAL_BOOL) goto fail;
      label_idx = find_label(labels, label_count, stmt->target_name);
      if (label_idx < 0) {
        fprintf(stderr, "missing.label=%s\n", stmt->target_name);
        goto fail;
      }
      {
        unsigned char test_eax[2] = {0x85, 0xc0};
        unsigned char jne_target[6] = {0x0f, 0x85, 0, 0, 0, 0};
        buf_put(code, test_eax, sizeof(test_eax));
        patch.patch_off = (uint32_t)(code->len + 2);
        patch.target_pc = labels[label_idx].pc;
        buf_put(code, jne_target, sizeof(jne_target));
        buf_put(&branch_patches, &patch, sizeof(patch));
      }
    } else if (stmt->kind == AOT_STMT_CALL_FUNC) {
      int target_idx = aot_find_func(m, stmt->target_name);
      unsigned char call_rel32[5] = {0xe8, 0, 0, 0, 0};
      AotCallPatch patch = {(uint32_t)(code->len + 1), stmt->target_name};
      if (target_idx < 0 || !return_kinds[target_idx]) goto fail;
      buf_put(code, call_rel32, sizeof(call_rel32));
      buf_put(call_patches, &patch, sizeof(patch));
      last_kind = return_kinds[target_idx];
    } else {
      goto fail;
    }
  }
  if (!emitted_stmts) goto fail;
  pc_offs[emitted_stmts] = (uint32_t)code->len;
  for (size_t i = 0; i < branch_patches.len; i += sizeof(PcPatch)) {
    const PcPatch *patch = (const PcPatch *)(branch_patches.data + i);
    int64_t rel = (int64_t)pc_offs[patch->target_pc] - (int64_t)(patch->patch_off + 4);
    wr32(code->data + patch->patch_off, (uint32_t)(int32_t)rel);
  }
  if (func->stmt_count) {
    unsigned char ret = 0xc3;
    buf_put(code, &ret, 1);
    saw_ret = 1;
  }
  if (saw_ret && expect_patches.len) {
    size_t fail_off = code->len;
    unsigned char fail_ret[6] = {0xb8, 125, 0, 0, 0, 0xc3};
    buf_put(code, fail_ret, sizeof(fail_ret));
    for (size_t i = 0; i < expect_patches.len; i += 4) {
      uint32_t patch_off = rd32(expect_patches.data + i);
      int64_t rel = (int64_t)fail_off - (int64_t)(patch_off + 4);
      wr32(code->data + patch_off, (uint32_t)(int32_t)rel);
    }
  }
  free(labels);
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  return saw_ret;

fail:
  free(labels);
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  return 0;
}

static int compile_aot_module_to_elf64_obj(const AotModule *m, const char *out_path,
                                           const char *entry_symbol) {
  Buf *codes = NULL;
  Buf *call_patches = NULL;
  size_t *text_offs = NULL;
  uint32_t *func_sym_idx = NULL;
  int *return_kinds = NULL;
  Elf64ObjSymbol *syms = NULL;
  Elf64ObjRela *relas = NULL;
  Buf text = {0};
  size_t local_count = 0;
  size_t rela_count = 0;
  int ok = 0;

  if (!entry_symbol[0] || !m->func_count) return 0;
  for (size_t i = 0; i < m->func_count; ++i) {
    if (m->funcs[i].is_global) continue;
    local_count++;
    if (strcmp(m->funcs[i].name, entry_symbol) == 0) return 0;
  }

  if (!infer_aot_module_return_kinds(m, &return_kinds)) goto done;
  codes = (Buf *)calloc(m->func_count, sizeof(*codes));
  call_patches = (Buf *)calloc(m->func_count, sizeof(*call_patches));
  text_offs = (size_t *)calloc(m->func_count, sizeof(*text_offs));
  func_sym_idx = (uint32_t *)calloc(m->func_count, sizeof(*func_sym_idx));
  syms = (Elf64ObjSymbol *)calloc(m->func_count, sizeof(*syms));
  if (!codes || !call_patches || !text_offs || !func_sym_idx || !syms) goto done;

  for (size_t i = 0; i < m->func_count; ++i) {
    if (!compile_aot_func_to_x86_ret(m, &m->funcs[i], return_kinds, &codes[i],
                                     &call_patches[i])) goto done;
    text_offs[i] = text.len;
    buf_put(&text, codes[i].data, codes[i].len);
  }

  for (size_t i = 0, next = 1; i < m->func_count; ++i) {
    if (m->funcs[i].is_global) continue;
    syms[next - 1] = (Elf64ObjSymbol){m->funcs[i].name, 0x02, 1, text_offs[i], codes[i].len};
    func_sym_idx[i] = (uint32_t)next++;
  }
  for (size_t i = 0, next = (uint32_t)local_count + 1; i < m->func_count; ++i) {
    if (!m->funcs[i].is_global) continue;
    syms[next - 1] = (Elf64ObjSymbol){entry_symbol, 0x12, 1, text_offs[i], codes[i].len};
    func_sym_idx[i] = (uint32_t)next++;
  }

  for (size_t i = 0; i < m->func_count; ++i) {
    rela_count += call_patches[i].len / sizeof(AotCallPatch);
  }
  relas = rela_count ? (Elf64ObjRela *)calloc(rela_count, sizeof(*relas)) : NULL;
  if (rela_count && !relas) goto done;

  for (size_t i = 0, rela_idx = 0; i < m->func_count; ++i) {
    for (size_t off = 0; off < call_patches[i].len; off += sizeof(AotCallPatch), rela_idx++) {
      const AotCallPatch *patch = (const AotCallPatch *)(call_patches[i].data + off);
      int target_idx = aot_find_func(m, patch->target_name);
      if (target_idx < 0) goto done;
      relas[rela_idx] =
        (Elf64ObjRela){text_offs[i] + patch->patch_off, func_sym_idx[target_idx], 4, -4};
    }
  }

  ok = emit_elf64_obj_file(out_path, text.data, text.len, syms, m->func_count, relas, rela_count);

done:
  free_buf_array(codes, m->func_count);
  free_buf_array(call_patches, m->func_count);
  free(text.data);
  free(text_offs);
  free(func_sym_idx);
  free(return_kinds);
  free(syms);
  free(relas);
  return ok;
}

static int compile_pure_blob_to_elf64_obj_file(const Blob *b, const char *out_path,
                                               const char *symbol);
static int compile_pure_blob_to_elf64_exe_file(const Blob *b, const char *out_path,
                                               const char *entry_symbol);

static int cmd_aot_elf64_code(const char *blob_path, const char *out_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!compile_pure_blob_to_elf64_exe_file(&b, out_path, "nano_main")) {
    free(owned);
    fprintf(stderr, "aot-elf64-code=unsupported_blob\n");
    return 2;
  }
  free(owned);
  printf("aot.code.output=%s\n", out_path);
  printf("aot.code.symbol=nano_main\n");
  return 0;
}

static int cmd_compile_elf64_code(const char *src_path, const char *out_path) {
  size_t blob_n = 0;
  unsigned char *blob_data = compile_source_path_to_blob(src_path, &blob_n);
  Blob b;
  if (!blob_data || !blob_init(&b, blob_data, blob_n)) {
    fprintf(stderr, "compile-elf64-code=compile_fail\n");
    free(blob_data);
    return 1;
  }
  free(blob_data);
  if (!compile_pure_blob_to_elf64_exe_file(&b, out_path, "nano_main")) {
    fprintf(stderr, "compile-elf64-code=unsupported_source\n");
    return 2;
  }
  printf("compile.elf64.output=%s\n", out_path);
  printf("compile.elf64.symbol=nano_main\n");
  return 0;
}

static int compile_pure_blob_to_elf64_obj_file(const Blob *b, const char *out_path,
                                               const char *symbol) {
  Buf code = {0};
  Buf rodata = {0};
  Buf data_sec = {0};
  Buf data_relas = {0};
  if (!symbol[0]) return 0;
  if (!compile_pure_u64_blob_to_x86_ret_obj(b, &code, &rodata, &data_sec, &data_relas)) {
    free(code.data);
    free(rodata.data);
    free(data_sec.data);
    free(data_relas.data);
    return 0;
  }
  size_t code_n = code.len;
  int emit_ok = 0;
  if (rodata.len || data_sec.len) {
    const char *sec_name = data_sec.len ? ".data" : ".rodata";
    const unsigned char *sec = data_sec.len ? data_sec.data : rodata.data;
    size_t sec_n = data_sec.len ? data_sec.len : rodata.len;
    size_t rela_n = data_relas.len / sizeof(Elf64ObjRela);
    emit_ok = emit_elf64_obj_text_data_section(out_path, symbol, code.data, code_n, sec_name, sec,
                                               sec_n, (const Elf64ObjRela *)data_relas.data,
                                               rela_n);
  } else {
    emit_ok = emit_elf64_obj_text_file(out_path, symbol, code.data, code.len);
  }
  free(code.data);
  free(rodata.data);
  free(data_sec.data);
  free(data_relas.data);
  return emit_ok;
}

static int link_elf64_exe_from_obj(const char *exe_path, const char *entry_symbol,
                                   const char *obj_path) {
  char *argv[] = {"nano-lisp-jit", "link-elf64-exe", (char *)exe_path, (char *)entry_symbol,
                  (char *)obj_path, NULL};
  return cmd_link_elf64_exe(5, argv);
}

static int compile_pure_blob_to_elf64_exe_file(const Blob *b, const char *out_path,
                                               const char *entry_symbol) {
  char tmp_obj[] = "/tmp/nano-jit-XXXXXX.o";
  int fd = mkstemps(tmp_obj, 2);
  if (fd < 0) return 0;
  close(fd);
  if (!compile_pure_blob_to_elf64_obj_file(b, tmp_obj, entry_symbol)) {
    remove(tmp_obj);
    return 0;
  }
  int rc = link_elf64_exe_from_obj(out_path, entry_symbol, tmp_obj);
  remove(tmp_obj);
  return rc == 0;
}

static int cmd_aot_elf64_obj_code(const char *blob_path, const char *out_path,
                                  const char *symbol) {
  Blob b;
  unsigned char *owned = NULL;
  if (!symbol[0]) {
    fprintf(stderr, "aot-elf64-obj-code=bad_symbol\n");
    return 1;
  }
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!compile_pure_blob_to_elf64_obj_file(&b, out_path, symbol)) {
    free(owned);
    fprintf(stderr, "aot-elf64-obj-code=write_fail path=%s\n", out_path);
    return 3;
  }
  free(owned);
  printf("aot.obj.code.output=%s\n", out_path);
  printf("aot.obj.code.symbol=%s\n", symbol);
  return 0;
}
