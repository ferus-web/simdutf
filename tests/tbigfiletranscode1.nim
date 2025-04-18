import simdutf/base64

let content = readFile("tests/vectors/mfwebsite.html")

let encoded = encode(content, urlSafe = true)
echo encoded

let decoded = decode(encoded, urlSafe = true)
echo decoded
