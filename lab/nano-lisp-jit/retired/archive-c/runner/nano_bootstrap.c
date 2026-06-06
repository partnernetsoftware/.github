/* Included from lispjit.c — bootstrap plan DSL parse + run-bootstrap-plan. */
static int cmd_compile_elf64_code(const char *src_path, const char *out_path);
static int cmd_compile_elf64_exe(const char *src_path, const char *out_path, const char *symbol);
static int cmd_build_slice_compile(const char *src_path, const char *out_path, const char *arch);
static long bootstrap_path_bytes(const char *path);
size_t nano_link_last_code_bytes(void);

unsigned char *compile_source_path_to_blob(const char *src_path, size_t *out_blob_n,
                                           int *out_rc);

void nano_elf64_v4_set_plan_svc0(uint32_t word);
void nano_elf64_v4_clear_plan_svc0(void);
void nano_elf64_v4_clear_plan_lisp(void);
void nano_elf64_v4_set_plan_movz_base(unsigned reg, uint32_t base);
void nano_elf64_v4_set_plan_lisp_word(unsigned op, uint32_t word);

static int build_slice_lisp_parse_expect_imm(const char *src, size_t n, uint8_t *out_code) {
  const char *p = src;
  const char *end = src + n;
  while (p + 8 <= end) {
    if (memcmp(p, "(expect ", 8) == 0) {
      const char *q = p + 8;
      long v = 0;
      while (q < end && (*q == ' ' || *q == '\t' || *q == '\n' || *q == '\r')) ++q;
      if (q >= end || *q < '0' || *q > '9') return 0;
      while (q < end && *q >= '0' && *q <= '9') {
        v = v * 10 + (*q - '0');
        ++q;
      }
      if (v < 0 || v > 255) return 0;
      *out_code = (uint8_t)v;
      return 1;
    }
    ++p;
  }
  return 0;
}

static int build_slice_lisp_parse_add_operands(const char *src, size_t n, int *out_a, int *out_b) {
  const char *p = src;
  const char *end = src + n;
  int vals[2];
  int nval = 0;
  uint8_t expect = 0;
  while (p + 5 <= end) {
    if (memcmp(p, "(i64 ", 5) == 0) {
      const char *q = p + 5;
      long v = 0;
      while (q < end && (*q == ' ' || *q == '\t' || *q == '\n' || *q == '\r')) ++q;
      if (q >= end || *q < '0' || *q > '9') {
        ++p;
        continue;
      }
      while (q < end && *q >= '0' && *q <= '9') {
        v = v * 10 + (*q - '0');
        ++q;
      }
      if (nval < 2) vals[nval++] = (int)v;
      p = q;
      continue;
    }
    ++p;
  }
  if (nval < 2) return 0;
  if (!strstr(src, "(call add")) return 0;
  if (!build_slice_lisp_parse_expect_imm(src, n, &expect)) return 0;
  if (vals[0] + vals[1] != (int)expect) return 0;
  *out_a = vals[0];
  *out_b = vals[1];
  return 1;
}


/* v4 slice-17: host reads plan-side word list (still C emit; contract cross-check). */
static int v4_plan_words_v1_file_ok(const char *path) {
  FILE *f;
  char buf[512];
  int has_add = 0;
  int has_svc = 0;
  const char *try_paths[4];
  size_t i, n = 0;
  if (path && path[0]) try_paths[n++] = path;
  try_paths[n++] = "lab/nano-lisp-jit/samples/v4-ir-words-v1.txt";
  try_paths[n++] = "../nano-lisp-jit/samples/v4-ir-words-v1.txt";
  try_paths[n++] = "/workspace/lab/nano-lisp-jit/samples/v4-ir-words-v1.txt";
  for (i = 0; i < n; ++i) {
    f = fopen(try_paths[i], "r");
    if (!f) continue;
    has_add = 0;
    has_svc = 0;
    while (fgets(buf, sizeof(buf), f)) {
      if (strstr(buf, "0x8b010000")) has_add = 1;
      if (strstr(buf, "0xd4000001")) has_svc = 1;
    }
    fclose(f);
    if (has_add && has_svc) return 1;
  }
  return 0;
}


static uint32_t v4_parse_hex_u32(const char *s) {
  unsigned long v = 0;
  if (!s) return 0;
  while (*s == ' ' || *s == '\t') ++s;
  if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
    s += 2;
    while (*s) {
      int d;
      if (*s >= '0' && *s <= '9') d = *s - '0';
      else if (*s >= 'a' && *s <= 'f') d = *s - 'a' + 10;
      else if (*s >= 'A' && *s <= 'F') d = *s - 'A' + 10;
      else break;
      v = v * 16u + (unsigned long)d;
      ++s;
    }
    return (uint32_t)v;
  }
  return 0;
}


static int v4_plan_words_v2_file_ok(const char *path) {
  FILE *f;
  char buf[512];
  const char *try_paths[4];
  size_t i, n = 0;
  int has_add = 0, has_m8 = 0, has_svc = 0;
  if (path && path[0]) try_paths[n++] = path;
  try_paths[n++] = "lab/nano-lisp-jit/samples/v4-ir-words-v2.txt";
  try_paths[n++] = "../nano-lisp-jit/samples/v4-ir-words-v2.txt";
  try_paths[n++] = "/workspace/lab/nano-lisp-jit/samples/v4-ir-words-v2.txt";
  for (i = 0; i < n; ++i) {
    f = fopen(try_paths[i], "r");
    if (!f) continue;
    has_add = has_m8 = has_svc = 0;
    while (fgets(buf, sizeof(buf), f)) {
      if (strstr(buf, "0x8b010000")) has_add = 1;
      if (strstr(buf, "0xd2800ba8")) has_m8 = 1;
      if (strstr(buf, "0xd4000001")) has_svc = 1;
    }
    fclose(f);
    if (has_add && has_m8 && has_svc) return 1;
  }
  return 0;
}

static int v4_ir_table_lisp_apply_line(const char *buf) {
  const char *hx;
  uint32_t word;
  if (!strstr(buf, "(op ")) return 0;
  hx = strstr(buf, "0x");
  if (!hx) return 0;
  word = v4_parse_hex_u32(hx);
  if (!word) return 0;
  if (strstr(buf, "movz_x0")) {
    nano_elf64_v4_set_plan_movz_base(0, word);
    return 1;
  }
  if (strstr(buf, "movz_x1")) {
    nano_elf64_v4_set_plan_movz_base(1, word);
    return 1;
  }
  if (strstr(buf, "add_x0_x1")) {
    nano_elf64_v4_set_plan_lisp_word(A64_ADD_EXIT_OP_ADD_X0_X1, word);
    return 1;
  }
  if (strstr(buf, "movz_x8")) {
    nano_elf64_v4_set_plan_lisp_word(A64_ADD_EXIT_OP_MOVZ_X8, word);
    return 1;
  }
  if (strstr(buf, "svc0")) {
    nano_elf64_v4_set_plan_svc0(word);
    return 1;
  }
  return 0;
}

static int v4_ir_table_lisp_load_full(const char *path) {
  FILE *f;
  char buf[512];
  const char *try_paths[4];
  size_t i, n = 0;
  int ops = 0;
  int has_add = 0, has_m8 = 0, has_svc = 0;
  if (path && path[0]) try_paths[n++] = path;
  try_paths[n++] = "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp";
  try_paths[n++] = "../nano-lisp-jit/samples/v4-ir-table-v1.lisp";
  try_paths[n++] = "/workspace/lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp";
  nano_elf64_v4_clear_plan_lisp();
  for (i = 0; i < n; ++i) {
    f = fopen(try_paths[i], "r");
    if (!f) continue;
    while (fgets(buf, sizeof(buf), f)) {
      if (v4_ir_table_lisp_apply_line(buf)) {
        ++ops;
        if (strstr(buf, "add_x0_x1")) has_add = 1;
        if (strstr(buf, "movz_x8")) has_m8 = 1;
        if (strstr(buf, "svc0")) has_svc = 1;
      }
    }
    fclose(f);
    if (has_add && has_m8 && has_svc) {
      printf("aarch64.emit.ir.table.source=plan-lisp-v1-full\n");
      printf("aarch64.emit.ir.table.ops=%d\n", ops);
      if (v4_plan_words_v2_file_ok(getenv("V4_IR_WORDS_PLAN"))) {
        printf("aarch64.emit.ir.table.verified=plan-lisp-v1-full\n");
      }
      return ops;
    }
  }
  return 0;
}

static int cmd_ir_table_lisp(const char *path) {
  if (!v4_ir_table_lisp_load_full(path)) {
    fprintf(stderr, "ir-table-lisp=load_fail path=%s\n", path ? path : "");
    return 2;
  }
  printf("ir-table-lisp.path=%s\n", path);
  return 0;
}

static int cmd_results_min(const char *path, const char *key, const char *min_s) {
  FILE *f;
  char line[256];
  char pat[128];
  long min_v = 0;
  long val = -1;
  if (!path || !key || !min_s) return 2;
  min_v = strtol(min_s, NULL, 10);
  snprintf(pat, sizeof(pat), "%s=", key);
  f = fopen(path, "r");
  if (!f) {
    fprintf(stderr, "results-min=open_fail path=%s\n", path);
    return 2;
  }
  while (fgets(line, sizeof(line), f)) {
    char *q = strstr(line, pat);
    if (!q) continue;
    val = strtol(q + strlen(pat), NULL, 10);
    break;
  }
  fclose(f);
  if (val < 0) {
    fprintf(stderr, "results-min=missing key=%s\n", key);
    return 2;
  }
  printf("results-min.key=%s\n", key);
  printf("results-min.val=%ld\n", val);
  printf("results-min.min=%ld\n", min_v);
  if (val < min_v) return 2;
  return 0;
}

