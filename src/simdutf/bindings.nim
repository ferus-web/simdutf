## Low-level bindings for simdutf functions.
## Copyright (C) 2024 Trayambak Rai and Ferus Authors
import std/[strutils]

# Tell the compiler how to properly link and compile against simdutf
{.passC: gorge("pkg-config --cflags simdutf").strip().}
{.passL: gorge("pkg-config --libs simdutf").strip().}

{.push header: "<simdutf.h>".}

type
  base64_options* {.importcpp: "simdutf::base64_options", pure.} = uint64 ## A base64 encoder option.
  error_code* {.importcpp: "simdutf::error_code", pure.} = uint64 ## An error code.

  simdutf_result* {.importcpp: "simdutf::result".} = object
    error*: error_code ## The error code.
    count*: uint64     ## In case of an error, this indicates the position of the erroroneous character. Upon success, this indicates the number of code units validated/written.

  encoding_type* {.importcpp: "simdutf::encoding_type".} = uint64 ## The kind of encoding used for a string.

  endianness* {.importcpp: "simdutf::endianness".} = uint64 ## Self explanatory

const
  base64_default*: base64_options = 0
  base64_url*: base64_options = 1
  base64_reverse_padding*: base64_options = 2
  base64_default_no_padding*: base64_options = base64_default or base64_reverse_padding
  base64_url_with_padding*: base64_options = base64_url or base64_reverse_padding

  error_success*: error_code = 0
  error_header_bits*: error_code = 1
  error_too_short*: error_code = 2
  error_too_long*: error_code = 3
  error_overlong*: error_code = 4
  error_too_large*: error_code = 5
  error_surrogate*: error_code = 6
  error_invalid_base64_character*: error_code = 7
  error_base64_input_remainder*: error_code = 8
  error_output_buffer_too_small*: error_code = 9
  error_other*: error_code = 10

  encoding_utf8*: encoding_type = 1
  encoding_utf16_le*: encoding_type = 2
  encoding_utf16_be*: encoding_type = 4
  encoding_utf32_le*: encoding_type = 8
  encoding_utf32_be*: encoding_type = 16
  encoding_latin1*: encoding_type = 32
  encoding_unspecified*: encoding_type = 0

  endianness_little*: endianness = 0
  endianness_big*: endianness = 1

proc binaryToBase64*(
  input: cstring,
  length: cuint,
  output: pointer,
  options: base64_options = base64_default
): cuint {.importcpp: "simdutf::binary_to_base64(@)".}

proc base64ToBinary*(
  input: cstring,
  length: cuint,
  output: pointer,
  options: base64_options = base64_default
): simdutf_result {.importcpp: "simdutf::base64_to_binary(@)".}

proc maximalBinaryLengthFromBase64*(
  input: cstring, length: cuint
): cuint {.importcpp: "simdutf::maximal_binary_length_from_base64(@)".}

proc base64LengthFromBinary*(
  length: cuint, options: base64_options = base64_default
): cuint {.importcpp: "simdutf::base64_length_from_binary(@)".}

proc autodetectEncoding*(
  input: cstring, length: cuint
): encoding_type {.importcpp: "simdutf::autodetect_encoding(@)".}

proc validateUtf8*(
  input: cstring, length: cuint
): bool {.importcpp: "simdutf::validate_utf8(@)".}

proc validateUtf8WithErrors*(
  input: cstring, length: cuint
): simdutf_result {.importcpp: "simdutf::validate_utf8_with_errors(@)".}

proc validateAscii*(
  input: cstring, length: cuint
): bool {.importcpp: "simdutf::validate_ascii(@)".}

proc validateAsciiWithErrors*(
  input: cstring, length: cuint
): simdutf_result {.importcpp: "simdutf::validate_ascii_with_errors(@)".}

{.pop.}
