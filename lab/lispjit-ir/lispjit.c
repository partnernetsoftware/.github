#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <dlfcn.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>
#endif

#if defined(__COSMOPOLITAN__)
extern void *cosmo_dlopen(const char *filename, int flags);
extern void *cosmo_dlsym(void *handle, const char *symbol);
#endif

#define HEADER_SIZE 32u
#define IMPORT_SIZE 16u
#define CONST_SIZE 16u
#define INSTR_SIZE 12u

#ifdef NANO_LISP_JIT
#define OUTPUT_MAGIC_INIT {'L', 'B', 'I', 'N', '0', '1', 0, 0}
#define OUTPUT_FORMAT "lbin"
#define SOURCE_EXT "lisp"
#define BLOB_EXT "lbin"
#else
#define OUTPUT_MAGIC_INIT {'L', 'J', 'I', 'R', 'B', '1', 0, 0}
#define OUTPUT_FORMAT "ljir"
#define SOURCE_EXT "lispir"
#define BLOB_EXT "ljir"
#endif

#define SIG_ADDR 0u
#define SIG_U64_PTR 1u
#define SIG_I32_PTR 2u
#define SIG_I32_PTR_PTR 3u
#define SIG_I32_VOID 4u
#define SIG_I32_I32 5u
#define CONST_STRING 1u
#define OP_CALL_IMPORT_CONST 1u
#define OP_RET_LAST 2u
#define OP_CALL_IMPORT_CONST2 3u
#define OP_RESOLVE_IMPORT 4u
#define OP_CALL_IMPORT_VOID 5u
#define OP_EXPECT_U64 6u
#define OP_CONST_U64 7u
#define OP_ADD_U64 8u
#define OP_CALL_IMPORT_IMM 9u
#define OP_CONST_I64 10u
#define OP_CONST_BOOL 11u
#define OP_EXPECT_I64 12u
#define OP_EXPECT_BOOL 13u
#define OP_EXPECT_PTR 14u
#define OP_BRANCH_BOOL 15u
#define OP_ADD_I64 16u
#define OP_SUB_I64 17u

#define SRC_FORM_CALL 1u
#define SRC_FORM_RESOLVE 2u
#define SRC_FORM_EXPECT 3u
#define SRC_FORM_CONST_U64 4u
#define SRC_FORM_ADD_U64 5u
#define SRC_FORM_CONST_I64 6u
#define SRC_FORM_CONST_BOOL 7u
#define SRC_FORM_EXPECT_I64 8u
#define SRC_FORM_EXPECT_BOOL 9u
#define SRC_FORM_EXPECT_PTR 10u
#define SRC_FORM_BRANCH 11u
#define SRC_FORM_LABEL 12u
#define SRC_FORM_ADD_I64 13u
#define SRC_FORM_SUB_I64 14u

#define AOT_STMT_CONST_U64 1u
#define AOT_STMT_ADD_U64 2u
#define AOT_STMT_EXPECT_U64 3u
#define AOT_STMT_CALL_FUNC 4u
#define AOT_STMT_CONST_I64 5u
#define AOT_STMT_CONST_BOOL 6u
#define AOT_STMT_EXPECT_I64 7u
#define AOT_STMT_EXPECT_BOOL 8u
#define AOT_STMT_BRANCH_BOOL 9u
#define AOT_STMT_LABEL 10u
#define AOT_STMT_ADD_I64 11u
#define AOT_STMT_SUB_I64 12u

#define BOOTSTRAP_STEP_COMPILE 1u
#define BOOTSTRAP_STEP_HASH 2u
#define BOOTSTRAP_STEP_RUN 3u
#define BOOTSTRAP_STEP_COMPARE 4u
#define BOOTSTRAP_STEP_PACK_APP 5u
#define BOOTSTRAP_STEP_INSPECT_APP 6u
#define BOOTSTRAP_STEP_EMIT_ELF64_EXIT 7u
#define BOOTSTRAP_STEP_AOT_ELF64_EXIT 8u
#define BOOTSTRAP_STEP_AOT_ELF64_CODE 9u
#define BOOTSTRAP_STEP_AOT_ELF64_OBJ_CODE 10u
#define BOOTSTRAP_STEP_COMPILE_ELF64_CODE 11u
#define BOOTSTRAP_STEP_COMPILE_ELF64_OBJ_CODE 12u
#define BOOTSTRAP_STEP_LINK_ELF64_EXE 13u
#define BOOTSTRAP_STEP_RUN_EXPECT_EXIT 14u
#define BOOTSTRAP_STEP_AOT_ELF64_OBJ_RET 15u
#define BOOTSTRAP_STEP_EMIT_ELF64_OBJ_RET 16u
#define BOOTSTRAP_STEP_EMIT_ELF64_OBJ_CALL 17u
#define BOOTSTRAP_STEP_LINK_EXPECT_EXIT 18u
#define BOOTSTRAP_STEP_RESOLVE_QUIET 19u
#define BOOTSTRAP_STEP_COMPILE_ELF64_EXE 20u
#define BOOTSTRAP_STEP_RUN_APP 21u
#define BOOTSTRAP_STEP_DUMP 22u
#define BOOTSTRAP_STEP_FILE_SIZE 23u
#define BOOTSTRAP_STEP_FILE_HASH 24u

typedef uint64_t (*jit_entry_fn)(void);
typedef int (*ffi_i32_ptr_fn)(const char *);
typedef int (*ffi_i32_ptr_ptr_fn)(const char *, const char *);
typedef int (*ffi_i32_void_fn)(void);
typedef int (*ffi_i32_i32_fn)(int);

typedef struct {
  char *name;
  char *lib;
  char *symbol;
  uint32_t sig;
} ImportDef;

typedef struct {
  char *name;
  char *value;
} ConstDef;

typedef struct {
  uint32_t form;
  char *import_name;
  char *const_name;
  char *const2_name;
  uint64_t imm;
} InstrDef;

typedef struct {
  ImportDef *imports;
  size_t import_count;
  size_t import_cap;
  ConstDef *consts;
  size_t const_count;
  size_t const_cap;
  InstrDef *instrs;
  size_t instr_count;
  size_t instr_cap;
} Module;

typedef struct {
  uint32_t kind;
  uint64_t imm;
  char *target_name;
} AotStmt;

typedef struct {
  char *name;
  int is_global;
  AotStmt *stmts;
  size_t stmt_count;
  size_t stmt_cap;
} AotFunc;

typedef struct {
  AotFunc *funcs;
  size_t func_count;
  size_t func_cap;
} AotModule;

typedef struct {
  uint32_t patch_off;
  const char *target_name;
} AotCallPatch;

typedef struct {
  uint32_t kind;
  char *arg0;
  char *arg1;
  char *arg2;
  char *arg3;
  char **extra_args;
  size_t extra_arg_count;
} BootstrapStep;

typedef struct {
  BootstrapStep *steps;
  size_t step_count;
  size_t step_cap;
} BootstrapPlan;

typedef struct {
  unsigned char *data;
  size_t len;
  size_t cap;
} Buf;

typedef struct {
  unsigned char *data;
  size_t size;
  uint32_t format;
  uint32_t version;
  uint32_t import_count;
  uint32_t const_count;
  uint32_t instr_count;
  uint32_t string_size;
  size_t import_off;
  size_t const_off;
  size_t instr_off;
  size_t string_off;
} Blob;

typedef struct {
  const char *name;
  uint32_t pc;
} LabelDef;

typedef enum {
  VAL_U64 = 1,
  VAL_I64 = 2,
  VAL_BOOL = 3,
  VAL_PTR = 4,
} ValueKind;

typedef struct {
  ValueKind kind;
  uint64_t bits;
} Value;

static uint32_t rd32(const unsigned char *p) {
  return ((uint32_t)p[0]) |
         ((uint32_t)p[1] << 8) |
         ((uint32_t)p[2] << 16) |
         ((uint32_t)p[3] << 24);
}

static uint16_t rd16(const unsigned char *p) {
  return ((uint16_t)p[0]) | ((uint16_t)p[1] << 8);
}

static uint64_t rd64(const unsigned char *p) {
  uint64_t v = 0;
  for (int i = 7; i >= 0; --i) {
    v = (v << 8) | p[i];
  }
  return v;
}

static void wr16(unsigned char *p, uint16_t v) {
  p[0] = (unsigned char)(v & 0xff);
  p[1] = (unsigned char)((v >> 8) & 0xff);
}

static void wr32(unsigned char *p, uint32_t v) {
  p[0] = (unsigned char)(v & 0xff);
  p[1] = (unsigned char)((v >> 8) & 0xff);
  p[2] = (unsigned char)((v >> 16) & 0xff);
  p[3] = (unsigned char)((v >> 24) & 0xff);
}

static void wr64(unsigned char *p, uint64_t v) {
  for (int i = 0; i < 8; ++i) {
    p[i] = (unsigned char)((v >> (i * 8)) & 0xff);
  }
}

static Value value_u64(uint64_t v) {
  Value out = {VAL_U64, v};
  return out;
}

static Value value_i64(int64_t v) {
  Value out = {VAL_I64, (uint64_t)v};
  return out;
}

static Value value_bool(int v) {
  Value out = {VAL_BOOL, v ? 1u : 0u};
  return out;
}

static Value value_ptr(const void *p) {
  Value out = {VAL_PTR, (uint64_t)(uintptr_t)p};
  return out;
}

static int value_expect_u64(Value v, uint64_t expected) {
  if (v.kind == VAL_U64) return v.bits == expected;
  if (v.kind == VAL_I64 && (int64_t)v.bits >= 0) return v.bits == expected;
  return 0;
}

static int value_expect_i64(Value v, int64_t expected) {
  if (v.kind == VAL_I64) return (int64_t)v.bits == expected;
  if (v.kind == VAL_U64 && expected >= 0) return v.bits == (uint64_t)expected;
  return 0;
}

static int value_expect_bool(Value v, int expected) {
  return v.kind == VAL_BOOL && (!!v.bits) == !!expected;
}

static int value_expect_ptr(Value v, int nonnull) {
  return v.kind == VAL_PTR && ((v.bits != 0) == !!nonnull);
}

static int value_add_u64(Value *v, uint64_t rhs) {
  if (v->kind != VAL_U64) return 0;
  v->bits += rhs;
  return 1;
}

