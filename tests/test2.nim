import std/unittest
import simdutf/unicode

suite "unicode module":
  test "encoding detection":
    assert autodetectEncoding("hello there!").encoding == Encoding.UTF8

  test "encoding verification":
    assert validateUtf8("yee-haw, pardner.")
    assert validateUtf8("guh-nome is a nice looking desktop environment")
    assert validateAscii("hello there! this is technically ascii!")
