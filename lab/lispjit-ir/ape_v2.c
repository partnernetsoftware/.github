#include "ape_v2.h"

#include <stdio.h>
#include <string.h>

#if !defined(_WIN32)
#include <sys/utsname.h>
#include <unistd.h>
#endif

const unsigned char NANO_APE_V2_MAGIC[NANO_APE_V2_MAGIC_LEN] = {
    0x7f, 'N', 'A', 'N', 'O', 'a', 'p', 'e',
};

static uint32_t rd32le(const unsigned char *p) {
  return ((uint32_t)p[0]) | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
         ((uint32_t)p[3] << 24);
}

static uint64_t rd64le(const unsigned char *p) {
  return ((uint64_t)rd32le(p)) | ((uint64_t)rd32le(p + 4) << 32);
}

static uint16_t rd16le(const unsigned char *p) {
  return (uint16_t)(((uint16_t)p[0]) | ((uint16_t)p[1] << 8));
}

static void wr32le(unsigned char *p, uint32_t v) {
  p[0] = (unsigned char)(v & 0xff);
  p[1] = (unsigned char)((v >> 8) & 0xff);
  p[2] = (unsigned char)((v >> 16) & 0xff);
  p[3] = (unsigned char)((v >> 24) & 0xff);
}

static void wr64le(unsigned char *p, uint64_t v) {
  wr32le(p, (uint32_t)v);
  wr32le(p + 4, (uint32_t)(v >> 32));
}

static void wr16le(unsigned char *p, uint16_t v) {
  p[0] = (unsigned char)(v & 0xff);
  p[1] = (unsigned char)((v >> 8) & 0xff);
}

int nano_ape_v2_magic_at(const unsigned char *data, size_t n, size_t offset) {
  if (offset + NANO_APE_V2_MAGIC_LEN > n) return 0;
  return memcmp(data + offset, NANO_APE_V2_MAGIC, NANO_APE_V2_MAGIC_LEN) == 0;
}

size_t nano_ape_v2_header_bytes(uint16_t slice_count) {
  return (size_t)NANO_APE_V2_FIXED_HDR_BYTES + (size_t)slice_count * NANO_APE_V2_SLICE_ENTRY_BYTES;
}

int parse_nano_ape_v2_at_offset(const unsigned char *data, size_t n, size_t offset,
                                NanoApeV2Image *out) {
  if (!data || !out) return 1;
  memset(out, 0, sizeof(*out));
  if (!nano_ape_v2_magic_at(data, n, offset)) return 1;
  if (offset + NANO_APE_V2_FIXED_HDR_BYTES > n) return 1;

  uint32_t version = rd32le(data + offset + 8);
  uint16_t slice_count = rd16le(data + offset + 12);
  uint16_t header_bytes = rd16le(data + offset + 14);

  if (version != NANO_APE_V2_VERSION) return 1;
  if (slice_count == 0 || slice_count > NANO_APE_V2_MAX_SLICES) return 1;
  if (header_bytes != nano_ape_v2_header_bytes(slice_count)) return 1;
  if (offset + header_bytes > n) return 1;

  out->file_offset = offset;
  out->slice_count = slice_count;
  out->header_bytes = header_bytes;
  out->slice_count_u32 = slice_count;

  for (uint16_t i = 0; i < slice_count; ++i) {
    size_t row_off = offset + NANO_APE_V2_FIXED_HDR_BYTES + (size_t)i * NANO_APE_V2_SLICE_ENTRY_BYTES;
    NanoApeV2SliceRow *r = &out->slices[i];
    r->arch_id = data[row_off + 0];
    r->os_id = data[row_off + 1];
    r->reserved = rd16le(data + row_off + 2);
    r->offset = rd64le(data + row_off + 4);
    r->size = rd64le(data + row_off + 12);
    r->hash = rd64le(data + row_off + 20);
  }
  return 0;
}

static int known_arch_os(uint8_t arch_id, uint8_t os_id) {
  if (arch_id != NANO_APE_V2_ARCH_X86_64 && arch_id != NANO_APE_V2_ARCH_AARCH64) return 0;
  if (os_id != 0 && os_id != NANO_APE_V2_OS_LINUX) return 0;
  return 1;
}

int validate_nano_ape_v2_slices(const NanoApeV2Image *img, const unsigned char *data, size_t n,
                                size_t payload_base, int (*is_elf_fn)(const unsigned char *, size_t),
                                const char *error_prefix) {
  const char *prefix = error_prefix ? error_prefix : "inspect-ape";
  for (uint16_t i = 0; i < img->slice_count; ++i) {
    const NanoApeV2SliceRow *r = &img->slices[i];
    if (!known_arch_os(r->arch_id, r->os_id)) {
      fprintf(stderr, "%s=bad_slice_ids arch_id=%u os_id=%u\n", prefix, r->arch_id, r->os_id);
      return 4;
    }
    if (r->reserved != 0) {
      fprintf(stderr, "%s=bad_slice_reserved arch_id=%u\n", prefix, r->arch_id);
      return 4;
    }
    size_t abs_off = payload_base + (size_t)r->offset;
    if (r->offset > n - payload_base || r->size > n - abs_off) {
      fprintf(stderr, "%s=bad_offset arch_id=%u off=%llu size=%llu base=%zu file=%zu\n", prefix,
              r->arch_id, (unsigned long long)r->offset, (unsigned long long)r->size, payload_base,
              n);
      return 4;
    }
    if (!is_elf_fn || !is_elf_fn(data + abs_off, (size_t)r->size)) {
      fprintf(stderr, "%s=bad_slice_elf arch_id=%u\n", prefix, r->arch_id);
      return 4;
    }
  }
  return 0;
}

