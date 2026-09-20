{ stdenv
, qt6
, cmake
, fetchFromGitHub
, lib
, pkgsBuildBuild
}:

let
  version = "1.0.5";

  # Build‑platform qttools, built normally with its own qtbase.
  qttoolsBuild = pkgsBuildBuild.qt6.qttools;

  # Wrapper that exposes only the qttools binaries.
  # It has no setup hook and does not propagate qtbase.
  qttoolsTools = pkgsBuildBuild.runCommand "qttools-tools" { } ''
    mkdir -p $out/bin
    for b in ${qttoolsBuild}/bin/*; do
      ln -s "$b" $out/bin/$(basename "$b")
    done
  '';
in
stdenv.mkDerivation {
  inherit version;
  pname = "vchar64";
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
    qttoolsTools            # only the binaries, no Qt setup hook
    qt6.wrapQtAppsHook      # target wrap hook (provides wrapQtApp)
  ];

  buildInputs = [
    qt6.qtbase              # target Qt libraries (the only Qt setup hook)
  ];

  cmakeDir = "..";

  cmakeFlags = [
    # Point CMake to the build‑platform Qt for host tools.
    "-DQT_HOST_PATH=${pkgsBuildBuild.qt6.qtbase}"
    # Point to the build‑platform Linguist tools.
    "-DQt6LinguistTools_DIR=${qttoolsBuild}/lib/cmake/Qt6LinguistTools"
    "-DQt6ToolsTools_DIR=${qttoolsBuild}/lib/cmake/Qt6ToolsTools"
  ];

  # Disable automatic wrapping; wrap manually with the target qtbase.
  dontWrapQtApps = true;

  fixupPhase = ''
    runHook preFixup
    wrapQtApp $out/bin/vchar64 \
      --prefix QT_PLUGIN_PATH : ${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}
    runHook postFixup
  '';

  meta = with lib; {
    description = "Charset editor for the Commodore 64";
    homepage = "https://github.com/ricardoquesada/vchar64";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}