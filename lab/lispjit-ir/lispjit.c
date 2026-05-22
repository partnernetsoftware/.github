#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ape_v2.h"

#if defined(_WIN32)
#include <windows.h>
#else
#include <dlfcn.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/utsname.h>
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
#define OP_MUL_I64 18u
#define OP_EQ_I64 19u
#define OP_LT_I64 20u
#define OP_GT_I64 21u
#define OP_NE_I64 22u
#define OP_LE_I64 23u
#define OP_GE_I64 24u
#define OP_NOT_BOOL 25u
#define OP_AND_BOOL 26u
#define OP_OR_BOOL 27u
#define OP_NULL_PTR 28u
#define OP_IS_NULL_PTR 29u
#define OP_IS_NONNULL_PTR 30u
#define OP_ADD_PTR 31u
#define OP_SUB_PTR 32u
#define OP_PTR_TO_U64 33u
#define OP_U64_TO_PTR 34u
#define OP_CONST_PTR 35u
#define OP_LOAD_U8 36u
#define OP_LOAD_U16 37u
#define OP_LOAD_U32 38u
#define OP_STORE_U8 39u
#define OP_STORE_U16 40u
#define OP_STORE_U32 41u

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
#define SRC_FORM_MUL_I64 15u
#define SRC_FORM_EQ_I64 16u
#define SRC_FORM_LT_I64 17u
#define SRC_FORM_GT_I64 18u
#define SRC_FORM_NE_I64 19u
#define SRC_FORM_LE_I64 20u
#define SRC_FORM_GE_I64 21u
#define SRC_FORM_NOT_BOOL 22u
#define SRC_FORM_AND_BOOL 23u
#define SRC_FORM_OR_BOOL 24u
#define SRC_FORM_NULL_PTR 25u
#define SRC_FORM_IS_NULL_PTR 26u
#define SRC_FORM_IS_NONNULL_PTR 27u
#define SRC_FORM_ADD_PTR 28u
#define SRC_FORM_SUB_PTR 29u
#define SRC_FORM_PTR_TO_U64 30u
#define SRC_FORM_U64_TO_PTR 31u
#define SRC_FORM_CONST_PTR 32u
#define SRC_FORM_LOAD_U8 33u
#define SRC_FORM_LOAD_U16 34u
#define SRC_FORM_LOAD_U32 35u
#define SRC_FORM_STORE_U8 36u
#define SRC_FORM_STORE_U16 37u
#define SRC_FORM_STORE_U32 38u

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
#define AOT_STMT_MUL_I64 13u
#define AOT_STMT_EQ_I64 14u
#define AOT_STMT_LT_I64 15u
#define AOT_STMT_GT_I64 16u
#define AOT_STMT_NE_I64 17u
#define AOT_STMT_LE_I64 18u
#define AOT_STMT_GE_I64 19u
#define AOT_STMT_NOT_BOOL 20u
#define AOT_STMT_AND_BOOL 21u
#define AOT_STMT_OR_BOOL 22u
#define AOT_STMT_NULL_PTR 23u
#define AOT_STMT_IS_NULL_PTR 24u
#define AOT_STMT_IS_NONNULL_PTR 25u
#define AOT_STMT_EXPECT_PTR 26u
#define AOT_STMT_ADD_PTR 27u
#define AOT_STMT_SUB_PTR 28u
#define AOT_STMT_PTR_TO_U64 29u
#define AOT_STMT_U64_TO_PTR 30u
#define AOT_STMT_LOAD_U8 31u
#define AOT_STMT_LOAD_U16 32u
#define AOT_STMT_LOAD_U32 33u
#define AOT_STMT_STORE_U8 34u
#define AOT_STMT_STORE_U16 35u
#define AOT_STMT_STORE_U32 36u

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
#define BOOTSTRAP_STEP_GEN_LIBC_RESOLVE 25u
#define BOOTSTRAP_STEP_COMPILE_EXPECT_EXIT 26u
#define BOOTSTRAP_STEP_PACK_APE 27u
#define BOOTSTRAP_STEP_INSPECT_APE 28u
#define BOOTSTRAP_STEP_RUN_APE 29u
#define BOOTSTRAP_STEP_INSPECT_EXPECT_EXIT 30u
#define BOOTSTRAP_STEP_RUN_APE_EXPECT_EXIT 31u

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

