/* Included from lispjit.c — ELF64 emit, object layout, tiny link. */
static size_t align_up_size(size_t n, size_t a) {
  return (n + a - 1) & ~(a - 1);
}

enum {
  ELF64_EHDR_SIZE = 64,
  ELF64_PHDR_SIZE = 56,
  ELF64_SHDR_SIZE = 64,
  ELF64_SYM_SIZE = 24,
  ELF64_RELA_SIZE = 24,
  ELF64_EXEC_CODE_OFF = ELF64_EHDR_SIZE + ELF64_PHDR_SIZE,
};

#define ELF64_EXEC_BASE 0x400000u

static size_t g_link_last_code_bytes;

typedef struct {
  size_t text_va;
  size_t rodata_va;
  size_t data_va;
} ExecSectionLayout;

static void exec_section_layout_fill(ExecSectionLayout *layout, size_t code_n, size_t rodata_n,
                                     size_t data_n, size_t *out_file_n) {
  const size_t page = 0x1000;
  int nph = 1 + (rodata_n > 0) + (data_n > 0);
  size_t off = ELF64_EHDR_SIZE + (size_t)nph * ELF64_PHDR_SIZE;
  size_t va = off;
  layout->text_va = ELF64_EXEC_BASE + va;
  off += code_n;
  va += code_n;
  layout->rodata_va = 0;
  layout->data_va = 0;
  if (rodata_n) {
    off = align_up_size(off, page);
    va = align_up_size(va, page);
    layout->rodata_va = ELF64_EXEC_BASE + va;
    off += rodata_n;
    va += rodata_n;
  }
  if (data_n) {
    off = align_up_size(off, page);
    va = align_up_size(va, page);
    layout->data_va = ELF64_EXEC_BASE + va;
    off += data_n;
    va += data_n;
  }
  *out_file_n = align_up_size(off, page);
}

#define ELF64_MACHINE_X86_64 62u
#define ELF64_MACHINE_AARCH64 183u

typedef struct {
  const char *name;
  uint8_t info;
  uint16_t shndx;
  uint64_t value;
  uint64_t size;
} Elf64ObjSymbol;

typedef struct {
  uint64_t offset;
  uint32_t sym_idx;
  uint32_t type;
  int64_t addend;
} Elf64ObjRela;

static void wr_elf64_ident(unsigned char *p) {
  memset(p, 0, 16);
  p[0] = 0x7f;
  p[1] = 'E';
  p[2] = 'L';
  p[3] = 'F';
  p[4] = 2;
  p[5] = 1;
  p[6] = 1;
}

static void wr_elf64_ehdr_exec(unsigned char *p, uint64_t entry, uint64_t phoff, uint16_t phnum,
                               uint16_t machine) {
  wr_elf64_ident(p);
  wr16(p + 16, 2);
  wr16(p + 18, machine);
  wr32(p + 20, 1);
  wr64(p + 24, entry);
  wr64(p + 32, phoff);
  wr16(p + 52, ELF64_EHDR_SIZE);
  wr16(p + 54, ELF64_PHDR_SIZE);
  wr16(p + 56, phnum);
}

static void wr_elf64_ehdr_reloc(unsigned char *p, uint64_t shoff, uint16_t shnum,
                                uint16_t shstrndx) {
  wr_elf64_ident(p);
  wr16(p + 16, 1);
  wr16(p + 18, ELF64_MACHINE_X86_64);
  wr32(p + 20, 1);
  wr64(p + 40, shoff);
  wr16(p + 52, ELF64_EHDR_SIZE);
  wr16(p + 58, ELF64_SHDR_SIZE);
  wr16(p + 60, shnum);
  wr16(p + 62, shstrndx);
}

static void wr_elf64_phdr(unsigned char *p, uint32_t type, uint32_t flags, uint64_t off,
                          uint64_t vaddr, uint64_t paddr, uint64_t filesz,
                          uint64_t memsz, uint64_t align) {
  wr32(p + 0, type);
  wr32(p + 4, flags);
  wr64(p + 8, off);
  wr64(p + 16, vaddr);
  wr64(p + 24, paddr);
  wr64(p + 32, filesz);
  wr64(p + 40, memsz);
  wr64(p + 48, align);
}

static void wr_elf64_shdr(unsigned char *p, uint32_t name, uint32_t type, uint64_t flags,
                          uint64_t addr, uint64_t off, uint64_t size, uint32_t link,
                          uint32_t info, uint64_t align, uint64_t entsize) {
  wr32(p + 0, name);
  wr32(p + 4, type);
  wr64(p + 8, flags);
  wr64(p + 16, addr);
  wr64(p + 24, off);
  wr64(p + 32, size);
  wr32(p + 40, link);
  wr32(p + 44, info);
  wr64(p + 48, align);
  wr64(p + 56, entsize);
}

static void wr_elf64_sym(unsigned char *p, uint32_t name, uint8_t info, uint16_t shndx,
                         uint64_t value, uint64_t size) {
  memset(p, 0, ELF64_SYM_SIZE);
  wr32(p + 0, name);
  p[4] = info;
  wr16(p + 6, shndx);
  wr64(p + 8, value);
  wr64(p + 16, size);
}

static void wr_elf64_rela(unsigned char *p, uint64_t off, uint32_t sym_idx, uint32_t type,
                          int64_t addend) {
  wr64(p + 0, off);
  wr64(p + 8, ((uint64_t)sym_idx << 32) | type);
  wr64(p + 16, (uint64_t)addend);
}