static int value_add_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  v->bits += (uint64_t)rhs;
  return 1;
}

static int value_sub_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  v->bits -= (uint64_t)rhs;
  return 1;
}

static void print_value(FILE *out, Value v) {
  switch (v.kind) {
    case VAL_U64:
      fprintf(out, "%llu", (unsigned long long)v.bits);
      return;
    case VAL_I64:
      fprintf(out, "%lld", (long long)(int64_t)v.bits);
      return;
    case VAL_BOOL:
      fprintf(out, "%s", v.bits ? "true" : "false");
      return;
    case VAL_PTR:
      if (!v.bits) {
        fprintf(out, "null");
      } else {
        fprintf(out, "0x%llx", (unsigned long long)v.bits);
      }
      return;
  }
  fprintf(out, "<?>");
}

static uint32_t parse_sig_id(const char *sig) {
  if (strcmp(sig, "addr") == 0) return SIG_ADDR;
  if (strcmp(sig, "u64(ptr)") == 0) return SIG_U64_PTR;
  if (strcmp(sig, "i32(ptr)") == 0) return SIG_I32_PTR;
  if (strcmp(sig, "i32(ptr,ptr)") == 0) return SIG_I32_PTR_PTR;
  if (strcmp(sig, "i32()") == 0) return SIG_I32_VOID;
  if (strcmp(sig, "i32(i32)") == 0) return SIG_I32_I32;
  return UINT32_MAX;
}

static const char *sig_name(uint32_t sig) {
  switch (sig) {
    case SIG_ADDR: return "addr";
    case SIG_U64_PTR: return "u64(ptr)";
    case SIG_I32_PTR: return "i32(ptr)";
    case SIG_I32_PTR_PTR: return "i32(ptr,ptr)";
    case SIG_I32_VOID: return "i32()";
    case SIG_I32_I32: return "i32(i32)";
    default: return "unknown";
  }
}

static void buf_reserve(Buf *b, size_t add) {
  if (b->len + add <= b->cap) return;
  size_t next = b->cap ? b->cap * 2 : 256;
  while (next < b->len + add) next *= 2;
  unsigned char *p = (unsigned char *)realloc(b->data, next);
  if (!p) {
    fprintf(stderr, "alloc=fail\n");
    exit(1);
  }
  b->data = p;
  b->cap = next;
}

static void buf_put(Buf *b, const void *p, size_t n) {
  buf_reserve(b, n);
  memcpy(b->data + b->len, p, n);
  b->len += n;
}

static void buf_put32(Buf *b, uint32_t v) {
  unsigned char tmp[4];
  wr32(tmp, v);
  buf_put(b, tmp, sizeof(tmp));
}

static uint32_t add_string(Buf *strings, const char *s) {
  uint32_t off = (uint32_t)strings->len;
  buf_put(strings, s, strlen(s) + 1);
  return off;
}

static char *dup_cstr(const char *s) {
  size_t n = strlen(s) + 1;
  char *out = (char *)malloc(n);
  if (!out) return NULL;
  memcpy(out, s, n);
  return out;
}

static unsigned char *read_file(const char *path, size_t *out_size) {
  FILE *f = fopen(path, "rb");
  if (!f) return NULL;
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return NULL;
  }
  long n = ftell(f);
  if (n < 0) {
    fclose(f);
    return NULL;
  }
  rewind(f);
  unsigned char *buf = (unsigned char *)malloc((size_t)n + 1);
  if (!buf) {
    fclose(f);
    return NULL;
  }
  if (fread(buf, 1, (size_t)n, f) != (size_t)n) {
    free(buf);
    fclose(f);
    return NULL;
  }
  fclose(f);
  buf[n] = 0;
  *out_size = (size_t)n;
  return buf;
}

static int write_file(const char *path, const unsigned char *data, size_t n) {
  FILE *f = fopen(path, "wb");
  if (!f) return 0;
  int ok = fwrite(data, 1, n, f) == n;
  fclose(f);
  return ok;
}

static uint64_t fnv1a64(const unsigned char *data, size_t n) {
  uint64_t h = 1469598103934665603ull;
  for (size_t i = 0; i < n; ++i) {
    h ^= data[i];
    h *= 1099511628211ull;
  }
  return h;
}

static int make_executable(const char *path) {
#if defined(_WIN32)
  (void)path;
  return 1;
#else
  return chmod(path, 0755) == 0;
#endif
}

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

static int parse_aot_body_items(const char **p, AotFunc *f) {
  while (1) {
    skip_ws(p);
    if (**p == ')') {
      (*p)++;
      return f->stmt_count > 0;
    }
    if (!eat(p, '(')) return 0;
    char *head = parse_atom(p);
    if (!head) return 0;
    int ok = 0;
    if (strcmp(head, "block") == 0) {
      ok = parse_aot_body_items(p, f);
      free(head);
      if (!ok) return 0;
      continue;
    }
    if (strcmp(head, "branch") == 0) {
      char *label = parse_atom(p);
      ok = label && eat(p, ')') &&
           aot_add_stmt(f, AOT_STMT_BRANCH_BOOL, 0, label);
      if (!ok) free(label);
    } else if (strcmp(head, "label") == 0) {
      char *label = parse_atom(p);
      ok = label && eat(p, ')') &&
           aot_add_stmt(f, AOT_STMT_LABEL, 0, label);
      if (!ok) free(label);
    } else if (strcmp(head, "u64") == 0 || strcmp(head, "add-u64") == 0 ||
               strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
               strcmp(head, "sub-i64") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      uint32_t kind = strcmp(head, "u64") == 0 ? AOT_STMT_CONST_U64 :
                      strcmp(head, "add-u64") == 0 ? AOT_STMT_ADD_U64 :
                      strcmp(head, "i64") == 0 ? AOT_STMT_CONST_I64 :
                      strcmp(head, "add-i64") == 0 ? AOT_STMT_ADD_I64 :
                      AOT_STMT_SUB_I64;
      if (strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
          strcmp(head, "sub-i64") == 0) {
        ok = value && parse_i64_atom(value, &i64) && eat(p, ')') &&
             aot_add_stmt(f, kind, (uint64_t)i64, NULL);
      } else {
        ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
             aot_add_stmt(f, kind, imm, NULL);
      }
      free(value);
    } else if (strcmp(head, "bool") == 0) {
      char *value = parse_atom(p);
      int boolean = 0;
      ok = value && parse_bool_atom(value, &boolean) && eat(p, ')') &&
           aot_add_stmt(f, AOT_STMT_CONST_BOOL, (uint64_t)boolean, NULL);
      free(value);
    } else if (strcmp(head, "expect") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      int boolean = 0;
      if (value && parse_bool_atom(value, &boolean)) {
        ok = eat(p, ')') &&
             aot_add_stmt(f, AOT_STMT_EXPECT_BOOL, (uint64_t)boolean, NULL);
      } else if (value && parse_i64_atom(value, &i64) && i64 < 0) {
        ok = eat(p, ')') &&
             aot_add_stmt(f, AOT_STMT_EXPECT_I64, (uint64_t)i64, NULL);
      } else {
        ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
             aot_add_stmt(f, AOT_STMT_EXPECT_U64, imm, NULL);
      }
      free(value);
    } else if (strcmp(head, "call") == 0) {
      char *target = parse_atom(p);
      skip_ws(p);
      ok = target && **p == ')' && eat(p, ')') &&
           aot_add_stmt(f, AOT_STMT_CALL_FUNC, 0, target);
      if (!ok) free(target);
    }
    free(head);
    if (!ok) return 0;
  }
}

static int parse_aot_module(const char *src, AotModule *m) {
  const char *p = src;
  int saw_main = 0;
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
      return *p == 0 && saw_main;
    }
    if (!eat(&p, '(')) return 0;
    char *head = parse_atom(&p);
    char *name = NULL;
    AotFunc *func = NULL;
    int ok = 0;
    if (!head) return 0;
    if (strcmp(head, "main") == 0) {
      if (saw_main || aot_find_func(m, "main") >= 0) {
        free(head);
        return 0;
      }
      name = dup_cstr("main");
      func = name ? aot_add_func(m, name, 1) : NULL;
      ok = func && parse_aot_body_items(&p, func);
      saw_main = ok;
    } else if (strcmp(head, "func") == 0) {
      name = parse_atom(&p);
      if (!name || !name[0] || aot_find_func(m, name) >= 0 || strcmp(name, "main") == 0) {
        free(name);
        free(head);
        return 0;
      }
      func = aot_add_func(m, name, 0);
      ok = func && parse_aot_body_items(&p, func);
    }
    free(head);
    if (!ok) return 0;
  }
}

