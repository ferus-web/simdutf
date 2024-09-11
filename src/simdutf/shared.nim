## Shared code between the base64 encoder and the UTF-8 validator.
## Copyright (C) 2024 Trayambak Rai and Ferus Authors
import std/strutils
import simdutf/bindings

type
  SimdutfError* = enum
    Success    ## The call was successful
    HeaderBits ## Any byte must have fewer than 5 header bits.
    TooShort   ## The leading byte must be followed by N-1 continuation bytes, where N is the UTF-8 character length
               ## This is also the error when the input is truncated.
    TooLong    ## We either have too many consecutive continuation bytes or the string starts with a continuation byte.
    OverLong   ## The decoded character must be above U+7F for two-byte characters, U+7FF for three-byte characters,
               ## and U+FFFF for four-byte characters.
    TooLarge   ## The decoded character must be less than or equal to U+10FFFF,less than or equal than U+7F for ASCII OR less than equal than U+FF for Latin1
               ## The decoded character must be not be in U+D800...DFFF (UTF-8 or UTF-32) OR
               ## a high surrogate must be followed by a low surrogate and a low surrogate must be preceded by a high surrogate (UTF-16) OR
               ## there must be no surrogate at all (Latin1)
    InvalidBase64Character ## Found a character that cannot be part of a valid base64 string.
    BaseInputRemainder ## The base64 input terminates with a single character, excluding padding (=).
    OutputBufferTooSmall ## The provided buffer is too small.
    Other ## Not related to validation/transcoding.

  SimdutfResult* = object
    error*: SimdutfError
    count*: uint

func simdutfResult*(res: simdutf_result): SimdutfResult {.inline.} =
  ## Convert a low-level `simdutf_result` to a high level `SimdutfResult`
  var native: SimdutfResult

  native.error = case res.error
  of error_success: Success
  of error_header_bits: HeaderBits
  of error_too_short: TooShort
  of error_too_long: TooLong
  of error_over_long: OverLong
  of error_too_large: TooLarge
  of error_invalid_base64_character: InvalidBase64Character
  of error_base64_input_remainder: BaseInputRemainder
  of error_output_buffer_too_small: OutputBufferTooSmall
  of error_other: Other
  else: assert false, "Invalid simdutf_result error code: " & $res.error; Success
  native.count = res.count.uint

  native

func resultToString*(res: simdutf_result): string {.inline.} =
  case res.error
  of error_success: "Success"
  of error_header_bits: "Byte at position $1 has more than 5 header bits!" % [$res.count]
  of error_too_short: "At position $1; the leading byte must be followed by N-1 continuation bytes, where N is the continuation UTF-8 character length." % [$res.count]
  of error_too_long:
    if res.count == 0: "Input cannot start with a continuation byte!"
    else: "At position $1; too many consecutive continuation bytes were found!" % [$res.count]
  of error_surrogate: "At position $1; this character is either in U+D800..DFFF. If it is a high surrogate, it must be followed by a low surrogate and that low surrogate must be preceded by a high surrogate (this character) or no surrogate at all (Latin1)." % [$res.count]
  of error_invalid_base64_character: "At position $1; invalid character detected whilst decoding base64-encoded string!" % [$res.count]
  of error_base64_input_remainder: "This base64-encoded string ends with a single character, excluding the padding symbols."
  of error_output_buffer_too_small: "The output buffer provided is too small to fit the entire decoded segment!"
  of error_other: "An error occured which is not related to validation or transcoding."
  else: "Unhandled error code provided (" & $res.error & ')'