static int value_mul_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  v->bits *= (uint64_t)rhs;
  return 1;
}

static int value_eq_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  *v = value_bool(v->bits == (uint64_t)rhs);
  return 1;
}

static int value_lt_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  uint64_t lhs_ordered = v->bits ^ 0x8000000000000000ull;
  uint64_t rhs_ordered = (uint64_t)rhs ^ 0x8000000000000000ull;
  *v = value_bool(lhs_ordered < rhs_ordered);
  return 1;
}

static int value_gt_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  uint64_t lhs_ordered = v->bits ^ 0x8000000000000000ull;
  uint64_t rhs_ordered = (uint64_t)rhs ^ 0x8000000000000000ull;
  *v = value_bool(lhs_ordered > rhs_ordered);
  return 1;
}

static int value_ne_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  *v = value_bool(v->bits != (uint64_t)rhs);
  return 1;
}

static int value_le_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  uint64_t lhs_ordered = v->bits ^ 0x8000000000000000ull;
  uint64_t rhs_ordered = (uint64_t)rhs ^ 0x8000000000000000ull;
  *v = value_bool(lhs_ordered <= rhs_ordered);
  return 1;
}

static int value_ge_i64(Value *v, int64_t rhs) {
  if (v->kind != VAL_I64) return 0;
  uint64_t lhs_ordered = v->bits ^ 0x8000000000000000ull;
  uint64_t rhs_ordered = (uint64_t)rhs ^ 0x8000000000000000ull;
  *v = value_bool(lhs_ordered >= rhs_ordered);
  return 1;
}

static int value_not_bool(Value *v) {
  if (v->kind != VAL_BOOL) return 0;
  *v = value_bool(!v->bits);
  return 1;
}

static int value_and_bool(Value *v, int rhs) {
  if (v->kind != VAL_BOOL) return 0;
  *v = value_bool(v->bits && rhs);
  return 1;
}

static int value_or_bool(Value *v, int rhs) {
  if (v->kind != VAL_BOOL) return 0;
  *v = value_bool(v->bits || rhs);
  return 1;
}

static int value_is_null_ptr(Value *v) {
  if (v->kind != VAL_PTR) return 0;
  *v = value_bool(v->bits == 0);
  return 1;
}

static int value_is_nonnull_ptr(Value *v) {
  if (v->kind != VAL_PTR) return 0;
  *v = value_bool(v->bits != 0);
  return 1;
}

static int value_add_ptr(Value *v, uint64_t rhs) {
  if (v->kind != VAL_PTR) return 0;
  v->bits += rhs;
  return 1;
}

static int value_sub_ptr(Value *v, uint64_t rhs) {
  if (v->kind != VAL_PTR) return 0;
  v->bits -= rhs;
  return 1;
}

static int value_ptr_to_u64(Value *v) {
  if (v->kind != VAL_PTR) return 0;
  v->kind = VAL_U64;
  return 1;
}

static int value_u64_to_ptr(Value *v) {
  if (v->kind != VAL_U64) return 0;
  v->kind = VAL_PTR;
  return 1;
}

static int value_load_u8(Value *v) {
  if (v->kind != VAL_PTR || !v->bits) return 0;
  v->kind = VAL_U64;
  v->bits = (uint64_t)*(const unsigned char *)(uintptr_t)v->bits;
  return 1;
}

static int value_load_u16(Value *v) {
  if (v->kind != VAL_PTR || !v->bits) return 0;
  const unsigned char *p = (const unsigned char *)(uintptr_t)v->bits;
  v->kind = VAL_U64;
  v->bits = (uint64_t)p[0] | ((uint64_t)p[1] << 8);
  return 1;
}

static int value_load_u32(Value *v) {
  if (v->kind != VAL_PTR || !v->bits) return 0;
  const unsigned char *p = (const unsigned char *)(uintptr_t)v->bits;
  v->kind = VAL_U64;
  v->bits = (uint64_t)p[0] | ((uint64_t)p[1] << 8) |
            ((uint64_t)p[2] << 16) | ((uint64_t)p[3] << 24);
  return 1;
}

static int value_store_u8(Value *v, uint64_t byte) {
  if (v->kind != VAL_PTR || !v->bits || byte > 255u) return 0;
  *(unsigned char *)(uintptr_t)v->bits = (unsigned char)byte;
  return 1;
}

