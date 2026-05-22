/* Included from lispjit.c — lbin/ljir parser + compile to blob. */
static void skip_ws(const char **p) {
  for (;;) {
    while (**p == ' ' || **p == '\t' || **p == '\r' || **p == '\n') (*p)++;
    if (**p == ';') {
      while (**p && **p != '\n') (*p)++;
      continue;
    }
    return;
  }
}

static int eat(const char **p, char c) {
  skip_ws(p);
  if (**p != c) return 0;
  (*p)++;
  return 1;
}

static char *parse_atom(const char **p) {
  skip_ws(p);
  const char *s = *p;
  if (!*s || *s == '(' || *s == ')' || *s == '"' || *s == ';') return NULL;
  while (**p && **p != '(' && **p != ')' && **p != '"' &&
         **p != ';' && **p != ' ' && **p != '\t' &&
         **p != '\r' && **p != '\n') {
    (*p)++;
  }
  size_t n = (size_t)(*p - s);
  char *out = (char *)malloc(n + 1);
  if (!out) return NULL;
  memcpy(out, s, n);
  out[n] = 0;
  return out;
}

static char *parse_string(const char **p) {
  skip_ws(p);
  if (**p != '"') return NULL;
  (*p)++;
  Buf b = {0};
  while (**p && **p != '"') {
    unsigned char c = (unsigned char)*(*p)++;
    if (c == '\\' && **p) {
      c = (unsigned char)*(*p)++;
      if (c == 'n') c = '\n';
      else if (c == 't') c = '\t';
    }
    buf_put(&b, &c, 1);
  }
  if (**p != '"') {
    free(b.data);
    return NULL;
  }
  (*p)++;
  unsigned char z = 0;
  buf_put(&b, &z, 1);
  return (char *)b.data;
}

static void module_free(Module *m) {
  for (size_t i = 0; i < m->import_count; ++i) {
    free(m->imports[i].name);
    free(m->imports[i].lib);
    free(m->imports[i].symbol);
  }
  for (size_t i = 0; i < m->const_count; ++i) {
    free(m->consts[i].name);
    free(m->consts[i].value);
  }
  for (size_t i = 0; i < m->instr_count; ++i) {
    free(m->instrs[i].import_name);
    free(m->instrs[i].const_name);
    free(m->instrs[i].const2_name);
  }
  free(m->imports);
  free(m->consts);
  free(m->instrs);
}

static void aot_module_free(AotModule *m) {
  for (size_t i = 0; i < m->func_count; ++i) {
    free(m->funcs[i].name);
    for (size_t j = 0; j < m->funcs[i].stmt_count; ++j) {
      free(m->funcs[i].stmts[j].target_name);
    }
    free(m->funcs[i].stmts);
  }
  free(m->funcs);
}

static void bootstrap_plan_free(BootstrapPlan *plan) {
  for (size_t i = 0; i < plan->step_count; ++i) {
    free(plan->steps[i].arg0);
    free(plan->steps[i].arg1);
    free(plan->steps[i].arg2);
    free(plan->steps[i].arg3);
    for (size_t j = 0; j < plan->steps[i].extra_arg_count; ++j) {
      free(plan->steps[i].extra_args[j]);
    }
    free(plan->steps[i].extra_args);
  }
  free(plan->steps);
}

static int add_import(Module *m, char *name, char *lib, char *symbol, char *sig) {
  uint32_t sig_id = parse_sig_id(sig);
  if (sig_id == UINT32_MAX) {
    fprintf(stderr, "unsupported.signature=%s\n", sig);
    return 0;
  }
  if (m->import_count == m->import_cap) {
    size_t next = m->import_cap ? m->import_cap * 2 : 4;
    ImportDef *p = (ImportDef *)realloc(m->imports, next * sizeof(*p));
    if (!p) return 0;
    m->imports = p;
    m->import_cap = next;
  }
  m->imports[m->import_count++] = (ImportDef){name, lib, symbol, sig_id};
  free(sig);
  return 1;
}

static int add_const(Module *m, char *name, char *value) {
  if (m->const_count == m->const_cap) {
    size_t next = m->const_cap ? m->const_cap * 2 : 4;
    ConstDef *p = (ConstDef *)realloc(m->consts, next * sizeof(*p));
    if (!p) return 0;
    m->consts = p;
    m->const_cap = next;
  }
  m->consts[m->const_count++] = (ConstDef){name, value};
  return 1;
}

