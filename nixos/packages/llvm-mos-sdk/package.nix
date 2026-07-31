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
in stdenv.mkDerivation rec {
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
    llvm-mos
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

  # Set environment for the build
  preConfigure = ''
    export LLVM_MOS_TOOLCHAIN_DIR=${llvm-mos}
    export LLVM_MOS_TOOLCHAIN_ROOT=${llvm-mos}
    export PATH=${llvm-mos}/bin:$PATH
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir build
    cd build
    cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$out -DLLVM_MOS_TOOLCHAIN_DIR=${llvm-mos} -DLLVM_MOS_TOOLCHAIN_ROOT=${llvm-mos} $src
    ninja install
    # Fix broken symlinks by creating the targets
  cd $out/bin
  for link in mos-*-clang mos-*-clang++ mos-*-clang-cpp; do
    if [ -L "$link" ]; then
      target=$(readlink "$link")
      if [ ! -e "$target" ]; then
        # Create a wrapper script instead of a symlink
        rm "$link"
        cat > "$link" << EOF
#!/bin/sh
exec ${llvm-mos}/bin/$target --sysroot="$out" "\$@"
EOF
        chmod +x "$link"
      fi
    fi
  done
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
