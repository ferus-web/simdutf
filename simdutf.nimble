# Package

version       = "5.5.0"
author        = "xTrayambak"
description   = "Nim bindings to simdutf"
license       = "Apache-2.0"
srcDir        = "src"
backend       = "cpp"

# Dependencies

requires "nim >= 2.0.0"
requires "results >= 0.5.0"
taskRequires "benchmark", "benchy", "lorem"

task benchmark, "Run the benchmark against std/base64":
  exec "nim cpp --define:release --define:speed --out:benchmark --run examples/benchmark.nim"
