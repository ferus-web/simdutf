# requires: benchy, lorem
import std/base64 as std
import simdutf/base64 as simdutf
import benchy, lorem

var sentences: array[1001, string]

echo "> generating sentences ..."
for x in 0 .. 1000:
  if x mod 2 == 0:
    sentences[x] = sentence()
  else:
    sentences[x] = essay()

echo "> sentences generated; may the most optimized win"

timeIt "encode 1000 strings (simdutf)":
  for sentence in sentences:
    let encoded = simdutf.encode(sentence)

timeIt "encode 1000 strings (std/base64)":
  for sentence in sentences:
    let encoded = std.encode(sentence)
