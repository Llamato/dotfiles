{
  lib,
  stdenv,
  unzip,
  jre,
  makeWrapper
}:
let
  sources = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-darwin" = "macos-aarch64";
  };
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
    makeWrapper
  ];

  buildInputs = [
    jre
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    shopt -s extglob
    cp -r multipaint/${sources."${stdenv.hostPlatform.system}"}/!(multipaint) $out/share
    makeWrapper ${jre}/bin/java $out/bin/multipaint \
    --add-flags "-Djna.nosys=true \
      -Djava.library.path=$out/share/lib \
      -cp $out/share/lib/multipaint.jar:$out/share/lib/jogl-all.jar:$out/share/lib/gluegen-rt.jar:$out/share/lib/core.jar \
      multipaint"
  '';

  meta = with lib; {
    description = "Multipaint reto bitmap editor";
    homepage = "https://multipaint.kameli.net/";
    license = lib.licenses.unfreeRedistributable;
    platforms = with attrsets; attrNames sources;
    #maintainers = with maintainers; [ llamato ];
  };
}