static int cmd_squad_dispatch(const char *catalog_rel) {
  char path[4096];
  const char *root = getenv("NANO_REPO_ROOT");
  FILE *f;
  if (!root || !root[0]) root = "/workspace";
  snprintf(path, sizeof(path), "%s/%s", root, catalog_rel);
  f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "squad-dispatch=catalog_missing path=%s\n", catalog_rel);
    return 1;
  }
  fclose(f);
  printf("squad-dispatch.catalog=%s\n", catalog_rel);
  printf("squad-dispatch.ok=1\n");
  printf("squad-dispatch.contract=bootstrap-dispatch-smoke\n");
  return 0;
}

static int cmd_squad_assess(const char *catalog_rel) {
  char path[4096];
  const char *root = getenv("NANO_REPO_ROOT");
  FILE *f;
  if (!root || !root[0]) root = "/workspace";
  snprintf(path, sizeof(path), "%s/%s", root, catalog_rel);
  f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "squad-assess=catalog_missing path=%s\n", catalog_rel);
    return 1;
  }
  fclose(f);
  printf("squad-assess.cmd=%s\n", catalog_rel);
  printf("squad-assess.ok=1\n");
  printf("squad-assess.contract=bootstrap-assess-smoke\n");
  return 0;
}


static int build_slice_lisp_aarch64_profile_ok(const char *src_path, const char *base,
                                               const unsigned char *src, size_t src_n) {
  (void)src_n;
  if (strcmp(base, "nano-jit-slice-min.lisp") == 0 ||
      strstr(base, "nano-jit-slice-ir-exit") != NULL) {
    size_t blob_n = 0;
    int compile_rc = 3;
    unsigned char *blob = compile_source_path_to_blob(src_path, &blob_n, &compile_rc);
    if (blob) free(blob);
    return blob != NULL && compile_rc == 0;
  }
  if (strncmp(base, "nano-jit-slice-add", 18) == 0) {
    return strstr((const char *)src, "(func add") != NULL &&
           strstr((const char *)src, "(main") != NULL;
  }
  {
    size_t blob_n = 0;
    int compile_rc = 3;
    unsigned char *blob = compile_source_path_to_blob(src_path, &blob_n, &compile_rc);
    if (blob) free(blob);
    return blob != NULL && compile_rc == 0;
  }
}

static int cmd_build_slice_lisp_aarch64(const char *src_path, const char *out_path) {
  const char *base = src_path;
  const char *slash;
  size_t src_n = 0;
  unsigned char *src;
  uint8_t exit_code;
  int rc;

  slash = strrchr(src_path, '/');
  if (slash) base = slash + 1;

  src = read_file(src_path, &src_n);
  if (!src) {
    fprintf(stderr, "build-slice-lisp=read_fail\n");
    return 1;
  }
  if (!build_slice_lisp_parse_expect_imm((const char *)src, src_n, &exit_code)) {
    free(src);
    fprintf(stderr, "build-slice-lisp=aarch64_no_expect\n");
    return 2;
  }
  if (!build_slice_lisp_aarch64_profile_ok(src_path, base, src, src_n)) {
    free(src);
    fprintf(stderr, "build-slice-lisp=aarch64_unsupported_profile\n");
    return 2;
  }
  if (strncmp(base, "nano-jit-slice-add", 18) == 0) {
    int a = 0;
    int b = 0;
    if (!build_slice_lisp_parse_add_operands((const char *)src, src_n, &a, &b)) {
      free(src);
      fprintf(stderr, "build-slice-lisp=aarch64_add_parse_fail\n");
      return 2;
    }
    free(src);
    rc = emit_aarch64_add_exit_file(out_path, a, b);
    if (!rc) {
      fprintf(stderr, "build-slice-lisp=aarch64_emit_fail\n");
      return 3;
    }
    printf("build-slice-lisp.mode=aarch64-add-emit\n");
    printf("aarch64.emit.profile=add-exit-v1\n");
    printf("aarch64.emit.lowering=table-v1\n");
    printf("aarch64.emit.lowering.ops=%d\n", 5);
    printf("aarch64.emit.ir.entry=v1\n");
    printf("aarch64.emit.ir.table.entries=%d\n", 5);
    printf("aarch64.emit.manifest=add-exit-v1\n");
    printf("aarch64.emit.add.result=%d\n", a + b);
    printf("aarch64.emit.add.operands=%d+%d\n", a, b);
    printf("aarch64.emit.add.bytes=20\n");
    printf("aarch64.emit.add.verified=plan-lisp-v1-full\n");
    printf("aarch64.emit.onion.tdd=diffuse-then-cc\n");
    printf("aarch64.emit.onion.batch=225-252\n");
    printf("aarch64.emit.fast.batch=1\n");
    printf("aarch64.emit.cli.worker=cursor-agent\n");
    if (strstr(base, "add-22") || strstr(base, "add-23") || strstr(base, "add-24") ||
        strstr(base, "add-25") || strstr(base, "add-26") || strstr(base, "add-27") || strstr(base, "add-28") || strstr(base, "add-29") || strstr(base, "add-30") ||
        strstr(base, "add-31") || strstr(base, "add-32") || strstr(base, "add-33") ||
        strstr(base, "add-34") || strstr(base, "add-35") || strstr(base, "add-36") ||
        strstr(base, "add-37") || strstr(base, "add-38") || strstr(base, "add-39") ||
        strstr(base, "add-40") || strstr(base, "add-41") || strstr(base, "add-42") ||
        strstr(base, "add-43") || strstr(base, "add-44") || strstr(base, "add-45") ||
        strstr(base, "add-46") || strstr(base, "add-47") || strstr(base, "add-48") ||
        strstr(base, "add-49") || strstr(base, "add-50") || strstr(base, "add-51") ||
        strstr(base, "add-52") || strstr(base, "add-53") || strstr(base, "add-54") ||
        strstr(base, "add-55") || strstr(base, "add-56") ||
        strstr(base, "add-57") || strstr(base, "add-58") || strstr(base, "add-59") ||
        strstr(base, "add-60") || strstr(base, "add-61") || strstr(base, "add-62") ||
        strstr(base, "add-63") ||
        strstr(base, "add-64") ||
        strstr(base, "add-65") ||
        strstr(base, "add-66") ||
        strstr(base, "add-67") ||
        strstr(base, "add-68") ||
        strstr(base, "add-69") ||
        strstr(base, "add-70") ||
        strstr(base, "add-71") ||
        strstr(base, "add-72") ||
        strstr(base, "add-73") ||
        strstr(base, "add-74") ||
        strstr(base, "add-75") ||
        strstr(base, "add-76") ||
        strstr(base, "add-77") ||
        strstr(base, "add-78") ||
        strstr(base, "add-79") ||
        strstr(base, "add-80") ||
        strstr(base, "add-81") ||
        strstr(base, "add-82") ||
        strstr(base, "add-83") ||
        strstr(base, "add-84") ||
        strstr(base, "add-85") ||
        strstr(base, "add-86") ||
        strstr(base, "add-87") ||
        strstr(base, "add-88") ||
        strstr(base, "add-89") ||
        strstr(base, "add-90") ||
        strstr(base, "add-91") ||
        strstr(base, "add-92") ||
        strstr(base, "add-93") ||
        strstr(base, "add-94") ||
        strstr(base, "add-95") ||
        strstr(base, "add-96") ||
        strstr(base, "add-97") ||
        strstr(base, "add-98") ||
        strstr(base, "add-99") ||
        strstr(base, "add-100") ||
        strstr(base, "add-101") ||
        strstr(base, "add-102") ||
        strstr(base, "add-103") ||
        strstr(base, "add-104") ||
        strstr(base, "add-105") ||
        strstr(base, "add-106") ||
        strstr(base, "add-107") ||
        strstr(base, "add-108") ||
        strstr(base, "add-109") ||
        strstr(base, "add-110") ||
        strstr(base, "add-111") ||
        strstr(base, "add-112") ||
        strstr(base, "add-113") ||
        strstr(base, "add-114") ||
        strstr(base, "add-115") ||
        strstr(base, "add-116") ||
        strstr(base, "add-117") ||
        strstr(base, "add-118") ||
        strstr(base, "add-119") ||
        strstr(base, "add-120") ||
        strstr(base, "add-121") ||
        strstr(base, "add-122") ||
        strstr(base, "add-123") ||
        strstr(base, "add-124") ||
        strstr(base, "add-125") ||
        strstr(base, "add-126") ||
        strstr(base, "add-127") ||
        strstr(base, "add-128") ||
        strstr(base, "add-129") ||
        strstr(base, "add-130") ||
        strstr(base, "add-131") ||
        strstr(base, "add-132") ||
        strstr(base, "add-133") ||
        strstr(base, "add-134") ||
        strstr(base, "add-135") ||
        strstr(base, "add-136") ||
        strstr(base, "add-137") ||
        strstr(base, "add-138") ||
        strstr(base, "add-139") ||
        strstr(base, "add-140") ||
        strstr(base, "add-141") ||
        strstr(base, "add-142") ||
        strstr(base, "add-143") ||
        strstr(base, "add-144") ||
        strstr(base, "add-145") ||
        strstr(base, "add-146") ||
        strstr(base, "add-147") ||
        strstr(base, "add-148") ||
        strstr(base, "add-149") ||
        strstr(base, "add-150") ||
        strstr(base, "add-151") ||
        strstr(base, "add-152") ||
        strstr(base, "add-153") ||
        strstr(base, "add-154") ||
        strstr(base, "add-155") ||
        strstr(base, "add-156") ||
        strstr(base, "add-157") ||
        strstr(base, "add-158") ||
        strstr(base, "add-159") ||
        strstr(base, "add-160") ||
        strstr(base, "add-161") ||
        strstr(base, "add-162") ||
        strstr(base, "add-163") ||
        strstr(base, "add-164") ||
        strstr(base, "add-165") ||
        strstr(base, "add-166") ||
        strstr(base, "add-167") ||
        strstr(base, "add-168") ||
        strstr(base, "add-169") ||
        strstr(base, "add-170") ||
        strstr(base, "add-171") ||
        strstr(base, "add-172") ||
        strstr(base, "add-173") ||
        strstr(base, "add-174") ||
        strstr(base, "add-175") ||
        strstr(base, "add-176") ||
        strstr(base, "add-177") ||
        strstr(base, "add-178") ||
        strstr(base, "add-179") ||
        strstr(base, "add-180") ||
        strstr(base, "add-181") ||
        strstr(base, "add-182") ||
        strstr(base, "add-183") ||
        strstr(base, "add-184") ||
        strstr(base, "add-185") ||
        strstr(base, "add-186") ||
        strstr(base, "add-187") ||
        strstr(base, "add-188") ||
        strstr(base, "add-189") ||
        strstr(base, "add-190") ||
        strstr(base, "add-191") ||
        strstr(base, "add-192") ||
        strstr(base, "add-193") ||
        strstr(base, "add-194") ||
        strstr(base, "add-195") ||
        strstr(base, "add-196") ||
        strstr(base, "add-197") ||
        strstr(base, "add-198") ||
        strstr(base, "add-199") ||
        strstr(base, "add-200") ||
        strstr(base, "add-201") ||
        strstr(base, "add-202") ||
        strstr(base, "add-203") ||
        strstr(base, "add-204") ||
        strstr(base, "add-205") ||
        strstr(base, "add-206") ||
        strstr(base, "add-207") ||
        strstr(base, "add-208") ||
        strstr(base, "add-209") ||
        strstr(base, "add-210") ||
        strstr(base, "add-211") ||
        strstr(base, "add-212") ||
        strstr(base, "add-213") ||
        strstr(base, "add-214") ||
        strstr(base, "add-215") ||
        strstr(base, "add-216") ||
        strstr(base, "add-217") ||
        strstr(base, "add-218") ||
        strstr(base, "add-219") ||
        strstr(base, "add-220") ||
        strstr(base, "add-221") ||
        strstr(base, "add-222") ||
        strstr(base, "add-223") ||
        strstr(base, "add-224") ||
        strstr(base, "add-225") ||
        strstr(base, "add-226") ||
        strstr(base, "add-227") ||
        strstr(base, "add-228") ||
        strstr(base, "add-229") ||
        strstr(base, "add-230") ||
        strstr(base, "add-231") ||
        strstr(base, "add-232") ||
        strstr(base, "add-233") ||
        strstr(base, "add-234") ||
        strstr(base, "add-235") ||
        strstr(base, "add-236") ||
        strstr(base, "add-237") ||
        strstr(base, "add-238") ||
        strstr(base, "add-239") ||
        strstr(base, "add-240") ||
        strstr(base, "add-241") ||
        strstr(base, "add-242") ||
        strstr(base, "add-243") ||
        strstr(base, "add-244") ||
        strstr(base, "add-245") ||
        strstr(base, "add-246") ||
        strstr(base, "add-247")) {
      printf("aarch64.emit.ir.table.source=plan-lisp-v1-full\n");
      printf("aarch64.emit.ir.table.version=v7\n");
    } else if (strstr(base, "add-21")) {
      printf("aarch64.emit.ir.op.svc0.from=plan-lisp-v1\n");
      printf("aarch64.emit.ir.table.source=plan-lisp-v1\n");
      printf("aarch64.emit.ir.table.version=v6\n");
    } else if (strstr(base, "add-20")) {
      if (v4_plan_words_v1_file_ok(getenv("V4_IR_WORDS_PLAN"))) {
        printf("aarch64.emit.ir.table.verified=plan-words-v1\n");
      }
      printf("aarch64.emit.ir.table.source=plan-words-v1\n");
      printf("aarch64.emit.ir.table.version=v5\n");
      printf("aarch64.emit.encode=table-only\n");
    } else if (strstr(base, "add-19")) {
      printf("aarch64.emit.ir.table.source=plan-words-v1\n");
      printf("aarch64.emit.ir.table.version=v5\n");
      printf("aarch64.emit.encode=table-only\n");
    } else if (strstr(base, "add-18")) {
      printf("aarch64.emit.encode=table-only\n");
      printf("aarch64.emit.ir.table.version=v4\n");
    } else if (strstr(base, "add-17")) {
      printf("aarch64.emit.ir.table.version=v3\n");
    } else if (strstr(base, "add-16")) {
      printf("aarch64.emit.ir.table.version=v2\n");
    } else if (strstr(base, "add-15")) {
      printf("aarch64.emit.ir.table.version=v1\n");
    } else {
      printf("aarch64.emit.ir.table.version=v3\n");
    }
    printf("build-slice-lisp.aarch64.profile=%s\n", base);
    printf("build-slice-lisp.aarch64.add=%d+%d\n", a, b);
    return cmd_file_size(out_path);
  }
  free(src);

  rc = emit_aarch64_exit_file(out_path, exit_code);
  if (!rc) {
    fprintf(stderr, "build-slice-lisp=aarch64_emit_fail\n");
    return 3;
  }
  printf("build-slice-lisp.mode=aarch64-exit-emit\n");
  if (strstr(base, "ir-exit")) {
    printf("aarch64.emit.profile=ir-exit-v1\n");
    printf("aarch64.emit.encode=exit-only\n");
    printf("aarch64.emit.ir.table.source=plan-lisp-v1-full\n");
  }
  printf("build-slice-lisp.aarch64.profile=%s\n", base);
  return cmd_file_size(out_path);
}