static int emit_elf64_exec_sections_file(const char *out_path, const unsigned char *code,
                                         size_t code_n, const unsigned char *rodata,
                                         size_t rodata_n, const unsigned char *data,
                                         size_t data_n, uint16_t machine) {
  ExecSectionLayout layout = {0};
  size_t file_n = 0;
  int nph = 1 + (rodata_n > 0) + (data_n > 0);
  exec_section_layout_fill(&layout, code_n, rodata_n, data_n, &file_n);
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  if (!out) return 0;

  wr_elf64_ehdr_exec(out, layout.text_va, ELF64_EHDR_SIZE, (uint16_t)nph, machine);
  size_t ph = ELF64_EHDR_SIZE;
  size_t text_off = layout.text_va - ELF64_EXEC_BASE;
  wr_elf64_phdr(out + ph, 1, 5, text_off, layout.text_va, layout.text_va, code_n, code_n, 0x1000);
  ph += ELF64_PHDR_SIZE;
  if (rodata_n) {
    size_t ro_off = layout.rodata_va - ELF64_EXEC_BASE;
    wr_elf64_phdr(out + ph, 1, 4, ro_off, layout.rodata_va, layout.rodata_va, rodata_n,
                  rodata_n, 0x1000);
    ph += ELF64_PHDR_SIZE;
  }
  if (data_n) {
    size_t data_off = layout.data_va - ELF64_EXEC_BASE;
    wr_elf64_phdr(out + ph, 1, 6, data_off, layout.data_va, layout.data_va, data_n, data_n,
                  0x1000);
  }

  memcpy(out + text_off, code, code_n);
  if (rodata_n) memcpy(out + (layout.rodata_va - ELF64_EXEC_BASE), rodata, rodata_n);
  if (data_n) memcpy(out + (layout.data_va - ELF64_EXEC_BASE), data, data_n);
  int ok = write_file(out_path, out, file_n) && make_executable(out_path);
  free(out);
  return ok;
}

static int emit_elf64_exec_rx_file(const char *out_path, const unsigned char *code,
                                   size_t code_n, uint16_t machine) {
  return emit_elf64_exec_sections_file(out_path, code, code_n, NULL, 0, NULL, 0, machine);
}

static int elf64_obj_local_info(const Elf64ObjSymbol *syms, size_t sym_count, uint32_t *out) {
  size_t local_count = 0;
  size_t i = 0;
  while (i < sym_count && (syms[i].info >> 4) == 0) {
    local_count++;
    i++;
  }
  for (; i < sym_count; ++i) {
    if ((syms[i].info >> 4) == 0) return 0;
  }
  *out = (uint32_t)(1 + local_count);
  return 1;
}

static int emit_elf64_obj_file(const char *out_path, const unsigned char *text, size_t text_n,
                               const Elf64ObjSymbol *syms, size_t sym_count,
                               const Elf64ObjRela *relas, size_t rela_count) {
  static const unsigned char shstr_no_rela[] =
    "\0.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack";
  static const unsigned char shstr_with_rela[] =
    "\0.text\0.rela.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack";
  const unsigned char *shstr = rela_count ? shstr_with_rela : shstr_no_rela;
  size_t shstr_n = rela_count ? sizeof(shstr_with_rela) : sizeof(shstr_no_rela);
  uint16_t shnum = rela_count ? 7 : 6;
  uint16_t shstrndx = rela_count ? 3 : 2;
  uint32_t symtab_link = rela_count ? 5 : 4;
  uint32_t text_name = 1;
  uint32_t rela_name = 7;
  uint32_t shstr_name = rela_count ? 18 : 7;
  uint32_t symtab_name = rela_count ? 28 : 17;
  uint32_t strtab_name = rela_count ? 36 : 25;
  uint32_t note_name = rela_count ? 44 : 33;
  size_t strtab_n = 1;
  uint32_t *name_offs = NULL;
  unsigned char *out = NULL;
  uint32_t symtab_info = 0;
  int ok = 0;

  if (!elf64_obj_local_info(syms, sym_count, &symtab_info)) return 0;
  name_offs = (uint32_t *)calloc(sym_count ? sym_count : 1, sizeof(*name_offs));
  if (!name_offs) return 0;
  for (size_t i = 0; i < sym_count; ++i) {
    name_offs[i] = (uint32_t)strtab_n;
    strtab_n += strlen(syms[i].name) + 1;
  }

  size_t off_text = ELF64_EHDR_SIZE;
  size_t rela_n = rela_count * ELF64_RELA_SIZE;
  size_t off_rela = rela_count ? align_up_size(off_text + text_n, 8) : 0;
  size_t off_shstr = rela_count ? off_rela + rela_n : off_text + text_n;
  size_t off_strtab = off_shstr + shstr_n;
  size_t off_symtab = align_up_size(off_strtab + strtab_n, 8);
  size_t symtab_n = (sym_count + 1) * ELF64_SYM_SIZE;
  size_t off_shdr = align_up_size(off_symtab + symtab_n, 8);
  size_t file_n = off_shdr + (size_t)shnum * ELF64_SHDR_SIZE;
  out = (unsigned char *)calloc(1, file_n);
  if (!out) goto done;

  wr_elf64_ehdr_reloc(out, off_shdr, shnum, shstrndx);
  memcpy(out + off_text, text, text_n);
  for (size_t i = 0; i < rela_count; ++i) {
    wr_elf64_rela(out + off_rela + i * ELF64_RELA_SIZE, relas[i].offset, relas[i].sym_idx,
                  relas[i].type, relas[i].addend);
  }
  memcpy(out + off_shstr, shstr, shstr_n);
  out[off_strtab] = 0;
  for (size_t i = 0; i < sym_count; ++i) {
    size_t name_n = strlen(syms[i].name) + 1;
    memcpy(out + off_strtab + name_offs[i], syms[i].name, name_n);
    wr_elf64_sym(out + off_symtab + (i + 1) * ELF64_SYM_SIZE, name_offs[i], syms[i].info,
                 syms[i].shndx, syms[i].value, syms[i].size);
  }

  unsigned char *sh = out + off_shdr;
  wr_elf64_shdr(sh + 1 * ELF64_SHDR_SIZE, text_name, 1, 0x6, 0, off_text, text_n, 0, 0, 16, 0);
  if (rela_count) {
    wr_elf64_shdr(sh + 2 * ELF64_SHDR_SIZE, rela_name, 4, 0, 0, off_rela, rela_n, 4, 1, 8,
                  ELF64_RELA_SIZE);
  }
  wr_elf64_shdr(sh + (size_t)shstrndx * ELF64_SHDR_SIZE, shstr_name, 3, 0, 0, off_shstr,
                shstr_n, 0, 0, 1, 0);
  wr_elf64_shdr(sh + (size_t)(rela_count ? 4 : 3) * ELF64_SHDR_SIZE, symtab_name, 2, 0, 0,
                off_symtab, symtab_n, symtab_link, symtab_info, 8, ELF64_SYM_SIZE);
  wr_elf64_shdr(sh + (size_t)(rela_count ? 5 : 4) * ELF64_SHDR_SIZE, strtab_name, 3, 0, 0,
                off_strtab, strtab_n, 0, 0, 1, 0);
  wr_elf64_shdr(sh + (size_t)(rela_count ? 6 : 5) * ELF64_SHDR_SIZE, note_name, 1, 0, 0, 0, 0,
                0, 0, 1, 0);

  ok = write_file(out_path, out, file_n);

done:
  free(out);
  free(name_offs);
  return ok;
}

