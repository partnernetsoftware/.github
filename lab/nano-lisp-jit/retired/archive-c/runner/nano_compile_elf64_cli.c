/* Included from lispjit.c after nano_aot_x86.c — source-path compile-elf64-* CLI. */

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