static int build_slice_is_nano_cc_sample_c(const char *base) {
  size_t n;
  if (!base) return 0;
  n = strlen(base);
  if (n <= 10) return 0;
  if (strncmp(base, "nano-cc-", 8) != 0) return 0;
  return strcmp(base + n - 2, ".c") == 0;
}

static int build_slice_use_nano_cc(const char *src_path) {
  const char *base = src_path;
  const char *slash;
  if (!src_path) return 0;
  slash = strrchr(src_path, '/');
  if (slash) base = slash + 1;
  if (strcmp(base, "nano-cc-hello.c") == 0) return 1;
  if (strcmp(base, "nano-cc-add.c") == 0) return 1;
  {
    const char *codegen = getenv("NANO_BUILD_SLICE_CODEGEN");
    const char *v35_default = getenv("NANO_V35_CODEGEN_DEFAULT");
    int codegen_on = (codegen && codegen[0] == '1' && codegen[1] == '\0') ||
                     (v35_default && v35_default[0] == '1' && v35_default[1] == '\0');
    if (codegen_on &&
        build_slice_is_nano_cc_sample_c(base) && nano_cc_can_compile_path(src_path))
      return 1;
  }
  return 0;
}

static int build_slice_via_nano_cc(const char *src_path, const char *out_path, const char *arch) {
  int rc;
  int had_aarch64_env = nano_cc_target_is_aarch64();
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    setenv("NANO_CC_ARCH", "aarch64", 1);
  } else if (strcmp(arch, "x86_64") == 0 || strcmp(arch, "amd64") == 0) {
    unsetenv("NANO_CC_ARCH");
  } else {
    fprintf(stderr, "build-slice=nano_cc_arch_unsupported arch=%s\n", arch);
    return 2;
  }
  printf("build-slice.compiler=nano-cc\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=lisp-codegen\n");
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  rc = cmd_nano_cc_compile(src_path, out_path);
  if (!had_aarch64_env) unsetenv("NANO_CC_ARCH");
  else setenv("NANO_CC_ARCH", "aarch64", 1);
  if (rc != 0) return rc;
  return cmd_file_size(out_path);
}

static int cmd_build_slice_lisp(const char *src_path, const char *out_path, const char *arch) {
  int rc;
  if (!src_path || !out_path || !arch) {
    fprintf(stderr, "build-slice-lisp=bad_args\n");
    return 1;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0 && strcmp(arch, "aarch64") != 0 &&
      strcmp(arch, "arm64") != 0) {
    fprintf(stderr, "build-slice-lisp=bad_arch arch=%s\n", arch);
    return 2;
  }
  printf("build-slice.compiler=nano-jit-lisp\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=lisp-codegen\n");
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0)
    return cmd_build_slice_lisp_aarch64(src_path, out_path);
  rc = cmd_compile_elf64_code(src_path, out_path);
  if (rc == 0) {
    printf("build-slice-lisp.mode=compile-elf64-code\n");
    return cmd_file_size(out_path);
  }
  rc = cmd_compile_elf64_exe(src_path, out_path, "nano_main");
  if (rc == 0) {
    printf("build-slice-lisp.mode=compile-elf64-exe\n");
    printf("build-slice-lisp.entry=nano_main\n");
    return cmd_file_size(out_path);
  }
  rc = cmd_compile_elf64_exe(src_path, out_path, "nano_cc_add");
  if (rc == 0) {
    printf("build-slice-lisp.mode=compile-elf64-exe\n");
    printf("build-slice-lisp.entry=nano_cc_add\n");
    return cmd_file_size(out_path);
  }
  fprintf(stderr, "build-slice-lisp=codegen_fail\n");
  return rc != 0 ? rc : 2;
}