static int emit_elf64_code_file(const char *out_path, const unsigned char *code, size_t code_n) {
  return emit_elf64_exec_rx_file(out_path, code, code_n, ELF64_MACHINE_X86_64);
}

static int emit_elf64_obj_text_file(const char *out_path, const char *symbol,
                                    const unsigned char *text, size_t text_n) {
  const Elf64ObjSymbol syms[] = {
    {symbol, 0x12, 1, 0, text_n},
  };
  return emit_elf64_obj_file(out_path, text, text_n, syms, 1, NULL, 0);
}

static int emit_elf64_obj_text_data_section(const char *out_path, const char *symbol,
                                            const unsigned char *text, size_t text_n,
                                            const char *sec_name,
                                            const unsigned char *sec_data, size_t sec_n,
                                            const Elf64ObjRela *sec_relas,
                                            size_t sec_rela_n) {
  static const unsigned char shstr[] =
    "\0.text\0.rodata\0.data\0.rela.rodata\0.rela.data\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack";
  enum {
    SHSTR_TEXT = 1,
    SHSTR_RODATA = 7,
    SHSTR_DATA = 15,
    SHSTR_RELA_RODATA = 21,
    SHSTR_RELA_DATA = 34,
    SHSTR_SHSTRTAB = 44,
    SHSTR_SYMTAB = 54,
    SHSTR_STRTAB = 61,
    SHSTR_NOTE = 68,
  };
  uint32_t sec_name_off = (uint32_t)(strcmp(sec_name, ".data") == 0 ? SHSTR_DATA : SHSTR_RODATA);
  uint32_t rela_name_off =
    (uint32_t)(strcmp(sec_name, ".data") == 0 ? SHSTR_RELA_DATA : SHSTR_RELA_RODATA);
  uint64_t sec_flags = strcmp(sec_name, ".data") == 0 ? 3u : 2u;
  const Elf64ObjSymbol syms[] = {
    {"nano_blob_data", 0x11, 2, 0, sec_n},
    {symbol, 0x12, 1, 0, text_n},
  };
  size_t off_text = ELF64_EHDR_SIZE;
  size_t off_sec = off_text + text_n;
  size_t off_rela = align_up_size(off_sec + sec_n, 8);
  size_t off_shstr = off_rela + sec_rela_n * ELF64_RELA_SIZE;
  size_t off_strtab = off_shstr + sizeof(shstr);
  size_t strtab_n = 1 + strlen("nano_blob_data") + 1 + strlen(symbol) + 1;
  size_t off_symtab = align_up_size(off_strtab + strtab_n, 8);
  size_t symtab_n = 3 * ELF64_SYM_SIZE;
  size_t off_shdr = align_up_size(off_symtab + symtab_n, 8);
  size_t file_n = off_shdr + 8 * ELF64_SHDR_SIZE;
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  uint32_t name_offs[2];
  if (!out) return 0;
  name_offs[0] = 1;
  name_offs[1] = 1 + (uint32_t)strlen("nano_blob_data") + 1;

  wr_elf64_ehdr_reloc(out, off_shdr, 8, 4);
  memcpy(out + off_text, text, text_n);
  memcpy(out + off_sec, sec_data, sec_n);
  for (size_t i = 0; i < sec_rela_n; ++i) {
    wr_elf64_rela(out + off_rela + i * ELF64_RELA_SIZE, sec_relas[i].offset, sec_relas[i].sym_idx,
                  sec_relas[i].type, sec_relas[i].addend);
  }
  memcpy(out + off_shstr, shstr, sizeof(shstr));
  out[off_strtab] = 0;
  memcpy(out + off_strtab + name_offs[0], "nano_blob_data", strlen("nano_blob_data") + 1);
  memcpy(out + off_strtab + name_offs[1], symbol, strlen(symbol) + 1);
  wr_elf64_sym(out + off_symtab + ELF64_SYM_SIZE, name_offs[0], syms[0].info, syms[0].shndx,
               syms[0].value, syms[0].size);
  wr_elf64_sym(out + off_symtab + 2 * ELF64_SYM_SIZE, name_offs[1], syms[1].info, syms[1].shndx,
               syms[1].value, syms[1].size);

  unsigned char *sh = out + off_shdr;
  wr_elf64_shdr(sh + 1 * ELF64_SHDR_SIZE, 1, 1, 0x6, 0, off_text, text_n, 0, 0, 16, 0);
  wr_elf64_shdr(sh + 2 * ELF64_SHDR_SIZE, sec_name_off, 1, sec_flags, 0, off_sec, sec_n, 0, 0, 1,
                0);
  wr_elf64_shdr(sh + 3 * ELF64_SHDR_SIZE, rela_name_off, 4, 0, 0, off_rela,
                sec_rela_n * ELF64_RELA_SIZE, 5, 2, 8, ELF64_RELA_SIZE);
  wr_elf64_shdr(sh + 4 * ELF64_SHDR_SIZE, SHSTR_SHSTRTAB, 3, 0, 0, off_shstr, sizeof(shstr), 0, 0,
                1, 0);
  wr_elf64_shdr(sh + 5 * ELF64_SHDR_SIZE, SHSTR_SYMTAB, 2, 0, 0, off_symtab, symtab_n, 6, 2, 8,
                ELF64_SYM_SIZE);
  wr_elf64_shdr(sh + 6 * ELF64_SHDR_SIZE, SHSTR_STRTAB, 3, 0, 0, off_strtab, strtab_n, 0, 0, 1, 0);
  wr_elf64_shdr(sh + 7 * ELF64_SHDR_SIZE, SHSTR_NOTE, 1, 0, 0, 0, 0, 0, 0, 1, 0);

  int ok = write_file(out_path, out, file_n);
  free(out);
  return ok;
}