static int add_instr(Module *m, uint32_t form, char *import_name, char *const_name,
                     char *const2_name, uint64_t imm) {
  if (m->instr_count == m->instr_cap) {
    size_t next = m->instr_cap ? m->instr_cap * 2 : 4;
    InstrDef *p = (InstrDef *)realloc(m->instrs, next * sizeof(*p));
    if (!p) return 0;
    m->instrs = p;
    m->instr_cap = next;
  }
  m->instrs[m->instr_count++] = (InstrDef){form, import_name, const_name, const2_name, imm};
  return 1;
}

static AotFunc *aot_add_func(AotModule *m, char *name, int is_global) {
  if (m->func_count == m->func_cap) {
    size_t next = m->func_cap ? m->func_cap * 2 : 4;
    AotFunc *p = (AotFunc *)realloc(m->funcs, next * sizeof(*p));
    if (!p) return NULL;
    m->funcs = p;
    m->func_cap = next;
  }
  m->funcs[m->func_count] = (AotFunc){name, is_global, NULL, 0, 0};
  return &m->funcs[m->func_count++];
}

static int aot_add_stmt(AotFunc *f, uint32_t kind, uint64_t imm, char *target_name) {
  if (f->stmt_count == f->stmt_cap) {
    size_t next = f->stmt_cap ? f->stmt_cap * 2 : 8;
    AotStmt *p = (AotStmt *)realloc(f->stmts, next * sizeof(*p));
    if (!p) return 0;
    f->stmts = p;
    f->stmt_cap = next;
  }
  f->stmts[f->stmt_count++] = (AotStmt){kind, imm, target_name};
  return 1;
}

static int bootstrap_add_step(BootstrapPlan *plan, uint32_t kind, char *arg0, char *arg1,
                              char *arg2, char *arg3) {
  if (plan->step_count == plan->step_cap) {
    size_t next = plan->step_cap ? plan->step_cap * 2 : 4;
    BootstrapStep *p = (BootstrapStep *)realloc(plan->steps, next * sizeof(*p));
    if (!p) return 0;
    plan->steps = p;
    plan->step_cap = next;
  }
  plan->steps[plan->step_count++] = (BootstrapStep){kind, arg0, arg1, arg2, arg3};
  return 1;
}

static int bootstrap_add_step_extra(BootstrapPlan *plan, uint32_t kind, char *arg0, char *arg1,
                                    char *arg2, char *arg3, char **extra_args,
                                    size_t extra_arg_count) {
  if (!bootstrap_add_step(plan, kind, arg0, arg1, arg2, arg3)) return 0;
  BootstrapStep *step = &plan->steps[plan->step_count - 1];
  step->extra_args = extra_args;
  step->extra_arg_count = extra_arg_count;
  return 1;
}

static void bootstrap_free_string_array(char **args, size_t count) {
  for (size_t i = 0; i < count; ++i) free(args[i]);
  free(args);
}

static int bootstrap_push_string_arg(char ***args, size_t *count, size_t *cap, char *arg) {
  if (*count == *cap) {
    size_t next = *cap ? *cap * 2 : 4;
    char **p = (char **)realloc(*args, next * sizeof(*p));
    if (!p) return 0;
    *args = p;
    *cap = next;
  }
  (*args)[(*count)++] = arg;
  return 1;
}

static int parse_u64_atom(const char *s, uint64_t *out) {
  char *end = NULL;
  unsigned long long v = strtoull(s, &end, 10);
  if (!s || !s[0] || !end || *end) return 0;
  *out = (uint64_t)v;
  return (unsigned long long)*out == v;
}

static int parse_i64_atom(const char *s, int64_t *out) {
  char *end = NULL;
  long long v = strtoll(s, &end, 10);
  if (!s || !s[0] || !end || *end) return 0;
  *out = (int64_t)v;
  return 1;
}

static int parse_i32_atom(const char *s, int32_t *out) {
  char *end = NULL;
  long v = strtol(s, &end, 10);
  if (!s || !s[0] || !end || *end || v < INT32_MIN || v > INT32_MAX) return 0;
  *out = (int32_t)v;
  return 1;
}

static int parse_bool_atom(const char *s, int *out) {
  if (strcmp(s, "true") == 0) {
    *out = 1;
    return 1;
  }
  if (strcmp(s, "false") == 0) {
    *out = 0;
    return 1;
  }
  return 0;
}

