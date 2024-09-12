import std/unittest
import simdutf/unicode

suite "unicode module":
  test "encoding detection":
    check autodetectEncoding("hello there!").encoding == Encoding.UTF8

  test "encoding verification":
    check validateUtf8("yee-haw, pardner.")
    check validateUtf8("guh-nome is a nice looking desktop environment")
    check validateAscii("hello there! this is technically ascii!")
    check validateUtf16("你好，世界")