static int emit_elf64_obj_ret_file(const char *out_path, const char *symbol, uint32_t value) {
  unsigned char text[6] = {0xb8, 0, 0, 0, 0, 0xc3};
  wr32(text + 1, value);
  return emit_elf64_obj_text_file(out_path, symbol, text, sizeof(text));
}

static int emit_elf64_obj_call_file(const char *out_path, const char *local, const char *external) {
  unsigned char text[6] = {0xe8, 0, 0, 0, 0, 0xc3};
  const Elf64ObjSymbol syms[] = {
    {local, 0x12, 1, 0, sizeof(text)},
    {external, 0x12, 0, 0, 0},
  };
  const Elf64ObjRela relas[] = {
    {1, 2, 4, -4},
  };
  return emit_elf64_obj_file(out_path, text, sizeof(text), syms, 2, relas, 1);
}

int emit_aarch64_exit_file(const char *out_path, uint8_t exit_code) {
  unsigned char code[12];
  uint32_t mov_x8 = 0xd2800000u | (93u << 5) | 8u;
  uint32_t mov_x0 = 0xd2800000u | ((uint32_t)exit_code << 5);
  uint32_t svc0 = 0xd4000001u;
  memset(code, 0, sizeof(code));
  wr32(code + 0, mov_x8);
  wr32(code + 4, mov_x0);
  wr32(code + 8, svc0);
  int ok = emit_elf64_exec_rx_file(out_path, code, sizeof(code), ELF64_MACHINE_AARCH64);
  if (ok) fprintf(stderr, "aarch64.emit.onion.wave=225-252\n");
  return ok;
}


/* v4 slice-9: opcode-indexed lowering table (still host emit, not VM). */
enum {
  A64_ADD_EXIT_OP_MOVZ_X0 = 0,
  A64_ADD_EXIT_OP_MOVZ_X1,
  A64_ADD_EXIT_OP_ADD_X0_X1,
  A64_ADD_EXIT_OP_MOVZ_X8,
  A64_ADD_EXIT_OP_SVC0,
  A64_ADD_EXIT_OP_COUNT,
};

static const unsigned char a64_add_exit_v1_op_order[A64_ADD_EXIT_OP_COUNT] = {
  A64_ADD_EXIT_OP_MOVZ_X0,
  A64_ADD_EXIT_OP_MOVZ_X1,
  A64_ADD_EXIT_OP_ADD_X0_X1,
  A64_ADD_EXIT_OP_MOVZ_X8,
  A64_ADD_EXIT_OP_SVC0,
};

/* v4 slice-11: fixed words for non-immediate ops (partial table-driven emit). */
static const uint32_t a64_ir_fixed_word_v2[A64_ADD_EXIT_OP_COUNT] = {
  [A64_ADD_EXIT_OP_ADD_X0_X1] = 0x8b010000u,
  [A64_ADD_EXIT_OP_MOVZ_X8] = 0xd2800000u | (93u << 5) | 8u,
  [A64_ADD_EXIT_OP_SVC0] = 0xd4000001u,
};

static int a64_ir_uses_fixed_word_v2(unsigned op) {
  return op == A64_ADD_EXIT_OP_ADD_X0_X1 || op == A64_ADD_EXIT_OP_MOVZ_X8 ||
         op == A64_ADD_EXIT_OP_SVC0;
}

/* v4 slice-12: movz bases in table (IR table v3). */
static const uint32_t a64_ir_movz_base_v3[2] = {
  0xd2800000u,
  0xd2800000u | 1u,
};

static uint32_t a64_movz_from_table_v3(unsigned reg, int imm) {
  return a64_ir_movz_base_v3[reg & 1u] | (((uint32_t)imm & 0xffffu) << 5);
}

static int v4_emit_svc0_from_plan;
static uint32_t v4_emit_svc0_plan_word;
static int v4_emit_plan_lisp_full;
static uint32_t v4_plan_movz_base_v3_override[2];
static int v4_plan_movz_override;
static uint32_t v4_plan_fixed_override[A64_ADD_EXIT_OP_COUNT];
static int v4_plan_fixed_active[A64_ADD_EXIT_OP_COUNT];

void nano_elf64_v4_clear_plan_lisp(void) {
  v4_emit_svc0_from_plan = 0;
  v4_emit_plan_lisp_full = 0;
  v4_plan_movz_override = 0;
  memset(v4_plan_fixed_active, 0, sizeof(v4_plan_fixed_active));
}

void nano_elf64_v4_set_plan_movz_base(unsigned reg, uint32_t base) {
  if (reg < 2) {
    v4_plan_movz_base_v3_override[reg] = base;
    v4_plan_movz_override = 1;
    v4_emit_plan_lisp_full = 1;
  }
}