static int parse_expect_ptr_atom(const char *s, int *out) {
  if (strcmp(s, "nonnull") == 0) {
    *out = 1;
    return 1;
  }
  if (strcmp(s, "null") == 0) {
    *out = 0;
    return 1;
  }
  return 0;
}

static int aot_find_func(const AotModule *m, const char *name) {
  for (size_t i = 0; i < m->func_count; ++i) {
    if (strcmp(m->funcs[i].name, name) == 0) return (int)i;
  }
  return -1;
}



static int parse_import_form(const char **p, Module *m) {
  char *name = parse_atom(p);
  char *lib = parse_string(p);
  char *symbol = parse_string(p);
  char *sig = parse_string(p);
  if (!name || !lib || !symbol || !sig || !eat(p, ')')) return 0;
  return add_import(m, name, lib, symbol, sig);
}

static int parse_const_form(const char **p, Module *m) {
  char *name = parse_atom(p);
  char *value = parse_string(p);
  if (!name || !value || !eat(p, ')')) return 0;
  return add_const(m, name, value);
}

static int parse_main_items(const char **p, Module *m) {
  while (1) {
    skip_ws(p);
    if (**p == ')') {
      (*p)++;
      return 1;
    }
    if (!eat(p, '(')) return 0;
    char *head = parse_atom(p);
    if (!head) return 0;
    int ok = 0;
    if (strcmp(head, "block") == 0) {
      ok = parse_main_items(p, m);
      free(head);
      if (!ok) return 0;
      continue;
    }
    if (strcmp(head, "resolve") == 0) {
      char *import_name = parse_atom(p);
      ok = import_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_RESOLVE, import_name, NULL, NULL, 0);
    } else if (strcmp(head, "branch") == 0) {
      char *label_name = parse_atom(p);
      ok = label_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_BRANCH, label_name, NULL, NULL, 0);
    } else if (strcmp(head, "label") == 0) {
      char *label_name = parse_atom(p);
      ok = label_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_LABEL, label_name, NULL, NULL, 0);
    } else if (strcmp(head, "u64") == 0 || strcmp(head, "add-u64") == 0 ||
               strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
               strcmp(head, "sub-i64") == 0 || strcmp(head, "mul-i64") == 0 ||
               strcmp(head, "eq-i64") == 0 || strcmp(head, "lt-i64") == 0 ||
               strcmp(head, "gt-i64") == 0 || strcmp(head, "ne-i64") == 0 ||
               strcmp(head, "le-i64") == 0 || strcmp(head, "ge-i64") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      uint32_t form = strcmp(head, "u64") == 0 ? SRC_FORM_CONST_U64 :
                      strcmp(head, "add-u64") == 0 ? SRC_FORM_ADD_U64 :
                      strcmp(head, "i64") == 0 ? SRC_FORM_CONST_I64 :
                      strcmp(head, "add-i64") == 0 ? SRC_FORM_ADD_I64 :
                      strcmp(head, "sub-i64") == 0 ? SRC_FORM_SUB_I64 :
                      strcmp(head, "mul-i64") == 0 ? SRC_FORM_MUL_I64 :
                      strcmp(head, "eq-i64") == 0 ? SRC_FORM_EQ_I64 :
                      strcmp(head, "lt-i64") == 0 ? SRC_FORM_LT_I64 :
                      strcmp(head, "gt-i64") == 0 ? SRC_FORM_GT_I64 :
                      strcmp(head, "ne-i64") == 0 ? SRC_FORM_NE_I64 :
                      strcmp(head, "le-i64") == 0 ? SRC_FORM_LE_I64 :
                      SRC_FORM_GE_I64;
      if (strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
          strcmp(head, "sub-i64") == 0 || strcmp(head, "mul-i64") == 0 ||
          strcmp(head, "eq-i64") == 0 || strcmp(head, "lt-i64") == 0 ||
          strcmp(head, "gt-i64") == 0 || strcmp(head, "ne-i64") == 0 ||
          strcmp(head, "le-i64") == 0 || strcmp(head, "ge-i64") == 0) {
        ok = value && parse_i64_atom(value, &i64) && eat(p, ')') &&
             add_instr(m, form, NULL, NULL, NULL, (uint64_t)i64);
      } else {
        ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
             add_instr(m, form, NULL, NULL, NULL, imm);
      }
      free(value);
    } else if (strcmp(head, "bool") == 0) {
      char *value = parse_atom(p);
      int boolean = 0;
      ok = value && parse_bool_atom(value, &boolean) && eat(p, ')') &&
           add_instr(m, SRC_FORM_CONST_BOOL, NULL, NULL, NULL, (uint64_t)boolean);
      free(value);
    } else if (strcmp(head, "null-ptr") == 0) {
      ok = eat(p, ')') && add_instr(m, SRC_FORM_NULL_PTR, NULL, NULL, NULL, 0);
    } else if (strcmp(head, "add-ptr") == 0 || strcmp(head, "sub-ptr") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      uint32_t form = strcmp(head, "add-ptr") == 0 ? SRC_FORM_ADD_PTR : SRC_FORM_SUB_PTR;
      ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
           add_instr(m, form, NULL, NULL, NULL, imm);
      free(value);
    } else if (strcmp(head, "ptr-to-u64") == 0 || strcmp(head, "u64-to-ptr") == 0) {
      uint32_t form = strcmp(head, "ptr-to-u64") == 0 ?
                      SRC_FORM_PTR_TO_U64 :
                      SRC_FORM_U64_TO_PTR;
      ok = eat(p, ')') && add_instr(m, form, NULL, NULL, NULL, 0);
    } else if (strcmp(head, "const-ptr") == 0) {
      char *const_name = parse_atom(p);
      ok = const_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_CONST_PTR, NULL, const_name, NULL, 0);
    } else if (strcmp(head, "load-u8") == 0 || strcmp(head, "load-u16") == 0 ||
               strcmp(head, "load-u32") == 0) {
      uint32_t form = strcmp(head, "load-u8") == 0 ? SRC_FORM_LOAD_U8 :
                      strcmp(head, "load-u16") == 0 ? SRC_FORM_LOAD_U16 :
                      SRC_FORM_LOAD_U32;
      ok = eat(p, ')') && add_instr(m, form, NULL, NULL, NULL, 0);
    } else if (strcmp(head, "store-u8") == 0 || strcmp(head, "store-u16") == 0 ||
               strcmp(head, "store-u32") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      uint32_t form = strcmp(head, "store-u8") == 0 ? SRC_FORM_STORE_U8 :
                      strcmp(head, "store-u16") == 0 ? SRC_FORM_STORE_U16 :
                      SRC_FORM_STORE_U32;
      ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
           add_instr(m, form, NULL, NULL, NULL, imm);
      free(value);
    } else if (strcmp(head, "is-null-ptr") == 0 ||
               strcmp(head, "is-nonnull-ptr") == 0) {
      uint32_t form = strcmp(head, "is-null-ptr") == 0 ?
                      SRC_FORM_IS_NULL_PTR :
                      SRC_FORM_IS_NONNULL_PTR;
      ok = eat(p, ')') && add_instr(m, form, NULL, NULL, NULL, 0);
    } else if (strcmp(head, "not-bool") == 0) {
      ok = eat(p, ')') && add_instr(m, SRC_FORM_NOT_BOOL, NULL, NULL, NULL, 0);
    } else if (strcmp(head, "and-bool") == 0 || strcmp(head, "or-bool") == 0) {
      char *value = parse_atom(p);
      int boolean = 0;
      uint32_t form = strcmp(head, "and-bool") == 0 ? SRC_FORM_AND_BOOL : SRC_FORM_OR_BOOL;
      ok = value && parse_bool_atom(value, &boolean) && eat(p, ')') &&
           add_instr(m, form, NULL, NULL, NULL, (uint64_t)boolean);
      free(value);
    } else if (strcmp(head, "expect") == 0) {
      char *value = parse_atom(p);
      uint64_t expected = 0;
      int64_t expected_i64 = 0;
      int boolean = 0;
      int ptr_state = 0;
      if (value && parse_bool_atom(value, &boolean)) {
        ok = eat(p, ')') &&
             add_instr(m, SRC_FORM_EXPECT_BOOL, NULL, NULL, NULL, (uint64_t)boolean);
      } else if (value && parse_expect_ptr_atom(value, &ptr_state)) {
        ok = eat(p, ')') &&
             add_instr(m, SRC_FORM_EXPECT_PTR, NULL, NULL, NULL, (uint64_t)ptr_state);
      } else if (value && parse_i64_atom(value, &expected_i64) && expected_i64 < 0) {
        ok = eat(p, ')') &&
             add_instr(m, SRC_FORM_EXPECT_I64, NULL, NULL, NULL, (uint64_t)expected_i64);
      } else {
        ok = value && parse_u64_atom(value, &expected) && eat(p, ')') &&
             add_instr(m, SRC_FORM_EXPECT, NULL, NULL, NULL, expected);
      }
      free(value);
    } else if (strcmp(head, "call") == 0) {
      char *import_name = parse_atom(p);
      char *const_name = NULL;
      char *const2_name = NULL;
      if (import_name) {
        skip_ws(p);
        if (**p != ')') {
          const_name = parse_atom(p);
          skip_ws(p);
          if (**p != ')') {
            const2_name = parse_atom(p);
          }
        }
      }
      ok = import_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_CALL, import_name, const_name, const2_name, 0);
    }
    free(head);
    if (!ok) return 0;
  }
}

