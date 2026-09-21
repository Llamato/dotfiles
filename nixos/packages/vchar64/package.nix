{
  stdenv,
  qt6,
  cmake,
  fetchFromGitHub,
  lib,
  pkgsBuildBuild,
}:
let
  qttoolsBuild = pkgsBuildBuild.qt6.qttools;
  qttools = pkgsBuildBuild.runCommand "qttools-tools" { } ''
    mkdir -p $out/bin
    for b in ${qttoolsBuild}/bin/*; do
      ln -s "$b" $out/bin/$(basename "$b")
    done
  '';
in
stdenv.mkDerivation {
  pname = "vchar64";
  version = "1.0.5";
  src = fetchFromGitHub {
    owner = "ricardoquesada";
    repo = "vchar64";
    rev = "c99c5320aa3d8a704b67ff1470c571e3ac11009d";
    hash = "sha256-+1UlMS63+sQj2/JZ/kT9T6V//Hf8neioJDk8f9HhbPs=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    qttools
  ];

  buildInputs = [
    qt6.qtbase
  ];

  cmakeDir = "..";
  cmakeFlags = [
    "-DQT_HOST_PATH=${pkgsBuildBuild.qt6.qtbase}"
    "-DQt6LinguistTools_DIR=${qttoolsBuild}/lib/cmake/Qt6LinguistTools"
    "-DQt6ToolsTools_DIR=${qttoolsBuild}/lib/cmake/Qt6ToolsTools"
  ];

  meta = with lib; {
    description = "Charset editor for the Commodore 64";
    homepage = "https://github.com/ricardoquesada/vchar64";
    license = licenses.asl20;
    platforms = platforms.linux;
    #maintainers = with maintainers; [ llamato ];
  };
}
