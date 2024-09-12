import std/unittest
import simdutf/base64

suite "base64 module":
  test "encode":
    check base64.encode("hello world") == "aGVsbG8gd29ybGQ="

  test "decode":
    check base64.decode("aGVsbG8gdGhlcmU=") == "hello there"