static int parse_main_form(const char **p, Module *m) {
  return parse_main_items(p, m) && m->instr_count > 0;
}

static int parse_module(const char *src, Module *m) {
  const char *p = src;
  if (!eat(&p, '(')) return 0;
  char *module = parse_atom(&p);
  if (!module || strcmp(module, "module") != 0) {
    free(module);
    return 0;
  }
  free(module);

  while (1) {
    skip_ws(&p);
    if (*p == ')') {
      p++;
      skip_ws(&p);
      return *p == 0 && m->instr_count > 0;
    }
    if (!eat(&p, '(')) return 0;
    char *head = parse_atom(&p);
    if (!head) return 0;
    int ok = 0;
    if (strcmp(head, "import") == 0) ok = parse_import_form(&p, m);
    else if (strcmp(head, "const") == 0) ok = parse_const_form(&p, m);
    else if (strcmp(head, "main") == 0) ok = parse_main_form(&p, m);
    free(head);
    if (!ok) return 0;
  }
}

static int find_import(const Module *m, const char *name) {
  for (size_t i = 0; i < m->import_count; ++i) {
    if (strcmp(m->imports[i].name, name) == 0) return (int)i;
  }
  return -1;
}

static int find_const(const Module *m, const char *name) {
  for (size_t i = 0; i < m->const_count; ++i) {
    if (strcmp(m->consts[i].name, name) == 0) return (int)i;
  }
  return -1;
}

