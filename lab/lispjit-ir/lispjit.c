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
#define BOOTSTRAP_STEP_PACK_APE_BARE 32u

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


#include "nano_lisp_parse.c"

#include "nano_blob_vm.c"

#include "nano_compile_cli.c"
#include "nano_libc_resolve.c"

static int parse_size_arg(const char *s, size_t *out);

#include "nano_manifest.c"
#include "nano_run_cli.c"
#include "nano_pack_app.c"

#include "nano_ape.c"

static int parse_size_arg(const char *s, size_t *out) {
  char *end = NULL;
  unsigned long long v = strtoull(s, &end, 10);
  if (!s[0] || !end || *end) return 0;
  *out = (size_t)v;
  return (unsigned long long)*out == v;
}

static int run_link_elf64_exe(const char *out_path, const char *entry_name,
                              const char *first_obj, char **extra_args,
                              size_t extra_arg_count);
static int check_link_expect_exit(const char *expected_s, const char *out_path,
                                  const char *entry_name, const char *first_obj,
                                  char **extra_args, size_t extra_arg_count,
                                  const char *label);
static int check_compile_expect_exit(const char *expected_s, const char *mode,
                                     const char *src_path, const char *out_path,
                                     char **extra_args, size_t extra_arg_count,
                                     const char *label);

#include "nano_elf64.c"

#include "nano_bootstrap.c"

#include "nano_aot_x86.c"

#include "nano_compile_elf64_cli.c"

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
  fprintf(stderr, "  %s pack-ape-bare output.ape x86_64.elf aarch64.elf\n", argv0);
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
  if (argc >= 2 && strcmp(argv[1], "pack-ape-bare") == 0 && argc == 5) {
    return cmd_pack_ape_bare(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-app") == 0 && argc == 6) {
    return cmd_pack_app(argv[2], argv[3], argv[4], argv[5]);
  }
  usage(argv[0]);
  return 2;
}