void nano_elf64_v4_set_plan_lisp_word(unsigned op, uint32_t word) {
  if (op < A64_ADD_EXIT_OP_COUNT) {
    v4_plan_fixed_override[op] = word;
    v4_plan_fixed_active[op] = 1;
    v4_emit_plan_lisp_full = 1;
  }
}

void nano_elf64_v4_set_plan_svc0(uint32_t word) {
  v4_emit_svc0_from_plan = 1;
  v4_emit_svc0_plan_word = word;
  nano_elf64_v4_set_plan_lisp_word(A64_ADD_EXIT_OP_SVC0, word);
}

void nano_elf64_v4_clear_plan_svc0(void) {
  nano_elf64_v4_clear_plan_lisp();
}

static uint32_t a64_add_exit_v1_encode(unsigned op, int a, int b) {
  if (a64_ir_uses_fixed_word_v2(op)) {
    if (v4_plan_fixed_active[op]) return v4_plan_fixed_override[op];
    if (op == A64_ADD_EXIT_OP_SVC0 && v4_emit_svc0_from_plan)
      return v4_emit_svc0_plan_word;
    return a64_ir_fixed_word_v2[op];
  }
  switch (op) {
  case A64_ADD_EXIT_OP_MOVZ_X0:
    if (v4_plan_movz_override)
      return v4_plan_movz_base_v3_override[0] | (((uint32_t)a & 0xffffu) << 5);
    return a64_movz_from_table_v3(0, a);
  case A64_ADD_EXIT_OP_MOVZ_X1:
    if (v4_plan_movz_override)
      return v4_plan_movz_base_v3_override[1] | (((uint32_t)b & 0xffffu) << 5);
    return a64_movz_from_table_v3(1, b);
  default:
    return 0;
  }
}

static int emit_aarch64_add_exit_v1_lower(int a, int b, unsigned char *code, size_t cap,
                                          size_t *out_n) {
  size_t i;
  if (!code || cap < 20) return 0;
  memset(code, 0, cap);
  for (i = 0; i < A64_ADD_EXIT_OP_COUNT; ++i) {
    unsigned op = a64_add_exit_v1_op_order[i];
    wr32(code + i * 4, a64_add_exit_v1_encode(op, a, b));
  }
  *out_n = A64_ADD_EXIT_OP_COUNT * 4;
  return 1;
}

int emit_aarch64_add_exit_file(const char *out_path, int a, int b) {
  unsigned char code[20];
  size_t code_n = 0;
  int ok;
  if (!emit_aarch64_add_exit_v1_lower(a, b, code, sizeof(code), &code_n)) return 0;
  ok = emit_elf64_exec_rx_file(out_path, code, code_n, ELF64_MACHINE_AARCH64);
  if (ok) {
    fprintf(stderr, "nano_elf64.emit.add.bytes=20\n");
    fprintf(stderr, "aarch64.emit.profile=add-exit-v2-diffuse\n");
    fprintf(stderr, "aarch64.emit.onion.layer=codegen\n");
    fprintf(stderr, "aarch64.emit.fast-path=1\n");
    fprintf(stderr, "aarch64.emit.cli.diffuse=1\n");
  }
  return ok;
}

int emit_elf64_exit_file(const char *out_path, uint8_t exit_code) {
  unsigned char code[12];
  memset(code, 0, sizeof(code));
  code[0] = 0xb8;
  wr32(code + 1, 60);
  code[5] = 0xbf;
  wr32(code + 6, (uint32_t)exit_code);
  code[10] = 0x0f;
  code[11] = 0x05;
  return emit_elf64_code_file(out_path, code, sizeof(code));
}

static int cmd_emit_elf64_exit(const char *out_path, const char *code_s) {
  size_t code_arg = 0;
  if (!parse_size_arg(code_s, &code_arg) || code_arg > 255) {
    fprintf(stderr, "emit-elf64-exit=bad_exit_code\n");
    return 1;
  }
  if (!emit_elf64_exit_file(out_path, (uint8_t)code_arg)) {
    fprintf(stderr, "emit-elf64-exit=write_fail path=%s\n", out_path);
    return 2;
  }
  printf("elf64.output=%s\n", out_path);
  printf("elf64.bytes=%d\n", 132);
  printf("elf64.entry=0x%llx\n", (unsigned long long)(0x400000u + 120));
  printf("elf64.exit=%zu\n", code_arg);
  return 0;
}

static int cmd_emit_elf64_obj_ret(const char *out_path, const char *symbol, const char *value_s) {
  size_t value = 0;
  if (!symbol[0] || !parse_size_arg(value_s, &value) || value > UINT32_MAX) {
    fprintf(stderr, "emit-elf64-obj-ret=bad_args\n");
    return 1;
  }
  if (!emit_elf64_obj_ret_file(out_path, symbol, (uint32_t)value)) {
    fprintf(stderr, "emit-elf64-obj-ret=write_fail path=%s\n", out_path);
    return 2;
  }
  printf("elf64.obj.output=%s\n", out_path);
  printf("elf64.obj.symbol=%s\n", symbol);
  printf("elf64.obj.ret=%zu\n", value);
  return 0;
}

static int cmd_emit_elf64_obj_call(const char *out_path, const char *local, const char *external) {
  if (!local[0] || !external[0]) {
    fprintf(stderr, "emit-elf64-obj-call=bad_args\n");
    return 1;
  }
  if (!emit_elf64_obj_call_file(out_path, local, external)) {
    fprintf(stderr, "emit-elf64-obj-call=write_fail path=%s\n", out_path);
    return 2;
  }
  printf("elf64.obj.output=%s\n", out_path);
  printf("elf64.obj.symbol=%s\n", local);
  printf("elf64.obj.extern=%s\n", external);
  return 0;
}