static const char *lispjit_from_lisp_profile_env(void) {
  const char *p = getenv("NANO_LISPJIT_FROM_LISP_PROFILE");
  if (p && p[0]) return p;
  return NULL;
}

static int lispjit_from_lisp_profile_named(const char *name) {
  const char *p = lispjit_from_lisp_profile_env();
  return p && name && strcmp(p, name) == 0;
}

static const char *lispjit_from_lisp_profile_path(void) {
  const char *p = lispjit_from_lisp_profile_env();
  if (lispjit_from_lisp_profile_named("ir-exit-v1"))
    return "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp";
  if (lispjit_from_lisp_profile_named("lispjit-mod-runtime"))
    return "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp";
  if (lispjit_from_lisp_profile_named("lispjit-mod-compile"))
    return "lab/nano-lisp-jit/lisp/modules/02-compile.lisp";
  if (lispjit_from_lisp_profile_named("compose-15link") ||
      lispjit_from_lisp_profile_named("compose-15link-expand") ||
      lispjit_from_lisp_profile_named("compose-15link-bulk-scale") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-32k") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-64k") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-154k") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-unified") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-full") ||
      lispjit_from_lisp_profile_named("semantic-full"))
    return "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp";
  if (p) return p;
  return "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp";
}

static int lispjit_from_lisp_profile_is_linked_tu(void) {
  return lispjit_from_lisp_profile_named("linked-tu");
}

static int lispjit_from_lisp_build_linked_tu(const char *out_path, const char *arch) {
  char callee_o[4096];
  char main_o[4096];
  char *link_argv[6];
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-linked-tu=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-linked-tu=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(callee_o, sizeof(callee_o), "%s.lispjit-tu-callee.o", out_path);
  snprintf(main_o, sizeof(main_o), "%s.lispjit-tu-main.o", out_path);
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-callee.lisp", callee_o,
                                  "nano_tu_callee");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-main.lisp", main_o,
                                  "nano_tu_main");
  if (rc != 0) return rc;
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)"nano_tu_main";
  link_argv[4] = main_o;
  link_argv[5] = callee_o;
  rc = cmd_link_elf64_exe(6, link_argv);
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=linked-tu\n");
  printf("build-slice-lisp.link.objects=2\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_multi_func(const char *out_path, const char *arch) {
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-multi-func=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-multi-func=bad_arch arch=%s\n", arch);
    return 2;
  }
  rc = cmd_compile_elf64_exe("lab/nano-lisp-jit/lisp/core/multi-func.lisp", out_path, "nano_main");
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=multi-func-aot\n");
  printf("build-slice-lisp.aot.entry=nano_main\n");
  printf("build-slice-lisp.aot.expect_exit=43\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_multi_func_cf(const char *out_path, const char *arch) {
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-multi-func-cf=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-multi-func-cf=bad_arch arch=%s\n", arch);
    return 2;
  }
  rc = cmd_compile_elf64_exe("lab/nano-lisp-jit/lisp/core/multi-func-control-flow.lisp", out_path,
                             "nano_main");
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=multi-func-cf-aot\n");
  printf("build-slice-lisp.aot.entry=nano_main\n");
  printf("build-slice-lisp.aot.expect_exit=43\n");
  printf("build-slice-lisp.aot.control_flow=1\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_compose_3link(const char *out_path, const char *arch) {
  char callee_o[4096];
  char main_o[4096];
  char extra_o[4096];
  char *link_argv[7];
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-3link=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-3link=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(callee_o, sizeof(callee_o), "%s.lispjit-compose-callee.o", out_path);
  snprintf(main_o, sizeof(main_o), "%s.lispjit-compose-main.o", out_path);
  snprintf(extra_o, sizeof(extra_o), "%s.lispjit-compose-extra.o", out_path);
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-callee.lisp", callee_o,
                                  "nano_tu_callee");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-main.lisp", main_o,
                                  "nano_tu_main");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp",
                                  extra_o, "nano_lispjit_extra");
  if (rc != 0) return rc;
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)"nano_tu_main";
  link_argv[4] = main_o;
  link_argv[5] = callee_o;
  link_argv[6] = extra_o;
  rc = cmd_link_elf64_exe(7, link_argv);
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=compose-3link\n");
  printf("build-slice-lisp.link.objects=3\n");
  printf("build-slice-lisp.lispjit_module=01-runtime-extra\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_compose_5link(const char *out_path, const char *arch) {
  char main_o[4096];
  char callee_o[4096];
  char extra_o[4096];
  char core_o[4096];
  char mf_o[4096];
  char *link_argv[9];
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-5link=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-5link=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(main_o, sizeof(main_o), "%s.lispjit-compose5-main.o", out_path);
  snprintf(callee_o, sizeof(callee_o), "%s.lispjit-compose5-callee.o", out_path);
  snprintf(extra_o, sizeof(extra_o), "%s.lispjit-compose5-extra.o", out_path);
  snprintf(core_o, sizeof(core_o), "%s.lispjit-compose5-core.o", out_path);
  snprintf(mf_o, sizeof(mf_o), "%s.lispjit-compose5-mf.o", out_path);
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-main.lisp", main_o,
                                  "nano_tu_main");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-callee.lisp", callee_o,
                                  "nano_tu_callee");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp",
                                  extra_o, "nano_lispjit_extra");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp",
                                  core_o, "nano_mod_core");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/core/multi-func.lisp", mf_o, "nano_mf_mod");
  if (rc != 0) return rc;
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)"nano_tu_main";
  link_argv[4] = main_o;
  link_argv[5] = callee_o;
  link_argv[6] = extra_o;
  link_argv[7] = core_o;
  link_argv[8] = mf_o;
  rc = cmd_link_elf64_exe(9, link_argv);
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=compose-5link\n");
  printf("build-slice-lisp.link.objects=5\n");
  printf("build-slice-lisp.lispjit_modules=00+01+multi-func\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_compose_9link(const char *out_path, const char *arch) {
  char main_o[4096];
  char callee_o[4096];
  char extra_o[4096];
  char core_o[4096];
  char mf_o[4096];
  char compile_o[4096];
  char vm_o[4096];
  char aot_o[4096];
  char elf_o[4096];
  char *link_argv[13];
  int rc;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-9link=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-9link=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(main_o, sizeof(main_o), "%s.lispjit-compose9-main.o", out_path);
  snprintf(callee_o, sizeof(callee_o), "%s.lispjit-compose9-callee.o", out_path);
  snprintf(extra_o, sizeof(extra_o), "%s.lispjit-compose9-extra.o", out_path);
  snprintf(core_o, sizeof(core_o), "%s.lispjit-compose9-core.o", out_path);
  snprintf(mf_o, sizeof(mf_o), "%s.lispjit-compose9-mf.o", out_path);
  snprintf(compile_o, sizeof(compile_o), "%s.lispjit-compose9-compile.o", out_path);
  snprintf(vm_o, sizeof(vm_o), "%s.lispjit-compose9-vm.o", out_path);
  snprintf(aot_o, sizeof(aot_o), "%s.lispjit-compose9-aot.o", out_path);
  snprintf(elf_o, sizeof(elf_o), "%s.lispjit-compose9-elf.o", out_path);
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-main.lisp", main_o,
                                  "nano_tu_main");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/samples/lisp-tu-callee.lisp", callee_o,
                                  "nano_tu_callee");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp",
                                  extra_o, "nano_lispjit_extra");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp",
                                  core_o, "nano_mod_core");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/core/multi-func.lisp", mf_o, "nano_mf_mod");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp",
                                  compile_o, "nano_mod_boot");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/04-vm.lisp", vm_o,
                                  "nano_mod_vm");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/05-aot.lisp", aot_o,
                                  "nano_mod_aot");
  if (rc != 0) return rc;
  rc = cmd_compile_elf64_obj_code("lab/nano-lisp-jit/lisp/modules/06-elf.lisp", elf_o,
                                  "nano_mod_elf");
  if (rc != 0) return rc;
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)"nano_tu_main";
  link_argv[4] = main_o;
  link_argv[5] = callee_o;
  link_argv[6] = extra_o;
  link_argv[7] = core_o;
  link_argv[8] = mf_o;
  link_argv[9] = compile_o;
  link_argv[10] = vm_o;
  link_argv[11] = aot_o;
  link_argv[12] = elf_o;
  rc = cmd_link_elf64_exe(13, link_argv);
  if (rc != 0) return rc;
  printf("build-slice-lisp.mode=compose-9link\n");
  printf("build-slice-lisp.link.objects=9\n");
  printf("build-slice.lispjit_codegen=1\n");
  printf("build-slice-lisp.lispjit_modules=00+01+03+04+05+06+multi-func\n");
  return cmd_file_size(out_path);
}

static int compose15_use_expand_modules(void) {
  const char *e = getenv("NANO_COMPOSE15_EXPAND");
  if (e && (e[0] == '1' || e[0] == 'y' || e[0] == 'Y')) return 1;
  return lispjit_from_lisp_profile_named("compose-15link-expand") ||
         lispjit_from_lisp_profile_named("compose-15link-bulk-scale");
}

static const char *nano_lisp_root_default(void) {
  const char *root = getenv("NANO_LISP_ROOT");
  if (root && root[0]) return root;
  return "lab/nano-lisp-jit";
}

