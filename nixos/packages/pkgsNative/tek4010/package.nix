{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config, 
  wrapGAppsHook3,
  gtk3,
  cairo,
}:
stdenv.mkDerivation {
  pname = "tek4010";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "Llamato";
    repo = "Tek4010";
    rev = "master";
    hash = "sha256-5wUEIdiZSbC2yq0pCU2lVdwaa+QEADIZOqEGYa7mH4c=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    cairo
  ];

  postPatch = ''
    substituteInPlace makefile --replace-fail 'pkg-config' "${pkg-config}/bin/pkg-config"
  '';

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tek4010 $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tek4010 - Tektronix 4010 emulator";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}