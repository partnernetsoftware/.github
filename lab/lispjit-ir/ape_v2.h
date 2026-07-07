#ifndef NANO_APE_V2_H
#define NANO_APE_V2_H

#include <stddef.h>
#include <stdint.h>

/* 8-byte magic per lab/nano-lisp-jit/APE-v2.md */
#define NANO_APE_V2_MAGIC_LEN 8u
extern const unsigned char NANO_APE_V2_MAGIC[NANO_APE_V2_MAGIC_LEN];

#define NANO_APE_V2_VERSION 2u
#define NANO_APE_V2_FIXED_HDR_BYTES 16u
#define NANO_APE_V2_SLICE_ENTRY_BYTES 28u
#define NANO_APE_V2_MAX_SLICES 16u

#define NANO_APE_V2_ARCH_X86_64 1u
#define NANO_APE_V2_ARCH_AARCH64 2u
#define NANO_APE_V2_OS_LINUX 1u
#define NANO_APE_V2_OS_MACOS 2u   /* Wave102+ planned */
#define NANO_APE_V2_OS_WINDOWS 3u /* Wave102+ planned */

typedef struct {
  uint8_t arch_id;
  uint8_t os_id;
  uint16_t reserved;
  uint64_t offset;
  uint64_t size;
  uint64_t hash;
} NanoApeV2SliceRow;

typedef struct {
  size_t file_offset;
  uint16_t slice_count;
  uint16_t header_bytes;
  uint32_t slice_count_u32;
  NanoApeV2SliceRow slices[NANO_APE_V2_MAX_SLICES];
} NanoApeV2Image;

int nano_ape_v2_magic_at(const unsigned char *data, size_t n, size_t offset);

size_t nano_ape_v2_header_bytes(uint16_t slice_count);

int parse_nano_ape_v2_at_offset(const unsigned char *data, size_t n, size_t offset,
                                NanoApeV2Image *out);

int validate_nano_ape_v2_slices(const NanoApeV2Image *img, const unsigned char *data, size_t n,
                                size_t payload_base, int (*is_elf_fn)(const unsigned char *, size_t),
                                const char *error_prefix);

int validate_nano_ape_v2_hashes(const NanoApeV2Image *img, const unsigned char *data, size_t n,
                                size_t payload_base,
                                uint64_t (*fnv1a64_fn)(const unsigned char *, size_t),
                                const char *error_prefix);

int validate_nano_ape_v2(const unsigned char *data, size_t n, size_t payload_start,
                         NanoApeV2Image *out, int (*is_elf_fn)(const unsigned char *, size_t),
                         uint64_t (*fnv1a64_fn)(const unsigned char *, size_t),
                         const char *error_prefix);

int nano_ape_v2_slice_for_arch(const NanoApeV2Image *img, const char *force_arch,
                               const NanoApeV2SliceRow **row, const char **arch_name);

ssize_t emit_nano_ape_v2_header(unsigned char *dst, size_t cap, uint16_t slice_count,
                                const NanoApeV2SliceRow *rows);

#endif
