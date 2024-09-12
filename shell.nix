with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
    pkg-config
    simdutf
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    simdutf
  ];
}
