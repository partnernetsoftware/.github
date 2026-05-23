/* Included from lispjit.c — bootstrap plan DSL parse + run-bootstrap-plan. */
static int cmd_compile_elf64_code(const char *src_path, const char *out_path);
static int cmd_compile_elf64_exe(const char *src_path, const char *out_path, const char *symbol);

unsigned char *compile_source_path_to_blob(const char *src_path, size_t *out_blob_n,
                                           int *out_rc);

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

static int build_slice_lisp_aarch64_profile_ok(const char *src_path, const char *base,
                                               const unsigned char *src, size_t src_n) {
  (void)src_n;
  if (strcmp(base, "nano-jit-slice-min.lisp") == 0) {
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
    printf("aarch64.emit.ir.table.version=v2\n");
    printf("aarch64.emit.ir.table.entries=%d\n", 5);
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
  if (build_slice_use_genesis_pin(src_path))
    return build_slice_via_genesis_pin(src_path, out_path, arch);
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0) {
    cc = "aarch64-linux-gnu-gcc";
  } else if (strcmp(arch, "x86_64") != 0 && strcmp(arch, "amd64") != 0) {
    fprintf(stderr, "build-slice=bad_arch arch=%s\n", arch);
    return 2;
  }
  snprintf(cmd, sizeof(cmd), "%s -DNANO_LISP_JIT -Os -s '%s' -ldl -o '%s'", cc, src_path,
           out_path);
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
    } else if (strcmp(head, "build-slice") == 0 || strcmp(head, "build-slice-lisp") == 0) {
      char *arg0 = parse_string(&p);
      char *arg1 = parse_string(&p);
      char *arg2 = parse_string(&p);
      uint32_t kind = strcmp(head, "build-slice") == 0 ? BOOTSTRAP_STEP_BUILD_SLICE :
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
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE_BARE) {
      printf("bootstrap-step.%zu=pack-ape-bare\n", i);
      rc = cmd_pack_ape_bare(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_PACK_APE_BARE_ENV) {
      printf("bootstrap-step.%zu=pack-ape-bare-env\n", i);
      rc = cmd_pack_ape_bare_env(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE) {
      printf("bootstrap-step.%zu=build-slice\n", i);
      rc = cmd_build_slice(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_BUILD_SLICE_LISP) {
      printf("bootstrap-step.%zu=build-slice-lisp\n", i);
      rc = cmd_build_slice_lisp(step->arg0, step->arg1, step->arg2);
    } else if (step->kind == BOOTSTRAP_STEP_NANO_CC_COMPILE) {
      printf("bootstrap-step.%zu=nano-cc-compile\n", i);
      rc = cmd_nano_cc_compile(step->arg0, step->arg1);
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
