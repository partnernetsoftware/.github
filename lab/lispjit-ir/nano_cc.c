/* Included from lispjit.c after nano_elf64.c — minimal nano-cc (C-subset → ELF). */

static int nano_cc_skip_ws(const char **p, const char *end) {
  while (*p < end && ((**p) == ' ' || (**p) == '\t' || (**p) == '\n' || (**p) == '\r'))
    ++*p;
  return *p < end;
}

static int nano_cc_parse_return_imm(const char **p, const char *end, int *out_code) {
  if (!nano_cc_skip_ws(p, end)) return 0;
  if (*p + 6 > end || memcmp(*p, "return", 6) != 0) return 0;
  *p += 6;
  if (!nano_cc_skip_ws(p, end)) return 0;
  if (**p == '(') ++*p;
  if (!nano_cc_skip_ws(p, end)) return 0;
  if (**p < '0' || **p > '9') return 0;
  long v = 0;
  while (*p < end && (**p) >= '0' && (**p) <= '9') {
    v = v * 10 + (**p - '0');
    ++*p;
  }
  if (v < 0 || v > 255) return 0;
  *out_code = (int)v;
  return 1;
}

static int nano_cc_parse_main_return(const char *src, size_t n, int *out_code) {
  const char *p = src;
  const char *end = src + n;
  const char *sig = "int main";
  while (p < end) {
    size_t remain = (size_t)(end - p);
    if (remain >= 8 && memcmp(p, sig, 8) == 0) {
      const char *q = p + 8;
      for (; q + 6 <= end; ++q) {
        if (memcmp(q, "return", 6) == 0) {
          const char *r = q;
          if (nano_cc_parse_return_imm(&r, end, out_code)) return 1;
        }
      }
    }
    ++p;
  }
  return 0;
}

static int nano_cc_can_compile_path(const char *src_path) {
  size_t n = 0;
  unsigned char *src = read_file(src_path, &n);
  int code = 0;
  int ok = 0;
  if (!src) return 0;
  ok = nano_cc_parse_main_return((const char *)src, n, &code);
  free(src);
  return ok;
}

static int cmd_nano_cc_compile(const char *src_path, const char *out_path) {
  size_t n = 0;
  unsigned char *src = read_file(src_path, &n);
  int code = 0;
  if (!src) {
    fprintf(stderr, "nano-cc=read_fail path=%s\n", src_path);
    return 1;
  }
  if (!nano_cc_parse_main_return((const char *)src, n, &code)) {
    fprintf(stderr, "nano-cc=unsupported_source path=%s\n", src_path);
    free(src);
    return 2;
  }
  free(src);
  if (!emit_elf64_exit_file(out_path, (uint8_t)code)) {
    fprintf(stderr, "nano-cc=emit_fail path=%s\n", out_path);
    return 3;
  }
  printf("nano-cc.source=%s\n", src_path);
  printf("nano-cc.output=%s\n", out_path);
  printf("nano-cc.exit_code=%d\n", code);
  return 0;
}