static int parse_bootstrap_plan(const char *src, BootstrapPlan *plan) {
  const char *p = src;
  if (!eat(&p, '(')) return 0;
  char *head = parse_atom(&p);
  if (!head || strcmp(head, "bootstrap") != 0) {
    free(head);
    return 0;
  }
  free(head);
  while (1) {
    skip_ws(&p);
    if (*p == ')') {
      p++;
      skip_ws(&p);
      return *p == 0 && plan->step_count > 0;
    }
    if (!eat(&p, '(')) return 0;
    head = parse_atom(&p);
    if (!head) return 0;
    if (strcmp(head, "compile") == 0 || strcmp(head, "compare") == 0 ||
        strcmp(head, "aot-elf64-exit") == 0 || strcmp(head, "aot-elf64-code") == 0 ||
        strcmp(head, "compile-elf64-code") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      uint32_t kind = strcmp(head, "compile") == 0 ? BOOTSTRAP_STEP_COMPILE :
                      strcmp(head, "compare") == 0 ? BOOTSTRAP_STEP_COMPARE :
                      strcmp(head, "aot-elf64-exit") == 0 ? BOOTSTRAP_STEP_AOT_ELF64_EXIT :
                      strcmp(head, "aot-elf64-code") == 0 ? BOOTSTRAP_STEP_AOT_ELF64_CODE :
                      BOOTSTRAP_STEP_COMPILE_ELF64_CODE;
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, arg1, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "emit-elf64-exit") == 0 ||
               strcmp(head, "run-expect-exit") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_atom(&p);
      uint32_t kind = strcmp(head, "emit-elf64-exit") == 0 ?
                      BOOTSTRAP_STEP_EMIT_ELF64_EXIT : BOOTSTRAP_STEP_RUN_EXPECT_EXIT;
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, arg1, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "aot-elf64-obj-ret") == 0 ||
               strcmp(head, "aot-elf64-obj-code") == 0 ||
               strcmp(head, "compile-elf64-obj-code") == 0 ||
               strcmp(head, "compile-elf64-exe") == 0 ||
               strcmp(head, "emit-elf64-obj-call") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      uint32_t kind = strcmp(head, "aot-elf64-obj-ret") == 0 ?
                      BOOTSTRAP_STEP_AOT_ELF64_OBJ_RET :
                      strcmp(head, "aot-elf64-obj-code") == 0 ?
                      BOOTSTRAP_STEP_AOT_ELF64_OBJ_CODE :
                      strcmp(head, "compile-elf64-obj-code") == 0 ?
                      BOOTSTRAP_STEP_COMPILE_ELF64_OBJ_CODE :
                      strcmp(head, "compile-elf64-exe") == 0 ?
                      BOOTSTRAP_STEP_COMPILE_ELF64_EXE :
                      BOOTSTRAP_STEP_EMIT_ELF64_OBJ_CALL;
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "emit-elf64-obj-ret") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_atom(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_EMIT_ELF64_OBJ_RET,
                                  arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "link-elf64-exe") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      char **extra_args = NULL;
      size_t extra_arg_count = 0;
      size_t extra_arg_cap = 0;
      int ok = arg0 && arg1 && arg2;
      while (ok) {
        skip_ws(&p);
        if (*p == ')') break;
        char *arg = parse_string(&p);
        if (!arg || !bootstrap_push_string_arg(&extra_args, &extra_arg_count,
                                               &extra_arg_cap, arg)) {
          free(arg);
          ok = 0;
          break;
        }
      }
      ok = ok && eat(&p, ')') &&
           bootstrap_add_step_extra(plan, BOOTSTRAP_STEP_LINK_ELF64_EXE,
                                    arg0, arg1, arg2, NULL,
                                    extra_args, extra_arg_count);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        bootstrap_free_string_array(extra_args, extra_arg_count);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "link-expect-exit") == 0) {
      char *arg0 = parse_atom(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      char *arg3 = parse_string(&p);
      char **extra_args = NULL;
      size_t extra_arg_count = 0;
      size_t extra_arg_cap = 0;
      int ok = arg0 && arg1 && arg2 && arg3;
      while (ok) {
        skip_ws(&p);
        if (*p == ')') break;
        char *arg = parse_string(&p);
        if (!arg || !bootstrap_push_string_arg(&extra_args, &extra_arg_count,
                                               &extra_arg_cap, arg)) {
          free(arg);
          ok = 0;
          break;
        }
      }
      ok = ok && eat(&p, ')') &&
           bootstrap_add_step_extra(plan, BOOTSTRAP_STEP_LINK_EXPECT_EXIT,
                                    arg0, arg1, arg2, arg3,
                                    extra_args, extra_arg_count);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(arg3);
        bootstrap_free_string_array(extra_args, extra_arg_count);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "pack-app") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      char *arg3 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && arg3 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_PACK_APP, arg0, arg1, arg2, arg3);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(arg3);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "inspect-app") == 0 || strcmp(head, "run-app") == 0) {
      char *arg0 = parse_string(&p);
      uint32_t kind = strcmp(head, "inspect-app") == 0 ? BOOTSTRAP_STEP_INSPECT_APP :
                      BOOTSTRAP_STEP_RUN_APP;
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, NULL, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "hash") == 0 || strcmp(head, "dump") == 0 ||
               strcmp(head, "file-size") == 0 || strcmp(head, "file-hash") == 0 ||
               strcmp(head, "run") == 0 ||
               strcmp(head, "resolve-quiet") == 0) {
      char *arg0 = parse_string(&p);
      uint32_t kind = strcmp(head, "hash") == 0 ? BOOTSTRAP_STEP_HASH :
                      strcmp(head, "dump") == 0 ? BOOTSTRAP_STEP_DUMP :
                      strcmp(head, "file-size") == 0 ? BOOTSTRAP_STEP_FILE_SIZE :
                      strcmp(head, "file-hash") == 0 ? BOOTSTRAP_STEP_FILE_HASH :
                      strcmp(head, "run") == 0 ? BOOTSTRAP_STEP_RUN :
                      BOOTSTRAP_STEP_RESOLVE_QUIET;
      int ok = arg0 && eat(&p, ')') && bootstrap_add_step(plan, kind, arg0, NULL, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(head);
        return 0;
      }
    } else {
      free(head);
      return 0;
    }
    free(head);
  }
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
               strcmp(head, "sub-i64") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      uint32_t form = strcmp(head, "u64") == 0 ? SRC_FORM_CONST_U64 :
                      strcmp(head, "add-u64") == 0 ? SRC_FORM_ADD_U64 :
                      strcmp(head, "i64") == 0 ? SRC_FORM_CONST_I64 :
                      strcmp(head, "add-i64") == 0 ? SRC_FORM_ADD_I64 :
                      SRC_FORM_SUB_I64;
      if (strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
          strcmp(head, "sub-i64") == 0) {
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
        in->form == SRC_FORM_SUB_I64) {
      uint8_t op = in->form == SRC_FORM_CONST_U64 ? OP_CONST_U64 :
                   in->form == SRC_FORM_ADD_U64 ? OP_ADD_U64 :
                   in->form == SRC_FORM_CONST_I64 ? OP_CONST_I64 :
                   in->form == SRC_FORM_ADD_I64 ? OP_ADD_I64 :
                   OP_SUB_I64;
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

static int checked_span(size_t size, size_t off, size_t count, size_t each) {
  return off <= size && count <= (size - off) / each;
}

static int blob_init(Blob *b, unsigned char *data, size_t size) {
  static const unsigned char lbin_magic[8] = {'L', 'B', 'I', 'N', '0', '1', 0, 0};
  static const unsigned char ljir_magic[8] = {'L', 'J', 'I', 'R', 'B', '1', 0, 0};
  if (size < HEADER_SIZE) return 0;
  if (memcmp(data, lbin_magic, sizeof(lbin_magic)) == 0) {
    b->format = 1;
  } else if (memcmp(data, ljir_magic, sizeof(ljir_magic)) == 0) {
    b->format = 2;
  } else {
    return 0;
  }
  b->data = data;
  b->size = size;
  b->version = rd32(data + 8);
  b->import_count = rd32(data + 16);
  b->const_count = rd32(data + 20);
  b->instr_count = rd32(data + 24);
  b->string_size = rd32(data + 28);
  b->import_off = HEADER_SIZE;
  b->const_off = b->import_off + (size_t)b->import_count * IMPORT_SIZE;
  b->instr_off = b->const_off + (size_t)b->const_count * CONST_SIZE;
  b->string_off = b->instr_off + (size_t)b->instr_count * INSTR_SIZE;
  if (!checked_span(size, b->import_off, b->import_count, IMPORT_SIZE)) return 0;
  if (!checked_span(size, b->const_off, b->const_count, CONST_SIZE)) return 0;
  if (!checked_span(size, b->instr_off, b->instr_count, INSTR_SIZE)) return 0;
  if (!checked_span(size, b->string_off, b->string_size, 1)) return 0;
  if (b->string_off + b->string_size != size) return 0;
  return b->version == 1;
}

static const char *blob_string(const Blob *b, uint32_t off) {
  if (off >= b->string_size) return NULL;
  const char *s = (const char *)(b->data + b->string_off + off);
  return memchr(s, 0, b->string_size - off) ? s : NULL;
}

static const unsigned char *import_row(const Blob *b, uint32_t idx) {
  return idx < b->import_count ? b->data + b->import_off + (size_t)idx * IMPORT_SIZE : NULL;
}

static const unsigned char *const_row(const Blob *b, uint32_t idx) {
  return idx < b->const_count ? b->data + b->const_off + (size_t)idx * CONST_SIZE : NULL;
}

static const unsigned char *instr_row(const Blob *b, uint32_t idx) {
  return idx < b->instr_count ? b->data + b->instr_off + (size_t)idx * INSTR_SIZE : NULL;
}

static void *open_named_library(const char *name) {
#if defined(_WIN32)
  if (strcmp(name, "libc") == 0) {
    void *h = LoadLibraryA("ucrtbase.dll");
    return h ? h : LoadLibraryA("msvcrt.dll");
  }
  return LoadLibraryA(name);
#elif defined(__COSMOPOLITAN__)
  if (strcmp(name, "libc") == 0) {
    void *h = cosmo_dlopen(NULL, RTLD_LAZY);
    if (h) return h;
    h = cosmo_dlopen("libc.so.6", RTLD_LAZY);
    return h ? h : cosmo_dlopen("libc.so", RTLD_LAZY);
  }
  return cosmo_dlopen(name, RTLD_LAZY);
#else
  if (strcmp(name, "libc") == 0) {
#if defined(__APPLE__)
    return dlopen("libSystem.B.dylib", RTLD_LAZY);
#else
    void *h = dlopen("libc.so.6", RTLD_LAZY);
    return h ? h : dlopen("libc.so", RTLD_LAZY);
#endif
  }
  return dlopen(name, RTLD_LAZY);
#endif
}

static void *load_symbol(void *handle, const char *name) {
#if defined(_WIN32)
  return (void *)GetProcAddress((HMODULE)handle, name);
#elif defined(__COSMOPOLITAN__)
  return cosmo_dlsym(handle, name);
#else
  return dlsym(handle, name);
#endif
}

static void *alloc_exec(size_t n) {
#if defined(_WIN32)
  return VirtualAlloc(NULL, n, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
#else
  void *p = mmap(NULL, n, PROT_READ | PROT_WRITE | PROT_EXEC,
                 MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  return p == MAP_FAILED ? NULL : p;
#endif
}

static void patch64(unsigned char *p, uint64_t v) {
  for (int i = 0; i < 8; ++i) p[i] = (unsigned char)((v >> (i * 8)) & 0xff);
}

static void *emit_u64_ptr_call(void *fn, const char *arg, size_t *out_n) {
#if defined(__x86_64__) || defined(_M_X64)
  unsigned char code[] = {
#if defined(_WIN32)
    0x48, 0xb9, 0, 0, 0, 0, 0, 0, 0, 0,
#else
    0x48, 0xbf, 0, 0, 0, 0, 0, 0, 0, 0,
#endif
    0x48, 0xb8, 0, 0, 0, 0, 0, 0, 0, 0,
    0xff, 0xd0,
    0xc3
  };
  patch64(code + 2, (uint64_t)(uintptr_t)arg);
  patch64(code + 12, (uint64_t)(uintptr_t)fn);
#elif defined(__aarch64__) || defined(_M_ARM64)
  unsigned char code[] = {
    0x80, 0x00, 0x00, 0x58, 0xb0, 0x00, 0x00, 0x58,
    0x00, 0x02, 0x3f, 0xd6, 0xc0, 0x03, 0x5f, 0xd6,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  patch64(code + 16, (uint64_t)(uintptr_t)arg);
  patch64(code + 24, (uint64_t)(uintptr_t)fn);
#else
  (void)fn;
  (void)arg;
  (void)out_n;
  return NULL;
#endif
  void *mem = alloc_exec(sizeof(code));
  if (!mem) return NULL;
  memcpy(mem, code, sizeof(code));
#if defined(__GNUC__) || defined(__clang__)
  __builtin___clear_cache((char *)mem, (char *)mem + sizeof(code));
#endif
  *out_n = sizeof(code);
  return mem;
}

static int blob_load_path(const char *path, Blob *b, unsigned char **owned) {
  size_t n = 0;
  unsigned char *data = read_file(path, &n);
  if (!data) return 0;
  if (!blob_init(b, data, n)) {
    free(data);
    return 0;
  }
  *owned = data;
  return 1;
}

typedef struct {
  const char *lib;
  const char *sym;
  uint32_t sig;
  void *handle;
  void *fn;
} RuntimeImport;

static int resolve_import_ref(const Blob *b, uint32_t idx, RuntimeImport *out) {
  const unsigned char *imp = import_row(b, idx);
  if (!imp) return 12;
  out->lib = blob_string(b, rd32(imp));
  out->sym = blob_string(b, rd32(imp + 4));
  out->sig = rd32(imp + 8);
  if (!out->lib || !out->sym) return 13;
  out->handle = open_named_library(out->lib);
  if (!out->handle) {
    fprintf(stderr, "ffi.open=fail lib=%s\n", out->lib);
    return 14;
  }
  out->fn = load_symbol(out->handle, out->sym);
  if (!out->fn) {
    fprintf(stderr, "ffi.symbol=fail symbol=%s\n", out->sym);
    return 15;
  }
  return 0;
}

static const char *const_string_ref(const Blob *b, uint32_t idx) {
  const unsigned char *con = const_row(b, idx);
  if (!con || rd32(con) != CONST_STRING) return NULL;
  return blob_string(b, rd32(con + 4));
}

static int call_import1(const RuntimeImport *ri, const char *arg, Value *out) {
  if (!arg) return 13;
  if (ri->sig == SIG_U64_PTR) {
    size_t code_n = 0;
    void *entry = emit_u64_ptr_call(ri->fn, arg, &code_n);
    if (!entry) return 16;
    *out = value_u64(((jit_entry_fn)entry)());
    fprintf(stderr, "jit.code.bytes=%zu\n", code_n);
    return 0;
  }
  if (ri->sig == SIG_I32_PTR) {
    *out = value_i64((int64_t)((ffi_i32_ptr_fn)ri->fn)(arg));
    return 0;
  }
  fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
  return 17;
}

static int call_import2(const RuntimeImport *ri, const char *arg0, const char *arg1, Value *out) {
  if (!arg0 || !arg1) return 13;
  if (ri->sig != SIG_I32_PTR_PTR) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_ptr_ptr_fn)ri->fn)(arg0, arg1));
  return 0;
}

static int call_import0(const RuntimeImport *ri, Value *out) {
  if (ri->sig != SIG_I32_VOID) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_void_fn)ri->fn)());
  return 0;
}