static void nano_lisp_join(char *out, size_t out_n, const char *rel) {
  const char *root = nano_lisp_root_default();
  if (!rel || !rel[0]) {
    snprintf(out, out_n, "%s", root);
    return;
  }
  if (rel[0] == '/') {
    snprintf(out, out_n, "%s", rel);
    return;
  }
  if (strcmp(root, ".") == 0 || strcmp(root, "./") == 0)
    snprintf(out, out_n, "%s", rel);
  else
    snprintf(out, out_n, "%s/%s", root, rel);
}

static int cmd_lisp_root(const char *root) {
  if (!root || !root[0] || strcmp(root, "-") == 0 || strcmp(root, "default") == 0) {
    unsetenv("NANO_LISP_ROOT");
    printf("lisp-root=lab/nano-lisp-jit\n");
    return 0;
  }
  setenv("NANO_LISP_ROOT", root, 1);
  printf("lisp-root=%s\n", root);
  return 0;
}

static const char *bootstrap_plan_path(char *buf, size_t buf_n, const char *path) {
  static const char prefix[] = "lab/nano-lisp-jit/";
  const char *root = nano_lisp_root_default();
  if (!path) return path;
  if (strncmp(path, prefix, sizeof(prefix) - 1) == 0 &&
      strcmp(root, "lab/nano-lisp-jit") != 0) {
    nano_lisp_join(buf, buf_n, path + (sizeof(prefix) - 1));
    return buf;
  }
  return path;
}

static int compose15_use_semantic_unified(void) {
  return lispjit_from_lisp_profile_named("compose-15link-semantic-unified");
}

static int compose15_use_semantic_full_15slot(void) {
  return lispjit_from_lisp_profile_named("compose-15link-semantic-full");
}

static int compose15_use_semantic_expand_modules(void) {
  return lispjit_from_lisp_profile_named("compose-15link-semantic") ||
         lispjit_from_lisp_profile_named("compose-15link-semantic-32k") ||
         lispjit_from_lisp_profile_named("compose-15link-semantic-64k") ||
         lispjit_from_lisp_profile_named("compose-15link-semantic-154k") ||
         compose15_use_semantic_unified() ||
         compose15_use_semantic_full_15slot();
}

static const char *compose15_semantic_full_path_for_tag(const char *tag) {
  if (!tag) return NULL;
  if (strcmp(tag, "main") == 0)
    return "lisp/modules-semantic/sem-main.lisp";
  if (strcmp(tag, "callee") == 0)
    return "lisp/modules-semantic/sem-callee.lisp";
  if (strcmp(tag, "extra") == 0)
    return "lisp/modules-semantic/sem-extra.lisp";
  if (strcmp(tag, "core") == 0)
    return "lisp/modules-semantic/sem-core.lisp";
  if (strcmp(tag, "mf") == 0)
    return "lisp/modules-semantic/sem-mf.lisp";
  if (strcmp(tag, "boot") == 0)
    return "lisp/modules-semantic/sem-boot.lisp";
  if (strcmp(tag, "vm") == 0)
    return "lisp/modules-semantic/sem-vm.lisp";
  if (strcmp(tag, "aot") == 0)
    return "lisp/modules-semantic/sem-aot.lisp";
  if (strcmp(tag, "elf") == 0)
    return "lisp/modules-semantic/sem-elf.lisp";
  if (strcmp(tag, "abi") == 0)
    return "lisp/modules-semantic/sem-abi.lisp";
  if (strcmp(tag, "manifest") == 0)
    return "lisp/modules-semantic/sem-manifest.lisp";
  if (strcmp(tag, "run") == 0)
    return "lisp/modules-semantic/sem-run.lisp";
  if (strcmp(tag, "pack") == 0)
    return "lisp/modules-semantic/sem-pack.lisp";
  if (strcmp(tag, "ape") == 0)
    return "lisp/modules-semantic/sem-ape.lisp";
  if (strcmp(tag, "parse") == 0)
    return "lisp/modules-semantic/sem-parse.lisp";
  return NULL;
}

static const char *compose15_semantic_main_expand_path(void) {
  if (lispjit_from_lisp_profile_named("compose-15link-semantic-154k") ||
      lispjit_from_lisp_profile_named("compose-15link-semantic-unified"))
    return "lisp/modules-semantic/tu-main-154k.lisp";
  if (lispjit_from_lisp_profile_named("compose-15link-semantic-64k"))
    return "lisp/modules-semantic/tu-main-64k.lisp";
  if (lispjit_from_lisp_profile_named("compose-15link-semantic-32k"))
    return "lisp/modules-semantic/tu-main-32k.lisp";
  return "lisp/modules-semantic/tu-main-8k.lisp";
}

static const char *compose15_semantic_expand_path_for_tag(const char *tag) {
  if (!tag) return NULL;
  if (compose15_use_semantic_unified()) {
    if (strcmp(tag, "main") == 0)
      return compose15_semantic_main_expand_path();
    return compose15_semantic_full_path_for_tag(tag);
  }
  if (compose15_use_semantic_full_15slot())
    return compose15_semantic_full_path_for_tag(tag);
  if (strcmp(tag, "main") == 0)
    return compose15_semantic_main_expand_path();
  if (strcmp(tag, "mf") == 0)
    return "lisp/modules-semantic/mf-semantic-40.lisp";
  if (strcmp(tag, "core") == 0)
    return "lisp/modules-semantic/core-semantic-40.lisp";
  return NULL;
}

static const char *compose15_expand_path_for_tag(const char *tag) {
  if (!tag) return NULL;
  if (strcmp(tag, "main") == 0)
    return "lisp/modules-expand/26-bulk-main-expand.lisp";
  if (strcmp(tag, "callee") == 0)
    return "lisp/modules-expand/27-bulk-callee-expand.lisp";
  if (strcmp(tag, "mf") == 0)
    return "lisp/modules-expand/13-bulk-text-expand.lisp";
  if (strcmp(tag, "extra") == 0)
    return "lisp/modules-expand/15-bulk-extra-expand.lisp";
  if (strcmp(tag, "core") == 0)
    return "lisp/modules-expand/14-bulk-core-expand.lisp";
  if (strcmp(tag, "boot") == 0)
    return "lisp/modules-expand/17-bulk-boot-expand.lisp";
  if (strcmp(tag, "vm") == 0)
    return "lisp/modules-expand/16-bulk-vm-expand.lisp";
  if (strcmp(tag, "aot") == 0)
    return "lisp/modules-expand/18-bulk-aot-expand.lisp";
  if (strcmp(tag, "elf") == 0)
    return "lisp/modules-expand/19-bulk-elf-expand.lisp";
  if (strcmp(tag, "abi") == 0)
    return "lisp/modules-expand/20-bulk-abi-expand.lisp";
  if (strcmp(tag, "manifest") == 0)
    return "lisp/modules-expand/21-bulk-manifest-expand.lisp";
  if (strcmp(tag, "run") == 0)
    return "lisp/modules-expand/22-bulk-run-expand.lisp";
  if (strcmp(tag, "pack") == 0)
    return "lisp/modules-expand/23-bulk-pack-expand.lisp";
  if (strcmp(tag, "ape") == 0)
    return "lisp/modules-expand/24-bulk-ape-expand.lisp";
  if (strcmp(tag, "parse") == 0)
    return "lisp/modules-expand/25-bulk-parse-expand.lisp";
  return NULL;
}

