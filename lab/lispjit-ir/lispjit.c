#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ape_v2.h"
#include "nano_types.h"

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
#define FUNC_ENTRY_SIZE 12u

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


#include "nano_abi.c"

#include "nano_lisp_parse.c"

#include "nano_blob_vm.c"

#include "nano_compile_cli.c"
#include "nano_libc_resolve.c"

#include "nano_util.c"

#include "nano_manifest.c"
#include "nano_run_cli.c"
#include "nano_pack_app.c"

#include "nano_ape.c"

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

#include "nano_main.c"