static int call_import_i32(const RuntimeImport *ri, int32_t arg, Value *out) {
  if (ri->sig != SIG_I32_I32) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_i32_fn)ri->fn)((int)arg));
  return 0;
}

static int resolve_blob(const Blob *b, int quiet) {
  uint32_t ok = 0;
  for (uint32_t i = 0; i < b->import_count; ++i) {
    RuntimeImport ri = {0};
    int rc = resolve_import_ref(b, i, &ri);
    if (rc != 0) return rc;
    ok++;
    if (!quiet) {
      printf("resolve.%u=%s:%s sig=%s ok\n", i, ri.lib, ri.sym, sig_name(ri.sig));
    }
  }
  printf("resolve.imports=%u\n", b->import_count);
  printf("resolve.ok=%u\n", ok);
  return 0;
}

static int execute_blob(const Blob *b) {
  Value last = value_u64(0);
  uint32_t pc = 0;
  while (pc < b->instr_count) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 10;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    RuntimeImport ri = {0};
    int rc = 0;
    if (op == OP_RET_LAST) {
      printf("ret=");
      print_value(stdout, last);
      printf("\n");
      return 0;
    }
    if (op == OP_RESOLVE_IMPORT) {
      rc = resolve_import_ref(b, arg0, &ri);
      if (rc != 0) return rc;
      last = value_ptr(ri.fn);
      printf("resolve.%u=%s:%s sig=%s ok\n", pc, ri.lib, ri.sym, sig_name(ri.sig));
      pc++;
      continue;
    }
    if (op == OP_EXPECT_U64) {
      uint64_t expected = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_expect_u64(last, expected)) {
        fprintf(stderr, "expect.%u=fail expected=%llu actual=", pc,
                (unsigned long long)expected);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%llu\n", pc, (unsigned long long)expected);
      pc++;
      continue;
    }
    if (op == OP_EXPECT_I64) {
      int64_t expected = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_expect_i64(last, expected)) {
        fprintf(stderr, "expect.%u=fail expected=%lld actual=", pc, (long long)expected);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%lld\n", pc, (long long)expected);
      pc++;
      continue;
    }
    if (op == OP_EXPECT_BOOL) {
      if (!value_expect_bool(last, (int)arg0)) {
        fprintf(stderr, "expect.%u=fail expected=%s actual=", pc, arg0 ? "true" : "false");
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%s\n", pc, arg0 ? "true" : "false");
      pc++;
      continue;
    }
    if (op == OP_EXPECT_PTR) {
      if (!value_expect_ptr(last, (int)arg0)) {
        fprintf(stderr, "expect.%u=fail expected=%s actual=", pc, arg0 ? "nonnull" : "null");
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%s\n", pc, arg0 ? "nonnull" : "null");
      pc++;
      continue;
    }
    if (op == OP_BRANCH_BOOL) {
      if (last.kind != VAL_BOOL) {
        fprintf(stderr, "type.branch=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 21;
      }
      if (arg0 >= b->instr_count) {
        fprintf(stderr, "branch.%u=bad_target %u\n", pc, arg0);
        return 22;
      }
      printf("branch.%u=%s target=%u\n", pc, last.bits ? "taken" : "not-taken", arg0);
      pc = last.bits ? arg0 : pc + 1;
      continue;
    }
    if (op == OP_CONST_U64) {
      last = value_u64((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      printf("u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_I64) {
      last = value_i64((int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32)));
      printf("i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_BOOL) {
      last = value_bool((int)arg0);
      printf("bool.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_U64) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_u64(&last, rhs)) {
        fprintf(stderr, "type.add-u64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("add-u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_add_i64(&last, rhs)) {
        fprintf(stderr, "type.add-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("add-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_SUB_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_sub_i64(&last, rhs)) {
        fprintf(stderr, "type.sub-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("sub-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    rc = resolve_import_ref(b, arg0, &ri);
    if (rc != 0) return rc;
    if (op == OP_CALL_IMPORT_CONST) {
      rc = call_import1(&ri, const_string_ref(b, arg1), &last);
    } else if (op == OP_CALL_IMPORT_CONST2) {
      uint32_t c0 = arg1 & 0xffffu;
      uint32_t c1 = arg1 >> 16;
      rc = call_import2(&ri, const_string_ref(b, c0), const_string_ref(b, c1), &last);
    } else if (op == OP_CALL_IMPORT_VOID) {
      rc = call_import0(&ri, &last);
    } else if (op == OP_CALL_IMPORT_IMM) {
      rc = call_import_i32(&ri, (int32_t)arg1, &last);
    } else {
      fprintf(stderr, "unsupported.op=%u\n", op);
      return 11;
    }
    if (rc != 0) return rc;
    printf("call.%u=%s:%s result=", pc, ri.lib, ri.sym);
    print_value(stdout, last);
    printf("\n");
    pc++;
  }
  fprintf(stderr, "missing.ret\n");
  return 18;
}

static int dump_blob(const Blob *b) {
  printf("blob.format=%s\n", b->format == 1 ? "lbin" : "legacy-ljir");
  printf("blob.version=%u\n", b->version);
  printf("blob.imports=%u\n", b->import_count);
  printf("blob.consts=%u\n", b->const_count);
  printf("blob.instructions=%u\n", b->instr_count);
  printf("blob.strings=%u\n", b->string_size);
  for (uint32_t i = 0; i < b->import_count; ++i) {
    const unsigned char *r = import_row(b, i);
    uint32_t sig = rd32(r + 8);
    printf("import.%u=%s:%s sig=%s(%u)\n", i, blob_string(b, rd32(r)),
           blob_string(b, rd32(r + 4)), sig_name(sig), sig);
  }
  return 0;
}

static unsigned char *compile_source_path_to_blob(const char *src_path, size_t *out_blob_n) {
  size_t src_n = 0;
  unsigned char *src = read_file(src_path, &src_n);
  if (!src) {
    fprintf(stderr, "read=fail path=%s\n", src_path);
    return NULL;
  }
  Module m = {0};
  if (!parse_module((const char *)src, &m)) {
    fprintf(stderr, "parse=fail path=%s\n", src_path);
    free(src);
    module_free(&m);
    return NULL;
  }
  unsigned char *blob = compile_module(&m, out_blob_n);
  free(src);
  module_free(&m);
  return blob;
}

static int cmd_compile(const char *src_path, const char *out_path) {
  size_t blob_n = 0;
  unsigned char *blob = compile_source_path_to_blob(src_path, &blob_n);
  if (!blob || !write_file(out_path, blob, blob_n)) {
    fprintf(stderr, "compile=fail\n");
    free(blob);
    return 3;
  }
  printf("blob.format=%s\n", OUTPUT_FORMAT);
  printf("blob.bytes=%zu\n", blob_n);
  printf("blob.path=%s\n", out_path);
  free(blob);
  return 0;
}

static int cmd_run(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = execute_blob(&b);
  free(owned);
  return rc;
}

static int parse_size_arg(const char *s, size_t *out) {
  char *end = NULL;
  unsigned long long v = strtoull(s, &end, 10);
  if (!s[0] || !end || *end) return 0;
  *out = (size_t)v;
  return (unsigned long long)*out == v;
}

static const char NANO_MANIFEST_BEGIN[] = "# nano.manifest.begin";
static const char NANO_MANIFEST_END[] = "# nano.manifest.end";
static const char NANO_APP_PAYLOAD_MARKER[] = "__NANO_APP_PAYLOAD_BELOW__";

static int find_payload_start(const unsigned char *data, size_t n, const char *marker,
                              size_t *out) {
  size_t marker_n = strlen(marker);
  if (marker_n + 1 > n) return 0;
  for (size_t i = 0; i + marker_n < n; ++i) {
    int line_start = i == 0 || data[i - 1] == '\n';
    if (line_start && data[i + marker_n] == '\n' &&
        memcmp(data + i, marker, marker_n) == 0) {
      *out = i + marker_n + 1;
      return 1;
    }
  }
  return 0;
}

static int cmd_run_embedded(const char *container_path, const char *off_s, const char *size_s) {
  size_t rel_off = 0;
  size_t blob_n = 0;
  size_t container_n = 0;
  size_t payload_start = 0;
  if (!parse_size_arg(off_s, &rel_off) || !parse_size_arg(size_s, &blob_n)) {
    fprintf(stderr, "run-embedded=bad_offset_or_size\n");
    return 1;
  }
  unsigned char *container = read_file(container_path, &container_n);
  if (!container) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  if (!find_payload_start(container, container_n, NANO_APP_PAYLOAD_MARKER, &payload_start) ||
      rel_off > container_n - payload_start ||
      blob_n > container_n - payload_start - rel_off) {
    fprintf(stderr, "run-embedded=payload_bounds\n");
    free(container);
    return 2;
  }
  Blob b;
  if (!blob_init(&b, container + payload_start + rel_off, blob_n)) {
    fprintf(stderr, "run-embedded=blob_parse_fail\n");
    free(container);
    return 3;
  }
  int rc = execute_blob(&b);
  free(container);
  return rc;
}

static int manifest_find_size(const unsigned char *data, size_t n,
                              const char *key, size_t *out) {
  int in_manifest = 0;
  size_t pos = 0;
  size_t key_n = strlen(key);
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(NANO_MANIFEST_BEGIN) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_BEGIN, sizeof(NANO_MANIFEST_BEGIN) - 1) == 0) {
      in_manifest = 1;
      continue;
    }
    if (line_n == sizeof(NANO_MANIFEST_END) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_END, sizeof(NANO_MANIFEST_END) - 1) == 0) {
      return 0;
    }
    if (in_manifest && line_n > 2 + key_n && data[line_start] == '#' &&
        data[line_start + 1] == ' ' &&
        memcmp(data + line_start + 2, key, key_n) == 0 &&
        data[line_start + 2 + key_n] == '=') {
      char value_buf[32];
      size_t value_n = line_n - 3 - key_n;
      if (value_n >= sizeof(value_buf)) return 0;
      memcpy(value_buf, data + line_start + 3 + key_n, value_n);
      value_buf[value_n] = '\0';
      return parse_size_arg(value_buf, out);
    }
  }
  return 0;
}

static int cmd_run_app(const char *container_path) {
  size_t n = 0;
  size_t blob_off = 0;
  size_t blob_size = 0;
  char off_buf[32];
  char size_buf[32];
  unsigned char *data = read_file(container_path, &n);
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  if (!manifest_find_size(data, n, "nano.blob.offset", &blob_off) ||
      !manifest_find_size(data, n, "nano.blob.size", &blob_size)) {
    fprintf(stderr, "run-app=manifest_key_missing path=%s\n", container_path);
    free(data);
    return 2;
  }
  free(data);
  snprintf(off_buf, sizeof(off_buf), "%zu", blob_off);
  snprintf(size_buf, sizeof(size_buf), "%zu", blob_size);
  printf("run-app.path=%s\n", container_path);
  printf("run-app.blob.offset=%zu\n", blob_off);
  printf("run-app.blob.size=%zu\n", blob_size);
  return cmd_run_embedded(container_path, off_buf, size_buf);
}

static int run_executable_expect_exit(const char *path, const char *expected_s) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "run-expect-exit=bad_expected\n");
    return 1;
  }
#if defined(_WIN32)
  (void)path;
  fprintf(stderr, "run-expect-exit=unsupported_platform\n");
  return 2;
#else
  pid_t pid = fork();
  if (pid < 0) {
    fprintf(stderr, "run-expect-exit=fork_fail path=%s\n", path);
    return 2;
  }
  if (pid == 0) {
    char *const argv[] = {(char *)path, NULL};
    execv(path, argv);
    _exit(127);
  }
  int status = 0;
  if (waitpid(pid, &status, 0) < 0) {
    fprintf(stderr, "run-expect-exit=wait_fail path=%s\n", path);
    return 3;
  }
  printf("run-expect-exit.path=%s\n", path);
  printf("run-expect-exit.expected=%zu\n", expected);
  if (WIFEXITED(status)) {
    int actual = WEXITSTATUS(status);
    printf("run-expect-exit.actual=%d\n", actual);
    if (actual == (int)expected) {
      printf("run-expect-exit.ok=1\n");
      return 0;
    }
    fprintf(stderr, "run-expect-exit=mismatch expected=%zu actual=%d\n", expected, actual);
    return 5;
  }
  if (WIFSIGNALED(status)) {
    fprintf(stderr, "run-expect-exit=signaled signal=%d\n", WTERMSIG(status));
    return 4;
  }
  fprintf(stderr, "run-expect-exit=unknown_status\n");
  return 4;
#endif
}

static int cmd_dump(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = dump_blob(&b);
  free(owned);
  return rc;
}

static int cmd_hash(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  printf("blob.bytes=%zu\n", b.size);
  printf("blob.fnv1a64=%016llx\n", (unsigned long long)fnv1a64(owned, b.size));
  free(owned);
  return 0;
}

static int cmd_file_size(const char *path) {
  FILE *f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "file-size=read_fail path=%s\n", path);
    return 1;
  }
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    fprintf(stderr, "file-size=seek_fail path=%s\n", path);
    return 1;
  }
  long n = ftell(f);
  fclose(f);
  if (n < 0) {
    fprintf(stderr, "file-size=tell_fail path=%s\n", path);
    return 1;
  }
  printf("%ld\n", n);
  return 0;
}