static void emit_instr(Buf *instrs, uint8_t op, uint32_t arg0, uint32_t arg1) {
  unsigned char pad[3] = {0, 0, 0};
  buf_put(instrs, &op, 1);
  buf_put(instrs, pad, 3);
  buf_put32(instrs, arg0);
  buf_put32(instrs, arg1);
}

static uint32_t pack_const_pair(uint32_t a, uint32_t b) {
  if (a > 0xffffu || b > 0xffffu) {
    fprintf(stderr, "const.index=too_large_for_pair\n");
    exit(1);
  }
  return a | (b << 16);
}

static int find_label(const LabelDef *labels, size_t label_count, const char *name) {
  for (size_t i = 0; i < label_count; ++i) {
    if (strcmp(labels[i].name, name) == 0) return (int)i;
  }
  return -1;
}

static int build_label_table(const Module *m, LabelDef **out_labels, size_t *out_label_count,
                             uint32_t *out_emitted_instrs) {
  LabelDef *labels = (LabelDef *)calloc(m->instr_count ? m->instr_count : 1, sizeof(*labels));
  size_t label_count = 0;
  uint32_t emitted = 0;
  if (!labels) return 0;
  for (size_t i = 0; i < m->instr_count; ++i) {
    const InstrDef *in = &m->instrs[i];
    if (in->form == SRC_FORM_LABEL) {
      if (find_label(labels, label_count, in->import_name) >= 0) {
        fprintf(stderr, "duplicate.label=%s\n", in->import_name);
        free(labels);
        return 0;
      }
      labels[label_count++] = (LabelDef){in->import_name, emitted};
    } else {
      emitted++;
    }
  }
  *out_labels = labels;
  *out_label_count = label_count;
  *out_emitted_instrs = emitted;
  return 1;
}