int validate_nano_ape_v2_hashes(const NanoApeV2Image *img, const unsigned char *data, size_t n,
                                size_t payload_base,
                                uint64_t (*fnv1a64_fn)(const unsigned char *, size_t),
                                const char *error_prefix) {
  const char *prefix = error_prefix ? error_prefix : "inspect-ape";
  if (!fnv1a64_fn) return 0;
  for (uint16_t i = 0; i < img->slice_count; ++i) {
    const NanoApeV2SliceRow *r = &img->slices[i];
    if (r->hash == 0) continue;
    size_t abs_off = payload_base + (size_t)r->offset;
    if (r->size > n - abs_off) return 4;
    uint64_t actual = fnv1a64_fn(data + abs_off, (size_t)r->size);
    if (actual != r->hash) {
      fprintf(stderr, "%s=bad_hash arch_id=%u expected=%016llx actual=%016llx\n", prefix,
              r->arch_id, (unsigned long long)r->hash, (unsigned long long)actual);
      return 5;
    }
  }
  return 0;
}

int validate_nano_ape_v2(const unsigned char *data, size_t n, size_t payload_start,
                         NanoApeV2Image *out, int (*is_elf_fn)(const unsigned char *, size_t),
                         uint64_t (*fnv1a64_fn)(const unsigned char *, size_t),
                         const char *error_prefix) {
  const char *prefix = error_prefix ? error_prefix : "inspect-ape";
  if (!nano_ape_v2_magic_at(data, n, payload_start)) {
    fprintf(stderr, "%s=bad_magic\n", prefix);
    return 3;
  }
  if (parse_nano_ape_v2_at_offset(data, n, payload_start, out) != 0) {
    fprintf(stderr, "%s=bad_header\n", prefix);
    return 3;
  }
  size_t payload_base = payload_start + out->header_bytes;
  if (payload_base > n) {
    fprintf(stderr, "%s=truncated_header\n", prefix);
    return 2;
  }
  int rc = validate_nano_ape_v2_slices(out, data, n, payload_base, is_elf_fn, prefix);
  if (rc != 0) return rc;
  return validate_nano_ape_v2_hashes(out, data, n, payload_base, fnv1a64_fn, prefix);
}

int nano_ape_v2_slice_for_arch(const NanoApeV2Image *img, const char *force_arch,
                               const NanoApeV2SliceRow **row, const char **arch_name) {
  uint8_t want_arch = 0;
  if (force_arch && force_arch[0]) {
    if (strcmp(force_arch, "x86_64") == 0) want_arch = NANO_APE_V2_ARCH_X86_64;
    else if (strcmp(force_arch, "aarch64") == 0) want_arch = NANO_APE_V2_ARCH_AARCH64;
    else {
      fprintf(stderr, "run-ape=bad_arch value=%s\n", force_arch);
      return 127;
    }
  }
#if !defined(_WIN32)
  if (!want_arch) {
    struct utsname ut;
    if (uname(&ut) != 0) return 126;
    if (strcmp(ut.machine, "x86_64") == 0 || strcmp(ut.machine, "amd64") == 0)
      want_arch = NANO_APE_V2_ARCH_X86_64;
    else if (strcmp(ut.machine, "aarch64") == 0 || strcmp(ut.machine, "arm64") == 0)
      want_arch = NANO_APE_V2_ARCH_AARCH64;
    else {
      fprintf(stderr, "run-ape=unsupported_arch machine=%s\n", ut.machine);
      return 126;
    }
  }
#else
  if (!want_arch) return 126;
#endif
  for (uint16_t i = 0; i < img->slice_count; ++i) {
    if (img->slices[i].arch_id == want_arch) {
      *row = &img->slices[i];
      *arch_name = want_arch == NANO_APE_V2_ARCH_X86_64 ? "x86_64" : "aarch64";
      return 0;
    }
  }
  fprintf(stderr, "run-ape=slice_missing arch_id=%u\n", want_arch);
  return 4;
}

ssize_t emit_nano_ape_v2_header(unsigned char *dst, size_t cap, uint16_t slice_count,
                                const NanoApeV2SliceRow *rows) {
  uint16_t hdr_bytes = (uint16_t)nano_ape_v2_header_bytes(slice_count);
  size_t need = hdr_bytes;
  if (need > cap) return -1;
  memcpy(dst, NANO_APE_V2_MAGIC, NANO_APE_V2_MAGIC_LEN);
  wr32le(dst + 8, NANO_APE_V2_VERSION);
  wr16le(dst + 12, slice_count);
  wr16le(dst + 14, hdr_bytes);
  for (uint16_t i = 0; i < slice_count; ++i) {
    unsigned char *row = dst + NANO_APE_V2_FIXED_HDR_BYTES + (size_t)i * NANO_APE_V2_SLICE_ENTRY_BYTES;
    const NanoApeV2SliceRow *r = &rows[i];
    row[0] = r->arch_id;
    row[1] = r->os_id;
    wr16le(row + 2, r->reserved);
    wr64le(row + 4, r->offset);
    wr64le(row + 12, r->size);
    wr64le(row + 20, r->hash);
  }
  return (ssize_t)need;
}