static int value_store_u16(Value *v, uint64_t word) {
  if (v->kind != VAL_PTR || !v->bits || word > 65535u) return 0;
  unsigned char *p = (unsigned char *)(uintptr_t)v->bits;
  p[0] = (unsigned char)(word & 0xffu);
  p[1] = (unsigned char)((word >> 8) & 0xffu);
  return 1;
}

static int value_store_u32(Value *v, uint64_t dword) {
  if (v->kind != VAL_PTR || !v->bits || dword > 4294967295ULL) return 0;
  unsigned char *p = (unsigned char *)(uintptr_t)v->bits;
  p[0] = (unsigned char)(dword & 0xffu);
  p[1] = (unsigned char)((dword >> 8) & 0xffu);
  p[2] = (unsigned char)((dword >> 16) & 0xffu);
  p[3] = (unsigned char)((dword >> 24) & 0xffu);
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

#include "ape_v2.c"

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
               strcmp(head, "sub-i64") == 0 || strcmp(head, "mul-i64") == 0 ||
               strcmp(head, "eq-i64") == 0 || strcmp(head, "lt-i64") == 0 ||
               strcmp(head, "gt-i64") == 0 || strcmp(head, "ne-i64") == 0 ||
               strcmp(head, "le-i64") == 0 || strcmp(head, "ge-i64") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      uint32_t kind = strcmp(head, "u64") == 0 ? AOT_STMT_CONST_U64 :
                      strcmp(head, "add-u64") == 0 ? AOT_STMT_ADD_U64 :
                      strcmp(head, "i64") == 0 ? AOT_STMT_CONST_I64 :
                      strcmp(head, "add-i64") == 0 ? AOT_STMT_ADD_I64 :
                      strcmp(head, "sub-i64") == 0 ? AOT_STMT_SUB_I64 :
                      strcmp(head, "mul-i64") == 0 ? AOT_STMT_MUL_I64 :
                      strcmp(head, "eq-i64") == 0 ? AOT_STMT_EQ_I64 :
                      strcmp(head, "lt-i64") == 0 ? AOT_STMT_LT_I64 :
                      strcmp(head, "gt-i64") == 0 ? AOT_STMT_GT_I64 :
                      strcmp(head, "ne-i64") == 0 ? AOT_STMT_NE_I64 :
                      strcmp(head, "le-i64") == 0 ? AOT_STMT_LE_I64 :
                      AOT_STMT_GE_I64;
      if (strcmp(head, "i64") == 0 || strcmp(head, "add-i64") == 0 ||
          strcmp(head, "sub-i64") == 0 || strcmp(head, "mul-i64") == 0 ||
          strcmp(head, "eq-i64") == 0 || strcmp(head, "lt-i64") == 0 ||
          strcmp(head, "gt-i64") == 0 || strcmp(head, "ne-i64") == 0 ||
          strcmp(head, "le-i64") == 0 || strcmp(head, "ge-i64") == 0) {
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
    } else if (strcmp(head, "null-ptr") == 0) {
      ok = eat(p, ')') && aot_add_stmt(f, AOT_STMT_NULL_PTR, 0, NULL);
    } else if (strcmp(head, "add-ptr") == 0 || strcmp(head, "sub-ptr") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      uint32_t kind = strcmp(head, "add-ptr") == 0 ? AOT_STMT_ADD_PTR : AOT_STMT_SUB_PTR;
      ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
           aot_add_stmt(f, kind, imm, NULL);
      free(value);
    } else if (strcmp(head, "ptr-to-u64") == 0 || strcmp(head, "u64-to-ptr") == 0) {
      uint32_t kind = strcmp(head, "ptr-to-u64") == 0 ?
                      AOT_STMT_PTR_TO_U64 :
                      AOT_STMT_U64_TO_PTR;
      ok = eat(p, ')') && aot_add_stmt(f, kind, 0, NULL);
    } else if (strcmp(head, "load-u8") == 0 || strcmp(head, "load-u16") == 0 ||
               strcmp(head, "load-u32") == 0) {
      uint32_t kind = strcmp(head, "load-u8") == 0 ? AOT_STMT_LOAD_U8 :
                      strcmp(head, "load-u16") == 0 ? AOT_STMT_LOAD_U16 :
                      AOT_STMT_LOAD_U32;
      ok = eat(p, ')') && aot_add_stmt(f, kind, 0, NULL);
    } else if (strcmp(head, "store-u8") == 0 || strcmp(head, "store-u16") == 0 ||
               strcmp(head, "store-u32") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      uint32_t kind = strcmp(head, "store-u8") == 0 ? AOT_STMT_STORE_U8 :
                      strcmp(head, "store-u16") == 0 ? AOT_STMT_STORE_U16 :
                      AOT_STMT_STORE_U32;
      ok = value && parse_u64_atom(value, &imm) && eat(p, ')') &&
           aot_add_stmt(f, kind, imm, NULL);
      free(value);
    } else if (strcmp(head, "is-null-ptr") == 0 ||
               strcmp(head, "is-nonnull-ptr") == 0) {
      uint32_t kind = strcmp(head, "is-null-ptr") == 0 ?
                      AOT_STMT_IS_NULL_PTR :
                      AOT_STMT_IS_NONNULL_PTR;
      ok = eat(p, ')') && aot_add_stmt(f, kind, 0, NULL);
    } else if (strcmp(head, "not-bool") == 0) {
      ok = eat(p, ')') && aot_add_stmt(f, AOT_STMT_NOT_BOOL, 0, NULL);
    } else if (strcmp(head, "and-bool") == 0 || strcmp(head, "or-bool") == 0) {
      char *value = parse_atom(p);
      int boolean = 0;
      uint32_t kind = strcmp(head, "and-bool") == 0 ? AOT_STMT_AND_BOOL : AOT_STMT_OR_BOOL;
      ok = value && parse_bool_atom(value, &boolean) && eat(p, ')') &&
           aot_add_stmt(f, kind, (uint64_t)boolean, NULL);
      free(value);
    } else if (strcmp(head, "expect") == 0) {
      char *value = parse_atom(p);
      uint64_t imm = 0;
      int64_t i64 = 0;
      int boolean = 0;
      int ptr_state = 0;
      if (value && parse_bool_atom(value, &boolean)) {
        ok = eat(p, ')') &&
             aot_add_stmt(f, AOT_STMT_EXPECT_BOOL, (uint64_t)boolean, NULL);
      } else if (value && parse_expect_ptr_atom(value, &ptr_state)) {
        ok = eat(p, ')') &&
             aot_add_stmt(f, AOT_STMT_EXPECT_PTR, (uint64_t)ptr_state, NULL);
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
    } else if (strcmp(head, "emit-elf64-exit") == 0 || strcmp(head, "run-expect-exit") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_atom(&p);
      uint32_t kind = strcmp(head, "emit-elf64-exit") == 0 ? BOOTSTRAP_STEP_EMIT_ELF64_EXIT :
                      BOOTSTRAP_STEP_RUN_EXPECT_EXIT;
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, arg1, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "run-ape-expect-exit") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_atom(&p);
      char *arg2 = NULL;
      while (*p == ' ' || *p == '\t') ++p;
      if (*p != ')') arg2 = parse_atom(&p);
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_RUN_APE_EXPECT_EXIT, arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
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
    } else if (strcmp(head, "compile-expect-exit") == 0) {
      char *arg0 = parse_atom(&p);
      char *arg1 = parse_atom(&p);
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
           bootstrap_add_step_extra(plan, BOOTSTRAP_STEP_COMPILE_EXPECT_EXIT,
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
    } else if (strcmp(head, "inspect-expect-exit") == 0) {
      char *arg0 = parse_atom(&p);
      char *arg1 = parse_atom(&p);
      char *arg2 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_INSPECT_EXPECT_EXIT,
                                  arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "pack-ape") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_PACK_APE, arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
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
    } else if (strcmp(head, "run-ape") == 0) {
      char *arg0 = parse_string(&p);
      char *arg2 = NULL;
      while (*p == ' ' || *p == '\t') ++p;
      if (*p != ')') arg2 = parse_atom(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_RUN_APE, arg0, NULL, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "inspect-ape") == 0 ||
               strcmp(head, "inspect-app") == 0 ||
               strcmp(head, "run-app") == 0) {
      char *arg0 = parse_string(&p);
      uint32_t kind = strcmp(head, "inspect-ape") == 0 ? BOOTSTRAP_STEP_INSPECT_APE :
                      strcmp(head, "inspect-app") == 0 ? BOOTSTRAP_STEP_INSPECT_APP :
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
               strcmp(head, "gen-libc-resolve") == 0 ||
               strcmp(head, "run") == 0 ||
               strcmp(head, "resolve-quiet") == 0) {
      char *arg0 = parse_string(&p);
      uint32_t kind = strcmp(head, "hash") == 0 ? BOOTSTRAP_STEP_HASH :
                      strcmp(head, "dump") == 0 ? BOOTSTRAP_STEP_DUMP :
                      strcmp(head, "file-size") == 0 ? BOOTSTRAP_STEP_FILE_SIZE :
                      strcmp(head, "file-hash") == 0 ? BOOTSTRAP_STEP_FILE_HASH :
                      strcmp(head, "gen-libc-resolve") == 0 ? BOOTSTRAP_STEP_GEN_LIBC_RESOLVE :
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


#include "nano_blob_vm.c"


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


static int parse_size_arg(const char *s, size_t *out) {
  char *end = NULL;
  unsigned long long v = strtoull(s, &end, 10);
  if (!s[0] || !end || *end) return 0;
  *out = (size_t)v;
  return (unsigned long long)*out == v;
}

#include "nano_manifest.c"

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

#include "nano_ape.c"

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

static int str_cmp_ptr(const void *a, const void *b) {
  const char *const *sa = (const char *const *)a;
  const char *const *sb = (const char *const *)b;
  return strcmp(*sa, *sb);
}

static int ident_char_ok(char c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
         (c >= '0' && c <= '9') || c == '_';
}

static char *libc_ident(const char *name, size_t index) {
  size_t n = strlen(name);
  char suffix[32];
  int suffix_n = snprintf(suffix, sizeof(suffix), "_%zu", index);
  int needs_prefix = n == 0 || (name[0] >= '0' && name[0] <= '9');
  size_t out_n = (needs_prefix ? 4u : 0u) + n + (size_t)suffix_n + 1u;
  char *out = (char *)malloc(out_n);
  if (!out) return NULL;
  size_t pos = 0;
  if (needs_prefix) {
    memcpy(out + pos, "sym_", 4);
    pos += 4;
  }
  for (size_t i = 0; i < n; ++i) out[pos++] = ident_char_ok(name[i]) ? name[i] : '_';
  memcpy(out + pos, suffix, (size_t)suffix_n + 1u);
  return out;
}

static int symbol_vec_push(char ***items, size_t *count, size_t *cap, const char *sym) {
  if (*count == *cap) {
    size_t next = *cap ? *cap * 2u : 256u;
    char **grown = (char **)realloc(*items, next * sizeof(**items));
    if (!grown) return 0;
    *items = grown;
    *cap = next;
  }
  (*items)[*count] = dup_cstr(sym);
  if (!(*items)[*count]) return 0;
  *count += 1u;
  return 1;
}

static const char *default_libc_path(void) {
  static const char *candidates[] = {
    "/lib/x86_64-linux-gnu/libc.so.6",
    "/lib64/libc.so.6",
    "/usr/lib/libc.so.6",
    "/usr/lib64/libc.so.6",
    NULL
  };
  for (size_t i = 0; candidates[i]; ++i) {
    FILE *f = fopen(candidates[i], "rb");
    if (f) {
      fclose(f);
      return candidates[i];
    }
  }
  return candidates[0];
}

static int collect_libc_dynsym_symbols(const char *libc_path, char ***symbols,
                                       size_t *symbol_count, size_t *symbol_cap) {
  enum {
    LOCAL_ELF64_EHDR_SIZE = 64,
    LOCAL_ELF64_SHDR_SIZE = 64,
    LOCAL_ELF64_SYM_SIZE = 24,
    LOCAL_SHT_STRTAB = 3,
    LOCAL_SHT_DYNSYM = 11,
    LOCAL_SHT_GNU_VERSYM = 0x6fffffff
  };
  size_t size = 0;
  unsigned char *data = read_file(libc_path, &size);
  if (!data) return 0;
  int ok = 0;
  if (size < LOCAL_ELF64_EHDR_SIZE || data[0] != 0x7f || data[1] != 'E' ||
      data[2] != 'L' || data[3] != 'F' || data[4] != 2 || data[5] != 1) {
    goto done;
  }
  uint64_t shoff = rd64(data + 40);
  uint16_t shentsize = rd16(data + 58);
  uint16_t shnum = rd16(data + 60);
  if (shentsize < LOCAL_ELF64_SHDR_SIZE || shoff > size ||
      shnum > (size - shoff) / shentsize) {
    goto done;
  }
  const unsigned char *shdr = data + shoff;
  for (uint16_t i = 1; i < shnum; ++i) {
    const unsigned char *sh = shdr + (size_t)i * shentsize;
    if (rd32(sh + 4) != LOCAL_SHT_DYNSYM) continue;
    uint64_t sym_off = rd64(sh + 24);
    uint64_t sym_size = rd64(sh + 32);
    uint32_t str_idx = rd32(sh + 40);
    uint64_t sym_entsize = rd64(sh + 56);
    if (sym_entsize != LOCAL_ELF64_SYM_SIZE || str_idx >= shnum ||
        sym_off > size || sym_size > size - sym_off) {
      goto done;
    }
    const unsigned char *str_sh = shdr + (size_t)str_idx * shentsize;
    if (rd32(str_sh + 4) != LOCAL_SHT_STRTAB) goto done;
    uint64_t str_off = rd64(str_sh + 24);
    uint64_t str_size = rd64(str_sh + 32);
    if (str_off > size || str_size > size - str_off) goto done;
    const unsigned char *strtab = data + str_off;
    const unsigned char *versym = NULL;
    size_t versym_count = 0;
    for (uint16_t v = 1; v < shnum; ++v) {
      const unsigned char *vsh = shdr + (size_t)v * shentsize;
      if (rd32(vsh + 4) != LOCAL_SHT_GNU_VERSYM || rd32(vsh + 40) != i) continue;
      uint64_t v_off = rd64(vsh + 24);
      uint64_t v_size = rd64(vsh + 32);
      if (v_off > size || v_size > size - v_off) goto done;
      versym = data + v_off;
      versym_count = (size_t)(v_size / 2u);
      break;
    }
    size_t nsyms = (size_t)(sym_size / sym_entsize);
    for (size_t s = 1; s < nsyms; ++s) {
      const unsigned char *sym = data + sym_off + s * sym_entsize;
      uint32_t name_off = rd32(sym);
      uint16_t shndx = rd16(sym + 6);
      if (shndx == 0 || name_off >= str_size) continue;
      if (versym && s < versym_count && (rd16(versym + s * 2u) & 0x8000u)) continue;
      const char *name = (const char *)strtab + name_off;
      if (!memchr(name, 0, (size_t)str_size - name_off)) continue;
      if (strncmp(name, "GLIBC_", 6) == 0 || strncmp(name, "GCC_", 4) == 0 || name[0] == 0) continue;
      if (!symbol_vec_push(symbols, symbol_count, symbol_cap, name)) goto done;
    }
  }
  ok = 1;
done:
  free(data);
  return ok;
}

static int cmd_gen_libc_resolve(const char *libc_path, const char *out_path) {
#if defined(_WIN32)
  (void)libc_path;
  (void)out_path;
  fprintf(stderr, "gen-libc-resolve=unsupported_platform\n");
  return 2;
#else
  if (!libc_path || !libc_path[0]) libc_path = default_libc_path();
  char **symbols = NULL;
  size_t symbol_count = 0;
  size_t symbol_cap = 0;
  int rc = 0;
  if (!collect_libc_dynsym_symbols(libc_path, &symbols, &symbol_count, &symbol_cap)) {
    fprintf(stderr, "gen-libc-resolve=dynsym_fail path=%s\n", libc_path);
    rc = 2;
  }
  if (rc == 0) {
    qsort(symbols, symbol_count, sizeof(*symbols), str_cmp_ptr);
    FILE *out = fopen(out_path, "wb");
    if (!out) {
      fprintf(stderr, "gen-libc-resolve=write_fail path=%s\n", out_path);
      rc = 3;
    } else {
      fprintf(out, "; Generated resolver manifest. It resolves exported libc symbols as addresses only.\n");
      fprintf(out, "(module\n");
      size_t emitted = 0;
      for (size_t i = 0; i < symbol_count; ++i) {
        if (i > 0 && strcmp(symbols[i], symbols[i - 1]) == 0) continue;
        char *name = libc_ident(symbols[i], emitted);
        if (!name) {
          rc = 2;
          break;
        }
        fprintf(out, "  (import %s \"libc\" \"%s\" \"addr\")\n", name, symbols[i]);
        free(name);
        emitted++;
      }
      fprintf(out, "  (main\n");
      emitted = 0;
      for (size_t i = 0; i < symbol_count; ++i) {
        if (i > 0 && strcmp(symbols[i], symbols[i - 1]) == 0) continue;
        char *name = libc_ident(symbols[i], emitted);
        if (!name) {
          rc = 2;
          break;
        }
        fprintf(out, "    (resolve %s)\n", name);
        free(name);
        emitted++;
      }
      fprintf(out, "  ))\n");
      if (fclose(out) != 0 && rc == 0) {
        fprintf(stderr, "gen-libc-resolve=close_fail path=%s\n", out_path);
        rc = 3;
      }
      if (rc == 0) {
        printf("libc.path=%s\n", libc_path);
        printf("symbols=%zu\n", emitted);
        printf("output=%s\n", out_path);
      }
    }
  }
  for (size_t i = 0; i < symbol_count; ++i) free(symbols[i]);
  free(symbols);
  return rc;
#endif
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
static int cmd_compile_expect_exit(int argc, char **argv);

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

static int run_compile_subcommand(const char *mode, const char *src_path,
                                  const char *out_path, char **extra_args,
                                  size_t extra_arg_count) {
  if (strcmp(mode, "compile-elf64-obj-code") == 0) {
    if (extra_arg_count != 1) return 1;
    return cmd_compile_elf64_obj_code(src_path, out_path, extra_args[0]);
  }
  if (strcmp(mode, "compile-elf64-exe") == 0) {
    if (extra_arg_count != 1) return 1;
    return cmd_compile_elf64_exe(src_path, out_path, extra_args[0]);
  }
  if (strcmp(mode, "compile-elf64-code") == 0) {
    if (extra_arg_count != 0) return 1;
    return cmd_compile_elf64_code(src_path, out_path);
  }
  if (strcmp(mode, "compile") == 0) {
    if (extra_arg_count != 0) return 1;
    return cmd_compile(src_path, out_path);
  }
  return 1;
}

static int check_compile_expect_exit(const char *expected_s, const char *mode,
                                     const char *src_path, const char *out_path,
                                     char **extra_args, size_t extra_arg_count,
                                     const char *label) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "%s=bad_expected\n", label);
    return 2;
  }
  int compile_rc = run_compile_subcommand(mode, src_path, out_path,
                                          extra_args, extra_arg_count);
  if ((size_t)compile_rc != expected) {
    fprintf(stderr, "%s=unexpected expected=%zu actual=%d\n", label, expected, compile_rc);
    return 2;
  }
  printf("%s.mode=%s\n", label, mode);
  printf("%s.ok=%zu\n", label, expected);
  return 0;
}

