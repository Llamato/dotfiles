{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  python3,
  libffi,
  libxml2,
  autoPatchelfHook,
  pkg-config,
  zlib,
  SDL2,
  zmusic,
  libvpx,
  libbacktrace,
  ncurses,
  callPackage
}: let
  llvm-mos = (callPackage ../llvm-mos/package.nix {}); #Temporary
in stdenv.mkDerivation {
  pname = "llvm-mos-sdk";
  version = "23.0.1";

  src = fetchFromGitHub {
    owner = "llvm-mos";
    repo = "llvm-mos-sdk";
    tag = "v23.0.1";
    fetchSubmodules = true;
    hash = "sha256-6/+4+1WnU5awmhgrwEKW6w7yhW6PWlhyNwYnd9bk3fI=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    libxml2
    libffi
    SDL2
    zmusic
    libvpx
    libbacktrace
    ncurses
    llvm-mos
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir build
    cd build
    cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$out $out
    runHook postInstall
  '';

  meta = {
    description = "LLVM-MOS C compiler for 6502-based systems";
    homepage = "https://llvm-mos.org/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ llamato ];
  };
}