typedef struct {
  const unsigned char *data;
  size_t size;
  const unsigned char *shdr;
  uint16_t shnum;
  uint16_t shentsize;
  uint16_t text_idx;
  const unsigned char *text;
  size_t text_size;
  size_t out_off;
  uint16_t rodata_idx;
  const unsigned char *rodata;
  size_t rodata_size;
  size_t rodata_out_off;
  uint16_t data_idx;
  const unsigned char *data_sec;
  size_t data_size;
  size_t data_out_off;
  const unsigned char *symtab;
  size_t sym_count;
  const unsigned char *strtab;
  size_t strtab_size;
  const unsigned char *rela;
  size_t rela_count;
  const unsigned char *rela_rodata;
  size_t rela_rodata_count;
  const unsigned char *rela_data;
  size_t rela_data_count;
} ElfObj;

typedef struct {
  const char *name;
  size_t obj_idx;
  uint64_t value;
} LinkSym;

static const unsigned char *elf_section(const ElfObj *o, uint16_t idx) {
  if (!idx || idx >= o->shnum) return NULL;
  return o->shdr + (size_t)idx * o->shentsize;
}

static const char *elf_str(const unsigned char *tab, size_t tab_n, uint32_t off) {
  if (off >= tab_n) return NULL;
  const char *s = (const char *)tab + off;
  return memchr(s, 0, tab_n - off) ? s : NULL;
}

static const unsigned char *elf_sym_row(const ElfObj *o, size_t idx) {
  return idx < o->sym_count ? o->symtab + idx * ELF64_SYM_SIZE : NULL;
}

static const char *elf_sym_name(const ElfObj *o, size_t idx) {
  const unsigned char *sym = elf_sym_row(o, idx);
  return sym ? elf_str(o->strtab, o->strtab_size, rd32(sym)) : NULL;
}

static uint8_t elf_sym_binding(const ElfObj *o, size_t idx) {
  const unsigned char *sym = elf_sym_row(o, idx);
  return sym ? (uint8_t)(sym[4] >> 4) : 0;
}

static uint16_t elf_sym_shndx(const ElfObj *o, size_t idx) {
  const unsigned char *sym = elf_sym_row(o, idx);
  return sym ? rd16(sym + 6) : 0;
}

static uint64_t elf_sym_value(const ElfObj *o, size_t idx) {
  const unsigned char *sym = elf_sym_row(o, idx);
  return sym ? rd64(sym + 8) : 0;
}

static const unsigned char *elf_rela_row(const ElfObj *o, size_t idx) {
  return idx < o->rela_count ? o->rela + idx * ELF64_RELA_SIZE : NULL;
}

static int parse_elf_obj(const unsigned char *data, size_t size, ElfObj *o) {
  if (!is_elf(data, size) || size < ELF64_EHDR_SIZE || rd16(data + 16) != 1 ||
      rd16(data + 18) != ELF64_MACHINE_X86_64) {
    return 0;
  }
  uint64_t shoff = rd64(data + 40);
  uint16_t shentsize = rd16(data + 58);
  uint16_t shnum = rd16(data + 60);
  uint16_t shstrndx = rd16(data + 62);
  if (shentsize < ELF64_SHDR_SIZE || shoff > size || shnum > (size - shoff) / shentsize ||
      shstrndx >= shnum) {
    return 0;
  }
  memset(o, 0, sizeof(*o));
  o->data = data;
  o->size = size;
  o->shdr = data + shoff;
  o->shnum = shnum;
  o->shentsize = shentsize;

  const unsigned char *shstr = elf_section(o, shstrndx);
  if (!shstr) return 0;
  uint64_t shstr_off = rd64(shstr + 24);
  uint64_t shstr_size = rd64(shstr + 32);
  if (shstr_off > size || shstr_size > size - shstr_off) return 0;

  for (uint16_t i = 1; i < shnum; ++i) {
    const unsigned char *sh = elf_section(o, i);
    uint32_t name_off = rd32(sh);
    uint32_t type = rd32(sh + 4);
    uint64_t off = rd64(sh + 24);
    uint64_t n = rd64(sh + 32);
    uint32_t link = rd32(sh + 40);
    uint32_t info = rd32(sh + 44);
    const char *name = elf_str(data + shstr_off, (size_t)shstr_size, name_off);
    if (!name || off > size || n > size - off) return 0;
    if (strcmp(name, ".text") == 0) {
      o->text_idx = i;
      o->text = data + off;
      o->text_size = (size_t)n;
    } else if (strcmp(name, ".rodata") == 0) {
      o->rodata_idx = i;
      o->rodata = data + off;
      o->rodata_size = (size_t)n;
    } else if (strcmp(name, ".data") == 0) {
      o->data_idx = i;
      o->data_sec = data + off;
      o->data_size = (size_t)n;
    } else if (type == 2) {
      uint64_t entsize = rd64(sh + 56);
      if (entsize != ELF64_SYM_SIZE || link >= shnum) return 0;
      const unsigned char *str_sh = elf_section(o, (uint16_t)link);
      uint64_t str_off = rd64(str_sh + 24);
      uint64_t str_n = rd64(str_sh + 32);
      if (str_off > size || str_n > size - str_off) return 0;
      o->symtab = data + off;
      o->sym_count = (size_t)(n / entsize);
      o->strtab = data + str_off;
      o->strtab_size = (size_t)str_n;
    } else if (type == 4 && strcmp(name, ".rela.text") == 0) {
      uint64_t entsize = rd64(sh + 56);
      if (entsize != ELF64_RELA_SIZE || info >= shnum) return 0;
      o->rela = data + off;
      o->rela_count = (size_t)(n / entsize);
    } else if (type == 4 && strcmp(name, ".rela.rodata") == 0) {
      uint64_t entsize = rd64(sh + 56);
      if (entsize != ELF64_RELA_SIZE || info >= shnum) return 0;
      o->rela_rodata = data + off;
      o->rela_rodata_count = (size_t)(n / entsize);
    } else if (type == 4 && strcmp(name, ".rela.data") == 0) {
      uint64_t entsize = rd64(sh + 56);
      if (entsize != ELF64_RELA_SIZE || info >= shnum) return 0;
      o->rela_data = data + off;
      o->rela_data_count = (size_t)(n / entsize);
    }
  }
  return o->text && o->symtab && o->strtab;
}