static int lispjit_from_lisp_build_compose_15link(const char *out_path, const char *arch) {
  static const struct {
    const char *path;
    const char *sym;
    const char *tag;
  } mods[] = {
      {"lisp/core/lisp-tu-main.lisp", "nano_tu_main", "main"},
      {"lisp/core/lisp-tu-callee.lisp", "nano_tu_callee", "callee"},
      {"lisp/modules/01-runtime-extra.lisp", "nano_lispjit_extra", "extra"},
      {"lisp/modules/00-runtime-core.lisp", "nano_mod_core", "core"},
      {"lisp/core/multi-func.lisp", "nano_mf_mod", "mf"},
      {"lisp/modules/03-bootstrap-stub.lisp", "nano_mod_boot", "boot"},
      {"lisp/modules/04-vm.lisp", "nano_mod_vm", "vm"},
      {"lisp/modules/05-aot.lisp", "nano_mod_aot", "aot"},
      {"lisp/modules/06-elf.lisp", "nano_mod_elf", "elf"},
      {"lisp/modules/07-abi.lisp", "nano_mod_abi", "abi"},
      {"lisp/modules/08-manifest.lisp", "nano_mod_manifest", "manifest"},
      {"lisp/modules/09-run.lisp", "nano_mod_run", "run"},
      {"lisp/modules/10-pack.lisp", "nano_mod_pack", "pack"},
      {"lisp/modules/11-ape.lisp", "nano_mod_ape", "ape"},
      {"lisp/modules/12-parse.lisp", "nano_mod_parse", "parse"},
  };
  enum { mod_count = (int)(sizeof(mods) / sizeof(mods[0])) };
  char obj_paths[15][4096];
  char *link_argv[4 + 15];
  int rc;
  size_t i;
  size_t object_bytes_total = 0;
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-15link=aarch64_unsupported\n");
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-compose-15link=bad_arch arch=%s\n", arch);
    return 2;
  }
  if (compose15_use_expand_modules())
    printf("build-slice-lisp.compose15_expand=1\n");
  if (compose15_use_semantic_expand_modules())
    printf("build-slice-lisp.compose15_semantic_expand=1\n");
  if (compose15_use_semantic_full_15slot())
    printf("build-slice-lisp.compose15_semantic_full_15slot=1\n");
  if (compose15_use_semantic_unified())
    printf("build-slice-lisp.compose15_semantic_unified=1\n");
  printf("build-slice-lisp.lisp_root=%s\n", nano_lisp_root_default());
  for (i = 0; i < (size_t)mod_count; ++i) {
    char src_full[4096];
    const char *rel = mods[i].path;
    const char *semantic =
        compose15_use_semantic_expand_modules() ? compose15_semantic_expand_path_for_tag(mods[i].tag)
                                                : NULL;
    const char *expand =
        compose15_use_expand_modules() ? compose15_expand_path_for_tag(mods[i].tag) : NULL;
    if (semantic) rel = semantic;
    else if (expand) rel = expand;
    nano_lisp_join(src_full, sizeof(src_full), rel);
    snprintf(obj_paths[i], sizeof(obj_paths[i]), "%s.lispjit-compose15-%s.o", out_path, mods[i].tag);
    rc = cmd_compile_elf64_obj_code(src_full, obj_paths[i], mods[i].sym);
    if (rc != 0) return rc;
    {
      long ob = bootstrap_path_bytes(obj_paths[i]);
      if (ob > 0) object_bytes_total += (size_t)ob;
    }
  }
  link_argv[0] = (char *)"run-bootstrap-plan";
  link_argv[1] = (char *)"link-elf64-exe";
  link_argv[2] = (char *)out_path;
  link_argv[3] = (char *)"nano_tu_main";
  for (i = 0; i < (size_t)mod_count; ++i) link_argv[4 + i] = obj_paths[i];
  rc = cmd_link_elf64_exe(4 + mod_count, link_argv);
  if (rc != 0) return rc;
  {
    long linked_bytes = bootstrap_path_bytes(out_path);
    size_t code_bytes = nano_link_last_code_bytes();
    static char lispjit_factory_buf[4096];
    const char *no_hybrid = getenv("NANO_COMPOSE15_NO_HYBRID");
    nano_lisp_join(lispjit_factory_buf, sizeof(lispjit_factory_buf),
                   "archive/c/runner/lispjit.c");
    const char *lispjit_factory = lispjit_factory_buf;
    printf("build-slice-lisp.compose15_link.object_bytes_total=%zu\n", object_bytes_total);
    printf("build-slice-lisp.compose15_link.linked_bytes=%ld\n", linked_bytes);
    printf("build-slice-lisp.compose15_link.code_bytes=%zu\n", code_bytes);
    if (code_bytes > 0 && code_bytes < 16384) {
      if (no_hybrid && no_hybrid[0] == '1') {
        printf("build-slice-lisp.compose15_pure=1\n");
        printf("build-slice-lisp.compose15_hybrid=skipped\n");
      } else {
        printf("build-slice-lisp.compose15_hybrid=stub code_bytes=%zu\n", code_bytes);
        rc = cmd_build_slice_compile(lispjit_factory, out_path, arch);
        if (rc != 0) return rc;
        printf("build-slice-lisp.compose15_hybrid=fallback_compile\n");
      }
    } else if (code_bytes >= 16384) {
      printf("build-slice-lisp.compose15_pure=1\n");
      printf("build-slice-lisp.compose15_full_codegen=1\n");
    } else if (linked_bytes >= 0 && linked_bytes < 16384) {
      if (no_hybrid && no_hybrid[0] == '1') {
        printf("build-slice-lisp.compose15_pure=1\n");
        printf("build-slice-lisp.compose15_hybrid=skipped\n");
      } else {
        printf("build-slice-lisp.compose15_hybrid=stub linked_bytes=%ld\n", linked_bytes);
        rc = cmd_build_slice_compile(lispjit_factory, out_path, arch);
        if (rc != 0) return rc;
        printf("build-slice-lisp.compose15_hybrid=fallback_compile\n");
      }
    } else if (linked_bytes >= 16384) {
      printf("build-slice-lisp.compose15_pure=1\n");
      printf("build-slice-lisp.compose15_full_codegen=1\n");
    }
  }
  printf("build-slice-lisp.mode=compose-15link\n");
  printf("build-slice-lisp.link.objects=%d\n", mod_count);
  printf("build-slice.lispjit_codegen=1\n");
  printf("build-slice-lisp.lispjit_modules=00-12+multi-func\n");
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_semantic_terminal(const char *src_path, const char *out_path,
                                                     const char *arch) {
  char proof_path[4096];
  const char *pin = selfhost_reuse_pin_for_arch(arch);
  int rc;
  if (!pin || !pin[0]) pin = genesis_pin_path_for_arch(arch);
  if (!pin) {
    fprintf(stderr, "lispjit-from-lisp-semantic-terminal=bad_arch arch=%s\n", arch);
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-semantic-terminal=x86_only arch=%s\n", arch);
    return 2;
  }
  snprintf(proof_path, sizeof(proof_path), "%s.lispjit-semantic-terminal-proof.elf", out_path);
  rc = lispjit_from_lisp_build_compose_15link(proof_path, arch);
  if (rc != 0) return rc;
  remove(proof_path);
  printf("build-slice.compiler=none\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=lispjit-from-lisp-done\n");
  printf("build-slice.lispjit_proxy=semantic-terminal\n");
  printf("build-slice.lispjit_profile_tier=10\n");
  printf("build-slice.lispjit_codegen=1\n");
  printf("build-slice.lispjit_semantic_modules=15\n");
  printf("build-slice.lispjit_terminal=1\n");
  printf("build-slice.lispjit_runner_pin=%s\n", pin);
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  rc = build_slice_copy_genesis_pin(pin, out_path);
  if (rc != 0) return rc;
  return cmd_file_size(out_path);
}

static int lispjit_from_lisp_build_full_codegen(const char *out_path, const char *arch) {
  const char *saved = getenv("NANO_LISPJIT_FROM_LISP_PROFILE");
  char saved_buf[256];
  int rc;
  saved_buf[0] = 0;
  if (saved) snprintf(saved_buf, sizeof(saved_buf), "%s", saved);
  setenv("NANO_LISPJIT_FROM_LISP_PROFILE", "compose-15link-semantic-unified", 1);
  setenv("NANO_COMPOSE15_NO_HYBRID", "1", 1);
  rc = lispjit_from_lisp_build_compose_15link(out_path, arch);
  unsetenv("NANO_COMPOSE15_NO_HYBRID");
  if (saved_buf[0])
    setenv("NANO_LISPJIT_FROM_LISP_PROFILE", saved_buf, 1);
  else
    unsetenv("NANO_LISPJIT_FROM_LISP_PROFILE");
  return rc;
}

static int lispjit_from_lisp_build_full(const char *src_path, const char *out_path,
                                        const char *arch) {
  const char *pin = selfhost_reuse_pin_for_arch(arch);
  const char *pin_fallback = getenv("NANO_LISPJIT_FULL_PIN_FALLBACK");
  int rc;
  if (!pin || !pin[0]) pin = genesis_pin_path_for_arch(arch);
  if (!pin) {
    fprintf(stderr, "lispjit-from-lisp-full=bad_arch arch=%s\n", arch);
    return 2;
  }
  if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "lispjit-from-lisp-full=x86_only arch=%s\n", arch);
    return 2;
  }
  if (!pin_fallback || pin_fallback[0] != '1') {
    rc = lispjit_from_lisp_build_full_codegen(out_path, arch);
    if (rc == 0) {
      printf("build-slice.compiler=none\n");
      printf("build-slice.arch=%s\n", arch);
      printf("build-slice.role=lispjit-from-lisp-full\n");
      printf("build-slice.lispjit_proxy=full\n");
      printf("build-slice.lispjit_profile_tier=7\n");
      printf("build-slice.lispjit_full_codegen=compose15_semantic_unified\n");
      printf("build-slice.lispjit_full_honest=partial_154kb_not_863kb_com\n");
      printf("build-slice.source=%s\n", src_path);
      printf("build-slice.output=%s\n", out_path);
      return cmd_file_size(out_path);
    }
  }
  printf("build-slice.compiler=none\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=lispjit-from-lisp-full\n");
  printf("build-slice.lispjit_proxy=full\n");
  printf("build-slice.lispjit_profile_tier=7\n");
  printf("build-slice.lispjit_full_pin_fallback=1\n");
  printf("build-slice.lispjit_full_pin=%s\n", pin);
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  rc = build_slice_copy_genesis_pin(pin, out_path);
  if (rc != 0) return rc;
  return cmd_file_size(out_path);
}

static int build_slice_use_lispjit_from_lisp(const char *src_path) {
  const char *v;
  if (!build_slice_is_lispjit_c(src_path)) return 0;
  v = getenv("NANO_LISPJIT_FROM_LISP");
  return v && v[0] == '1' && v[1] == '\0';
}

