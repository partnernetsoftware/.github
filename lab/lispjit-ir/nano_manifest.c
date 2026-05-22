/* Included from lispjit.c — comment manifest + payload markers. */
static const char NANO_MANIFEST_BEGIN[] = "# nano.manifest.begin";
static const char NANO_MANIFEST_END[] = "# nano.manifest.end";
static const char NANO_APE_PAYLOAD_MARKER[] = "__NANO_APE_PAYLOAD_BELOW__";
static const char NANO_APP_PAYLOAD_MARKER[] = "__NANO_APP_PAYLOAD_BELOW__";

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
static int manifest_find_size(const unsigned char *data, size_t n,
                              const char *key, size_t *out) {
  int in_manifest = 0;
  size_t pos = 0;
  size_t key_n = strlen(key);
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(NANO_MANIFEST_BEGIN) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_BEGIN, sizeof(NANO_MANIFEST_BEGIN) - 1) == 0) {
      in_manifest = 1;
      continue;
    }
    if (line_n == sizeof(NANO_MANIFEST_END) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_END, sizeof(NANO_MANIFEST_END) - 1) == 0) {
      return 0;
    }
    if (in_manifest && line_n > 2 + key_n && data[line_start] == '#' &&
        data[line_start + 1] == ' ' &&
        memcmp(data + line_start + 2, key, key_n) == 0 &&
        data[line_start + 2 + key_n] == '=') {
      char value_buf[32];
      size_t value_n = line_n - 3 - key_n;
      if (value_n >= sizeof(value_buf)) return 0;
      memcpy(value_buf, data + line_start + 3 + key_n, value_n);
      value_buf[value_n] = '\0';
      return parse_size_arg(value_buf, out);
    }
  }
  return 0;
}

static int manifest_find_string(const unsigned char *data, size_t n, const char *key,
                                char *out, size_t out_cap) {
  int in_manifest = 0;
  size_t pos = 0;
  size_t key_n = strlen(key);
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(NANO_MANIFEST_BEGIN) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_BEGIN, sizeof(NANO_MANIFEST_BEGIN) - 1) == 0) {
      in_manifest = 1;
      continue;
    }
    if (line_n == sizeof(NANO_MANIFEST_END) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_END, sizeof(NANO_MANIFEST_END) - 1) == 0) {
      return 0;
    }
    if (in_manifest && line_n > 2 + key_n && data[line_start] == '#' &&
        data[line_start + 1] == ' ' &&
        memcmp(data + line_start + 2, key, key_n) == 0 &&
        data[line_start + 2 + key_n] == '=') {
      size_t value_n = line_n - 3 - key_n;
      if (value_n + 1 > out_cap) return 0;
      memcpy(out, data + line_start + 3 + key_n, value_n);
      out[value_n] = '\0';
      return 1;
    }
  }
  return 0;
}

static int manifest_find_hash(const unsigned char *data, size_t n, const char *key,
                              uint64_t *out) {
  char value_buf[32];
  if (!manifest_find_string(data, n, key, value_buf, sizeof(value_buf))) return 0;
  char *end = NULL;
  unsigned long long v = strtoull(value_buf, &end, 16);
  if (!value_buf[0] || !end || *end) return 0;
  *out = (uint64_t)v;
  return 1;
}

static int is_elf(const unsigned char *data, size_t n) {
  return n >= 4 && data[0] == 0x7f && data[1] == 'E' && data[2] == 'L' && data[3] == 'F';
}