static unsigned char *compile_module(const Module *m, size_t *out_n) {
  Buf out = {0};
  Buf imports = {0};
  Buf consts = {0};
  Buf instrs = {0};
  Buf strings = {0};
  LabelDef *labels = NULL;
  size_t label_count = 0;
  uint32_t emitted_instrs = 0;

  for (size_t i = 0; i < m->import_count; ++i) {
    buf_put32(&imports, add_string(&strings, m->imports[i].lib));
    buf_put32(&imports, add_string(&strings, m->imports[i].symbol));
    buf_put32(&imports, m->imports[i].sig);
    buf_put32(&imports, 0);
  }

  for (size_t i = 0; i < m->const_count; ++i) {
    buf_put32(&consts, CONST_STRING);
    buf_put32(&consts, add_string(&strings, m->consts[i].value));
    buf_put32(&consts, (uint32_t)strlen(m->consts[i].value));
    buf_put32(&consts, 0);
  }

  if (!build_label_table(m, &labels, &label_count, &emitted_instrs)) {
    free(imports.data);
    free(consts.data);
    free(strings.data);
    return NULL;
  }

  for (size_t i = 0; i < m->instr_count; ++i) {
    const InstrDef *in = &m->instrs[i];
    if (in->form == SRC_FORM_LABEL) continue;
    if (in->form == SRC_FORM_CONST_U64 || in->form == SRC_FORM_ADD_U64 ||
        in->form == SRC_FORM_CONST_I64 || in->form == SRC_FORM_ADD_I64 ||
        in->form == SRC_FORM_SUB_I64 || in->form == SRC_FORM_MUL_I64 ||
        in->form == SRC_FORM_EQ_I64 || in->form == SRC_FORM_LT_I64 ||
        in->form == SRC_FORM_GT_I64 || in->form == SRC_FORM_NE_I64 ||
        in->form == SRC_FORM_LE_I64 || in->form == SRC_FORM_GE_I64) {
      uint8_t op = in->form == SRC_FORM_CONST_U64 ? OP_CONST_U64 :
                   in->form == SRC_FORM_ADD_U64 ? OP_ADD_U64 :
                   in->form == SRC_FORM_CONST_I64 ? OP_CONST_I64 :
                   in->form == SRC_FORM_ADD_I64 ? OP_ADD_I64 :
                   in->form == SRC_FORM_SUB_I64 ? OP_SUB_I64 :
                   in->form == SRC_FORM_MUL_I64 ? OP_MUL_I64 :
                   in->form == SRC_FORM_EQ_I64 ? OP_EQ_I64 :
                   in->form == SRC_FORM_LT_I64 ? OP_LT_I64 :
                   in->form == SRC_FORM_GT_I64 ? OP_GT_I64 :
                   in->form == SRC_FORM_NE_I64 ? OP_NE_I64 :
                   in->form == SRC_FORM_LE_I64 ? OP_LE_I64 :
                   OP_GE_I64;
      emit_instr(&instrs, op, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_EXPECT) {
      emit_instr(&instrs, OP_EXPECT_U64, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_CONST_BOOL) {
      emit_instr(&instrs, OP_CONST_BOOL, (uint32_t)in->imm, 0);
      continue;
    }
    if (in->form == SRC_FORM_NULL_PTR) {
      emit_instr(&instrs, OP_NULL_PTR, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_ADD_PTR) {
      emit_instr(&instrs, OP_ADD_PTR, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_SUB_PTR) {
      emit_instr(&instrs, OP_SUB_PTR, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_PTR_TO_U64) {
      emit_instr(&instrs, OP_PTR_TO_U64, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_U64_TO_PTR) {
      emit_instr(&instrs, OP_U64_TO_PTR, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_CONST_PTR) {
      int const_idx = in->const_name ? find_const(m, in->const_name) : -1;
      if (const_idx < 0) {
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_CONST_PTR, (uint32_t)const_idx, 0);
      continue;
    }
    if (in->form == SRC_FORM_LOAD_U8) {
      emit_instr(&instrs, OP_LOAD_U8, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_LOAD_U16) {
      emit_instr(&instrs, OP_LOAD_U16, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_LOAD_U32) {
      emit_instr(&instrs, OP_LOAD_U32, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_STORE_U8) {
      emit_instr(&instrs, OP_STORE_U8, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_STORE_U16) {
      emit_instr(&instrs, OP_STORE_U16, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_STORE_U32) {
      emit_instr(&instrs, OP_STORE_U32, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_IS_NULL_PTR) {
      emit_instr(&instrs, OP_IS_NULL_PTR, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_IS_NONNULL_PTR) {
      emit_instr(&instrs, OP_IS_NONNULL_PTR, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_NOT_BOOL) {
      emit_instr(&instrs, OP_NOT_BOOL, 0, 0);
      continue;
    }
    if (in->form == SRC_FORM_AND_BOOL) {
      emit_instr(&instrs, OP_AND_BOOL, (uint32_t)in->imm, 0);
      continue;
    }
    if (in->form == SRC_FORM_OR_BOOL) {
      emit_instr(&instrs, OP_OR_BOOL, (uint32_t)in->imm, 0);
      continue;
    }
    if (in->form == SRC_FORM_EXPECT_I64) {
      emit_instr(&instrs, OP_EXPECT_I64, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_EXPECT_BOOL) {
      emit_instr(&instrs, OP_EXPECT_BOOL, (uint32_t)in->imm, 0);
      continue;
    }
    if (in->form == SRC_FORM_EXPECT_PTR) {
      emit_instr(&instrs, OP_EXPECT_PTR, (uint32_t)in->imm, 0);
      continue;
    }
    if (in->form == SRC_FORM_BRANCH) {
      int label_idx = find_label(labels, label_count, in->import_name);
      if (label_idx < 0) {
        fprintf(stderr, "missing.label=%s\n", in->import_name);
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_BRANCH_BOOL, labels[label_idx].pc, 0);
      continue;
    }
    int import_idx = find_import(m, in->import_name);
    if (import_idx < 0) {
      free(imports.data);
      free(consts.data);
      free(instrs.data);
      free(strings.data);
      free(labels);
      return NULL;
    }
    if (in->form == SRC_FORM_RESOLVE) {
      emit_instr(&instrs, OP_RESOLVE_IMPORT, (uint32_t)import_idx, 0);
      continue;
    }
    uint32_t sig = m->imports[import_idx].sig;
    if (sig == SIG_I32_VOID) {
      if (in->const_name || in->const2_name) {
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_CALL_IMPORT_VOID, (uint32_t)import_idx, 0);
    } else if (sig == SIG_I32_I32) {
      int32_t imm = 0;
      if (!in->const_name || in->const2_name || !parse_i32_atom(in->const_name, &imm)) {
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_CALL_IMPORT_IMM, (uint32_t)import_idx, (uint32_t)imm);
    } else if (sig == SIG_U64_PTR || sig == SIG_I32_PTR) {
      int const_idx = in->const_name ? find_const(m, in->const_name) : -1;
      if (const_idx < 0 || in->const2_name) {
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_CALL_IMPORT_CONST, (uint32_t)import_idx, (uint32_t)const_idx);
    } else if (sig == SIG_I32_PTR_PTR) {
      int const_idx = in->const_name ? find_const(m, in->const_name) : -1;
      int const2_idx = in->const2_name ? find_const(m, in->const2_name) : -1;
      if (const_idx < 0 || const2_idx < 0) {
        free(imports.data);
        free(consts.data);
        free(instrs.data);
        free(strings.data);
        free(labels);
        return NULL;
      }
      emit_instr(&instrs, OP_CALL_IMPORT_CONST2, (uint32_t)import_idx,
                 pack_const_pair((uint32_t)const_idx, (uint32_t)const2_idx));
    } else {
      fprintf(stderr, "signature.not_callable=%s\n", sig_name(sig));
      free(imports.data);
      free(consts.data);
      free(instrs.data);
      free(strings.data);
      free(labels);
      return NULL;
    }
  }
  emit_instr(&instrs, OP_RET_LAST, 0, 0);

  unsigned char magic[8] = OUTPUT_MAGIC_INIT;
  buf_put(&out, magic, 8);
  buf_put32(&out, 1);
  buf_put32(&out, 0);
  buf_put32(&out, (uint32_t)m->import_count);
  buf_put32(&out, (uint32_t)m->const_count);
  buf_put32(&out, emitted_instrs + 1);
  buf_put32(&out, (uint32_t)strings.len);
  buf_put(&out, imports.data, imports.len);
  buf_put(&out, consts.data, consts.len);
  buf_put(&out, instrs.data, instrs.len);
  buf_put(&out, strings.data, strings.len);

  free(imports.data);
  free(consts.data);
  free(instrs.data);
  free(strings.data);
  free(labels);
  *out_n = out.len;
  return out.data;
}


