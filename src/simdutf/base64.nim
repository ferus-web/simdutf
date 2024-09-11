## High level wrapper over simdutf's base64 encoders/decoders
## Copyright (C) 2024 Trayambak Rai and Ferus Authors
import std/options
import simdutf/[bindings, shared]
import results

type
  Base64DecodeError* = object of ValueError
    ## An error that is raised when the Base64 decoder fails to decode a string.

proc calculateEncodedLength*(input: string, urlSafe: bool = false): uint {.inline.} =
  ## Calculate the length of `input` when it would be encoded with Base64.
  ## If you want to account for URL-safe encoding, make sure to pass `urlSafe` as `true`!
  uint(base64LengthFromBinary(
    input.len.cuint,
    if urlSafe: base64_url else: base64_default
  ))

proc calculateDecodedLength*(input: string): uint {.inline.} =
  ## Calculate the length of `input` when it would be decoded, granted that it is a valid Base64-encoded string.
  uint(maximalBinaryLengthFromBase64(
    input.cstring, input.len.cuint
  ))

proc encode*(input: string, urlSafe: bool = false): string =
  ## Encode a string using base64. Optionally, encode it to be URL-safe.
  ## This function is guaranteed to succeed.

  # NOTE: To whomever it may concern,
  # If you mess with this allocation, please keep this in mind:
  # Do NOT mess with how the buffer size is calculated! If the buffer is too small,
  # we can potentially trigger a buffer overflow. Therefore, do not touch it unless you know what
  # you're doing. If I've scared you away from messing with it, then that's probably a good thing.
  var output = 
    when not compileOption("threads"):
      alloc(
        base64LengthFromBinary(
          input.len.cuint,
          if urlSafe:
            base64_url
          else:
            base64_default
        )
      )
    else:
      allocShared(
        base64LengthFromBinary(
          input.len.cuint,
          if urlSafe:
            base64_url
          else:
            base64_default
        )
      )
  
  # Convert the input to a `const char *` and pass it over to simdutf.
  let 
    inpCstring = input.cstring
    length = binaryToBase64(
      inpCstring, 
      input.len.cuint, 
      output,
      if urlSafe:
        base64_url
      else:
        base64_default
    )
  
  # Cast the output pointer to a `const char *` and convert that to a string and deep copy it. Now, we're in Nim-land so the GC is responsible for cleaning up this Nim
  # string.
  let encoded = deepCopy($cast[cstring](output))
  
  # However, Nim isn't responsible for cleaning the buffer we allocated earlier, so free it up.
  when not compileOption("threads"):
    dealloc(output)
  else:
    deallocShared(output)

  encoded

proc decode*(input: string, urlSafe: bool = false): string =
  ## Decode a base64-encoded string, given that it's valid.
  ## If this string was encoded with URL-safety enabled, make sure to enable that here as well.
  
  # NOTE: If you ever make changes around this allocation, please keep the following in mind:
  # Do NOT fiddle with how the length of the buffer is calculated! If the buffer is too small, then
  # we can potentially trigger a buffer overflow. `maximalBinaryLengthFromBase64` ensures that that doesn't
  # occur, so do not mess around with this unless you're _completely_ sure of what you're doing.
  var output = 
    when not compileOption("threads"):
      alloc(
        maximalBinaryLengthFromBase64(input.cstring, input.len.cuint)
      )
    else:
      allocShared(
        maximalBinaryLengthFromBase64(input.cstring, input.len.cuint)
      )

  let
    inpCstring = input.cstring
    decodeResult = base64ToBinary(
      inpCstring,
      input.len.cuint,
      output,
      if urlSafe:
        base64_url
      else:
        base64_default
    )

  if decodeResult.error != error_success:
    raise newException(
      Base64DecodeError,
      resultToString(decodeResult)
    )
  
  let decoded = deepCopy($cast[cstring](output))

  when not compileOption("threads"):
    dealloc(output)
  else:
    deallocShared(output)

  decoded

proc decodeOrError*(input: string, urlSafe: bool = false): Result[string, string] {.inline.} =
  ## Try decoding a base64-encoded string, and return an error upon failure. 
  ## This is meant for people who do not like using exceptions and works the same way as the main decode function.
  try:
    return ok(input.decode(
      urlSafe = urlSafe
    ))
  except Base64DecodeError as exc:
    return err(exc.msg)

proc tryDecode*(input: string, urlSafe: bool = false): Option[string] {.inline.} =
  ## Try decoding a base64-encoded string and return an empty Option upon failure.
  ## This is meant for people who don't wish to use exceptions and just use options instead. It works the
  ## same way as the main decode function.
  try:
    return some(input.decode(
      urlSafe = urlSafe
    ))
  except Base64DecodeError:
    return none(string)
