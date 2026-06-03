{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4fe8d07066f6ea82cda2b0c9ae7aee59b2d241b3.tar.gz";
    sha256 = "sha256:06jzngg5jm1f81sc4xfskvvgjy5bblz51xpl788mnps1wrkykfhp";
  }) { },
}:
pkgs.stdenv.mkDerivation rec {
  pname = "ssacli";
  version = "6.50-11.0";

  src = builtins.fetchurl {
    url = "https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1736097809/v262718/ssacli-6.50-11.0.x86_64.rpm";
    sha256 = "0f61x3iy8wj169zass6sp765rhb9khgifzrhqd9ykv1fx0c1spgm";
  };

  nativeBuildInputs = [
    pkgs.rpmextract
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.ncurses
    pkgs.glibc
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  installPhase = ''
    mkdir -p $out

    # Copy binaries
    if [ -d opt/smartstorageadmin/ssacli ]; then
      mkdir -p $out/bin
      cp -r opt/smartstorageadmin/ssacli/bin/* $out/bin/ 2>/dev/null || true
      
      # Copy libraries
      if [ -d opt/smartstorageadmin/ssacli/lib ]; then
        mkdir -p $out/lib
        cp -r opt/smartstorageadmin/ssacli/lib/* $out/lib/ 2>/dev/null || true
      fi
      
      # Copy other resources
      if [ -d opt/smartstorageadmin/ssacli ]; then
        mkdir -p $out/share/ssacli
        cp -r opt/smartstorageadmin/ssacli/* $out/share/ssacli/ 2>/dev/null || true
      fi
    fi

    # Copy any documentation
    if [ -d usr/share ]; then
      mkdir -p $out/share
      cp -r usr/share/* $out/share/ 2>/dev/null || true
    fi
  '';

  postFixup = ''
    # Ensure binaries can find their libraries
    for bin in $out/bin/*; do
      if [ -f "$bin" ] && [ -x "$bin" ]; then
        patchelf --set-rpath "$out/lib:${pkgs.lib.makeLibraryPath buildInputs}" "$bin" 2>/dev/null || true
      fi
    done
  '';

  meta = with pkgs.lib; {
    description = "HPE Smart Storage Administrator CLI";
    homepage = "https://www.hpe.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
