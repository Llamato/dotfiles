{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4fe8d07066f6ea82cda2b0c9ae7aee59b2d241b3.tar.gz";
    sha256 = "sha256:06jzngg5jm1f81sc4xfskvvgjy5bblz51xpl788mnps1wrkykfhp";
  }) {}
}: 
pkgs.stdenv.mkDerivation {
  pname = "llvm-mos";
  version = "23.0.1";
  src = fetchTarball {
    url = "https://github.com/llvm-mos/llvm-mos-sdk/releases/download/v23.0.1/llvm-mos-linux.tar.xz";
    sha256 = "05bhyj1ilyh52v4lcxd9brxdmj7g91n19vyajadjc8rr2y1qb6q1";
  };

  installPhase = ''
    mkdir -p $out/
    cp -R * $out/
  '';
}