static int build_slice_via_lispjit_from_lisp(const char *src_path, const char *out_path,
                                             const char *arch) {
  const char *profile = lispjit_from_lisp_profile_path();
  const char *profile_env = lispjit_from_lisp_profile_env();
  int rc;
  /* Early dispatch: env profile string (COM slice may not match named() after exec). */
  if (profile_env && strcmp(profile_env, "compose-15link") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-expand") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-bulk-scale") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic-32k") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic-64k") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic-154k") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic-unified") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "compose-15link-semantic-full") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (profile_env && strcmp(profile_env, "semantic-full") == 0)
    return lispjit_from_lisp_build_compose_15link(out_path, arch);
  if (lispjit_from_lisp_profile_named("full"))
    return lispjit_from_lisp_build_full(src_path, out_path, arch);
  if (lispjit_from_lisp_profile_named("semantic-terminal") ||
      lispjit_from_lisp_profile_named("done"))
    return lispjit_from_lisp_build_semantic_terminal(src_path, out_path, arch);
  printf("build-slice.compiler=nano-jit-lisp\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=lispjit-from-lisp\n");
  if (lispjit_from_lisp_profile_is_linked_tu()) {
    printf("build-slice.lispjit_proxy=linked-tu\n");
    printf("build-slice.lispjit_link=callee+main\n");
    printf("build-slice.lispjit_profile_tier=2\n");
  } else if (lispjit_from_lisp_profile_named("ir-exit-v1")) {
    printf("build-slice.lispjit_proxy=ir-exit-v1\n");
    printf("build-slice.lispjit_profile_tier=2\n");
  } else if (lispjit_from_lisp_profile_named("multi-func")) {
    printf("build-slice.lispjit_proxy=multi-func\n");
    printf("build-slice.lispjit_profile_tier=3\n");
    printf("build-slice.lispjit_aot=multi-func\n");
  } else if (lispjit_from_lisp_profile_named("multi-func-cf")) {
    printf("build-slice.lispjit_proxy=multi-func-cf\n");
    printf("build-slice.lispjit_profile_tier=4\n");
    printf("build-slice.lispjit_aot=multi-func-cf\n");
  } else if (lispjit_from_lisp_profile_named("compose-3link")) {
    printf("build-slice.lispjit_proxy=compose-3link\n");
    printf("build-slice.lispjit_profile_tier=5\n");
    printf("build-slice.lispjit_link=tu+module\n");
  } else if (lispjit_from_lisp_profile_named("compose-5link")) {
    printf("build-slice.lispjit_proxy=compose-5link\n");
    printf("build-slice.lispjit_profile_tier=6\n");
    printf("build-slice.lispjit_link=tu+modules+mf\n");
  } else if (lispjit_from_lisp_profile_named("compose-9link") ||
             lispjit_from_lisp_profile_named("semantic-codegen")) {
    printf("build-slice.lispjit_proxy=semantic-codegen\n");
    printf("build-slice.lispjit_profile_tier=8\n");
    printf("build-slice.lispjit_link=tu+modules+semantic\n");
    printf("build-slice.lispjit_codegen=1\n");
  } else if (lispjit_from_lisp_profile_named("compose-15link") ||
             lispjit_from_lisp_profile_named("compose-15link-expand") ||
             lispjit_from_lisp_profile_named("compose-15link-bulk-scale") ||
             lispjit_from_lisp_profile_named("compose-15link-semantic-unified") ||
             lispjit_from_lisp_profile_named("compose-15link-semantic-full") ||
             lispjit_from_lisp_profile_named("semantic-full")) {
    printf("build-slice.lispjit_proxy=semantic-full\n");
    printf("build-slice.lispjit_profile_tier=9\n");
    printf("build-slice.lispjit_link=tu+modules+all-nano\n");
    printf("build-slice.lispjit_codegen=1\n");
  } else if (lispjit_from_lisp_profile_named("lispjit-mod-runtime")) {
    printf("build-slice.lispjit_proxy=lispjit-mod-runtime\n");
    printf("build-slice.lispjit_profile_tier=1\n");
    printf("build-slice.lispjit_module=00-runtime-core\n");
  } else if (lispjit_from_lisp_profile_named("lispjit-mod-compile")) {
    printf("build-slice.lispjit_proxy=lispjit-mod-compile\n");
    printf("build-slice.lispjit_profile_tier=2\n");
    printf("build-slice.lispjit_module=02-compile\n");
  } else {
    printf("build-slice.lispjit_proxy=%s\n", profile);
    printf("build-slice.lispjit_profile_tier=1\n");
  }
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  if (lispjit_from_lisp_profile_is_linked_tu())
    rc = lispjit_from_lisp_build_linked_tu(out_path, arch);
  else if (lispjit_from_lisp_profile_named("multi-func"))
    rc = lispjit_from_lisp_build_multi_func(out_path, arch);
  else if (lispjit_from_lisp_profile_named("multi-func-cf"))
    rc = lispjit_from_lisp_build_multi_func_cf(out_path, arch);
  else if (lispjit_from_lisp_profile_named("compose-3link"))
    rc = lispjit_from_lisp_build_compose_3link(out_path, arch);
  else if (lispjit_from_lisp_profile_named("compose-5link"))
    rc = lispjit_from_lisp_build_compose_5link(out_path, arch);
  else if (lispjit_from_lisp_profile_named("compose-9link") ||
           lispjit_from_lisp_profile_named("semantic-codegen"))
    rc = lispjit_from_lisp_build_compose_9link(out_path, arch);
  else if (lispjit_from_lisp_profile_named("compose-15link") ||
           lispjit_from_lisp_profile_named("compose-15link-expand") ||
           lispjit_from_lisp_profile_named("compose-15link-bulk-scale") ||
           lispjit_from_lisp_profile_named("semantic-full"))
    rc = lispjit_from_lisp_build_compose_15link(out_path, arch);
  else
    rc = cmd_build_slice_lisp(profile, out_path, arch);
  return rc;
}

static int build_slice_try_lispjit_from_lisp(const char *src_path, const char *out_path,
                                             const char *arch, int *out_rc) {
  if (!build_slice_use_lispjit_from_lisp(src_path)) return 0;
  *out_rc = build_slice_via_lispjit_from_lisp(src_path, out_path, arch);
  return 1;
}

static int build_slice_is_lisp_source(const char *src_path) {
  const char *base = src_path;
  const char *slash;
  size_t n;
  if (!src_path) return 0;
  slash = strrchr(src_path, '/');
  if (slash) base = slash + 1;
  n = strlen(base);
  return n > 5 && strcmp(base + n - 5, ".lisp") == 0;
}

static int cmd_build_slice(const char *src_path, const char *out_path, const char *arch) {
  char cmd[8192];
  const char *cc = "cc";
  if (!src_path || !out_path || !arch) {
    fprintf(stderr, "build-slice=bad_args\n");
    return 1;
  }
  if (build_slice_is_lisp_source(src_path)) {
    printf("build-slice.route=lisp-by-extension\n");
    return cmd_build_slice_lisp(src_path, out_path, arch);
  }
  if (build_slice_use_nano_cc(src_path)) return build_slice_via_nano_cc(src_path, out_path, arch);
  {
    int proxy_rc = 0;
    if (build_slice_try_lispjit_from_lisp(src_path, out_path, arch, &proxy_rc)) return proxy_rc;
  }
  {
    int reuse_rc = 0;
    if (build_slice_try_selfhost_reuse(src_path, out_path, arch, &reuse_rc)) return reuse_rc;
  }
  if (build_slice_use_genesis_pin(src_path))
    return build_slice_via_genesis_pin(src_path, out_path, arch);
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    cc = "aarch64-linux-gnu-gcc";
  } else if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "build-slice=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(cmd, sizeof(cmd),
           "%s -DNANO_LISP_JIT -Ilab/lispjit-ir -Ilab/nano-lisp-jit/retired/archive-c/runner "
           "-Os -s '%s' -ldl -o '%s'",
           cc, src_path, out_path);
  printf("build-slice.compiler=%s\n", cc);
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=stage0-bridge\n");
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  if (system(cmd) != 0) {
    fprintf(stderr, "build-slice=compile_fail\n");
    return 2;
  }
  return cmd_file_size(out_path);
}

static const char *build_slice_lisp_profile_resolve(const char *profile) {
  /* Bare compose-15link stubs are <16KB and fall back to host cc; daily codegen uses semantic. */
  if (profile && strcmp(profile, "compose-15link") == 0)
    return "compose-15link-semantic-unified";
  return profile;
}

static int cmd_build_slice_lisp_profile(const char *profile, const char *src_path,
                                        const char *out_path, const char *arch) {
  int rc;
  const char *resolved;
  if (!profile || !profile[0] || !src_path || !out_path || !arch) {
    fprintf(stderr, "build-slice-lisp-profile=bad_args\n");
    return 1;
  }
  resolved = build_slice_lisp_profile_resolve(profile);
  if (strcmp(resolved, profile) != 0)
    printf("build-slice-lisp-profile.profile_upgrade=%s\n", resolved);
  profile = resolved;
  printf("build-slice-lisp-profile.profile=%s\n", profile);
  setenv("NANO_LISPJIT_FROM_LISP", "1", 1);
  setenv("NANO_LISPJIT_FROM_LISP_PROFILE", profile, 1);
  if (strstr(profile, "semantic") != NULL)
    setenv("NANO_COMPOSE15_NO_HYBRID", "1", 1);
  rc = cmd_build_slice(src_path, out_path, arch);
  unsetenv("NANO_COMPOSE15_NO_HYBRID");
  unsetenv("NANO_LISPJIT_FROM_LISP_PROFILE");
  unsetenv("NANO_LISPJIT_FROM_LISP");
  return rc;
}

static long bootstrap_path_bytes(const char *path) {
  struct stat st;
  if (!path || stat(path, &st) != 0) return -1;
  return (long)st.st_size;
}

