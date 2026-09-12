{
  lib,
  stdenv,
  openjdk25,
  unzip,
}:
let
  sources = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-darwin" = "macos-aarch64";
  };
  sysfolder = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "multipaint";
  version = "2026.1";
  src = builtins.fetchurl {
    url = "https://multipaint.kameli.net/multipaint_P4.zip";
    sha256 = "1xyi1n2kqcaqksyzdibi28h99v79lk08kjphvqh8ih3wgz3720jd";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    unzip
  ];

  buildInputs = [
    openjdk25
  ];

  unpackPhase = ''
    unzip $src
    mkdir -p $out/bin
    mkdir -p $out/share/multipaint
    ls multipaint
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r multipaint $out
    mv $out/multipaint $out/bin
  '';

  meta = with lib; {
    description = "Multipaint reto bitmap";
    homepage = "https://multipaint.kameli.net/";
    license = licenses.unfree;
    platforms = with attrsets; attrNames sources;
    #+maintainers = with maintainers; [ llamato ];
  };
}
