/* Included from lispjit.c — source path to lbin/ljir blob, compile CLI. */

int infer_vm_module(const Module *m);

unsigned char *compile_source_path_to_blob(const char *src_path, size_t *out_blob_n,
                                                  int *out_rc) {
  size_t src_n = 0;
  unsigned char *src = read_file(src_path, &src_n);
  *out_rc = 3;
  if (!src) {
    fprintf(stderr, "read=fail path=%s\n", src_path);
    *out_rc = 1;
    return NULL;
  }
  Module m = {0};
  if (!parse_module((const char *)src, &m)) {
    fprintf(stderr, "parse=fail path=%s\n", src_path);
    free(src);
    module_free(&m);
    *out_rc = 1;
    return NULL;
  }
  if (!infer_vm_module(&m)) {
    free(src);
    module_free(&m);
    *out_rc = 2;
    return NULL;
  }
  unsigned char *blob = compile_module(&m, out_blob_n);
  free(src);
  module_free(&m);
  if (!blob) {
    fprintf(stderr, "compile=fail\n");
    *out_rc = 2;
    return NULL;
  }
  *out_rc = 0;
  return blob;
}

static int cmd_compile(const char *src_path, const char *out_path) {
  size_t blob_n = 0;
  int rc = 3;
  unsigned char *blob = compile_source_path_to_blob(src_path, &blob_n, &rc);
  if (!blob) {
    return rc;
  }
  if (!write_file(out_path, blob, blob_n)) {
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