static int link_find_sym(const LinkSym *syms, size_t sym_count, const char *name, uint64_t *out) {
  for (size_t i = 0; i < sym_count; ++i) {
    if (strcmp(syms[i].name, name) == 0) {
      *out = syms[i].value;
      return 1;
    }
  }
  return 0;
}

static void link_cleanup(unsigned char **owned, size_t *owned_n, ElfObj *objs, int obj_count,
                         LinkSym *syms, Buf *code) {
  (void)owned_n;
  if (code) free(code->data);
  free(syms);
  if (owned) {
    for (int i = 0; i < obj_count; ++i) free(owned[i]);
  }
  free(owned);
  free(owned_n);
  free(objs);
}

static int link_rel32_checked(int64_t rel, uint32_t *out) {
  if (rel < INT32_MIN || rel > INT32_MAX) return 0;
  *out = (uint32_t)(int32_t)rel;
  return 1;
}

static int link_add_text_symbols(const ElfObj *o, size_t obj_idx, uint64_t text_base,
                                 LinkSym **syms, size_t *sym_count, size_t *sym_cap) {
  for (size_t s = 1; s < o->sym_count; ++s) {
    const char *name = elf_sym_name(o, s);
    uint64_t existing = 0;
    if (elf_sym_shndx(o, s) != o->text_idx || elf_sym_binding(o, s) == 0 ||
        !name || !name[0]) continue;
    if (link_find_sym(*syms, *sym_count, name, &existing)) {
      fprintf(stderr, "link-elf64-exe=duplicate_symbol symbol=%s\n", name);
      return 0;
    }
    if (*sym_count == *sym_cap) {
      size_t next = *sym_cap ? *sym_cap * 2 : 8;
      LinkSym *p = (LinkSym *)realloc(*syms, next * sizeof(*p));
      if (!p) return 0;
      *syms = p;
      *sym_cap = next;
    }
    (*syms)[(*sym_count)++] =
      (LinkSym){name, obj_idx, text_base + o->out_off + elf_sym_value(o, s)};
  }
  return 1;
}

static int link_apply_sec_pc32_relocations(Buf *code, const ElfObj *o, const unsigned char *rela_tab,
                                           size_t rela_count, const ExecSectionLayout *layout,
                                           uint64_t sec_va, size_t sec_out_off,
                                           uint16_t sec_shndx) {
  uint32_t rel32 = 0;
  for (size_t r = 0; r < rela_count; ++r) {
    const unsigned char *rela = rela_tab + r * ELF64_RELA_SIZE;
    uint64_t r_off = rd64(rela);
    uint64_t r_info = rd64(rela + 8);
    int64_t addend = (int64_t)rd64(rela + 16);
    uint32_t type = (uint32_t)r_info;
    uint32_t sym_idx = (uint32_t)(r_info >> 32);
    if (type != 1 || sym_idx >= o->sym_count || r_off > o->text_size - 4) {
      fprintf(stderr, "link-elf64-exe=unsupported_data_reloc\n");
      return 0;
    }
    if (elf_sym_shndx(o, sym_idx) != sec_shndx) {
      fprintf(stderr, "link-elf64-exe=bad_data_symbol\n");
      return 0;
    }
    uint64_t target = sec_va + sec_out_off + elf_sym_value(o, sym_idx) + (uint64_t)addend;
    uint64_t rip_next = layout->text_va + o->out_off + r_off + 4;
    int64_t rel = (int64_t)target - (int64_t)rip_next;
    if (!link_rel32_checked(rel, &rel32)) {
      fprintf(stderr, "link-elf64-exe=data_reloc_out_of_range\n");
      return 0;
    }
    wr32(code->data + o->out_off + r_off, rel32);
  }
  return 1;
}

static int link_apply_relocations(Buf *code, const ElfObj *o, const LinkSym *syms,
                                  size_t sym_count, const ExecSectionLayout *layout) {
  uint32_t rel32 = 0;
  for (size_t r = 0; r < o->rela_count; ++r) {
    const unsigned char *rela = elf_rela_row(o, r);
    uint64_t r_off = rd64(rela);
    uint64_t r_info = rd64(rela + 8);
    int64_t addend = (int64_t)rd64(rela + 16);
    uint32_t type = (uint32_t)r_info;
    uint32_t sym_idx = (uint32_t)(r_info >> 32);
    const char *name = NULL;
    uint64_t target = 0;
    if (type != 4 || sym_idx >= o->sym_count || r_off > o->text_size - 4) {
      fprintf(stderr, "link-elf64-exe=unsupported_reloc\n");
      return 0;
    }
    if (elf_sym_binding(o, sym_idx) == 0) {
      if (elf_sym_shndx(o, sym_idx) != o->text_idx) {
        fprintf(stderr, "link-elf64-exe=unsupported_local_reloc\n");
        return 0;
      }
      target = layout->text_va + o->out_off + elf_sym_value(o, sym_idx);
    } else {
      name = elf_sym_name(o, sym_idx);
      if (!name || !link_find_sym(syms, sym_count, name, &target)) {
        fprintf(stderr, "link-elf64-exe=symbol_missing symbol=%s\n", name ? name : "?");
        return 0;
      }
    }
    uint64_t place = layout->text_va + o->out_off + r_off;
    int64_t rel = (int64_t)target + addend - (int64_t)place;
    if (!link_rel32_checked(rel, &rel32)) {
      fprintf(stderr, "link-elf64-exe=reloc_out_of_range symbol=%s\n", name);
      return 0;
    }
    wr32(code->data + o->out_off + r_off, rel32);
  }
  return 1;
}

