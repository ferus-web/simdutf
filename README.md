# High-level wrapper over simdutf
This package provides a nice little interface over [simdutf](https://github.com/simdutf/simdutf), a fast, cross-architecture SIMD accelerated library for base64 encoding and decoding alongside encoding validation and conversion.

The low level bindings are present in `simdutf/bindings`, but do not use them unless you know what you're doing. The high level wrapper is memory safe* as it validates all allocations to be of the correct sizes to prevent buffer overflows.

# How fast is it?
Here's a benchmark to show that. (Run this for yourselves with `nimble benchmark`)

**Device**: Laptop \
**CPU**: AMD Ryzen 5 5600H @ 4.20Ghz with 12 cores \
**RAM**: 16 GB of DDR4 @ 3200 MT/s + 24GB of swap (not used in this benchmark)

```
$ nimble benchmark
> generating sentences ...
> sentences generated; may the most optimized win
   min time    avg time  std dv   runs name
   0.337 ms    0.373 ms  ±0.016  x1000 encode 1000 strings (simdutf)
   2.741 ms    2.825 ms  ±0.039  x1000 encode 1000 strings (std/base64)
```

# Real-World Usage
This library was initially bound to Nim for [bali](https://github.com/ferus-web/bali), a JavaScript engine written in Nim. It'll hopefully soon fully replace `std/base64` from the entirity of the Ferus' web engine's stack.

# Usage (Base64)
The API is almost the same as `std/base64`.
```nim
import simdutf/base64

for i, name in [
    "Joseph",
    "Andreas",
    "James",
    "Thomas",
    "Monika",
    "Prateek",
    "Ahmad",
    "Anton",
]:
  echo name.encode(urlSafe = (i mod 2) == 0) # We support URL safe encoding too
```

# Usage (Unicode)
The unicode wrapper is still very much a work-in-progress. Most of the functions in the unicode module aren't wrapped yet. Feel free to send PRs, though :)
```nim
import simdutf/unicode

assert validateUtf8("Hello simdutf!")
assert validateAscii("This is ascii, isn't it?")
```
