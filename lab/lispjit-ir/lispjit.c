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
#endif

#if defined(__COSMOPOLITAN__)
extern void *cosmo_dlopen(const char *filename, int flags);
extern void *cosmo_dlsym(void *handle, const char *symbol);
#endif

#define HEADER_SIZE 32u
#define IMPORT_SIZE 16u
#define CONST_SIZE 16u
#define INSTR_SIZE 12u

#ifdef NANO_LISTP
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

#define SRC_FORM_CALL 1u
#define SRC_FORM_RESOLVE 2u
#define SRC_FORM_EXPECT 3u
#define SRC_FORM_CONST_U64 4u
#define SRC_FORM_ADD_U64 5u

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

static int parse_u64_atom(const char *s, uint64_t *out) {
  char *end = NULL;
  unsigned long long v = strtoull(s, &end, 10);
  if (!s || !s[0] || !end || *end) return 0;
  *out = (uint64_t)v;
  return (unsigned long long)*out == v;
}

static int parse_i32_atom(const char *s, int32_t *out) {
  char *end = NULL;
  long v = strtol(s, &end, 10);
  if (!s || !s[0] || !end || *end || v < INT32_MIN || v > INT32_MAX) return 0;
  *out = (int32_t)v;
  return 1;
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

static int parse_main_form(const char **p, Module *m) {
  while (1) {
    skip_ws(p);
    if (**p == ')') {
      (*p)++;
      return m->instr_count > 0;
    }
    if (!eat(p, '(')) return 0;
    char *head = parse_atom(p);
    if (!head) return 0;
    int ok = 0;
    if (strcmp(head, "resolve") == 0) {
      char *import_name = parse_atom(p);
      ok = import_name && eat(p, ')') &&
           add_instr(m, SRC_FORM_RESOLVE, import_name, NULL, NULL, 0);
    } else if (strcmp(head, "u64") == 0 || strcmp(head, "add-u64") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      uint32_t form = strcmp(head, "u64") == 0 ? SRC_FORM_CONST_U64 : SRC_FORM_ADD_U64;
      ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
           add_instr(m, form, NULL, NULL, NULL, imm);
      free(value);
    } else if (strcmp(head, "expect") == 0) {
      char *value = parse_atom(p);
      uint64_t expected = 0;
      ok = value && parse_u64_atom(value, &expected) && eat(p, ')') &&
           add_instr(m, SRC_FORM_EXPECT, NULL, NULL, NULL, expected);
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

static unsigned char *compile_module(const Module *m, size_t *out_n) {
  Buf out = {0};
  Buf imports = {0};
  Buf consts = {0};
  Buf instrs = {0};
  Buf strings = {0};

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

  for (size_t i = 0; i < m->instr_count; ++i) {
    const InstrDef *in = &m->instrs[i];
    if (in->form == SRC_FORM_CONST_U64 || in->form == SRC_FORM_ADD_U64) {
      emit_instr(&instrs, in->form == SRC_FORM_CONST_U64 ? OP_CONST_U64 : OP_ADD_U64,
                 (uint32_t)(in->imm & 0xffffffffu), (uint32_t)(in->imm >> 32));
      continue;
    }
    if (in->form == SRC_FORM_EXPECT) {
      emit_instr(&instrs, OP_EXPECT_U64, (uint32_t)(in->imm & 0xffffffffu),
                 (uint32_t)(in->imm >> 32));
      continue;
    }
    int import_idx = find_import(m, in->import_name);
    if (import_idx < 0) return NULL;
    if (in->form == SRC_FORM_RESOLVE) {
      emit_instr(&instrs, OP_RESOLVE_IMPORT, (uint32_t)import_idx, 0);
      continue;
    }
    uint32_t sig = m->imports[import_idx].sig;
    if (sig == SIG_I32_VOID) {
      if (in->const_name || in->const2_name) return NULL;
      emit_instr(&instrs, OP_CALL_IMPORT_VOID, (uint32_t)import_idx, 0);
    } else if (sig == SIG_I32_I32) {
      int32_t imm = 0;
      if (!in->const_name || in->const2_name || !parse_i32_atom(in->const_name, &imm)) {
        return NULL;
      }
      emit_instr(&instrs, OP_CALL_IMPORT_IMM, (uint32_t)import_idx, (uint32_t)imm);
    } else if (sig == SIG_U64_PTR || sig == SIG_I32_PTR) {
      int const_idx = in->const_name ? find_const(m, in->const_name) : -1;
      if (const_idx < 0 || in->const2_name) return NULL;
      emit_instr(&instrs, OP_CALL_IMPORT_CONST, (uint32_t)import_idx, (uint32_t)const_idx);
    } else if (sig == SIG_I32_PTR_PTR) {
      int const_idx = in->const_name ? find_const(m, in->const_name) : -1;
      int const2_idx = in->const2_name ? find_const(m, in->const2_name) : -1;
      if (const_idx < 0 || const2_idx < 0) return NULL;
      emit_instr(&instrs, OP_CALL_IMPORT_CONST2, (uint32_t)import_idx,
                 pack_const_pair((uint32_t)const_idx, (uint32_t)const2_idx));
    } else {
      fprintf(stderr, "signature.not_callable=%s\n", sig_name(sig));
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
  buf_put32(&out, (uint32_t)(m->instr_count + 1));
  buf_put32(&out, (uint32_t)strings.len);
  buf_put(&out, imports.data, imports.len);
  buf_put(&out, consts.data, consts.len);
  buf_put(&out, instrs.data, instrs.len);
  buf_put(&out, strings.data, strings.len);

  free(imports.data);
  free(consts.data);
  free(instrs.data);
  free(strings.data);
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

static int call_import1(const RuntimeImport *ri, const char *arg, uint64_t *out) {
  if (!arg) return 13;
  if (ri->sig == SIG_U64_PTR) {
    size_t code_n = 0;
    void *entry = emit_u64_ptr_call(ri->fn, arg, &code_n);
    if (!entry) return 16;
    *out = ((jit_entry_fn)entry)();
    fprintf(stderr, "jit.code.bytes=%zu\n", code_n);
    return 0;
  }
  if (ri->sig == SIG_I32_PTR) {
    *out = (uint64_t)(int64_t)((ffi_i32_ptr_fn)ri->fn)(arg);
    return 0;
  }
  fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
  return 17;
}

static int call_import2(const RuntimeImport *ri, const char *arg0, const char *arg1, uint64_t *out) {
  if (!arg0 || !arg1) return 13;
  if (ri->sig != SIG_I32_PTR_PTR) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = (uint64_t)(int64_t)((ffi_i32_ptr_ptr_fn)ri->fn)(arg0, arg1);
  return 0;
}

static int call_import0(const RuntimeImport *ri, uint64_t *out) {
  if (ri->sig != SIG_I32_VOID) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = (uint64_t)(int64_t)((ffi_i32_void_fn)ri->fn)();
  return 0;
}

static int call_import_i32(const RuntimeImport *ri, int32_t arg, uint64_t *out) {
  if (ri->sig != SIG_I32_I32) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = (uint64_t)(int64_t)((ffi_i32_i32_fn)ri->fn)((int)arg);
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
  uint64_t last = 0;
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 10;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    RuntimeImport ri = {0};
    int rc = 0;
    if (op == OP_RET_LAST) {
      printf("ret=%llu\n", (unsigned long long)last);
      return 0;
    }
    if (op == OP_RESOLVE_IMPORT) {
      rc = resolve_import_ref(b, arg0, &ri);
      if (rc != 0) return rc;
      printf("resolve.%u=%s:%s sig=%s ok\n", pc, ri.lib, ri.sym, sig_name(ri.sig));
      continue;
    }
    if (op == OP_EXPECT_U64) {
      uint64_t expected = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (last != expected) {
        fprintf(stderr, "expect.%u=fail expected=%llu actual=%llu\n", pc,
                (unsigned long long)expected, (unsigned long long)last);
        return 19;
      }
      printf("expect.%u=ok expected=%llu\n", pc, (unsigned long long)expected);
      continue;
    }
    if (op == OP_CONST_U64) {
      last = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      printf("u64.%u=%llu\n", pc, (unsigned long long)last);
      continue;
    }
    if (op == OP_ADD_U64) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      last += rhs;
      printf("add-u64.%u=%llu\n", pc, (unsigned long long)last);
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
    printf("call.%u=%s:%s result=%llu\n", pc, ri.lib, ri.sym,
           (unsigned long long)last);
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
  if (!find_payload_start(container, container_n, "__NANO_APP_PAYLOAD_BELOW__", &payload_start) ||
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

static int cmd_inspect_app(const char *container_path) {
  size_t n = 0;
  unsigned char *data = read_file(container_path, &n);
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  static const char begin[] = "# nano.manifest.begin";
  static const char end[] = "# nano.manifest.end";
  int in_manifest = 0;
  int found = 0;
  size_t pos = 0;
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(begin) - 1 &&
        memcmp(data + line_start, begin, sizeof(begin) - 1) == 0) {
      in_manifest = 1;
      found = 1;
      continue;
    }
    if (line_n == sizeof(end) - 1 &&
        memcmp(data + line_start, end, sizeof(end) - 1) == 0) {
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

static int emit_elf64_code_file(const char *out_path, const unsigned char *code, size_t code_n) {
  enum { EHDR = 64, PHDR = 56, CODE_OFF = 120 };
  size_t file_n = CODE_OFF + code_n;
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  if (!out) return 0;

  /* ELF64 little-endian executable with one RX PT_LOAD segment. */
  out[0] = 0x7f;
  out[1] = 'E';
  out[2] = 'L';
  out[3] = 'F';
  out[4] = 2;
  out[5] = 1;
  out[6] = 1;
  wr16(out + 16, 2);
  wr16(out + 18, 62);
  wr32(out + 20, 1);
  wr64(out + 24, 0x400000u + CODE_OFF);
  wr64(out + 32, EHDR);
  wr16(out + 52, EHDR);
  wr16(out + 54, PHDR);
  wr16(out + 56, 1);

  unsigned char *ph = out + EHDR;
  wr32(ph + 0, 1);
  wr32(ph + 4, 5);
  wr64(ph + 8, 0);
  wr64(ph + 16, 0x400000u);
  wr64(ph + 24, 0x400000u);
  wr64(ph + 32, file_n);
  wr64(ph + 40, file_n);
  wr64(ph + 48, 0x1000);

  memcpy(out + CODE_OFF, code, code_n);
  int ok = write_file(out_path, out, file_n) && make_executable(out_path);
  free(out);
  return ok;
}

static size_t align_up_size(size_t n, size_t a) {
  return (n + a - 1) & ~(a - 1);
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

static int emit_elf64_obj_text_file(const char *out_path, const char *symbol,
                                    const unsigned char *text, size_t text_n) {
  static const unsigned char shstr[] = "\0.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack";
  size_t sym_len = strlen(symbol);
  size_t strtab_n = 1 + sym_len + 1;

  size_t off_text = 64;
  size_t off_shstr = off_text + text_n;
  size_t off_strtab = off_shstr + sizeof(shstr);
  size_t off_symtab = align_up_size(off_strtab + strtab_n, 8);
  size_t symtab_n = 48;
  size_t off_shdr = align_up_size(off_symtab + symtab_n, 8);
  size_t file_n = off_shdr + 6 * 64;
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  if (!out) return 0;

  out[0] = 0x7f;
  out[1] = 'E';
  out[2] = 'L';
  out[3] = 'F';
  out[4] = 2;
  out[5] = 1;
  out[6] = 1;
  wr16(out + 16, 1);
  wr16(out + 18, 62);
  wr32(out + 20, 1);
  wr64(out + 40, off_shdr);
  wr16(out + 52, 64);
  wr16(out + 58, 64);
  wr16(out + 60, 6);
  wr16(out + 62, 2);

  memcpy(out + off_text, text, text_n);
  memcpy(out + off_shstr, shstr, sizeof(shstr));
  out[off_strtab] = 0;
  memcpy(out + off_strtab + 1, symbol, sym_len + 1);

  unsigned char *sym = out + off_symtab + 24;
  wr32(sym + 0, 1);
  sym[4] = 0x12;
  wr16(sym + 6, 1);
  wr64(sym + 8, 0);
  wr64(sym + 16, text_n);

  unsigned char *sh = out + off_shdr;
  wr_elf64_shdr(sh + 1 * 64, 1, 1, 0x6, 0, off_text, text_n, 0, 0, 16, 0);
  wr_elf64_shdr(sh + 2 * 64, 7, 3, 0, 0, off_shstr, sizeof(shstr), 0, 0, 1, 0);
  wr_elf64_shdr(sh + 3 * 64, 17, 2, 0, 0, off_symtab, symtab_n, 4, 1, 8, 24);
  wr_elf64_shdr(sh + 4 * 64, 25, 3, 0, 0, off_strtab, strtab_n, 0, 0, 1, 0);
  wr_elf64_shdr(sh + 5 * 64, 33, 1, 0, 0, 0, 0, 0, 0, 1, 0);

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
  static const unsigned char shstr[] =
    "\0.text\0.rela.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack";
  size_t local_len = strlen(local);
  size_t external_len = strlen(external);
  size_t local_name = 1;
  size_t external_name = local_name + local_len + 1;
  size_t strtab_n = 1 + local_len + 1 + external_len + 1;
  unsigned char text[6] = {0xe8, 0, 0, 0, 0, 0xc3};
  unsigned char rela[24] = {0};
  wr64(rela + 0, 1);
  wr64(rela + 8, ((uint64_t)2 << 32) | 4);
  wr64(rela + 16, (uint64_t)(int64_t)-4);

  size_t off_text = 64;
  size_t off_rela = align_up_size(off_text + sizeof(text), 8);
  size_t off_shstr = off_rela + sizeof(rela);
  size_t off_strtab = off_shstr + sizeof(shstr);
  size_t off_symtab = align_up_size(off_strtab + strtab_n, 8);
  size_t symtab_n = 72;
  size_t off_shdr = align_up_size(off_symtab + symtab_n, 8);
  size_t file_n = off_shdr + 7 * 64;
  unsigned char *out = (unsigned char *)calloc(1, file_n);
  if (!out) return 0;

  out[0] = 0x7f;
  out[1] = 'E';
  out[2] = 'L';
  out[3] = 'F';
  out[4] = 2;
  out[5] = 1;
  out[6] = 1;
  wr16(out + 16, 1);
  wr16(out + 18, 62);
  wr32(out + 20, 1);
  wr64(out + 40, off_shdr);
  wr16(out + 52, 64);
  wr16(out + 58, 64);
  wr16(out + 60, 7);
  wr16(out + 62, 3);

  memcpy(out + off_text, text, sizeof(text));
  memcpy(out + off_rela, rela, sizeof(rela));
  memcpy(out + off_shstr, shstr, sizeof(shstr));
  out[off_strtab] = 0;
  memcpy(out + off_strtab + local_name, local, local_len + 1);
  memcpy(out + off_strtab + external_name, external, external_len + 1);

  unsigned char *sym_local = out + off_symtab + 24;
  wr32(sym_local + 0, (uint32_t)local_name);
  sym_local[4] = 0x12;
  wr16(sym_local + 6, 1);
  wr64(sym_local + 8, 0);
  wr64(sym_local + 16, sizeof(text));
  unsigned char *sym_external = out + off_symtab + 48;
  wr32(sym_external + 0, (uint32_t)external_name);
  sym_external[4] = 0x12;
  wr16(sym_external + 6, 0);

  unsigned char *sh = out + off_shdr;
  wr_elf64_shdr(sh + 1 * 64, 1, 1, 0x6, 0, off_text, sizeof(text), 0, 0, 16, 0);
  wr_elf64_shdr(sh + 2 * 64, 7, 4, 0, 0, off_rela, sizeof(rela), 4, 1, 8, 24);
  wr_elf64_shdr(sh + 3 * 64, 18, 3, 0, 0, off_shstr, sizeof(shstr), 0, 0, 1, 0);
  wr_elf64_shdr(sh + 4 * 64, 28, 2, 0, 0, off_symtab, symtab_n, 5, 1, 8, 24);
  wr_elf64_shdr(sh + 5 * 64, 36, 3, 0, 0, off_strtab, strtab_n, 0, 0, 1, 0);
  wr_elf64_shdr(sh + 6 * 64, 44, 1, 0, 0, 0, 0, 0, 0, 1, 0);

  int ok = write_file(out_path, out, file_n);
  free(out);
  return ok;
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

static int parse_elf_obj(const unsigned char *data, size_t size, ElfObj *o) {
  if (!is_elf(data, size) || size < 64 || rd16(data + 16) != 1 ||
      rd16(data + 18) != 62) {
    return 0;
  }
  uint64_t shoff = rd64(data + 40);
  uint16_t shentsize = rd16(data + 58);
  uint16_t shnum = rd16(data + 60);
  uint16_t shstrndx = rd16(data + 62);
  if (shentsize < 64 || shoff > size || shnum > (size - shoff) / shentsize ||
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
      if (entsize != 24 || link >= shnum) return 0;
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
      if (entsize != 24 || info >= shnum) return 0;
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

    for (size_t s = 1; s < objs[i].sym_count; ++s) {
      const unsigned char *sym = objs[i].symtab + s * 24;
      uint16_t shndx = rd16(sym + 6);
      if (shndx != objs[i].text_idx) continue;
      const char *name = elf_str(objs[i].strtab, objs[i].strtab_size, rd32(sym));
      if (!name || !name[0]) continue;
      uint64_t existing = 0;
      if (link_find_sym(syms, sym_count, name, &existing)) {
        fprintf(stderr, "link-elf64-exe=duplicate_symbol symbol=%s\n", name);
        goto done;
      }
      if (sym_count == sym_cap) {
        size_t next = sym_cap ? sym_cap * 2 : 8;
        LinkSym *p = (LinkSym *)realloc(syms, next * sizeof(*p));
        if (!p) goto done;
        syms = p;
        sym_cap = next;
      }
      syms[sym_count++] = (LinkSym){name, (size_t)i, 0x400000u + 120 + objs[i].out_off + rd64(sym + 8)};
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
  }

  uint64_t entry_addr = 0;
  if (!link_find_sym(syms, sym_count, entry_name, &entry_addr)) {
    fprintf(stderr, "link-elf64-exe=entry_missing symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  int64_t entry_rel = (int64_t)entry_addr - (int64_t)(0x400000u + 120 + 5);
  uint32_t rel32 = 0;
  if (!link_rel32_checked(entry_rel, &rel32)) {
    fprintf(stderr, "link-elf64-exe=entry_out_of_range symbol=%s\n", entry_name);
    rc = 3;
    goto done;
  }
  wr32(code.data + 1, rel32);

  for (int i = 0; i < obj_count; ++i) {
    const ElfObj *o = &objs[i];
    for (size_t r = 0; r < o->rela_count; ++r) {
      const unsigned char *rela = o->rela + r * 24;
      uint64_t r_off = rd64(rela);
      uint64_t r_info = rd64(rela + 8);
      int64_t addend = (int64_t)rd64(rela + 16);
      uint32_t type = (uint32_t)r_info;
      uint32_t sym_idx = (uint32_t)(r_info >> 32);
      if (type != 4 || sym_idx >= o->sym_count || r_off > o->text_size - 4) {
        fprintf(stderr, "link-elf64-exe=unsupported_reloc\n");
        rc = 4;
        goto done;
      }
      const unsigned char *sym = o->symtab + (size_t)sym_idx * 24;
      const char *name = elf_str(o->strtab, o->strtab_size, rd32(sym));
      uint64_t target = 0;
      if (!name || !link_find_sym(syms, sym_count, name, &target)) {
        fprintf(stderr, "link-elf64-exe=symbol_missing symbol=%s\n", name ? name : "?");
        rc = 4;
        goto done;
      }
      uint64_t place = 0x400000u + 120 + o->out_off + r_off;
      int64_t rel = (int64_t)target + addend - (int64_t)place;
      if (!link_rel32_checked(rel, &rel32)) {
        fprintf(stderr, "link-elf64-exe=reloc_out_of_range symbol=%s\n", name);
        rc = 4;
        goto done;
      }
      wr32(code.data + o->out_off + r_off, rel32);
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

static int eval_pure_u64_blob(const Blob *b, uint64_t *out) {
  uint64_t last = 0;
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 0;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    if (op == OP_CONST_U64) {
      last = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
    } else if (op == OP_ADD_U64) {
      last += (uint64_t)arg0 | ((uint64_t)arg1 << 32);
    } else if (op == OP_EXPECT_U64) {
      uint64_t expected = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (last != expected) return 0;
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
  uint64_t result = 0;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!eval_pure_u64_blob(&b, &result)) {
    fprintf(stderr, "aot-elf64-exit=unsupported_blob\n");
    free(owned);
    return 2;
  }
  free(owned);
  if (!emit_elf64_exit_file(out_path, (uint8_t)(result & 0xffu))) {
    fprintf(stderr, "aot-elf64-exit=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.elf64.output=%s\n", out_path);
  printf("aot.elf64.bytes=%d\n", 132);
  printf("aot.elf64.exit=%llu\n", (unsigned long long)(result & 0xffu));
  return 0;
}

static int cmd_aot_elf64_obj_ret(const char *blob_path, const char *out_path, const char *symbol) {
  Blob b;
  unsigned char *owned = NULL;
  uint64_t result = 0;
  if (!symbol[0]) {
    fprintf(stderr, "aot-elf64-obj-ret=bad_symbol\n");
    return 1;
  }
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  if (!eval_pure_u64_blob(&b, &result) || result > UINT32_MAX) {
    fprintf(stderr, "aot-elf64-obj-ret=unsupported_blob\n");
    free(owned);
    return 2;
  }
  free(owned);
  if (!emit_elf64_obj_ret_file(out_path, symbol, (uint32_t)result)) {
    fprintf(stderr, "aot-elf64-obj-ret=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("aot.obj.output=%s\n", out_path);
  printf("aot.obj.symbol=%s\n", symbol);
  printf("aot.obj.ret=%llu\n", (unsigned long long)result);
  return 0;
}

static int compile_pure_u64_blob_to_x86_exit(const Blob *b, Buf *code) {
  int saw_ret = 0;
  Buf expect_patches = {0};
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) {
      free(expect_patches.data);
      return 0;
    }
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    uint64_t imm = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
    if (imm > UINT32_MAX) {
      free(expect_patches.data);
      return 0;
    }
    if (op == OP_CONST_U64) {
      unsigned char mov_edi[5] = {0xbf, 0, 0, 0, 0};
      wr32(mov_edi + 1, (uint32_t)imm);
      buf_put(code, mov_edi, sizeof(mov_edi));
    } else if (op == OP_ADD_U64) {
      unsigned char add_edi[6] = {0x81, 0xc7, 0, 0, 0, 0};
      wr32(add_edi + 2, (uint32_t)imm);
      buf_put(code, add_edi, sizeof(add_edi));
    } else if (op == OP_EXPECT_U64) {
      unsigned char cmp_edi[6] = {0x81, 0xff, 0, 0, 0, 0};
      unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
      uint32_t patch_off = (uint32_t)(code->len + sizeof(cmp_edi) + 2);
      wr32(cmp_edi + 2, (uint32_t)imm);
      buf_put(code, cmp_edi, sizeof(cmp_edi));
      buf_put(code, jne_fail, sizeof(jne_fail));
      buf_put32(&expect_patches, patch_off);
    } else if (op == OP_RET_LAST) {
      unsigned char exit_syscall[7] = {0xb8, 0x3c, 0, 0, 0, 0x0f, 0x05};
      buf_put(code, exit_syscall, sizeof(exit_syscall));
      saw_ret = 1;
      break;
    } else {
      free(expect_patches.data);
      return 0;
    }
  }
  if (saw_ret && expect_patches.len) {
    size_t fail_off = code->len;
    unsigned char fail_exit[12] = {
      0xbf, 125, 0, 0, 0,
      0xb8, 0x3c, 0, 0, 0,
      0x0f, 0x05
    };
    buf_put(code, fail_exit, sizeof(fail_exit));
    for (size_t i = 0; i < expect_patches.len; i += 4) {
      uint32_t patch_off = rd32(expect_patches.data + i);
      int64_t rel = (int64_t)fail_off - (int64_t)(patch_off + 4);
      wr32(code->data + patch_off, (uint32_t)(int32_t)rel);
    }
  }
  free(expect_patches.data);
  return saw_ret;
}

static int compile_pure_u64_blob_to_x86_ret(const Blob *b, Buf *code) {
  int saw_ret = 0;
  Buf expect_patches = {0};
  for (uint32_t pc = 0; pc < b->instr_count; ++pc) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) {
      free(expect_patches.data);
      return 0;
    }
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    uint64_t imm = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
    if (imm > UINT32_MAX) {
      free(expect_patches.data);
      return 0;
    }
    if (op == OP_CONST_U64) {
      unsigned char mov_eax[5] = {0xb8, 0, 0, 0, 0};
      wr32(mov_eax + 1, (uint32_t)imm);
      buf_put(code, mov_eax, sizeof(mov_eax));
    } else if (op == OP_ADD_U64) {
      unsigned char add_eax[5] = {0x05, 0, 0, 0, 0};
      wr32(add_eax + 1, (uint32_t)imm);
      buf_put(code, add_eax, sizeof(add_eax));
    } else if (op == OP_EXPECT_U64) {
      unsigned char cmp_eax[5] = {0x3d, 0, 0, 0, 0};
      unsigned char jne_fail[6] = {0x0f, 0x85, 0, 0, 0, 0};
      uint32_t patch_off = (uint32_t)(code->len + sizeof(cmp_eax) + 2);
      wr32(cmp_eax + 1, (uint32_t)imm);
      buf_put(code, cmp_eax, sizeof(cmp_eax));
      buf_put(code, jne_fail, sizeof(jne_fail));
      buf_put32(&expect_patches, patch_off);
    } else if (op == OP_RET_LAST) {
      unsigned char ret = 0xc3;
      buf_put(code, &ret, 1);
      saw_ret = 1;
      break;
    } else {
      free(expect_patches.data);
      return 0;
    }
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
  free(expect_patches.data);
  return saw_ret;
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
  size_t blob_n = 0;
  unsigned char *blob_data = compile_source_path_to_blob(src_path, &blob_n);
  Blob b;
  Buf code = {0};
  if (!symbol[0]) {
    fprintf(stderr, "compile-elf64-obj-code=bad_symbol\n");
    free(blob_data);
    return 1;
  }
  if (!blob_data || !blob_init(&b, blob_data, blob_n)) {
    fprintf(stderr, "compile-elf64-obj-code=compile_fail\n");
    free(blob_data);
    return 1;
  }
  int ok = compile_pure_u64_blob_to_x86_ret(&b, &code);
  free(blob_data);
  if (!ok) {
    free(code.data);
    fprintf(stderr, "compile-elf64-obj-code=unsupported_source\n");
    return 2;
  }
  if (!emit_elf64_obj_text_file(out_path, symbol, code.data, code.len)) {
    free(code.data);
    fprintf(stderr, "compile-elf64-obj-code=write_fail path=%s\n", out_path);
    return 3;
  }
  printf("compile.obj.code.output=%s\n", out_path);
  printf("compile.obj.code.symbol=%s\n", symbol);
  printf("compile.obj.code.x86.bytes=%zu\n", code.len);
  free(code.data);
  return 0;
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
  fprintf(stderr, "  %s emit-elf64-exit output.elf exit_code\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-ret output.o symbol value\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-call output.o local_symbol external_symbol\n", argv0);
  fprintf(stderr, "  %s aot-elf64-exit input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-ret input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-code input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-code input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s compile-elf64-code input.%s output.elf\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-elf64-obj-code input.%s output.o symbol\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s link-elf64-exe output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s dump program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s hash program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s resolve [--quiet] program.%s\n", argv0, BLOB_EXT);
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
  if (argc >= 2 && strcmp(argv[1], "link-elf64-exe") == 0) {
    return cmd_link_elf64_exe(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "dump") == 0 && argc == 3) {
    return cmd_dump(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "hash") == 0 && argc == 3) {
    return cmd_hash(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve") == 0) {
    if (argc == 3) return cmd_resolve(argv[2], 0);
    if (argc == 4 && strcmp(argv[2], "--quiet") == 0) return cmd_resolve(argv[3], 1);
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
