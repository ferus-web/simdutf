# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "Nim bindings to simdutf"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
taskRequires "benchmark", "benchy", "lorem"

task benchmark, "Run the benchmark against std/base64":
  exec "nim cpp --define:release --define:speed --out:benchmark --run examples/benchmark.nim"
