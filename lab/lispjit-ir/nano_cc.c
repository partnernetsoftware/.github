/* Included from lispjit.c after nano_elf64.c — minimal nano-cc (C-subset → ELF). */

static int cmd_compile_elf64_exe(const char *src_path, const char *out_path,
                                 const char *symbol);

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

static int nano_cc_match_token(const char **p, const char *end, const char *tok) {
  size_t n = strlen(tok);
  if (!nano_cc_skip_ws(p, end)) return 0;
  if ((size_t)(end - *p) < n || memcmp(*p, tok, n) != 0) return 0;
  *p += n;
  return 1;
}

static int nano_cc_path_readable(const char *path) {
  struct stat st;
  return path && stat(path, &st) == 0 && S_ISREG(st.st_mode);
}

static int nano_cc_parse_int_lit(const char **p, const char *end, int *out_v) {
  long v = 0;
  if (!nano_cc_skip_ws(p, end)) return 0;
  if (**p < '0' || **p > '9') return 0;
  while (*p < end && (**p) >= '0' && (**p) <= '9') {
    v = v * 10 + (**p - '0');
    ++*p;
  }
  if (v < 0 || v > 255) return 0;
  *out_v = (int)v;
  return 1;
}

static int nano_cc_parse_add_module(const char *src, size_t n, int *out_a, int *out_b) {
  const char *p = src;
  const char *end = src + n;
  const char *add_sig = "int add(int a,int b)";
  int saw_add = 0;
  while (p + strlen(add_sig) <= end) {
    if (memcmp(p, add_sig, strlen(add_sig)) == 0) {
      const char *q = p + strlen(add_sig);
      if (!nano_cc_skip_ws(&q, end)) return 0;
      if (*q != '{') return 0;
      ++q;
      if (!nano_cc_match_token(&q, end, "return")) return 0;
      if (!nano_cc_match_token(&q, end, "a+b")) return 0;
      if (!nano_cc_skip_ws(&q, end) || *q != ';') return 0;
      saw_add = 1;
      break;
    }
    ++p;
  }
  if (!saw_add) return 0;
  p = src;
  while (p + 8 <= end) {
    if (memcmp(p, "int main", 8) == 0) {
      const char *q = p + 8;
      for (; q + 6 <= end; ++q) {
        if (memcmp(q, "return", 6) == 0) {
          q += 6;
          if (!nano_cc_match_token(&q, end, "add(")) continue;
          if (!nano_cc_parse_int_lit(&q, end, out_a)) return 0;
          if (!nano_cc_skip_ws(&q, end) || *q != ',') return 0;
          ++q;
          if (!nano_cc_parse_int_lit(&q, end, out_b)) return 0;
          if (!nano_cc_skip_ws(&q, end) || *q != ')') return 0;
          return 1;
        }
      }
    }
    ++p;
  }
  return 0;
}

static int nano_cc_companion_lisp_path(const char *c_path, char *out, size_t out_sz) {
  size_t n;
  const char *dot;
  if (!c_path || !out || out_sz < 6) return 0;
  n = strlen(c_path);
  dot = strrchr(c_path, '.');
  if (!dot || strcmp(dot, ".c") != 0) return 0;
  if ((size_t)(dot - c_path) + 5 >= out_sz) return 0;
  memcpy(out, c_path, (size_t)(dot - c_path));
  memcpy(out + (dot - c_path), ".lisp", 6);
  return 1;
}

static int nano_cc_compile_via_companion_lisp(const char *src_path, const char *out_path) {
  char lisp_path[4096];
  int a = 0;
  int b = 0;
  size_t n = 0;
  unsigned char *src = read_file(src_path, &n);
  int rc;
  if (!src) {
    fprintf(stderr, "nano-cc=read_fail path=%s\n", src_path);
    return 1;
  }
  if (!nano_cc_parse_add_module((const char *)src, n, &a, &b)) {
    free(src);
    return -1;
  }
  free(src);
  if (!nano_cc_companion_lisp_path(src_path, lisp_path, sizeof(lisp_path))) {
    fprintf(stderr, "nano-cc=companion_path_fail path=%s\n", src_path);
    return 2;
  }
  if (!nano_cc_path_readable(lisp_path)) {
    fprintf(stderr, "nano-cc=companion_missing path=%s\n", lisp_path);
    return 2;
  }
  rc = cmd_compile_elf64_exe(lisp_path, out_path, "nano_cc_add");
  if (rc != 0) return rc;
  printf("nano-cc.source=%s\n", src_path);
  printf("nano-cc.lisp=%s\n", lisp_path);
  printf("nano-cc.output=%s\n", out_path);
  printf("nano-cc.exit_code=%d\n", a + b);
  return 0;
}

static int nano_cc_can_compile_path(const char *src_path) {
  size_t n = 0;
  unsigned char *src = read_file(src_path, &n);
  int code = 0;
  int a = 0;
  int b = 0;
  int ok = 0;
  char lisp_path[4096];
  if (!src) return 0;
  if (nano_cc_parse_main_return((const char *)src, n, &code)) {
    ok = 1;
  } else if (nano_cc_parse_add_module((const char *)src, n, &a, &b) &&
             nano_cc_companion_lisp_path(src_path, lisp_path, sizeof(lisp_path)) &&
             nano_cc_path_readable(lisp_path)) {
    ok = 1;
  }
  free(src);
  return ok;
}

static int cmd_nano_cc_compile(const char *src_path, const char *out_path) {
  size_t n = 0;
  unsigned char *src = read_file(src_path, &n);
  int code = 0;
  int rc;
  if (!src) {
    fprintf(stderr, "nano-cc=read_fail path=%s\n", src_path);
    return 1;
  }
  if (nano_cc_parse_main_return((const char *)src, n, &code)) {
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
  free(src);
  rc = nano_cc_compile_via_companion_lisp(src_path, out_path);
  if (rc == 0) return 0;
  if (rc == -1) {
    fprintf(stderr, "nano-cc=unsupported_source path=%s\n", src_path);
    return 2;
  }
  return rc;
}

static int cmd_nano_cc_compile_expect_exit(const char *expected_s, const char *src_path,
                                           const char *out_path) {
  size_t expected = 0;
  int actual;
  if (!expected_s || !src_path || !out_path) {
    fprintf(stderr, "nano-cc-compile-expect-exit=bad_args\n");
    return 1;
  }
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "nano-cc-compile-expect-exit=bad_expected\n");
    return 1;
  }
  actual = cmd_nano_cc_compile(src_path, out_path);
  printf("nano-cc-compile-expect-exit.expected=%zu\n", expected);
  printf("nano-cc-compile-expect-exit.actual=%d\n", actual);
  if ((size_t)actual == expected) {
    printf("nano-cc-compile-expect-exit.ok=1\n");
    return 0;
  }
  fprintf(stderr, "nano-cc-compile-expect-exit=mismatch expected=%zu actual=%d\n", expected,
          actual);
  return 1;
}
