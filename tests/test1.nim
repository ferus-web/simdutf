import std/unittest
import simdutf/base64

suite "base64 module":
  test "encode":
    check base64.encode("hello world") == "aGVsbG8gd29ybGQ="

  test "decode":
    check base64.decode("aGVsbG8gdGhlcmU=") == "hello there"

  test "decode vector":
    check base64.decodeSeq("aGVsbG8gdGhlcmU=") ==
      @[104, 101, 108, 108, 111, 32, 116, 104, 101, 114, 101]