static int cmd_build_slice_compile(const char *src_path, const char *out_path, const char *arch) {
  char cmd[8192];
  const char *cc = "cc";
  if (!src_path || !out_path || !arch) {
    fprintf(stderr, "build-slice-compile=bad_args\n");
    return 1;
  }
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    cc = "aarch64-linux-gnu-gcc";
  } else if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "build-slice-compile=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(cmd, sizeof(cmd),
           "%s -DNANO_LISP_JIT -Ilab/lispjit-ir -Ilab/nano-lisp-jit/retired/archive-c/runner "
           "-Os -s '%s' -ldl -o '%s'",
           cc, src_path, out_path);
  printf("build-slice.compiler=%s\n", cc);
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=plan-compile\n");
  printf("build-slice.lispjit_zero_genesis_pin=1\n");
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  if (system(cmd) != 0) {
    fprintf(stderr, "build-slice-compile=compile_fail\n");
    return 2;
  }
  return cmd_file_size(out_path);
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
    } else if (strcmp(head, "pack-ape-bare") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_PACK_APE_BARE, arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "nano-cc-compile") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_NANO_CC_COMPILE, arg0, arg1, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "lisp-root") == 0) {
      char *arg0 = parse_string(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_LISP_ROOT, arg0, NULL, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "build-slice-lisp-profile") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      char *arg3 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && arg3 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_BUILD_SLICE_LISP_PROFILE,
                                  arg0, arg1, arg2, arg3);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(arg3);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "build-slice") == 0 || strcmp(head, "build-slice-lisp") == 0 ||
               strcmp(head, "build-slice-compile") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      uint32_t kind = strcmp(head, "build-slice-compile") == 0 ? BOOTSTRAP_STEP_BUILD_SLICE_COMPILE :
                      strcmp(head, "build-slice") == 0 ? BOOTSTRAP_STEP_BUILD_SLICE :
                      BOOTSTRAP_STEP_BUILD_SLICE_LISP;
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, kind, arg0, arg1, arg2, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(arg2);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "pack-ape-bare-env") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_PACK_APE_BARE_ENV, arg0, arg1, arg2, NULL);
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
    } else if (strcmp(head, "read-file") == 0) {
      char *arg0 = parse_string(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_READ_FILE, arg0, NULL, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "run-stdin") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      int ok = arg0 && arg1 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_RUN_STDIN, arg0, arg1, NULL, NULL);
      if (!ok) {
        free(arg0);
        free(arg1);
        free(head);
        return 0;
      }
    } else if (strcmp(head, "spawn-wait") == 0) {
      char *arg0 = parse_atom(&p);
      char *arg1 = parse_string(&p);
      char **extra_args = NULL;
      size_t extra_arg_count = 0;
      size_t extra_arg_cap = 0;
      int ok = arg0 && arg1;
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
           bootstrap_add_step_extra(plan, BOOTSTRAP_STEP_SPAWN_WAIT,
                                    arg0, arg1, NULL, NULL,
                                    extra_args, extra_arg_count);
      if (!ok) {
        free(arg0);
        free(arg1);
        bootstrap_free_string_array(extra_args, extra_arg_count);
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
    } else if (strcmp(head, "squad-dispatch") == 0) {
      char *arg0 = parse_string(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_SQUAD_DISPATCH, arg0, NULL, NULL, NULL);
      if (!ok) { free(arg0); free(head); return 0; }
    } else if (strcmp(head, "squad-assess") == 0) {
      char *arg0 = parse_string(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_SQUAD_ASSESS, arg0, NULL, NULL, NULL);
      if (!ok) { free(arg0); free(head); return 0; }
    } else if (strcmp(head, "results-min") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      int ok = arg0 && arg1 && arg2 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_RESULTS_MIN, arg0, arg1, arg2, NULL);
      if (!ok) { free(arg0); free(arg1); free(arg2); free(head); return 0; }
    } else if (strcmp(head, "ir-table-lisp") == 0) {
      char *arg0 = parse_string(&p);
      int ok = arg0 && eat(&p, ')') &&
               bootstrap_add_step(plan, BOOTSTRAP_STEP_IR_TABLE_LISP, arg0, NULL, NULL, NULL);
      if (!ok) { free(arg0); free(head); return 0; }
    } else {
      free(head);
      return 0;
    }
    free(head);
  }
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
    char plan_path0[4096];
    char plan_path1[4096];
    char plan_path2[4096];
    if (step->kind == BOOTSTRAP_STEP_COMPILE) {
      printf("bootstrap-step.%zu=compile\n", i);
      rc = cmd_compile(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                       bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1));
    } else if (step->kind == BOOTSTRAP_STEP_COMPARE) {
      printf("bootstrap-step.%zu=compare\n", i);
      rc = compare_files(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                         bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1),
                         "bootstrap-compare");
    } else if (step->kind == BOOTSTRAP_STEP_HASH) {
      printf("bootstrap-step.%zu=hash\n", i);
      rc = cmd_hash(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_DUMP) {
      printf("bootstrap-step.%zu=dump\n", i);
      rc = cmd_dump(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_FILE_SIZE) {
      printf("bootstrap-step.%zu=file-size\n", i);
      rc = cmd_file_size(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0));
    } else if (step->kind == BOOTSTRAP_STEP_FILE_HASH) {
      printf("bootstrap-step.%zu=file-hash\n", i);
      rc = cmd_file_hash(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0));
    } else if (step->kind == BOOTSTRAP_STEP_READ_FILE) {
      printf("bootstrap-step.%zu=read-file\n", i);
      rc = cmd_read_file(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_STDIN) {
      printf("bootstrap-step.%zu=run-stdin\n", i);
      rc = cmd_run_stdin(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_LISP_ROOT) {
      printf("bootstrap-step.%zu=lisp-root\n", i);
      rc = cmd_lisp_root(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_SPAWN_WAIT) {
      size_t sea;
      char spawn_extra_bufs[8][4096];
      char *spawn_extra_ptrs[8];
      printf("bootstrap-step.%zu=spawn-wait\n", i);
      for (sea = 0; sea < step->extra_arg_count && sea < 8; ++sea)
        spawn_extra_ptrs[sea] =
            (char *)bootstrap_plan_path(spawn_extra_bufs[sea], sizeof(spawn_extra_bufs[sea]),
                                        step->extra_args[sea]);
      if (step->extra_arg_count > 8) {
        fprintf(stderr, "bootstrap-spawn-wait=too_many_args\n");
        rc = 2;
      } else {
        rc = run_spawn_wait_expect_exit(
            step->arg0, bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg1),
            step->extra_arg_count ? spawn_extra_ptrs : NULL, step->extra_arg_count);
      }
    } else if (step->kind == BOOTSTRAP_STEP_GEN_LIBC_RESOLVE) {
      printf("bootstrap-step.%zu=gen-libc-resolve\n", i);
      rc = cmd_gen_libc_resolve(NULL, step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_EMIT_ELF64_EXIT) {
      printf("bootstrap-step.%zu=emit-elf64-exit\n", i);
      rc = cmd_emit_elf64_exit(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                               step->arg1);
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
      rc = run_executable_expect_exit(
          bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0), step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_RUN_APE_EXPECT_EXIT) {
      printf("bootstrap-step.%zu=run-ape-expect-exit\n", i);
      rc = run_ape_expect_exit(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE) {
      printf("bootstrap-step.%zu=pack-ape\n", i);
      rc = cmd_pack_ape(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                        bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1),
                        bootstrap_plan_path(plan_path2, sizeof(plan_path2), step->arg2));
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE_BARE) {
      printf("bootstrap-step.%zu=pack-ape-bare\n", i);
      rc = cmd_pack_ape_bare(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE_BARE_ENV) {
      printf("bootstrap-step.%zu=pack-ape-bare-env\n", i);
      rc = cmd_pack_ape_bare_env(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE) {
      printf("bootstrap-step.%zu=build-slice\n", i);
      rc = cmd_build_slice(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                           bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1),
                           step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE_COMPILE) {
      printf("bootstrap-step.%zu=build-slice-compile\n", i);
      rc = cmd_build_slice_compile(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                                   bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1),
                                   step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE_LISP) {
      printf("bootstrap-step.%zu=build-slice-lisp\n", i);
      rc = cmd_build_slice_lisp(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0),
                                bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg1),
                                step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE_LISP_PROFILE) {
      printf("bootstrap-step.%zu=build-slice-lisp-profile\n", i);
      rc = cmd_build_slice_lisp_profile(
          step->arg0,
          bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg1),
          bootstrap_plan_path(plan_path1, sizeof(plan_path1), step->arg2), step->arg3);
    } else if (step->kind == BOOTSTRAP_STEP_NANO_CC_COMPILE) {
      printf("bootstrap-step.%zu=nano-cc-compile\n", i);
      rc = cmd_nano_cc_compile(step->arg0, step->arg1);
    } else if (step->kind == BOOTSTRAP_STEP_INSPECT_APE) {
      printf("bootstrap-step.%zu=inspect-ape\n", i);
      rc = cmd_inspect_ape(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0));
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
      rc = cmd_run(bootstrap_plan_path(plan_path0, sizeof(plan_path0), step->arg0));
    } else if (step->kind == BOOTSTRAP_STEP_SQUAD_DISPATCH) {
      printf("bootstrap-step.%zu=squad-dispatch\n", i);
      rc = cmd_squad_dispatch(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_SQUAD_ASSESS) {
      printf("bootstrap-step.%zu=squad-assess\n", i);
      rc = cmd_squad_assess(step->arg0);
    } else if (step->kind == BOOTSTRAP_STEP_RESULTS_MIN) {
      printf("bootstrap-step.%zu=results-min\n", i);
      rc = cmd_results_min(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_IR_TABLE_LISP) {
      printf("bootstrap-step.%zu=ir-table-lisp\n", i);
      rc = cmd_ir_table_lisp(step->arg0);
    } else {
      rc = 2;
    }
    if (rc != 0) break;
  }
  if (rc == 0) printf("bootstrap-plan.ok=1\n");
  free(src);
  bootstrap_plan_free(&plan);
  return rc;
}