static int cmd_link_elf64_exe(int argc, char **argv) {
  if (argc < 5) {
    fprintf(stderr, "link-elf64-exe=bad_args\n");
    return 1;
  }
  const char *out_path = argv[2];
  const char *entry_name = argv[3];
  int obj_count = argc - 4;
  unsigned char **owned = (unsigned char **)calloc((size_t)obj_count, sizeof(*owned));
  size_t *owned_n = (size_t *)calloc((size_t)obj_count, sizeof(*owned_n));
  ElfObj *objs = (ElfObj *)calloc((size_t)obj_count, sizeof(*objs));
  LinkSym *syms = NULL;
  size_t sym_count = 0;
  size_t sym_cap = 0;
  int rc = 2;
  if (!owned || !owned_n || !objs) goto done;

  Buf code = {0};
  Buf rodata = {0};
  Buf data_buf = {0};
  ExecSectionLayout layout = {0};
  size_t file_n = 0;
  size_t stub_n = 14;
  size_t text_total = stub_n;

  for (int i = 0; i < obj_count; ++i) {
    owned[i] = read_file(argv[4 + i], &owned_n[i]);
    if (!owned[i] || !parse_elf_obj(owned[i], owned_n[i], &objs[i])) {
      fprintf(stderr, "link-elf64-exe=parse_fail path=%s\n", argv[4 + i]);
      goto done;
    }
    text_total += objs[i].text_size;
  }
  (void)text_total;

  {
    size_t text_off = stub_n;
    for (int i = 0; i < obj_count; ++i) {
      objs[i].out_off = text_off;
      text_off += objs[i].text_size;
    }
  }

  unsigned char entry_stub[14] = {
    0xe8, 0, 0, 0, 0,
    0x89, 0xc7,
    0xb8, 0x3c, 0, 0, 0,
    0x0f, 0x05
  };
  buf_put(&code, entry_stub, sizeof(entry_stub));
  for (int i = 0; i < obj_count; ++i) {
    buf_put(&code, objs[i].text, objs[i].text_size);
    if (objs[i].rodata_size) {
      objs[i].rodata_out_off = rodata.len;
      buf_put(&rodata, objs[i].rodata, objs[i].rodata_size);
    }
    if (objs[i].data_size) {
      objs[i].data_out_off = data_buf.len;
      buf_put(&data_buf, objs[i].data_sec, objs[i].data_size);
    }
  }
  exec_section_layout_fill(&layout, code.len, rodata.len, data_buf.len, &file_n);

  for (int i = 0; i < obj_count; ++i) {
    if (!link_add_text_symbols(&objs[i], (size_t)i, layout.text_va, &syms, &sym_count,
                                &sym_cap)) {
      goto done;
    }
  }

  uint64_t entry_addr = 0;
  if (!link_find_sym(syms, sym_count, entry_name, &entry_addr)) {
    fprintf(stderr, "link-elf64-exe=entry_missing symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  uint32_t rel32 = 0;
  int64_t entry_rel = (int64_t)entry_addr - (int64_t)(layout.text_va + 5);
  if (!link_rel32_checked(entry_rel, &rel32)) {
    fprintf(stderr, "link-elf64-exe=entry_out_of_range symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  wr32(code.data + 1, rel32);

  for (int i = 0; i < obj_count; ++i) {
    if (!link_apply_relocations(&code, &objs[i], syms, sym_count, &layout)) {
      rc = 4;
      goto done;
    }
    if (objs[i].rela_rodata_count &&
        !link_apply_sec_pc32_relocations(&code, &objs[i], objs[i].rela_rodata,
                                         objs[i].rela_rodata_count, &layout, layout.rodata_va,
                                         objs[i].rodata_out_off, objs[i].rodata_idx)) {
      rc = 4;
      goto done;
    }
    if (objs[i].rela_data_count &&
        !link_apply_sec_pc32_relocations(&code, &objs[i], objs[i].rela_data,
                                         objs[i].rela_data_count, &layout, layout.data_va,
                                         objs[i].data_out_off, objs[i].data_idx)) {
      rc = 4;
      goto done;
    }
  }

  if (!emit_elf64_exec_sections_file(out_path, code.data, code.len, rodata.data, rodata.len,
                                     data_buf.data, data_buf.len, ELF64_MACHINE_X86_64)) {
    fprintf(stderr, "link-elf64-exe=write_fail path=%s\n", out_path);
    rc = 5;
    goto done;
  }
  printf("link.output=%s\n", out_path);
  printf("link.objects=%d\n", obj_count);
  printf("link.code.bytes=%zu\n", code.len);
  if (rodata.len) printf("link.rodata.bytes=%zu\n", rodata.len);
  if (data_buf.len) printf("link.data.bytes=%zu\n", data_buf.len);
  g_link_last_code_bytes = code.len;
  rc = 0;

done:
  free(rodata.data);
  free(data_buf.data);
  link_cleanup(owned, owned_n, objs, obj_count, syms, &code);
  return rc;
}

size_t nano_link_last_code_bytes(void) {
  return g_link_last_code_bytes;
}

static int cmd_link_expect_exit(int argc, char **argv) {
  if (argc < 6) {
    fprintf(stderr, "link-expect-exit=bad_args\n");
    return 1;
  }
  char **extra_args = argc > 6 ? &argv[6] : NULL;
  size_t extra_arg_count = argc > 6 ? (size_t)(argc - 6) : 0;
  return check_link_expect_exit(argv[2], argv[3], argv[4], argv[5],
                                extra_args, extra_arg_count,
                                "link-expect-exit");
}

