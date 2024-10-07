## A high level wrapper over simdutf's unicode utilities.
## Copyright (C) 2024 Trayambak Rai and Ferus Authors
import simdutf/[bindings, shared]

type
  UnicodeError* = object of ValueError
    ## An error that occurs in the unicode module.

  UTF8ToUTF16ConversionFailed* = object of UnicodeError
  UTF8ToUTF32ConversionFailed* = object of UnicodeError

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

proc validateUtf16*(input: string): bool =
  ## Validate a UTF-16 string.
  ## This should be used when you're confident that the encoding isn't erroneous.
  ## Otherwise, use `validateUtf16WithErrors`.
  var memory =
    when not compileOption("threads"):
      alloc(
        utf16LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )
    else:
      allocShared(
        utf16LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )

  var buffer = cast[ptr UncheckedArray[uint16]](memory)
  if convertUtf8ToUtf16LittleEndianWithErrors(input.cstring, input.len.cuint, buffer).error != error_success:
    raise newException(
      UTF8ToUTF16ConversionFailed,
      "Failed to convert string from UTF-8 to UTF-16 (LE): " & input
    )

  let validation = validateUtf16LittleEndian(buffer, input.len.cuint)
  
  when not compileOption("threads"):
    dealloc(memory)
  else:
    deallocShared(memory)

  validation

proc validateUtf32*(
  input: string
): bool =
  ## Validate a UTF-32 string.
  ## This should be used when you're confident that the encoding isn't erroneos.
  ## Otherwise, use `validateUtf32WithErrors`
  var memory =
    when not compileOption("threads"):
      alloc(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )
    else:
      allocShared(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )

  var buffer = cast[ptr UncheckedArray[uint32]](memory)
  if convertUtf8ToUtf32LittleEndianWithErrors(input.cstring, input.len.cuint, buffer).error != error_success:
    raise newException(
      UTF8ToUTF32ConversionFailed,
      "Failed to convert string from UTF-8 to UTF-32 (LE): " & input
    )

  let validation = validateUtf32LittleEndian(buffer, input.len.cuint)
  
  when not compileOption("threads"):
    dealloc(memory)
  else:
    deallocShared(memory)

  validation

proc validateUtf16WithErrors*(input: string): SimdutfResult =
  ## Validate a UTF-16 string.
  ## This function is ideal for untrusted inputs.
  var memory =
    when not compileOption("threads"):
      alloc(
        utf16LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )
    else:
      allocShared(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )

  var buffer = cast[ptr UncheckedArray[uint16]](memory)
  if convertUtf8ToUtf16LittleEndianWithErrors(input.cstring, input.len.cuint, buffer).error != error_success:
    raise newException(
      UTF8ToUTF16ConversionFailed,
      "Failed to convert string from UTF-8 to UTF-32 (LE): " & input
    )

  let validation = validateUtf16LittleEndianWithErrors(buffer, input.len.cuint)
  
  when not compileOption("threads"):
    dealloc(memory)
  else:
    deallocShared(memory)

  simdutfResult(validation)

proc validateUtf32WithErrors*(
  input: string
): SimdutfResult =
  ## Validate a UTF-32 string.
  ## This function is ideal for untrusted inputs.
  var memory =
    when not compileOption("threads"):
      alloc(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )
    else:
      allocShared(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )

  var buffer = cast[ptr UncheckedArray[uint32]](memory)
  if convertUtf8ToUtf32LittleEndianWithErrors(input.cstring, input.len.cuint, buffer).error != error_success:
    raise newException(
      UTF8ToUTF32ConversionFailed,
      "Failed to convert string from UTF-8 to UTF-32 (LE): " & input
    )

  let validation = validateUtf32LittleEndianWithErrors(buffer, input.len.cuint)
  
  when not compileOption("threads"):
    dealloc(memory)
  else:
    deallocShared(memory)

  simdutfResult(validation)

proc convertUtf8ToUtf16*(input: string, endianness: Endianness = Endianness.Little): seq[uint16] =
  ## Convert a valid UTF-8 string to UTF-16 encoded bytes.
  var memory =
    when not compileOption("threads"):
      alloc(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )
    else:
      allocShared(
        utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
      )

  var buffer = cast[ptr UncheckedArray[uint16]](memory)
  var size: int
  case endianness
  of Endianness.Little:
    if (let res = convertUtf8ToUtf16LittleEndianWithErrors(input.cstring, input.len.cuint, buffer); res.error == error_success):
      size = res.count.int
    else:
      raise newException(
        UTF8ToUTF16ConversionFailed,
        "Failed to convert string from UTF-8 to UTF-16 (LE): " & input
      )
  of Endianness.Big:
    if (let res = convertUtf8ToUtf16BigEndianWithErrors(input.cstring, input.len.cuint, buffer); res.error == error_success):
      size = res.count.int
    else:
      raise newException(
        UTF8ToUTF16ConversionFailed,
        "Failed to convert string from UTF-8 to UTF-16 (BE): " & input
      )
  of Endianness.None: discard

  when not compileOption("threads"):
    dealloc(memory)
  else:
    deallocShared(memory)

  let utf16Length = size

  var final = newSeq[uint16](utf16Length)
  for x in 0 ..< utf16Length:
    final[x] = buffer[][x]

  final

proc countCodepoints*(input: string, info: sink EncodingInfo = EncodingInfo(endianness: Endianness.None)): uint =
  ## Count the number of Unicode codepoints in this string
  ## It is acceptable to pass invalid UTF-8 strings but in such cases
  ## the result is implementation defined.
  
  if info.endianness == None:
    # autodetect the encoding, we weren't provided anything.
    info = autodetectEncoding(input)
  
  case info.encoding
  of UTF8:
    return uint(countUtf8(input.cstring, input.len.csize_t))
  of UTF16:
    case info.endianness
    of Little:
      var memory = when not compileOption("threads"):
        alloc(
          utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
        )
      else:
        allocShared(
          utf32LengthFromUtf8(input.cstring, input.len.cuint) + 1.cuint
        )
      
      var buffer = cast[ptr UncheckedArray[uint16]](memory)
      let converted = convertUtf8ToUtf16(input, Endianness.Little)

      for i, u16 in converted:
        buffer[i] = u16

      return uint(countUtf16LittleEndian(buffer, converted.len.csize_t))
    of Big: return
    else: assert false, "unreachable"
  else: discard