static int run_inspect_subcommand(const char *mode, const char *path) {
  if (strcmp(mode, "inspect-ape") == 0) return cmd_inspect_ape(path);
  if (strcmp(mode, "inspect-app") == 0) return cmd_inspect_app(path);
  return 1;
}

static int check_inspect_expect_exit(const char *expected_s, const char *mode,
                                     const char *path, const char *label) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "%s=bad_expected\n", label);
    return 2;
  }
  int inspect_rc = run_inspect_subcommand(mode, path);
  if ((size_t)inspect_rc != expected) {
    fprintf(stderr, "%s=unexpected expected=%zu actual=%d\n", label, expected, inspect_rc);
    return 2;
  }
  printf("%s.mode=%s\n", label, mode);
  printf("%s.ok=%zu\n", label, expected);
  return 0;
}

static int cmd_inspect_expect_exit(int argc, char **argv) {
  if (argc != 5) {
    fprintf(stderr, "inspect-expect-exit=bad_args\n");
    return 1;
  }
  return check_inspect_expect_exit(argv[2], argv[3], argv[4], "inspect-expect-exit");
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
    } else if (step->kind == BOOTSTRAP_STEP_GEN_LIBC_RESOLVE) {
      printf("bootstrap-step.%zu=gen-libc-resolve\n", i);
      rc = cmd_gen_libc_resolve(NULL, step->arg0);
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
    } else if (step->kind == BOOTSTRAP_STEP_COMPILE_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=compile-expect-exit\n", i);
      rc = check_compile_expect_exit(step->arg0, step->arg1, step->arg2, step->arg3,
                                     step->extra_args, step->extra_arg_count,
                                     "bootstrap-compile-expect-exit");
    } else if (step->kind == BOOTSTRAP_STEP_INSPECT_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=inspect-expect-exit\n", i);
      rc = check_inspect_expect_exit(step->arg0, step->arg1, step->arg2,
                                     "bootstrap-inspect-expect-exit");
    } else if (step->kind == BOOTSTRAP_STEP_RESOLVE_QUIET) {
      printf("bootstrap-step.%zu=resolve-quiet\n", i);
      rc = cmd_resolve(step->arg0, 1);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=run-expect-exit\n", i);
      rc = run_executable_expect_exit(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_APE_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=run-ape-expect-exit\n", i);
      rc = run_ape_expect_exit(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE) {
      printf("bootstrap-step.%zu=pack-ape\n", i);
      rc = cmd_pack_ape(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_INSPECT_APE) {
      printf("bootstrap-step.%zu=inspect-ape\n", i);
      rc = cmd_inspect_ape(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_APE) {
      printf("bootstrap-step.%zu=run-ape\n", i);
      rc = cmd_run_ape(step->arg0, step->arg2);
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

#include "nano_elf64.c"

static int cmd_compile_expect_exit(int argc, char **argv) {
  if (argc < 6) {
    fprintf(stderr, "compile-expect-exit=bad_args\n");
    return 1;
  }
  char **extra_args = argc > 6 ? &argv[6] : NULL;
  size_t extra_arg_count = argc > 6 ? (size_t)(argc - 6) : 0;
  return check_compile_expect_exit(argv[2], argv[3], argv[4], argv[5],
                                   extra_args, extra_arg_count,
                                   "compile-expect-exit");
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
  fprintf(stderr, "  %s inspect-ape container.com\n", argv0);
  fprintf(stderr, "  %s inspect-expect-exit expected inspect-ape|inspect-app container.com\n", argv0);
  fprintf(stderr, "  %s inspect-app container.com\n", argv0);
  fprintf(stderr, "  %s run-ape container.com [x86_64|aarch64]\n", argv0);
  fprintf(stderr, "  %s run-ape-expect-exit container.com expected_exit [arch]\n", argv0);
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
  fprintf(stderr, "  %s compile-expect-exit expected mode input output [symbol]\n", argv0);
  fprintf(stderr, "  %s link-elf64-exe output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s link-expect-exit expected output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s run-expect-exit executable expected_exit\n", argv0);
  fprintf(stderr, "  %s dump program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s hash program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s file-size path\n", argv0);
  fprintf(stderr, "  %s file-hash path\n", argv0);
  fprintf(stderr, "  %s gen-libc-resolve [libc.so] output.%s\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compare left.%s right.%s\n", argv0, BLOB_EXT, BLOB_EXT);
  fprintf(stderr, "  %s resolve [--quiet] program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s resolve-quiet program.%s\n", argv0, BLOB_EXT);
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
  if (argc >= 2 && strcmp(argv[1], "inspect-ape") == 0 && argc == 3) {
    return cmd_inspect_ape(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-app") == 0 && argc == 3) {
    return cmd_inspect_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-app") == 0 && argc == 3) {
    return cmd_run_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape") == 0 && argc == 3) {
    return cmd_run_ape(argv[2], NULL);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape") == 0 && argc == 4) {
    return cmd_run_ape(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape-expect-exit") == 0 && argc == 4) {
    return run_ape_expect_exit(argv[2], argv[3], NULL);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape-expect-exit") == 0 && argc == 5) {
    return run_ape_expect_exit(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-expect-exit") == 0 && argc == 5) {
    return cmd_inspect_expect_exit(argc, argv);
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
  if (argc >= 2 && strcmp(argv[1], "compile-expect-exit") == 0) {
    return cmd_compile_expect_exit(argc, argv);
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
  if (argc >= 2 && strcmp(argv[1], "gen-libc-resolve") == 0) {
    if (argc == 3) return cmd_gen_libc_resolve(NULL, argv[2]);
    if (argc == 4) return cmd_gen_libc_resolve(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "compare") == 0 && argc == 4) {
    return cmd_compare(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve") == 0) {
    if (argc == 3) return cmd_resolve(argv[2], 0);
    if (argc == 4 && strcmp(argv[2], "--quiet") == 0) return cmd_resolve(argv[3], 1);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve-quiet") == 0 && argc == 3) {
    return cmd_resolve(argv[2], 1);
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
