## A high level wrapper over simdutf's unicode utilities.
## Copyright (C) 2024 Trayambak Rai and Ferus Authors
import simdutf/[bindings, shared]

type
  Encoding* {.pure.} = enum
    UTF8
    UTF16
    UTF32
    Latin1
    Unspecified

  Endianness* {.pure.} = enum
    Little
    Big
    None

  EncodingInfo* = object
    encoding*: Encoding
    endianness*: Endianness

func wrap(encoding: encoding_type): Encoding {.inline.} =
  case encoding
  of encoding_utf8: Encoding.UTF8
  of encoding_utf16_le, encoding_utf16_be: Encoding.UTF16
  of encoding_utf32_le, encoding_utf32_be: Encoding.UTF32
  of encoding_latin1: Encoding.Latin1
  of encoding_unspecified: Encoding.Unspecified
  else:
    raise newException(ValueError, "Invalid encoding: " & $encoding)

func wrapEndianness(encoding: encoding_type): Endianness {.inline.} =
  case encoding
  of encoding_utf8, encoding_unspecified: Endianness.None
  of encoding_utf16_le, encoding_utf32_le: Endianness.Little
  of encoding_utf16_be, encoding_utf32_be: Endianness.Big
  else:
    raise newException(ValueError, "Invalid encoding: " & $encoding)

func encodingInfo(
  encoding: encoding_type
): EncodingInfo {.inline.} =
  EncodingInfo(
    encoding: encoding.wrap(),
    endianness: encoding.wrapEndianness()
  )

proc autodetectEncoding*(input: string): EncodingInfo {.inline.} =
  ## This function tries to detect the encoding of a string.
  encodingInfo(
    autodetectEncoding(
      input.cstring, input.len.cuint
    )
  )

proc validateUtf8*(input: string): bool {.inline.} =
  ## Validate a UTF-8 string.
  ## This should be used when you're confident that the encoding isn't erroneous.
  ## Otherwise, use `validateUtf8WithErrors`
  validateUtf8(input.cstring, input.len.cuint)

proc validateUtf8WithErrors*(input: string): SimdutfResult {.inline.} =
  ## Validate a UTF-8 string.
  ## This function is suitable for untrusted input.
  simdutfResult(validateUtf8WithErrors(input.cstring, input.len.cuint))

proc validateAscii*(input: string): bool {.inline.} =
  ## Validate an ASCII string.
  ## This should be used when you're confident that the encoding isn't erroneous.
  ## Otherwise, use `validateAsciiWithErrors`
  validateAscii(input.cstring, input.len.cuint)

proc validateAsciiWithErrors*(input: string): SimdutfResult {.inline.} =
  ## Validate an ASCII string.
  ## This function is suitable for untrusted input.
  simdutfResult(validateUtf8WithErrors(input.cstring, input.len.cuint))