static int cmd_file_hash(const char *path) {
  size_t n = 0;
  unsigned char *data = read_file(path, &n);
  if (!data) {
    fprintf(stderr, "file-hash=read_fail path=%s\n", path);
    return 1;
  }
  printf("%016llx\n", (unsigned long long)fnv1a64(data, n));
  free(data);
  return 0;
}

static int compare_files(const char *left_path, const char *right_path, const char *label) {
  size_t left_n = 0;
  size_t right_n = 0;
  unsigned char *left = read_file(left_path, &left_n);
  unsigned char *right = read_file(right_path, &right_n);
  int rc = 0;
  if (!left || !right) {
    fprintf(stderr, "%s=read_fail\n", label);
    rc = 2;
  } else if (left_n != right_n || memcmp(left, right, left_n) != 0) {
    fprintf(stderr, "%s=diff left=%s right=%s\n", label, left_path, right_path);
    rc = 2;
  } else {
    printf("%s.ok bytes=%zu\n", label, left_n);
  }
  free(left);
  free(right);
  return rc;
}

static int cmd_compare(const char *left_path, const char *right_path) {
  return compare_files(left_path, right_path, "compare");
}

static int cmd_resolve(const char *blob_path, int quiet) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = resolve_blob(&b, quiet);
  free(owned);
  return rc;
}

static int cmd_inspect_app(const char *container_path);
static int cmd_pack_app(const char *out_path, const char *x86_path, const char *arm_path,
                        const char *blob_path);
static int cmd_emit_elf64_exit(const char *out_path, const char *code_s);
static int cmd_aot_elf64_exit(const char *blob_path, const char *out_path);
static int cmd_aot_elf64_obj_ret(const char *blob_path, const char *out_path,
                                 const char *symbol);
static int cmd_aot_elf64_code(const char *blob_path, const char *out_path);
static int cmd_aot_elf64_obj_code(const char *blob_path, const char *out_path,
                                  const char *symbol);
static int cmd_compile_elf64_code(const char *src_path, const char *out_path);
static int cmd_compile_elf64_obj_code(const char *src_path, const char *out_path,
                                      const char *symbol);
static int cmd_compile_elf64_exe(const char *src_path, const char *out_path,
                                 const char *symbol);
static int cmd_emit_elf64_obj_ret(const char *out_path, const char *symbol,
                                  const char *value_s);
static int cmd_emit_elf64_obj_call(const char *out_path, const char *local,
                                   const char *external);
static int cmd_link_elf64_exe(int argc, char **argv);
static int cmd_link_expect_exit(int argc, char **argv);

static int run_link_elf64_exe(const char *out_path, const char *entry_name,
                              const char *first_obj, char **extra_args,
                              size_t extra_arg_count) {
  size_t obj_count = 1 + extra_arg_count;
  size_t link_argc = 4 + obj_count;
  char **link_argv = (char **)calloc(link_argc, sizeof(*link_argv));
  int rc = 2;
  if (!link_argv) return rc;
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)entry_name;
  link_argv[4] = (char *)first_obj;
  for (size_t i = 0; i < extra_arg_count; ++i) {
    link_argv[5 + i] = extra_args[i];
  }
  rc = cmd_link_elf64_exe((int)link_argc, link_argv);
  free(link_argv);
  return rc;
}

static int check_link_expect_exit(const char *expected_s, const char *out_path,
                                  const char *entry_name, const char *first_obj,
                                  char **extra_args, size_t extra_arg_count,
                                  const char *label) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "%s=bad_expected\n", label);
    return 2;
  }
  int link_rc = run_link_elf64_exe(out_path, entry_name, first_obj,
                                   extra_args, extra_arg_count);
  if ((size_t)link_rc != expected) {
    fprintf(stderr, "%s=unexpected expected=%zu actual=%d\n", label, expected, link_rc);
    return 2;
  }
  printf("%s.ok=%zu\n", label, expected);
  return 0;
}

static int cmd_run_bootstrap_plan(const char *plan_path) {
  size_t n = 0;
  unsigned char *src = read_file(plan_path, &n);
  BootstrapPlan plan = {0};
  int rc = 0;
  if (!src || !parse_bootstrap_plan((const char *)src, &plan)) {
    fprintf(stderr, "bootstrap-plan=parse_fail path=%s\n", plan_path);
    free(src);
    bootstrap_plan_free(&plan);
    return 1;
  }
  printf("bootstrap-plan.path=%s\n", plan_path);
  printf("bootstrap-plan.steps=%zu\n", plan.step_count);
  for (size_t i = 0; i < plan.step_count; ++i) {
    const BootstrapStep *step = &plan.steps[i];
    if (step->kind == BOOTSTRAP_STEP_COMPILE) {
      printf("bootstrap-step.%zu=compile\n", i);
      rc = cmd_compile(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_COMPARE) {
      printf("bootstrap-step.%zu=compare\n", i);
      rc = compare_files(step->arg0, step->arg1, "bootstrap-compare");
    } else if (step->kind == BOOTSTRAP_STEP_HASH) {
      printf("bootstrap-step.%zu=hash\n", i);
      rc = cmd_hash(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_DUMP) {
      printf("bootstrap-step.%zu=dump\n", i);
      rc = cmd_dump(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_FILE_SIZE) {
      printf("bootstrap-step.%zu=file-size\n", i);
      rc = cmd_file_size(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_FILE_HASH) {
      printf("bootstrap-step.%zu=file-hash\n", i);
      rc = cmd_file_hash(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_EMIT_ELF64_EXIT) {
      printf("bootstrap-step.%zu=emit-elf64-exit\n", i);
      rc = cmd_emit_elf64_exit(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_AOT_ELF64_EXIT) {
      printf("bootstrap-step.%zu=aot-elf64-exit\n", i);
      rc = cmd_aot_elf64_exit(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_AOT_ELF64_OBJ_RET) {
      printf("bootstrap-step.%zu=aot-elf64-obj-ret\n", i);
      rc = cmd_aot_elf64_obj_ret(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_AOT_ELF64_CODE) {
      printf("bootstrap-step.%zu=aot-elf64-code\n", i);
      rc = cmd_aot_elf64_code(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_AOT_ELF64_OBJ_CODE) {
      printf("bootstrap-step.%zu=aot-elf64-obj-code\n", i);
      rc = cmd_aot_elf64_obj_code(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_COMPILE_ELF64_CODE) {
      printf("bootstrap-step.%zu=compile-elf64-code\n", i);
      rc = cmd_compile_elf64_code(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_COMPILE_ELF64_OBJ_CODE) {
      printf("bootstrap-step.%zu=compile-elf64-obj-code\n", i);
      rc = cmd_compile_elf64_obj_code(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_COMPILE_ELF64_EXE) {
      printf("bootstrap-step.%zu=compile-elf64-exe\n", i);
      rc = cmd_compile_elf64_exe(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_EMIT_ELF64_OBJ_RET) {
      printf("bootstrap-step.%zu=emit-elf64-obj-ret\n", i);
      rc = cmd_emit_elf64_obj_ret(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_EMIT_ELF64_OBJ_CALL) {
      printf("bootstrap-step.%zu=emit-elf64-obj-call\n", i);
      rc = cmd_emit_elf64_obj_call(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_LINK_ELF64_EXE) {
      printf("bootstrap-step.%zu=link-elf64-exe\n", i);
      rc = run_link_elf64_exe(step->arg0, step->arg1, step->arg2,
                              step->extra_args, step->extra_arg_count);
    } else if (step->kind == BOOTSTRAP_STEP_LINK_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=link-expect-exit\n", i);
      rc = check_link_expect_exit(step->arg0, step->arg1, step->arg2, step->arg3,
                                  step->extra_args, step->extra_arg_count,
                                  "bootstrap-link-expect-exit");
    } else if (step->kind == BOOTSTRAP_STEP_RESOLVE_QUIET) {
      printf("bootstrap-step.%zu=resolve-quiet\n", i);
      rc = cmd_resolve(step->arg0, 1);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=run-expect-exit\n", i);
      rc = run_executable_expect_exit(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APP) {
      printf("bootstrap-step.%zu=pack-app\n", i);
      rc = cmd_pack_app(step->arg0, step->arg1, step->arg2, step->arg3);
    } else if (step->kind == BOOTSTRAP_STEP_INSPECT_APP) {
      printf("bootstrap-step.%zu=inspect-app\n", i);
      rc = cmd_inspect_app(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_APP) {
      printf("bootstrap-step.%zu=run-app\n", i);
      rc = cmd_run_app(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_RUN) {
      printf("bootstrap-step.%zu=run\n", i);
      rc = cmd_run(step->arg0);
    } else {
      rc = 2;
    }
    if (rc != 0) break;
  }
  free(src);
  bootstrap_plan_free(&plan);
  return rc;
}
static int cmd_inspect_app(const char *container_path) {
  size_t n = 0;
  unsigned char *data = read_file(container_path, &n);
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  int in_manifest = 0;
  int found = 0;
  size_t pos = 0;
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(NANO_MANIFEST_BEGIN) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_BEGIN, sizeof(NANO_MANIFEST_BEGIN) - 1) == 0) {
      in_manifest = 1;
      found = 1;
      continue;
    }
    if (line_n == sizeof(NANO_MANIFEST_END) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_END, sizeof(NANO_MANIFEST_END) - 1) == 0) {
      free(data);
      return found ? 0 : 2;
    }
    if (in_manifest && line_n >= 2 && data[line_start] == '#' &&
        data[line_start + 1] == ' ') {
      fwrite(data + line_start + 2, 1, line_n - 2, stdout);
      fputc('\n', stdout);
    }
  }
  fprintf(stderr, "inspect-app=manifest_missing\n");
  free(data);
  return 2;
}

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
#define ELF64_MACHINE_X86_64 62u

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

static void wr_elf64_ehdr_exec(unsigned char *p, uint64_t entry, uint64_t phoff, uint16_t phnum) {
  wr_elf64_ident(p);
  wr16(p + 16, 2);
  wr16(p + 18, ELF64_MACHINE_X86_64);
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

static int emit_elf64_exec_rx_file(const char *out_path, const unsigned char *code,
                                   size_t code_n) {
  size_t file_n = ELF64_EXEC_CODE_OFF + code_n;
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  if (!out) return 0;

  wr_elf64_ehdr_exec(out, ELF64_EXEC_BASE + ELF64_EXEC_CODE_OFF, ELF64_EHDR_SIZE, 1);
  wr_elf64_phdr(out + ELF64_EHDR_SIZE, 1, 5, 0, ELF64_EXEC_BASE, ELF64_EXEC_BASE,
                file_n, file_n, 0x1000);

  memcpy(out + ELF64_EXEC_CODE_OFF, code, code_n);
  int ok = write_file(out_path, out, file_n) && make_executable(out_path);
  free(out);
  return ok;
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
  return emit_elf64_exec_rx_file(out_path, code, code_n);
}

static int emit_elf64_obj_text_file(const char *out_path, const char *symbol,
                                    const unsigned char *text, size_t text_n) {
  const Elf64ObjSymbol syms[] = {
    {symbol, 0x12, 1, 0, text_n},
  };
  return emit_elf64_obj_file(out_path, text, text_n, syms, 1, NULL, 0);
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
  const unsigned char *symtab;
  size_t sym_count;
  const unsigned char *strtab;
  size_t strtab_size;
  const unsigned char *rela;
  size_t rela_count;
} ElfObj;

typedef struct {
  const char *name;
  size_t obj_idx;
  uint64_t value;
} LinkSym;

static int is_elf(const unsigned char *data, size_t n);

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

static int link_add_text_symbols(const ElfObj *o, size_t obj_idx, LinkSym **syms,
                                 size_t *sym_count, size_t *sym_cap) {
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
      (LinkSym){name, obj_idx, ELF64_EXEC_BASE + ELF64_EXEC_CODE_OFF + o->out_off + elf_sym_value(o, s)};
  }
  return 1;
}

static int link_apply_relocations(Buf *code, const ElfObj *o, const LinkSym *syms,
                                  size_t sym_count) {
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
      target = ELF64_EXEC_BASE + ELF64_EXEC_CODE_OFF + o->out_off + elf_sym_value(o, sym_idx);
    } else {
      name = elf_sym_name(o, sym_idx);
      if (!name || !link_find_sym(syms, sym_count, name, &target)) {
        fprintf(stderr, "link-elf64-exe=symbol_missing symbol=%s\n", name ? name : "?");
        return 0;
      }
    }
    uint64_t place = ELF64_EXEC_BASE + ELF64_EXEC_CODE_OFF + o->out_off + r_off;
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

  size_t code_off = 14;
  Buf code = {0};
  for (int i = 0; i < obj_count; ++i) {
    owned[i] = read_file(argv[4 + i], &owned_n[i]);
    if (!owned[i] || !parse_elf_obj(owned[i], owned_n[i], &objs[i])) {
      fprintf(stderr, "link-elf64-exe=parse_fail path=%s\n", argv[4 + i]);
      goto done;
    }
    objs[i].out_off = code_off;
    code_off += objs[i].text_size;
    if (!link_add_text_symbols(&objs[i], (size_t)i, &syms, &sym_count, &sym_cap)) goto done;
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
  }

  uint64_t entry_addr = 0;
  if (!link_find_sym(syms, sym_count, entry_name, &entry_addr)) {
    fprintf(stderr, "link-elf64-exe=entry_missing symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  int64_t entry_rel = (int64_t)entry_addr - (int64_t)(ELF64_EXEC_BASE + ELF64_EXEC_CODE_OFF + 5);
  uint32_t rel32 = 0;
  if (!link_rel32_checked(entry_rel, &rel32)) {
    fprintf(stderr, "link-elf64-exe=entry_out_of_range symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  wr32(code.data + 1, rel32);

  for (int i = 0; i < obj_count; ++i) {
    if (!link_apply_relocations(&code, &objs[i], syms, sym_count)) {
      rc = 4;
      goto done;
    }
  }

  if (!emit_elf64_code_file(out_path, code.data, code.len)) {
    fprintf(stderr, "link-elf64-exe=write_fail path=%s\n", out_path);
    rc = 5;
    goto done;
  }
  printf("link.output=%s\n", out_path);
  printf("link.objects=%d\n", obj_count);
  printf("link.code.bytes=%zu\n", code.len);
  rc = 0;

done:
  link_cleanup(owned, owned_n, objs, obj_count, syms, &code);
  return rc;
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

static int emit_elf64_exit_file(const char *out_path, uint8_t exit_code) {
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

static int compile_pure_blob_to_x86(const Blob *b, Buf *code, int exit_style) {
  int saw_ret = 0;
  int last_kind = 0;
  Buf expect_patches = {0};
  Buf branch_patches = {0};
  uint32_t *pc_offs = (uint32_t *)calloc(b->instr_count ? b->instr_count : 1, sizeof(*pc_offs));
  if (!pc_offs) return 0;
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
    } else if (op == OP_EXPECT_U64 || op == OP_EXPECT_I64 || op == OP_EXPECT_BOOL) {
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
      } else {
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
      }
      {
        unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
        buf_put(code, jne_fail, sizeof(jne_fail));
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
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  return 1;

fail:
  free(pc_offs);
  free(expect_patches.data);
  free(branch_patches.data);
  return 0;
}

static int compile_pure_u64_blob_to_x86_exit(const Blob *b, Buf *code) {
  return compile_pure_blob_to_x86(b, code, 1);
}

static int compile_pure_u64_blob_to_x86_ret(const Blob *b, Buf *code) {
  return compile_pure_blob_to_x86(b, code, 0);
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

static int compile_aot_func_to_x86_ret(const AotFunc *func, Buf *code, Buf *call_patches) {
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
        stmt->kind == AOT_STMT_EXPECT_U64) {
      if (stmt->imm > UINT32_MAX) goto fail;
    }
    if (stmt->kind == AOT_STMT_ADD_I64 || stmt->kind == AOT_STMT_SUB_I64) {
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
      unsigned char call_rel32[5] = {0xe8, 0, 0, 0, 0};
      AotCallPatch patch = {(uint32_t)(code->len + 1), stmt->target_name};
      buf_put(code, call_rel32, sizeof(call_rel32));
      buf_put(call_patches, &patch, sizeof(patch));
      last_kind = VAL_U64;
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

  codes = (Buf *)calloc(m->func_count, sizeof(*codes));
  call_patches = (Buf *)calloc(m->func_count, sizeof(*call_patches));
  text_offs = (size_t *)calloc(m->func_count, sizeof(*text_offs));
  func_sym_idx = (uint32_t *)calloc(m->func_count, sizeof(*func_sym_idx));
  syms = (Elf64ObjSymbol *)calloc(m->func_count, sizeof(*syms));
  if (!codes || !call_patches || !text_offs || !func_sym_idx || !syms) goto done;

  for (size_t i = 0; i < m->func_count; ++i) {
    if (!compile_aot_func_to_x86_ret(&m->funcs[i], &codes[i], &call_patches[i])) goto done;
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
  free(syms);
  free(relas);
  return ok;
}

static int cmd_aot_elf64_code(const char *blob_path, const char *out_path) {
  Blob b;
  unsigned char *owned = NULL;
  Buf code = {0};
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int ok = compile_pure_u64_blob_to_x86_exit(&b, &code);
  free(owned);
  if (!ok) {
    free(code.data);
    fprintf(stderr, "aot-elf64-code=unsupported_blob\n");
    return 2;
  }
  if (!emit_elf64_code_file(out_path, code.data, code.len)) {
    free(code.data);
    fprintf(stderr, "aot-elf64-code=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.code.output=%s\n", out_path);
  printf("aot.code.bytes=%zu\n", 120 + code.len);
  printf("aot.code.x86.bytes=%zu\n", code.len);
  free(code.data);
  return 0;
}

static int cmd_compile_elf64_code(const char *src_path, const char *out_path) {
  size_t blob_n = 0;
  unsigned char *blob_data = compile_source_path_to_blob(src_path, &blob_n);
  Blob b;
  Buf code = {0};
  if (!blob_data || !blob_init(&b, blob_data, blob_n)) {
    fprintf(stderr, "compile-elf64-code=compile_fail\n");
    free(blob_data);
    return 1;
  }
  int ok = compile_pure_u64_blob_to_x86_exit(&b, &code);
  free(blob_data);
  if (!ok) {
    free(code.data);
    fprintf(stderr, "compile-elf64-code=unsupported_source\n");
    return 2;
  }
  if (!emit_elf64_code_file(out_path, code.data, code.len)) {
    free(code.data);
    fprintf(stderr, "compile-elf64-code=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("compile.elf64.output=%s\n", out_path);
  printf("compile.elf64.bytes=%zu\n", 120 + code.len);
  printf("compile.elf64.x86.bytes=%zu\n", code.len);
  free(code.data);
  return 0;
}

static int cmd_aot_elf64_obj_code(const char *blob_path, const char *out_path,
                                  const char *symbol) {
  Blob b;
  unsigned char *owned = NULL;
  Buf code = {0};
  if (!symbol[0]) {
    fprintf(stderr, "aot-elf64-obj-code=bad_symbol\n");
    return 1;
  }
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int ok = compile_pure_u64_blob_to_x86_ret(&b, &code);
  free(owned);
  if (!ok) {
    free(code.data);
    fprintf(stderr, "aot-elf64-obj-code=unsupported_blob\n");
    return 2;
  }
  if (!emit_elf64_obj_text_file(out_path, symbol, code.data, code.len)) {
    free(code.data);
    fprintf(stderr, "aot-elf64-obj-code=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.obj.code.output=%s\n", out_path);
  printf("aot.obj.code.symbol=%s\n", symbol);
  printf("aot.obj.code.x86.bytes=%zu\n", code.len);
  free(code.data);
  return 0;
}

static int cmd_compile_elf64_obj_code(const char *src_path, const char *out_path,
                                      const char *symbol) {
  size_t src_n = 0;
  unsigned char *src = read_file(src_path, &src_n);
  AotModule m = {0};
  if (!symbol[0]) {
    fprintf(stderr, "compile-elf64-obj-code=bad_symbol\n");
    return 1;
  }
  if (!src || !parse_aot_module((const char *)src, &m)) {
    fprintf(stderr, "compile-elf64-obj-code=compile_fail\n");
    free(src);
    aot_module_free(&m);
    return 1;
  }
  if (!compile_aot_module_to_elf64_obj(&m, out_path, symbol)) {
    fprintf(stderr, "compile-elf64-obj-code=unsupported_source\n");
    free(src);
    aot_module_free(&m);
    return 2;
  }
  free(src);
  aot_module_free(&m);
  printf("compile.obj.code.output=%s\n", out_path);
  printf("compile.obj.code.symbol=%s\n", symbol);
  printf("compile.obj.code.mode=multi-func\n");
  return 0;
}

static int cmd_compile_elf64_exe(const char *src_path, const char *out_path,
                                 const char *symbol) {
  size_t src_n = 0;
  unsigned char *src = read_file(src_path, &src_n);
  AotModule m = {0};
  size_t tmp_n = strlen(out_path) + 7;
  char *tmp_obj = (char *)malloc(tmp_n);
  int rc = 0;
  if (!symbol[0] || !tmp_obj) {
    fprintf(stderr, "compile-elf64-exe=bad_args\n");
    free(src);
    free(tmp_obj);
    return 1;
  }
  snprintf(tmp_obj, tmp_n, "%s.tmp.o", out_path);
  if (!src || !parse_aot_module((const char *)src, &m)) {
    fprintf(stderr, "compile-elf64-exe=compile_fail\n");
    rc = 1;
    goto done;
  }
  if (!compile_aot_module_to_elf64_obj(&m, tmp_obj, symbol)) {
    fprintf(stderr, "compile-elf64-exe=unsupported_source\n");
    rc = 2;
    goto done;
  }
  rc = run_link_elf64_exe(out_path, symbol, tmp_obj, NULL, 0);
  if (rc == 0) {
    printf("compile.elf64.exe.output=%s\n", out_path);
    printf("compile.elf64.exe.symbol=%s\n", symbol);
    printf("compile.elf64.exe.mode=multi-func\n");
  }

done:
  if (tmp_obj) remove(tmp_obj);
  free(tmp_obj);
  free(src);
  aot_module_free(&m);
  return rc;
}

static int is_elf(const unsigned char *data, size_t n) {
  return n >= 4 && data[0] == 0x7f && data[1] == 'E' && data[2] == 'L' && data[3] == 'F';
}

static int cmd_pack_ape(const char *out_path, const char *x86_path, const char *arm_path) {
  size_t x86_n = 0;
  size_t arm_n = 0;
  unsigned char *x86 = read_file(x86_path, &x86_n);
  unsigned char *arm = read_file(arm_path, &arm_n);
  if (!x86 || !arm || !is_elf(x86, x86_n) || !is_elf(arm, arm_n)) {
    fprintf(stderr, "pack-ape=input_not_elf\n");
    free(x86);
    free(arm);
    return 1;
  }

  const char *stub_fmt =
      "#!/bin/sh\n"
      "set -eu\n"
      "arch=\"$(uname -m)\"\n"
      "case \"$arch\" in\n"
      "  x86_64|amd64) off=0; size=%zu; suffix=x86_64 ;;\n"
      "  aarch64|arm64) off=%zu; size=%zu; suffix=aarch64 ;;\n"
      "  *) echo \"nano pack-ape: unsupported arch $arch\" >&2; exit 126 ;;\n"
      "esac\n"
      "payload_line=$(awk '/^__NANO_APE_PAYLOAD_BELOW__$/ { print NR + 1; exit }' \"$0\")\n"
      "if [ -z \"${payload_line:-}\" ]; then echo \"nano pack-ape: payload marker missing\" >&2; exit 126; fi\n"
      "tmp=\"${TMPDIR:-/tmp}/nano-ape-$$-$suffix\"\n"
      "trap 'rm -f \"$tmp\"' EXIT HUP INT TERM\n"
      "tail -n +\"$payload_line\" \"$0\" | dd bs=1 skip=\"$off\" count=\"$size\" of=\"$tmp\" 2>/dev/null\n"
      "chmod +x \"$tmp\"\n"
      "exec \"$tmp\" \"$@\"\n"
      "exit 127\n"
      "__NANO_APE_PAYLOAD_BELOW__\n";

  int stub_n = snprintf(NULL, 0, stub_fmt, x86_n, x86_n, arm_n);
  if (stub_n < 0) {
    free(x86);
    free(arm);
    return 2;
  }
  char *stub = (char *)malloc((size_t)stub_n + 1);
  if (!stub) {
    free(x86);
    free(arm);
    return 2;
  }
  snprintf(stub, (size_t)stub_n + 1, stub_fmt, x86_n, x86_n, arm_n);

  Buf out = {0};
  buf_put(&out, stub, (size_t)stub_n);
  buf_put(&out, x86, x86_n);
  buf_put(&out, arm, arm_n);
  int ok = write_file(out_path, out.data, out.len) && make_executable(out_path);
  if (ok) {
    printf("pack-ape.output=%s\n", out_path);
    printf("pack-ape.bytes=%zu\n", out.len);
    printf("pack-ape.x86_64.bytes=%zu\n", x86_n);
    printf("pack-ape.aarch64.bytes=%zu\n", arm_n);
  } else {
    fprintf(stderr, "pack-ape=write_fail path=%s\n", out_path);
  }

  free(stub);
  free(out.data);
  free(x86);
  free(arm);
  return ok ? 0 : 3;
}

static int cmd_pack_app(const char *out_path, const char *x86_path, const char *arm_path,
                        const char *blob_path) {
  size_t x86_n = 0;
  size_t arm_n = 0;
  size_t blob_n = 0;
  unsigned char *x86 = read_file(x86_path, &x86_n);
  unsigned char *arm = read_file(arm_path, &arm_n);
  unsigned char *blob = read_file(blob_path, &blob_n);
  Blob checked_blob;
  if (!x86 || !arm || !blob || !is_elf(x86, x86_n) || !is_elf(arm, arm_n) ||
      !blob_init(&checked_blob, blob, blob_n)) {
    fprintf(stderr, "pack-app=input_invalid\n");
    free(x86);
    free(arm);
    free(blob);
    return 1;
  }

  const char *stub_fmt =
      "#!/bin/sh\n"
      "set -eu\n"
      "arch=\"$(uname -m)\"\n"
      "case \"$arch\" in\n"
      "  x86_64|amd64) exe_off=0; exe_size=%zu; suffix=x86_64 ;;\n"
      "  aarch64|arm64) exe_off=%zu; exe_size=%zu; suffix=aarch64 ;;\n"
      "  *) echo \"nano pack-app: unsupported arch $arch\" >&2; exit 126 ;;\n"
      "esac\n"
      "blob_off=%zu\n"
      "blob_size=%zu\n"
      "# nano.manifest.begin\n"
      "# nano.container=app-v1\n"
      "# nano.slice.x86_64.offset=0\n"
      "# nano.slice.x86_64.size=%zu\n"
      "# nano.slice.aarch64.offset=%zu\n"
      "# nano.slice.aarch64.size=%zu\n"
      "# nano.blob.offset=%zu\n"
      "# nano.blob.size=%zu\n"
      "# nano.manifest.end\n"
      "payload_line=$(awk '/^__NANO_APP_PAYLOAD_BELOW__$/ { print NR + 1; exit }' \"$0\")\n"
      "if [ -z \"${payload_line:-}\" ]; then echo \"nano pack-app: payload marker missing\" >&2; exit 126; fi\n"
      "tmp_exe=\"${TMPDIR:-/tmp}/nano-app-$$-$suffix\"\n"
      "trap 'rm -f \"$tmp_exe\"' EXIT HUP INT TERM\n"
      "tail -n +\"$payload_line\" \"$0\" | dd bs=1 skip=\"$exe_off\" count=\"$exe_size\" of=\"$tmp_exe\" 2>/dev/null\n"
      "chmod +x \"$tmp_exe\"\n"
      "exec \"$tmp_exe\" run-embedded \"$0\" \"$blob_off\" \"$blob_size\"\n"
      "exit 127\n"
      "__NANO_APP_PAYLOAD_BELOW__\n";

  int stub_n = snprintf(NULL, 0, stub_fmt, x86_n, x86_n, arm_n, x86_n + arm_n, blob_n,
                        x86_n, x86_n, arm_n, x86_n + arm_n, blob_n);
  if (stub_n < 0) {
    free(x86);
    free(arm);
    free(blob);
    return 2;
  }
  char *stub = (char *)malloc((size_t)stub_n + 1);
  if (!stub) {
    free(x86);
    free(arm);
    free(blob);
    return 2;
  }
  snprintf(stub, (size_t)stub_n + 1, stub_fmt, x86_n, x86_n, arm_n,
           x86_n + arm_n, blob_n, x86_n, x86_n, arm_n, x86_n + arm_n, blob_n);

  Buf out = {0};
  buf_put(&out, stub, (size_t)stub_n);
  buf_put(&out, x86, x86_n);
  buf_put(&out, arm, arm_n);
  buf_put(&out, blob, blob_n);
  int ok = write_file(out_path, out.data, out.len) && make_executable(out_path);
  if (ok) {
    printf("pack-app.output=%s\n", out_path);
    printf("pack-app.bytes=%zu\n", out.len);
    printf("pack-app.x86_64.bytes=%zu\n", x86_n);
    printf("pack-app.aarch64.bytes=%zu\n", arm_n);
    printf("pack-app.blob.bytes=%zu\n", blob_n);
  } else {
    fprintf(stderr, "pack-app=write_fail path=%s\n", out_path);
  }

  free(stub);
  free(out.data);
  free(x86);
  free(arm);
  free(blob);
  return ok ? 0 : 3;
}

static void usage(const char *argv0) {
  fprintf(stderr, "usage:\n");
  fprintf(stderr, "  %s compile input.%s output.%s\n", argv0, SOURCE_EXT, BLOB_EXT);
  fprintf(stderr, "  %s run program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s run-embedded container.com blob_offset blob_size\n", argv0);
  fprintf(stderr, "  %s inspect-app container.com\n", argv0);
  fprintf(stderr, "  %s run-app container.com\n", argv0);
  fprintf(stderr, "  %s emit-elf64-exit output.elf exit_code\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-ret output.o symbol value\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-call output.o local_symbol external_symbol\n", argv0);
  fprintf(stderr, "  %s aot-elf64-exit input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-ret input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-code input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-code input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s compile-elf64-code input.%s output.elf\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-elf64-obj-code input.%s output.o symbol\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-elf64-exe input.%s output.elf entry_symbol\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s link-elf64-exe output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s link-expect-exit expected output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s run-expect-exit executable expected_exit\n", argv0);
  fprintf(stderr, "  %s dump program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s hash program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s file-size path\n", argv0);
  fprintf(stderr, "  %s file-hash path\n", argv0);
  fprintf(stderr, "  %s compare left.%s right.%s\n", argv0, BLOB_EXT, BLOB_EXT);
  fprintf(stderr, "  %s resolve [--quiet] program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s run-bootstrap-plan plan.lisp\n", argv0);
  fprintf(stderr, "  %s pack-ape output.com x86_64.elf aarch64.elf\n", argv0);
  fprintf(stderr, "  %s pack-app output.com x86_64.elf aarch64.elf program.%s\n", argv0, BLOB_EXT);
}

int main(int argc, char **argv) {
  if (argc >= 2 && strcmp(argv[1], "compile") == 0 && argc == 4) {
    return cmd_compile(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "run") == 0 && argc == 3) {
    return cmd_run(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-embedded") == 0 && argc == 5) {
    return cmd_run_embedded(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-app") == 0 && argc == 3) {
    return cmd_inspect_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-app") == 0 && argc == 3) {
    return cmd_run_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-exit") == 0 && argc == 4) {
    return cmd_emit_elf64_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-obj-ret") == 0 && argc == 5) {
    return cmd_emit_elf64_obj_ret(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-obj-call") == 0 && argc == 5) {
    return cmd_emit_elf64_obj_call(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-exit") == 0 && argc == 4) {
    return cmd_aot_elf64_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-obj-ret") == 0 && argc == 5) {
    return cmd_aot_elf64_obj_ret(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-code") == 0 && argc == 4) {
    return cmd_aot_elf64_code(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-obj-code") == 0 && argc == 5) {
    return cmd_aot_elf64_obj_code(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-code") == 0 && argc == 4) {
    return cmd_compile_elf64_code(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-obj-code") == 0 && argc == 5) {
    return cmd_compile_elf64_obj_code(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-exe") == 0 && argc == 5) {
    return cmd_compile_elf64_exe(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "link-elf64-exe") == 0) {
    return cmd_link_elf64_exe(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "link-expect-exit") == 0) {
    return cmd_link_expect_exit(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "run-expect-exit") == 0 && argc == 4) {
    return run_executable_expect_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "dump") == 0 && argc == 3) {
    return cmd_dump(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "hash") == 0 && argc == 3) {
    return cmd_hash(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "file-size") == 0 && argc == 3) {
    return cmd_file_size(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "file-hash") == 0 && argc == 3) {
    return cmd_file_hash(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "compare") == 0 && argc == 4) {
    return cmd_compare(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve") == 0) {
    if (argc == 3) return cmd_resolve(argv[2], 0);
    if (argc == 4 && strcmp(argv[2], "--quiet") == 0) return cmd_resolve(argv[3], 1);
  }
  if (argc >= 2 && strcmp(argv[1], "run-bootstrap-plan") == 0 && argc == 3) {
    return cmd_run_bootstrap_plan(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-ape") == 0 && argc == 5) {
    return cmd_pack_ape(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-app") == 0 && argc == 6) {
    return cmd_pack_app(argv[2], argv[3], argv[4], argv[5]);
  }
  usage(argv[0]);
  return 2;
}
